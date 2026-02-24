provider "aws" {
  region = var.aws_region
}

# =========================
# Récupère Ubuntu 24.04 officielle
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
# Génère une clé SSH locale
# =========================
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Enregistre la clé publique dans AWS
resource "aws_key_pair" "deployer" {
  key_name   = "terraform-react-lab-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
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
}

# =========================
# EC2 Instance
# =========================
resource "aws_instance" "react_lab" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro" # Free tier
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