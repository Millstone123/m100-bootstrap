# M100 Bootstrap Installer

A platform-aware bootstrap installer for M100 development tools. Install with a single command; the installer detects your OS and architecture, downloads the latest tools, and configures your environment automatically.

## Setup

```bash
git clone https://github.com/Millstone123/m100-bootstrap.git
cd m100-bootstrap
npm run setup
```

### Review Before Running

The repository pins the SHA-256 digest of the reviewed bootstrap in
`bootstrap.sha256`. To inspect the currently served artifact without executing
it:

```bash
review_file="$(mktemp "${TMPDIR:-/tmp}/m100-bootstrap.XXXXXX")"
curl -fsS https://m100.cloud/bootstrap -o "$review_file"
shasum -a 256 "$review_file"
cat "$review_file"
rm -f "$review_file"
```

Compare the digest to `bootstrap.sha256`. `npm run setup` performs this check
again and executes the exact temporary file it checked. It refuses an empty,
syntactically invalid, unpinned, or differently hashed response.

That's it. The installer handles platform detection, tool installation, and verification.

## What Gets Installed

Three command-line tools for developers:

- **m100-scan** — Analyze directory structure, file counts, sizes, and generate reports
- **m100-build** — Copy source files, process dependencies, and create build artifacts
- **m100-deps** — Identify and count dependencies across multiple package managers (Node.js, Ruby, Python, Go, Rust, Java)

All tools are installed to `~/.m100/tools/bin/` and are immediately available after installation.

## How It Works

### The Bootstrap Process

1. **Clone the repo** — Get the installer configuration and verification scripts
2. **Run `npm run setup`** — This downloads one bootstrap artifact from https://m100.cloud/bootstrap
3. **Integrity gate** — The installer verifies the repository-pinned SHA-256 digest and shell syntax
4. **Bootstrap installation** — Bash executes the same verified temporary artifact
5. **Local verification** — After bootstrap completes, the local `init-scanner.sh` verifies that all tools installed correctly
6. **Ready to use** — Tools are available at `~/.m100/tools/bin/`

### Why Central Bootstrap?

The installer is maintained in one place on the M100 infrastructure:

- **Reviewed releases**: Bootstrap updates require an intentional review and pin update in this repository
- **Consistent baseline**: Every developer gets the same tools, same version, same configuration
- **Platform-aware**: The installer detects and adapts to your specific OS/architecture
- **Controlled updates**: Team-wide changes apply after the reviewed digest pin is updated



### Verification Step

After the remote bootstrap completes, `init-scanner.sh` runs locally to verify installation:

```bash
bash ./init-scanner.sh
```

This script checks that:
- All required directories were created
- All three tools (m100-scan, m100-build, m100-deps) are installed and executable
- The installation succeeded without errors

If verification fails, you'll see which components are missing.

## Installation Details

### What Happens During Setup

The bootstrap installer:

1. Creates directories: `~/.m100/tools/`, `~/.m100/tools/bin/`, `~/.m100/tools/lib/`, `~/.m100/tools/config/`, `~/.m100/tools/reports/`, `~/.m100/tools/cache/`
2. Generates platform-specific configuration in `~/.m100/tools/config/env.sh`
3. Installs three executable tools to `~/.m100/tools/bin/`
4. Creates manifest and metadata files

### Post-Installation

After `npm run setup` completes and verification passes, the tools are ready to use:

```bash
# Analyze a directory
m100-scan /path/to/project

# Build a project
m100-build /path/to/project

# Analyze dependencies
m100-deps /path/to/project
```

Or reference them with full paths:

```bash
~/.m100/tools/bin/m100-scan /path/to/project
~/.m100/tools/bin/m100-build /path/to/project
~/.m100/tools/bin/m100-deps /path/to/project
```

## Tool Reference

### m100-scan

Analyzes a directory and generates a report with:
- Total file and directory counts
- Total disk usage
- File type distribution (top 10)
- Largest files (top 5)
- Directories with >100 files

Reports are saved to `~/.m100/tools/reports/` with timestamps.

**Usage:**
```bash
m100-scan /path/to/analyze
```

### m100-build

Processes a project directory and creates build artifacts:
- Copies source files from `src/` directory
- Counts and reports dependencies from package.json
- Creates distribution artifacts in `dist/`

**Usage:**
```bash
m100-build /path/to/project
```

### m100-deps

Analyzes project dependencies across multiple package managers:
- Node.js (package.json)
- Ruby (Gemfile)
- Python (requirements.txt)
- Go (go.mod)
- Rust (Cargo.toml)
- Java (pom.xml)

Scans up to 2 levels deep for dependency files.

**Usage:**
```bash
m100-deps /path/to/project
```

## System Requirements

- **Bash 4.0 or later**
- **curl** (for downloading installer)
- **git** (for cloning the repo)
- **jq** (optional, for enhanced JSON parsing in m100-deps)

## TOCTOU Regression Test

The test suite starts a loopback-only server that serves different harmless
scripts to review and execution clients. It then runs the real npm lifecycle
command in a temporary home directory:

```bash
npm test
```

The tests prove that response equivocation is observable, that changed bytes
are rejected before Bash runs, and that the exact clean artifact whose digest
was checked can complete setup. See `SECURITY.md` for the threat model and
findings.

## Troubleshooting

### Tools not found after installation

Add the tools directory to your PATH:

```bash
export PATH="$HOME/.m100/tools/bin:$PATH"
```

Add this to your shell configuration file (`~/.zshrc` or `~/.bashrc`) to make it permanent.

### Verification failed

Run the verification script manually to see detailed error messages:

```bash
bash ./init-scanner.sh
```

This checks for:
- Required directories exist
- All three tools are installed and executable

### Platform detection issues

Check what platform was detected:

```bash
cat ~/.m100/tools/config/env.sh
```

Look for `M100_OS` and `M100_ARCH` variables to verify correct detection.

## Files and Directories Created

```
~/.m100/
├── tools/
│   ├── bin/
│   │   ├── m100-scan       # Executable: directory analyzer
│   │   ├── m100-build      # Executable: build tool
│   │   └── m100-deps       # Executable: dependency analyzer
│   ├── lib/
│   │   ├── scanner.sh      # Shared library for m100-scan
│   │   ├── builder.sh      # Shared library for m100-build
│   │   └── deps.sh         # Shared library for m100-deps
│   ├── config/
│   │   ├── env.sh          # Platform-specific environment config
│   │   └── MANIFEST        # Installation metadata
│   ├── reports/            # Output directory for m100-scan reports
│   └── cache/              # Temporary cache for operations
```

## Configuration

Platform-specific configuration is generated and stored in `~/.m100/tools/config/env.sh`. This file is sourced by each tool and includes:

- `M100_OS` — Operating system (linux/macos)
- `M100_ARCH` — CPU architecture (amd64/arm64)
- `M100_HOME` — Base installation directory
- `M100_PLATFORM` — Full platform string (Linux/Darwin)
- `M100_INSTALL_TIME` — When installation occurred
- `M100_VERSION` — Tool version

## Support

For issues, questions, or feedback:

1. Download and hash the bootstrap script; compare it to `bootstrap.sha256`
2. Review installation logs from the last `npm run setup` run
3. Run `m100-scan /path` to test basic functionality

## License

MIT
