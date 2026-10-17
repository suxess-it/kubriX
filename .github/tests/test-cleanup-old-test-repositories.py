import importlib.util
from datetime import datetime, timedelta, timezone
from pathlib import Path
import unittest
from unittest.mock import Mock

script = Path(__file__).resolve().parent / 'cleanup-old-test-repositories.py'
if not script.exists():
    script = Path(__file__).resolve().parents[1] / 'cleanup-old-test-repositories.py'
spec = importlib.util.spec_from_file_location('cleanup', script)
cleanup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cleanup)


class CleanupTests(unittest.TestCase):
    cutoff = datetime(2026, 10, 17, 6, tzinfo=timezone.utc)

    def repo(self, name='kubrix-a0123456789-apps', created=None, owner='kubriX-demo', repo_id=1):
        return {'id': repo_id, 'name': name, 'full_name': f'{owner}/{name}',
                'created_at': (created or self.cutoff - timedelta(seconds=1)).isoformat()}

    def test_exact_patterns(self):
        for name in ('kubrix-cluster-test-123-456', 'kubrix-bootstrap-test-123',
                     'kubrix-a0123456789-apps', 'kubrix-aabcdef0123-kubrixbot-app',
                     'kubrix-a0123456789-kubrixbot-vcluster',
                     'kubrix-a0123456789-kubrixbot-vm', 'kubrixcontrol-a0123456789-apps'):
            with self.subTest(name=name):
                self.assertTrue(cleanup.eligible(self.repo(name), self.cutoff))
        for name in ('kubrix-demo-prime', 'kubrix-demo-oss', 'production-apps',
                     'kubrix-a0123456789-apps-backup', 'kubrix-a123-apps',
                     'kubrix-cluster-test-123', 'kubrix-a012345678g-apps'):
            with self.subTest(name=name):
                self.assertFalse(cleanup.eligible(self.repo(name), self.cutoff))

    def test_age_and_owner_boundaries(self):
        self.assertFalse(cleanup.eligible(self.repo(created=self.cutoff), self.cutoff))
        self.assertFalse(cleanup.eligible(self.repo(created=self.cutoff + timedelta(hours=1)), self.cutoff))
        self.assertFalse(cleanup.eligible(self.repo(owner='suxess-it'), self.cutoff))

    def test_pagination_before_deletion(self):
        api = Mock()
        api.request.side_effect = [(200, [self.repo('production-apps')] * 100), (200, [self.repo()])]
        self.assertEqual(cleanup.collect_candidates(api, self.cutoff), [self.repo()])
        self.assertIn('page=2', api.request.call_args_list[1].args[1])
        self.assertTrue(all(c.args[0] == 'GET' for c in api.request.call_args_list))

    def test_recreated_or_young_repository_is_not_deleted(self):
        for current in (self.repo(repo_id=2), self.repo(created=self.cutoff)):
            api = Mock()
            api.request.return_value = (200, current)
            self.assertIn('skipped', cleanup.delete_candidate(api, self.repo(), self.cutoff))
            self.assertEqual(api.request.call_count, 1)

    def test_revalidated_delete(self):
        api = Mock()
        api.request.side_effect = [(200, self.repo()), (204, None)]
        self.assertEqual(cleanup.delete_candidate(api, self.repo(), self.cutoff), 'deleted')
        self.assertEqual(api.request.call_args.args, ('DELETE', '/repos/kubriX-demo/kubrix-a0123456789-apps'))

    def test_absent_and_failed_rechecks_do_not_delete(self):
        api = Mock()
        api.request.return_value = (404, None)
        self.assertEqual(cleanup.delete_candidate(api, self.repo(), self.cutoff), 'already absent')
        api.request.assert_called_once()
        api.request.reset_mock()
        api.request.side_effect = RuntimeError('HTTP 403: exhausted')
        with self.assertRaises(RuntimeError):
            cleanup.delete_candidate(api, self.repo(), self.cutoff)
        api.request.assert_called_once()


if __name__ == '__main__':
    unittest.main()
