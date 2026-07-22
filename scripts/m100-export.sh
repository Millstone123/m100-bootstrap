#!/bin/bash
# M100 Export Script - Export configurations and metadata

set -e

if [ ! -d ~/.m100/tools/config ]; then
  echo "Error: M100 not installed"
  echo "Run 'npm run setup' first"
  exit 1
fi

echo "M100 Configuration Export"
echo "========================="
echo ""

EXPORT_DIR="${1:-.}"
EXPORT_FILE="$EXPORT_DIR/m100-export-$(date +%Y%m%d_%H%M%S).tar.gz"

if [ ! -w "$EXPORT_DIR" ]; then
  echo "Error: Cannot write to $EXPORT_DIR"
  exit 1
fi

echo "Exporting M100 configuration and metadata..."
echo ""

# Create temporary export directory
TEMP_EXPORT=$(mktemp -d)
mkdir -p "$TEMP_EXPORT/m100-config"

# Copy configuration files
cp -r ~/.m100/tools/config/* "$TEMP_EXPORT/m100-config/" 2>/dev/null || true
cp -r ~/.m100/tools/metadata "$TEMP_EXPORT/" 2>/dev/null || true

# Create tar archive
tar -czf "$EXPORT_FILE" -C "$TEMP_EXPORT" . 2>/dev/null

# Cleanup
rm -rf "$TEMP_EXPORT"

echo "✓ Configuration exported to: $EXPORT_FILE"
echo ""
echo "Export contents:"
echo "  - M100 configuration files"
echo "  - Installation metadata"
echo "  - Platform information"
