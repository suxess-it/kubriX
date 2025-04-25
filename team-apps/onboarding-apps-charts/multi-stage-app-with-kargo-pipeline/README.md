# multi-stage app with kargo pipeline

This chart creates an argocd app per stage and a kargo project with specific stages and a default promotionMechanism for this app.

# restrictions

## naming

The chart and the sane default values work well if you follow the naming concepts of the [app-in-any-namespace option of the team-onboarding adr](https://github.com/suxess-it/kubriX/blob/main/backstage-resources/adr/0001-gitops-onboarding-teams.md#apps-in-any-namespace-and-multi-tenant-kyverno-policies) 

## flexibility

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
| teamName            | the name of the team this app belongs to | ~ | team1
| appProject          | the argocd app project this app belongs to | `{{ .Values.teamName }}-project` | -
| appName             | the base name of the apps, the stage name will be appened to     |  ~ | team1-demo-app
| appDefinition       | additional app definition attributes (annotations and synOptions) | ~ | <pre>appDefinition:<br>&nbsp;&nbsp;annotations:<br>&nbsp;&nbsp;&nbsp;&nbsp;argocd.argoproj.io/compare-options: ServerSideDiff=true<br>&nbsp;&nbsp;syncOptions:<br>&nbsp;&nbsp;&nbsp;&nbsp;- ServerSideApply=true</pre> |
| repoUrl             | the gitops repo for this apps | ~ | https://github.com/suxess-it/kubrix-demo-app
| kargoProject        | the kargo project where the kargo resources get created for this app | `{{ .Values.appName }}-kargo-project` | -
| createAppNamespace  | if the namespaces for this apps get created automatically, the namespaces will have the same name as the apps | `true` | `true`
| stages              | an array of kargo stages with subscriptions attributes | `[]` | see examples below

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
  namespace: team1-apps
spec:
  destination:
    namespace: adn-team1
    server: https://kubernetes.default.svc
  project: team1-project
  source:
    repoURL: https://github.com/suxess-it/kubriX
    targetRevision: main
    path: team-apps/onboarding-apps-charts/multi-stage-app-with-kargo-pipeline
    helm:
      values: |
        teamName: team1
        appName: multi-stage-app
        repoUrl: https://github.com/suxess-it/kubrix-demo-app
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

Also, you could create an applicationset once for all apps for the team.
Per default this applicationset could be created by the platform team.
Also, the dev-team could create AppSets by themselves when enabling [applicationset-in-any-namespaces](https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Appset-Any-Namespace/).

Still, it could be a feature that with team-onboarding this appset gets created automatically via values in https://github.com/suxess-it/kubriX/blob/d2edfc78fe31109f3b33dcd4071a5247ab4abad1/platform-apps/charts/team-onboarding/values-k3d.yaml#L1

### Steps to create this appset

create a secret first for the github pat (otherwise a very low rate limit affects you):
```
export KUBRIX_ARGOCD_APPSET_TOKEN=<token>
kubectl create secret generic appset-github-token --from-literal=token=${KUBRIX_ARGOCD_APPSET_TOKEN} -n team1-apps
```

and then define this applicationset in the teams1-apps namespace:
```
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: team1-appset
  namespace: adn-team1
spec:
  goTemplate: true
  goTemplateOptions: ["missingkey=error"]
  generators:
  - scmProvider:
      cloneProtocol: https
      github:
        # The GitHub organization to scan.
        organization: suxess-it
        tokenRef:
          secretName: appset-github-token
          key: token
      filters:
      # Include any repository starting with "team1" AND including an app-stage.yaml
      - repositoryMatch: ^team1
        pathsExist: [app-stages.yaml]
  template:
    metadata:
      name: '{{ .repository }}'
    spec:
      project: "team1-project"
      sources:
      - repoURL: https://github.com/suxess-it/kubriX
        targetRevision: HEAD
        path: team-apps/onboarding-apps-charts/multi-stage-app-with-kargo-pipeline
        helm:
          valueFiles:
          - $values/app-stages.yaml
      - repoURL: '{{ .url }}'
        targetRevision: main
        ref: values
      destination:
        server: https://kubernetes.default.svc
        namespace: adn-team1
      syncPolicy:
        automated:
          selfHeal: true
          prune: true
```
or look at this [example](https://github.com/suxess-it/kubriX/blob/main/team-apps/onboarding-apps-charts/multi-stage-app-with-kargo-pipeline/applicationSet-example.yaml)

And in each app-gitops-repo you create an `app-staging.yaml` which defines the values from above.

# Big Picture

maybe show the big picture in a excalidraw diagram

