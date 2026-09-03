output "state_bucket" {
  value       = aws_s3_bucket.state.id
  description = "S3 bucket for remote Terraform state (native lockfile locking)."
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "ECR repository URL for the application image."
}

output "cd_role_arns" {
  value       = { for k, r in aws_iam_role.cd : k => r.arn }
  description = "CD role ARNs by environment."
}

output "github_oidc_provider_arn" {
  value       = data.aws_iam_openid_connect_provider.github.arn
  description = "ARN of the (pre-existing) GitHub OIDC provider."
}
