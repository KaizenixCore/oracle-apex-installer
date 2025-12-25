cat > install-web-gui.sh << 'EOF'
#!/bin/bash
################################################################################
#  Oracle APEX Complete Web Installer - Quick Setup
#  Created by: Peyman Rasouli - KaizenixCore
#  Version: 4.0
################################################################################

set -e

echo ""
echo "  ╔═══════════════════════════════════════════════════════════════════╗"
echo "  ║                                                                   ║"
echo "  ║      🚀 Oracle APEX Complete Web Installer Setup 🚀              ║"
echo "  ║                                                                   ║"
echo "  ╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "  ❌ Docker is not installed!"
    echo ""
    echo "  Please install Docker first:"
    echo "    • Ubuntu/Debian: sudo apt-get install docker.io docker-compose"
    echo "    • Fedora: sudo dnf install docker docker-compose"
    echo "    • openSUSE: sudo zypper install docker docker-compose"
    echo "    • macOS: Install Docker Desktop"
    echo "    • Windows: Install Docker Desktop"
    echo ""
    exit 1
fi

echo "  ✅ Docker is installed"
echo ""

# Download files
echo "  📥 Downloading installer files..."
echo ""

REPO_URL="https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main"

curl -fsSL "$REPO_URL/Dockerfile" -o Dockerfile
curl -fsSL "$REPO_URL/web-installer.py" -o web-installer.py
curl -fsSL "$REPO_URL/docker-compose.yml" -o docker-compose.yml

echo "  ✅ Files downloaded"
echo ""

# Build Docker image
echo "  🔨 Building Docker image..."
echo ""

docker build -t oracle-apex-web-installer:latest .

echo ""
echo "  ✅ Docker image built successfully"
echo ""

# Run container
echo "  🚀 Starting web installer..."
echo ""

docker-compose up -d

sleep 3

echo ""
echo "  ╔═══════════════════════════════════════════════════════════════════╗"
echo "  ║                                                                   ║"
echo "  ║              ✅ Web Installer is now running! ✅                 ║"
echo "  ║                                                                   ║"
echo "  ╚═══════════════════════════════════════════════════════════════════╝"
echo ""
echo "  🌐 Open your browser and go to:"
echo ""
echo "     http://localhost:8888"
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📋 Useful commands:"
echo ""
echo "     Stop:    docker-compose down"
echo "     Restart: docker-compose restart"
echo "     Logs:    docker-compose logs -f"
echo ""
EOF

chmod +x install-web-gui.sh
