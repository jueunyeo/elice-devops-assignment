# 이 구성은 Terraform Remote State 저장소(S3)와 State Locking(DynamoDB)을 사전에 준비합니다.
# 협업 환경에서 동시 apply 충돌을 방지하기 위해 환경별 backend 자원을 분리합니다.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  # Management account hosts all environment states.
  state_bucket_name = "${var.project}-management-terraform-state"
  lock_table_name   = "${var.project}-management-terraform-locks"
}

resource "aws_s3_bucket" "tf_state" {
  bucket        = local.state_bucket_name
  force_destroy = false

  tags = {
    Project     = var.project
    Environment = "management"
    Purpose     = "terraform-state"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.tf_state.arn,
      "${aws_s3_bucket.tf_state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "tf_state" {
  # Enforce TLS-only access for state buckets.
  bucket = aws_s3_bucket.tf_state.id
  policy = data.aws_iam_policy_document.deny_insecure_transport.json
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = local.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project     = var.project
    Environment = "management"
    Purpose     = "terraform-locking"
  }
}

resource "aws_dynamodb_table_point_in_time_recovery" "tf_locks" {
  # PITR improves lock table recoverability during operational incidents.
  table_name                 = aws_dynamodb_table.tf_locks.name
  point_in_time_recovery_enabled = true
}
