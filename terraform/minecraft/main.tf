resource "aws_ebs_volume" "minecraft_world_test" {
  availability_zone = var.az
  encrypted         = true

  type = "gp3"
  size = 15

  tags = {
    Name        = "MinecraftWorld-Test"
    Service     = "Minecraft"
    Environment = "test"
  }
}

resource "aws_instance" "minecraft_test" {
  ami           = data.aws_ami.ubuntu_arm64.id
  instance_type = var.mc_instance_type
  subnet_id     = tolist(data.aws_subnet_ids.public.ids)[0]
  key_name      = "mbainter"
  user_data     = file("${path.module}/user_data.yaml")

  availability_zone      = var.az
  vpc_security_group_ids = [aws_security_group.minecraft.id]

  #tfsec:ignore:AWS012
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.minecraft.name

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name        = "Minecraft-Test"
    Service     = "Minecraft"
    Environment = "test"
  }
}

resource "aws_volume_attachment" "minecraft_world_test" {
  device_name = "/dev/sdh"

  volume_id   = aws_ebs_volume.minecraft_world_test.id
  instance_id = aws_instance.minecraft_test.id
}

#resource "local_file" "ansible_inventory" {
#  content = templatefile("inventory.tmpl", {
#    ips = [
#      aws_instance.minecraft.public_ip
#      aws_instance.minecraft_test.public_ip
#    ],
#  })
#
#  filename = format("%s/%s", abspath(path.root), "inventory.yaml")
#}

resource "aws_ebs_volume" "minecraft_world" {
  availability_zone = var.az
  encrypted         = true

  type = "gp3"
  size = 15

  tags = {
    Name        = "MinecraftWorld"
    Service     = "Minecraft"
    Environment = "test"
  }
}

# TODO
# - increase root volume size at launch
resource "aws_instance" "minecraft" {
  ami           = data.aws_ami.ubuntu_arm64.id
  instance_type = var.mc_instance_type
  subnet_id     = tolist(data.aws_subnet_ids.public.ids)[0]
  key_name      = "mbainter"
  user_data     = file("${path.module}/user_data.yaml")

  availability_zone      = var.az
  vpc_security_group_ids = [aws_security_group.minecraft.id]

  #tfsec:ignore:AWS012
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.minecraft.name

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 10
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name        = "Minecraft"
    Service     = "Minecraft"
    Environment = "test"
  }
}

resource "aws_volume_attachment" "minecraft_world" {
  device_name = "/dev/sdh"

  volume_id   = aws_ebs_volume.minecraft_world_test.id
  instance_id = aws_instance.minecraft_test.id
}
