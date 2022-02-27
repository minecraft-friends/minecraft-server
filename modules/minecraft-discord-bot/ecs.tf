resource "aws_ecs_service" "minecraft_discord_bot" {
  name            = "${var.env}_minecraft_discord_bot"
  cluster         = aws_ecs_cluster.minecraft_discord_bot.id
  task_definition = aws_ecs_task_definition.minecraft_discord_bot.arn
  launch_type = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets = [var.ecs_subnet_id]
  }
  tags = var.tags
}

resource "aws_ecs_cluster" "minecraft_discord_bot" {
  name = "${var.env}_minecraft_discord_bot"
  tags = var.tags
}

resource "aws_ecs_task_definition" "minecraft_discord_bot" {
  family = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn = aws_iam_role.minecraft_discord_bot_task_role.arn
  task_role_arn = aws_iam_role.minecraft_discord_bot_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "minecraft_discord_bot"
      image     = var.ecs_task_image
      cpu = var.ecs_task_container_cpu
      memory = var.ecs_task_container_memory
      environment= [
        {
          name = "BUCKET_NAME",
          value = var.config_bucket_name
        },
        {
          name = "BUCKET_KEY_NAME",
          value = var.config_bucket_key_name
        },
        {
          name = "EC2_INSTANCE_ID",
          value = var.config_bucket_key_name
        }
      ],
      runtime_platform = {
        operating_system_family = "LINUX"
        cpu_architecture        = "ARM64"
      },
      logConfiguration = {
        logDriver = "awslogs",
        options= {
          awslogs-group= aws_cloudwatch_log_group.minecraft_discord_bot.name,
          "awslogs-region": var.region,
          "awslogs-stream-prefix": "ecs"
        }
      },
      tags = var.tags
    }
  ])
  tags = var.tags
}

