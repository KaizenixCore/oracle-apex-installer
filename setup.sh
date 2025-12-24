#!/bin/bash
################################################################################
#
#  ██╗  ██╗ █████╗ ██╗███████╗███████╗███╗   ██╗██╗██╗  ██╗
#  ██║ ██╔╝██╔══██╗██║╚══███╔╝██╔════╝████╗  ██║██║╚██╗██╔╝
#  █████╔╝ ███████║██║  ███╔╝ █████╗  ██╔██╗ ██║██║ ╚███╔╝
#  ██╔═██╗ ██╔══██║██║ ███╔╝  ██╔══╝  ██║╚██╗██║██║ ██╔██╗
#  ██║  ██╗██║  ██║██║███████╗███████╗██║ ╚████║██║██╔╝ ██╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
#
#  ╔═══════════════════════════════════════════════════════════════════════════╗
#  ║              ORACLE APEX ULTIMATE INSTALLER - SETUP v3.0.1                ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ║  License    : MIT                                                         ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  This script downloads and runs the Oracle APEX installer                 ║
#  ║  Features:                                                                ║
#  ║    ✅ Cross-Platform (Linux, macOS, Windows WSL)                          ║
#  ║    ✅ Auto-download from GitHub                                           ║
#  ║    ✅ Interactive execution                                               ║
#  ║    ✅ Error handling                                                      ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main"
TARGET_DIR="$HOME/oracle-apex-complete"
INSTALLER_FILE="oracle-apex-installer.sh"
VERSION="3.0.1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

# Print banner
print_banner() {
    clear
    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "  ██╗  ██╗ █████╗ ██╗███████╗███████╗███╗   ██╗██╗██╗  ██╗"
    echo "  ██║ ██╔╝██╔══██╗██║╚══███╔╝██╔════╝████╗  ██║██║╚██╗██╔╝"
    echo "  █████╔╝ ███████║██║  ███╔╝ █████╗  ██╔██╗ ██║██║ ╚███╔╝ "
    echo "  ██╔═██╗ ██╔══██║██║ ███╔╝  ██╔══╝  ██║╚██╗██║██║ ██╔██╗ "
    echo "  ██║  ██╗██║  ██║██║███████╗███████╗██║ ╚████║██║██╔╝ ██╗"
    echo "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${WHITE}${BOLD}  ╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}           ${MAGENTA}${BOLD}ORACLE APEX ULTIMATE INSTALLER${NC}                     ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}                    ${WHITE}Setup Script v${VERSION}${NC}                       ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} Cross-Platform  ${GREEN}✓${NC} DBeaver Support   ${GREEN}✓${NC} Modern GUI        ${WHITE}${BOLD}   ║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} Multi-Language  ${GREEN}✓${NC} Error-Free        ${GREEN}✓${NC} Auto-Start        ${WHITE}${BOLD}   ║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GRAY}Created by:${NC} ${CYAN}Peyman Rasouli${NC}                                    ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GRAY}Project:${NC}    ${MAGENTA}KaizenixCore${NC}                                       ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GRAY}GitHub:${NC}     ${BLUE}github.com/KaizenixCore/oracle-apex-installer${NC}       ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Logging functions
log_info() {
    echo -e "  ${BLUE}ℹ${NC}  $*"
}

log_success() {
    echo -e "  ${GREEN}✓${NC}  $*"
}

log_warning() {
    echo -e "  ${YELLOW}⚠${NC}  $*"
}

log_error() {
    echo -e "  ${RED}✗${NC}  $*"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_deps=()
    
    if ! command_exists curl; then
        missing_deps+=("curl")
    fi
    
    if ! command_exists chmod; then
        missing_deps+=("chmod")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_deps[*]}"
        echo ""
        echo "  Please install them first:"
        echo ""
        echo "  Ubuntu/Debian:  sudo apt-get install curl"
        echo "  Fedora/RHEL:    sudo dnf install curl"
        echo "  openSUSE:       sudo zypper install curl"
        echo "  macOS:          brew install curl"
        echo ""
        exit 1
    fi
    
    log_success "Prerequisites OK"
}

