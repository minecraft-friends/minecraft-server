module "minecraft_discord_bot" {
  source = "./modules/minecraft-discord-bot"
  config_bucket_key_name = "config.json"
  config_bucket_name = "minecraft-discord-bot"
  ecs_subnet_id = aws_subnet.private_subnet.id
  ecs_task_image = "622452799301.dkr.ecr.us-west-2.amazonaws.com/minecraft-discord-bot:latest"
  env = local.environment
  tags = local.tags
  region = local.region
  minecraft_server_ec2_instance_id = aws_instance.minecraft_server.id
}
