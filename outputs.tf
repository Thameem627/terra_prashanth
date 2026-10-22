output "instance_id" {
  description = "Created EC2 instance ID"
  value       = aws_instance.web.id
}

output "instance_ami" {
  description = "AMI used by the instance"
  value       = aws_instance.web.ami
}

output "instance_type" {
  description = "EC2 instance type"
  value       = aws_instance.web.instance_type
}

output "instance_public_ip" {
  description = "Public IP, if assigned"
  value       = aws_instance.web.public_ip
}
