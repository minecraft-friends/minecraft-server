#data "aws_caller_identity" "current" {}

# Grants permissions to the minecraft server to access other resources
resource "aws_iam_policy" "minecraft_server_policy" {
  name = "minecraft-server-policy"
  path = "/"
  description = "Policy to provide permissions for the minecraft server"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.snapshot_bucket}/*"
      }
    ]
  })

  tags = local.tags
}
# !!!! EXAMPLE POLICY ONLY !!!!
#      {
#        Effect = "Allow"
#        Action = [
#          "ssm:GetParameters",
#          "ssm:GetParameter"
#        ],
#        Resource = "arn:aws:ssm:${var.region}:${accountId}:parameter/dev*"
#      },

# Allow ec2 instances assigned the role to assume the role
resource "aws_iam_role" "minecraft_server_role" {
  name = "minecraft-server"
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
  name = "minecraft-server-role-attachment"
  roles = [aws_iam_role.minecraft_server_role.name]
  policy_arn = aws_iam_policy.minecraft_server_policy.arn
}

# Create an instance profile from the role with the attached policy
resource "aws_iam_instance_profile" "minecraft_server_profile" {
  name = "minecraft-server-ip"
  role = aws_iam_role.minecraft_server_role.name
}