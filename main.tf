terraform {
  cloud {
    organization = "bbachkala"

    workspaces {
      name = "lyon"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

module "ami-ubuntu" {
  source  = "andreswebs/ami-ubuntu/aws"
  version = "1.1.0"
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.5.0"
  count   = 1

  name = "ec2-nginx"

  ami                    = module.ami-ubuntu.ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io -y
              sudo service docker start
              sudo usermod -aG docker ubuntu
              sudo docker run -d -p 80:80 --rm bbachkaladocker/lyon
              sudo docker run -d --name watchtower --interval 60 -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower
              EOF
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "nginx_sg" {
  name   = "nginx_sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
