#data "aws_caller_identity" "current" {}

# Grants permissions to the minecraft server to access other resources
resource "aws_iam_policy" "minecraft_server_policy" {
  name = "${local.env}-minecraft-server-policy"
  path = "/"
  description = "Policy to provide permissions for the minecraft server"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.snapshot_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.snapshot_bucket.bucket}",
        ]
      },
    ]
  })

  tags = local.tags
}

# Allow ec2 instances assigned the role to assume the role
resource "aws_iam_role" "minecraft_server_role" {
  name = "${local.env}-minecraft-server"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

# Attach the role to the policy specified
resource "aws_iam_policy_attachment" "minecraft_server_role_attachment" {
  name = "${local.env}-minecraft-server-role-attachment"
  roles = [
    aws_iam_role.minecraft_server_role.name
  ]

  # TODO: add creation of these users and alias these names
  users = [
    "gonzo-minecraft-server",
    "sushi-minecraft-server",
  ]
  groups = []
  policy_arn = aws_iam_policy.minecraft_server_policy.arn
}

# Create an instance profile from the role with the attached policy
resource "aws_iam_instance_profile" "minecraft_server_profile" {
  name = "${local.env}-minecraft-server-ip"
  role = aws_iam_role.minecraft_server_role.name
}