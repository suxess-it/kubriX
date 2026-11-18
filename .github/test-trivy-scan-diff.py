#!/usr/bin/env python3

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

SCRIPT_PATH = Path(__file__).with_name("trivy-scan-diff.py")
SPEC = importlib.util.spec_from_file_location("trivy_scan_diff", SCRIPT_PATH)
trivy_scan_diff = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(trivy_scan_diff)


def vulnerability_entries(vulnerabilities):
    entries = []
    for package, vulnerability_id, severity, installed, *fixed in vulnerabilities:
        entries.append(
            {
                "VulnerabilityID": vulnerability_id,
                "PkgName": package,
                "InstalledVersion": installed,
                "FixedVersion": fixed[0] if fixed else "",
                "Severity": severity,
            }
        )
    return entries


def report(
    image,
    target,
    vulnerabilities,
    tag="v1.0.0",
    os="debian 13",
    os_vulnerabilities=(),
):
    """Trivy JSON image report with an OS result and one binary result."""
    results = []
    if os is not None:
        results.append(
            {
                "Target": f"{image}:{tag} ({os})",
                "Class": "os-pkgs",
                "Type": os.split()[0],
                "Vulnerabilities": vulnerability_entries(os_vulnerabilities),
            }
        )
    results.append(
        {
            "Target": target,
            "Class": "lang-pkgs",
            "Type": "gobinary",
            "Vulnerabilities": vulnerability_entries(vulnerabilities),
        }
    )
    return {"ArtifactName": f"{image}:{tag}", "Results": results}


def write_reports(directory, reports):
    directory.mkdir(parents=True)
    for number, image_report in enumerate(reports, start=1):
        directory.joinpath(f"{number}.json").write_text(
            json.dumps(image_report), encoding="utf-8"
        )


