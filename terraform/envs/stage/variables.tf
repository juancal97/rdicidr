variable "aws_region" {
  type        = string
  description = "AWS region."
  default     = "us-east-1"
}

variable "container_image" {
  type        = string
  description = "ECR image URI with an immutable :<git-sha> tag. Passed by CD at apply time."
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks."
  default     = 2
}
