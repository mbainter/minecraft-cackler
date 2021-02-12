data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "minecraft" {
  name               = "minecraft-server"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "minecraft" {
  name = aws_iam_role.minecraft.name
  role = aws_iam_role.minecraft.name
}

resource "aws_iam_role_policy_attachment" "minecraft_ssm" {
  role       = aws_iam_role.minecraft.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