class TrivyScanDiffTest(unittest.TestCase):
    def compare(self, target_report, pr_report):
        target = trivy_scan_diff.parse_report(target_report, "keycloak")
        pr = trivy_scan_diff.parse_report(pr_report, "keycloak")
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
            report("example/image", "binary", existing),
            report("example/image", "binary", [*existing, introduced]),
        )
        self.assert_counts(findings, introduced_high=1)

    def test_high_cve_disappears(self):
        vulnerability = [("package-a", "CVE-2026-11111", "HIGH", "1.0.0")]
        findings = self.compare(
            report("example/image", "binary", vulnerability),
            report("example/image", "binary", []),
        )
        self.assert_counts(findings, fixed_high=1)

    def test_critical_cve_appears_and_disappears(self):
        findings = self.compare(
            report(
                "example/image",
                "binary",
                [("package-a", "CVE-2026-11111", "CRITICAL", "1.0.0")],
            ),
            report(
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
            report(
                "example/image",
                "binary",
                [("package-a", "CVE-2026-11111", "HIGH", "1.0.0")],
            ),
            report(
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
            report("example/image", "binary", target),
            report("example/image", "binary", pr),
        )
        self.assert_counts(findings)

    def test_pr_2935_regression(self):
        findings = self.compare(
            report(
                "example/image",
                "usr/local/bin/provider",
                [("old-package", "GHSA-r277-6w6q-xmqw", "CRITICAL", "1.0.0")],
            ),
            report(
                "example/image",
                "usr/local/bin/provider",
                [("github.com/antchfx/xpath", "CVE-2026-32287", "HIGH", "v1.2.0")],
            ),
        )
        self.assert_counts(findings, fixed_critical=1, introduced_high=1)

    def test_ghsa_vulnerability_can_be_introduced(self):
        findings = self.compare(
            report("example/image", "binary", []),
            report(
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
            report(
                "example/image",
                "binary",
                [("package-a", "CVE-2026-11111", "MEDIUM", "1.0.0")],
            ),
            report(
                "example/image",
                "binary",
                [("package-b", "CVE-2026-22222", "MEDIUM", "1.0.0")],
            ),
        )
        self.assert_counts(findings)

    def test_same_cve_in_different_images_does_not_cancel(self):
        vulnerability = [("stdlib", "CVE-2026-39822", "HIGH", "1.0.0")]
        findings = self.compare(
            report("example/image-a", "binary", vulnerability),
            report("example/image-b", "binary", vulnerability),
        )
        self.assert_counts(findings, fixed_high=1, introduced_high=1)

    def test_image_tag_and_installed_version_are_not_identity(self):
        findings = self.compare(
            report(
                "example/image",
                "binary",
                [("stdlib", "CVE-2026-39822", "HIGH", "v1.25.11")],
                tag="v1.0.0",
            ),
            report(
                "example/image",
                "binary",
                [("stdlib", "CVE-2026-39822", "HIGH", "v1.25.8")],
                tag="v2.0.0",
            ),
        )
        self.assert_counts(findings)

    def test_os_version_and_digest_are_not_identity(self):
        vulnerability = [("openssl", "CVE-2026-11111", "HIGH", "3.0.0-r0")]
        target = report(
            "example/image",
            "binary",
            [],
            tag="v1.0.0",
            os="alpine 3.20.1",
            os_vulnerabilities=vulnerability,
        )
        pr = report(
            "example/image",
            "binary",
            [],
            tag="v1.1.0",
            os="alpine 3.21.0",
            os_vulnerabilities=vulnerability,
        )
        pr["ArtifactName"] = "example/image:v1.1.0@sha256:0123456789abcdef"
        self.assert_counts(self.compare(target, pr))

    def test_registry_port_is_not_mistaken_for_tag(self):
        parsed = trivy_scan_diff.parse_report(
            report(
                "registry.example.com:5000/team/image",
                "binary",
                [("package", "CVE-2026-11111", "HIGH", "1.0.0")],
            ),
            "chart",
        )
        self.assertEqual(
            {identity[1] for identity in parsed},
            {"registry.example.com:5000/team/image"},
        )

    def test_missing_results_and_vulnerabilities_are_empty(self):
        self.assertEqual(
            trivy_scan_diff.parse_report({"ArtifactName": "example/image:v1"}, "c"),
            {},
        )
        self.assertEqual(
            trivy_scan_diff.parse_report(
                {
                    "ArtifactName": "example/image:v1",
                    "Results": [{"Target": "binary", "Vulnerabilities": None}],
                },
                "c",
            ),
            {},
        )

    def test_ids_other_than_cve_and_ghsa_are_ignored(self):
        findings = self.compare(
            report("example/image", "binary", []),
            report(
                "example/image",
                "binary",
                [
                    ("golang.org/x/crypto", "GO-2026-5932", "HIGH", "v0.58.0"),
                    ("libc6", "DLA-1234-1", "CRITICAL", "2.36"),
                ],
            ),
        )
        self.assert_counts(findings)

    def test_pr_3225_binary_only_image_keeps_its_own_image(self):
        """A binary-only image must not inherit another image (PR #3225 false positive)."""
        memcached_exporter = report(
            "docker.io/prom/memcached-exporter",
            "bin/memcached_exporter",
            [("golang.org/x/net", "CVE-2026-78661", "HIGH", "v0.61.0", "0.62.0")],
            tag="v0.18.0",
            os=None,
        )
        nginx = report("docker.io/nginxinc/nginx-unprivileged", "binary", [])
        silo = report(
            "docker.io/pgsty/silo",
            "usr/bin/silo",
            [("golang.org/x/net", "CVE-2026-78661", "HIGH", "v0.61.0", "0.62.0")],
        )
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_reports(root / "target/loki", [nginx, silo, memcached_exporter])
            write_reports(root / "pr/loki", [nginx, memcached_exporter])
            target = trivy_scan_diff.load_vulnerabilities(root / "target")
            pr = trivy_scan_diff.load_vulnerabilities(root / "pr")

        findings = trivy_scan_diff.compare_vulnerabilities(target, pr)
        self.assert_counts(findings, fixed_high=1)
        self.assertEqual(
            findings["fixed_high"],
            {
                (
                    "loki",
                    "docker.io/pgsty/silo",
                    "usr/bin/silo",
                    "golang.org/x/net",
                    "CVE-2026-78661",
                    "HIGH",
                )
            },
        )

    def test_all_reports_of_a_chart_are_loaded(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_reports(
                root / "mimir",
                [
                    report(
                        "docker.io/nginxinc/nginx-unprivileged",
                        "binary",
                        [("package-a", "CVE-2026-11111", "HIGH", "1.0.0")],
                        tag="1.29-alpine",
                    ),
                    report(
                        "docker.io/nginxinc/nginx-unprivileged",
                        "binary",
                        [("package-b", "CVE-2026-22222", "HIGH", "1.0.0")],
                        tag="1.31-alpine",
                    ),
                ],
            )
            loaded = trivy_scan_diff.load_vulnerabilities(root)
        self.assertEqual(
            {identity[4] for identity in loaded},
            {"CVE-2026-11111", "CVE-2026-22222"},
        )

    def test_fixed_cve_table_deduplicates_per_component(self):
        target = {}
        target.update(
            trivy_scan_diff.parse_report(
                report(
                    "example/image-a",
                    "binary-a",
                    [
                        ("package-a", "CVE-2026-22222", "HIGH", "1.0.0"),
                        ("package-b", "CVE-2026-11111", "CRITICAL", "1.0.0"),
                        ("package-c", "GHSA-1111-2222-3333", "HIGH", "1.0.0"),
                        ("package-d", "CVE-2026-44444", "MEDIUM", "1.0.0"),
                    ],
                ),
                "component-b",
            )
        )
        target.update(
            trivy_scan_diff.parse_report(
                report(
                    "example/image-b",
                    "binary-b",
                    [("package-e", "CVE-2026-22222", "HIGH", "1.0.0")],
                ),
                "component-b",
            )
        )
        target.update(
            trivy_scan_diff.parse_report(
                report(
                    "example/image-c",
                    "binary-c",
                    [("package-f", "CVE-2026-33333", "HIGH", "1.0.0")],
                ),
                "component-a",
            )
        )

        table = trivy_scan_diff.format_fixed_cve_table(
            trivy_scan_diff.fixed_component_cves(target, {})
        )

        self.assertEqual(
            table,
            "| Severity | Component | CVEs |\n"
            "|----------|-----------|------|\n"
            "| Critical | component-b | CVE-2026-11111 |\n"
            "| High | component-a | CVE-2026-33333 |\n"
            "| High | component-b | CVE-2026-22222, GHSA-1111-2222-3333 |\n",
        )

    def test_cve_still_present_elsewhere_in_component_is_not_fixed(self):
        target = trivy_scan_diff.parse_report(
            report(
                "example/image-a",
                "old-binary",
                [("old-package", "CVE-2026-11111", "HIGH", "1.0.0")],
            ),
            "component",
        )
        current = trivy_scan_diff.parse_report(
            report(
                "example/image-b",
                "new-binary",
                [("new-package", "CVE-2026-11111", "HIGH", "2.0.0")],
            ),
            "component",
        )

        self.assertEqual(
            trivy_scan_diff.fixed_component_cves(target, current), set()
        )

    def test_cve_with_changed_severity_is_not_fixed(self):
        target = trivy_scan_diff.parse_report(
            report(
                "example/image",
                "binary",
                [("package", "CVE-2026-11111", "HIGH", "1.0.0")],
            ),
            "component",
        )
        current = trivy_scan_diff.parse_report(
            report(
                "example/image",
                "binary",
                [("package", "CVE-2026-11111", "MEDIUM", "2.0.0")],
            ),
            "component",
        )

        self.assertEqual(
            trivy_scan_diff.fixed_component_cves(target, current), set()
        )

    def test_ghsa_still_present_in_component_is_not_fixed(self):
        target = trivy_scan_diff.parse_report(
            report(
                "example/image-a",
                "old-binary",
                [("old-package", "GHSA-1111-2222-3333", "HIGH", "1.0.0")],
            ),
            "component",
        )
        current = trivy_scan_diff.parse_report(
            report(
                "example/image-b",
                "new-binary",
                [("new-package", "GHSA-1111-2222-3333", "HIGH", "2.0.0")],
            ),
            "component",
        )

        self.assertEqual(
            trivy_scan_diff.fixed_component_cves(target, current), set()
        )

    def test_comment_shows_location_and_fixability(self):
        target = trivy_scan_diff.parse_report(
            report(
                "example/image",
                "binary",
                [("old-package", "CVE-2026-33333", "HIGH", "1.0.0", "1.0.1")],
            ),
            "chart",
        )
        pr = trivy_scan_diff.parse_report(
            report(
                "example/image",
                "binary",
                [
                    ("package-a", "CVE-2026-11111", "HIGH", "1.0.0", "1.0.1"),
                    ("package-b", "CVE-2026-22222", "CRITICAL", "2.0.0"),
                    ("package-c", "CVE-2026-44444", "MEDIUM", "3.0.0", "3.0.1"),
                ],
            ),
            "chart",
        )

        comment = trivy_scan_diff.format_comment(target, pr)

        self.assertIn("**Introduced CRITICAL/HIGH vulnerabilities: 2 (1 fixable)**", comment)
        critical_row = (
            "| Critical | chart | example/image | binary | package-b "
            "| CVE-2026-22222 | 2.0.0 | no fix available |"
        )
        high_row = (
            "| High | chart | example/image | binary | package-a "
            "| CVE-2026-11111 | 1.0.0 | 1.0.1 |"
        )
        self.assertIn(critical_row, comment)
        self.assertIn(high_row, comment)
        self.assertLess(comment.index(critical_row), comment.index(high_row))
        self.assertIn(
            "<summary>Fixed CRITICAL/HIGH vulnerabilities: 1</summary>", comment
        )
        self.assertIn("| old-package | CVE-2026-33333 | 1.0.0 | 1.0.1 |", comment)
        self.assertIn(
            "<summary>Introduced MEDIUM/LOW/UNKNOWN vulnerabilities: 1 (1 fixable)</summary>",
            comment,
        )
        self.assertIn("**Fixed MEDIUM/LOW/UNKNOWN vulnerabilities: 0**", comment)

    def test_comment_without_changes(self):
        same = trivy_scan_diff.parse_report(
            report(
                "example/image",
                "binary",
                [("package", "CVE-2026-11111", "HIGH", "1.0.0")],
            ),
            "chart",
        )
        comment = trivy_scan_diff.format_comment(same, same)
        self.assertIn("**Introduced CRITICAL/HIGH vulnerabilities: 0 (0 fixable)**", comment)
        self.assertIn("**Fixed CRITICAL/HIGH vulnerabilities: 0**", comment)
        self.assertNotIn("| Severity |", comment)

    def test_comment_merges_versions_and_escapes_cells(self):
        pr = trivy_scan_diff.parse_report(
            report(
                "example/image",
                "binary",
                [
                    ("pkg|<x>", "CVE-2026-11111", "HIGH", "1.0.0"),
                    ("pkg|<x>", "CVE-2026-11111", "HIGH", "1.1.0", "1.2.0"),
                ],
            ),
            "chart",
        )
        comment = trivy_scan_diff.format_comment({}, pr)
        self.assertIn(
            "| pkg\\|&lt;x&gt; | CVE-2026-11111 | 1.0.0, 1.1.0 | 1.2.0 |", comment
        )
        self.assertIn("(1 fixable)", comment)

    def test_long_comment_drops_optional_tables_but_keeps_introduced_critical_high(self):
        target = trivy_scan_diff.parse_report(
            report(
                "example/old-image",
                "binary",
                [
                    (f"package-{n}", f"CVE-2026-{n}", severity, "1.0.0")
                    for n in range(100000, 101000)
                    for severity in ("HIGH", "MEDIUM")
                ],
            ),
            "chart",
        )
        pr = trivy_scan_diff.parse_report(
            report(
                "example/image",
                "binary",
                [("package", "CVE-2026-99999", "HIGH", "1.0.0", "1.0.1")],
            ),
            "chart",
        )
        self.assertGreater(
            len(trivy_scan_diff.format_comment(target, pr)),
            trivy_scan_diff.MAX_COMMENT_LENGTH,
        )

        comment = trivy_scan_diff.format_limited_comment(target, pr)

        self.assertLessEqual(len(comment), trivy_scan_diff.MAX_COMMENT_LENGTH)
        self.assertIn(
            "| High | chart | example/image | binary | package | CVE-2026-99999 | 1.0.0 | 1.0.1 |",
            comment,
        )
        self.assertIn(
            "**Fixed MEDIUM/LOW/UNKNOWN vulnerabilities: 1000** (table omitted",
            comment,
        )
        self.assertIn("**Fixed CRITICAL/HIGH vulnerabilities: 1000** (table omitted", comment)

    def test_short_comment_is_not_limited(self):
        pr = trivy_scan_diff.parse_report(
            report(
                "example/image",
                "binary",
                [("package", "CVE-2026-11111", "MEDIUM", "1.0.0")],
            ),
            "chart",
        )
        self.assertEqual(
            trivy_scan_diff.format_limited_comment({}, pr),
            trivy_scan_diff.format_comment({}, pr),
        )

    def test_recursive_loading_environment_flags_and_comment_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_reports(
                root / "target/scans/keycloak",
                [report("example/image", "binary", [])],
            )
            write_reports(
                root / "pr/scans/keycloak",
                [
                    report(
                        "example/image",
                        "binary",
                        [("package-a", "CVE-2026-11111", "HIGH", "1.0.0")],
                    )
                ],
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
            self.assertEqual(
                {identity[:2] for identity in pr}, {("keycloak", "example/image")}
            )

    def test_missing_scan_directory_is_empty(self):
        with tempfile.TemporaryDirectory() as tmp:
            self.assertEqual(
                trivy_scan_diff.load_vulnerabilities(Path(tmp) / "missing"), {}
            )


if __name__ == "__main__":
    unittest.main()
