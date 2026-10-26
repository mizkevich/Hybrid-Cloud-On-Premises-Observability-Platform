output "vpc_id" {
  description = "ID of the provisioned VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the host security group"
  value       = aws_security_group.host_sg.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.monitoring_target.id
}

output "instance_public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value       = aws_instance.monitoring_target.public_ip
}

output "instance_private_ip" {
  description = "Private VPC IPv4 address of the EC2 instance"
  value       = aws_instance.monitoring_target.private_ip
}

output "ssh_command" {
  description = "Convenience command to SSH into the provisioned host"
  value       = "ssh -i ~/.ssh/hybrid_infra_ed25519 ubuntu@${aws_instance.monitoring_target.public_ip}"
}
