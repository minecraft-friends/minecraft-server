data "aws_caller_identity" "current" {}
locals {
  name = "${var.env}-minecraft-discord-bot"
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "minecraft_discord_bot_task_role" {
  name = local.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy_attachment" "minecraft_discord_bot_task_policy" {
  name   = "${var.env}_minecraft_discord_bot_lambda_logs"
  roles   = [aws_iam_role.minecraft_discord_bot_task_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "minecraft_discord_bot_s3_access" {
  name   = "${var.env}_minecraft_discord_bot_s3_access"
  role   = aws_iam_role.minecraft_discord_bot_task_role.name
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.config_bucket_name}/*"
        ]
      },
    ]
  })
}

data "aws_caller_identity" "current_id" {}

resource "aws_iam_role_policy" "minecraft_discord_bot_ec2_access" {
  name   = "${var.env}_minecraft_discord_bot_ec2_access"
  role   = aws_iam_role.minecraft_discord_bot_task_role.name
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances",
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:ec2::${data.aws_caller_identity.current_id.account_id}:instance/${var.minecraft_server_ec2_instance_id}"
        ]
      }, {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
        ],
        Effect = "Allow",
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "minecraft_discord_bot_logs_policy" {
  name   = "${var.env}_minecraft_discord_bot_lambda_logs"
  role   = aws_iam_role.minecraft_discord_bot_task_role.name
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:ListTagsLogGroup",
        ],
        Effect = "Allow",
        Resource = [
          aws_cloudwatch_log_group.minecraft_discord_bot.arn
        ]
      },
    ]
  })
}
