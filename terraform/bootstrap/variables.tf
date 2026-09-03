variable "aws_region" {
  type        = string
  description = "AWS region for the shared account-level resources."
  default     = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID that owns these resources."
  default     = "488463488153"
}

variable "app_name" {
  type        = string
  description = "Base application name (ECR repo name, IAM role prefix)."
  default     = "rdicidr"
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "ARN of the PRE-EXISTING GitHub Actions OIDC provider. Data-sourced, never created."
  default     = "arn:aws:iam::488463488153:oidc-provider/token.actions.githubusercontent.com"
}

variable "github_sub_claim_prefix" {
  type        = string
  description = <<-EOT
    GitHub OIDC subject-claim prefix in immutable-ID form. Read at deploy time:
      gh api repos/juancal97/rdicidr/actions/oidc/customization/sub --jq .sub_claim_prefix
    Example: repo:juancal97@53842751/rdicidr@1355360558
    The plain "repo:owner/repo" form must NOT be used - it is why OIDC failed before.
  EOT
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket holding remote Terraform state."
  default     = "rdicidr-tfstate-488463488153"
}

variable "environments" {
  type        = list(string)
  description = "Deployment environments that get a CD role."
  default     = ["devel", "stage"]
}
