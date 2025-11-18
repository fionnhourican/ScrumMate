{{/*
Expand the name of the chart.
*/}}
{{- define "scrummate.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "scrummate.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "scrummate.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "scrummate.labels" -}}
helm.sh/chart: {{ include "scrummate.chart" . }}
{{ include "scrummate.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "scrummate.selectorLabels" -}}
app.kubernetes.io/name: {{ include "scrummate.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend labels
*/}}
{{- define "scrummate.backend.labels" -}}
{{ include "scrummate.labels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "scrummate.frontend.labels" -}}
{{ include "scrummate.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Database labels
*/}}
{{- define "scrummate.database.labels" -}}
{{ include "scrummate.labels" . }}
app.kubernetes.io/component: database
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "scrummate.backend.selectorLabels" -}}
{{ include "scrummate.selectorLabels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "scrummate.frontend.selectorLabels" -}}
{{ include "scrummate.selectorLabels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Database selector labels
*/}}
{{- define "scrummate.database.selectorLabels" -}}
{{ include "scrummate.selectorLabels" . }}
app.kubernetes.io/component: database
{{- end }}

{{/*
Create the name of the service account to use for backend
*/}}
{{- define "scrummate.backend.serviceAccountName" -}}
{{- if .Values.backend.serviceAccount.create }}
{{- default (printf "%s-backend" (include "scrummate.fullname" .)) .Values.backend.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.backend.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for frontend
*/}}
{{- define "scrummate.frontend.serviceAccountName" -}}
{{- if .Values.frontend.serviceAccount.create }}
{{- default (printf "%s-frontend" (include "scrummate.fullname" .)) .Values.frontend.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.frontend.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for database
*/}}
{{- define "scrummate.database.serviceAccountName" -}}
{{- if .Values.database.serviceAccount.create }}
{{- default (printf "%s-database" (include "scrummate.fullname" .)) .Values.database.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.database.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Backend image
*/}}
{{- define "scrummate.backend.image" -}}
{{- printf "%s:%s" .Values.backend.image.repository (.Values.backend.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{/*
Frontend image
*/}}
{{- define "scrummate.frontend.image" -}}
{{- printf "%s:%s" .Values.frontend.image.repository (.Values.frontend.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{/*
Database connection URL
*/}}
{{- define "scrummate.database.url" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "jdbc:postgresql://%s-postgresql:5432/%s" .Release.Name .Values.postgresql.auth.database }}
{{- else }}
{{- printf "jdbc:postgresql://%s:5432/%s" .Values.database.host .Values.database.name }}
{{- end }}
{{- end }}
