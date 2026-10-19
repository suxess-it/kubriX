#!/usr/bin/env python3
"""Exercise the installer's repository preflight without GitHub credentials."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


class RepositoryCheck(unittest.TestCase):
    def run_check(self, status, body, transport=0):
        source = Path("install-platform.sh").read_text()
        function = source.split("boostrap_check_downstream_repo_org() {", 1)[1]
        function = "boostrap_check_downstream_repo_org() {" + function.split(
            "\nbootstrap_push_to_downstream()", 1
        )[0]
        with tempfile.TemporaryDirectory() as directory:
            curl = Path(directory) / "curl"
            curl.write_text("""#!/usr/bin/env python3
import os, sys
from pathlib import Path
args = sys.argv[1:]
body = os.environ["TEST_BODY"]
if "-o" in args:
    Path(args[args.index("-o") + 1]).write_text(body)
else:
    print(body, end="")
if "-D" in args:
    Path(args[args.index("-D") + 1]).write_text(
        "HTTP/2 " + os.environ["TEST_STATUS"] + "\\n"
        "x-ratelimit-remaining: 0\\nretry-after: 60\\n"
        "x-github-request-id: test-request\\n")
if "-w" in args:
    print(os.environ["TEST_STATUS"], end="")
sys.exit(int(os.environ["TEST_TRANSPORT"]))
""")
            curl.chmod(0o755)
            env = dict(os.environ, PATH=directory + ":" + os.environ["PATH"],
                       TEST_STATUS=status, TEST_BODY=body,
                       TEST_TRANSPORT=str(transport))
            return subprocess.run(
                ["bash", "-c", 'set -Eeuo pipefail\n'
                 'fail() { echo "$1" >&2; exit 1; }\n' + function +
                 '\nKUBRIX_REPO_URL=github.com/example/repo\n'
                 'KUBRIX_REPO_PASSWORD=test-secret\n'
                 'boostrap_check_downstream_repo_org'],
                env=env, capture_output=True, text=True)

    def test_403_reports_api_failure_and_diagnostics(self):
        result = self.run_check("403", '{"message":"API rate limit exceeded"}', 22)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unable to read repository", result.stderr)
        self.assertIn("403", result.stderr)
        self.assertIn("API rate limit exceeded", result.stderr)
        self.assertIn("x-ratelimit-remaining: 0", result.stderr)
        self.assertIn("retry-after: 60", result.stderr)
        self.assertNotIn("not owned", result.stderr)
        self.assertNotIn("test-secret", result.stderr)

    def test_organization_is_accepted(self):
        self.assertEqual(self.run_check("200", '{"owner":{"type":"Organization"}}').returncode, 0)

    def test_http_error_without_curl_failure_is_rejected(self):
        result = self.run_check("403", '{"message":"Resource not accessible by integration"}')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("HTTP 403", result.stderr)
        self.assertIn("Resource not accessible by integration", result.stderr)
        self.assertNotIn("not owned", result.stderr)

    def test_user_is_rejected(self):
        result = self.run_check("200", '{"owner":{"type":"User"}}')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("not owned by an organization", result.stderr)

    def test_transport_failure_is_rejected(self):
        result = self.run_check("000", "", 6)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unable to read repository", result.stderr)
        self.assertNotIn("not owned", result.stderr)


if __name__ == "__main__":
    unittest.main()
