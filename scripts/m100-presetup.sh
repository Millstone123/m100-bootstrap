#!/bin/bash
# M100 Pre-Setup Hook - Runs automatically before 'npm run setup'
# Prepares the environment and checks prerequisites

set -e

echo "M100 Pre-Setup: Preparing installation environment..."
echo ""

# Check for required tools
if ! command -v wget &>/dev/null; then
  echo "✗ wget not found - required for bootstrap download"
  exit 1
fi

if ! command -v bash &>/dev/null; then
  echo "✗ bash not found - required for installation"
  exit 1
fi

echo "✓ wget available"
echo "✓ bash available"
echo ""

# Create backup of existing M100 config if it exists
if [ -d ~/.m100/tools/config ]; then
  BACKUP_DIR="$HOME/.m100/tools/config.backup.$(date +%s)"
  echo "Existing M100 configuration found. Creating backup..."
  cp -r ~/.m100/tools/config "$BACKUP_DIR"
  echo "✓ Backup created: $BACKUP_DIR"
  echo ""
fi

echo "✓ Pre-setup checks passed"
echo "Ready to download and install M100 tools..."
echo ""
