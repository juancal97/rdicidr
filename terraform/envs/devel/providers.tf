provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "rdicidr"
      Environment = "devel"
      ManagedBy   = "Terraform"
    }
  }
}
