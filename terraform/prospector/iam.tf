data "aws_iam_instance_profile" "minecraft" {
  name = "minecraft-server"
}

data "aws_iam_policy_document" "prospector" {
  statement {
    sid = "RoleLockedAccess"

    actions = [
      "ec2:StartInstances",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "ec2:InstanceProfile"

      values = [
        data.aws_iam_instance_profile.minecraft.arn
      ]
    }
  }

  statement {
    sid = "ReadAccess"

    actions = [
      "ec2:DescribeTags",
      "ec2:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ReadInstanceProfiles"

    actions = [
      "iam:GetInstanceProfile",
      "iam:ListInstanceProfiles",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "prospector" {
  name        = "ProspectorEC2Access"
  path        = "/"
  description = "Access policy for Prospector to start and query the Minecraft server"

  policy = data.aws_iam_policy_document.prospector.json
}

resource "aws_iam_user" "prospector" {
  name = "prospector"
}

resource "aws_iam_access_key" "heroku" {
  user    = aws_iam_user.prospector.name
  pgp_key = "keybase:mbainter"
}

resource "aws_iam_user_policy_attachment" "prospector" {
  user       = aws_iam_user.prospector.name
  policy_arn = aws_iam_policy.prospector.arn
}
