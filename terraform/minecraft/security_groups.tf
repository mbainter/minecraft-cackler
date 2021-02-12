resource "aws_security_group" "minecraft" {
  name        = "minecraft"
  description = "Minecraft server instances"

  vpc_id = data.aws_vpc.target.id

  tags = {
    Name = "minecraft"
  }
}

resource "aws_security_group_rule" "minecraft_allow_ssh" {
  security_group_id = aws_security_group.minecraft.id
  description       = "Allow SSH to minecraft instances"

  type      = "ingress"
  from_port = 44390
  to_port   = 44390
  protocol  = "tcp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "minecraft_allow_clients" {
  security_group_id = aws_security_group.minecraft.id
  description       = "Allow client connections to minecraft instances"

  type      = "ingress"
  from_port = 25565
  to_port   = 25565
  protocol  = "tcp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "minecraft_allow_all_out" {
  security_group_id = aws_security_group.minecraft.id
  description       = "Allow all outbound access for Minecraft"

  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "all"
  #tfsec:ignore:AWS007
  cidr_blocks = ["0.0.0.0/0"]
}
