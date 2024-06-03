# multi-stage app with kargo pipeline

This chart creates an argocd app per stage and a kargo project with specific stages for this app.

# prereqs

- an argocd app-project for this app


# create apps

helm template --namespace team-jokl-app-definition . | kubectl apply -f -

