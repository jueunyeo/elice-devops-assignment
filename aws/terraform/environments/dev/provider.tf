provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-${var.environment}"
  }

  default_tags {
    tags = {
      Project     = "elice"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
