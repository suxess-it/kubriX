# Contributing to kubriX

## 👋 Welcome

We’re excited that you want to contribute to **kubriX**!  
Whether you’re fixing a bug, improving documentation, or adding a new feature, your work helps make kubriX better for everyone.

kubriX is an **open-source Internal Developer Platform (IDP)** for Kubernetes, built with a modular “bricks” architecture.  
We believe in **collaboration, openness, and quality** - and we’re happy to have you on board.

---

## 🛠 Ways to Contribute

You can contribute to kubriX in many ways:

- 🐛 **Bug Reports** – Help us identify and track down problems  
- 💡 **Feature Suggestions** – Share ideas for new features or improvements  
- 🧹 **Code Improvements** – Bug fixes, performance enhancements, refactoring  
- 📚 **Documentation** – Improve guides, tutorials, or API references  
- 🎨 **UX/UI Enhancements** – Improve the developer portal experience  
- 🔌 **Integrations** – Add or improve kubriX “bricks” (preconfigured tools)

---

## 📜 Ground Rules

- Follow our [Code of Conduct](CODE_OF_CONDUCT.md) 
- Write clear, descriptive commit messages (prefer [Conventional Commits](https://www.conventionalcommits.org/)), at least as a description for your PR (we squash-merge PRs)
- Keep pull requests focused and atomic—smaller changes are easier to review  
- Ensure CI checks pass before requesting a review  
- Add tests for new functionality when possible

---

# Branching & Pull Request Workflow

* Use a feature, fix or chore branch (feat/my-new-feature)
* Keep main branch clean—only merged via PR
* PR title format (conventional commits recommended: fix:, feat:, docs:…) - we release with Release-Please
* Link related Issues in PR description
* Include screenshots for UI changes
* Ask for review from at least one maintainer
* Keep your feature branch up-to-date, maintainers will squash-merge the PR

---

# Running E2E tests

We use Playwright for running e2e tests. To run them locally you need to do the following


install otpauth dependency:

```
cd e2e-tests/playwright
npm install otpauth
```

get some env entries for the tests (documented in the '__comments' attribute in the following json)

and save them in `playwright.env` section of the `settings.json` of vscode:

```
    "playwright.reuseBrowser": true,
    "remote.autoForwardPortsSource": "hybrid",
    "playwright.env": {
        "__comments": {
            "E2E_KEYCLOAK_DEMOADMIN_PASSWORD": "kubectl get secret -n keycloak cp-keycloak-users-secret -o=jsonpath='{.data.demoadmin}'  | base64 -d",
            "E2E_KEYCLOAK_DEMOUSER_PASSWORD": "kubectl get secret -n keycloak cp-keycloak-users-secret -o=jsonpath='{.data.demouser}'  | base64 -d",
            "E2E_ARGOCD_ADMIN_PASSWORD": "kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' | base64 -d",
            "E2E_GRAFANA_ADMIN_PASSWORD": "kubectl get secret -n grafana grafana-admin-secret  -o=jsonpath='{.data.passwordKey}'  | base64 -d",
            "E2E_KEYCLOAK_ADMIN_PASSWORD": "kubectl get secret -n keycloak  keycloak-admin -o=jsonpath='{.data.admin-password}'  | base64 -d",
            "E2E_VAULT_ROOT_TOKEN": "kubectl get secret -n vault vault-init -o jsonpath='{.data.root_token}' | base64 -d ",
            "E2E_KARGO_ADMIN_PASSWORD": "kubectl get secret -n kargo kargo-admin-secret  -o=jsonpath='{.data.ADMIN_ACCOUNT_PASSWORD}'  | base64 -d",
        },
        "E2E_KEYCLOAK_DEMOADMIN_PASSWORD": "xxx",
        "E2E_KEYCLOAK_DEMOUSER_PASSWORD": "xxx",
        "E2E_GRAFANA_ADMIN_PASSWORD": "xxx",
        "E2E_KEYCLOAK_ADMIN_PASSWORD": "xxx",
        "E2E_VAULT_ROOT_TOKEN": "xxx",
        "E2E_KARGO_ADMIN_PASSWORD": "xxx",
        "E2E_TEST_GH_USERNAME": "xxx",
        "E2E_TEST_GH_PASSWORD": "xxx",
        "E2E_TEST_GITHUB_OTP": "xxx",
        "E2E_ARGOCD_ADMIN_PASSWORD": "xxx",
        "E2E_ARGOCD_VERSION": "current-version",
        "E2E_KARGO_VERSION": "current-version",
        "E2E_KUBRIX_REPO": "your-forked-demo-repo",
        "E2E_KUBRIX_ARGOCD_APPSET_TOKEN": "xxx",
        "E2E_KUBRIX_KARGO_GIT_PASSWORD": "xxx"
    },
    "playwright.showTrace": false
```

also setup github oauth in backstage in your kubriX setup:

```
export GITHUB_CLIENTID="<oauth-github-clientid>"
export GITHUB_CLIENTSECRET="<oauth-github-clientsecret>"
```

and then execute the following:

```
export VAULT_HOSTNAME=$(kubectl get ingress -o jsonpath='{.items[*].spec.rules[*].host}' -n vault)
export VAULT_TOKEN=$(kubectl get secret -n vault vault-init -o=jsonpath='{.data.root_token}'  | base64 -d)
curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request PATCH --header "Content-Type: application/merge-patch+json" --data "{\"data\": {\"GITHUB_CLIENTSECRET\": \"${GITHUB_CLIENTSECRET}\", \"GITHUB_CLIENTID\": \"${GITHUB_CLIENTID}\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/portal/backstage/base
kubectl delete secret -n backstage sx-cnp-secret
kubectl delete externalsecret -n backstage sx-cnp-secret
kubectl rollout restart deployment -n backstage sx-backstage
kubectl rollout status deployment -n backstage sx-backstage
```

You can show the html report when you execute this command in the `e2e-tests/playwright` folder:

```
npx playwright show-report
```

or you can select `show browser` or `show trace viewer` in your playwright vscode extension view.