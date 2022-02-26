resource "aws_cloudwatch_log_group" "minecraft_discord_bot" {
  name = "${var.env}_minecraft_discord_bot"
  retention_in_days = 7
  tags = var.tags
}
