variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "eu-west-3"
}

variable "vpc_id" {
  description = "ID of the VPC to use"
}

variable "subnet_id" {
  description = "ID of the subnet to use"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "my-key"
}

variable "project_name" {
  description = "Project name for tagging"
  default     = "DevOps_Project"
}

variable "ssh_cidr" {
  description = "IP range to allow SSH access"
  default     = "0.0.0.0/0"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  default     = "ami-040f38c176c3e6e6c"  
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
