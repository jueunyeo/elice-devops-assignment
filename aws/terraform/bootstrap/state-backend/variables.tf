# 이 구성은 Terraform Remote State 저장소(S3)와 State Locking(DynamoDB)을 사전에 준비합니다.
# 협업 환경에서 동시 apply 충돌을 방지하기 위해 환경별 backend 자원을 분리합니다.

variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "project" {
  description = "Project prefix for naming convention"
  type        = string
  default     = "elice"
}
