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
  # backend_names: { env => { bucket, lock_table } }
  backend_names = {
    dev = {
      bucket     = "${var.project}-dev-terraform-state"
      lock_table = "${var.project}-dev-terraform-locks"
    }
    stage = {
      bucket     = "${var.project}-stage-terraform-state"
      lock_table = "${var.project}-stage-terraform-locks"
    }
    prod = {
      bucket     = "${var.project}-prod-terraform-state"
      lock_table = "${var.project}-prod-terraform-locks"
    }
  }
}

resource "aws_s3_bucket" "tf_state" {
  for_each = local.backend_names

  bucket        = each.value.bucket
  force_destroy = false

  tags = {
    Project     = var.project
    Environment = each.key
    Purpose     = "terraform-state"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  for_each = local.backend_names
  bucket   = aws_s3_bucket.tf_state[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  for_each = local.backend_names
  bucket   = aws_s3_bucket.tf_state[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  for_each = local.backend_names
  bucket   = aws_s3_bucket.tf_state[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  for_each = local.backend_names

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.tf_state[each.key].arn,
      "${aws_s3_bucket.tf_state[each.key].arn}/*"
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
  for_each = local.backend_names

  bucket = aws_s3_bucket.tf_state[each.key].id
  policy = data.aws_iam_policy_document.deny_insecure_transport[each.key].json
}

resource "aws_dynamodb_table" "tf_locks" {
  for_each = local.backend_names

  name         = each.value.lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project     = var.project
    Environment = each.key
    Purpose     = "terraform-locking"
  }
}

resource "aws_dynamodb_table_point_in_time_recovery" "tf_locks" {
  # PITR improves lock table recoverability during operational incidents.
  for_each = local.backend_names

  table_name                 = aws_dynamodb_table.tf_locks[each.key].name
  point_in_time_recovery_enabled = true
}
