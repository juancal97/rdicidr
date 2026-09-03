########################################
# Pre-existing GitHub OIDC provider
########################################

# Created manually in the account. NEVER create it here - only read it.
data "aws_iam_openid_connect_provider" "github" {
  arn = var.github_oidc_provider_arn
}

########################################
# Remote Terraform state bucket
########################################

resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################################
# ECR repository (immutable, scan on push)
########################################

resource "aws_ecr_repository" "app" {
  name                 = var.app_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

########################################
# CD roles - one per environment
########################################

# Subject claims MUST use GitHub's immutable-ID prefix (var.github_sub_claim_prefix).
data "aws_iam_policy_document" "cd_assume" {
  for_each = toset(var.environments)

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = each.key == "devel" ? [
        "${var.github_sub_claim_prefix}:environment:devel",
        "${var.github_sub_claim_prefix}:ref:refs/heads/devel",
        ] : [
        "${var.github_sub_claim_prefix}:environment:stage",
      ]
    }
  }
}

resource "aws_iam_role" "cd" {
  for_each = toset(var.environments)

  name                 = "${var.app_name}-cd-${each.key}"
  assume_role_policy   = data.aws_iam_policy_document.cd_assume[each.key].json
  max_session_duration = 3600
}

# Broad build/deploy permissions. PowerUserAccess excludes IAM writes, so the
# task/execution roles are handled by the scoped inline policy below.
resource "aws_iam_role_policy_attachment" "cd_poweruser" {
  for_each = aws_iam_role.cd

  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

data "aws_iam_policy_document" "cd_iam" {
  statement {
    sid    = "ManageAppScopedRoles"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:ListRoleTags",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:ListInstanceProfilesForRole",
    ]
    resources = ["arn:aws:iam::${var.aws_account_id}:role/${var.app_name}-*"]
  }

  statement {
    sid       = "PassAppScopedRoles"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${var.aws_account_id}:role/${var.app_name}-*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cd_iam" {
  for_each = aws_iam_role.cd

  name   = "${var.app_name}-cd-iam"
  role   = each.value.name
  policy = data.aws_iam_policy_document.cd_iam.json
}
