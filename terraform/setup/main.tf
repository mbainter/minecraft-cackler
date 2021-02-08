variable "state_bucket_name" {}
variable "dynamodb_table_name" {}

resource "aws_dynamodb_table" "dynamodb-state-lock" {
  # checkov:skip=CKV_AWS_28:Point in time recovery is unnecessary for the lock table
  name           = var.dynamodb_table_name
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }
}

#tfsec:ignore:AWS002
resource "aws_s3_bucket" "tf-state" {
  # checkov:skip=CKV_AWS_18:Not paying for logging terraform state changes in this account
  # checkov:skip=CKV_AWS_52:MFA delete won't work for this automated terraform use
  bucket = var.state_bucket_name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "tf-state" {
  bucket = aws_s3_bucket.tf-state.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "DenyRiskyAccessWithoutValidMFA",
    "Statement": [
        {
            "Sid": "ProtectSensitiveBucketOps",
            "Effect": "Deny",
            "Principal": "*",
            "Action": [
                "s3:DeleteBucket",
                "s3:PutBucket*",
                "s3:GetBucketAcl",
                "s3:GetBucketPolicy"
            ],
            "Resource": [
                "arn:aws:s3:::${var.state_bucket_name}/*",
                "arn:aws:s3:::${var.state_bucket_name}"
            ],
            "Condition": {
                "Bool": {
                    "aws:MultiFactorAuthPresent": "false"
                }
            }
        },
        {
            "Sid": "AllowAccessBasedOnIAMPolicy",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::833233943383:root"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.state_bucket_name}/*",
                "arn:aws:s3:::${var.state_bucket_name}"
            ]
        }
    ]
}
POLICY
}
