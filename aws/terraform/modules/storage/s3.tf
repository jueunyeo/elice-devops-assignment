# 공통 Terraform 모듈로, 반복되는 인프라 Provisioning 로직을 캡슐화해 운영 일관성을 높입니다.
# 모듈 입력값은 환경 특성(가용성/비용/보안)에 맞게 상위 environment에서 제어합니다.

locals {
  # S3 모듈 태그 정책(Tagging Policy):
  # - 플랫폼 공통 식별자(Project)로 운영 일관성을 유지합니다.
  common_tags = merge(var.tags, {
    Project = "elice"
  })
}

resource "aws_s3_bucket" "this" {
  # 버킷 명명 규칙 권장:
  # - {project}-{purpose}-{env} (예: elice-media-prod)
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Name = var.bucket_name
  })
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for ${var.bucket_name} encryption"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${var.bucket_name}-kms"
  })
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${replace(var.bucket_name, "_", "-")}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
