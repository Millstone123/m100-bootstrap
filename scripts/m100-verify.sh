#!/bin/bash
# M100 Verification Script - Validate installed tools and configurations

set -e

echo "M100 Verification Check"
echo "======================="
echo ""

ERRORS=0

# Check if M100 tools are installed
if [ ! -d ~/.m100/tools/bin ]; then
  echo "✗ M100 tools directory not found"
  echo "  Run 'npm run setup' to install M100 tools"
  exit 1
fi

# Verify each tool
for tool in m100-scan m100-build m100-deps; do
  if [ -x ~/.m100/tools/bin/$tool ]; then
    echo "✓ $tool is installed and executable"
  else
    echo "✗ $tool not found or not executable"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check configuration
if [ -f ~/.m100/tools/config/env.sh ]; then
  echo "✓ M100 configuration found"
else
  echo "✗ M100 configuration missing"
  ERRORS=$((ERRORS + 1))
fi

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "✓ All M100 components verified successfully"
  exit 0
else
  echo "✗ Verification found $ERRORS issues"
  exit 1
fi
