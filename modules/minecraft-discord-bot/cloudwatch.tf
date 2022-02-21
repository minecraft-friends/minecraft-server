resource "aws_cloudwatch_log_group" "minecraft_discord_bot" {
  name = "${var.env}_minecraft_discord_bot"
  tags = var.tags
}
