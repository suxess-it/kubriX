# Application Deployment - DRAFT

Deploying team applications is managed by the team-onboarding chart. Currently teams have two options:

* create own application definitions in the app-of-apps git-repo by themselves
* create only application specific gitops-repos and let a platform AppSet SCM generator find this repos and create the application definition

In both options the application is restricted to the teams specific argo project in the team-onboarding chart.

## Project definition

The project definition in the team-onboarding chart in a hub-and-spoke topology needs different destination rules:

Single instance:

```
  destinations:
  - name: in-cluster
    namespace: {{ .name }}-*
    server: https://kubernetes.default.svc
  - name: in-cluster
    namespace: adn-{{ .name }}
    server: https://kubernetes.default.svc
```

Hub & Spoke:

```
  destinations:
  # do not allow to deploy team applications on the hub
  - name: !in-cluster
    namespace: {{ .name }}-*
    server: https://kubernetes.default.svc
  # only allow to deploy team app-of-apps or appsets on the hub in the special "adn" namespace (application-definition-namespace)
  - name: in-cluster
    namespace: adn-{{ .name }}
    server: https://kubernetes.default.svc
  # all other clusters are allowed as long as the target namespace starts with the teams name
  - name: *
    namespace: {{ .name }}-*
    server: https://kubernetes.default.svc
```

see allow and deny rules in https://argo-cd.readthedocs.io/en/latest/user-guide/projects/#managing-projects


