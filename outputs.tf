output "server_public_ip" {
  value = aws_eip.minecraft_server_eip.public_ip
}