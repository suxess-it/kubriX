#!/usr/bin/env python3

import argparse
import re
from html.parser import HTMLParser
from pathlib import Path

VULNERABILITY_ID_PATTERN = re.compile(
    r"(?:CVE-\d{4}-\d+|GHSA-[0-9A-Z]{4}(?:-[0-9A-Z]{4}){2})",
    re.IGNORECASE,
)
SEVERITIES = {"UNKNOWN", "LOW", "MEDIUM", "HIGH", "CRITICAL"}


def normalize_image(target):
    match = re.match(r"(.+)\s+\([^)]+\)$", target)
    if not match:
        return None

    image = match.group(1).split("@", 1)[0]
    last_slash = image.rfind("/")
    last_colon = image.rfind(":")
    if last_colon > last_slash:
        image = image[:last_colon]
    return image


class TrivySummaryParser(HTMLParser):
    def __init__(self, chart):
        super().__init__(convert_charrefs=True)
        self.chart = chart
        self.image = ""
        self.target = ""
        self.vulnerabilities = set()
        self._heading = None
        self._heading_text = []
        self._row = None
        self._cell = None

    def handle_starttag(self, tag, attrs):
        if tag == "h3":
            self._heading = tag
            self._heading_text = []
        elif tag == "tr":
            self._row = []
        elif tag == "td" and self._row is not None:
            self._cell = []

    def handle_data(self, data):
        if self._heading is not None:
            self._heading_text.append(data)
        if self._cell is not None:
            self._cell.append(data)

    def handle_endtag(self, tag):
        if tag == "h3" and self._heading is not None:
            heading = " ".join("".join(self._heading_text).split())
            if heading.startswith("Target "):
                self.target = heading.removeprefix("Target ")
                image = normalize_image(self.target)
                if image is not None:
                    self.image = image
                    self.target = image
            self._heading = None
            self._heading_text = []
        elif tag == "td" and self._cell is not None:
            self._row.append(" ".join("".join(self._cell).split()))
            self._cell = None
        elif tag == "tr" and self._row is not None:
            self._add_vulnerability(self._row)
            self._row = None
            self._cell = None

    def _add_vulnerability(self, cells):
        if len(cells) < 3:
            return

        vulnerability_id_match = VULNERABILITY_ID_PATTERN.fullmatch(cells[1])
        severity = cells[2].upper()
        if not vulnerability_id_match or severity not in SEVERITIES:
            return

        self.vulnerabilities.add(
            (
                self.chart,
                self.image,
                self.target,
                cells[0],
                vulnerability_id_match.group(0).upper(),
                severity,
            )
        )


def parse_summary(content, chart):
    parser = TrivySummaryParser(chart)
    parser.feed(content)
    parser.close()
    return parser.vulnerabilities


def load_vulnerabilities(root):
    vulnerabilities = set()
    for summary in sorted(root.rglob("scan_summary.md")):
        chart = summary.relative_to(root).parent.as_posix()
        vulnerabilities.update(parse_summary(summary.read_text(encoding="utf-8"), chart))
    return vulnerabilities


def compare_vulnerabilities(target, pr):
    fixed = target - pr
    introduced = pr - target
    return {
        "fixed_critical": {item for item in fixed if item[-1] == "CRITICAL"},
        "fixed_high": {item for item in fixed if item[-1] == "HIGH"},
        "introduced_critical": {
            item for item in introduced if item[-1] == "CRITICAL"
        },
        "introduced_high": {item for item in introduced if item[-1] == "HIGH"},
    }


def format_identity(identity):
    chart, image, target, package, vulnerability_id, _ = identity
    context = image or "unknown image"
    return f"{chart} | {context} | {target} | {package} | {vulnerability_id}"


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


if __name__ == "__main__":
    main()
