# 환경별 인프라 진입점으로, 동일 모듈을 재사용하면서도 dev/stage/prod의 정책 차이를 변수로 분리합니다.
# 운영 시에는 변경 영향도를 계획(plan)으로 먼저 검증한 뒤 순차적으로 적용하는 것을 권장합니다.

terraform {
  backend "s3" {
    bucket         = "elice-prod-terraform-state"
    key            = "terraform/aws/prod/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "elice-prod-terraform-locks"
    encrypt        = true
  }
}
