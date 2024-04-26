# Function

Via an appset 3 stages get deployed and are managed in a Kargo-Project: https://kargo-${{values.fqdn}}/project/kargo-${{values.application_id}}

kargo needs to write to your gitops repo to promote changed from one stage to another. 


```
export GITHUB_USERNAME=<your github handle>
export GITHUB_PAT=<your personal access token>
kubectl create secret generic git-demo-app -n kargo-${{values.application_id}} --from-literal=type=git --from-literal=url=https://github.com/${{values.repoUrlowner}}/${{values.application_id}}' --from-literal=username=${GITHUB_USERNAME} --from-literal=password=${GITHUB_PAT}
kubectl label secret git-demo-app -n kargo-${{values.application_id}} kargo.akuity.io/secret-type=repository
```

URLs for stages:

test: http://test-${{values.application_id}}-${{values.fqdn}}
qa: http://qa-${{values.application_id}}-${{values.fqdn}}
prod: http://prod-${{values.application_id}}-${{values.fqdn}}