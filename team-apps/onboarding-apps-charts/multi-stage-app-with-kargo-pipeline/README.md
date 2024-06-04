# multi-stage app with kargo pipeline

This chart creates an argocd app per stage and a kargo project with specific stages for this app.

# prereqs

- an argocd app-project for this app

# promotion

todo: how promotion then works in stage branches

# how to use this chart


todo: explain how teams can use this chart

- in the teams app-of-apps gitops repo 
- in the app gitops repo via applicationset


maybe show the big picture in a excalidraw diagram


# values

todo: describe values

appProject: team1-project
appName: team1-demo-app
repoUrl: https://github.com/suxess-it/sx-cnp-oss-demo-app
kargoProject: "{{ .Values.appName }}-kargo-project"
createAppNamespace: true
stages:
  - name: "test"
    subscriptions: 
      # maybe the warehouse is some implicit thing which we don't need to define here.
      # maybe in the future we just say "warehouse" without a name, because the name is some internal thing
      warehouse: "warehouse-{{ .Values.appName }}"
  - name: "qa"
    subscriptions: 
      upstreamStages:
      - name: test
  - name: "prod"
    subscriptions: 
      upstreamStages:
      - name: qa






helm template --namespace team-jokl-app-definition . | kubectl apply -f -

