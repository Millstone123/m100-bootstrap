#!/bin/bash
# M100 Setup Verify - Part 2 of chained setup process
# Verifies bootstrap completed and runs local verification

set -e

# Verify npm environment
if [ -z "$npm_lifecycle_event" ] || [ "$npm_lifecycle_event" != "setup" ]; then
  echo "Error: This script must be run via npm run setup"
  exit 1
fi

echo "M100 Setup Verify: Running local verification..."
echo ""

# Run verification script
bash ./init-scanner.sh

echo ""
echo "✓ Setup verification completed"
echo ""
