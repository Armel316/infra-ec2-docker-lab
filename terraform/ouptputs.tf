output "public_ip" {
  description = "Public IP of EC2"
  value       = aws_instance.react_lab.public_ip
}