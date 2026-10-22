variable "aws_region" {
  description = "AWS region for the EC2 instance"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "jenkins-terraform-demo"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}
