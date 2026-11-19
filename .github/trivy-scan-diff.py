#!/usr/bin/env python3

import argparse
import json
import re
from pathlib import Path

VULNERABILITY_ID_PATTERN = re.compile(
    r"(?:CVE-\d{4}-\d+|GHSA-[0-9A-Z]{4}(?:-[0-9A-Z]{4}){2})",
    re.IGNORECASE,
)
SEVERITIES = {"UNKNOWN", "LOW", "MEDIUM", "HIGH", "CRITICAL"}
TABLE_SEVERITIES = ("CRITICAL", "HIGH")
OTHER_SEVERITIES = ("MEDIUM", "LOW", "UNKNOWN")
# stay below GitHub's comment size limit
MAX_COMMENT_LENGTH = 60000
# tables dropped in this order when the comment is too long;
# the table of introduced CRITICAL/HIGH vulnerabilities is always kept
OPTIONAL_TABLES = (
    "Fixed MEDIUM/LOW/UNKNOWN vulnerabilities",
    "Introduced MEDIUM/LOW/UNKNOWN vulnerabilities",
    "Fixed CRITICAL/HIGH vulnerabilities",
)


def strip_image_tag(image):
    image = image.split("@", 1)[0]
    last_slash = image.rfind("/")
    last_colon = image.rfind(":")
    if last_colon > last_slash:
        image = image[:last_colon]
    return image


def parse_report(report, chart):
    """Map each finding of a Trivy JSON image report to its installed and fixed versions.

    The identity ignores image tag, OS version and installed version, so that
    upgrading an image only shows vulnerabilities that really appear or disappear.
    """
    image = strip_image_tag(report.get("ArtifactName") or "")
    vulnerabilities = {}
    for result in report.get("Results") or []:
        # the OS target contains image tag and OS version, e.g. "img:1.0 (alpine 3.20)"
        target = "os" if result.get("Class") == "os-pkgs" else result.get("Target", "")
        for vulnerability in result.get("Vulnerabilities") or []:
            vulnerability_id_match = VULNERABILITY_ID_PATTERN.fullmatch(
                vulnerability.get("VulnerabilityID", "")
            )
            severity = vulnerability.get("Severity", "").upper()
            if not vulnerability_id_match or severity not in SEVERITIES:
                continue
            identity = (
                chart,
                image,
                target,
                vulnerability.get("PkgName", ""),
                vulnerability_id_match.group(0).upper(),
                severity,
            )
            installed, fixed = vulnerabilities.setdefault(identity, (set(), set()))
            installed.add(vulnerability.get("InstalledVersion") or "")
            fixed.add(vulnerability.get("FixedVersion") or "")
    return vulnerabilities


def load_vulnerabilities(root):
    vulnerabilities = {}
    for report_file in sorted(root.rglob("*.json")):
        chart = report_file.relative_to(root).parent.as_posix()
        report = json.loads(report_file.read_text(encoding="utf-8"))
        for identity, (installed, fixed) in parse_report(report, chart).items():
            known_installed, known_fixed = vulnerabilities.setdefault(
                identity, (set(), set())
            )
            known_installed.update(installed)
            known_fixed.update(fixed)
    return vulnerabilities


def compare_vulnerabilities(target, pr):
    fixed = set(target) - set(pr)
    introduced = set(pr) - set(target)
    return {
        "fixed_critical": {item for item in fixed if item[-1] == "CRITICAL"},
        "fixed_high": {item for item in fixed if item[-1] == "HIGH"},
        "introduced_critical": {
            item for item in introduced if item[-1] == "CRITICAL"
        },
        "introduced_high": {item for item in introduced if item[-1] == "HIGH"},
    }


def component_cves(vulnerabilities):
    """Project CVE and GHSA findings onto the identity used by release notes."""
    return {
        (chart, vulnerability_id, severity)
        for chart, _, _, _, vulnerability_id, severity in vulnerabilities
        if severity in TABLE_SEVERITIES
    }


def fixed_component_cves(target, current):
    """Return CVEs that disappeared completely from a component."""
    current_ids = {
        (chart, vulnerability_id)
        for chart, _, _, _, vulnerability_id, _ in current
    }
    fixed = {}
    for chart, vulnerability_id, severity in component_cves(target):
        key = (chart, vulnerability_id)
        if key in current_ids:
            continue
        if severity == "CRITICAL" or key not in fixed:
            fixed[key] = severity
    return {
        (chart, vulnerability_id, severity)
        for (chart, vulnerability_id), severity in fixed.items()
    }


def format_fixed_cve_table(fixed):
    grouped = {}
    for chart, vulnerability_id, severity in fixed:
        grouped.setdefault((severity, chart), set()).add(vulnerability_id)

    lines = [
        "| Severity | Component | CVEs |",
        "|----------|-----------|------|",
    ]
    for severity in TABLE_SEVERITIES:
        for _, chart in sorted(key for key in grouped if key[0] == severity):
            vulnerability_ids = ", ".join(sorted(grouped[(severity, chart)]))
            lines.append(
                f"| {severity.title()} | {chart} | {vulnerability_ids} |"
            )
    return "\n".join(lines) + "\n"


def format_identity(identity):
    chart, image, target, package, vulnerability_id, _ = identity
    context = image or "unknown image"
    return f"{chart} | {context} | {target} | {package} | {vulnerability_id}"


