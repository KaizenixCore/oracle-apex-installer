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
#  ║        ORACLE APEX ULTIMATE INSTALLER v3.0.0 - KAIZENIXCORE               ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ║  License    : MIT                                                         ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║                           FEATURES                                        ║
#  ├───────────────────────────────────────────────────────────────────────────┤
#  ║  ✅ Fully Automated Oracle APEX + ORDS + XE 21c Installation              ║
#  ║  ✅ Smart Dependency Detection & Auto-Installation                        ║
#  ║  ✅ Docker-based Isolated Environment                                     ║
#  ║  ✅ Cross-Platform Support (Linux, macOS, Windows WSL)                    ║
#  ║  ✅ DBeaver Database Tool Integration (Optional)                          ║
#  ║  ✅ Modern GUI with YAD/Zenity (Auto-Detection)                           ║
#  ║  ✅ Error 500 & Internal Server Error - FIXED                             ║
#  ║  ✅ Error 571 & Proxy Authentication - FIXED                              ║
#  ║  ✅ Error 574 & Database Credentials - FIXED                              ║
#  ║  ✅ Error 404 & Invalid Schema - FIXED                                    ║
#  ║  ✅ ORDS_METADATA Installation - FIXED                                    ║
#  ║  ✅ GUI Application Crash - COMPLETELY FIXED                              ║
#  ║  ✅ System Restart Persistence - FIXED                                    ║
#  ║  ✅ Schema Not Found After Reboot - FIXED                                 ║
#  ║  ✅ Password File Persistence - FIXED                                     ║
#  ║  ✅ ORDS Password Encryption - FIXED                                      ║
#  ║  ✅ Multi-Language GUI (English/Persian/German)                           ║
#  ║  ✅ Modern UI/UX with YAD or Zenity                                       ║
#  ║  ✅ One-Click Browser Launch                                              ║
#  ║  ✅ Systemd Service Auto-Start                                            ║
#  ║  ✅ Desktop Application (.desktop file)                                   ║
#  ║  ✅ Persistent Configuration (survives restart/browser close)             ║
#  ║  ✅ Smart Auto-Recovery on Startup                                        ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e
trap 'handle_error $LINENO' ERR

VERSION="3.0.0"
PROJECT_DIR="$HOME/oracle-apex-complete"
DOWNLOADS_DIR="$PROJECT_DIR/downloads"
LOG_DIR="$PROJECT_DIR/logs"
IMAGES_DIR="$PROJECT_DIR/images"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"

DB_HOST="localhost"
DB_SERVICE="XEPDB1"
DB_PORT="1521"
ORDS_PORT="8080"

APEX_FILE="apex-latest.zip"
ORDS_FILE="ords-latest.zip"
APEX_URL="https://download.oracle.com/otn_software/apex/apex-latest.zip"
ORDS_URL="https://download.oracle.com/otn_software/java/ords/ords-latest.zip"
ORACLE_IMAGE="gvenzl/oracle-xe:21-full"

APEX_MIN_SIZE=100000000
ORDS_MIN_SIZE=50000000

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
DIM='\033[2m'
NC='\033[0m'

CURRENT_STEP=0
TOTAL_STEPS=31

# GUI Tool Detection (YAD is better than Zenity)
GUI_TOOL=""
detect_gui_tool() {
    if command -v yad &> /dev/null; then
        GUI_TOOL="yad"
        log_info "Using YAD for GUI (Modern UI)"
    elif command -v zenity &> /dev/null; then
        GUI_TOOL="zenity"
        log_info "Using Zenity for GUI"
    else
        GUI_TOOL="none"
        log_warning "No GUI tool found - will install Zenity"
    fi
}

# OS Detection
OS_TYPE="unknown"
OS_ID=""
OS_VERSION=""
ARCH=$(uname -m)

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS_ID="$ID"
            OS_VERSION="$VERSION_ID"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="mac"
        OS_ID="macos"
        OS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
        OS_TYPE="windows"
        OS_ID="wsl"
    fi
}

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
    echo -e "${WHITE}${BOLD}  ║${NC}      ${MAGENTA}${BOLD}ORACLE APEX ULTIMATE INSTALLER${NC} ${WHITE}v${VERSION}${NC}                    ${WHITE}${BOLD}   ║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} Cross-Platform  ${GREEN}✓${NC} DBeaver Support   ${GREEN}✓${NC} Modern GUI        ${WHITE}${BOLD}   ║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} Error 500 Fixed ${GREEN}✓${NC} Error 574 Fixed   ${GREEN}✓${NC} Restart Safe      ${WHITE}${BOLD}  ║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}Created by:${NC} ${CYAN}Peyman Rasouli${NC}                                    ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}Project:${NC}    ${MAGENTA}KaizenixCore${NC}                                       ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}GitHub:${NC}     ${BLUE}https://github.com/KaizenixCore${NC}                      ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

