terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region_name
}


resource "aws_vpc" "customVPC" {
  cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.customVPC.id

  tags = {
    Name = "CustomVPC"
  }
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.customVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRT"
  }
}

resource "aws_subnet" "custom_public_sunet1" {
  vpc_id                  = aws_vpc.customVPC.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = var.az1
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "custom_public_sunet2" {
  vpc_id                  = aws_vpc.customVPC.id
  cidr_block              = var.subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone = var.az2
  
  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_route_table_association" "public_subnet_association1" {
  subnet_id      = aws_subnet.custom_public_sunet1.id
  route_table_id = aws_route_table.publicRT.id
}

resource "aws_route_table_association" "public_subnet_association2" {
  subnet_id      = aws_subnet.custom_public_sunet2.id
  route_table_id = aws_route_table.publicRT.id
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.custom_public_sunet1.id
  tags = {
    Name = "Harun-Terraform"
  }
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.customVPC.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_lb" "web_alb" {
  name               = "harunapp-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.custom_public_sunet1.id, aws_subnet.custom_public_sunet2.id]

  tags = {
    Environment = "lab"
  }
}




