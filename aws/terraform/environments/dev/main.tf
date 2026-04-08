# 환경별 인프라 진입점으로, 동일 모듈을 재사용하면서도 dev/stage/prod의 정책 차이를 변수로 분리합니다.
# 운영 시에는 변경 영향도를 계획(plan)으로 먼저 검증한 뒤 순차적으로 적용하는 것을 권장합니다.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  name_prefix = "elice-${var.environment}"

  common_tags = {
    Project     = "elice"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                  = local.name_prefix
  cidr_block            = var.vpc_cidr
  azs                   = var.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  single_nat_gateway    = var.single_nat_gateway
  tags                  = local.common_tags
}

# Dev environment: keep resource quota intentionally low for cost control.
module "eks" {
  source = "../../modules/eks"

  name               = "${local.name_prefix}-eks"
  kubernetes_version = "1.30"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  node_group_name    = "primary"
  instance_types         = var.eks_instance_types
  desired_size           = var.eks_desired_size
  min_size               = var.eks_min_size
  max_size               = var.eks_max_size
  eso_allowed_secret_arns = var.eso_allowed_secret_arns
  tags               = local.common_tags
}

module "database" {
  source = "../../modules/database"

  identifier              = "${local.name_prefix}-postgres"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  engine_version          = "16.3"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  multi_az                = false
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.database_subnet_ids
  allowed_cidr_blocks     = [var.vpc_cidr]
  deletion_protection     = false
  backup_retention_period = var.db_backup_retention_period
  tags                    = local.common_tags
}

module "storage" {
  source = "../../modules/storage"

  bucket_name        = "${local.name_prefix}-artifacts"
  versioning_enabled = true
  force_destroy      = var.storage_force_destroy
  tags               = local.common_tags
}
