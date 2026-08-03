import path from 'path';

export const githubAuthDir = path.join(__dirname, '../.auth');
export const ghAuthFile = path.join(githubAuthDir, 'github.json');
export const ghAuthLockFile = path.join(githubAuthDir, 'github.lock');
