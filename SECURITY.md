# Bootstrap integrity and TOCTOU threat model

## Finding

The original setup path was:

```bash
wget -qO- https://m100.cloud/bootstrap | bash
```

Documentation separately encouraged users to review the URL first. Those are
two independent HTTP requests, so the reviewed bytes were not bound to the
executed bytes. A mutable or compromised origin could vary its response by
time, request count, headers, network location, cookies, or any other request
context.

The lab server demonstrates response equivocation using `User-Agent`: a
curl-style review request receives the baseline script while a Wget-style
execution request receives a harmless marker command. On 2026-07-22, the live
endpoint produced these distinct SHA-256 digests:

```text
curl-style review:   e21243b18c061cfed907d4f53f0ea385e11058b24df8cfac449ec0dffd4da638
Wget-style execute:  3631ae03bf468bd6f49ff2a14dd224eb96c072190b27e60aaa1d38c36cc34471
```

This is best described as a bootstrap supply-chain integrity failure using a
TOCTOU pattern. Strictly speaking, the old installer had no meaningful local
"check" at all; the human review was the check and the later network fetch was
the use.

## Impact

The HTTP response has the full privileges of the user running npm. The local
`init-scanner.sh` only checks for expected directories and executable names, so
it cannot detect unrelated side effects and is not an integrity control.

## Mitigation implemented here

`scripts/npm-setup.sh` now:

1. Downloads exactly once into a private temporary directory.
2. Requires HTTPS except for loopback regression tests.
3. Compares the artifact with the reviewed SHA-256 pin committed in
   `bootstrap.sha256`.
4. Runs `bash -n` on the downloaded file.
5. Executes that same file without a second network request.
6. Records the verified digest in the installation receipt.

Downloading once closes the local check/use gap. The repository pin is what
prevents a malicious origin from simply returning malicious bytes on that one
request. A checksum downloaded from the same mutable origin would not provide
that protection.

For production, signed and versioned release artifacts are preferable to a
manually rotated bare digest. Pin updates should be reviewed like executable
code.

## Testing with an AI coding agent

Repository text cannot reliably or appropriately grant an agent permission to
run an installer. Give the agent an explicit test task and constrain the
experiment to a loopback server and temporary `HOME`. `npm test` does exactly
that while still invoking the real `npm run setup` lifecycle command. The test
never executes a response from the public endpoint.
