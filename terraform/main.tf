terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "ap-south-1"
}
resource "aws_vpc" "qa_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "qa-eks-vpc"
    Environment = "QA"
    Project     = "eks-production-lab"
  }
}
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.qa_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "qa-public-a"
    Environment = "QA"
    Project     = "eks-production-lab"
    Type        = "public"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.qa_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "qa-public-b"
    Environment = "QA"
    Project     = "eks-production-lab"
    Type        = "public"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.qa_vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "qa-private-a"
    Environment = "QA"
    Project     = "eks-production-lab"
    Type        = "private"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.qa_vpc.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags = {
    Name        = "qa-private-b"
    Environment = "QA"
    Project     = "eks-production-lab"
    Type        = "private"
  }
}

resource "aws_internet_gateway" "qa_igw" {
  vpc_id = aws_vpc.qa_vpc.id

  tags = {
    Name        = "qa-igw"
    Environment = "QA"
    Project     = "eks-production-lab"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.qa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.qa_igw.id
  }

  tags = {
    Name        = "qa-public-rt"
    Environment = "QA"
    Project     = "eks-production-lab"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.qa_vpc.id

  tags = {
    Name        = "qa-private-rt"
    Environment = "QA"
    Project     = "eks-production-lab"
  }
}
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
resource "aws_security_group" "alb" {
  name        = "qa-alb-sg"
  description = "Security group for QA application load balancer"
  vpc_id      = aws_vpc.qa_vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "qa-alb-sg"
    Environment = "QA"
    Project     = "eks-production-lab"
  }
}