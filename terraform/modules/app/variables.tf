variable "env" {
  type        = string
  description = "Environment name (devel, stage). Used as the resource name prefix."
}

variable "aws_region" {
  type        = string
  description = "AWS region for deployment."
  default     = "us-east-1"
}

variable "app_name" {
  type        = string
  description = "Base application name."
  default     = "rdicidr"
}

variable "container_image" {
  type        = string
  description = "Fully-qualified ECR image URI including an immutable tag."
}

variable "container_port" {
  type        = number
  description = "Port the container listens on."
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "ALB target-group health check path."
  default     = "/health"
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks to run."
  default     = 2
}

variable "cpu" {
  type        = number
  description = "Fargate task CPU units."
  default     = 256
}

variable "memory" {
  type        = number
  description = "Fargate task memory (MiB)."
  default     = 512
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention in days."
  default     = 30
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "Grace period before the ECS service starts counting ALB health checks."
  default     = 60
}
