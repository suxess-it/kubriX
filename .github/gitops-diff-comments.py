#!/usr/bin/env python3
"""Turn the rendered GitOps diffs of all test cases into PR comment bodies.

Reads <diff-dir>/<testCase>/diff.txt and default-values-diff.txt as written by
create-pr-comment-file.sh and writes one Markdown file per PR comment into the
output directory: summary.md and, unless too many charts changed, one
chart-<chart>.md per changed chart. The workflow creates, updates and deletes
the PR comments to match these files.
"""

import argparse
import re
from dataclasses import dataclass
from itertools import groupby
from pathlib import Path

# GitHub allows 65536 characters per comment; keep some headroom.
MAX_COMMENT_LENGTH = 60000
MAX_CHART_COMMENTS = 10
# Reserved for the note that lists how many files were left out of a comment.
TRUNCATION_NOTE_RESERVE = 500
DIFF_HEADER_PREFIX = "diff -U"
# diff -N shows a file that exists on one side only with this timestamp.
MISSING_FILE_TIMESTAMP = "1970-01-01 00:00:00"


@dataclass
class FileDiff:
    chart: str
    test_case: str
    text: str
    status: str
    additions: int
    deletions: int


def split_file_diffs(diff):
    """Split `diff -r` output into one chunk per compared file."""
    chunks = []
    for line in diff.splitlines(keepends=True):
        if line.startswith(DIFF_HEADER_PREFIX):
            chunks.append([])
        if chunks:
            chunks[-1].append(line)
    return ["".join(chunk) for chunk in chunks]


def classify_file(old_header, new_header):
    if MISSING_FILE_TIMESTAMP in old_header:
        return "added"
    if MISSING_FILE_TIMESTAMP in new_header:
        return "removed"
    return "modified"


def parse_file_diff(text):
    header, old_header, new_header, *hunks = text.splitlines()
    # header: diff -U 4 -rN out/target/<chart>/<testCase>/... out/pr/<chart>/<testCase>/...
    _, _, chart, test_case, *_ = header.split()[-2].split("/")
    return FileDiff(
        chart=chart,
        test_case=test_case,
        text=text,
        status=classify_file(old_header, new_header),
        additions=sum(line.startswith("+") for line in hunks),
        deletions=sum(line.startswith("-") for line in hunks),
    )


def parse_diff(diff):
    return [parse_file_diff(chunk) for chunk in split_file_diffs(diff)]


def describe(file_diffs):
    count = {status: 0 for status in ("added", "removed", "modified")}
    for file_diff in file_diffs:
        count[file_diff.status] += 1
    return f"{count['added']} added, {count['removed']} removed, {count['modified']} modified"


def describe_lines(file_diffs):
    additions = sum(file_diff.additions for file_diff in file_diffs)
    deletions = sum(file_diff.deletions for file_diff in file_diffs)
    return f"+{additions} / -{deletions}"


def code_fence(text):
    """Return a fence longer than any backtick run in the text."""
    longest_run = max((len(run) for run in re.findall(r"`+", text)), default=0)
    return "`" * max(3, longest_run + 1)


def code_block(text):
    fence = code_fence(text)
    body = text.rstrip("\n")
    return f"{fence}diff\n{body}\n{fence}\n"


def details(summary, body):
    return f"<details><summary>{summary}</summary>\n\n{body}\n</details>\n\n"


def marker(name):
    return f"<!-- gitops-diff:{name} -->\n"


def full_diff_link(run_url):
    return (
        f"The full diffs are attached as artifacts to the "
        f"[workflow run]({run_url}).\n"
    )


def by_chart_and_test_case(file_diff):
    return file_diff.chart, file_diff.test_case


def render_summary_table(file_diffs):
    if not file_diffs:
        return "No changes in the rendered manifests.\n\n"
    lines = [
        "| Chart | Test case | Files | Lines |",
        "|-------|-----------|-------|-------|",
    ]
    for (chart, test_case), group in groupby(file_diffs, key=by_chart_and_test_case):
        group = list(group)
        lines.append(
            f"| `{chart}` | {test_case} | {len(group)} ({describe(group)}) | {describe_lines(group)} |"
        )
    return "\n".join(lines) + "\n\n"


