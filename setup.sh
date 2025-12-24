#!/bin/bash
################################################################################
#  KaizenixCore Oracle APEX - One-Line Installer
#  Usage: curl -fsSL <URL>/setup.sh | bash
################################################################################

REPO_URL="https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main"
TARGET_DIR="$HOME/oracle-apex-complete"

echo "🚀 KaizenixCore Oracle APEX Installer v3.0.0"
echo "════════════════════════════════════════════"
echo ""

# Create directory
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Download scripts
echo "📥 Downloading installation files..."
curl -fsSL "$REPO_URL/install.sh" -o install.sh
curl -fsSL "$REPO_URL/dbeaver.sh" -o dbeaver.sh

# Make executable
chmod +x install.sh dbeaver.sh

echo "✅ Files downloaded successfully!"
echo ""
echo "🎯 Starting installation..."
echo ""

# Run installer
./install.sh
