# Availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = var.vpc_tags
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.igw_tags
}

# Subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidrs["public_a"]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_a"
  }
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidrs["public_b"]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_b"
  }
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidrs["private_a"]
  tags = {
    Name = "private_a"
  }
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidrs["private_b"]
  tags = {
    Name = "private_b"
  }
  availability_zone = data.aws_availability_zones.available.names[1]
}

# Route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public route table"
  }
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_default_route_table" "private_rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = "Private route table"
  }
}

# Route table association
resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_association" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_default_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_association" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_default_route_table.private_rt.id
}

# Security group
resource "aws_security_group" "my_instance_sg" {
  name        = "my_instance_sg"
  description = "Control access to my_instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.local_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.local_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "db_subnet_group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  tags = {
    Name = "rds_subnet_group"
  }
}

# RDS security group
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Control access to the db"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      aws_security_group.my_instance_sg.id
    ]
  }
}
