module "app" {
  source = "../../modules/app"

  env             = "stage"
  aws_region      = var.aws_region
  container_image = var.container_image
  desired_count   = var.desired_count
}
