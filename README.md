# Elice DevOps Infrastructure

본 프로젝트는 대규모 트래픽 처리가 가능한 **고가용성(High Availability)** 인프라와 **선언적 GitOps** 체계를 구축한 DevOps 레퍼런스 모델입니다. AWS 클라우드와 On-premise(vSphere) 환경을 각각 구성하였으며, 인프라의 모든 요소는 코드(IaC)로 관리됩니다.

---

## 🏗 1. MSA Service Architecture

전체 서비스는 마이크로서비스 아키텍처로 설계되어 독립적인 확장과 배포를 지원합니다.

### **Service Component**

- **API Gateway**: 모든 외부 요청의 진입점(Entrypoint)이며, 라우팅 및 통합 인증을 담당합니다.
- **Portal Web**: 사용자와 상호작용하는 프론트엔드 서비스입니다.
- **User API**: 사용자 계정, 권한 및 프로필 관리를 담당하는 핵심 비즈니스 로직 서비스입니다.
- **Media Manager**: 대용량 미디어 파일 처리 및 S3/MinIO 스토리지 연동을 전담합니다.

### **Traffic Flow**

1. **Ingress/LoadBalancer**: 외부 트래픽을 수용하여 서비스로 전달합니다.
2. **Internal LB**: 내부 서비스 간 통신 시 로드밸런싱을 수행합니다.
3. **Persistence Layer**: 환경 특성에 따라 RDS(AWS) 또는 Postgres-HA(On-prem)로 데이터를 영속화합니다.

---

## 📊 2. Public vs Private Cloud Infrastructure Comparison

본 프로젝트는 하이브리드 클라우드 전략에 따라 각 환경에 최적화된 스택을 채택하여 운영 안정성과 제어권을 확보했습니다.


| 구분                 | Public Cloud (AWS Managed) | Prviate Cloud (On-Premise) | 비고                                           |
| ------------------ | -------------------------- | -------------------------- | -------------------------------------------- |
| **Kubernetes**     | **EKS (Managed)**          | **Self-managed K8s**       | 클라우드는 관리 효율성, 온프레미스는 커스텀 제어 중심               |
| **Database**       | **Amazon RDS (Multi-AZ)**  | **Postgres-HA (Patroni)**  | 양쪽 모두 데이터 고가용성(HA) 및 자동 페일오버 확보              |
| **Storage**        | **Amazon S3**              | **MinIO (S3 Compatible)**  | 동일한 S3 프로토콜을 사용하여 앱 수정 없이 호환성 유지             |
| **Secrets**        | **AWS Secrets Manager**    | **HashiCorp Vault**        | External Secrets Operator(ESO)로 시크릿 주입 방식 통일 |
| **Image Registry** | **Amazon ECR**             | **Harbor**                 | 온프레미스 내 로컬 이미지 캐싱 및 보안 취약점 스캐닝 강화            |
| **Network/LB**     | **AWS ALB/NLB**            | **MetalLB**                | 가상화 환경 내 소프트웨어 정의 로드밸런싱 구현                   |
| **Scaling**        | **Cluster Autoscaler**     | **VM Provisioning**        | 클라우드는 노드 자동 확장, 온프레미스는 자원 고정 활용              |


#### **(1) 관리 편의성 (Management Convenience)**

- **AWS Managed**: 인프라 하위 계층(물리 서버, 하이퍼바이저, 네트워크 가동)의 운영 부담을 AWS가 전담합니다. 특히 EKS, RDS와 같은 Managed 서비스를 통해 OS 패치, 백업, 고가용성 구성을 자동화하여 엔지니어는 비즈니스 로직 및 애플리케이션 최적화에만 집중할 수 있는 **운영 효율성**을 제공합니다.
- **On-premise**: 서버 랙 실장부터 케이블링, vSphere 하이퍼바이저 관리, OS 커널 업데이트까지 전체 스택(Full Stack Ownership)을 내부 인력이 직접 관리해야 합니다. 하드웨어 장애 시 부품 조달 및 교체 등 **물리적 유지보수에 상당한 시간과 인력**이 소모되어 운영 부하가 상대적으로 높습니다.

#### **(2) 민첩성 (Agility)**

- **AWS Managed**: 'On-demand' 자원 할당을 통해 수 분 내에 수천 개의 리소스를 프로비저닝할 수 있습니다. 이는 신규 비즈니스의 **시장 진입 속도(Time-to-Market)를 극대화**하며, 필요 시 즉시 리소스를 삭제할 수 있어 가설 검증을 위한 실험과 실패 비용을 최소화하는 데 최적화되어 있습니다.
- **On-premise**: 신규 자원 확장을 위해 견적 요청(RFQ)부터 구매 승인, 배송 및 설치까지 **수주에서 수개월의 리드 타임(Lead Time)**이 발생합니다. 급격한 트래픽 변화에 즉각 대응하기 어려우며, 인프라 확장이 비즈니스 성장 속도를 따라가지 못하는 병목 현상이 발생할 수 있습니다.

