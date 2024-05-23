# prereqs

a team-jokl project with

- source repos defined: github.com/team-jokl/* (in our ase github.com/suxess-it/team-jokl-*)
- source namespaces (for app definitions): team-jokl-app-mgmt (todo: can kargo projects share one ns, or do we need our own app-mgmt ns and kargo needs its own projects)
- destinations: team-jokl-*

# create apps

helm template --namespace team-jokl-app-mgmt . | kubectl apply -f -


# TODOS

if kargo projects need their own namespace we could overwrite the namespace for this resources (or maybe build a subchart for kargo resources and overwrite it there), like this:

```
{{- define "argo-cd.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}
```
