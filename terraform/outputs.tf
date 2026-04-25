output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "app_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.app_server.public_ip}:${var.app_port}"
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_instance.app_server.public_ip}:8080"
}
