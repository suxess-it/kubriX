{{- /*
Teams come from two sources, merged:
- .Values.teams: a plain list in a values file, for a handful of manually
  maintained teams (OSS/small setups).
- teams/*.yaml (prime only): one file per team, read via .Files.Glob rather
  than a values file. This is deliberate, values-*.yaml files must be added
  to an Application's valueFiles list to take effect, which would mean every
  self-service team onboarding PR (sx-template-onboarding-prime) also needs a
  central edit to that list. .Files.Glob picks up new files automatically at
  render time, so onboarding stays a single, self-contained PR.
*/ -}}
{{- define "team-onboarding.teams" -}}
{{- $teams := list -}}
{{- range $team := (.Values.teams | default list) -}}
{{- $teams = append $teams $team -}}
{{- end -}}
{{- if eq .Values.kubriXPlan "prime" -}}
{{- range $path, $_ := .Files.Glob "teams/*.yaml" -}}
{{- $teamFile := $.Files.Get $path | fromYaml -}}
{{- if kindIs "slice" $teamFile -}}
{{- range $team := $teamFile -}}
{{- $teams = append $teams $team -}}
{{- end -}}
{{- else -}}
{{- $teams = append $teams $teamFile -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- toYaml $teams -}}
{{- end -}}
