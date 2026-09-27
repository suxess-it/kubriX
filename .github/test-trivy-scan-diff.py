#!/usr/bin/env python3

import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT_PATH = Path(__file__).with_name("trivy-scan-diff.py")
SPEC = importlib.util.spec_from_file_location("trivy_scan_diff", SCRIPT_PATH)
trivy_scan_diff = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(trivy_scan_diff)


def summary(image, target, vulnerabilities):
    rows = []
    for package, cve, severity, installed in vulnerabilities:
        rows.append(
            f"""
    <tr>
        <td><code>{package}</code></td>
        <td>{cve}</td>
        <td>{severity}</td>
        <td>{installed}</td>
        <td>fixed-version</td>
    </tr>"""
        )
    return f"""
<h3>Target <code>{image}:v1.0.0 (debian 13)</code></h3>
<h4>No Vulnerabilities found</h4>
<h3>Target <code>{target}</code></h3>
<h4>Vulnerabilities ({len(rows)})</h4>
<table>{''.join(rows)}</table>
"""


class TrivyScanDiffTest(unittest.TestCase):
    def compare(self, target_summary, pr_summary):
        target = trivy_scan_diff.parse_summary(target_summary, "keycloak")
        pr = trivy_scan_diff.parse_summary(pr_summary, "keycloak")
        return trivy_scan_diff.compare_vulnerabilities(target, pr)

    def assert_counts(
        self,
        findings,
        fixed_critical=0,
        fixed_high=0,
        introduced_critical=0,
        introduced_high=0,
    ):
        self.assertEqual(len(findings["fixed_critical"]), fixed_critical)
        self.assertEqual(len(findings["fixed_high"]), fixed_high)
        self.assertEqual(len(findings["introduced_critical"]), introduced_critical)
        self.assertEqual(len(findings["introduced_high"]), introduced_high)

    def test_high_cve_appears(self):
        existing = [("package-a", "CVE-2026-11111", "HIGH", "1.0.0")]
        introduced = ("package-b", "CVE-2026-22222", "HIGH", "1.0.0")
        findings = self.compare(
            summary("example/image", "binary", existing),
            summary("example/image", "binary", [*existing, introduced]),
        )
        self.assert_counts(findings, introduced_high=1)

    def test_high_cve_disappears(self):
        vulnerability = [("package-a", "CVE-2026-11111", "HIGH", "1.0.0")]
        findings = self.compare(
            summary("example/image", "binary", vulnerability),
            summary("example/image", "binary", []),
        )
        self.assert_counts(findings, fixed_high=1)

    def test_critical_cve_appears_and_disappears(self):
        findings = self.compare(
            summary(
                "example/image",
                "binary",
                [("package-a", "CVE-2026-11111", "CRITICAL", "1.0.0")],
            ),
            summary(
                "example/image",
                "binary",
                [("package-b", "CVE-2026-22222", "CRITICAL", "1.0.0")],
            ),
        )
        self.assert_counts(
            findings,
            fixed_critical=1,
            introduced_critical=1,
        )

    def test_different_high_cve_disappears_and_appears(self):
        findings = self.compare(
            summary(
                "example/image",
                "binary",
                [("package-a", "CVE-2026-11111", "HIGH", "1.0.0")],
            ),
            summary(
                "example/image",
                "binary",
                [("package-b", "CVE-2026-22222", "HIGH", "1.0.0")],
            ),
        )
        self.assert_counts(findings, fixed_high=1, introduced_high=1)

    def test_installed_version_change_is_not_a_new_identity(self):
        target = [("stdlib", "CVE-2026-39822", "HIGH", "v1.25.11")]
        pr = [("stdlib", "CVE-2026-39822", "HIGH", "v1.25.8")]
        findings = self.compare(
            summary("example/image", "binary", target),
            summary("example/image", "binary", pr),
        )
        self.assert_counts(findings)

    def test_pr_2935_regression(self):
        findings = self.compare(
            summary(
                "example/image",
                "usr/local/bin/provider",
                [("old-package", "GHSA-r277-6w6q-xmqw", "CRITICAL", "1.0.0")],
            ),
            summary(
                "example/image",
                "usr/local/bin/provider",
                [("github.com/antchfx/xpath", "CVE-2026-32287", "HIGH", "v1.2.0")],
            ),
        )
        self.assert_counts(findings, fixed_critical=1, introduced_high=1)

    def test_ghsa_vulnerability_can_be_introduced(self):
        findings = self.compare(
            summary("example/image", "binary", []),
            summary(
                "example/image",
                "binary",
                [
                    (
                        "github.com/getkin/kin-openapi",
                        "GHSA-r277-6w6q-xmqw",
                        "CRITICAL",
                        "v0.133.0",
                    )
                ],
            ),
        )
        self.assert_counts(findings, introduced_critical=1)

    def test_medium_changes_do_not_set_high_or_critical_findings(self):
        findings = self.compare(
            summary(
                "example/image",
                "binary",
                [("package-a", "CVE-2026-11111", "MEDIUM", "1.0.0")],
            ),
            summary(
                "example/image",
                "binary",
                [("package-b", "CVE-2026-22222", "MEDIUM", "1.0.0")],
            ),
        )
        self.assert_counts(findings)

    def test_same_cve_in_different_images_does_not_cancel(self):
        vulnerability = [("stdlib", "CVE-2026-39822", "HIGH", "1.0.0")]
        findings = self.compare(
            summary("example/image-a", "binary", vulnerability),
            summary("example/image-b", "binary", vulnerability),
        )
        self.assert_counts(findings, fixed_high=1, introduced_high=1)

    def test_image_tag_and_installed_version_are_not_identity(self):
        target = summary(
            "example/image",
            "binary",
            [("stdlib", "CVE-2026-39822", "HIGH", "v1.25.11")],
        )
        pr = target.replace(":v1.0.0", ":v2.0.0").replace("v1.25.11", "v1.25.8")
        self.assert_counts(self.compare(target, pr))

    def test_recursive_loading_and_environment_flags(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target_dir = root / "target/scans/keycloak"
            pr_dir = root / "pr/scans/keycloak"
            target_dir.mkdir(parents=True)
            pr_dir.mkdir(parents=True)
            target_dir.joinpath("scan_summary.md").write_text(
                summary("example/image", "binary", []),
                encoding="utf-8",
            )
            pr_dir.joinpath("scan_summary.md").write_text(
                summary(
                    "example/image",
                    "binary",
                    [("package-a", "CVE-2026-11111", "HIGH", "1.0.0")],
                ),
                encoding="utf-8",
            )

            target = trivy_scan_diff.load_vulnerabilities(root / "target/scans")
            pr = trivy_scan_diff.load_vulnerabilities(root / "pr/scans")
            findings = trivy_scan_diff.compare_vulnerabilities(target, pr)
            env_path = root / "github-env"
            trivy_scan_diff.write_flags(env_path, findings)

            self.assertEqual(
                env_path.read_text(encoding="utf-8").splitlines(),
                [
                    "CRITICAL_FIXED=false",
                    "HIGH_FIXED=false",
                    "CRITICAL_INTRODUCED=false",
                    "HIGH_INTRODUCED=true",
                ],
            )


if __name__ == "__main__":
    unittest.main()
