{{- define "llm-serving.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "llm-serving.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
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
