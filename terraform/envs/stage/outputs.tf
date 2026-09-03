output "alb_url" {
  value       = module.app.alb_url
  description = "HTTP URL of the stage load balancer."
}

output "alb_dns_name" {
  value       = module.app.alb_dns_name
  description = "DNS name of the stage load balancer."
}

output "cluster_name" {
  value       = module.app.cluster_name
  description = "ECS cluster name."
}

output "service_name" {
  value       = module.app.service_name
  description = "ECS service name."
}
