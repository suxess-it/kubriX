# GitHub App for cluster tests

[kubrix-ci-manifest.json](kubrix-ci-manifest.json) is a reusable registration template for the GitHub App used by cluster tests, Backstage, ApplicationSets and test-repository cleanup. It contains configuration only and is safe to publish.

The template is derived from the permissions requested in [cluster-test.yml](../workflows/cluster-test.yml). It is not an export of an existing App's settings. Changes to this file do not automatically update registered Apps.

## Register separate OSS and Prime Apps

Create one App named `kubrix-ci` for OSS and another named `kubrix-prime-ci` for Prime. Both can use this template. For Prime, change `name`, `description` and the homepage `url` as needed. The webhook URL is an inactive placeholder; this CI App does not receive webhook events or perform user OAuth login.

Because `public` is `false`, register each App under `kubriX-demo`, the organization where it will be installed. If the App is owned by a different account, it must permit installation in `kubriX-demo`; see [GitHub App visibility](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/making-a-github-app-public-or-private).

For a one-time setup, [open the prefilled registration form](https://github.com/organizations/kubriX-demo/settings/apps/new?name=kubrix-ci&url=https%3A%2F%2Fgithub.com%2Fsuxess-it%2FkubriX&public=false&webhook_active=false&request_oauth_on_install=false&administration=write&contents=write&metadata=read&pull_requests=write&statuses=read&workflows=write), review the permissions below, and choose a distinct name for Prime. Keep this link aligned with the manifest when changing permissions.

The JSON file is intended for GitHub's [App Manifest flow](https://docs.github.com/en/apps/sharing-github-apps/registering-a-github-app-from-a-manifest), not a file-upload field in the registration UI. An integration using that flow must POST the JSON as the `manifest` form parameter, receive GitHub's temporary code through its registration redirect, and exchange the code at `POST /app-manifests/{code}/conversions` within one hour. The prefilled form above is the simpler manual alternative.

## Repository permissions

| Permission | Access | CI use |
| --- | --- | --- |
| Administration | Read and write | Create and delete test repositories |
| Contents | Read and write | Read catalog files and create/update application content |
| Metadata | Read | Repository metadata; automatically included by GitHub |
| Pull requests | Read and write | Scaffolder/test PRs and preview discovery |
| Commit statuses | Read | Backstage repository token's requested permission |
| Workflows | Read and write | Commit repository content containing workflow files |

No organization permissions or webhook subscriptions are requested. Individual workflow token-generation steps restrict each installation token to the permissions needed by that step.

## Install and configure

1. Install the new App in `kubriX-demo` with access to **all repositories**, including future repositories created by cluster tests.
2. On the App's settings page, copy its **Client ID** and generate a private key.
3. In the repository that should use this App, open **Settings → Secrets and variables → Actions**:
   - Set repository variable `KUBRIX_CI_REPOS_APP_CLIENT_ID` to the Client ID.
   - Set repository secret `KUBRIX_CI_REPOS_APP_PRIVATE_KEY` to the complete PEM private key, including its BEGIN/END lines.
4. Use the OSS App credentials in `suxess-it/kubriX` and the Prime App credentials in `suxess-it/kubriX-prime`.
5. Start a cluster test or the [budget monitor](../workflows/monitor-github-rate-limit.yml) in the relevant repository and verify token creation and repository access.

Workflow definitions can remain identical between OSS and Prime; the repository variable and secret select the App. New credentials apply to newly started jobs, not tokens already issued to running jobs.

Never commit private keys, client secrets, webhook secrets or access tokens. Store the private key only in the repository's Actions secret or your secret-management system. A manifest grants no access until the App is registered and its installation authorized.

## Public OSS to Prime batch sync

The [upstream sync](../workflows/sync-upstream.yaml) and
[release-tag sync](../workflows/sync-release-tag.yaml) workflows support only
`suxess-it/kubriX` → `suxess-it/kubriX-prime` (public source, private target).
Their jobs are skipped in OSS and other repositories. This is separate from
the per-PR `notify-kubrix-prime` / `sync-from-kubrix` flow.

Use the existing sync App, installed on `suxess-it/kubriX-prime`, with Contents,
Pull requests and Workflows read/write. In Prime, provide:

- Actions variable `KUBRIX_CI_SYNC_APP_CLIENT_ID`.
- Actions secret `KUBRIX_CI_SYNC_APP_PRIVATE_KEY` containing the PEM private key.

The public OSS repository is fetched anonymously. The App token is generated
for Prime only and used for cloning Prime, branch pushes and PR creation.
Tokens stay in the process environment; remote URLs and persistent Git config
contain no credentials. The token is revoked when the job ends.
`SYNC_TOKEN`, `UPSTREAM_TOKEN` and the `UPSTREAM_REPO` variable are no longer used
by these workflows. Private or customer-specific upstreams are not supported.

`sync-upstream.yaml` runs manually. `sync-release-tag.yaml` keeps its daily
18:01 UTC schedule and manual trigger, but its job runs only when the Prime
Actions variable `SYNC_RELEASE_TAG` is `true`. Both create PRs against Prime
`main`, using the existing `from-upstream` / `from-upstream-release` branches.
Neither workflow merges a PR automatically. Existing update/tag selection and
conflict behavior are unchanged.

After propagation to the relevant branches, old PAT secrets can be removed
from these workflows' configuration. Revoke a PAT only after checking any
other consumers that may share its value.
