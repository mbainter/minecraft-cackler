#tfsec:ignore:AWS002
resource "aws_s3_bucket" "minecraft" {
  bucket        = var.minecraft_backups_bucket
  force_destroy = false

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name      = var.minecraft_backups_bucket
    Service   = "Minecraft"
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy_document" "minecraft_backups" {
  policy_id = "MinecraftBackupsPolicy"

  statement {
    sid = "AllowGeneralBucketAccess"

    principals {
      type = "AWS"
      identifiers = concat(
        formatlist("arn:aws:iam::%s:user/%s", local.account_id, concat(var.minecraft_backups_admins, var.minecraft_backups_admins)),
        [aws_iam_role.minecraft.arn]
      )
    }

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]

    resources = [aws_s3_bucket.minecraft.arn]
  }

  statement {
    sid = "AllowBucketAdminAccess"

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:user/%s", local.account_id, var.minecraft_backups_admins)
    }

    actions = [
      "s3:DeleteBucket",
    ]

    resources = [aws_s3_bucket.minecraft.arn]

    condition {
      test     = "Null"
      variable = "aws:MultiFactorAuthAge"

      values = [
        "true"
      ]
    }
  }

  statement {
    sid = "AllowFullAdminObjectAccess"

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:user/%s", local.account_id, var.minecraft_backups_admins)
    }

    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    resources = ["${aws_s3_bucket.minecraft.arn}/*"]

    condition {
      test     = "Null"
      variable = "aws:MultiFactorAuthAge"

      values = [
        "true"
      ]
    }
  }

  statement {
    sid = "AllowBackupReadObjectAccess"

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:user/%s", local.account_id, var.minecraft_backups_ro)
    }
    actions = [
      "s3:GetObject*",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    resources = ["${aws_s3_bucket.minecraft.arn}/*"]

    condition {
      test     = "Null"
      variable = "aws:MultiFactorAuthAge"

      values = [
        "true"
      ]
    }
  }

  statement {
    sid = "AllowResticRoleAccess"

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.minecraft.arn
      ]
    }

    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    resources = ["${aws_s3_bucket.minecraft.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "minecraft" {
  bucket = aws_s3_bucket.minecraft.id
  policy = data.aws_iam_policy_document.minecraft_backups.json
}
