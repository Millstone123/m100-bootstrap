#!/bin/bash
# M100 Health Check Script - System status and diagnostics

set -e

echo "M100 Health Check"
echo "================="
echo ""

if [ ! -d ~/.m100/tools/bin ]; then
  echo "✗ M100 not installed"
  echo "  Run 'npm run setup' to install"
  exit 1
fi

echo "System Information:"
echo "  OS: $(uname -s)"
echo "  Architecture: $(uname -m)"
echo ""

echo "Tool Status:"
for tool in m100-scan m100-build m100-deps; do
  if [ -x ~/.m100/tools/bin/$tool ]; then
    echo "  ✓ $tool"
  else
    echo "  ✗ $tool (missing or not executable)"
  fi
done

echo ""
echo "Directory Structure:"
for dir in ~/.m100/tools/bin ~/.m100/tools/lib ~/.m100/tools/config ~/.m100/tools/reports ~/.m100/tools/cache; do
  if [ -d "$dir" ]; then
    echo "  ✓ $(basename $dir)"
  else
    echo "  ✗ $(basename $dir) (missing)"
  fi
done

echo ""
echo "✓ Health check complete"
