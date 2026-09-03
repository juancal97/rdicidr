terraform {
  backend "s3" {
    bucket       = "rdicidr-tfstate-488463488153"
    key          = "envs/stage/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
