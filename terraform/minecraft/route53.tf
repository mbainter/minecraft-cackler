resource "aws_route53_zone" "mc-trampledstones-com" {
  name = "mc.trampledstones.com"

  tags = {
    Name      = "mc.trampledstones.com"
    Service   = "Minecraft"
    ManagedBy = "Terraform"
  }
}

resource "aws_route53_record" "bifrost-mc-a" {
  zone_id = aws_route53_zone.mc-trampledstones-com.zone_id
  name    = "bifrost.mc.litmus.com"
  type    = "A"
  ttl     = "60"

  records = [
    aws_instance.minecraft.public_ip
  ]
}

resource "aws_route53_record" "test-mc-a" {
  zone_id = aws_route53_zone.mc-trampledstones-com.zone_id
  name    = "test.mc.litmus.com"
  type    = "A"
  ttl     = "60"

  records = [
    aws_instance.minecraft_test.public_ip
  ]
}
