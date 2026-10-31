#!/usr/bin/env python3
"""Offline Git/credential tests for the public OSS -> Prime sync workflows.

Run with python3 .github/tests/upstream-sync.py (requires PyYAML and Git).
No network requests or real GitHub credentials are used.
"""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

import yaml


ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = ("sync-upstream.yaml", "sync-release-tag.yaml")
TOKEN = "offline-test-app-token"


def workflow(name):
    return yaml.safe_load((ROOT / ".github/workflows" / name).read_text())


class UpstreamSync(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.config = self.base / "gitconfig"
        self.config.touch()
        self.env = os.environ | {
            "GIT_CONFIG_GLOBAL": str(self.config),
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_TERMINAL_PROMPT": "0",
            "GITHUB_REPOSITORY": "suxess-it/kubriX-prime",
        }

    def git(self, *args, cwd=None, env=None):
        return subprocess.run(
            ["git", *args], cwd=cwd, env=env or self.env,
            text=True, capture_output=True, check=True,
        ).stdout.strip()

    def credentials(self, host, token):
        env = self.env | workflow(WORKFLOWS[0])["jobs"]["build"]["env"]
        env["GIT_APP_TOKEN"] = token
        return subprocess.run(
            ["git", "credential", "fill"],
            input=f"protocol=https\nhost={host}\npath=suxess-it/kubriX-prime.git\n\n",
            env=env, text=True, capture_output=True,
        )

    def test_app_credentials_are_supplied_only_to_github(self):
        result = self.credentials("github.com", TOKEN)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("username=x-access-token", result.stdout)
        self.assertIn(f"password={TOKEN}", result.stdout)
        other = self.credentials("other.invalid", TOKEN)
        self.assertNotEqual(other.returncode, 0)
        self.assertNotIn(TOKEN, other.stdout + other.stderr)

    def test_anonymous_fetch_cannot_reuse_ambient_credentials(self):
        # The workflow clears any previously configured credential helpers.
        self.git("config", "--file", str(self.config), "credential.helper",
                 "!f() { printf 'username=old-user\npassword=old-pat\n'; }; f")
        result = self.credentials("github.com", "")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("old-pat", result.stdout + result.stderr)

    def test_token_does_not_persist_after_git_process(self):
        self.assertEqual(self.credentials("github.com", TOKEN).returncode, 0)
        self.assertNotIn(TOKEN, self.config.read_text())
        result = subprocess.run(
            ["git", "credential", "fill"],
            input="protocol=https\nhost=github.com\n\n",
            env=self.env, text=True, capture_output=True,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn(TOKEN, result.stdout + result.stderr)

    def test_workflow_scope_and_syntax(self):
        for name in WORKFLOWS:
            w = workflow(name)
            self.assertEqual(w["permissions"], {})
            job = w["jobs"]["build"]
            self.assertIn("github.repository == 'suxess-it/kubriX-prime'", job["if"])
            self.assertEqual(job["env"]["UPSTREAM_REPO"], "suxess-it/kubriX")
            token = job["steps"][0]["with"]
            self.assertEqual(token["owner"], "suxess-it")
            self.assertEqual(token["repositories"], "kubriX-prime")
            self.assertNotIn("skip-token-revoke", token)
            if name == WORKFLOWS[1]:
                self.assertIn("vars.SYNC_RELEASE_TAG == 'true'", job["if"])
            text = (ROOT / ".github/workflows" / name).read_text()
            self.assertNotIn("secrets.SYNC_TOKEN", text)
            self.assertNotIn("secrets.UPSTREAM_TOKEN", text)
            for step in job["steps"]:
                if "run" in step:
                    subprocess.run(["bash", "-n"], input=step["run"],
                                   text=True, capture_output=True, check=True)

    def fixture(self):
        source = self.base / "source"
        self.git("init", "--initial-branch=main", str(source))
        self.git("config", "user.name", "Original contributor", cwd=source)
        self.git("config", "user.email", "contributor@example.invalid", cwd=source)
        self.commit(source, 1)
        self.git("tag", "-a", "v1.0.0", "-m", "first", cwd=source)
        target = self.base / "target.git"
        self.git("clone", "--bare", str(source), str(target))
        self.commit(source, 2)
        self.git("tag", "-a", "v2.0.0", "-m", "second", cwd=source)
        for repo, path in [("kubriX", source), ("kubriX-prime", target)]:
            self.git("config", "--file", str(self.config),
                     f"url.{path.as_uri()}.insteadOf", f"https://github.com/suxess-it/{repo}.git")
        bin_dir = self.base / "bin"
        bin_dir.mkdir()
        gh = bin_dir / "gh"
        gh.write_text("""#!/usr/bin/env python3
import json, os, sys
with open(os.environ['GH_CALLS'], 'a') as f:
    f.write(json.dumps(sys.argv[1:]) + '\\n')
if sys.argv[1:3] == ['pr', 'view']:
    print('OPEN' if os.environ.get('PR_OPEN') else 'CLOSED')
elif sys.argv[1:3] == ['pr', 'create']:
    print('offline mock PR created')
else:
    sys.exit(1)
""")
        gh.chmod(0o755)
        self.env |= {"PATH": str(bin_dir) + ":" + self.env["PATH"],
                     "GH_CALLS": str(self.base / "gh-calls")}
        return source, target

    def commit(self, repo, number):
        (repo / "change.txt").write_text(f"upstream change {number}\n")
        self.git("add", ".", cwd=repo)
        self.git("commit", "-m", f"upstream {number}", cwd=repo,
                 env=self.env | {
                     "GIT_AUTHOR_DATE": f"2026-01-01T00:00:{number:02d}Z",
                     "GIT_COMMITTER_DATE": f"2026-01-01T00:00:{number:02d}Z",
                 })

    def run_workflow_scripts(self, name, folder):
        folder.mkdir()
        job = workflow(name)["jobs"]["build"]
        for step in job["steps"]:
            if "run" not in step:
                continue
            env = self.env | job["env"]
            env |= {key: TOKEN for key in step.get("env", {})}
            result = subprocess.run(["bash", "-e", "-o", "pipefail"],
                                    input=step["run"], cwd=folder, env=env,
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn(TOKEN, result.stdout + result.stderr)
        self.assertNotIn(TOKEN, (folder / ".git/config").read_text())
        self.assertEqual(self.git("config", "--local", "--get", "remote.origin.url", cwd=folder),
                         "https://github.com/suxess-it/kubriX-prime.git")
        self.assertEqual(self.git("config", "--local", "--get", "remote.upstream.url", cwd=folder),
                         "https://github.com/suxess-it/kubriX.git")

    def test_branch_sync_pushes_original_commits_and_opens_pr(self):
        source, target = self.fixture()
        self.run_workflow_scripts(WORKFLOWS[0], self.base / "work")
        self.assertEqual(self.git("rev-parse", "refs/heads/from-upstream", cwd=target),
                         self.git("rev-parse", "main", cwd=source))
        calls = [json.loads(line) for line in (self.base / "gh-calls").read_text().splitlines()]
        self.assertEqual(sum(call[:2] == ["pr", "create"] for call in calls), 1)

    def test_existing_open_branch_sync_updates_without_duplicate_pr(self):
        source, target = self.fixture()
        self.run_workflow_scripts(WORKFLOWS[0], self.base / "first")
        self.commit(source, 3)
        (self.base / "gh-calls").write_text("")
        self.env["PR_OPEN"] = "1"
        self.run_workflow_scripts(WORKFLOWS[0], self.base / "second")
        self.assertEqual(self.git("rev-parse", "refs/heads/from-upstream", cwd=target),
                         self.git("rev-parse", "main", cwd=source))
        calls = (self.base / "gh-calls").read_text()
        self.assertNotIn('"create"', calls)

    def test_release_sync_pushes_selected_tag_and_opens_pr(self):
        source, target = self.fixture()
        self.run_workflow_scripts(WORKFLOWS[1], self.base / "work")
        self.assertEqual(self.git("rev-parse", "refs/heads/from-upstream-release", cwd=target),
                         self.git("rev-parse", "v2.0.0^{commit}", cwd=source))
        calls = (self.base / "gh-calls").read_text()
        self.assertIn('"create"', calls)


if __name__ == "__main__":
    unittest.main(verbosity=2)
