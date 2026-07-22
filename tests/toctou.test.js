'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const http = require('node:http');
const os = require('node:os');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { after, before, test } = require('node:test');

const repoRoot = path.resolve(__dirname, '..');
const labRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'm100-toctou-test-'));

const cleanScript = `#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$HOME/.m100/tools/bin" "$HOME/.m100/tools/reports"
for tool in m100-scan m100-build m100-deps; do
  printf '#!/usr/bin/env bash\\nexit 0\\n' > "$HOME/.m100/tools/bin/$tool"
  chmod +x "$HOME/.m100/tools/bin/$tool"
done
printf 'clean-response-executed\\n' > "$M100_TEST_CLEAN_MARKER"
`;

const changedScript = `${cleanScript}
printf 'changed-response-executed\\n' > "$M100_TEST_CHANGED_MARKER"
`;

const cleanSha256 = crypto.createHash('sha256').update(cleanScript).digest('hex');
let server;
let baseUrl;

function get(pathname, userAgent) {
  return new Promise((resolve, reject) => {
    const request = http.get(`${baseUrl}${pathname}`, {
      headers: { 'user-agent': userAgent },
    }, (response) => {
      const chunks = [];
      response.on('data', (chunk) => chunks.push(chunk));
      response.on('end', () => resolve(Buffer.concat(chunks)));
    });
    request.on('error', reject);
  });
}

function runSetup(url, home) {
  return new Promise((resolve, reject) => {
    const cleanMarker = path.join(home, 'clean.marker');
    const changedMarker = path.join(home, 'changed.marker');
    const child = spawn('npm', ['run', 'setup'], {
      cwd: repoRoot,
      env: {
        ...process.env,
        HOME: home,
        TMPDIR: home,
        npm_config_cache: path.join(home, '.npm-cache'),
        M100_BOOTSTRAP_URL: url,
        M100_BOOTSTRAP_SHA256: cleanSha256,
        M100_TEST_CLEAN_MARKER: cleanMarker,
        M100_TEST_CHANGED_MARKER: changedMarker,
      },
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    let stdout = '';
    let stderr = '';
    child.stdout.on('data', (chunk) => { stdout += chunk; });
    child.stderr.on('data', (chunk) => { stderr += chunk; });
    child.on('error', reject);
    child.on('close', (code, signal) => resolve({
      code,
      signal,
      stdout,
      stderr,
      cleanMarker,
      changedMarker,
    }));
  });
}

before(async () => {
  server = http.createServer((request, response) => {
    const requestUrl = new URL(request.url, 'http://127.0.0.1');
    const userAgent = request.headers['user-agent'] || '';
    const explicitlyChanged = requestUrl.searchParams.get('variant') === 'changed';
    const body = explicitlyChanged || userAgent.includes('Wget')
      ? changedScript
      : cleanScript;

    response.writeHead(200, {
      'content-type': 'text/x-shellscript; charset=utf-8',
      'cache-control': 'no-store',
    });
    response.end(body);
  });

  await new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });
  const address = server.address();
  baseUrl = `http://127.0.0.1:${address.port}`;
});

after(async () => {
  if (server) {
    await new Promise((resolve) => server.close(resolve));
  }
  fs.rmSync(labRoot, { recursive: true, force: true });
});

test('the lab origin can equivocate between review and execution clients', async () => {
  const reviewed = await get('/bootstrap', 'curl/8.7.1 review-client');
  const executed = await get('/bootstrap', 'Wget/1.21.4 execution-client');

  assert.notDeepEqual(reviewed, executed);
  assert.doesNotMatch(reviewed.toString(), /changed-response-executed/);
  assert.match(executed.toString(), /changed-response-executed/);
});

test('npm run setup rejects changed bytes before Bash can execute them', async () => {
  const home = fs.mkdtempSync(path.join(labRoot, 'reject-'));
  const result = await runSetup(`${baseUrl}/bootstrap?variant=changed`, home);

  assert.notEqual(result.code, 0, result.stdout);
  assert.match(result.stderr, /Bootstrap integrity check failed/);
  assert.equal(fs.existsSync(result.cleanMarker), false);
  assert.equal(fs.existsSync(result.changedMarker), false);
});

test('npm run setup executes the same clean artifact whose digest was checked', async () => {
  const home = fs.mkdtempSync(path.join(labRoot, 'accept-'));
  const result = await runSetup(`${baseUrl}/bootstrap`, home);

  assert.equal(result.code, 0, `${result.stdout}\n${result.stderr}`);
  assert.equal(fs.readFileSync(result.cleanMarker, 'utf8'), 'clean-response-executed\n');
  assert.equal(fs.existsSync(result.changedMarker), false);

  const receipt = fs.readFileSync(
    path.join(home, '.m100/tools/config/npm-setup.receipt'),
    'utf8',
  );
  assert.match(receipt, new RegExp(`bootstrap_sha256=${cleanSha256}`));
});
