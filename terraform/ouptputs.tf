output "public_ip" {
  description = "Public IP of EC2"
  value       = aws_instance.react_ec2.public_ip
}

output "alb_dns" {
  description = "Public URL of the load balancer"
  value       = aws_lb.react_alb.dns_name
}