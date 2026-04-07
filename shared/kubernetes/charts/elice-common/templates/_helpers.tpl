# 공통 Helm 차트 템플릿으로, 서비스 간 배포 규약(Deployment/Ingress/HPA)을 일관되게 유지합니다.
# 환경 차이는 개별 values 파일에서 주입하고 템플릿 로직은 가능한 단순하게 유지합니다.

{{- define "elice-common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "elice-common.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "elice-common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "elice-common.labels" -}}
helm.sh/chart: {{ include "elice-common.chart" . }}
app.kubernetes.io/name: {{ include "elice-common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "elice-common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elice-common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "elice-common.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
{{- include "elice-common.fullname" . -}}
{{- end -}}
{{- end -}}
