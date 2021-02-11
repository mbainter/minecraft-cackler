data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource aws_iam_role "packer_build" {
  name               = "packer-build"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "packer_build" {
  name = aws_iam_role.packer_build.name
  role = aws_iam_role.packer_build.name
}

data "aws_iam_policy_document" "packer_build" {
  statement {
    sid = "AllowLambdaTriggers"

    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync",
      "lambda:GetAlias",
      "lambda:ListAliases",
      "lambda:ListFunctions",
      "lambda:ListVersionsByFunction",
    ]

    resources = ["arn:aws:lambda:${local.region}:${local.account_id}:function:*"]
  }

  statement {
    sid    = "AllowListRoles"
    effect = "Allow"

    actions = [
      "iam:ListRoles",
      "iam:ListInstanceProfiles",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "HashicorpRecommendedPolicy"
    effect = "Allow"

    actions = [
      "ec2:AttachVolume",
      "ec2:AssociateIamInstanceProfile",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateLaunchTemplate",
      "ec2:DeleteLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcs",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:ReplaceIamInstanceProfileAssociation",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowKMSAccess"
    effect = "Allow"

    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowRoleAccess"
    effect = "Allow"

    actions = [
      "iam:PassRole",
      "iam:GetInstanceProfile"
    ]

    resources = [
      aws_iam_role.packer_build.arn,
      aws_iam_instance_profile.packer_build.arn
    ]
  }
}

resource "aws_iam_policy" "packer_build" {
  name        = "packer-build"
  description = "IAM Policy to allow packer to function"
  path        = "/"
  policy      = data.aws_iam_policy_document.packer_build.json
}

resource "aws_iam_role_policy_attachment" "packer_build_base" {
  role       = aws_iam_role.packer_build.name
  policy_arn = aws_iam_policy.packer_build.arn
}

resource "aws_iam_role_policy_attachment" "packer_build_ssm" {
  role       = aws_iam_role.packer_build.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
