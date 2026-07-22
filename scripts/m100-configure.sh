#!/bin/bash
# M100 Configuration Script - Manage M100 settings and environment

set -e

if [ ! -d ~/.m100/tools/config ]; then
  echo "Error: M100 not installed"
  echo "Run 'npm run setup' first"
  exit 1
fi

echo "M100 Configuration Management"
echo "============================="
echo ""

ACTION="${1:-status}"

case "$ACTION" in
  status)
    echo "M100 Configuration Status:"
    echo ""
    if [ -f ~/.m100/tools/config/env.sh ]; then
      echo "✓ Configuration file exists: ~/.m100/tools/config/env.sh"
      echo ""
      echo "Configuration variables:"
      grep "export M100" ~/.m100/tools/config/env.sh | sed 's/^/  /'
    else
      echo "✗ Configuration file not found"
      exit 1
    fi
    ;;
  paths)
    echo "M100 Installation Paths:"
    echo "  Home: $HOME/.m100/tools"
    echo "  Tools: $HOME/.m100/tools/bin"
    echo "  Config: $HOME/.m100/tools/config"
    echo "  Reports: $HOME/.m100/tools/reports"
    ;;
  *)
    echo "Usage: npm run configure [status|paths]"
    exit 1
    ;;
esac
