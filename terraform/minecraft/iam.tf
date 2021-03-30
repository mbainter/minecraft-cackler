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

data "aws_iam_policy_document" "restic_s3" {
  statement {
    sid = "ResticS3BucketAccess"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]

    resources = [
      aws_s3_bucket.minecraft.arn,
    ]
  }

  statement {
    sid = "ResticS3ObjectAccess"

    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    resources = [
      "${aws_s3_bucket.minecraft.arn}/*",
    ]
  }

  statement {
    sid = "RoleLockedAccess"

    actions = [
      "ec2:StopInstances",
      "ec2:StartInstances",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "ec2:InstanceProfile"

      values = [
        aws_iam_instance_profile.minecraft.arn
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

  statement {
    sid = "ElbReadAccess"

    actions = [
      "elasticloadbalancing:Describe*",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ParameterStoreListAccess"

    actions = [
      "ssm:DescribeParameters"
    ]

    resources = ["*"]
  }

  statement {
    sid = "CreateRcloneVolume"

    actions = [
      "ec2:CreateVolume",
    ]

    resources = [
      "arn:aws:ec2:*:*:volume/*",
    ]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"

      values = [
        "Name",
        "Environment",
        "Service"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Name"

      values = [
        "RcloneBackup"
      ]
    }
  }

  statement {
    sid = "ManageMinecraftServerVolumes"

    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]

    resources = [
      "arn:aws:ec2:*:*:instance/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Service"

      values = [
        "Minecraft"
      ]
    }
  }

  statement {
    sid = "ManageRcloneVolume"

    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:DeleteVolume"
    ]

    resources = [
      "arn:aws:ec2:*:*:volume/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Name"

      values = [
        "RcloneBackup"
      ]
    }
  }

  statement {
    sid = "AllowTagCreationOnLaunch"

    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      "arn:aws:ec2:*:*:volume/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"

      values = [
        "CreateVolume"
      ]
    }
  }

  statement {
    sid = "ParameterStoreReadAccess"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = [
      "arn:aws:ssm:${local.region}:${local.account_id}:parameter/shared/minecraft/*",
    ]
  }

}

resource "aws_iam_policy" "restic_s3" {
  name        = "ResticMinecraftS3Access"
  path        = "/"
  description = "Access policy for Restic to make Minecraft backups"

  policy = data.aws_iam_policy_document.restic_s3.json
}

resource "aws_iam_role_policy_attachment" "restic_s3" {
  role       = aws_iam_role.minecraft.name
  policy_arn = aws_iam_policy.restic_s3.arn
}

data "aws_iam_policy_document" "route53" {
  statement {
    sid = "AllowEC2TagAccess"

    actions = ["ec2:DescribeTags"]

    resources = ["*"]
  }

  statement {
    sid = "AllowRoute53Updates"

    actions = ["route53:ChangeResourceRecordSets"]

    resources = [
      "arn:aws:route53:::hostedzone/${aws_route53_zone.mc-trampledstones-com.zone_id}"
    ]
  }
}

resource "aws_iam_policy" "route53" {
  name        = "Route53Access"
  path        = "/"
  description = "Access policy for Instances to make Route53 updates"

  policy = data.aws_iam_policy_document.route53.json
}

resource "aws_iam_role_policy_attachment" "route53" {
  role       = aws_iam_role.minecraft.name
  policy_arn = aws_iam_policy.route53.arn
}

resource "aws_iam_role_policy_attachment" "minecraft_ssm" {
  role       = aws_iam_role.minecraft.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
