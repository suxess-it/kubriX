# Onboarding teams

New teams can simply onboard themselves by [executing the 'team-onboarding' template](https://backstage.demo.kubrix.cloud/create/templates/default/team-onboarding) or by clicking "Choose" in the "Team-Onboarding" template here: https://backstage.demo.kubrix.cloud/create

![image](../../img/team-onboarding-1.png)

The team name is automatically selected based on your assigned group, so just click on 'Next'

![image](../../img/team-onboarding-2.png)

The host, organization and path to your kubriX platform Git-Repo is also automatically select, so just click on 'Next'

![image](../../img/team-onboarding-3.png)

On the summary page review your data and click on 'Create'

![image](../../img/team-onboarding-4.png)

Backstage creates a Pull-Request for you to add your team to the team-onboarding chart. This PR needs to get reviewewd and merged by the platform-team.

Also, your team gets their own "App-Of-apps" Git-Repo where you can put your own ArgoCD application definitions in the created 'demo-apps' folder.

![image](../../img/team-onboarding-5.png)

What you will see in the Pull-Request 'Files changed" tab, is a new stanza for your team.
With these values the team-onboarding chart creates:

* a new ArgoCD project with defined allowed sourceRepos, clusterResourceWhitelist and destinations.
* some predefined platform AppSet SCM-Generators which search for some specific git-Repos of your team.

If you are interested in the specific Kubernetes Resources which would get created with this PR
you can have a look at the automatically created PR comments "Changes Rendered Chart".

When your platform team merges the PR and everything gets synchronized by ArgoCD 
your application team can deploy new applications in a complete self-service way!

# Create tokens for ArgoCD AppSet and GitOps promotion for you onboarded team

For the ArgoCD AppSet and the Kargo GitOps-Promotion you need two additional Tokens:

`KUBRIX_ARGOCD_APPSET_TOKEN` ... A Token which has Read-Permissions in the Git Group/Organization, to find new application git-repos via ArgoCD AppSet SCM-Generator.
`KUBRIX_KARGO_GIT_PASSWORD` ... A Token which has Write-Permissions in this Git Group/Organization, to do git commands for GitOps promotion.

Then write these tokens in vault:

```
export TEAM_NAME=<your-team-name>
export KUBRIX_ARGOCD_APPSET_TOKEN=<your-appset-token>
export KUBRIX_KARGO_GIT_PASSWORD=<your-kargo-token>
export VAULT_HOSTNAME=$(kubectl get ingress -o jsonpath='{.items[*].spec.rules[*].host}' -n vault)
export VAULT_TOKEN=$(kubectl get secret -n vault vault-init -o=jsonpath='{.data.root_token}'  | base64 -d)
curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request POST --data "{\"data\": {\"KUBRIX_ARGOCD_APPSET_TOKEN\": \"${KUBRIX_ARGOCD_APPSET_TOKEN}\", \"KUBRIX_KARGO_GIT_PASSWORD\":
\"${KUBRIX_KARGO_GIT_PASSWORD}\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/${TEAM_NAME}/delivery
```

# Additional infos

Some background information can also be found in the [Additional infos](onboarding-additional-infos.md) chapter.