#### **(3) 비용 효율성 (Cost-Efficiency)**

- **AWS Managed**: 자본 지출(CapEx)을 **운영 비용(OpEx) 모델**로 전환합니다. 초기 대규모 투자 없이 사용한 만큼 지불(Pay-as-you-go)하며, 인프라 단가 인하를 누릴 수 있습니다. **다만**, 장기적인 고부하 워크로드의 경우 예약 인스턴스(RI)나 Savings Plans를 통한 전략적 비용 최적화가 수반되어야 합니다.
- **On-premise**: 초기 하드웨어 구매에 막대한 **자본 지출(CapEx)**이 발생하지만, 장비 감가상각 기간(3~5년) 동안 일정한 고부하 워크로드를 처리할 경우 단위 자원당 비용(Unit Cost)은 클라우드보다 저렴할 수 있습니다. 단, 전력, 냉각, 공간 및 유휴 자원 유지비용을 포함한 **전체 소유 비용(TCO)** 관점에서의 철저한 분석이 필요합니다.

#### **(4) 보안 측면 (Security)**

- **AWS Managed**: 전 세계 수십 개의 보안 규제 인증(ISO 27001, SOC, HIPAA 등)을 통과한 **글로벌 수준의 물리 보안**과 자동화된 보안 도구(IAM, GuardDuty, WAF)를 제공합니다. 'Security by Design'을 통해 인프라 전반의 보안 가시성을 확보하기 용이하나, 설정 오류(Misconfiguration)에 대한 책임은 사용자에게 있습니다.
- **On-premise**: 데이터에 대한 **물리적 제어권(Data Sovereignty)**을 완벽히 보유합니다. 폐쇄망 구성을 통해 민감한 내부 기밀이나 법규상 클라우드 저장이 불가한 데이터를 관리하기에 유리합니다. 그러나 침입 탐지 시스템(IDS/IPS), 암호화 체계 등을 수동으로 구축/운영해야 하므로 전문 보안 인력 부재 시 보안 허점이 발생할 위험이 있습니다.

---

## 📂 3. Directory Structure

인프라(IaC)와 애플리케이션(K8s)의 책임을 엄격히 분리하여 관리 효율성을 높였습니다.

```text
elice-devops-assignment/
├── .github/workflows/          # [CI] 자동화 파이프라인
├── aws/
│   ├── terraform/             # [IaC] AWS 인프라 정의 (VPC, EKS, RDS, S3)
│   │   ├── bootstrap/         # Backend(S3/DynamoDB) 초기 구축용
│   │   ├── environments/      # dev, stage, prod 환경별 설정
│   │   └── modules/           # 재사용 가능한 인프라 모듈 (vpc, eks, storage, database)
│   └── kubernetes/            # [GitOps] AWS EKS 전용 매니페스트
│       ├── argocd/            # ArgoCD Application 정의 (main-app.yaml)
│       ├── external-secrets/  # External Secrets Operator 설정
│       └── services/          # 각 MSA 서비스별 Helm Values
├── on-prem/
│   ├── terraform/             # [IaC] vSphere 환경 인프라 정의
│   └── kubernetes/            # [GitOps] On-prem K8s 전용 매니페스트
├── shared/
│   └── kubernetes/charts/     # [Standard] 전 서비스 공통 Helm Chart (elice-common)
└── README.md
```

---

## 🛠 4. Infrastructure as Code (Terraform)

인프라의 정합성(Consistency)과 재현성(Reproducibility)을 위해 모든 AWS 및 vSphere 리소스는 Terraform으로 관리됩니다.

### **High Availability (HA) & Scaling**

- **Multi-AZ Architecture**: EKS 워커 노드 및 RDS 인스턴스를 다중 가용 영역(Multi-AZ)에 분산 배치하여 단일 데이터 센터 장애 시에도 서비스 연속성을 보장합니다.
- **Auto-scaling Strategy**:
  - **Cluster Autoscaler**: 트래픽 증가에 따른 물리 노드(EC2) 자동 증설.
  - **HPA (Horizontal Pod Autoscaler)**: CPU/Memory 메트릭 기반의 Pod 단위 자동 확장.
- **Postgres-HA**: On-premise 환경에서도 데이터 가용성을 위해 Patroni 기반의 고가용성 클러스터를 구성했습니다.

### **Environment Isolation**

`dev`, `stage`, `prod` 환경을 디렉토리 수준에서 완전히 물리적으로 격리하였으며, 각 환경별로 독립적인 `tfvars`와 Backend 설정을 가집니다.

### **Multi-Account Architecture (AWS Organizations)**

AWS 환경은 `dev`, `stage`, `prod`를 각각 별도 AWS Account로 분리하고, Management Account를 컨트롤 플레인으로 사용하는 구조로 운영합니다.

