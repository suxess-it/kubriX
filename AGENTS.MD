# AGENTS.MD

Guidance for AI coding agents working in this repository.

## Project Overview

kubriX is an opinionated Internal Developer Platform distribution for Kubernetes. The repo is primarily GitOps and Helm content, plus bootstrap automation, CI helpers, generated scan/list artifacts, and Playwright e2e tests.

Key areas:

- `platform-apps/charts/`: Helm wrapper charts for platform bricks such as Argo CD, Backstage, Grafana, Keycloak, OpenBao, Kargo, Kyverno, Traefik, and others.
- `platform-apps/target-chart/`: Helm chart that renders Argo CD `Application` resources for target profiles.
- `team-apps/onboarding-apps-charts/`: Helm charts for team onboarding/demo application workflows.
- `bootstrap-app-*.yaml` and `bootstrap-argocd-values.yaml`: Argo CD bootstrap manifests and values.
- `install-platform.sh`: main installation/bootstrap script.
- `.github/`: validation, rendering, scan, release, and CI helper scripts/workflows.
- `kubeconform-schemas/`: custom CRD schemas used by kubeconform.
- `e2e-tests/playwright/`: Playwright e2e tests.
- `image-list/`, `helm-chart-list/`, `trivy-scan-reports/`: generated inventory/security outputs.

## Working Principles

- Keep changes narrow and aligned with the existing GitOps/Helm patterns.
- Do not rewrite generated reports or large inventory files unless the task explicitly asks for regeneration.
- Treat secrets carefully. Do not print, commit, or invent real credentials. Many scripts depend on secret-like environment variables.
- Prefer existing shell helpers in `.github/` over creating new validation logic.
- Preserve YAML formatting and ordering where possible; many diffs are reviewed as rendered GitOps output.
- When touching Helm charts, update the specific chart only unless a shared target/profile change is required.

## Helm Chart Conventions

Platform charts live under `platform-apps/charts/<app>/` and usually include:

- `Chart.yaml`
- `Chart.lock` when dependencies are locked
- `values.yaml`
- `values-kubrix-default.yaml`
- `values-customer.yaml`
- optional aspect files such as `values-cluster-kind.yaml`, `values-provider-*.yaml`, `values-ha-enabled.yaml`, `values-size-*.yaml`, `values-security-strict.yaml`, or `values-demo-metalstack.yaml`
- optional generated template files named `values-customer-generated.yaml.tmpl`

Common pattern:

- Put opinionated kubriX defaults in `values-kubrix-default.yaml`.
- Keep customer overrides in `values-customer.yaml`.
- Keep local kind overrides in `values-cluster-kind.yaml` or target-specific `values-kind*.yaml`.
- Use chart dependencies instead of vendoring upstream manifests when an upstream Helm chart exists.
- Run `helm dependency update` for charts whose dependencies changed.

## Helm Values Design Principles

kubriX uses modular Helm values files so the platform can ship stable, secure, integrated defaults while still letting customers adapt the distribution to their own environments.

- Keep values files aspect-oriented. Prefer a dedicated file for each configuration concern instead of one large templated values file.
- Preserve the boundary between kubriX-provided defaults and customer-maintained configuration. Product defaults belong in kubriX values files; manually maintained customer settings belong in `values-customer.yaml`.
- Do not manually edit generated customer values. `values-customer-generated.yaml` is generated during bootstrap from variables such as `KUBRIX_REPO`, `KUBRIX_DOMAIN`, `KUBRIX_DNS_PROVIDER`, `KUBRIX_GIT_USER_NAME`, and `KUBRIX_CUSTOM_VALUES`.
- Avoid copying the same configuration between multiple values files. Let later values files inherit and override earlier ones to keep the structure DRY.
- Prefer maps over lists where possible. Helm cannot partially override arrays, so list changes require redefining the entire list.
- Keep values files friendly to static analysis such as `helm lint`; avoid unnecessary dynamic templating in normal values files.
- When reviewing changes, reason about the final computed values and rendered manifests, not just the edited file. CI GitOps diff comments exist for this reason.

Values files are applied in priority order, with later files overriding earlier files:

1. `values-kubrix-default.yaml`
2. `values-cluster-${clusterType}.yaml`
3. `values-provider-${cloudProvider}.yaml`
4. `values-ha-enabled.yaml`
5. `values-size-${tShirtSize}.yaml`
6. `values-security-strict.yaml`
7. `values-customer-generated.yaml`
8. `values-customer.yaml`

All of these files are optional. A chart may rely entirely on the default values of its dependent subcharts if no kubriX-specific values are needed.

