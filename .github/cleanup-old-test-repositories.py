#!/usr/bin/env python3
"""Delete only old, precisely named CI repositories in kubriX-demo."""
import argparse
from datetime import datetime, timedelta, timezone
import json
import os
from pathlib import Path
import re
import sys
import time
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

OWNER = "kubriX-demo"
MIN_AGE = timedelta(hours=6)
NAME_PATTERN = re.compile(
    r"(?:kubrix-cluster-test-[0-9]+-[0-9]+"
    r"|kubrix-bootstrap-test-[0-9]+"
    r"|kubrix-a[0-9a-f]{10}-(?:apps|kubrixbot-app|kubrixbot-vcluster|kubrixbot-vm)"
    r"|kubrixcontrol-a[0-9a-f]{10}-apps)"
)


def eligible(repo, cutoff):
    if not NAME_PATTERN.fullmatch(repo.get("name", "")):
        return False
    if repo.get("full_name", "") != f"{OWNER}/{repo['name']}":
        return False
    created = datetime.fromisoformat(repo["created_at"].replace("Z", "+00:00"))
    return created < cutoff


class GitHub:
    def __init__(self, token):
        self.token = token

    def request(self, method, path):
        req = Request("https://api.github.com" + path, method=method, headers={
            "Authorization": f"Bearer {self.token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "kubrix-stale-test-repository-cleanup",
        })
        try:
            with urlopen(req, timeout=30) as response:
                body = response.read()
                return response.status, json.loads(body) if body else None
        except HTTPError as error:
            if error.code == 404:
                return 404, None
            # Stop rather than hammering an exhausted installation or hiding errors.
            details = {key: error.headers.get(key) for key in (
                "x-github-request-id", "x-ratelimit-remaining",
                "x-ratelimit-reset", "retry-after",
            )}
            raise RuntimeError(
                f"{method} {path}: HTTP {error.code}; {json.dumps(details)}. "
                "For rate limits, rerun after Retry-After/reset; no further requests will be made."
            ) from None


def collect_candidates(api, cutoff):
    candidates = []
    page = 1
    while True:
        status, repos = api.request(
            "GET", f"/orgs/{OWNER}/repos?type=all&sort=created&direction=asc&per_page=100&page={page}"
        )
        if status != 200 or not isinstance(repos, list):
            raise RuntimeError("Unable to list repositories; refusing cleanup")
        candidates.extend(repo for repo in repos if eligible(repo, cutoff))
        if len(repos) < 100:
            return candidates
        page += 1


def delete_candidate(api, candidate, cutoff):
    path = f"/repos/{candidate['full_name']}"
    status, current = api.request("GET", path)
    if status == 404:
        return "already absent"
    if status != 200 or not isinstance(current, dict):
        raise RuntimeError(f"Unable to recheck {candidate['full_name']}")
    if current.get("id") != candidate["id"] or not eligible(current, cutoff):
        return "skipped: identity or eligibility changed"
    status, _ = api.request("DELETE", path)
    if status not in (204, 404):
        raise RuntimeError(f"Unexpected deletion status {status}")
    return "deleted" if status == 204 else "already absent"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--delete", action="store_true", help="Delete; default is preview only")
    args = parser.parse_args()
    token = os.environ.get("GH_TOKEN")
    if not token:
        raise RuntimeError("GH_TOKEN is required")
    cutoff = datetime.now(timezone.utc) - MIN_AGE
    api = GitHub(token)
    candidates = collect_candidates(api, cutoff)
    mode = "DELETE" if args.delete else "PREVIEW"
    header = f"{mode}: {len(candidates)} matching repositories in {OWNER}, created before {cutoff.isoformat()}"
    print(header, flush=True)
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with Path(summary_path).open("a") as summary:
            summary.write(f"## Old test repository cleanup\n\n{header}\n\n| Repository | Created (UTC) | Result |\n|---|---|---|\n")
    for repo in candidates:
        result = delete_candidate(api, repo, cutoff) if args.delete else "would delete"
        print(f"{repo['full_name']} created={repo['created_at']}: {result}", flush=True)
        if summary_path:
            with Path(summary_path).open("a") as summary:
                summary.write(f"| {repo['full_name']} | {repo['created_at']} | {result} |\n")
        if result == "deleted":
            time.sleep(1)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, URLError, ValueError, KeyError) as error:
        print(f"Cleanup stopped: {error}", file=sys.stderr)
        sys.exit(1)
