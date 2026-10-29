resource "aws_security_group" "host_sg" {
  name        = "${var.project_name}-${var.environment}-host-sg"
  description = "Allow SSH from admin IP and WireGuard traffic; no public exporter ports"
  vpc_id      = aws_vpc.main.id

  # SSH strictly from your Admin IP
  ingress {
    description = "SSH from Admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_cidr]
  }

  # HTTP (8080) from Admin IP for testing our Session 9 Dockerized web workload
  ingress {
    description = "App HTTP from Admin IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_cidr]
  }

  # WireGuard UDP port
  ingress {
    description = "WireGuard VPN"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Node Exporter (9100) ONLY over the private WireGuard subnet (10.10.0.0/24)
  ingress {
    description = "Prometheus Node Exporter over WireGuard"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/24"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-host-sg"
  }
}
