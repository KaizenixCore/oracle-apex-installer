#!/bin/bash
################################################################################
#  KaizenixCore Oracle APEX - One-Line Installer v3.0.0
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

if ! curl -fsSL "$REPO_URL/install.sh" -o install.sh; then
    echo "❌ Error: Could not download install.sh"
    exit 1
fi

if ! curl -fsSL "$REPO_URL/dbeaver.sh" -o dbeaver.sh; then
    echo "⚠️  Warning: Could not download dbeaver.sh (optional)"
fi

# Make executable
chmod +x install.sh
[ -f dbeaver.sh ] && chmod +x dbeaver.sh

echo "✅ Files downloaded successfully!"
echo ""

# Check if running in pipe (non-interactive)
if [ -t 0 ]; then
    # Interactive mode - run directly
    echo "🎯 Starting installation..."
    echo ""
    bash install.sh
else
    # Pipe mode - show instructions
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  ✅ Setup completed! Files are ready in:"
    echo "     $TARGET_DIR"
    echo ""
    echo "  🎯 To start installation, run:"
    echo ""
    echo "     cd $TARGET_DIR && bash install.sh"
    echo ""
    echo "  Or run this one-liner:"
    echo ""
    echo "     cd ~ && bash oracle-apex-complete/install.sh"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi
