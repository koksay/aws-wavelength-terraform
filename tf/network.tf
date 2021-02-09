resource "aws_vpc" "wl-vpc" {
  cidr_block       = "10.10.0.0/24"
  instance_tenancy = "default"
  tags = {
    Name = "wavelength-vpc"
  }
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "wl-public" {
  vpc_id            = aws_vpc.wl-vpc.id
  availability_zone = var.AWS_PUBLIC_AZ
  cidr_block        = "10.10.0.0/25"
  tags = {
    Name = "wl-bastion"
  }
}

resource "aws_subnet" "wl-carrier" {
  vpc_id            = aws_vpc.wl-vpc.id
  availability_zone = var.AWS_WL_AZ
  cidr_block        = "10.10.0.128/26"
  tags = {
    Name = "wl-carrier"
  }
}

resource "aws_ec2_carrier_gateway" "cgw" {
  vpc_id = aws_vpc.wl-vpc.id
  tags = {
    Name = "carrier-gw"
  }
}

resource "aws_route_table" "t" {
  vpc_id = aws_vpc.wl-vpc.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.wl-carrier.id
  route_table_id = aws_route_table.t.id
  depends_on     = [aws_route_table.t]
}

resource "null_resource" "carrier-gw-route" {
  provisioner "local-exec" {
    command = "aws ec2 create-route --destination-cidr-block 0.0.0.0/0 --route-table-id ${aws_route_table.t.id} --carrier-gateway-id ${aws_ec2_carrier_gateway.cgw.id}"
  }
  depends_on = [aws_ec2_carrier_gateway.cgw,aws_route_table.t,aws_route_table_association.a]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.wl-vpc.id
  tags = {
    Name = "internet-gw"
  }
}

resource "aws_route" "r" {
  route_table_id          = aws_vpc.wl-vpc.default_route_table_id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.igw.id
}

resource "aws_security_group" "allow_ssh_http_https" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH/HTTP/HTTPS inbound traffic"
  vpc_id      = aws_vpc.wl-vpc.id
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "allow_ssh_http_https"
  }
}