- **Account Isolation**: 환경 단위 계정 분리를 통해 장애 전파 범위와 권한 경계를 최소화합니다.
- **Provider Assume Role**: 각 환경 Terraform은 `OrganizationAccountAccessRole`을 Assume 하여 대상 계정에 배포합니다.
- **Environment Account ID Parameterization**: `aws_account_id` 변수를 통해 환경별 대상 Account를 선언적으로 주입합니다.

### **State Management & Locking**

- **Backend Strategy**: S3를 원격 백엔드로 사용하여 팀 협업 시 State 공유를 지원합니다.
- **State Locking**: **DynamoDB Table**을 통한 Locking 메커니즘을 적용하여, 다수의 엔지니어가 동시에 실행할 때 발생할 수 있는 Race Condition과 State 오염을 원천 차단합니다.

---

## 🔄 5. CI/CD & GitOps Workflow

수동 개입을 최소화하고 변경 사항의 추적성을 극대화하기 위해 GitOps 표준을 준수합니다.

### **Deployment Pipeline**

1. **Build**: Github Actions/CI Tool을 통해 도커 이미지를 빌드하고 Harbor/ECR에 푸시합니다.
2. **GitOps (ArgoCD)**:
  - **App-of-Apps Pattern**: 인프라 구성과 애플리케이션 배포를 계층화하여 관리합니다.
  - **Self-healing**: 클러스터 상태와 Git 소스 간의 차이(Drift)를 실시간 감지하여 자동 복구(Sync)합니다.

### **Helm Chart Standardization**

- **elice-common**: 모든 마이크로서비스가 공통으로 사용하는 Standard Helm Chart를 구축했습니다. 
- 이를 통해 배포 일관성을 유지하며, `PDB(Pod Disruption Budget)`, `Anti-affinity`, `Resources Quotas` 등 운영 필수 설정을 중앙에서 관리합니다.

---

## 🔐 6. Security & Operational Excellence

보안은 설계 단계에서부터 고려된 **Security by Design** 원칙을 따릅니다.

- **Secrets Management**: 민감 정보는 코드에 절대 포함되지 않습니다. **AWS Secrets Manager**와 **Vault**를 활용하며, **External Secrets Operator (ESO)**를 통해 Kubernetes Secret으로 안전하게 주입됩니다.
- **Least Privilege (IRSA)**: EKS의 IAM Role for Service Accounts를 적용하여, 각 Pod는 필요한 최소한의 AWS 권한만을 가집니다.
- **Network Policy**: 서비스 간 불필요한 통신을 차단하는 화이트리스트 기반 네트워크 보안 정책을 적용합니다.

---

## 🚀 7. Getting Started

실제 운영 환경 구축을 위한 상세 연동 절차입니다. 본 프로젝트는 로컬 실행을 지양하며 CI/CD 환경에서의 구동을 원칙으로 합니다.

### **Step 1: Infrastructure Bootstrap (Backend Setup)**

가장 먼저 Terraform의 상태를 관리할 S3 버킷과 DynamoDB 테이블을 생성해야 합니다.

- **관련 코드**: `aws/terraform/bootstrap/state-backend/main.tf`
- **수행 내용**: 
  1. 관리자 권한으로 위 경로의 코드를 1회 수동 배포하여 리소스를 생성합니다.
  2. 생성된 DynamoDB 테이블 이름은 이후 모든 환경의 `backend.tf`에서 `dynamodb_table` 항목에 설정되어 Race Condition을 방지하는 락커 역할을 합니다.

### **Step 2: External Credential Integration**

CI/CD 환경(GitHub Actions)이 AWS 및 vSphere에 접근할 수 있도록 권한을 연동합니다.

- **GitHub Secrets 설정**:
  - `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`: 인프라 프로비저닝용.
  - `VSPHERE_USER` / `VSPHERE_PASSWORD`: 온프레미스 제어용.
- **관련 파일**: `.github/workflows/terraform.yml` 내에서 `env` 섹션을 통해 주입됩니다.

### **Step 3: Provisioning via Pull Request (CI)**

모든 인프라 수정은 PR을 통해 검증됩니다.

1. 브랜치에서 인프라 코드를 수정 후 PR을 생성합니다.
2. GitHub Actions가 `terraform plan`을 실행하여 변경될 리소스를 리포트합니다.
3. **근거**: `.github/workflows/terraform.yml`의 `on: pull_request` 트리거 로직.

### **Step 4: GitOps Deployment (ArgoCD)**

인프라(EKS)가 준비되면 ArgoCD를 통해 애플리케이션을 배포합니다.

1. `aws/kubernetes/argocd/main-app.yaml`을 클러스터에 적용합니다.
2. 이는 **App-of-Apps 패턴**에 따라 `apps/` 폴더 내의 각 서비스 선언을 읽어와 전체 MSA를 구성합니다.
3. **동작 원리**: ArgoCD는 Git의 `values.yaml` 변경을 감지하고, 실제 클러스터 상태와 다를 경우 자동으로 **Self-healing**을 수행합니다.

