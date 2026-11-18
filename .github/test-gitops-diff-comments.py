#!/usr/bin/env python3

import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT_PATH = Path(__file__).with_name("gitops-diff-comments.py")
SPEC = importlib.util.spec_from_file_location("gitops_diff_comments", SCRIPT_PATH)
gitops_diff_comments = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(gitops_diff_comments)

RUN_URL = "https://github.com/suxess-it/kubriX/actions/runs/1"
TIMESTAMP = "2026-11-18 20:13:10.761387489 +0000"
MISSING_TIMESTAMP = "1970-01-01 00:00:00.000000000 +0000"


def file_diff(chart, test_case, path, added=(), removed=(), status="modified"):
    target = f"out/target/{chart}/{test_case}/{path}"
    pr = f"out/pr/{chart}/{test_case}/{path}"
    old_timestamp = MISSING_TIMESTAMP if status == "added" else TIMESTAMP
    new_timestamp = MISSING_TIMESTAMP if status == "removed" else TIMESTAMP
    lines = [
        f"diff -U 4 -rN {target} {pr}",
        f"--- {target}\t{old_timestamp}",
        f"+++ {pr}\t{new_timestamp}",
        f"@@ -1,{len(removed)} +1,{len(added)} @@",
        " unchanged: line",
        *(f"-{line}" for line in removed),
        *(f"+{line}" for line in added),
    ]
    return "\n".join(lines) + "\n"


def write_test_case(diff_dir, test_case, chart_diffs=None, default_values_diff=""):
    # Like create-pr-comment-file.sh, write one file per chart and only keep non-empty diffs.
    directory = diff_dir / test_case
    directory.mkdir(parents=True)
    for chart, diff in (chart_diffs or {}).items():
        (directory / f"{chart}.diff").write_text(diff, encoding="utf-8")
    if default_values_diff:
        (directory / "default-values-diff.txt").write_text(
            default_values_diff, encoding="utf-8"
        )


def write_comments(diff_dir):
    output_dir = diff_dir.parent / "comments"
    gitops_diff_comments.write_comments(diff_dir, output_dir, RUN_URL)
    return {
        path.stem: path.read_text(encoding="utf-8")
        for path in sorted(output_dir.glob("*.md"))
    }


