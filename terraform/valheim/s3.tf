#tfsec:ignore:AWS002
resource "aws_s3_bucket" "valheim_usw2" {
  provider = aws.us-west-2

  bucket        = "mordheim-valheim-backups"
  force_destroy = false

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "global"
    enabled = true

    prefix = "/"

    expiration {
      days = 10
    }
  }

  tags = {
    Name      = "mordheim-valheim-backups"
    Service   = "Valheim"
    ManagedBy = "Terraform"
  }
}

##tfsec:ignore:AWS002
resource "aws_s3_bucket" "valheim" {
  bucket        = "bainterfam-valheim-backups"
  force_destroy = false

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "global"
    enabled = true

    prefix = "/"

    expiration {
      days = 10
    }
  }

  tags = {
    Name      = "valheim-backups"
    Service   = "Valheim"
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy_document" "valheim_backups" {
  policy_id = "ValheimBackupsPolicy"

  statement {
    sid = "AllowGeneralBucketAccess"

    principals {
      type = "AWS"
      identifiers = concat(
        formatlist("arn:aws:iam::%s:user/%s", local.account_id, concat(var.valheim_backups_admins, var.valheim_backups_ro)),
        [aws_iam_role.valheim_backup.arn]
      )
    }

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]

    resources = [aws_s3_bucket.valheim.arn]
  }

  statement {
    sid = "AllowBucketAdminAccess"

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:user/%s", local.account_id, var.valheim_backups_admins)
    }

    actions = [
      "s3:DeleteBucket",
    ]

    resources = [aws_s3_bucket.valheim.arn]

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
      identifiers = formatlist("arn:aws:iam::%s:user/%s", local.account_id, var.valheim_backups_admins)
    }

    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    resources = ["${aws_s3_bucket.valheim.arn}/*"]

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
      identifiers = formatlist("arn:aws:iam::%s:user/%s", local.account_id, var.valheim_backups_ro)
    }
    actions = [
      "s3:GetObject*",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    resources = ["${aws_s3_bucket.valheim.arn}/*"]

    condition {
      test     = "Null"
      variable = "aws:MultiFactorAuthAge"

      values = [
        "true"
      ]
    }
  }

  statement {
    sid = "AllowValheimRoleAccess"

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.valheim_backup.arn
      ]
    }

    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    resources = ["${aws_s3_bucket.valheim.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "valheim" {
  bucket = aws_s3_bucket.valheim.id
  policy = data.aws_iam_policy_document.valheim_backups.json
}
