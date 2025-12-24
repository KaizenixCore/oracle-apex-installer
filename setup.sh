#!/bin/bash
################################################################################
#  KaizenixCore Oracle APEX - Setup Script v3.0.0
#  Fixes: Interactive input with pipe, DBeaver support, Cross-platform
################################################################################

set -e

REPO_URL="https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main"
TARGET_DIR="$HOME/oracle-apex-complete"

echo ""
echo "  ██╗  ██╗ █████╗ ██╗███████╗███████╗███╗   ██╗██╗██╗  ██╗"
echo "  ██║ ██╔╝██╔══██╗██║╚══███╔╝██╔════╝████╗  ██║██║╚██╗██╔╝"
echo "  █████╔╝ ███████║██║  ███╔╝ █████╗  ██╔██╗ ██║██║ ╚███╔╝ "
echo "  ██╔═██╗ ██╔══██║██║ ███╔╝  ██╔══╝  ██║╚██╗██║██║ ██╔██╗ "
echo "  ██║  ██╗██║  ██║██║███████╗███████╗██║ ╚████║██║██╔╝ ██╗"
echo "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝"
echo ""
echo "  🚀 Oracle APEX Ultimate Installer - Setup v3.0.0"
echo "  ════════════════════════════════════════════════════════"
echo ""
echo "  ✅ Cross-Platform (Linux, macOS, Windows WSL)"
echo "  ✅ DBeaver Database Tool Support"
echo "  ✅ Modern GUI (YAD/Zenity)"
echo "  ✅ Multi-Language (English/Persian/German)"
echo ""
echo "  ════════════════════════════════════════════════════════"
echo ""

# Create directory
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

echo "  📥 Downloading installation files..."
echo ""

# Download main installer
if curl -fsSL "$REPO_URL/oracle-apex-installer.sh" -o oracle-apex-installer.sh 2>/dev/null; then
    echo "  ✅ oracle-apex-installer.sh downloaded"
else
    echo "  ❌ Failed to download oracle-apex-installer.sh"
    echo ""
    echo "  Please check:"
    echo "    1. Internet connection"
    echo "    2. GitHub repository: https://github.com/KaizenixCore/oracle-apex-installer"
    echo "    3. File exists: $REPO_URL/oracle-apex-installer.sh"
    echo ""
    exit 1
fi

# Make executable
chmod +x oracle-apex-installer.sh

echo ""
echo "  ✅ Setup completed!"
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if running interactively
if [ -t 0 ]; then
    # Interactive mode - run installer directly
    echo "  🎯 Starting installation..."
    echo ""
    exec bash oracle-apex-installer.sh
else
    # Pipe mode - show instructions
    echo "  📌 Files downloaded to: $TARGET_DIR"
    echo ""
    echo "  🎯 To start installation, run:"
    echo ""
    echo "     cd $TARGET_DIR && bash oracle-apex-installer.sh"
    echo ""
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  💡 Or use this one-liner:"
    echo ""
    echo "     bash $TARGET_DIR/oracle-apex-installer.sh"
    echo ""
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi
