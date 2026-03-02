#VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
      Name = "${local.common_name}"
    }
  )
}

#IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,
    local.common_tags,
    {
      Name = "${local.common_name}"
    }
  )
}

#Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.public_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-public-${local.az_names[count.index]}"
    }
  )
}

#Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.private_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-private-${local.az_names[count.index]}"
    }
  )
}

#Database Subnets
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr_block[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.database_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-database-${local.az_names[count.index]}"
    }
  )
}

#Public Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.public_route_table_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-public"
    }
  )
}

#Private Route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route_table_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-private"
    }
  )
}

#Database Route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.database_route_table_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-database"
    }
  )
}

#Route Table add Public Subnet Association
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#Route Table add Public Subnet Association
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

#Route Table add Public Subnet Association
resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}


#Public route to IGW
resource "aws_route" "route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

#Elastic IP
resource "aws_eip" "nat" {
  #instance = aws_instance.web.id
  domain   = "vpc"

  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${local.common_name}"
    }
  )
}

#Nat Gateway on roboshop-dev-public-us-east-1a
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.nat_tags,
    local.common_tags,
    {
      Name = "${local.common_name} - gw NAT"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#Private route to Nat on Public
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

#Database route to Nat on Public
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}