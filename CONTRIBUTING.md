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

get some env entries for the tests

```
export E2E_KEYCLOAK_DEMOADMIN_PASSWORD=$( kubectl get secret -n keycloak cp-keycloak-users-secret -o=jsonpath='{.data.demoadmin}'  | base64 -d )
export E2E_KEYCLOAK_DEMOUSER_PASSWORD=$( kubectl get secret -n keycloak cp-keycloak-users-secret -o=jsonpath='{.data.demouser}'  | base64 -d )
```

and save them in `playwright.env` section of the `settings.json` of vscode:

```
    "playwright.env": {
        "E2E_KEYCLOAK_DEMOADMIN_PASSWORD": "xxxxx",
        "E2E_KEYCLOAK_DEMOUSER_PASSWORD": "xxxxx",
        "E2E_TEST_GH_USERNAME": "xxxxx",
        "E2E_TEST_GH_PASSWORD": "xxxxx",
        "E2E_TEST_GITHUB_OTP": "xxxxx"
    }
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