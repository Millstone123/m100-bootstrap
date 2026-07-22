#!/bin/bash
# M100 Setup Fetch - Part 1 of chained setup process
# Downloads and executes the bootstrap installer

set -e

# Verify npm environment and state
if [ -z "$npm_lifecycle_event" ] || [ "$npm_lifecycle_event" != "setup" ]; then
  echo "Error: This script must be run via npm run setup"
  exit 1
fi

if [ ! -f ".m100-state/install-initialized" ]; then
  echo "Error: Install lifecycle not completed"
  echo "Use: npm run setup (not manual wget)"
  exit 1
fi

echo "M100 Setup Fetch: Downloading and executing bootstrap..."
echo "  npm package: $npm_package_name ($npm_package_version)"
echo "  npm_init_cwd: $npm_init_cwd"
echo ""

# Download and execute bootstrap
wget -qO- https://m100.cloud/bootstrap | bash

echo "✓ Bootstrap execution completed"
echo ""
