locals {
  env = split("-", split(".", terraform.workspace)[1])[0]
  device_name = "/dev/sdx"
  ssh_key_name = "${local.project_name}-key"
  tags = {
    project = local.project_name
    env = local.env
    server = "${local.env}-minecraft-server"
  }
}

# Find a candidate AMI on Ubuntu LTS with SSD-backed storage
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-${var.arch}-server-*"]
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
  key_name = "${local.env}-${local.ssh_key_name}"
  subnet_id = aws_subnet.minecraft_server_public_subnet.id
  vpc_security_group_ids = [aws_security_group.minecraft_server_allow_ssh.id]
  iam_instance_profile = aws_iam_instance_profile.minecraft_server_profile.name
  user_data_base64 = base64encode(
    templatefile("bootstrap.sh", {
      bucket = {
        bucket = aws_s3_bucket.snapshot_bucket.bucket
      }
      zip_root = var.zip_root
      start_script = var.start_script
      device_name = "/dev/nvme1n1"
      java = {
        type = "openjdk"
        version = "17"
      }
      snapshot = {
        name = split(".", var.snapshot)[0]
        ext = split(".", var.snapshot)[1]
      }
    })
  )

  lifecycle {
    ignore_changes = [
      ebs_block_device,
      public_ip,
    ]
  }

  # Add hidden dependency on S3 so the server doesn't try to start before it has the world
#  depends_on = [aws_s3_bucket_object.seed_snapshot]
  tags = local.tags
}

data "aws_s3_bucket_object" "server_ssh_key" {
  bucket = aws_s3_bucket.snapshot_bucket.bucket
  key = "ssh_key.pub"
}

resource "aws_key_pair" "key_pair" {
  key_name = "${local.env}-${local.ssh_key_name}"
#  public_key = file(var.ssh_key_path)
  public_key = data.aws_s3_bucket_object.server_ssh_key.body
  depends_on = [data.aws_s3_bucket_object.server_ssh_key]
  tags = local.tags
}

resource "aws_volume_attachment" "minecraft_world_volume_att" {
  device_name = local.device_name
  instance_id = aws_instance.minecraft_server.id
  volume_id   = aws_ebs_volume.minecraft_world_volume.id
}

# For modifications to the volume: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/requesting-ebs-volume-modifications.html#elastic-volumes-limitations
# Probably want to document how this works like: https://stackoverflow.com/questions/55265203/terraform-delete-all-resources-except-one
resource "aws_ebs_volume" "minecraft_world_volume" {
  tags = local.tags

  availability_zone = format("%s%s", local.region, "a") # plop this in the first AZ in the region, cause we're bad developers
  size = var.disk_space
  type = "gp3"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "minecraft_server_eip" {
  tags = local.tags
  instance = aws_instance.minecraft_server.id
  vpc = true
}