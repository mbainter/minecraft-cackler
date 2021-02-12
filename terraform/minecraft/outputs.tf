output "minecraft_test_ip" {
  description = "Public ip address of the minecraft test instance"
  value       = aws_instance.minecraft_test.public_ip
}
