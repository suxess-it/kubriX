#!/usr/bin/env python3
"""Exercise the actual gate shell with successful, failed and skipped dependencies."""
import itertools
import os
from pathlib import Path
import subprocess
import unittest
from types import SimpleNamespace
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
                env = dict(os.environ, TEST_REQUIRED='true', CHANGES_RESULT=results[0], BUILD_RESULT=results[1], CLUSTER_RESULT=results[2])
                run = subprocess.run(['bash', '-e', '-c', script], env=env, capture_output=True)
                self.assertEqual(run.returncode == 0, results == ('success',) * 3)

    def test_irrelevant_changes_need_no_cluster_run(self):
        gate = yaml.safe_load(WORKFLOW.read_text())['jobs']['cluster-test-gate']
        for required, changes in itertools.product(['false', 'true', ''], ['success', 'failure', 'skipped']):
            with self.subTest(required=required, changes=changes):
                env = dict(os.environ, TEST_REQUIRED=required, CHANGES_RESULT=changes,
                           BUILD_RESULT='skipped', CLUSTER_RESULT='skipped')
                run = subprocess.run(['bash', '-e', '-c', gate['steps'][0]['run']], env=env, capture_output=True)
                self.assertEqual(run.returncode == 0, required == 'false' and changes == 'success')

    def test_required_paths_match_original_trigger(self):
        workflow = yaml.load(WORKFLOW.read_text(), Loader=yaml.BaseLoader)
        filter_step = next(step for step in workflow['jobs']['changes']['steps'] if step.get('id') == 'filter')
        filters = yaml.safe_load(filter_step['with']['filters'])
        self.assertEqual(filters['clusterTestRequired'], workflow['on']['push']['paths'])

    def test_request_policy(self):
        expression = yaml.safe_load(WORKFLOW.read_text())['jobs']['changes']['steps'][2]['if']
        expression = expression.replace('&&', ' and ').replace('||', ' or ')
        expression = expression.replace('github.event.pull_request.labels.*.name', 'labels')
        for author, labels, action, added_label in itertools.product(
            ['renovate[bot]', 'human'], [[], ['run-cluster-tests']],
            ['opened', 'reopened', 'synchronize', 'labeled'],
            ['run-cluster-tests', 'unrelated'],
        ):
            with self.subTest(author=author, labels=labels, action=action, added_label=added_label):
                github = SimpleNamespace(repository='suxess-it/kubriX', event_name='pull_request', event=SimpleNamespace(
                    action=action, label=SimpleNamespace(name=added_label),
                    pull_request=SimpleNamespace(user=SimpleNamespace(login=author))))
                actual = eval('(' + expression + ')', {'__builtins__': {}}, {
                    'github': github, 'labels': labels, 'contains': lambda values, value: value in values})
                expected = (added_label == 'run-cluster-tests' if action == 'labeled' else
                            author == 'renovate[bot]' and 'run-cluster-tests' in labels)
                self.assertEqual(actual, expected)

    def test_prime_sync_request_policy(self):
        expression = yaml.safe_load(WORKFLOW.read_text())['jobs']['changes']['steps'][2]['if']
        expression = expression.replace('&&', ' and ').replace('||', ' or ')
        expression = expression.replace('github.event.pull_request.labels.*.name', 'labels')
        for repo, author, branch, labels, action in itertools.product(
            ['suxess-it/kubriX-prime', 'suxess-it/kubriX'],
            ['kubrix-ci-sync[bot]', 'human'], ['sync-upstream-pr-123', 'backport-pr-123'],
            [[], ['run-cluster-tests'], ['run-cluster-tests', 'upstream-sync'],
             ['run-cluster-tests', 'upstream-sync', 'automerge']],
            ['opened', 'reopened', 'synchronize', 'labeled'],
        ):
            with self.subTest(repo=repo, author=author, branch=branch, labels=labels, action=action):
                github = SimpleNamespace(repository=repo, event_name='pull_request', event=SimpleNamespace(
                    action=action, label=SimpleNamespace(name='unrelated'),
                    pull_request=SimpleNamespace(user=SimpleNamespace(login=author), head=SimpleNamespace(ref=branch))))
                actual = eval('(' + expression + ')', {'__builtins__': {}}, {
                    'github': github, 'labels': labels, 'contains': lambda values, value: value in values,
                    'startsWith': lambda value, prefix: value.startswith(prefix)})
                expected = (repo == 'suxess-it/kubriX-prime' and author == 'kubrix-ci-sync[bot]' and
                            branch == 'sync-upstream-pr-123' and action != 'labeled' and
                            all(label in labels for label in ['run-cluster-tests', 'upstream-sync', 'automerge']))
                self.assertEqual(actual, expected)

    def test_empty_target_matrix_cannot_satisfy_gate(self):
        workflow = yaml.safe_load(WORKFLOW.read_text())
        jobs = workflow['jobs']
        self.assertIn("needs.changes.outputs.targets != '[]'", jobs['create-cluster']['if'])
        # Unrelated labels must neither emit a skipped required check nor cancel an active test run.
        self.assertIn('github.event.label.name', jobs['cluster-test-gate']['name'])
        self.assertIn('github.run_id', workflow['concurrency']['group'])


if __name__ == '__main__':
    unittest.main()

