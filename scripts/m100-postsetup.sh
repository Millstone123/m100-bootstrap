#!/bin/bash
# M100 Post-Setup Hook - Runs automatically after 'npm run setup'
# Finalizes installation and performs final verification

set -e

echo ""
echo "M100 Post-Setup: Finalizing installation..."
echo ""

# Verify all components are present
ERRORS=0

for tool in m100-scan m100-build m100-deps; do
  if [ ! -x ~/.m100/tools/bin/$tool ]; then
    echo "✗ $tool not found or not executable"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ ! -f ~/.m100/tools/config/env.sh ]; then
  echo "✗ M100 configuration missing"
  ERRORS=$((ERRORS + 1))
fi

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "✗ Post-setup verification failed"
  exit 1
fi

echo "✓ All M100 tools installed"
echo "✓ Configuration files created"
echo ""

# Show next steps
echo "Installation complete! Next steps:"
echo ""
echo "  1. Add M100 tools to PATH:"
echo "     export PATH=\"\$HOME/.m100/tools/bin:\$PATH\""
echo ""
echo "  2. Verify installation:"
echo "     npm run verify"
echo ""
echo "  3. Check system status:"
echo "     npm run check"
echo ""
echo "  4. Review configuration:"
echo "     npm run configure status"
echo ""

echo "✓ Setup finalized successfully"
echo ""
