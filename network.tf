resource "aws_vpc" "minecraft_server_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = local.tags
}

resource "aws_subnet" "minecraft_server_public_subnet" {
  vpc_id = aws_vpc.minecraft_server_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = format("%s%s", local.region, "a") # plop this in the first AZ in the region, cause we're bad developers
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

resource "aws_security_group" "minecraft_server_allow_ssh" {
  name = "${local.env}-minecraft-server-sg"
  vpc_id = aws_vpc.minecraft_server_vpc.id

  egress {
    from_port = 0
    protocol  = -1
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = [
    {
      cidr_blocks = [
        "104.107.159.250/32"
      ]
      description = "gonzo"
      from_port = 22
      protocol = "tcp"
      to_port = 22
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }, {
      cidr_blocks = [
        "208.190.140.213/32"
      ]
      description = "Me"
      from_port = 22
      protocol = "tcp"
      to_port = 22
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }, {
      cidr_blocks = [
        "76.218.39.198/32"
      ]
      description = "sushi"
      from_port = 22
      protocol = "tcp"
      to_port = 22
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }, {
      from_port = 25565
      protocol  = "tcp"
      to_port   = 25565
      cidr_blocks = ["0.0.0.0/0"]
      description = "Minecraft server port"
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = local.tags
}