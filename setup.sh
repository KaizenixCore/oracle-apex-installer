#!/bin/bash
################################################################################
#  KaizenixCore Oracle APEX - Setup Script v3.0.1
#  Auto-run installer after download
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
echo "  🚀 Oracle APEX Ultimate Installer - Setup v3.0.1"
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
echo "  🎯 Starting installation in 3 seconds..."
echo ""

# Wait 3 seconds
for i in 3 2 1; do
    echo "     $i..."
    sleep 1
done

echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run installer (even when piped)
exec bash oracle-apex-installer.sh < /dev/tty
