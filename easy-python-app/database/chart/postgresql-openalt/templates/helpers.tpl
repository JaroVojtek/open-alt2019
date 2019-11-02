{{- define "postgresql-openalt.labels" -}}
app: {{ .Chart.Name }}
name: {{ .Release.Name }}
{{- end -}}