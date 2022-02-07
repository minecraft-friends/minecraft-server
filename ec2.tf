locals {
  tags = {
    project = "minecraft-server"
  }
}

# Find a candidate AMI on Ubuntu LTS with SSD-backed storage
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "minecraft_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_size
  key_name = var.ssh_key_name
  subnet_id = aws_subnet.minecraft_server_public_subnet.id
  vpc_security_group_ids = [aws_security_group.minecraft_server_allow_ssh.id]
  tags = local.tags
}

resource "aws_key_pair" "key_pair" {
  key_name = var.ssh_key_name
  public_key = file(var.ssh_key_path)
  tags = local.tags
}