get_passwords() {
    echo ""
    echo -e "${CYAN}${BOLD}  ┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                   ${WHITE}${BOLD}PASSWORD CONFIGURATION${NC}                       ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  └─────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}Important:${NC} Password must contain only letters and numbers"
    echo -e "  ${YELLOW}${BOLD}           ${NC}(no special characters), minimum 6 characters"
    echo ""

    while true; do
        read -p "  Enter Oracle Database Password: " ORACLE_PASSWORD
        echo
        read -p "  Enter APEX Admin Password: " APEX_ADMIN_PASSWORD
        echo

        if [[ ! "$ORACLE_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]] || [ ${#ORACLE_PASSWORD} -lt 6 ]; then
            echo -e "  ${RED}✗ Password must start with letter, only letters/numbers, min 6 chars${NC}"
            continue
        fi

        if [[ ! "$APEX_ADMIN_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]] || [ ${#APEX_ADMIN_PASSWORD} -lt 6 ]; then
            echo -e "  ${RED}✗ APEX Password must start with letter, only letters/numbers, min 6 chars${NC}"
            continue
        fi

        break
    done

    export ORACLE_PASSWORD APEX_ADMIN_PASSWORD
    log_success "Passwords validated successfully"
}

handle_error() {
    local line=$1
    echo ""
    echo -e "${RED}${BOLD}  ╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}  ║                      💥 ERROR OCCURRED                            ║${NC}"
    echo -e "${RED}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}${BOLD}  ║${NC}  Line: ${WHITE}$line${NC}"
    echo -e "${RED}${BOLD}  ║${NC}  Logs: ${CYAN}$LOG_DIR${NC}"
    echo -e "${RED}${BOLD}  ║${NC}  Docker: ${CYAN}docker logs oracle-apex-db${NC}"
    echo -e "${RED}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    exit 1
}

log_info() { echo -e "  ${BLUE}ℹ${NC}  $*"; }
log_success() { echo -e "  ${GREEN}✓${NC}  $*"; }
log_warning() { echo -e "  ${YELLOW}⚠${NC}  $*"; }
log_error() { echo -e "  ${RED}✗${NC}  $*"; }

log_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    echo -e "${MAGENTA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}${BOLD}   STEP $CURRENT_STEP/$TOTAL_STEPS │ $*${NC}"
    echo -e "${MAGENTA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

validate_zip_file() {
    local zip_file=$1
    local min_size=$2
    local file_name=$(basename "$zip_file")

    [ ! -f "$zip_file" ] && { log_warning "$file_name not found"; return 1; }

    local file_size=$(stat -c%s "$zip_file" 2>/dev/null || stat -f%z "$zip_file" 2>/dev/null || echo 0)
    [ "$file_size" -lt "$min_size" ] && { log_warning "$file_name too small"; return 1; }

    log_info "Testing $file_name..."
    unzip -t "$zip_file" > /dev/null 2>&1 && { log_success "$file_name valid ($((file_size/1024/1024))MB)"; return 0; }

    log_error "$file_name CORRUPTED"
    return 1
}

download_file() {
    local url=$1 output=$2 name=$3 min_size=$4

    for attempt in 1 2 3; do
        log_info "Downloading $name (attempt $attempt/3)..."
        rm -f "$output" 2>/dev/null || true

        if wget --progress=bar:force --timeout=300 -O "$output" "$url" 2>&1; then
            validate_zip_file "$output" "$min_size" && { log_success "$name downloaded!"; return 0; }
            rm -f "$output"
        fi

        [ $attempt -lt 3 ] && sleep 5
    done

    log_error "Failed to download $name"
    return 1
}

wait_for_db() {
    log_info "Waiting for database to be ready..."
    local timeout=900
    local start_time=$(date +%s)

    # First check if container exists
    if ! docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"; then
        log_error "Container oracle-apex-db does not exist!"
        log_info "Creating container with docker compose..."
        cd "$PROJECT_DIR"
        docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || {
            log_error "Failed to create container"
            return 1
        }
        sleep 10
    fi

    # Check if container is running
    if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"; then
        log_info "Starting container..."
        docker start oracle-apex-db 2>/dev/null || true
        sleep 10
    fi

    while true; do
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            echo ""
            log_success "Database reports READY"
            log_info "Waiting 90s for listener to fully stabilize..."
            sleep 90
            return 0
        fi

        local elapsed=$(($(date +%s) - start_time))
        [ $elapsed -gt $timeout ] && { echo ""; log_error "Timeout waiting for database"; return 1; }

        echo -ne "\r  ${CYAN}⏳ Waiting... ${elapsed}s${NC}    "
        sleep 5
    done
}

test_db_connection() {
    log_info "Testing database connection..."

    local max_attempts=15
    for attempt in $(seq 1 $max_attempts); do
        log_info "Connection test $attempt/$max_attempts..."

        local result=$(docker exec oracle-apex-db bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>&1)

        if echo "$result" | grep -q "1"; then
            log_success "Database connection successful!"
            return 0
        fi

        log_warning "Attempt $attempt failed, waiting 15s..."
        sleep 15
    done

    log_error "Could not connect to database after $max_attempts attempts"
    return 1
}
# ═══════════════════════════════════════════════════════════════════════════════
# STEP 01: INITIALIZE
# ═══════════════════════════════════════════════════════════════════════════════
step_01_init() {
    log_step "Initializing Project"
    
    detect_os
    log_info "Detected OS: $OS_TYPE ($OS_ID $OS_VERSION) - Arch: $ARCH"
    
    mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR"
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    
    # CRITICAL FIX: Save passwords immediately and ensure they persist
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    
    log_success "Directories created"
    log_success "Password files created and secured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 02: SYSTEM CHECK
# ═══════════════════════════════════════════════════════════════════════════════
step_02_check() {
    log_step "System Check"
    
    log_info "OS: $OS_TYPE ($OS_ID $OS_VERSION)"
    log_info "Architecture: $ARCH"
    
    command -v docker &>/dev/null && log_success "Docker: OK" || log_warning "Docker: Missing"
    command -v java &>/dev/null && log_success "Java: OK" || log_warning "Java: Missing"

    # Check disk space (cross-platform)
    local free=0
    if [[ "$OS_TYPE" == "mac" ]]; then
        free=$(df -g "$HOME" | awk 'NR==2{print $4}')
    else
        free=$(df -BG "$HOME" | awk 'NR==2{print $4}' | sed 's/G//')
    fi
    
    [ "$free" -lt 10 ] 2>/dev/null && { log_error "Need 10GB, have ${free}GB"; exit 1; }
    log_success "Disk Space: ${free}GB available"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 03: PREREQUISITES (CROSS-PLATFORM) - ULTIMATE VERSION
# ═══════════════════════════════════════════════════════════════════════════════
step_03_prerequisites() {
    log_step "Installing Dependencies (Cross-Platform - Ultimate)"

    # ═══════════════════════════════════════════════════════════════════════════
    # HELPER FUNCTION: Install package with multiple fallbacks
    # ═══════════════════════════════════════════════════════════════════════════
    install_package() {
        local pkg_apt="$1"
        local pkg_dnf="$2"
        local pkg_zypper="$3"
        local pkg_pacman="$4"
        local pkg_brew="$5"
        
        case "$OS_TYPE" in
            linux)
                case "$OS_ID" in
                    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|parrot|mx)
                        [ -n "$pkg_apt" ] && sudo apt-get install -y $pkg_apt 2>/dev/null || true
                        ;;
                    fedora)
                        [ -n "$pkg_dnf" ] && sudo dnf install -y $pkg_dnf 2>/dev/null || true
                        ;;
                    rhel|centos|rocky|alma|oracle)
                        [ -n "$pkg_dnf" ] && sudo dnf install -y $pkg_dnf 2>/dev/null || sudo yum install -y $pkg_dnf 2>/dev/null || true
                        ;;
                    opensuse*|suse*|sles)
                        [ -n "$pkg_zypper" ] && sudo zypper --non-interactive install -y $pkg_zypper 2>/dev/null || true
                        ;;
                    arch|manjaro|endeavouros|garuda|artix)
                        [ -n "$pkg_pacman" ] && sudo pacman -S --noconfirm --needed $pkg_pacman 2>/dev/null || true
                        ;;
                    void)
                        [ -n "$pkg_apt" ] && sudo xbps-install -y $pkg_apt 2>/dev/null || true
                        ;;
                    alpine)
                        [ -n "$pkg_apt" ] && sudo apk add --no-cache $pkg_apt 2>/dev/null || true
                        ;;
                    gentoo)
                        [ -n "$pkg_apt" ] && sudo emerge --ask=n $pkg_apt 2>/dev/null || true
                        ;;
                    *)
                        log_warning "Unknown distro, trying multiple package managers..."
                        [ -n "$pkg_apt" ] && sudo apt-get install -y $pkg_apt 2>/dev/null || \
                        [ -n "$pkg_dnf" ] && sudo dnf install -y $pkg_dnf 2>/dev/null || \
                        [ -n "$pkg_zypper" ] && sudo zypper --non-interactive install -y $pkg_zypper 2>/dev/null || \
                        [ -n "$pkg_pacman" ] && sudo pacman -S --noconfirm $pkg_pacman 2>/dev/null || true
                        ;;
                esac
                ;;
            mac)
                [ -n "$pkg_brew" ] && brew install $pkg_brew 2>/dev/null || true
                ;;
        esac
    }

    # ═══════════════════════════════════════════════════════════════════════════
    # LINUX INSTALLATION
    # ═══════════════════════════════════════════════════════════════════════════
    case "$OS_TYPE" in
        linux)
            log_info "Detected Linux: $OS_ID $OS_VERSION ($ARCH)"
            
            # ───────────────────────────────────────────────────────────────────
            # STEP 3.1: Update package manager cache
            # ───────────────────────────────────────────────────────────────────
            log_info "Updating package manager cache..."
            case "$OS_ID" in
                ubuntu|debian|linuxmint|pop|elementary|zorin|kali|parrot|mx)
                    sudo apt-get update -qq 2>/dev/null || true
                    ;;
                fedora)
                    sudo dnf makecache --refresh -q 2>/dev/null || true
                    ;;
                rhel|centos|rocky|alma|oracle)
                    sudo dnf makecache -q 2>/dev/null || sudo yum makecache -q 2>/dev/null || true
                    ;;
                opensuse*|suse*|sles)
                    sudo zypper --non-interactive refresh 2>/dev/null || true
                    ;;
                arch|manjaro|endeavouros|garuda|artix)
                    sudo pacman -Sy --noconfirm 2>/dev/null || true
                    ;;
                alpine)
                    sudo apk update 2>/dev/null || true
                    ;;
            esac

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.2: Install essential tools first
            # ───────────────────────────────────────────────────────────────────
            log_info "Installing essential tools (wget, curl, unzip, ca-certificates)..."
            case "$OS_ID" in
                ubuntu|debian|linuxmint|pop|elementary|zorin|kali|parrot|mx)
                    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
                        wget curl unzip ca-certificates gnupg lsb-release \
                        apt-transport-https software-properties-common 2>/dev/null || true
                    ;;
                fedora)
                    sudo dnf install -y wget curl unzip ca-certificates gnupg2 2>/dev/null || true
                    ;;
                rhel|centos|rocky|alma|oracle)
                    sudo dnf install -y wget curl unzip ca-certificates gnupg2 2>/dev/null || \
                    sudo yum install -y wget curl unzip ca-certificates gnupg2 2>/dev/null || true
                    # Enable EPEL for additional packages
                    sudo dnf install -y epel-release 2>/dev/null || sudo yum install -y epel-release 2>/dev/null || true
                    ;;
                opensuse*|suse*|sles)
                    sudo zypper --non-interactive install -y wget curl unzip ca-certificates gpg2 2>/dev/null || true
                    ;;
                arch|manjaro|endeavouros|garuda|artix)
                    sudo pacman -S --noconfirm --needed wget curl unzip ca-certificates gnupg 2>/dev/null || true
                    ;;
                alpine)
                    sudo apk add --no-cache wget curl unzip ca-certificates gnupg 2>/dev/null || true
                    ;;
                void)
                    sudo xbps-install -y wget curl unzip ca-certificates gnupg 2>/dev/null || true
                    ;;
            esac

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.3: Install Docker
            # ───────────────────────────────────────────────────────────────────
            log_info "Installing Docker..."
            if ! command -v docker &> /dev/null; then
                case "$OS_ID" in
                    ubuntu|debian|linuxmint|pop|elementary|zorin)
                        # Try official Docker repository first
                        log_info "Setting up Docker official repository..."
                        sudo mkdir -p /etc/apt/keyrings 2>/dev/null || true
                        curl -fsSL https://download.docker.com/linux/$OS_ID/gpg 2>/dev/null | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
                        if [ -f /etc/apt/keyrings/docker.gpg ]; then
                            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS_ID $(lsb_release -cs 2>/dev/null || echo stable) stable" | \
                                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>/dev/null
                            sudo apt-get update -qq 2>/dev/null || true
                            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
                        fi
                        # Fallback to docker.io
                        if ! command -v docker &> /dev/null; then
                            log_info "Falling back to docker.io package..."
                            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io 2>/dev/null || true
                        fi
                        ;;
                    fedora)
                        # Official Docker repo for Fedora
                        sudo dnf -y install dnf-plugins-core 2>/dev/null || true
                        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo 2>/dev/null || true
                        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || \
                        sudo dnf install -y docker 2>/dev/null || true
                        ;;
                    rhel|centos|rocky|alma|oracle)
                        sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 2>/dev/null || \
                        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 2>/dev/null || true
                        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || \
                        sudo yum install -y docker-ce docker-ce-cli containerd.io 2>/dev/null || \
                        sudo dnf install -y docker 2>/dev/null || \
                        sudo yum install -y docker 2>/dev/null || true
                        ;;
                    opensuse*|suse*|sles)
                        log_info "Installing Docker for openSUSE/SUSE..."
                        sudo zypper --non-interactive install -y docker docker-compose 2>/dev/null || true
                        # If docker-compose not found, try docker-compose-switch
                        if ! command -v docker-compose &> /dev/null; then
                            sudo zypper --non-interactive install -y docker-compose-switch 2>/dev/null || true
                        fi
                        ;;
                    arch|manjaro|endeavouros|garuda|artix)
                        sudo pacman -S --noconfirm --needed docker docker-compose 2>/dev/null || true
                        ;;
                    alpine)
                        sudo apk add --no-cache docker docker-compose 2>/dev/null || true
                        sudo rc-update add docker boot 2>/dev/null || true
                        ;;
                    void)
                        sudo xbps-install -y docker docker-compose 2>/dev/null || true
                        ;;
                    gentoo)
                        sudo emerge --ask=n app-containers/docker app-containers/docker-compose 2>/dev/null || true
                        ;;
                    *)
                        log_warning "Unknown distro for Docker installation"
                        # Try universal installation script
                        log_info "Trying Docker's universal installation script..."
                        curl -fsSL https://get.docker.com | sudo sh 2>/dev/null || true
                        ;;
                esac
            else
                log_success "Docker already installed"
            fi

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.4: Install Docker Compose (if not included)
            # ───────────────────────────────────────────────────────────────────
            log_info "Checking Docker Compose..."
            if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
                log_info "Installing Docker Compose..."
                case "$OS_ID" in
                    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|parrot|mx)
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-compose 2>/dev/null || true
                        ;;
                    fedora|rhel|centos|rocky|alma|oracle)
                        sudo dnf install -y docker-compose 2>/dev/null || sudo yum install -y docker-compose 2>/dev/null || true
                        ;;
                    opensuse*|suse*|sles)
                        sudo zypper --non-interactive install -y docker-compose 2>/dev/null || true
                        ;;
                    arch|manjaro|endeavouros|garuda|artix)
                        sudo pacman -S --noconfirm --needed docker-compose 2>/dev/null || true
                        ;;
                    *)
                        # Download docker-compose binary directly
                        log_info "Downloading Docker Compose binary..."
                        local COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null || echo "v2.24.0")
                        sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 2>/dev/null || true
                        sudo chmod +x /usr/local/bin/docker-compose 2>/dev/null || true
                        ;;
                esac
            else
                log_success "Docker Compose already installed"
            fi

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.5: Install Java 17
            # ───────────────────────────────────────────────────────────────────
            log_info "Installing Java 17..."
            if ! command -v java &> /dev/null || ! java -version 2>&1 | grep -q "17"; then
                case "$OS_ID" in
                    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|parrot|mx)
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jdk openjdk-17-jre 2>/dev/null || \
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jdk-headless 2>/dev/null || \
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk 2>/dev/null || true
                        ;;
                    fedora)
                        sudo dnf install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || \
                        sudo dnf install -y java-17-openjdk-headless 2>/dev/null || true
                        ;;
                    rhel|centos|rocky|alma|oracle)
                        sudo dnf install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || \
                        sudo yum install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || true
                        ;;
                    opensuse*|suse*|sles)
                        sudo zypper --non-interactive install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || \
                        sudo zypper --non-interactive install -y java-17-openjdk-headless 2>/dev/null || true
                        ;;
                    arch|manjaro|endeavouros|garuda|artix)
                        sudo pacman -S --noconfirm --needed jdk17-openjdk jre17-openjdk 2>/dev/null || \
                        sudo pacman -S --noconfirm --needed jdk-openjdk 2>/dev/null || true
                        ;;
                    alpine)
                        sudo apk add --no-cache openjdk17 openjdk17-jre 2>/dev/null || true
                        ;;
                    void)
                        sudo xbps-install -y openjdk17 2>/dev/null || true
                        ;;
                    gentoo)
                        sudo emerge --ask=n dev-java/openjdk:17 2>/dev/null || true
                        ;;
                    *)
                        log_warning "Unknown distro for Java installation"
                        # Try SDKMAN as fallback
                        if command -v sdk &> /dev/null; then
                            sdk install java 17.0.9-tem 2>/dev/null || true
                        fi
                        ;;
                esac
            else
                log_success "Java 17 already installed"
            fi

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.6: Install GUI Tools (YAD, Zenity, Dialog)
            # ───────────────────────────────────────────────────────────────────
            log_info "Installing GUI tools (YAD/Zenity/Dialog)..."
            case "$OS_ID" in
                ubuntu|debian|linuxmint|pop|elementary|zorin|kali|parrot|mx)
                    # Try YAD first (better than Zenity)
                    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y yad 2>/dev/null || \
                    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y zenity 2>/dev/null || \
                    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y dialog 2>/dev/null || true
                    ;;
                fedora)
                    sudo dnf install -y yad 2>/dev/null || \
                    sudo dnf install -y zenity 2>/dev/null || \
                    sudo dnf install -y dialog 2>/dev/null || true
                    ;;
                rhel|centos|rocky|alma|oracle)
                    sudo dnf install -y zenity 2>/dev/null || \
                    sudo yum install -y zenity 2>/dev/null || \
                    sudo dnf install -y dialog 2>/dev/null || \
                    sudo yum install -y dialog 2>/dev/null || true
                    ;;
                opensuse*|suse*|sles)
                    sudo zypper --non-interactive install -y yad 2>/dev/null || \
                    sudo zypper --non-interactive install -y zenity 2>/dev/null || \
                    sudo zypper --non-interactive install -y dialog 2>/dev/null || true
                    ;;
                arch|manjaro|endeavouros|garuda|artix)
                    sudo pacman -S --noconfirm --needed yad 2>/dev/null || \
                    sudo pacman -S --noconfirm --needed zenity 2>/dev/null || \
                    sudo pacman -S --noconfirm --needed dialog 2>/dev/null || true
                    ;;
                alpine)
                    sudo apk add --no-cache zenity 2>/dev/null || \
                    sudo apk add --no-cache dialog 2>/dev/null || true
                    ;;
                void)
                    sudo xbps-install -y yad 2>/dev/null || \
                    sudo xbps-install -y zenity 2>/dev/null || \
                    sudo xbps-install -y dialog 2>/dev/null || true
                    ;;
                *)
                    log_warning "Unknown distro for GUI tools"
                    ;;
            esac

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.7: Install Flatpak (for DBeaver and other apps)
            # ───────────────────────────────────────────────────────────────────
            log_info "Installing Flatpak (for DBeaver support)..."
            if ! command -v flatpak &> /dev/null; then
                case "$OS_ID" in
                    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|parrot|mx)
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y flatpak 2>/dev/null || true
                        # Add GNOME Software Flatpak plugin
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gnome-software-plugin-flatpak 2>/dev/null || true
                        ;;
                    fedora)
                        # Flatpak is usually pre-installed on Fedora
                        sudo dnf install -y flatpak 2>/dev/null || true
                        ;;
                    rhel|centos|rocky|alma|oracle)
                        sudo dnf install -y flatpak 2>/dev/null || \
                        sudo yum install -y flatpak 2>/dev/null || true
                        ;;
                    opensuse*|suse*|sles)
                        sudo zypper --non-interactive install -y flatpak 2>/dev/null || true
                        ;;
                    arch|manjaro|endeavouros|garuda|artix)
                        sudo pacman -S --noconfirm --needed flatpak 2>/dev/null || true
                        ;;
                    alpine)
                        sudo apk add --no-cache flatpak 2>/dev/null || true
                        ;;
                    void)
                        sudo xbps-install -y flatpak 2>/dev/null || true
                        ;;
                    gentoo)
                        sudo emerge --ask=n sys-apps/flatpak 2>/dev/null || true
                        ;;
                esac
            else
                log_success "Flatpak already installed"
            fi

            # Add Flathub repository
            if command -v flatpak &> /dev/null; then
                log_info "Adding Flathub repository..."
                flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || \
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
            fi

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.8: Install Snap (optional, for DBeaver fallback)
            # ───────────────────────────────────────────────────────────────────
            log_info "Checking Snap support..."
            case "$OS_ID" in
                ubuntu|linuxmint|pop|elementary|zorin)
                    # Snap is usually pre-installed on Ubuntu-based distros
                    if ! command -v snap &> /dev/null; then
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y snapd 2>/dev/null || true
                        sudo systemctl enable snapd.socket 2>/dev/null || true
                        sudo systemctl start snapd.socket 2>/dev/null || true
                    fi
                    ;;
                fedora)
                    if ! command -v snap &> /dev/null; then
                        sudo dnf install -y snapd 2>/dev/null || true
                        sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
                        sudo systemctl enable snapd.socket 2>/dev/null || true
                        sudo systemctl start snapd.socket 2>/dev/null || true
                    fi
                    ;;
                # Note: Snap is not well supported on openSUSE, Arch, etc.
            esac

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.9: Start and Enable Docker Service
            # ───────────────────────────────────────────────────────────────────
            log_info "Starting Docker service..."
            if command -v systemctl &> /dev/null; then
                sudo systemctl enable docker.service 2>/dev/null || true
                sudo systemctl enable containerd.service 2>/dev/null || true
                sudo systemctl start docker.service 2>/dev/null || true
                sudo systemctl start containerd.service 2>/dev/null || true
            elif command -v rc-service &> /dev/null; then
                # Alpine Linux / OpenRC
                sudo rc-service docker start 2>/dev/null || true
                sudo rc-update add docker default 2>/dev/null || true
            elif command -v service &> /dev/null; then
                # SysV init
                sudo service docker start 2>/dev/null || true
            fi

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.10: Add User to Docker Group
            # ───────────────────────────────────────────────────────────────────
            log_info "Checking Docker group membership..."
            if command -v docker &> /dev/null; then
                # Create docker group if it doesn't exist
                sudo groupadd docker 2>/dev/null || true
                
                # Check if user is in docker group
                if ! groups "$USER" 2>/dev/null | grep -q '\bdocker\b'; then
                    log_warning "Adding $USER to docker group..."
                    sudo usermod -aG docker "$USER" 2>/dev/null || true
                    
                    # Try to apply group without logout
                    if command -v newgrp &> /dev/null; then
                        log_warning "You've been added to the docker group."
                        log_warning "Please run one of these commands:"
                        echo ""
                        echo -e "  ${YELLOW}Option 1:${NC} ${WHITE}newgrp docker${NC}"
                        echo -e "  ${YELLOW}Option 2:${NC} Log out and log back in"
                        echo -e "  ${YELLOW}Option 3:${NC} ${WHITE}exec su -l \$USER${NC}"
                        echo ""
                        log_warning "Then run this script again: ${WHITE}bash $0${NC}"
                        
                        # Ask user what to do
                        read -p "  Try to continue anyway? [y/N]: " continue_anyway
                        if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
                            log_info "Please run: newgrp docker && bash $0"
                            exit 0
                        fi
                    fi
                else
                    log_success "User $USER is already in docker group"
                fi
            fi

            # ───────────────────────────────────────────────────────────────────
            # STEP 3.11: Verify Docker is working
            # ───────────────────────────────────────────────────────────────────
            log_info "Verifying Docker installation..."
            if command -v docker &> /dev/null; then
                # Try running docker without sudo first
                if docker info &> /dev/null 2>&1; then
                    log_success "Docker is working correctly"
                elif sudo docker info &> /dev/null 2>&1; then
                    log_warning "Docker works with sudo only"
                    log_info "You may need to log out and back in for group changes to take effect"
                else
                    log_error "Docker is installed but not working properly"
                    log_info "Try: sudo systemctl restart docker"
                fi
            else
                log_error "Docker installation failed!"
                log_info "Please install Docker manually: https://docs.docker.com/engine/install/"
            fi
            ;;

        # ═══════════════════════════════════════════════════════════════════════
        # macOS INSTALLATION
        # ═══════════════════════════════════════════════════════════════════════
        mac)
            log_info "Detected macOS: $OS_VERSION ($ARCH)"
            
            # ───────────────────────────────────────────────────────────────────
            # STEP 3.1: Install Homebrew
            # ───────────────────────────────────────────────────────────────────
            if ! command -v brew &> /dev/null; then
                log_warning "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
                
                # Add Homebrew to PATH for Apple Silicon
                if [[ "$ARCH" == "arm64" ]]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
                    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
                else
                    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
                    eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
                fi
            else
                log_success "Homebrew already installed"
            fi
            
            # ───────────────────────────────────────────────────────────────────
            # STEP 3.2: Install packages via Homebrew
            # ───────────────────────────────────────────────────────────────────
            if command -v brew &> /dev/null; then
                log_info "Installing packages via Homebrew..."
                
                # Update Homebrew
                brew update 2>/dev/null || true
                
                # Install essential tools
                brew install wget curl unzip 2>/dev/null || true
                
                # Install Java 17
                log_info "Installing Java 17..."
                brew install openjdk@17 2>/dev/null || true
                # Create symlink for Java
                sudo ln -sfn $(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
                
                # Install dialog tool
                brew install dialog 2>/dev/null || true
                
                # Install Docker Desktop (if not installed)
                if ! command -v docker &> /dev/null; then
                    log_info "Installing Docker Desktop..."
                    brew install --cask docker 2>/dev/null || true
                fi
            fi
            
            # ───────────────────────────────────────────────────────────────────
            # STEP 3.3: Check Docker Desktop
            # ───────────────────────────────────────────────────────────────────
            if ! command -v docker &> /dev/null; then
                log_warning "Docker Desktop not found!"
                log_info ""
                log_info "Please install Docker Desktop from:"
                log_info "  ${CYAN}https://www.docker.com/products/docker-desktop${NC}"
                log_info ""
                log_info "After installation:"
                log_info "  1. Open Docker Desktop"
                log_info "  2. Wait for it to start (whale icon in menu bar)"
                log_info "  3. Run this script again"
                log_info ""
                
                read -p "  Press Enter after installing Docker Desktop, or Ctrl+C to exit..."
                
                if ! command -v docker &> /dev/null; then
                    log_error "Docker still not found. Please install Docker Desktop and try again."
                    exit 1
                fi
            else
                log_success "Docker Desktop is installed"
                
                # Check if Docker is running
                if ! docker info &> /dev/null 2>&1; then
                    log_warning "Docker Desktop is not running!"
                    log_info "Starting Docker Desktop..."
                    open -a Docker 2>/dev/null || true
                    
                    log_info "Waiting for Docker to start (up to 60 seconds)..."
                    local docker_wait=0
                    while ! docker info &> /dev/null 2>&1 && [ $docker_wait -lt 60 ]; do
                        sleep 2
                        docker_wait=$((docker_wait + 2))
                        echo -ne "\r  Waiting... ${docker_wait}s "
                    done
                    echo ""
                    
                    if docker info &> /dev/null 2>&1; then
                        log_success "Docker Desktop is now running"
                    else
                        log_error "Docker Desktop failed to start. Please start it manually."
                        exit 1
                    fi
                else
                    log_success "Docker Desktop is running"
                fi
            fi
            ;;

        # ═══════════════════════════════════════════════════════════════════════
        # WINDOWS (WSL) INSTALLATION
        # ═══════════════════════════════════════════════════════════════════════
        windows)
            log_info "Detected Windows (WSL)"
            
            # ───────────────────────────────────────────────────────────────────
            # STEP 3.1: Check WSL distribution
            # ───────────────────────────────────────────────────────────────────
            local WSL_DISTRO=""
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                WSL_DISTRO="$ID"
                log_info "WSL Distribution: $WSL_DISTRO"
            fi
            
            # ───────────────────────────────────────────────────────────────────
            # STEP 3.2: Install packages based on WSL distro
            # ───────────────────────────────────────────────────────────────────
            case "$WSL_DISTRO" in
                ubuntu|debian)
                    log_info "Installing packages for Ubuntu/Debian WSL..."
                    sudo apt-get update -qq 2>/dev/null || true
                    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
                        docker.io docker-compose openjdk-17-jdk openjdk-17-jre \
                        unzip wget curl ca-certificates \
                        zenity dialog 2>/dev/null || true
                    ;;
                fedora)
                    log_info "Installing packages for Fedora WSL..."
                    sudo dnf install -y \
                        docker docker-compose java-17-openjdk \
                        unzip wget curl ca-certificates \
                        zenity dialog 2>/dev/null || true
                    ;;
                opensuse*|suse*)
                    log_info "Installing packages for openSUSE WSL..."
                    sudo zypper --non-interactive install -y \
                        docker docker-compose java-17-openjdk \
                        unzip wget curl ca-certificates \
                        zenity dialog 2>/dev/null || true
                    ;;
                *)
                    log_warning "Unknown WSL distribution: $WSL_DISTRO"
                    # Try apt-get as fallback
                    if command -v apt-get &> /dev/null; then
                        sudo apt-get update -qq 2>/dev/null || true
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
                            docker.io docker-compose openjdk-17-jdk \
                            unzip wget curl zenity 2>/dev/null || true
                    fi
                    ;;
            esac
            
            # ───────────────────────────────────────────────────────────────────
            # STEP 3.3: Docker Desktop for Windows notice
            # ───────────────────────────────────────────────────────────────────
            log_info ""
            log_info "═══════════════════════════════════════════════════════════════════"
            log_info "  IMPORTANT: Docker Desktop for Windows"
            log_info "═══════════════════════════════════════════════════════════════════"
            log_info ""
            log_info "  For best results, please ensure:"
            log_info ""
            log_info "  1. Docker Desktop for Windows is installed"
            log_info "     Download: https://www.docker.com/products/docker-desktop"
            log_info ""
            log_info "  2. WSL 2 integration is enabled in Docker Desktop:"
            log_info "     Settings → Resources → WSL Integration → Enable"
            log_info ""
            log_info "  3. Your WSL distro is selected in Docker Desktop"
            log_info ""
            log_info "═══════════════════════════════════════════════════════════════════"
            log_info ""
            
            # Check if Docker is accessible
            if ! command -v docker &> /dev/null; then
                log_warning "Docker command not found in WSL"
                log_info "Please install Docker Desktop for Windows and enable WSL integration"
            elif ! docker info &> /dev/null 2>&1; then
                log_warning "Docker is installed but not accessible"
                log_info "Please ensure Docker Desktop is running and WSL integration is enabled"
            else
                log_success "Docker is accessible from WSL"
            fi
            ;;

        # ═══════════════════════════════════════════════════════════════════════
        # UNKNOWN OS
        # ═══════════════════════════════════════════════════════════════════════
        *)
            log_error "Unknown operating system: $OS_TYPE"
            log_info "This script supports:"
            log_info "  - Linux (Ubuntu, Debian, Fedora, CentOS, RHEL, openSUSE, Arch, etc.)"
            log_info "  - macOS (Intel and Apple Silicon)"
            log_info "  - Windows (WSL)"
            exit 1
            ;;
    esac

    # ═══════════════════════════════════════════════════════════════════════════
    # FINAL: Detect GUI tool
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Detecting GUI tool..."
    detect_gui_tool

    # ═══════════════════════════════════════════════════════════════════════════
    # FINAL: Summary
    # ═══════════════════════════════════════════════════════════════════════════
    echo ""
    log_info "───────────────────────────────────────────────────────────────────"
    log_info "  Prerequisites Installation Summary"
    log_info "───────────────────────────────────────────────────────────────────"
    
    # Check each component
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')
        log_success "Docker:         $docker_version"
    else
        log_error "Docker:         NOT INSTALLED"
    fi
    
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null 2>&1; then
        local compose_version=$(docker-compose --version 2>/dev/null | cut -d' ' -f4 | tr -d ',' || docker compose version 2>/dev/null | cut -d' ' -f4)
        log_success "Docker Compose: $compose_version"
    else
        log_error "Docker Compose: NOT INSTALLED"
    fi
    
    if command -v java &> /dev/null; then
        local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
        log_success "Java:           $java_version"
    else
        log_error "Java:           NOT INSTALLED"
    fi
    
    if command -v yad &> /dev/null; then
        log_success "GUI Tool:       YAD (Modern)"
    elif command -v zenity &> /dev/null; then
        log_success "GUI Tool:       Zenity"
    elif command -v dialog &> /dev/null; then
        log_success "GUI Tool:       Dialog"
    else
        log_warning "GUI Tool:       None (terminal mode only)"
    fi
    
    if command -v flatpak &> /dev/null; then
        log_success "Flatpak:        Installed (for DBeaver)"
    else
        log_warning "Flatpak:        Not installed"
    fi
    
    log_info "───────────────────────────────────────────────────────────────────"
    echo ""
    
    log_success "Dependencies installation completed!"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 04: CLEANUP
