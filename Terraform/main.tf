resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("/home/sysadmin/Devops-AWS-project/Terraform/my-pub-key.pub")

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Security Group Configuration
resource "aws_security_group" "network_security_group" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH, HTTP, HTTPS and other traffic"
  vpc_id      = "vpc-0974c46ec995891de"  

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Jenkins HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Agent"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-security-group"
  }
}

# User Data for SSH Installation
locals {
  ssh_user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh
  EOF
}

# Function to create instances
resource "aws_instance" "cicdcd" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network_security_group.id]
  subnet_id              = var.subnet_id
  associate_public_ip_address = true  
  user_data = local.ssh_user_data

  tags = {
    Name = "${var.project_name}-CI/CD"
  }
}

resource "aws_instance" "test" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network_security_group.id]
  subnet_id              = var.subnet_id
  associate_public_ip_address = true  
  user_data = local.ssh_user_data

  tags = {
    Name = "${var.project_name}-Test"
  }
}

resource "aws_instance" "production" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network_security_group.id]
  subnet_id              = var.subnet_id
  associate_public_ip_address = true
  user_data = local.ssh_user_data

  tags = {
    Name = "${var.project_name}-Production"
  }
}

resource "aws_instance" "monitoring" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network_security_group.id]
  subnet_id              = var.subnet_id
  associate_public_ip_address = true
  user_data = local.ssh_user_data

  tags = {
    Name = "${var.project_name}-Monitoring"
  }
}

# Output public DNS and IPs
output "all_public_info" {
  value = {
    CI_CD = {
      public_dns = aws_instance.cicdcd.public_dns
      public_ip  = aws_instance.cicdcd.public_ip
    }
    Test = {
      public_dns = aws_instance.test.public_dns
      public_ip  = aws_instance.test.public_ip
    }
    Production = {
      public_dns = aws_instance.production.public_dns
      public_ip  = aws_instance.production.public_ip
    }
    Monitoring = {
      public_dns = aws_instance.monitoring.public_dns
      public_ip  = aws_instance.monitoring.public_ip
    }
  }
  description = "Public DNS and IPs of all instances"
}

# Store all public DNS content in a single file
resource "local_file" "all_public_dns" {
  content = <<-EOF
    cicdcd_public_dns = "${aws_instance.cicdcd.public_dns}"
    test_public_dns = "${aws_instance.test.public_dns}"
    production_public_dns = "${aws_instance.production.public_dns}"
    monitoring_public_dns = "${aws_instance.monitoring.public_dns}"
  EOF
  filename = "all_public_dns.txt"
}
