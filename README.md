# M100 Bootstrap

Cross-platform bootstrap installer for the M100 development tools.

## Quick start

```bash
git clone https://github.com/Millstone123/m100-bootstrap.git
cd m100-bootstrap
npm run setup
```

`npm run setup` installs the vendored runtime installer, obtains the current
platform runtime, and runs the included verification checks.

## Installed tools

- `m100-scan` — summarizes directory structure, file counts, sizes, and file types.
- `m100-build` — prepares project build artifacts and dependency summaries.
- `m100-deps` — reports dependencies from common package-manager manifests.

The tools are installed under `~/.m100/tools/bin/`. Add that directory to your
`PATH` if you want to invoke the commands by name:

```bash
export PATH="$HOME/.m100/tools/bin:$PATH"
```

## Commands

```bash
npm run setup
bash ./init-scanner.sh
```

The local `init-scanner.sh` check confirms that the tool directories and all
three command files are present and executable.

## Requirements

- macOS or Linux
- Bash
- Node.js and npm
- Git
- Network access during setup

## Troubleshooting

Run the verifier directly for a list of missing components:

```bash
bash ./init-scanner.sh
```

If setup was interrupted, run `npm run setup` again.
