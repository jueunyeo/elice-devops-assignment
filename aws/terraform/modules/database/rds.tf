# 공통 Terraform 모듈로, 반복되는 인프라 Provisioning 로직을 캡슐화해 운영 일관성을 높입니다.
# 모듈 입력값은 환경 특성(가용성/비용/보안)에 맞게 상위 environment에서 제어합니다.

locals {
  # RDS 모듈 공통 태그:
  # - Hybrid 환경 간 리소스 매핑 가독성을 위해 동일 키를 유지합니다.
  common_tags = merge(var.tags, {
    Project = "elice"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

resource "aws_security_group" "rds" {
  name        = "${var.identifier}-rds-sg"
  description = "RDS PostgreSQL access"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from trusted CIDRs"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.identifier}-rds-sg"
  })
}

resource "aws_kms_key" "rds" {
  description             = "KMS key for ${var.identifier} RDS encryption"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${var.identifier}-rds-kms"
  })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.identifier}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_db_instance" "postgres" {
  identifier                  = var.identifier
  engine                      = "postgres"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  storage_type                = "gp3"
  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.rds.arn
  db_name                     = var.db_name
  username                    = var.username
  password                    = var.password
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  backup_retention_period     = var.backup_retention_period
  backup_window               = "02:00-03:00"
  maintenance_window          = "sun:03:00-sun:04:00"
  # Multi-AZ 가용성(Availability):
  # - prod에서는 multi_az=true를 사용하여 AZ 장애 시 자동 Failover를 기대합니다.
  multi_az                    = var.multi_az
  deletion_protection         = true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.identifier}-final-snapshot"
  auto_minor_version_upgrade  = true
  performance_insights_enabled = true

  tags = merge(local.common_tags, {
    Name = var.identifier
  })
}
