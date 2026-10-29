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
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
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
  description = "Your public IP in /32 CIDR notation for SSH access"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_ip_cidr)) && endswith(var.admin_ip_cidr, "/32")
    error_message = "Security Policy: admin_ip_cidr must be a valid single-host IPv4 CIDR ending in /32 (never 0.0.0.0/0)."
  }
}

variable "instance_type" {
  description = "EC2 instance type (restricted for cost control)"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small"], var.instance_type)
    error_message = "Cost Guardrail: Only t3.micro and t3.small are permitted in this lab."
  }
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key for EC2 access"
  type        = string
  default     = "~/.ssh/hybrid_infra_ed25519.pub"
}
