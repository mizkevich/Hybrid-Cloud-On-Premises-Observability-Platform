variable "aws_region" {
  description = "AWS region for deploying infrastructure"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "hybrid-infra"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (non-overlapping with WireGuard 10.10.0.0/24)"
  type        = string
  default     = "10.20.1.0/24"
}

variable "admin_ip_cidr" {
  description = "Your public IP in CIDR notation (e.g., 1.2.3.4/32) for SSH access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (t3.micro is Free Tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key for EC2 access"
  type        = string
  default     = "~/.ssh/hybrid_infra_ed25519.pub"
}
