# Create the VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# Create the DHCP options set
resource "aws_vpc_dhcp_options" "main" {
  domain_name          = var.dhcp_options["domain_name"]
  domain_name_servers  = [var.dhcp_options["domain_name_servers"]]
}

# Associate the DHCP options set with the VPC
resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

# Create the internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Create the public subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-public-${count.index}"
  }
}

# Attach the public subnets to the internet gateway
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Create the private subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = element(var.availability_zones, count.index)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-private-${count.index}"
  }
}

# Create the NAT gateway
resource "aws_nat_gateway" "main" {
  count = length(var.availability_zones)
  allocation_id = aws_eip.main[count.index].id
  subnet_id = element(aws_subnet.public.*.id, count.index)
}

# Create the EIPs for the NAT gateways
resource "aws_eip" "main" {
  count = length(var.availability_zones)
}

# Create the route table for the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-public"
  }
}

# Create the route table for the private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-private"
  }
}

# Add the routes to the public route table
resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# Add the routes to the private route table
resource "aws_route" "private_nat_gateway" {
  count = length(var.availability_zones)
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
}

# Associate the private subnets with the route table
resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}