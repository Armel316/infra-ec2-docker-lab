provider "aws" {
  region = var.aws_region
}

# =========================
# Ubuntu 24.04 officielle
# =========================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =========================
# VPC par défaut
# =========================
data "aws_vpc" "default" {
  default = true
}

# =========================
# Clé SSH (publique locale)
# =========================
resource "aws_key_pair" "deployer" {
  key_name   = "terraform-react-lab-key"
  public_key = file("${path.module}/keys/id_ed25519.pub")
}

# =========================
# Security Group
# =========================
resource "aws_security_group" "react_sg" {
  name        = "react-lab-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # LAB ONLY
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # LAB ONLY
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "react-lab-sg"
  }
}

# =========================
# EC2 Instance
# =========================
resource "aws_instance" "react_lab" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.react_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "terraform-react-lab"
  }
}