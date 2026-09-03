provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "rdicidr"
      Component = "bootstrap"
      ManagedBy = "Terraform"
    }
  }
}
