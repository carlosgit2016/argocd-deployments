# VPC and igw
locals {
  availability_zones = ["us-east-1a", "us-east-1b"]
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_default_route_table" "example" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "default-rt"
  }
}

# SUBNETS
resource "aws_subnet" "public" {
  for_each          = toset(local.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${index(local.availability_zones, each.value) + 1}.0/24"
  availability_zone = each.value

  tags = {
    Name = "subnet-pub-${each.value}"
  }
}

resource "aws_subnet" "private" {
  for_each          = toset(local.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${index(local.availability_zones, each.value) + length(local.availability_zones) + 1}.0/24"
  availability_zone = each.value

  tags = {
    Name = "subnet-priv-${each.value}"
  }
}

# Public IP
resource "aws_eip" "example" {
  for_each = toset(local.availability_zones)
  domain   = "vpc"
}

# NAT public subnet
resource "aws_nat_gateway" "example" {
  for_each      = toset(local.availability_zones)
  allocation_id = aws_eip.example["${each.value}"].id
  subnet_id     = aws_subnet.public["${each.value}"].id

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "NAT gtw ${each.value}"
  }
}

# Route table and routes public subnet
# Route table and routes private subnet
resource "aws_route_table" "rt2" {
  for_each = toset(local.availability_zones)
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example["${each.value}"].id # Go through the NAT in the public subnet
  }

  tags = {
    Name = "private-subnet-${each.value}-rt"
  }
}

resource "aws_route_table_association" "rt_association" {
  for_each       = toset(local.availability_zones)
  subnet_id      = aws_subnet.private["${each.value}"].id
  route_table_id = aws_route_table.rt2["${each.value}"].id
}
