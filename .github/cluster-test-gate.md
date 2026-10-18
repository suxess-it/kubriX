# On-demand PR cluster tests

Cluster tests for pull requests start only when the `run-cluster-tests` label is
added. A request runs every existing profile listed in the repository variable
`CLUSTER_TEST_TARGET_TYPES`. Installer builds remain conditional on installer
changes. Installation and Testkube steps are unchanged.

Opening, reopening, or pushing commits to a PR runs a small, failing
`Cluster Test Gate` check without starting cluster tests or installer builds.
Add the label when the PR is ready to test. If it is already present, remove it
and add it again. A new commit requires a new explicit test request.
Unrelated labels neither satisfy the gate nor cancel running tests.
The gate requires successful change detection, installer build job, and cluster
matrix. Missing configuration, an empty matrix, cancellation, failure, or skipped
tests cannot satisfy it. A workflow_dispatch run is for diagnostics and does not
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
   up to date before merging**. Updating the PR then requires another manual test
   request. Leaving this disabled saves runs but permits a tested PR to merge
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

The regression test executes the gate's actual shell for all combinations of
successful, failed, cancelled, skipped, and missing dependency results.
Live acceptance: confirm an unrequested PR is blocked, a requested successful
matrix releases the gate, and a subsequent commit blocks it without starting
cluster tests. Also confirm unrelated labels cannot release or cancel the gate.
