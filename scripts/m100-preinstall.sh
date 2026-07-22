#!/bin/bash
# M100 Pre-Install Hook - Runs before npm install
# Validates npm environment and checks system prerequisites

set -e

# Verify we're being run by npm (check for npm environment variables)
if [ -z "$npm_package_name" ] || [ -z "$npm_lifecycle_event" ]; then
  echo "Error: This script must be run via npm"
  echo "Use: npm run setup"
  exit 1
fi

if [ "$npm_lifecycle_event" != "preinstall" ]; then
  echo "Error: npm_lifecycle_event is $npm_lifecycle_event, expected preinstall"
  exit 1
fi

echo "M100 Pre-Install: Validating environment..."
echo "  npm_package_name: $npm_package_name"
echo "  npm_package_version: $npm_package_version"
echo "  npm_lifecycle_event: $npm_lifecycle_event"
echo ""

# Check system requirements
for cmd in bash wget curl; do
  if ! command -v $cmd &>/dev/null; then
    echo "✗ Required tool not found: $cmd"
    exit 1
  fi
done

echo "✓ System prerequisites validated"
echo ""