`platform-apps/target-chart/values-${targetType}.yaml` defines which stack is installed for a given `KUBRIX_TARGET_TYPE`. Its `.default.valuesFiles` entry should include the relevant values file layers for each application, and `.applications` can include or exclude charts based on installation variables. Use `KUBRIX_APP_EXCLUDE` to remove specific applications from the application list instead of adding complex conditionals when that is simpler.

Variables inside values files are rendered only during bootstrap, when `KUBRIX_BOOTSTRAP=true`.

## Validation Commands

Use the narrowest validation that matches the change.

Render a single chart:

```bash
helm dependency update platform-apps/charts/<chart>
helm template sx-<chart> --include-crds platform-apps/charts/<chart> \
  -f platform-apps/charts/<chart>/values-kubrix-default.yaml \
  -f platform-apps/charts/<chart>/values-cluster-kind.yaml
```

Run kubeconform like CI for all or changed platform charts:

```bash
.github/kubeconform.sh kind values-kubrix-default.yaml,values-cluster-kind.yaml ""
```

Run kube-score helper:

```bash
.github/kube-score.sh kind values-kubrix-default.yaml,values-cluster-kind.yaml ""
```

Render target chart applications:

```bash
helm template platform-apps/target-chart -f platform-apps/target-chart/values-kind.yaml
```

Create rendered GitOps diff artifacts:

```bash
.github/create-pr-comment-file.sh kind values-kubrix-default.yaml,values-cluster-kind.yaml ""
```

These scripts may download tools such as `kubeconform`, `kube-score`, or Helm plugins. If network access is unavailable, explain which validation could not be run.

## Installation / Cluster Testing

`install-platform.sh` is the main bootstrap path. It expects tools such as `yq`, `jq`, `kubectl`, `helm`, `curl`, and `k8sgpt`, plus environment variables for repo access and target selection.

Common variables:

- `KUBRIX_REPO`
- `KUBRIX_REPO_BRANCH` default `main`
- `KUBRIX_REPO_USERNAME`
- `KUBRIX_REPO_PASSWORD`
- `KUBRIX_TARGET_TYPE` default `kubrix-oss-stack`
- `KUBRIX_CLUSTER_TYPE` default `k8s`; use `kind` for local kind installs
- `KUBRIX_BOOTSTRAP`
- `KUBRIX_BOOTSTRAP_MAX_WAIT_TIME`

Devcontainers run `.devcontainer/install-platform-devcontainer.sh` with target-specific values such as `kind-delivery`, `kind-observability`, `kind-portal`, or `kind-security`.

Cluster-level CI is defined in `.github/workflows/cluster-test.yml` and uses kind, mkcert, Argo CD, Testkube, and Playwright artifacts. Do not assume these tests are cheap or local-friendly.

## E2E Tests

Playwright tests live in `e2e-tests/playwright/`.

Setup:

```bash
cd e2e-tests/playwright
npm install
```

Run tests from that directory with Playwright, for example:

```bash
npx playwright test
```

The tests require environment variables documented in `CONTRIBUTING.md`, including service admin passwords, GitHub test credentials/OTP, target branch/repo values, and optional `E2E_BASE_DOMAIN`.

Show a report:

```bash
npx playwright show-report
```

## Generated Artifacts

Be careful with these directories:

- `trivy-scan-reports/` is generated by `.github/create-trivy-scan-report.sh` and related workflows.
- `image-list/` is generated by image inventory/SBOM helpers.
- `helm-chart-list/` is generated by `.github/create-helm-dependency-list.sh`.
- `kubeconform-schemas/` can be generated/extracted from CRDs but is also used directly by validation.

Only update generated files when the task is specifically about those reports/lists/schemas, or when the source change requires a matching generated update.

## CI / Release Notes

- PRs should be focused and atomic.
- Conventional Commit-style PR titles are preferred because Release Please is used.
- Important CI workflows include kubeconform, kube-score, GitOps diff rendering, trivy scans/diffs, image and Helm dependency list generation, cluster tests, installer image creation, and release.
- Workflows often use repository variables such as `GITOPS_DIFF_TESTCASES`; mirror the workflow inputs when reproducing locally.

## Agent Checklist

Before finishing a change:

- Run `git status --short` and mention changed files.
- Run relevant render/validation/test commands when feasible.
- If validation needs a live cluster, secrets, or network access that is unavailable, say so clearly.
- Do not clean up, revert, or rewrite unrelated user changes.
- Keep final responses concise and include the exact commands that were run.