class GitOpsDiffCommentsTest(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.diff_dir = Path(self.temp_dir.name) / "comment-files"

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_parse_diff_classifies_files_and_counts_lines(self):
        diff = (
            file_diff("loki", "default-kind", "a.yaml", added=["x"], removed=["y", "z"])
            + file_diff("loki", "default-kind", "b.yaml", added=["--- x", "+++ y"], status="added")
            + file_diff("mimir", "default-kind", "c.yaml", removed=["x"], status="removed")
        )

        file_diffs = gitops_diff_comments.parse_diff(diff)

        self.assertEqual(
            [(d.chart, d.test_case, d.status, d.additions, d.deletions) for d in file_diffs],
            [
                ("loki", "default-kind", "modified", 1, 2),
                ("loki", "default-kind", "added", 2, 0),
                ("mimir", "default-kind", "removed", 0, 1),
            ],
        )
        self.assertEqual("".join(d.text for d in file_diffs), diff)

    def test_writes_summary_and_one_comment_per_chart(self):
        write_test_case(
            self.diff_dir,
            "default-kind",
            {
                "loki": file_diff("loki", "default-kind", "a.yaml", added=["x"]),
                "mimir": file_diff("mimir", "default-kind", "b.yaml", removed=["y"]),
            },
            default_values_diff="-old: value\n+new: value\n",
        )
        write_test_case(
            self.diff_dir,
            "default-aks-kind",
            {"loki": file_diff("loki", "default-aks-kind", "a.yaml", added=["x"])},
            default_values_diff="-old: value\n+new: value\n",
        )

        comments = write_comments(self.diff_dir)

        self.assertEqual(sorted(comments), ["chart-loki", "chart-mimir", "summary"])
        summary = comments["summary"]
        self.assertTrue(summary.startswith("<!-- gitops-diff:summary -->\n"))
        self.assertIn("| `loki` | default-aks-kind | 1 (0 added, 0 removed, 1 modified) | +1 / -0 |", summary)
        self.assertIn("| `mimir` | default-kind | 1 (0 added, 0 removed, 1 modified) | +0 / -1 |", summary)
        self.assertEqual(summary.count("+new: value"), 1)
        self.assertIn(RUN_URL, summary)

        loki = comments["chart-loki"]
        self.assertTrue(loki.startswith("<!-- gitops-diff:chart-loki -->\n"))
        self.assertIn("<summary>default-aks-kind:", loki)
        self.assertIn("<summary>default-kind:", loki)
        self.assertNotIn("mimir", loki)

    def test_chart_comment_stays_within_limit(self):
        big_lines = ["x" * 100] * 300
        diff = "".join(
            file_diff("loki", "default-kind", f"file-{index}.yaml", added=big_lines)
            for index in range(10)
        )
        write_test_case(self.diff_dir, "default-kind", {"loki": diff})

        comment = write_comments(self.diff_dir)["chart-loki"]

        self.assertLessEqual(len(comment), gitops_diff_comments.MAX_COMMENT_LENGTH)
        self.assertIn("file-0.yaml", comment)
        self.assertNotIn("file-9.yaml", comment)
        self.assertIn("files are not shown", comment)
        self.assertIn(RUN_URL, comment)
        self.assertIn("default-kind: 0 added, 0 removed, 10 modified files", comment)

    def test_too_many_charts_only_writes_summary(self):
        charts = [f"chart{index:02d}" for index in range(gitops_diff_comments.MAX_CHART_COMMENTS + 1)]
        chart_diffs = {chart: file_diff(chart, "default-kind", "a.yaml", added=["x"]) for chart in charts}
        write_test_case(self.diff_dir, "default-kind", chart_diffs)

        comments = write_comments(self.diff_dir)

        self.assertEqual(list(comments), ["summary"])
        self.assertIn("not posted as separate comments", comments["summary"])
        self.assertIn("`chart10`", comments["summary"])

    def test_no_changes_writes_summary_saying_so(self):
        write_test_case(self.diff_dir, "default-kind")

        comments = write_comments(self.diff_dir)

        self.assertEqual(list(comments), ["summary"])
        self.assertIn("No changes in the rendered manifests or the default values.", comments["summary"])
        self.assertNotIn(RUN_URL, comments["summary"])

    def test_missing_diff_dir_means_no_changes(self):
        comments = write_comments(self.diff_dir)

        self.assertEqual(list(comments), ["summary"])
        self.assertIn("No changes in the rendered manifests or the default values.", comments["summary"])

    def test_only_default_values_changed_writes_summary(self):
        write_test_case(self.diff_dir, "default-kind", default_values_diff="+new: value\n")

        comments = write_comments(self.diff_dir)

        self.assertEqual(list(comments), ["summary"])
        self.assertIn("No changes in the rendered manifests.", comments["summary"])
        self.assertIn("+new: value", comments["summary"])

    def test_too_large_default_values_diff_is_left_out(self):
        default_values_diff = ("+" + "x" * 100 + "\n") * 1000
        write_test_case(
            self.diff_dir,
            "default-kind",
            {"loki": file_diff("loki", "default-kind", "a.yaml", added=["x"])},
            default_values_diff=default_values_diff,
        )

        summary = write_comments(self.diff_dir)["summary"]

        self.assertLessEqual(len(summary), gitops_diff_comments.MAX_COMMENT_LENGTH)
        self.assertIn("too large for a comment", summary)
        self.assertNotIn("x" * 100, summary)

    def test_code_block_fence_is_longer_than_backticks_in_content(self):
        block = gitops_diff_comments.code_block("+```yaml\n+key: value\n+```\n")

        self.assertTrue(block.startswith("````diff\n"))
        self.assertTrue(block.endswith("\n````\n"))


if __name__ == "__main__":
    unittest.main()
