{{- define "llm-serving.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "llm-serving.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if contains (include "llm-serving.name" .) .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "llm-serving.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "llm-serving.labels" -}}
app.kubernetes.io/name: {{ include "llm-serving.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | quote }}
{{- end }}

{{- define "llm-serving.selectorLabels" -}}
app.kubernetes.io/name: {{ include "llm-serving.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "llm-serving.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "llm-serving.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "llm-serving.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{- define "llm-serving.modelCacheClaimName" -}}
{{- if .Values.vllm.modelCache.create }}
{{- .Values.vllm.modelCache.claimName }}
{{- else }}
{{- required "vllm.modelCache.existingClaim is required when modelCache.create is false" .Values.vllm.modelCache.existingClaim }}
{{- end }}
{{- end }}

{{- define "llm-serving.validate" -}}
{{- if ne (int .Values.vllm.replicaCount) 1 }}
{{- fail "v0.1.0 requires vllm.replicaCount: 1" }}
{{- end }}
{{- if ne .Values.vllm.deployment.strategy "Recreate" }}
{{- fail "v0.1.0 requires vllm.deployment.strategy: Recreate" }}
{{- end }}
{{- $gpuLimit := index .Values.vllm.resources.limits "nvidia.com/gpu" }}
{{- if ne (toString $gpuLimit) "1" }}
{{- fail "v0.1.0 requires vllm.resources.limits.nvidia.com/gpu: 1" }}
{{- end }}
{{- if .Values.vllm.model.trustRemoteCode }}
{{- fail "v0.1.0 does not permit trustRemoteCode: true" }}
{{- end }}
{{- end }}
