module "minecraft_discord_bot" {
  source = "./modules/minecraft-discord-bot"
  config_bucket_key_name = "discord-bot-config.json"
  config_bucket_name = "dev-minecraft-snapshots-298urhg"
  ecs_subnet_id = aws_subnet.minecraft_server_public_subnet.id
  ecs_task_image = "553590173470.dkr.ecr.us-east-1.amazonaws.com/minecraft-friends/minecraft-discord-bot:latest"
  env = local.environment
  tags = local.tags
  region = local.region
  minecraft_server_ec2_instance_id = aws_instance.minecraft_server.id
}
