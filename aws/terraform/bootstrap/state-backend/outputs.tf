# 이 구성은 Terraform Remote State 저장소(S3)와 State Locking(DynamoDB)을 사전에 준비합니다.
# 협업 환경에서 동시 apply 충돌을 방지하기 위해 환경별 backend 자원을 분리합니다.

output "state_buckets" {
  description = "Environment to S3 bucket mapping"
  value       = { for env, cfg in aws_s3_bucket.tf_state : env => cfg.bucket }
}

output "lock_tables" {
  description = "Environment to DynamoDB lock table mapping"
  value       = { for env, cfg in aws_dynamodb_table.tf_locks : env => cfg.name }
}