# Download installer
download_installer() {
    log_info "Downloading installer from GitHub..."
    echo ""
    
    mkdir -p "$TARGET_DIR"
    cd "$TARGET_DIR"
    
    local temp_file=$(mktemp)
    
    if curl -fsSL "$REPO_URL/$INSTALLER_FILE" -o "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$INSTALLER_FILE"
        chmod +x "$INSTALLER_FILE"
        log_success "Installer downloaded successfully"
        echo ""
        log_info "Location: ${TARGET_DIR}/${INSTALLER_FILE}"
        return 0
    else
        rm -f "$temp_file"
        log_error "Failed to download installer"
        echo ""
        echo "  Please check:"
        echo "    1. ${YELLOW}Internet connection${NC}"
        echo "    2. ${YELLOW}GitHub repository availability${NC}"
        echo "    3. ${YELLOW}URL: ${REPO_URL}/${INSTALLER_FILE}${NC}"
        echo ""
        echo "  ${CYAN}GitHub:${NC} https://github.com/KaizenixCore/oracle-apex-installer"
        echo ""
        exit 1
    fi
}

# Verify download
verify_download() {
    log_info "Verifying downloaded file..."
    
    if [ ! -f "$TARGET_DIR/$INSTALLER_FILE" ]; then
        log_error "Installer file not found!"
        exit 1
    fi
    
    if [ ! -x "$TARGET_DIR/$INSTALLER_FILE" ]; then
        log_warning "File not executable, fixing..."
        chmod +x "$TARGET_DIR/$INSTALLER_FILE"
    fi
    
    local file_size=$(stat -c%s "$TARGET_DIR/$INSTALLER_FILE" 2>/dev/null || stat -f%z "$TARGET_DIR/$INSTALLER_FILE" 2>/dev/null || echo 0)
    
    if [ "$file_size" -lt 1000 ]; then
        log_error "Downloaded file is too small (${file_size} bytes)"
        log_error "File may be corrupted or incomplete"
        exit 1
    fi
    
    log_success "File verified (${file_size} bytes)"
}

# Show next steps
show_next_steps() {
    echo ""
    echo -e "${GREEN}${BOLD}  ╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
    echo -e "${GREEN}${BOLD}  ║              ✅ SETUP COMPLETED SUCCESSFULLY! ✅                  ║${NC}"
    echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
    echo -e "${GREEN}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   📦 Files downloaded to:${NC}"
    echo -e "      ${CYAN}${TARGET_DIR}${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   🎯 Starting installation in 3 seconds...${NC}"
    echo ""
    
    for i in 3 2 1; do
        echo -e "     ${YELLOW}${BOLD}$i...${NC}"
        sleep 1
    done
    
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Run installer
run_installer() {
    log_info "Launching Oracle APEX Installer..."
    echo ""
    sleep 1
    
    cd "$TARGET_DIR"
    
    # Check if running in interactive terminal
    if [ -t 0 ]; then
        # Interactive mode - run directly
        exec bash "$INSTALLER_FILE"
    else
        # Non-interactive mode (piped) - try to attach to TTY
        if [ -e /dev/tty ]; then
            exec bash "$INSTALLER_FILE" < /dev/tty
        else
            # Fallback: run in background and show instructions
            bash "$INSTALLER_FILE" &
            local installer_pid=$!
            
            echo ""
            echo -e "${YELLOW}  ⚠️  Running in non-interactive mode${NC}"
            echo ""
            echo -e "  ${CYAN}Installer is running in background (PID: ${installer_pid})${NC}"
            echo ""
            echo -e "  ${WHITE}To interact with the installer, open a new terminal and run:${NC}"
            echo ""
            echo -e "     ${CYAN}cd ${TARGET_DIR} && bash ${INSTALLER_FILE}${NC}"
            echo ""
            
            wait $installer_pid
        fi
    fi
}

# Main function
main() {
    print_banner
    
    log_info "Starting setup process..."
    echo ""
    
    check_prerequisites
    download_installer
    verify_download
    show_next_steps
    run_installer
}

# Error handler
trap 'echo ""; log_error "Setup failed at line $LINENO"; exit 1' ERR

# Run main
main "$@"
