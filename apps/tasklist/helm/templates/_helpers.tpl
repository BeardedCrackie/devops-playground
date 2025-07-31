{{- define "tasklist.name" -}}
tasklist
{{- end -}}

{{- define "tasklist.fullname" -}}
{{ include "tasklist.name" . }}
{{- end -}}
