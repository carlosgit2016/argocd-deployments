{{/*
    Name definition
*/}}
{{- define "microservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
    Labels definition
*/}}
{{- define "microservice.labels" -}}
app.kubernetes.io/name: {{ include "microservice.name" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }} 
helm.sh/chart: {{ .Chart.Name }}
{{- end }}

{{/*
    Labels selector
*/}}
{{- define "microservice.labels.selector" -}}
app.kubernetes.io/name: {{ include "microservice.name" . }}
{{- end }}

{{- define "microservice.configMap.name" -}}
{{- printf "%s-config" (include "microservice.name" .)  -}}
{{- end }}