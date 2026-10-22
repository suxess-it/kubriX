# On-demand PR cluster tests

Every PR first gets a lightweight changed-file check. Cluster tests are required
only when a changed file matches `clusterTestRequired` in `cluster-test.yml`.
That filter exactly matches the former PR-trigger paths (also retained under the
push trigger). If no matching files changed, `Cluster Test Gate` succeeds without
an installer build or cluster test, even if the start label is present. A failed
or missing path-check result blocks merging rather than assuming tests are optional.

For relevant changes, ordinary PR cluster tests start only when the
`run-cluster-tests` label is added. A request runs every existing profile listed in the repository variable
`CLUSTER_TEST_TARGET_TYPES`. Installer builds remain conditional on installer
changes. Installation and Testkube steps are unchanged.

Opening, reopening, or pushing commits to an ordinary PR with relevant changes
runs change detection and a failing `Cluster Test Gate` check without starting
cluster tests or installer builds.
Add the label when the PR is ready to test. If it is already present, remove it
and add it again. A new commit requires a new explicit test request.
PRs authored by `renovate[bot]` with `run-cluster-tests` already present also
start required tests automatically when opened, reopened, or updated (including
rebases). Irrelevant changes still skip cluster tests.
This uses the PR author, not the event actor, so a maintainer-triggered rebase of
a Renovate PR is covered. Renovate PRs without the label remain manual. The future
Renovate configuration decides which updates receive the label (for example,
patch automerge PRs); this workflow does not infer update types or enable automerge.
Unrelated labels neither satisfy the gate nor cancel running tests.
The gate requires successful change detection, installer build job, and cluster
matrix when tests are required. Missing configuration, an empty matrix,
cancellation, failure, or skipped required tests cannot satisfy it. A workflow_dispatch run is for diagnostics and does not
satisfy the PR gate; use the label for required PR validation.

## One-time repository setup

1. Merge the workflow PR. Create a repository label named `run-cluster-tests`
   if it does not already exist (the label itself is repository metadata).
2. On a PR containing the new workflow, add the label and confirm a successful
   cluster run and a successful `Cluster Test Gate` check.
3. Open **Settings → Rules → Rulesets → protect-main → Edit**.
4. Enable **Require status checks to pass** and add the exact check name
   **Cluster Test Gate**. Select **GitHub Actions** as the expected source if
   offered. Keep the ruleset **Active**, targeting the default branch.
5. Keep the bypass list empty if tests must be mandatory even for administrators.
   The independent review ruleset may retain its admin review bypass.
6. For validation against the latest base branch, enable **Require branches to be
   up to date before merging**. Updating an ordinary PR then requires another
   manual test request; labeled Renovate PRs retest automatically. Leaving this disabled saves runs but permits a tested PR to merge
   after the base branch has changed.

Do not require the individual dynamic matrix jobs instead of the gate: GitHub
can accept skipped jobs as successful required checks. Do not configure a required
workflow rule for this gate; configure the named status check.

The existing `protect-main` ruleset targets only the default branch. To protect
maintenance branches too, add those targets explicitly. Apply equivalent ruleset
and label setup independently in kubriX-prime after the workflow sync arrives.
This workflow does not implement merge-queue (`merge_group`) testing.

## Verification

With Python and PyYAML installed:

```sh
python .github/tests/cluster-test-gate.py
git diff --check
```

The regression tests verify path-list parity, the request policy, irrelevant-change
handling, and the gate's actual shell for all combinations of
successful, failed, cancelled, skipped, and missing dependency results.
Live acceptance: confirm an unrequested PR is blocked, a requested successful
matrix releases the gate, and a subsequent commit blocks it without starting
cluster tests. Also confirm unrelated labels cannot release or cancel the gate.

Also verify a documentation-only PR passes the gate without a label or cluster run.