def markdown_cell(value):
    return value.replace("|", "\\|").replace("<", "&lt;").replace(">", "&gt;")


def format_findings_table(identities, details, severities):
    severity_order = {severity: index for index, severity in enumerate(severities)}
    lines = [
        "| Severity | Chart | Image | Target | Package | ID | Installed | Fixed in |",
        "|----------|-------|-------|--------|---------|----|-----------|----------|",
    ]
    for identity in sorted(
        identities, key=lambda identity: (severity_order[identity[-1]], identity)
    ):
        chart, image, target, package, vulnerability_id, severity = identity
        installed, fixed = details[identity]
        fixed_versions = ", ".join(sorted(version for version in fixed if version))
        cells = [
            severity.title(),
            chart,
            image or "unknown image",
            target,
            package,
            vulnerability_id,
            ", ".join(sorted(version for version in installed if version)),
            fixed_versions or "no fix available",
        ]
        lines.append("| " + " | ".join(markdown_cell(cell) for cell in cells) + " |")
    return "\n".join(lines) + "\n"


def format_comment_section(
    title, identities, details, severities, collapsed, with_table
):
    heading = f"{title}: {len(identities)}"
    if title.startswith("Introduced"):
        fixable = sum(1 for identity in identities if any(details[identity][1]))
        heading += f" ({fixable} fixable)"
    if not identities:
        return f"**{heading}**\n"
    if not with_table:
        return (
            f"**{heading}** (table omitted to stay within GitHub's comment size "
            "limit, see the workflow log)\n"
        )
    table = format_findings_table(identities, details, severities)
    if collapsed:
        return f"<details><summary>{heading}</summary>\n\n{table}\n</details>\n"
    return f"**{heading}**\n\n{table}"


def format_comment(target, pr, omitted_tables=()):
    """PR comment listing where vulnerabilities are introduced or fixed."""
    introduced = set(pr) - set(target)
    fixed = set(target) - set(pr)
    sections = ["### Trivy scan diff\n"]
    for severities, collapsed in ((TABLE_SEVERITIES, False), (OTHER_SEVERITIES, True)):
        label = "/".join(severities)
        for title, identities, details, section_collapsed in (
            (f"Introduced {label} vulnerabilities", introduced, pr, collapsed),
            (f"Fixed {label} vulnerabilities", fixed, target, True),
        ):
            sections.append(
                format_comment_section(
                    title,
                    {identity for identity in identities if identity[-1] in severities},
                    details,
                    severities,
                    section_collapsed,
                    title not in omitted_tables,
                )
            )
    return "\n".join(sections)


def format_limited_comment(target, pr):
    omitted_tables = []
    comment = format_comment(target, pr)
    for title in OPTIONAL_TABLES:
        if len(comment) <= MAX_COMMENT_LENGTH:
            break
        omitted_tables.append(title)
        comment = format_comment(target, pr, omitted_tables)
    return comment


def print_findings(label, findings):
    print(f"{label}: {len(findings)}")
    for identity in sorted(findings):
        print(f"  {format_identity(identity)}")


def write_flags(github_env, findings):
    flags = {
        "CRITICAL_FIXED": findings["fixed_critical"],
        "HIGH_FIXED": findings["fixed_high"],
        "CRITICAL_INTRODUCED": findings["introduced_critical"],
        "HIGH_INTRODUCED": findings["introduced_high"],
    }
    with github_env.open("a", encoding="utf-8") as env_file:
        for name, values in flags.items():
            env_file.write(f"{name}={'true' if values else 'false'}\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target-dir", required=True, type=Path)
    parser.add_argument("--pr-dir", required=True, type=Path)
    parser.add_argument("--github-env", required=True, type=Path)
    parser.add_argument(
        "--fixed-cve-table",
        type=Path,
        help="write a changelog-ready table of fixed CRITICAL/HIGH CVEs and GHSAs",
    )
    parser.add_argument(
        "--comment-file",
        type=Path,
        help="write a PR comment listing introduced and fixed vulnerabilities",
    )
    args = parser.parse_args()

    target = load_vulnerabilities(args.target_dir)
    pr = load_vulnerabilities(args.pr_dir)
    findings = compare_vulnerabilities(target, pr)

    print(f"Target vulnerabilities: {len(target)}")
    print(f"PR vulnerabilities: {len(pr)}")
    print_findings("Fixed CRITICAL vulnerabilities", findings["fixed_critical"])
    print_findings("Fixed HIGH vulnerabilities", findings["fixed_high"])
    print_findings(
        "Introduced CRITICAL vulnerabilities", findings["introduced_critical"]
    )
    print_findings("Introduced HIGH vulnerabilities", findings["introduced_high"])
    write_flags(args.github_env, findings)
    if args.comment_file:
        comment = format_limited_comment(target, pr)
        if comment != format_comment(target, pr):
            print("PR comment was shortened, full comment:")
            print(format_comment(target, pr))
        args.comment_file.write_text(comment, encoding="utf-8")
    if args.fixed_cve_table:
        fixed = fixed_component_cves(target, pr)
        args.fixed_cve_table.write_text(
            format_fixed_cve_table(fixed), encoding="utf-8"
        )


if __name__ == "__main__":
    main()