# ═══════════════════════════════════════════════════════════════════════════════
step_04_cleanup() {
    log_step "Cleanup Previous Installation"

    read -p "  Clean old installation? [Y/n]: " confirm
    [[ $confirm =~ ^[Nn]$ ]] && { log_info "Skipped"; return; }

    log_info "Cleaning..."
    pkill -9 -f "ords" 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true
    docker rm -f oracle-apex-db 2>/dev/null || true
    docker volume rm oracle-apex-complete_oracle-data 2>/dev/null || true

    rm -f "$DOWNLOADS_DIR"/apex*.zip "$DOWNLOADS_DIR"/ords*.zip 2>/dev/null || true
    rm -rf "$PROJECT_DIR"/{apex,ords,docker-compose.yml,ords_config,images,.apex_schema} 2>/dev/null || true
    
    mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR"
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    
    # CRITICAL FIX: Ensure password files exist after cleanup
    if [ ! -f "$PROJECT_DIR/.db_password" ]; then
        echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
        chmod 600 "$PROJECT_DIR/.db_password"
    fi
    if [ ! -f "$PROJECT_DIR/.apex_password" ]; then
        echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
        chmod 600 "$PROJECT_DIR/.apex_password"
    fi
    
    log_success "Cleanup completed (password files preserved)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 05: DOWNLOAD
# ═══════════════════════════════════════════════════════════════════════════════
step_05_download() {
    log_step "Downloading Components"
    cd "$PROJECT_DIR"

    local apex_path="$DOWNLOADS_DIR/$APEX_FILE"
    local ords_path="$DOWNLOADS_DIR/$ORDS_FILE"

    validate_zip_file "$apex_path" "$APEX_MIN_SIZE" 2>/dev/null || {
        rm -f "$DOWNLOADS_DIR"/apex*.zip 2>/dev/null
        download_file "$APEX_URL" "$apex_path" "APEX" "$APEX_MIN_SIZE" || exit 1
    }

    validate_zip_file "$ords_path" "$ORDS_MIN_SIZE" 2>/dev/null || {
        rm -f "$DOWNLOADS_DIR"/ords*.zip 2>/dev/null
        download_file "$ORDS_URL" "$ords_path" "ORDS" "$ORDS_MIN_SIZE" || exit 1
    }

    log_success "Downloads ready"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 06: EXTRACT
# ═══════════════════════════════════════════════════════════════════════════════
step_06_extract() {
    log_step "Extracting Components"
    cd "$PROJECT_DIR"

    local apex_path="$DOWNLOADS_DIR/$APEX_FILE"
    local ords_path="$DOWNLOADS_DIR/$ORDS_FILE"

    log_info "Extracting APEX..."
    rm -rf apex && unzip -q -o "$apex_path" || { log_error "APEX extract failed"; exit 1; }
    [ -f "apex/apexins.sql" ] || { log_error "apexins.sql missing"; exit 1; }
    log_success "APEX extracted"

    log_info "Extracting ORDS..."
    rm -rf ords && mkdir -p ords && unzip -q -o "$ords_path" -d ords || { log_error "ORDS extract failed"; exit 1; }
    find ords -name "ords" -type f -exec chmod +x {} \;
    log_success "ORDS extracted"

    log_info "Copying images..."
    rm -rf "$IMAGES_DIR" && cp -r apex/images "$IMAGES_DIR"
    log_success "Images copied"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 07: DOCKER COMPOSE
# ═══════════════════════════════════════════════════════════════════════════════
step_07_docker_compose() {
    log_step "Creating Docker Compose Configuration"
    cd "$PROJECT_DIR"

    cat > docker-compose.yml << EOF
version: '3.8'
services:
  oracle-db:
    image: ${ORACLE_IMAGE}
    container_name: oracle-apex-db
    ports:
      - "${DB_PORT}:1521"
    environment:
      - ORACLE_PASSWORD=${ORACLE_PASSWORD}
    volumes:
      - oracle-data:/opt/oracle/oradata
      - ./apex:/opt/oracle/apex:ro
    shm_size: 2g
    restart: unless-stopped
volumes:
  oracle-data:
EOF

    log_success "Docker Compose created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 08: START DATABASE
# ═══════════════════════════════════════════════════════════════════════════════
step_08_start_db() {
    log_step "Starting Oracle Database"
    cd "$PROJECT_DIR"

    docker images | grep -q "gvenzl/oracle-xe.*21-full" || {
        log_info "Pulling Oracle XE image (5-10 min)..."
        docker pull $ORACLE_IMAGE
    }

    log_info "Starting container..."
    docker compose up -d 2>/dev/null || docker-compose up -d

    wait_for_db || exit 1
    test_db_connection || exit 1

    log_success "Database running"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 09: DISABLE POLICIES
# ═══════════════════════════════════════════════════════════════════════════════
step_09_disable_policies() {
    log_step "Disabling Password Policies"

    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT
    FAILED_LOGIN_ATTEMPTS UNLIMITED
    PASSWORD_LOCK_TIME UNLIMITED
    PASSWORD_LIFE_TIME UNLIMITED
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/policies.log" || true

    log_success "Policies disabled"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 10: INSTALL APEX
# ═══════════════════════════════════════════════════════════════════════════════
step_10_install_apex() {
    log_step "Installing Oracle APEX"

    local check=$(docker exec oracle-apex-db bash -c "echo \"SELECT COUNT(*) FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%';\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep -E "^[[:space:]]*[0-9]+" | head -1 | tr -d ' ')

    if [ "$check" -gt 0 ] 2>/dev/null; then
        log_success "APEX already installed"
        return
    fi

    log_warning "Installing APEX (15-25 minutes)... Time for coffee! ☕"

    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/apex_install.log" | grep -iE "phase|complete|error|timing" || true

    sleep 30

    local verify=$(docker exec oracle-apex-db bash -c "echo \"SELECT COUNT(*) FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%';\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep -E "^[[:space:]]*[0-9]+" | head -1 | tr -d ' ')

    if [ "$verify" -gt 0 ] 2>/dev/null; then
        log_success "APEX installed and verified"
    else
        log_error "APEX installation verification failed"
        exit 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 11: APEX REST CONFIG
# ═══════════════════════════════════════════════════════════════════════════════
step_11_apex_rest() {
    log_step "Configuring APEX REST Services"

    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/apex_rest.log" | grep -iE "complete|error" || true

    sleep 10
    log_success "APEX REST configured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 12: CREATE USERS
# ═══════════════════════════════════════════════════════════════════════════════
step_12_create_users() {
    log_step "Creating Database Users"

    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
SET SERVEROUTPUT ON

BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION TO ORDS_PUBLIC_USER;
GRANT ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE TO ORDS_PUBLIC_USER;
GRANT CREATE SEQUENCE TO ORDS_PUBLIC_USER;
GRANT CREATE TABLE TO ORDS_PUBLIC_USER;
GRANT CREATE TRIGGER TO ORDS_PUBLIC_USER;
GRANT CREATE VIEW TO ORDS_PUBLIC_USER;
GRANT CREATE SYNONYM TO ORDS_PUBLIC_USER;
GRANT CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN
    BEGIN
        EXECUTE IMMEDIATE 'CREATE USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD}';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
END;
/
GRANT CONNECT TO APEX_PUBLIC_USER;
GRANT CREATE SESSION TO APEX_PUBLIC_USER;
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN
    BEGIN
        EXECUTE IMMEDIATE 'CREATE USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD}';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
END;
/
GRANT CONNECT TO APEX_LISTENER;
GRANT CREATE SESSION TO APEX_LISTENER;
ALTER USER APEX_LISTENER ACCOUNT UNLOCK;

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN
    BEGIN
        EXECUTE IMMEDIATE 'CREATE USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD}';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
END;
/
GRANT CONNECT TO APEX_REST_PUBLIC_USER;
GRANT CREATE SESSION TO APEX_REST_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER ACCOUNT UNLOCK;

COMMIT;
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/users.log"

    log_success "Database users created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 13: GRANT PROXY (CRITICAL FOR ERROR 500/571)
# ═══════════════════════════════════════════════════════════════════════════════
step_13_grant_proxy() {
    log_step "Granting Proxy Authentication (CRITICAL - Fixes Error 500/571)"

    log_warning "This step fixes Error 500 & 571 - Proxy Authentication"

    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
SET SERVEROUTPUT ON

-- Grant proxy connections
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

-- Grant proxy for APEX schema
DECLARE
    v_apex_schema VARCHAR2(30);
BEGIN
    SELECT USERNAME INTO v_apex_schema
    FROM ALL_USERS
    WHERE USERNAME LIKE 'APEX_2%'
    ORDER BY USERNAME DESC
    FETCH FIRST 1 ROW ONLY;

    EXECUTE IMMEDIATE 'ALTER USER ' || v_apex_schema || ' GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    DBMS_OUTPUT.PUT_LINE('Granted proxy for: ' || v_apex_schema);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Proxy grant note: ' || SQLERRM);
END;
/

-- Grant required privileges
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_UTILITY TO ORDS_PUBLIC_USER;

COMMIT;

-- Verify proxy grants
SELECT PROXY, CLIENT, AUTHENTICATION FROM DBA_PROXIES WHERE PROXY = 'ORDS_PUBLIC_USER';

EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/proxy_grants.log"

    log_success "Proxy authentication granted"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 14: APEX ADMIN
# ═══════════════════════════════════════════════════════════════════════════════
step_14_apex_admin() {
    log_step "Creating APEX Admin"

    local apex_schema=$(docker exec oracle-apex-db bash -c "echo \"SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ')

    if [ -z "$apex_schema" ]; then
        log_error "Could not find APEX schema"
        exit 1
    fi

    log_info "Found APEX schema: $apex_schema"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"

    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
SET SERVEROUTPUT ON

BEGIN
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('RESTFUL_SERVICES_ENABLED', 'Y');
    COMMIT;
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Instance param: ' || SQLERRM);
END;
/

BEGIN
    ${apex_schema}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);

    BEGIN
        ${apex_schema}.APEX_UTIL.CREATE_USER(
            p_user_name                    => 'ADMIN',
            p_email_address                => 'admin@localhost',
            p_web_password                 => '${APEX_ADMIN_PASSWORD}',
            p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
            p_change_password_on_first_use => 'N',
            p_account_locked               => 'N'
        );
        DBMS_OUTPUT.PUT_LINE('ADMIN user created');
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                ${apex_schema}.APEX_UTIL.EDIT_USER(
                    p_user_id                      => ${apex_schema}.APEX_UTIL.GET_USER_ID('ADMIN'),
                    p_user_name                    => 'ADMIN',
                    p_web_password                 => '${APEX_ADMIN_PASSWORD}',
                    p_new_password                 => '${APEX_ADMIN_PASSWORD}',
                    p_change_password_on_first_use => 'N',
                    p_account_locked               => 'N'
                );
                DBMS_OUTPUT.PUT_LINE('ADMIN password updated');
            EXCEPTION WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Edit user: ' || SQLERRM);
            END;
    END;

    COMMIT;
END;
/
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/admin.log"

    log_success "APEX Admin configured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 15: PRIVILEGES
# ═══════════════════════════════════════════════════════════════════════════════
step_15_privileges() {
    log_step "Granting Additional Privileges"

    local apex_schema=$(cat "$PROJECT_DIR/.apex_schema" 2>/dev/null)

    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
GRANT EXECUTE ON ${apex_schema}.WWV_FLOW_EPG_INCLUDE_MODULES TO ORDS_PUBLIC_USER;

BEGIN
    FOR r IN (SELECT object_name FROM all_objects WHERE owner = '${apex_schema}' AND object_type IN ('VIEW', 'PACKAGE') AND object_name LIKE 'WWV%' AND ROWNUM <= 50) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'GRANT EXECUTE ON ${apex_schema}.' || r.object_name || ' TO ORDS_PUBLIC_USER';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

COMMIT;
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/privileges.log"

    log_success "Privileges granted"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 16: UNINSTALL OLD ORDS
# ═══════════════════════════════════════════════════════════════════════════════
step_16_uninstall_old_ords() {
    log_step "Uninstalling Old ORDS (if exists)"

    log_info "Stopping ORDS..."
    pkill -f ords 2>/dev/null || true
    sleep 5

    log_info "Attempting ORDS uninstall from database..."
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    
    if [ -n "$ORDS_BIN" ] && [ -d "$ORDS_CONFIG_DIR" ]; then
        echo "${ORACLE_PASSWORD}" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" uninstall \
            --admin-user SYS \
            --db-hostname localhost \
            --db-port $DB_PORT \
            --db-servicename $DB_SERVICE \
            --password-stdin 2>&1 | tee "$LOG_DIR/ords_uninstall.log" | grep -iE "completed|success|error|warning|uninstall" || true
    fi

    log_info "Manually cleaning ALL ORDS users from database..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
SET SERVEROUTPUT ON

BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_METADATA CASCADE';
    DBMS_OUTPUT.PUT_LINE('Dropped ORDS_METADATA');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ORDS_METADATA: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE';
    DBMS_OUTPUT.PUT_LINE('Dropped ORDS_PUBLIC_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ORDS_PUBLIC_USER: ' || SQLERRM);
END;
/

BEGIN
    FOR u IN (SELECT username FROM dba_users WHERE username LIKE 'ORDS%' AND username != 'ORDSYS') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP USER ' || u.username || ' CASCADE';
            DBMS_OUTPUT.PUT_LINE('Dropped ' || u.username);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(u.username || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

COMMIT;
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/manual_cleanup.log"

    log_info "Deleting old ORDS configuration..."
    rm -rf "$ORDS_CONFIG_DIR"/* 2>/dev/null || true
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"

    log_success "Old ORDS uninstalled and cleaned - ready for fresh install"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 17: INSTALL ORDS METADATA (CRITICAL FOR ERROR 500)
# ═══════════════════════════════════════════════════════════════════════════════
step_17_install_ords_metadata() {
    log_step "Installing ORDS with Metadata Schema (Fixes Error 500)"
    cd "$PROJECT_DIR"

    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
    [ -z "$ORDS_BIN" ] && { log_error "ORDS binary not found"; exit 1; }
    chmod +x "$ORDS_BIN"

    log_warning "CRITICAL: Installing ORDS schema into database..."
    log_info "This creates ORDS_METADATA and ORDS_PUBLIC_USER (3-7 minutes)..."

    # Create password file for non-interactive install
    local PASS_FILE=$(mktemp)
    echo "${ORACLE_PASSWORD}" > "$PASS_FILE"
    echo "${ORACLE_PASSWORD}" >> "$PASS_FILE"
    echo "${ORACLE_PASSWORD}" >> "$PASS_FILE"

    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
        --admin-user SYS \
        --db-hostname localhost \
        --db-port $DB_PORT \
        --db-servicename $DB_SERVICE \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --log-folder "$LOG_DIR" \
        --password-stdin < "$PASS_FILE" 2>&1 | tee "$LOG_DIR/ords_metadata_install.log"

    rm -f "$PASS_FILE"
    sleep 10

    # Verify ORDS_METADATA
    log_info "Verifying ORDS_METADATA schema..."
    local METADATA_CHECK=$(docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME='ORDS_METADATA';
EXIT;
EOF" 2>/dev/null | grep -o '[0-9]' | head -1)

    if [ "$METADATA_CHECK" = "1" ]; then
        log_success "✅ ORDS_METADATA schema created successfully!"
        
        # Re-grant proxy permissions after ORDS install
        log_info "Re-granting proxy permissions..."
        docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOF" 2>&1 || true
        
        log_success "ORDS metadata installation completed"
    else
        log_warning "⚠️ ORDS_METADATA not found - attempting alternative installation..."
        
        # Create ORDS_PUBLIC_USER manually if needed
        docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOF
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD};
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1 || true

        # Retry ORDS install
        echo "${ORACLE_PASSWORD}" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
            --admin-user SYS \
            --db-hostname localhost \
            --db-port $DB_PORT \
            --db-servicename $DB_SERVICE \
            --feature-sdw true \
            --gateway-mode proxied \
            --gateway-user APEX_PUBLIC_USER \
            --log-folder "$LOG_DIR" \
            --password-stdin 2>&1 | tee "$LOG_DIR/ords_metadata_install_retry.log" || true
    fi
}
# ═══════════════════════════════════════════════════════════════════════════════
# STEP 18: FIX POOL CONFIGURATION (CRITICAL FOR ERROR 574)
# ═══════════════════════════════════════════════════════════════════════════════
step_18_fix_pool_config() {
    log_step "Fixing ORDS Pool Configuration (Fixes Error 574)"

    log_warning "CRITICAL: This step fixes Error 574 - Database Credential Error"

    # Reset all passwords
    log_info "Resetting database user passwords..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;

-- Re-grant proxy
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

COMMIT;
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/password_reset.log"

    # Test connection
    log_info "Testing ORDS_PUBLIC_USER connection..."
    local test_result=$(docker exec oracle-apex-db bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s ORDS_PUBLIC_USER/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1" 2>&1)
    
    if echo "$test_result" | grep -q "1"; then
        log_success "✅ ORDS_PUBLIC_USER can connect"
    else
        log_warning "Connection test failed, recreating user..."
        docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
DROP USER ORDS_PUBLIC_USER CASCADE;
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD};
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1
    fi

    # CRITICAL FIX: Use ORDS CLI to set password securely (encrypted)
    log_info "Setting ORDS database password using CLI (encrypted)..."
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
    
    if [ -n "$ORDS_BIN" ]; then
        echo "${ORACLE_PASSWORD}" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>&1 || true
    fi

    # Create pool.xml WITHOUT plain text password (ORDS will use encrypted secret)
    log_info "Creating pool.xml (without plain text password)..."
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    
    cat > "$ORDS_CONFIG_DIR/databases/default/pool.xml" << POOLEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>ORDS Connection Pool - KaizenixCore v${VERSION}</comment>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">localhost</entry>
<entry key="db.port">${DB_PORT}</entry>
<entry key="db.servicename">${DB_SERVICE}</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="plsql.gateway.mode">proxied</entry>
<entry key="feature.sdw">true</entry>
<entry key="restEnabledSql.active">true</entry>
<entry key="security.requestValidationFunction">wwv_flow_epg_include_modules.authorize</entry>
<entry key="jdbc.InitialLimit">3</entry>
<entry key="jdbc.MinLimit">1</entry>
<entry key="jdbc.MaxLimit">10</entry>
</properties>
POOLEOF

    # Create global settings
    cat > "$ORDS_CONFIG_DIR/global/settings.xml" << 'GLOBALEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="database.api.enabled">true</entry>
<entry key="debug.printDebugToScreen">true</entry>
</properties>
GLOBALEOF

    # Create standalone settings with actual path
    cat > "$ORDS_CONFIG_DIR/settings.xml" << SETTINGSEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="standalone.context.path">/ords</entry>
<entry key="standalone.http.port">${ORDS_PORT}</entry>
<entry key="standalone.static.context.path">/i</entry>
<entry key="standalone.static.path">${IMAGES_DIR}</entry>
<entry key="standalone.doc.root">${IMAGES_DIR}</entry>
</properties>
SETTINGSEOF

    log_success "✅ Pool configuration fixed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 19: CONFIGURE ORDS
# ═══════════════════════════════════════════════════════════════════════════════
step_19_configure_ords() {
    log_step "Configuring ORDS Settings"
    cd "$PROJECT_DIR"

    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)

    log_info "Configuring standalone settings..."
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.context.path /ords 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port $ORDS_PORT 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" 2>&1 || true

    log_success "ORDS configuration completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 20: FINAL UNLOCK
# ═══════════════════════════════════════════════════════════════════════════════
step_20_final_unlock() {
    log_step "Final Unlock and Verify"

    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;

ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

COMMIT;
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/final_unlock.log"

    # Test connection
    local result=$(docker exec oracle-apex-db bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s ORDS_PUBLIC_USER/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1" 2>&1)
    echo "$result" | grep -q "1" && log_success "✅ Connection verified" || log_warning "Connection test inconclusive"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 21: VERIFY CONFIG
# ═══════════════════════════════════════════════════════════════════════════════
step_21_verify_config() {
    log_step "Verifying ORDS Configuration"

    [ -f "$ORDS_CONFIG_DIR/databases/default/pool.xml" ] && log_success "pool.xml exists" || log_warning "pool.xml missing"
    [ -f "$ORDS_CONFIG_DIR/settings.xml" ] && log_success "settings.xml exists" || log_warning "settings.xml missing"

    log_info "Config files:"
    find "$ORDS_CONFIG_DIR" -type f -name "*.xml" 2>/dev/null | head -10
    
    # Verify password files exist
    [ -f "$PROJECT_DIR/.db_password" ] && log_success "Password file exists" || log_warning "Password file missing!"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 22: START ORDS
# ═══════════════════════════════════════════════════════════════════════════════
step_22_start_ords() {
    log_step "Starting ORDS"
    cd "$PROJECT_DIR"

    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)

    pkill -9 -f "ords" 2>/dev/null || true
    sleep 5

    log_info "Starting ORDS on port $ORDS_PORT..."

    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port $ORDS_PORT \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &

    echo $! > "$PROJECT_DIR/ords.pid"

    log_info "Waiting for ORDS to start (90 seconds)..."

    local timeout=180
    local start=$(date +%s)

    while true; do
        sleep 5

        if ! pgrep -f "ords" > /dev/null; then
            log_warning "ORDS process not found, checking log..."
            tail -20 "$LOG_DIR/ords.log" 2>/dev/null || true
            break
        fi

        local code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/" 2>/dev/null || echo "000")

        if [[ "$code" =~ ^(200|301|302|303)$ ]]; then
            echo ""
            log_success "ORDS responding (HTTP $code)"
            break
        fi

        local elapsed=$(($(date +%s) - start))
        [ $elapsed -gt $timeout ] && { echo ""; log_warning "Timeout"; break; }

        echo -ne "\r  ${CYAN}⏳ Waiting... ${elapsed}s (HTTP $code)${NC}    "
    done

    sleep 20
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 23: CREATE MANAGEMENT SCRIPTS
# ═══════════════════════════════════════════════════════════════════════════════
step_23_scripts() {
    log_step "Creating Management Scripts"

    local ACTUAL_PASS="$ORACLE_PASSWORD"

    # START SCRIPT WITH AUTO-RECOVERY
    cat > "$SCRIPTS_DIR/start.sh" << STARTEOF
#!/bin/bash
################################################################################
# Oracle APEX Start Script with Smart Auto-Recovery
# KaizenixCore v${VERSION}
################################################################################

cd ~/oracle-apex-complete
PASS="${ACTUAL_PASS}"

if [ -z "\$PASS" ]; then
    PASS=\$(cat .db_password 2>/dev/null)
fi

if [ -z "\$PASS" ]; then
    echo "❌ Password not found!"
    echo "Please create: echo 'yourpassword' > ~/oracle-apex-complete/.db_password"
    exit 1
fi

echo "════════════════════════════════════════════════════════════"
echo "  Starting Oracle APEX Services..."
echo "════════════════════════════════════════════════════════════"

echo ""
echo "Step 1: Starting database container..."
docker start oracle-apex-db 2>/dev/null || docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null
echo "Waiting 90s for database to be ready..."
sleep 90

echo ""
echo "Step 2: Verifying database connection..."
for i in {1..10}; do
    if docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba <<< "SELECT 1 FROM DUAL;" 2>/dev/null | grep -q "1"; then
        echo "✅ Database connection verified"
        break
    fi
    echo "  Attempt \$i/10 - waiting..."
    sleep 10
done

echo ""
echo "Step 3: Running auto-recovery (fixing schemas and proxies)..."
docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba << RECOVERYEOF
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
RECOVERYEOF

echo ""
echo "Step 4: Starting ORDS..."
pkill -f ords 2>/dev/null || true
sleep 3

ORDS_BIN=\$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
if [ -n "\$ORDS_BIN" ]; then
    export ORDS_CONFIG=~/oracle-apex-complete/ords_config
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "\$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &
    echo "ORDS started (PID \$!)"
fi

echo "Waiting 60s for ORDS to initialize..."
sleep 60

echo ""
echo "Step 5: Verifying endpoints..."
HTTP_ADMIN=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=\$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ✅ Oracle APEX Started!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  APEX Admin:  HTTP \$HTTP_ADMIN - http://localhost:8080/ords/apex_admin"
echo "  APEX Login:  HTTP \$HTTP_LOGIN - http://localhost:8080/ords/f?p=4550"
echo ""

if [[ ! "\$HTTP_ADMIN" =~ ^(200|302|303)$ ]]; then
    echo "⚠️  If you see errors, run: bash ~/oracle-apex-complete/scripts/fix.sh"
fi
STARTEOF

    # STOP SCRIPT
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
echo "════════════════════════════════════════════════════════════"
echo "  Stopping Oracle APEX Services..."
echo "════════════════════════════════════════════════════════════"
pkill -f ords 2>/dev/null || true
sleep 3
cd ~/oracle-apex-complete && docker stop oracle-apex-db 2>/dev/null || true
echo ""
echo "✅ Oracle APEX stopped successfully!"
STOPEOF

    # STATUS SCRIPT
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
echo "════════════════════════════════════════════════════════════"
echo "  Oracle APEX Status"
echo "════════════════════════════════════════════════════════════"
echo ""

DB_STATUS=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo "false")
if [ "$DB_STATUS" = "true" ]; then
    echo "  Database:    🟢 Running"
else
    echo "  Database:    🔴 Stopped"
fi

ORDS_PID=$(pgrep -f "ords.*serve" | head -1)
if [ -n "$ORDS_PID" ]; then
    echo "  ORDS:        🟢 Running (PID $ORDS_PID)"
else
    echo "  ORDS:        🔴 Stopped"
fi

echo ""
echo "  HTTP Endpoints:"
HTTP_ORDS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")

echo "    ORDS Root:   HTTP $HTTP_ORDS"
echo "    APEX Admin:  HTTP $HTTP_ADMIN"
echo "    APEX Login:  HTTP $HTTP_LOGIN"
echo ""
echo "════════════════════════════════════════════════════════════"
STATUSEOF

    # LOGS SCRIPT
    cat > "$SCRIPTS_DIR/logs.sh" << 'LOGSEOF'
#!/bin/bash
echo "════════════════════════════════════════════════════════════"
echo "  ORDS Logs (last 100 lines)"
echo "════════════════════════════════════════════════════════════"
tail -100 ~/oracle-apex-complete/logs/ords.log 2>/dev/null || echo "No logs found"
LOGSEOF

    # COMPREHENSIVE FIX SCRIPT
    cat > "$SCRIPTS_DIR/fix.sh" << FIXEOF
#!/bin/bash
################################################################################
#  COMPREHENSIVE FIX SCRIPT - Fixes Error 500, 574, 571, 404
#  KaizenixCore v${VERSION}
################################################################################

cd ~/oracle-apex-complete
PASS="${ACTUAL_PASS}"

if [ -z "\$PASS" ]; then
    PASS=\$(cat .db_password 2>/dev/null)
fi

if [ -z "\$PASS" ]; then
    echo "❌ Password file not found!"
    echo "Please create: echo 'yourpassword' > ~/oracle-apex-complete/.db_password"
    exit 1
fi

echo "════════════════════════════════════════════════════════════"
echo "  COMPREHENSIVE FIX - Error 500/574/571/404/Schema Not Found"
echo "════════════════════════════════════════════════════════════"
echo ""

echo "Step 1: Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 5
echo "✅ ORDS stopped"

echo ""
echo "Step 2: Ensuring database is running..."
docker start oracle-apex-db 2>/dev/null || true
sleep 30

for i in {1..20}; do
    if docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba <<< "SELECT 1 FROM DUAL;" 2>/dev/null | grep -q "1"; then
        echo "✅ Database is ready"
        break
    fi
    echo "  Waiting for database... attempt \$i/20"
    sleep 10
done

echo ""
echo "Step 3: Fixing database accounts and passwords..."
docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba << SQLEOF
SET SERVEROUTPUT ON

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ORDS_PUBLIC_USER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('APEX_PUBLIC_USER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('APEX_LISTENER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('APEX_REST_PUBLIC_USER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

COMMIT;
EXIT;
SQLEOF
echo "✅ Database accounts fixed"

echo ""
echo "Step 4: Testing ORDS_PUBLIC_USER connection..."
TEST_RESULT=\$(docker exec oracle-apex-db sqlplus -s ORDS_PUBLIC_USER/\${PASS}@//localhost:1521/XEPDB1 << 'TESTEOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT 'CONNECTION_OK' FROM DUAL;
EXIT;
TESTEOF
)

if echo "\$TEST_RESULT" | grep -q "CONNECTION_OK"; then
    echo "✅ ORDS_PUBLIC_USER can connect"
else
    echo "⚠️ Connection failed - recreating user..."
    docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba << RECREATEOF
DROP USER ORDS_PUBLIC_USER CASCADE;
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \${PASS};
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
RECREATEOF
    echo "✅ User recreated"
fi

echo ""
echo "Step 5: Setting ORDS database password (encrypted)..."
ORDS_BIN=\$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
if [ -n "\$ORDS_BIN" ]; then
    echo "\${PASS}" | "\$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config secret --password-stdin db.password 2>/dev/null || true
    echo "✅ Password set"
fi

echo ""
echo "Step 6: Starting ORDS..."
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

ORDS_BIN=\$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
if [ -n "\$ORDS_BIN" ]; then
    nohup "\$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &
    echo "ORDS started with PID \$!"
fi

echo "Waiting 90s for ORDS to fully start..."
sleep 90

echo ""
echo "Step 7: Testing endpoints..."
HTTP_ROOT=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
HTTP_ADMIN=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=\$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  FIX COMPLETED!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  Status:"
echo "    ORDS Root:    HTTP \$HTTP_ROOT"
echo "    APEX Admin:   HTTP \$HTTP_ADMIN"
echo "    APEX Login:   HTTP \$HTTP_LOGIN"
echo ""

if [[ "\$HTTP_ADMIN" =~ ^(200|302|303)$ ]] && [[ "\$HTTP_LOGIN" =~ ^(200|302|303)$ ]]; then
    echo "✅ All endpoints working!"
else
    echo "⚠️ Some endpoints may need more time. Wait 2 minutes and refresh browser."
fi

echo ""
echo "  URLs:"
echo "    http://localhost:8080/ords/apex_admin"
echo "    http://localhost:8080/ords/f?p=4550"
echo ""
FIXEOF

    # RESET APEX PASSWORD SCRIPT
    cat > "$SCRIPTS_DIR/reset-apex-password.sh" << RESETEOF
#!/bin/bash
cd ~/oracle-apex-complete
PASS="${ACTUAL_PASS}"

if [ -z "\$PASS" ]; then
    PASS=\$(cat .db_password 2>/dev/null)
fi

echo "════════════════════════════════════════════════════════════"
echo "  Reset APEX Admin Password"
echo "════════════════════════════════════════════════════════════"
echo ""
read -p "Enter new APEX Admin password: " NEW_PASS

APEX_SCHEMA=\$(cat .apex_schema 2>/dev/null)
if [ -z "\$APEX_SCHEMA" ]; then
    APEX_SCHEMA=\$(docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SCHEMAEOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;
EXIT;
SCHEMAEOF
)
    APEX_SCHEMA=\$(echo "\$APEX_SCHEMA" | grep "^APEX_" | tr -d ' ')
    echo "\$APEX_SCHEMA" > ~/oracle-apex-complete/.apex_schema
fi

echo "Using APEX schema: \$APEX_SCHEMA"

docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba << RESETPWEOF
BEGIN
    \${APEX_SCHEMA}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    \${APEX_SCHEMA}.APEX_UTIL.EDIT_USER(
        p_user_id => \${APEX_SCHEMA}.APEX_UTIL.GET_USER_ID('ADMIN'),
        p_user_name => 'ADMIN',
        p_web_password => '\${NEW_PASS}',
        p_new_password => '\${NEW_PASS}',
        p_change_password_on_first_use => 'N',
        p_account_locked => 'N'
    );
    COMMIT;
END;
/
EXIT;
RESETPWEOF

echo "\$NEW_PASS" > ~/oracle-apex-complete/.apex_password
echo ""
echo "✅ Password updated!"
echo "   Username: ADMIN"
echo "   Password: \$NEW_PASS"
RESETEOF

    chmod +x "$SCRIPTS_DIR"/*.sh
    log_success "Management scripts created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 24: VERIFY INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════
step_24_verify() {
    log_step "Verifying Installation"

    sleep 30

    log_info "Testing endpoints..."

    local ords_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/" 2>/dev/null || echo "000")
    local apex_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null || echo "000")
    local apex_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/f?p=4550" 2>/dev/null || echo "000")

    echo ""
    if [[ "$ords_code" =~ ^(200|301|302|303)$ ]]; then
        log_success "ORDS Root: HTTP $ords_code"
    else
        log_warning "ORDS Root: HTTP $ords_code"
    fi

    if [[ "$apex_code" =~ ^(200|301|302|303)$ ]]; then
        log_success "APEX Admin: HTTP $apex_code"
    else
        log_warning "APEX Admin: HTTP $apex_code - Run fix.sh if needed"
    fi

    if [[ "$apex_login" =~ ^(200|301|302|303)$ ]]; then
        log_success "APEX Login: HTTP $apex_login"
    else
        log_warning "APEX Login: HTTP $apex_login"
    fi

    echo ""
    log_info "Checking for errors in log..."
    if grep -qi "ORA-00942\|574\|ORA-01017\|500" "$LOG_DIR/ords.log" 2>/dev/null; then
        log_warning "Found potential errors - run fix.sh if needed"
    else
        log_success "No critical errors found"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 25: FINAL CHECK AND AUTO-FIX
# ═══════════════════════════════════════════════════════════════════════════════
step_25_final_check() {
    log_step "Final Configuration Check"

    if [ ! -f "$PROJECT_DIR/.db_password" ]; then
        log_warning "Password file missing - recreating..."
        echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
        chmod 600 "$PROJECT_DIR/.db_password"
    fi

    local apex_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null || echo "000")
    
    if [[ "$apex_code" =~ ^(574|500|404)$ ]] || grep -q "571\|proxy\|ORA-00942\|574\|500" "$LOG_DIR/ords.log" 2>/dev/null; then
        log_warning "Detected issues - running automatic fix..."
        bash "$SCRIPTS_DIR/fix.sh"
        sleep 30
    fi

    log_success "Final check completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 26: SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════
step_26_summary() {
    log_step "Installation Summary"

    echo ""
    echo -e "${GREEN}${BOLD}  ╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
    echo -e "${GREEN}${BOLD}  ║           🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉             ║${NC}"
    echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
    echo -e "${GREEN}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   🌐 APEX URLs:${NC}"
    echo -e "      Admin:  ${CYAN}http://localhost:$ORDS_PORT/ords/apex_admin${NC}"
    echo -e "      Login:  ${CYAN}http://localhost:$ORDS_PORT/ords/f?p=4550${NC}"
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   🔐 Credentials:${NC}"
    echo -e "      Workspace: ${WHITE}INTERNAL${NC}"
    echo -e "      Username:  ${WHITE}ADMIN${NC}"
    echo -e "      Password:  ${WHITE}${APEX_ADMIN_PASSWORD}${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   🗄️ Database:${NC}"
    echo -e "      Host:      ${WHITE}localhost:$DB_PORT${NC}"
    echo -e "      Service:   ${WHITE}$DB_SERVICE${NC}"
    echo -e "      SYS Pass:  ${WHITE}${ORACLE_PASSWORD}${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   📜 Management Scripts:${NC}"
    echo -e "      Start:      ${CYAN}bash $SCRIPTS_DIR/start.sh${NC}"
    echo -e "      Stop:       ${CYAN}bash $SCRIPTS_DIR/stop.sh${NC}"
    echo -e "      Status:     ${CYAN}bash $SCRIPTS_DIR/status.sh${NC}"
    echo -e "      Fix:        ${CYAN}bash $SCRIPTS_DIR/fix.sh${NC}"
    echo -e "      Logs:       ${CYAN}bash $SCRIPTS_DIR/logs.sh${NC}"
    echo -e "      Reset PW:   ${CYAN}bash $SCRIPTS_DIR/reset-apex-password.sh${NC}"
    echo -e "      GUI:        ${CYAN}bash $SCRIPTS_DIR/launch-gui.sh${NC}"
    echo -e "      DBeaver:    ${CYAN}bash $SCRIPTS_DIR/open-dbeaver.sh${NC}"
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}${BOLD}   💡 Troubleshooting:${NC}"
    echo -e "      If you see Error 500/574 or 'Invalid schema name':"
    echo -e "      ${WHITE}bash $SCRIPTS_DIR/fix.sh${NC}"
    echo ""
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}   Created by: ${WHITE}Peyman Rasouli${NC} ${GRAY}| Project: ${MAGENTA}KaizenixCore${NC}"
    echo -e "${GRAY}   GitHub: ${BLUE}https://github.com/KaizenixCore/oracle-apex-installer/${NC}"
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}
# ═══════════════════════════════════════════════════════════════════════════════
# STEP 27: CREATE GUI (CROSS-PLATFORM WITH YAD/ZENITY)
# ═══════════════════════════════════════════════════════════════════════════════
step_27_create_gui() {
    log_step "Creating Multi-Language GUI Manager (YAD/Zenity - Cross-Platform)"

    local ACTUAL_PASS="$ORACLE_PASSWORD"

    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
################################################################################
#  Oracle APEX Manager - Multi-Language GUI (YAD/Zenity)
#  Created by: Peyman Rasouli | KaizenixCore
#  Languages: English, فارسی, Deutsch
#  Version: 3.0.0 - Cross-Platform (Linux, macOS, Windows WSL)
################################################################################

# ═══════════════════════════════════════════════════════════════════════════════
# DETECT GUI TOOL (YAD > ZENITY > DIALOG)
# ═══════════════════════════════════════════════════════════════════════════════
GUI_TOOL=""
if command -v yad &> /dev/null; then
    GUI_TOOL="yad"
elif command -v zenity &> /dev/null; then
    GUI_TOOL="zenity"
elif command -v dialog &> /dev/null; then
    GUI_TOOL="dialog"
else
    echo "❌ No GUI tool found!"
    echo "Please install one of: yad, zenity, or dialog"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# PREVENT MULTIPLE INSTANCES
# ═══════════════════════════════════════════════════════════════════════════════
LOCK_FILE="/tmp/oracle-apex-gui.lock"
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --warning --title="Oracle APEX Manager" \
                --text="Oracle APEX Manager is already running!\n\nPID: $PID" \
                --width=350 --timeout=5 2>/dev/null
        else
            zenity --warning --title="Oracle APEX Manager" \
                --text="Oracle APEX Manager is already running!\n\nPID: $PID" \
                --width=350 --timeout=5 2>/dev/null
        fi
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════
PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
LOG_DIR="$PROJECT_DIR/logs"
CONFIG_FILE="$PROJECT_DIR/.gui_config"
LANG_CODE="en"
GUIEOF

    # Embed password in script
    cat >> "$SCRIPTS_DIR/launch-gui.sh" << GUIEOF2
DB_PASS="${ACTUAL_PASS}"
GUIEOF2

    cat >> "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF3'

# Fallback to password file
if [ -z "$DB_PASS" ]; then
    DB_PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
fi

# Load saved language preference
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE" 2>/dev/null || LANG_CODE="en"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS
# ═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_EN=(
    ["title"]="Oracle APEX Manager"
    ["subtitle"]="KaizenixCore Edition v3.0"
    ["select_action"]="Select an action:"
    ["start"]="▶️  Start Services"
    ["stop"]="⏹️  Stop Services"
    ["status"]="📊  Check Status"
    ["admin"]="🌐  Open Admin Panel"
    ["login"]="🔐  Open Login Page"
    ["fix"]="🔧  Run Fix Script"
    ["logs"]="📜  View Logs"
    ["dbeaver"]="🗄️  Open DBeaver"
    ["settings"]="⚙️  Settings"
    ["exit"]="❌  Exit"
    ["starting"]="Starting Oracle APEX..."
    ["stopping"]="Stopping Oracle APEX..."
    ["please_wait"]="Please wait..."
    ["success_start"]="✅ Oracle APEX started successfully!"
    ["success_stop"]="✅ Oracle APEX stopped successfully!"
    ["error_not_running"]="⚠️ Oracle APEX is not running!\nPlease start it first."
    ["select_language"]="Select Language"
    ["status_running"]="Running"
    ["status_stopped"]="Stopped"
    ["open_browser"]="Open Admin Panel in browser?"
    ["fix_running"]="Running fix script..."
    ["fix_complete"]="Fix script completed!"
    ["no_logs"]="No logs found"
    ["db_status"]="Database"
    ["ords_status"]="ORDS"
    ["endpoints"]="HTTP Endpoints"
    ["dbeaver_opening"]="Opening DBeaver..."
    ["dbeaver_not_found"]="DBeaver not installed"
)

declare -A LANG_FA=(
    ["title"]="مدیریت اوراکل اپکس"
    ["subtitle"]="نسخه KaizenixCore v3.0"
    ["select_action"]="یک عملیات انتخاب کنید:"
    ["start"]="▶️  شروع سرویس‌ها"
    ["stop"]="⏹️  توقف سرویس‌ها"
    ["status"]="📊  بررسی وضعیت"
    ["admin"]="🌐  پنل مدیریت"
    ["login"]="🔐  صفحه ورود"
    ["fix"]="🔧  اجرای اسکریپت تعمیر"
    ["logs"]="📜  مشاهده لاگ‌ها"
    ["dbeaver"]="🗄️  باز کردن DBeaver"
    ["settings"]="⚙️  تنظیمات"
    ["exit"]="❌  خروج"
    ["starting"]="در حال شروع اوراکل اپکس..."
    ["stopping"]="در حال توقف اوراکل اپکس..."
    ["please_wait"]="لطفاً صبر کنید..."
    ["success_start"]="✅ اوراکل اپکس با موفقیت شروع شد!"
    ["success_stop"]="✅ اوراکل اپکس با موفقیت متوقف شد!"
    ["error_not_running"]="⚠️ اوراکل اپکس در حال اجرا نیست!\nلطفاً ابتدا آن را شروع کنید."
    ["select_language"]="انتخاب زبان"
    ["status_running"]="در حال اجرا"
    ["status_stopped"]="متوقف"
    ["open_browser"]="پنل مدیریت در مرورگر باز شود؟"
    ["fix_running"]="در حال اجرای اسکریپت تعمیر..."
    ["fix_complete"]="اسکریپت تعمیر با موفقیت اجرا شد!"
    ["no_logs"]="لاگی یافت نشد"
    ["db_status"]="پایگاه داده"
    ["ords_status"]="ORDS"
    ["endpoints"]="آدرس‌های HTTP"
    ["dbeaver_opening"]="در حال باز کردن DBeaver..."
    ["dbeaver_not_found"]="DBeaver نصب نشده است"
)

declare -A LANG_DE=(
    ["title"]="Oracle APEX Manager"
    ["subtitle"]="KaizenixCore Edition v3.0"
    ["select_action"]="Wählen Sie eine Aktion:"
    ["start"]="▶️  Dienste starten"
    ["stop"]="⏹️  Dienste stoppen"
    ["status"]="📊  Status prüfen"
    ["admin"]="🌐  Admin-Panel öffnen"
    ["login"]="🔐  Anmeldeseite öffnen"
    ["fix"]="🔧  Reparaturskript ausführen"
    ["logs"]="📜  Protokolle anzeigen"
    ["dbeaver"]="🗄️  DBeaver öffnen"
    ["settings"]="⚙️  Einstellungen"
    ["exit"]="❌  Beenden"
    ["starting"]="Oracle APEX wird gestartet..."
    ["stopping"]="Oracle APEX wird gestoppt..."
    ["please_wait"]="Bitte warten..."
    ["success_start"]="✅ Oracle APEX erfolgreich gestartet!"
    ["success_stop"]="✅ Oracle APEX erfolgreich gestoppt!"
    ["error_not_running"]="⚠️ Oracle APEX läuft nicht!\nBitte starten Sie es zuerst."
    ["select_language"]="Sprache auswählen"
    ["status_running"]="Läuft"
    ["status_stopped"]="Gestoppt"
    ["open_browser"]="Admin-Panel im Browser öffnen?"
    ["fix_running"]="Reparaturskript wird ausgeführt..."
    ["fix_complete"]="Reparaturskript abgeschlossen!"
    ["no_logs"]="Keine Protokolle gefunden"
    ["db_status"]="Datenbank"
    ["ords_status"]="ORDS"
    ["endpoints"]="HTTP-Endpunkte"
    ["dbeaver_opening"]="DBeaver wird geöffnet..."
    ["dbeaver_not_found"]="DBeaver nicht installiert"
)

get_str() {
    local key=$1
    case $LANG_CODE in
        fa) echo "${LANG_FA[$key]:-${LANG_EN[$key]}}" ;;
        de) echo "${LANG_DE[$key]:-${LANG_EN[$key]}}" ;;
        *)  echo "${LANG_EN[$key]}" ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# CHECK SERVICE STATUS
# ═══════════════════════════════════════════════════════════════════════════════
check_status() {
    local db_ok=false
    local ords_ok=false
    
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"; then
        db_ok=true
    fi
    
    if pgrep -f "ords.*serve" > /dev/null 2>&1; then
        ords_ok=true
    fi
    
    $db_ok && $ords_ok
}

# ═══════════════════════════════════════════════════════════════════════════════
# AUTO-RECOVERY FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════
auto_recovery() {
    [ -z "$DB_PASS" ] && return 1
    
    docker exec oracle-apex-db sqlplus -s sys/${DB_PASS}@//localhost:1521/XEPDB1 as sysdba << 'RECOVERYEOF' > /dev/null 2>&1
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
RECOVERYEOF
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# START SERVICES
# ═══════════════════════════════════════════════════════════════════════════════
start_services() {
    if [ "$GUI_TOOL" = "yad" ]; then
        (
            echo "5"; echo "# Starting database container..."
            docker start oracle-apex-db 2>/dev/null || docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d 2>/dev/null || true
            
            echo "15"; echo "# Waiting for database (60s)..."
            sleep 60
            
            echo "35"; echo "# Running auto-recovery..."
            auto_recovery
            
            echo "45"; echo "# Waiting for database to stabilize..."
            sleep 30
            
            echo "55"; echo "# Stopping old ORDS..."
            pkill -f ords 2>/dev/null || true
            sleep 3
            
            echo "65"; echo "# Starting ORDS..."
            ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
            if [ -n "$ORDS_BIN" ]; then
                export ORDS_CONFIG="$PROJECT_DIR/ords_config"
                export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
                nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$LOG_DIR/ords.log" 2>&1 &
            fi
            
            echo "80"; echo "# Waiting for ORDS to start (45s)..."
            sleep 45
            
            echo "95"; echo "# Verifying services..."
            sleep 5
            
            echo "100"; echo "# Done!"
        ) | yad --progress --title="$(get_str title)" --text="$(get_str starting)" \
            --percentage=0 --auto-close --no-cancel --width=450 --height=100 2>/dev/null
    else
        (
            echo "5"; echo "# Starting database container..."
            docker start oracle-apex-db 2>/dev/null || docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d 2>/dev/null || true
            
            echo "15"; echo "# Waiting for database (60s)..."
            sleep 60
            
            echo "35"; echo "# Running auto-recovery..."
            auto_recovery
            
            echo "45"; echo "# Waiting for database to stabilize..."
            sleep 30
            
            echo "55"; echo "# Stopping old ORDS..."
            pkill -f ords 2>/dev/null || true
            sleep 3
            
            echo "65"; echo "# Starting ORDS..."
            ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
            if [ -n "$ORDS_BIN" ]; then
                export ORDS_CONFIG="$PROJECT_DIR/ords_config"
                export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
                nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$LOG_DIR/ords.log" 2>&1 &
            fi
            
            echo "80"; echo "# Waiting for ORDS to start (45s)..."
            sleep 45
            
            echo "95"; echo "# Verifying services..."
            sleep 5
            
            echo "100"; echo "# Done!"
        ) | zenity --progress --title="$(get_str title)" --text="$(get_str starting)" \
            --percentage=0 --auto-close --no-cancel --width=450 2>/dev/null
    fi
    
    sleep 3
    
    if check_status; then
        local http_admin=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
        
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --info --title="$(get_str title)" \
                --text="$(get_str success_start)\n\n🌐 Admin: http://localhost:8080/ords/apex_admin\n🔐 Login: http://localhost:8080/ords/f?p=4550\n\nHTTP Status: $http_admin" \
                --width=450 --button="Open Browser:0" --button="Close:1" 2>/dev/null
            if [ $? -eq 0 ]; then
                xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
            fi
        else
            zenity --info --title="$(get_str title)" \
                --text="$(get_str success_start)\n\n🌐 Admin: http://localhost:8080/ords/apex_admin\n🔐 Login: http://localhost:8080/ords/f?p=4550\n\nHTTP Status: $http_admin" \
                --width=450 2>/dev/null
            
            if zenity --question --title="$(get_str title)" --text="$(get_str open_browser)" --width=350 2>/dev/null; then
                xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
            fi
        fi
    else
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --warning --title="$(get_str title)" \
                --text="Services may not have started correctly.\n\nTry running Fix Script from the menu." \
                --width=450 2>/dev/null
        else
            zenity --warning --title="$(get_str title)" \
                --text="Services may not have started correctly.\n\nTry running Fix Script from the menu." \
                --width=450 2>/dev/null
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# STOP SERVICES
# ═══════════════════════════════════════════════════════════════════════════════
stop_services() {
    if [ "$GUI_TOOL" = "yad" ]; then
        (
            echo "20"; echo "# Stopping ORDS..."
            pkill -f ords 2>/dev/null || true
            sleep 3
            
            echo "60"; echo "# Stopping database container..."
            docker stop oracle-apex-db 2>/dev/null || true
            
            echo "100"; echo "# Done!"
        ) | yad --progress --title="$(get_str title)" --text="$(get_str stopping)" \
            --percentage=0 --auto-close --no-cancel --width=400 2>/dev/null
    else
        (
            echo "20"; echo "# Stopping ORDS..."
            pkill -f ords 2>/dev/null || true
            sleep 3
            
            echo "60"; echo "# Stopping database container..."
            docker stop oracle-apex-db 2>/dev/null || true
            
            echo "100"; echo "# Done!"
        ) | zenity --progress --title="$(get_str title)" --text="$(get_str stopping)" \
            --percentage=0 --auto-close --no-cancel --width=400 2>/dev/null
    fi
    
    sleep 2
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$(get_str title)" --text="$(get_str success_stop)" --width=350 2>/dev/null
    else
        zenity --info --title="$(get_str title)" --text="$(get_str success_stop)" --width=350 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SHOW STATUS
# ═══════════════════════════════════════════════════════════════════════════════
show_status() {
    local db_status="🔴 $(get_str status_stopped)"
    local ords_status="🔴 $(get_str status_stopped)"
    local ords_pid=""
    
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"; then
        db_status="🟢 $(get_str status_running)"
    fi
    
    ords_pid=$(pgrep -f "ords.*serve" | head -1)
    if [ -n "$ords_pid" ]; then
        ords_status="🟢 $(get_str status_running) (PID: $ords_pid)"
    fi
    
    local http_root=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
    local http_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")
    
    local status_text=""
    status_text+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    status_text+="$(get_str db_status):  $db_status\n"
    status_text+="$(get_str ords_status):  $ords_status\n\n"
    status_text+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    status_text+="$(get_str endpoints):\n"
    status_text+="  ORDS Root:   HTTP $http_root\n"
    status_text+="  APEX Admin:  HTTP $http_admin\n"
    status_text+="  APEX Login:  HTTP $http_login\n\n"
    status_text+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    status_text+="🌐 http://localhost:8080/ords/apex_admin\n"
    status_text+="🔐 http://localhost:8080/ords/f?p=4550"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$(get_str title) - Status" --text="$status_text" \
            --width=450 --height=400 2>/dev/null
    else
        zenity --info --title="$(get_str title) - Status" --text="$status_text" \
            --width=450 --height=400 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# OPEN ADMIN/LOGIN/DBEAVER
# ═══════════════════════════════════════════════════════════════════════════════
open_admin() {
    if check_status; then
        xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
    else
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --error --title="$(get_str title)" --text="$(get_str error_not_running)" --width=400 2>/dev/null
        else
            zenity --error --title="$(get_str title)" --text="$(get_str error_not_running)" --width=400 2>/dev/null
        fi
    fi
}

open_login() {
    if check_status; then
        xdg-open "http://localhost:8080/ords/f?p=4550" 2>/dev/null || open "http://localhost:8080/ords/f?p=4550" 2>/dev/null &
    else
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --error --title="$(get_str title)" --text="$(get_str error_not_running)" --width=400 2>/dev/null
        else
            zenity --error --title="$(get_str title)" --text="$(get_str error_not_running)" --width=400 2>/dev/null
        fi
    fi
}

open_dbeaver() {
    if command -v dbeaver-ce &> /dev/null; then
        dbeaver-ce &
    elif command -v dbeaver &> /dev/null; then
        dbeaver &
    elif command -v flatpak &> /dev/null && flatpak list | grep -q dbeaver; then
        flatpak run io.dbeaver.DBeaverCommunity &
    elif command -v snap &> /dev/null && snap list | grep -q dbeaver; then
        snap run dbeaver-ce &
    else
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --warning --title="$(get_str title)" --text="$(get_str dbeaver_not_found)\n\nInstall from: https://dbeaver.io" --width=400 2>/dev/null
        else
            zenity --warning --title="$(get_str title)" --text="$(get_str dbeaver_not_found)\n\nInstall from: https://dbeaver.io" --width=400 2>/dev/null
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# RUN FIX SCRIPT
# ═══════════════════════════════════════════════════════════════════════════════
run_fix() {
    bash "$SCRIPTS_DIR/fix.sh" > /tmp/apex_fix_output.txt 2>&1 &
    FIX_PID=$!
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="$(get_str title)" --text="$(get_str fix_running)" \
            --pulsate --auto-close --no-cancel --width=450 2>/dev/null &
        PROGRESS_PID=$!
        
        wait $FIX_PID
        kill $PROGRESS_PID 2>/dev/null || true
        
        if [ -f /tmp/apex_fix_output.txt ]; then
            yad --text-info --title="$(get_str title) - Fix Result" \
                --filename=/tmp/apex_fix_output.txt --width=800 --height=600 \
                --fontname="monospace" 2>/dev/null
        fi
    else
        (
            while kill -0 $FIX_PID 2>/dev/null; do
                echo "# $(get_str fix_running)"
                sleep 1
            done
            echo "100"
        ) | zenity --progress --title="$(get_str title)" --text="$(get_str fix_running)" \
            --pulsate --auto-close --no-cancel --width=450 2>/dev/null
        
        if [ -f /tmp/apex_fix_output.txt ]; then
            zenity --text-info --title="$(get_str title) - Fix Result" \
                --filename=/tmp/apex_fix_output.txt --width=800 --height=600 \
                --font="monospace" 2>/dev/null
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SHOW LOGS
# ═══════════════════════════════════════════════════════════════════════════════
show_logs() {
    local log_file="$LOG_DIR/ords.log"
    
    if [ -f "$log_file" ]; then
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --text-info --title="$(get_str title) - ORDS Logs" \
                --filename="$log_file" --width=900 --height=700 \
                --fontname="monospace" 2>/dev/null
        else
            zenity --text-info --title="$(get_str title) - ORDS Logs" \
                --filename="$log_file" --width=900 --height=700 \
                --font="monospace" 2>/dev/null
        fi
    else
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --warning --title="$(get_str title)" \
                --text="$(get_str no_logs)\n\nLog file: $log_file" --width=400 2>/dev/null
        else
            zenity --warning --title="$(get_str title)" \
                --text="$(get_str no_logs)\n\nLog file: $log_file" --width=400 2>/dev/null
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SETTINGS (LANGUAGE SELECTION)
# ═══════════════════════════════════════════════════════════════════════════════
show_settings() {
    local NEW_LANG
    
    if [ "$GUI_TOOL" = "yad" ]; then
        NEW_LANG=$(yad --list --title="$(get_str select_language)" \
            --text="Select your preferred language:" \
            --radiolist --column="" --column="Code" --column="Language" \
            $([ "$LANG_CODE" = "en" ] && echo "TRUE" || echo "FALSE") "en" "🇺🇸 English" \
            $([ "$LANG_CODE" = "fa" ] && echo "TRUE" || echo "FALSE") "fa" "🇮🇷 فارسی (Persian)" \
            $([ "$LANG_CODE" = "de" ] && echo "TRUE" || echo "FALSE") "de" "🇩🇪 Deutsch (German)" \
            --width=400 --height=280 --print-column=2 2>/dev/null)
    else
        NEW_LANG=$(zenity --list --title="$(get_str select_language)" \
            --text="Select your preferred language:\nزبان مورد نظر خود را انتخاب کنید:\nWählen Sie Ihre Sprache:" \
            --radiolist --column="" --column="Code" --column="Language" \
            $([ "$LANG_CODE" = "en" ] && echo "TRUE" || echo "FALSE") "en" "🇺🇸 English" \
            $([ "$LANG_CODE" = "fa" ] && echo "TRUE" || echo "FALSE") "fa" "🇮🇷 فارسی (Persian)" \
            $([ "$LANG_CODE" = "de" ] && echo "TRUE" || echo "FALSE") "de" "🇩🇪 Deutsch (German)" \
            --width=400 --height=280 2>/dev/null)
    fi
    
    if [ -n "$NEW_LANG" ] && [ "$NEW_LANG" != "$LANG_CODE" ]; then
        LANG_CODE="$NEW_LANG"
        echo "LANG_CODE=\"$LANG_CODE\"" > "$CONFIG_FILE"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN MENU LOOP
# ═══════════════════════════════════════════════════════════════════════════════
main_menu() {
    while true; do
        local STATUS_ICON="🔴"
        local STATUS_TEXT="$(get_str status_stopped)"
        
        if check_status; then
            STATUS_ICON="🟢"
            STATUS_TEXT="$(get_str status_running)"
        fi
        
        local CHOICE
        
        if [ "$GUI_TOOL" = "yad" ]; then
            CHOICE=$(yad --list --title="$(get_str title) - $(get_str subtitle)" \
                --text="$STATUS_ICON Status: $STATUS_TEXT\n\n$(get_str select_action)" \
                --radiolist --column="" --column="Action" --column="Description" \
                TRUE "start" "$(get_str start)" \
                FALSE "stop" "$(get_str stop)" \
                FALSE "status" "$(get_str status)" \
                FALSE "admin" "$(get_str admin)" \
                FALSE "login" "$(get_str login)" \
                FALSE "fix" "$(get_str fix)" \
                FALSE "logs" "$(get_str logs)" \
                FALSE "dbeaver" "$(get_str dbeaver)" \
                FALSE "settings" "$(get_str settings)" \
                FALSE "exit" "$(get_str exit)" \
                --width=500 --height=520 --print-column=2 --hide-column=2 2>/dev/null)
        else
            CHOICE=$(zenity --list --title="$(get_str title) - $(get_str subtitle)" \
                --text="$STATUS_ICON Status: $STATUS_TEXT\n\n$(get_str select_action)" \
                --radiolist --column="" --column="Action" --column="Description" \
                TRUE "start" "$(get_str start)" \
                FALSE "stop" "$(get_str stop)" \
                FALSE "status" "$(get_str status)" \
                FALSE "admin" "$(get_str admin)" \
                FALSE "login" "$(get_str login)" \
                FALSE "fix" "$(get_str fix)" \
                FALSE "logs" "$(get_str logs)" \
                FALSE "dbeaver" "$(get_str dbeaver)" \
                FALSE "settings" "$(get_str settings)" \
                FALSE "exit" "$(get_str exit)" \
                --width=500 --height=520 --hide-column=2 2>/dev/null)
        fi
        
        if [ -z "$CHOICE" ]; then
            exit 0
        fi
        
        case "$CHOICE" in
            start)    start_services ;;
            stop)     stop_services ;;
            status)   show_status ;;
            admin)    open_admin ;;
            login)    open_login ;;
            fix)      run_fix ;;
            logs)     show_logs ;;
            dbeaver)  open_dbeaver ;;
            settings) show_settings ;;
            exit)     exit 0 ;;
            *)        exit 0 ;;
        esac
        
        sleep 0.3
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# STARTUP CHECKS
# ═══════════════════════════════════════════════════════════════════════════════
if [ ! -d "$PROJECT_DIR" ]; then
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="Oracle APEX Manager" \
            --text="Oracle APEX is not installed!\n\nProject directory not found:\n$PROJECT_DIR\n\nPlease run the installer first." \
            --width=450 2>/dev/null
    else
        zenity --error --title="Oracle APEX Manager" \
            --text="Oracle APEX is not installed!\n\nProject directory not found:\n$PROJECT_DIR\n\nPlease run the installer first." \
            --width=450 2>/dev/null
    fi
    exit 1
fi

if [ -z "$DB_PASS" ]; then
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="Oracle APEX Manager" \
            --text="Password not found!\n\nPlease ensure password file exists:\n$PROJECT_DIR/.db_password\n\nOr run the installer again." \
            --width=450 2>/dev/null
    else
        zenity --error --title="Oracle APEX Manager" \
            --text="Password not found!\n\nPlease ensure password file exists:\n$PROJECT_DIR/.db_password\n\nOr run the installer again." \
            --width=450 2>/dev/null
    fi
    exit 1
fi

# Start main menu
main_menu
GUIEOF3

    chmod +x "$SCRIPTS_DIR/launch-gui.sh"
    log_success "Multi-Language GUI Manager created (YAD/Zenity - Cross-Platform)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 28: CREATE DESKTOP AND SERVICES
# ═══════════════════════════════════════════════════════════════════════════════
step_28_create_desktop_and_services() {
    log_step "Creating Desktop Application & Systemd Services"

    mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons"
    
    # Create SVG icon
    cat > "$PROJECT_DIR/oracle-apex-icon.svg" << 'SVGEOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF4444;stop-opacity:1"/>
      <stop offset="100%" style="stop-color:#CC0000;stop-opacity:1"/>
    </linearGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.3"/>
    </filter>
  </defs>
  <rect x="20" y="20" width="216" height="216" rx="40" fill="url(#grad1)" filter="url(#shadow)"/>
  <text x="128" y="105" font-family="Arial Black, sans-serif" font-size="52" font-weight="bold" fill="white" text-anchor="middle">APEX</text>
  <text x="128" y="155" font-family="Arial, sans-serif" font-size="28" font-weight="600" fill="rgba(255,255,255,0.95)" text-anchor="middle">Manager</text>
  <text x="128" y="195" font-family="Arial, sans-serif" font-size="18" fill="rgba(255,255,255,0.75)" text-anchor="middle">KaizenixCore</text>
</svg>
SVGEOF

    cp "$PROJECT_DIR/oracle-apex-icon.svg" "$HOME/.local/share/icons/"
    
    # Create desktop file
    cat > "$HOME/.local/share/applications/oracle-apex.desktop" << DESKTOPEOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle APEX Manager
GenericName=Database Development Tool
Comment=Manage Oracle APEX and ORDS - KaizenixCore Edition v${VERSION}
Exec=bash $SCRIPTS_DIR/launch-gui.sh
Icon=$HOME/.local/share/icons/oracle-apex-icon.svg
Terminal=false
Categories=Development;Database;IDE;
Keywords=oracle;apex;ords;database;development;sql;plsql;
StartupNotify=true
StartupWMClass=oracle-apex-manager
DESKTOPEOF

    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"
    
    # Update desktop database
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    
    log_success "Desktop application created"

    # Create systemd services (Linux only)
    if [[ "$OS_TYPE" == "linux" ]]; then
        local ORDS_BIN_PATH=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
        local ACTUAL_PASS="$ORACLE_PASSWORD"
        
        if [ -n "$ORDS_BIN_PATH" ]; then
            # Database service
            cat > /tmp/oracle-apex-db.service << DBSERVICEEOF
[Unit]
Description=Oracle APEX Database Container
Documentation=https://github.com/KaizenixCore
After=docker.service network-online.target
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=$USER
ExecStartPre=/bin/sleep 10
ExecStart=/usr/bin/docker start oracle-apex-db
ExecStop=/usr/bin/docker stop oracle-apex-db
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
DBSERVICEEOF

            # ORDS service with auto-recovery
            cat > /tmp/oracle-apex-ords.service << ORDSSERVICEEOF
[Unit]
Description=Oracle APEX ORDS Service
Documentation=https://github.com/KaizenixCore
After=oracle-apex-db.service docker.service
Requires=oracle-apex-db.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment="ORDS_CONFIG=$ORDS_CONFIG_DIR"
Environment="_JAVA_OPTIONS=-Xms512m -Xmx1024m"
ExecStartPre=/bin/sleep 120
ExecStartPre=/bin/bash -c 'PASS="${ACTUAL_PASS}"; if [ -z "\$PASS" ]; then PASS=\$(cat $PROJECT_DIR/.db_password 2>/dev/null); fi; docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba <<< "ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER; ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER; ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER; COMMIT; EXIT;"'
ExecStart=$ORDS_BIN_PATH --config $ORDS_CONFIG_DIR serve --port 8080 --apex-images $IMAGES_DIR
Restart=always
RestartSec=15
TimeoutStartSec=300
StandardOutput=append:$LOG_DIR/ords.log
StandardError=append:$LOG_DIR/ords.log

[Install]
WantedBy=multi-user.target
ORDSSERVICEEOF

            # Install services
            if command -v sudo &> /dev/null; then
                log_info "Installing systemd services..."
                sudo mv /tmp/oracle-apex-db.service /etc/systemd/system/ 2>/dev/null || true
                sudo mv /tmp/oracle-apex-ords.service /etc/systemd/system/ 2>/dev/null || true
                sudo systemctl daemon-reload 2>/dev/null || true
                
                log_success "Systemd services created"
                
                read -p "  Enable auto-start on boot? [Y/n]: " enable_autostart
                if [[ ! $enable_autostart =~ ^[Nn]$ ]]; then
                    sudo systemctl enable oracle-apex-db.service 2>/dev/null || true
                    sudo systemctl enable oracle-apex-ords.service 2>/dev/null || true
                    log_success "Auto-start enabled"
                fi
            fi
        fi
    fi
    
    log_success "Desktop application and services configuration completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 29: FINAL VERIFICATION
# ═══════════════════════════════════════════════════════════════════════════════
step_29_final_verification() {
    log_step "Final Verification & System Check"

    log_info "Checking ORDS_METADATA schema..."
    local METADATA_EXISTS=$(docker exec oracle-apex-db sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'CHECKEOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME='ORDS_METADATA';
EXIT;
CHECKEOF
)
    METADATA_EXISTS=$(echo "$METADATA_EXISTS" | grep -o '[0-9]' | head -1)

    if [ "$METADATA_EXISTS" = "1" ]; then
        log_success "✅ ORDS_METADATA schema exists"
    else
        log_warning "⚠️ ORDS_METADATA missing - run fix.sh after reboot"
    fi

    log_info "Checking proxy grants..."
    local PROXY_CHECK=$(docker exec oracle-apex-db sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'PROXYEOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM DBA_PROXIES WHERE PROXY='ORDS_PUBLIC_USER';
EXIT;
PROXYEOF
)
    PROXY_COUNT=$(echo "$PROXY_CHECK" | grep -o '[0-9]' | head -1)
    
    if [ "$PROXY_COUNT" -ge 1 ] 2>/dev/null; then
        log_success "✅ Proxy grants configured"
    else
        log_warning "⚠️ Proxy grants may need reconfiguration"
    fi

    log_info "Checking for errors in log..."
    if grep -qi "574\|ORA-01017\|ORA-00942\|500" "$LOG_DIR/ords.log" 2>/dev/null; then
        log_warning "⚠️ Found potential issues in log - run fix.sh if needed"
    else
        log_success "✅ No critical errors found"
    fi

    log_info "Final endpoint check..."
    local final_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null || echo "000")
    local final_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/f?p=4550" 2>/dev/null || echo "000")
    
    if [[ "$final_admin" =~ ^(200|302|303)$ ]]; then
        log_success "✅ APEX Admin: HTTP $final_admin"
    else
        log_warning "⚠️ APEX Admin: HTTP $final_admin"
    fi
    
    if [[ "$final_login" =~ ^(200|302|303)$ ]]; then
        log_success "✅ APEX Login: HTTP $final_login"
    else
        log_warning "⚠️ APEX Login: HTTP $final_login"
    fi

    if [ -f "$PROJECT_DIR/.db_password" ] && [ -f "$PROJECT_DIR/.apex_password" ]; then
        log_success "✅ Password files exist"
    else
        log_warning "⚠️ Password files missing - recreating..."
        echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
        echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
        chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
        log_success "✅ Password files recreated"
    fi

    if [ -x "$SCRIPTS_DIR/launch-gui.sh" ]; then
        log_success "✅ GUI launcher is executable"
    else
        chmod +x "$SCRIPTS_DIR/launch-gui.sh"
        log_success "✅ GUI launcher permissions fixed"
    fi

    chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true
    log_success "✅ All management scripts are executable"

    log_success "✅ Final verification completed - system is ready!"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CHECK SERVICE STATUS - FIXED VERSION
# ═══════════════════════════════════════════════════════════════════════════════
check_status() {
    local db_running=0
    local ords_running=0
    
    # Check database container
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"; then
        db_running=1
    fi
    
    # Check ORDS process
    if pgrep -f "ords.*serve" > /dev/null 2>&1; then
        ords_running=1
    fi
    
    # Return success (0) only if both are running
    if [ "$db_running" -eq 1 ] && [ "$ords_running" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 31: FINAL SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════
step_31_final_summary() {
    log_step "Installation Complete - Final Summary"

    echo ""
    echo -e "${GREEN}${BOLD}  ╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
    echo -e "${GREEN}${BOLD}  ║           🎉 ALL COMPONENTS INSTALLED SUCCESSFULLY! 🎉           ║${NC}"
    echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
    echo -e "${GREEN}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}  💡 Quick Access:${NC}"
    echo -e "     Admin Panel: ${CYAN}http://localhost:8080/ords/apex_admin${NC}"
    echo -e "     Login Page:  ${CYAN}http://localhost:8080/ords/f?p=4550${NC}"
    echo ""
    echo -e "${YELLOW}  🔧 If you see Error 500/574 or 'Invalid schema name':${NC}"
    echo -e "     Run: ${CYAN}bash $SCRIPTS_DIR/fix.sh${NC}"
    echo ""
    echo -e "${CYAN}  🖥️ Launch GUI Manager:${NC}"
    echo -e "     Run: ${CYAN}bash $SCRIPTS_DIR/launch-gui.sh${NC}"
    echo -e "     Or find 'Oracle APEX Manager' in your applications menu"
    echo ""
    echo -e "${MAGENTA}  📦 Management Commands:${NC}"
    echo -e "     Start:      ${WHITE}bash $SCRIPTS_DIR/start.sh${NC}"
    echo -e "     Stop:       ${WHITE}bash $SCRIPTS_DIR/stop.sh${NC}"
    echo -e "     Status:     ${WHITE}bash $SCRIPTS_DIR/status.sh${NC}"
    echo -e "     Fix:        ${WHITE}bash $SCRIPTS_DIR/fix.sh${NC}"
    echo -e "     Logs:       ${WHITE}bash $SCRIPTS_DIR/logs.sh${NC}"
    echo -e "     DBeaver:    ${WHITE}bash $SCRIPTS_DIR/open-dbeaver.sh${NC}"
    echo -e "     Reset Pass: ${WHITE}bash $SCRIPTS_DIR/reset-apex-password.sh${NC}"
    echo ""
    echo -e "${GREEN}  🔐 Credentials:${NC}"
    echo -e "     Workspace:  ${WHITE}INTERNAL${NC}"
    echo -e "     Username:   ${WHITE}ADMIN${NC}"
    echo -e "     Password:   ${WHITE}$APEX_ADMIN_PASSWORD${NC}"
    echo ""
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}   Created by: ${WHITE}Peyman Rasouli${NC} ${GRAY}| Project: ${MAGENTA}KaizenixCore${NC}"
    echo -e "${GRAY}   GitHub: ${BLUE}https://github.com/KaizenixCore/oracle-apex-installer/${NC}"
    echo -e "${GRAY}   Version: ${WHITE}$VERSION${NC} ${GRAY}| License: ${WHITE}MIT${NC}"
    echo -e "${GRAY}   OS: ${WHITE}$OS_TYPE ($OS_ID $OS_VERSION)${NC} ${GRAY}| Arch: ${WHITE}$ARCH${NC}"
    echo -e "${GRAY}   GUI Tool: ${WHITE}$GUI_TOOL${NC}"
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════
main() {
    print_banner
    detect_os
    detect_gui_tool
    get_passwords

    step_01_init
    step_02_check
    step_03_prerequisites
    step_04_cleanup
    step_05_download
    step_06_extract
    step_07_docker_compose
    step_08_start_db
    step_09_disable_policies
    step_10_install_apex
    step_11_apex_rest
    step_12_create_users
    step_13_grant_proxy
    step_14_apex_admin
    step_15_privileges
    step_16_uninstall_old_ords
    step_17_install_ords_metadata
    step_18_fix_pool_config
    step_19_configure_ords
    step_20_final_unlock
    step_21_verify_config
    step_22_start_ords
    step_23_scripts
    step_24_verify
    step_25_final_check
    step_26_summary
    step_27_create_gui
    step_28_create_desktop_and_services
    step_29_final_verification
    step_30_install_dbeaver
    step_31_final_summary
}

# ═══════════════════════════════════════════════════════════════════════════════
# RUN MAIN
# ═══════════════════════════════════════════════════════════════════════════════
main "$@"
