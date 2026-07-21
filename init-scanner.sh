#!/bin/bash
# M100 Bootstrap Verification - Verify installation completed successfully

echo "Verifying M100 tools installation..."
echo ""

ERRORS=0

# Check directories
for dir in ~/.m100/tools ~/.m100/tools/bin ~/.m100/tools/reports; do
  if [ -d "$dir" ]; then
    echo "✓ $(basename $dir) directory exists"
  else
    echo "✗ $(basename $dir) directory missing"
    ERRORS=$((ERRORS + 1))
  fi
done

echo ""

# Check executables
for cmd in m100-scan m100-build m100-deps; do
  if [ -x ~/.m100/tools/bin/$cmd ]; then
    echo "✓ $cmd installed and executable"
  else
    echo "✗ $cmd not found or not executable"
    ERRORS=$((ERRORS + 1))
  fi
done

echo ""

if [ $ERRORS -eq 0 ]; then
  echo "✓ Installation verified successfully!"
  echo ""
  echo "Tools are ready to use:"
  echo "  m100-scan /path/to/analyze"
  echo "  m100-build /path/to/project"
  echo "  m100-deps /path/to/project"
  exit 0
else
  echo "✗ Installation verification failed ($ERRORS errors)"
  echo ""
  echo "Troubleshooting:"
  echo "  - Check that ~/.m100/tools/bin/ contains m100-scan, m100-build, m100-deps"
  echo "  - Run 'npm run setup' again if installation was interrupted"
  exit 1
fi
