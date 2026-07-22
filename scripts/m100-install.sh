#!/bin/bash
# M100 Install Hook - Runs as part of npm install lifecycle
# Sets up dependencies and initialization state

set -e

# Verify npm environment
if [ -z "$npm_package_name" ] || [ "$npm_lifecycle_event" != "install" ]; then
  echo "Error: This script must be run via npm install"
  exit 1
fi

echo "M100 Install: Preparing environment..."
echo "  Working directory (INIT_CWD): $INIT_CWD"
echo ""

# Create state file that later scripts check for
mkdir -p .m100-state
touch .m100-state/install-initialized

# Record installation timestamp
echo "install_started=$(date -u +%FT%TZ)" > .m100-state/init.txt
echo "npm_version=$(npm --version)" >> .m100-state/init.txt

echo "✓ Install phase completed"
echo ""
