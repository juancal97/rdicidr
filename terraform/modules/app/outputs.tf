output "alb_dns_name" {
  value       = aws_lb.app.dns_name
  description = "DNS name of the load balancer."
}

output "alb_url" {
  value       = "http://${aws_lb.app.dns_name}"
  description = "HTTP URL of the load balancer."
}

output "cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "ECS cluster name."
}

output "service_name" {
  value       = aws_ecs_service.app.name
  description = "ECS service name."
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.app.arn
  description = "Active task definition ARN."
}
