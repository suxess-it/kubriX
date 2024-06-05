# multi-stage app with kargo pipeline

This chart creates an argocd app per stage and a kargo project with specific stages and a default promotionMechanism for this app.

# restrictions

## Flexibility

Currently this chart is just a proof-of-concept and very limited in terms of flexibility. PromotionMechnism is hard coded for example.

## applicable topologies

Also, this chart only work when argocd applications and kargo projects are defined in the same cluster.

So when multi-stage-apps are deployed across different clusters (e.g. nonprod-cluster for "test" and "qa" and prod-cluster for "prod") you need a [Hub-and-Spoke](https://github.com/cloudogu/gitops-patterns?tab=readme-ov-file#hub-and-spoke) topology, where the argocd control plane and kargo control plane is in a "Hub" or "Management Cluster".

When you have multi-stage clusters but one argocd instance in each cluster you need to define your argocd applications in each cluster and your kargo resources in one cluster (maybe again a mgmt-cluster),
because your kargo pipeline needs to be in one cluster.

# prereqs

An argocd app-project for this app

# values

just define these values and all needed argocd app resources and kargo resources are created automatically.

|                     | description | default | example
| ------------------- | ----------- | ------- | -------|
| appProject          | the argocd app project this app belongs to | ~ | team1-project
| appName             | the base name of the apps, the stage name will be appened to     |  ~ | team1-demo-app
| repoUrl             | the gitops repo for this apps | ~ | https://github.com/suxess-it/sx-cnp-oss-demo-app
| kargoProject        | the kargo project where the kargo resources get created for this app | `{{ .Values.appName }}-kargo-project` | -
| createAppNamespace  | if the namespaces for this apps get created automatically, the namespaces will have the same name as the apps | `true` | `true`
| stages              | an array of kargo stages with subscriptions attributes | `[]` | <code>- name: "test"<br>&nbsp;&nbsp;subscriptions:<br>&nbsp;&nbsp;&nbsp;&nbsp;warehouse: "warehouse-{{ .Values.appName }}"<br>- name: "qa"<br>&nbsp;&nbsp;subscriptions:<br>&nbsp;&nbsp;&nbsp;&nbsp;upstreamStages:<br>&nbsp;&nbsp;&nbsp;&nbsp;- name: test<br>- name: "prod"<br>&nbsp;&nbsp;subscriptions:<br>&nbsp;&nbsp;&nbsp;&nbsp;upstreamStages:<br>&nbsp;&nbsp;&nbsp;&nbsp;- name: qa
<code>

# promotion

Promotion works with stage specific branches. Stage-Definiton automatically is defined like this:

```
  promotionMechanisms:
    gitRepoUpdates:
    - repoURL: {{ $.Values.repoUrl }}
      writeBranch: stages/{{ .name }}
```

See [Behind the scenes](https://kargo.akuity.io/quickstart#behind-the-scenes) for details.

# how to use this chart

## argocd app

you can use this chart in an argocd app like that: 

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: team1-multi-stage-apps
  namespace: team1-app-definitions
spec:
  destination:
    namespace: team1-app-definitions
    server: https://kubernetes.default.svc
  project: team1-project
  source:
    repoURL: https://github.com/suxess-it/sx-cnp-oss
    targetRevision: main
    path: team-apps/onboarding-apps-charts/multi-stage-app-with-kargo-pipeline
    helm:
      values: |
        appProject: team1-project
        appName: team1-multi-stage-app
        repoUrl: https://github.com/suxess-it/sx-cnp-oss-demo-app
        kargoProject: "{{ .Values.appName }}-kargo-project"
        createAppNamespace: true
        stages:
          - name: "test"
            subscriptions: 
              warehouse: "warehouse-{{ .Values.appName }}"
          - name: "qa"
            subscriptions: 
              upstreamStages:
              - name: test
          - name: "prod"
            subscriptions: 
              upstreamStages:
              - name: qa
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

or look at this [example](https://github.com/suxess-it/team1-apps/blob/main/k3d-apps/example-multi-stage-app-with-kargo.yaml)

## applicationset with SCM provider

**needs to be tested!!**

Also, you could create an applicationset once for all apps for the team.
Per default this applicationset needs to be created by the platform team.
However, we prefer enabling [applicationset-in-any-namespaces](https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Appset-Any-Namespace/) so the dev-team can create the appset in their namespace by themselves.

```
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: team1-appset
  namespace: team1-app-definitions
spec:
  generators:
  - scmProvider:
      github:
        # The GitHub organization to scan.
        organization: myorg
      filters:
      # Include any repository starting with "team1" AND including a Kustomize config AND labeled with "deploy-ok" ...
      - repositoryMatch: ^team1
        pathsExist: [app-stages.yaml]
        labelMatch: deploy-ok
  template:
    metadata:
      name: '{{ .repository }}'
    spec:
      project: "team1-project"
      sources:
      - repoURL: https://github.com/suxess-it/sx-cnp-oss
        targetRevision: HEAD
        path: team-apps/onboarding-apps-charts/multi-stage-app-with-kargo-pipeline
        helm:
          valueFiles:
          - $values/kubernetes/app-stages.yaml
      - repoURL: '{{ .url }}'
        targetRevision: main
        # is this needed???
        path: '{{path}}'
        ref: values
      destination:
        server: https://kubernetes.default.svc
        namespace: team1-app-definitions
      syncPolicy:
        automated:
          selfHeal: true
          prune: true
```

And in each app-gitops-repo you create an `apps-staging.yaml` which defines the values from above.

# Big Picture

maybe show the big picture in a excalidraw diagram