def render_summary(file_diffs, charts, default_values_diff, run_url):
    parts = [marker("summary"), "### GitOps diff\n\n", render_summary_table(file_diffs)]
    if len(charts) > MAX_CHART_COMMENTS:
        parts.append(
            f"{len(charts)} charts changed, so their rendered diffs are not posted "
            f"as separate comments (limit: {MAX_CHART_COMMENTS}).\n\n"
        )
    elif charts:
        parts.append("The rendered diff of each chart is posted as a separate comment.\n\n")

    footer = full_diff_link(run_url)
    if default_values_diff:
        # Subchart default values don't depend on the test case, so show them once.
        section = details("Changes Default Values", code_block(default_values_diff))
        if len("".join(parts)) + len(section) + len(footer) > MAX_COMMENT_LENGTH:
            section = "The default values diff is too large for a comment.\n\n"
        parts.append(section)
    parts.append(footer)
    return "".join(parts)


def render_chart_comment(chart, file_diffs, run_url):
    parts = [marker(f"chart-{chart}"), f"### GitOps diff: `{chart}`\n\n"]
    length = len("".join(parts))
    omitted = 0
    for test_case, group in groupby(file_diffs, key=lambda file_diff: file_diff.test_case):
        group = list(group)
        fence = code_fence("".join(file_diff.text for file_diff in group))
        opening = (
            f"<details><summary>{test_case}: {describe(group)} files, "
            f"{describe_lines(group)} lines</summary>\n\n{fence}diff\n"
        )
        closing = f"{fence}\n</details>\n\n"
        shown = []
        shown_length = len(opening) + len(closing)
        for file_diff in group:
            needed = length + shown_length + len(file_diff.text) + TRUNCATION_NOTE_RESERVE
            if needed > MAX_COMMENT_LENGTH:
                omitted += 1
                continue
            shown.append(file_diff.text)
            shown_length += len(file_diff.text)
        if shown:
            parts += [opening, *shown, closing]
            length += shown_length

    if omitted:
        parts.append(
            f"{omitted} changed files are not shown because the diff is too large "
            f"for a comment. {full_diff_link(run_url)}"
        )
    return "".join(parts)


def read_diffs(diff_dir):
    """Return the rendered file diffs of all test cases and the default values diff."""
    file_diffs = []
    default_values_diff = ""
    for test_case_dir in sorted(path for path in diff_dir.iterdir() if path.is_dir()):
        file_diffs += parse_diff((test_case_dir / "diff.txt").read_text(encoding="utf-8"))
        if not default_values_diff:
            default_values_diff = (test_case_dir / "default-values-diff.txt").read_text(
                encoding="utf-8"
            )
    file_diffs.sort(key=by_chart_and_test_case)
    return file_diffs, default_values_diff


def write_comments(diff_dir, output_dir, run_url):
    file_diffs, default_values_diff = read_diffs(diff_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    if not file_diffs and not default_values_diff:
        print("no changes, no comments to write")
        return

    comments = {}
    charts = sorted({file_diff.chart for file_diff in file_diffs})
    comments["summary"] = render_summary(file_diffs, charts, default_values_diff, run_url)
    if len(charts) <= MAX_CHART_COMMENTS:
        for chart, group in groupby(file_diffs, key=lambda file_diff: file_diff.chart):
            comments[f"chart-{chart}"] = render_chart_comment(chart, list(group), run_url)

    for name, body in comments.items():
        (output_dir / f"{name}.md").write_text(body, encoding="utf-8")
        print(f"wrote {name}.md ({len(body)} characters)")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--diff-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--run-url", required=True)
    args = parser.parse_args()
    write_comments(args.diff_dir, args.output_dir, args.run_url)


if __name__ == "__main__":
    main()
