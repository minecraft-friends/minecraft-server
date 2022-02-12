resource "aws_vpc" "minecraft_server_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = local.tags
}

resource "aws_subnet" "minecraft_server_public_subnet" {
  vpc_id = aws_vpc.minecraft_server_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = format("%s%s", var.region, "a") # plop this in the first AZ in the region, cause we're bad developers
  tags = local.tags
}

resource "aws_internet_gateway" "minecraft_server_igw" {
  vpc_id = aws_vpc.minecraft_server_vpc.id
  tags = local.tags
}

resource "aws_route_table" "minecraft_server_route_table" {
  vpc_id = aws_vpc.minecraft_server_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft_server_igw.id
  }
  tags = local.tags
}

resource "aws_route_table_association" "minecraft_crt_association" {
  subnet_id = aws_subnet.minecraft_server_public_subnet.id
  route_table_id = aws_route_table.minecraft_server_route_table.id
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "minecraft_server_allow_ssh" {
  vpc_id = aws_vpc.minecraft_server_vpc.id

  egress {
    from_port = 0
    protocol  = -1
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = concat(["${chomp(data.http.myip.body)}/32"], compact(var.allow_ssh))
  }

  ingress {
    from_port = 25565
    protocol  = "tcp"
    to_port   = 25565
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}