#!/usr/bin/env python3
"""Exercise the actual gate shell with successful, failed and skipped dependencies."""
import itertools
import os
from pathlib import Path
import subprocess
import unittest
import yaml

WORKFLOW = Path(__file__).resolve().parents[1] / 'workflows/cluster-test.yml'


class ClusterTestGate(unittest.TestCase):
    def test_gate_requires_every_dependency_to_succeed(self):
        jobs = yaml.safe_load(WORKFLOW.read_text())['jobs']
        gate = jobs['cluster-test-gate']
        self.assertIn('always()', gate['if'])
        self.assertEqual(set(gate['needs']), {'changes', 'create-kubrix-installer-image', 'create-cluster'})
        script = gate['steps'][0]['run']
        for results in itertools.product(['success', 'failure', 'cancelled', 'skipped', ''], repeat=3):
            with self.subTest(results=results):
                env = dict(os.environ, CHANGES_RESULT=results[0], BUILD_RESULT=results[1], CLUSTER_RESULT=results[2])
                run = subprocess.run(['bash', '-e', '-c', script], env=env, capture_output=True)
                self.assertEqual(run.returncode == 0, results == ('success',) * 3)

    def test_empty_target_matrix_cannot_satisfy_gate(self):
        workflow = yaml.safe_load(WORKFLOW.read_text())
        jobs = workflow['jobs']
        self.assertIn("needs.changes.outputs.targets != '[]'", jobs['create-cluster']['if'])
        # Unrelated labels must neither emit a skipped required check nor cancel an active test run.
        self.assertIn('github.event.label.name', jobs['cluster-test-gate']['name'])
        self.assertIn('github.run_id', workflow['concurrency']['group'])


if __name__ == '__main__':
    unittest.main()
