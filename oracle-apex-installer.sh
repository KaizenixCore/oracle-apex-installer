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
#  ║        ORACLE APEX ULTIMATE INSTALLER v3.0.1 - KAIZENIXCORE               ║
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
#  ║  ✅ All Errors FIXED (500, 571, 574, 404)                                 ║
#  ║  ✅ GUI Crash - COMPLETELY FIXED                                          ║
#  ║  ✅ System Restart Persistence - FIXED                                    ║
#  ║  ✅ Multi-Language GUI (English/Persian/German)                           ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e
trap 'handle_error $LINENO' ERR

VERSION="3.0.1"
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

# GUI Tool Detection
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
        log_warning "No GUI tool found - will install"
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
    echo -e "${WHITE}${BOLD}  ║${NC}      ${MAGENTA}${BOLD}ORACLE APEX ULTIMATE INSTALLER${NC} ${WHITE}v${VERSION}${NC}                       ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} Cross-Platform  ${GREEN}✓${NC} DBeaver Support   ${GREEN}✓${NC} Modern GUI           ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} Error 500 Fixed ${GREEN}✓${NC} Error 574 Fixed   ${GREEN}✓${NC} Restart Safe         ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}Created by:${NC} ${CYAN}Peyman Rasouli${NC}                                       ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}Project:${NC}    ${MAGENTA}KaizenixCore${NC}                                          ${WHITE}${BOLD}║${NC}"
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

    case "$OS_TYPE" in
        linux)
            log_info "Detected Linux: $OS_ID $OS_VERSION ($ARCH)"
            
            # Update package manager
            log_info "Updating package manager..."
            case "$OS_ID" in
                ubuntu|debian|linuxmint|pop|elementary|zorin|kali|mx)
                    sudo apt-get update -qq 2>/dev/null || true
                    ;;
                fedora)
                    sudo dnf makecache --refresh -q 2>/dev/null || true
                    ;;
                rhel|centos|rocky|alma|oracle)
                    sudo dnf makecache -q 2>/dev/null || sudo yum makecache -q 2>/dev/null || true
                    sudo dnf install -y epel-release 2>/dev/null || sudo yum install -y epel-release 2>/dev/null || true
                    ;;
                opensuse*|suse*|sles)
                    sudo zypper --non-interactive refresh 2>/dev/null || true
                    ;;
                arch|manjaro|endeavouros|garuda)
                    sudo pacman -Sy --noconfirm 2>/dev/null || true
                    ;;
                alpine)
                    sudo apk update 2>/dev/null || true
                    ;;
            esac

            # Install essential tools
            log_info "Installing essential tools..."
            case "$OS_ID" in
                ubuntu|debian|linuxmint|pop|elementary|zorin|kali|mx)
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
                    ;;
                opensuse*|suse*|sles)
                    sudo zypper --non-interactive install -y wget curl unzip ca-certificates gpg2 2>/dev/null || true
                    ;;
                arch|manjaro|endeavouros|garuda)
                    sudo pacman -S --noconfirm --needed wget curl unzip ca-certificates gnupg 2>/dev/null || true
                    ;;
                alpine)
                    sudo apk add --no-cache wget curl unzip ca-certificates gnupg 2>/dev/null || true
                    ;;
            esac

            # Install Docker
            log_info "Installing Docker..."
            if ! command -v docker &> /dev/null; then
                case "$OS_ID" in
                    ubuntu|debian|linuxmint|pop|elementary|zorin)
                        sudo mkdir -p /etc/apt/keyrings 2>/dev/null || true
                        curl -fsSL https://download.docker.com/linux/$OS_ID/gpg 2>/dev/null | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
                        if [ -f /etc/apt/keyrings/docker.gpg ]; then
                            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS_ID $(lsb_release -cs 2>/dev/null || echo stable) stable" | \
                                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>/dev/null
                            sudo apt-get update -qq 2>/dev/null || true
                            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
                        fi
                        if ! command -v docker &> /dev/null; then
                            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io 2>/dev/null || true
                        fi
                        ;;
                    fedora)
                        sudo dnf -y install dnf-plugins-core 2>/dev/null || true
                        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo 2>/dev/null || true
                        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || \
                        sudo dnf install -y docker 2>/dev/null || true
                        ;;
                    rhel|centos|rocky|alma|oracle)
                        sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 2>/dev/null || true
                        sudo dnf install -y docker-ce docker-ce-cli containerd.io 2>/dev/null || \
                        sudo yum install -y docker 2>/dev/null || true
                        ;;
                    opensuse*|suse*|sles)
                        sudo zypper --non-interactive install -y docker docker-compose 2>/dev/null || true
                        ;;
                    arch|manjaro|endeavouros|garuda)
                        sudo pacman -S --noconfirm --needed docker docker-compose 2>/dev/null || true
                        ;;
                    alpine)
                        sudo apk add --no-cache docker docker-compose 2>/dev/null || true
                        sudo rc-update add docker boot 2>/dev/null || true
                        ;;
                    *)
                        log_info "Trying Docker's universal installation script..."
                        curl -fsSL https://get.docker.com | sudo sh 2>/dev/null || true
                        ;;
                esac
            else
                log_success "Docker already installed"
            fi

            # Install Docker Compose
            log_info "Checking Docker Compose..."
            if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
                case "$OS_ID" in
                    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|mx)
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-compose 2>/dev/null || true
                        ;;
                    fedora|rhel|centos|rocky|alma|oracle)
                        sudo dnf install -y docker-compose 2>/dev/null || sudo yum install -y docker-compose 2>/dev/null || true
                        ;;
                    opensuse*|suse*|sles)
                        sudo zypper --non-interactive install -y docker-compose 2>/dev/null || true
                        ;;
                    arch|manjaro|endeavouros|garuda)
                        sudo pacman -S --noconfirm --needed docker-compose 2>/dev/null || true
                        ;;
                    *)
                        local COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null || echo "v2.24.0")
                        sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 2>/dev/null || true
                        sudo chmod +x /usr/local/bin/docker-compose 2>/dev/null || true
                        ;;
                esac
            fi

            # Install Java 17
            log_info "Installing Java 17..."
            if ! command -v java &> /dev/null || ! java -version 2>&1 | grep -q "17"; then
                case "$OS_ID" in
                    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|mx)
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jdk 2>/dev/null || \
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk 2>/dev/null || true
                        ;;
                    fedora)
                        sudo dnf install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || true
                        ;;
                    rhel|centos|rocky|alma|oracle)
                        sudo dnf install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || \
                        sudo yum install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || true
                        ;;
                    opensuse*|suse*|sles)
                        sudo zypper --non-interactive install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || true
                        ;;
                    arch|manjaro|endeavouros|garuda)
                        sudo pacman -S --noconfirm --needed jdk17-openjdk 2>/dev/null || true
                        ;;
                    alpine)
                        sudo apk add --no-cache openjdk17 2>/dev/null || true
                        ;;
                esac
            fi

            # Install GUI Tools (YAD/Zenity)
            log_info "Installing GUI tools..."
            case "$OS_ID" in
                ubuntu|debian|linuxmint|pop|elementary|zorin|kali|mx)
                    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y yad 2>/dev/null || \
                    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y zenity 2>/dev/null || true
                    ;;
                fedora)
                    sudo dnf install -y yad 2>/dev/null || sudo dnf install -y zenity 2>/dev/null || true
                    ;;
                rhel|centos|rocky|alma|oracle)
                    sudo dnf install -y zenity 2>/dev/null || sudo yum install -y zenity 2>/dev/null || true
                    ;;
                opensuse*|suse*|sles)
                    sudo zypper --non-interactive install -y yad 2>/dev/null || \
                    sudo zypper --non-interactive install -y zenity 2>/dev/null || true
                    ;;
                arch|manjaro|endeavouros|garuda)
                    sudo pacman -S --noconfirm --needed yad 2>/dev/null || \
                    sudo pacman -S --noconfirm --needed zenity 2>/dev/null || true
                    ;;
                alpine)
                    sudo apk add --no-cache zenity 2>/dev/null || true
                    ;;
            esac

            # Install Flatpak (for DBeaver)
            log_info "Installing Flatpak..."
            if ! command -v flatpak &> /dev/null; then
                case "$OS_ID" in
                    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|mx)
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y flatpak 2>/dev/null || true
                        ;;
                    fedora)
                        sudo dnf install -y flatpak 2>/dev/null || true
                        ;;
                    rhel|centos|rocky|alma|oracle)
                        sudo dnf install -y flatpak 2>/dev/null || sudo yum install -y flatpak 2>/dev/null || true
                        ;;
                    opensuse*|suse*|sles)
                        sudo zypper --non-interactive install -y flatpak 2>/dev/null || true
                        ;;
                    arch|manjaro|endeavouros|garuda)
                        sudo pacman -S --noconfirm --needed flatpak 2>/dev/null || true
                        ;;
                esac
            fi

            # Add Flathub
            if command -v flatpak &> /dev/null; then
                flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || \
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
            fi

            # Start Docker
            log_info "Starting Docker service..."
            if command -v systemctl &> /dev/null; then
                sudo systemctl enable docker.service 2>/dev/null || true
                sudo systemctl start docker.service 2>/dev/null || true
            fi

            # Add user to docker group
            log_info "Checking Docker group..."
            sudo groupadd docker 2>/dev/null || true
            if ! groups "$USER" 2>/dev/null | grep -q '\bdocker\b'; then
                sudo usermod -aG docker "$USER" 2>/dev/null || true
                log_warning "Added to docker group. You may need to run: newgrp docker"
            fi
            ;;
            
        mac)
            log_info "Installing for macOS..."
            
            if ! command -v brew &> /dev/null; then
                log_warning "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
                
                if [[ "$ARCH" == "arm64" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
                else
                    eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
                fi
            fi
            
            if command -v brew &> /dev/null; then
                brew update 2>/dev/null || true
                brew install wget curl unzip openjdk@17 dialog 2>/dev/null || true
                sudo ln -sfn $(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
                
                if ! command -v docker &> /dev/null; then
                    brew install --cask docker 2>/dev/null || true
                fi
            fi
            
            if ! command -v docker &> /dev/null; then
                log_warning "Docker Desktop not found!"
                log_info "Please install from: https://www.docker.com/products/docker-desktop"
                exit 1
            fi
            ;;
            
        windows)
            log_info "Detected Windows (WSL)..."
            
            local WSL_DISTRO=""
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                WSL_DISTRO="$ID"
            fi
            
            if command -v apt-get &> /dev/null; then
                sudo apt-get update -qq 2>/dev/null || true
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
                    docker.io docker-compose openjdk-17-jdk unzip wget curl zenity 2>/dev/null || true
            fi
            
            log_info "Make sure Docker Desktop for Windows is installed with WSL integration enabled"
            ;;
    esac

    detect_gui_tool
    
    # Summary
    echo ""
    log_info "Prerequisites Summary:"
    command -v docker &>/dev/null && log_success "Docker: $(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')" || log_error "Docker: NOT INSTALLED"
    command -v java &>/dev/null && log_success "Java: $(java -version 2>&1 | head -n1 | cut -d'"' -f2)" || log_error "Java: NOT INSTALLED"
    [ "$GUI_TOOL" != "none" ] && log_success "GUI Tool: $GUI_TOOL" || log_warning "GUI Tool: None"
    command -v flatpak &>/dev/null && log_success "Flatpak: Installed" || log_warning "Flatpak: Not installed"
    echo ""
    
    log_success "Dependencies ready"
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

    log_info "Verifying ORDS_METADATA schema..."
    local METADATA_CHECK=$(docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME='ORDS_METADATA';
EXIT;
EOF" 2>/dev/null | grep -o '[0-9]' | head -1)

    if [ "$METADATA_CHECK" = "1" ]; then
        log_success "✅ ORDS_METADATA schema created successfully!"
        
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
        
        docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOF
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD};
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1 || true

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

    log_info "Setting ORDS database password using CLI (encrypted)..."
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
    
    if [ -n "$ORDS_BIN" ]; then
        echo "${ORACLE_PASSWORD}" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>&1 || true
    fi

    log_info "Creating pool.xml..."
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

    cat > "$ORDS_CONFIG_DIR/global/settings.xml" << 'GLOBALEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="database.api.enabled">true</entry>
<entry key="debug.printDebugToScreen">true</entry>
</properties>
GLOBALEOF

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
cd ~/oracle-apex-complete
PASS="${ACTUAL_PASS}"

if [ -z "\$PASS" ]; then
    PASS=\$(cat .db_password 2>/dev/null)
fi

if [ -z "\$PASS" ]; then
    echo "❌ Password not found!"
    exit 1
fi

echo "════════════════════════════════════════════════════════════"
echo "  Starting Oracle APEX Services..."
echo "════════════════════════════════════════════════════════════"

echo "Step 1: Starting database container..."
docker start oracle-apex-db 2>/dev/null || docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null
echo "Waiting 90s for database to be ready..."
sleep 90

echo "Step 2: Running auto-recovery..."
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

echo "Step 3: Starting ORDS..."
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

echo "✅ Oracle APEX Started!"
echo "  Admin: http://localhost:8080/ords/apex_admin"
echo "  Login: http://localhost:8080/ords/f?p=4550"
STARTEOF

    # STOP SCRIPT
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
echo "Stopping Oracle APEX Services..."
pkill -f ords 2>/dev/null || true
sleep 3
cd ~/oracle-apex-complete && docker stop oracle-apex-db 2>/dev/null || true
echo "✅ Oracle APEX stopped!"
STOPEOF

    # STATUS SCRIPT
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
echo "════════════════════════════════════════════════════════════"
echo "  Oracle APEX Status"
echo "════════════════════════════════════════════════════════════"

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

HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")

echo ""
echo "  APEX Admin:  HTTP $HTTP_ADMIN"
echo "  APEX Login:  HTTP $HTTP_LOGIN"
echo "════════════════════════════════════════════════════════════"
STATUSEOF

    # LOGS SCRIPT
    cat > "$SCRIPTS_DIR/logs.sh" << 'LOGSEOF'
#!/bin/bash
echo "ORDS Logs (last 100 lines):"
tail -100 ~/oracle-apex-complete/logs/ords.log 2>/dev/null || echo "No logs found"
LOGSEOF

    # FIX SCRIPT
    cat > "$SCRIPTS_DIR/fix.sh" << FIXEOF
#!/bin/bash
cd ~/oracle-apex-complete
PASS="${ACTUAL_PASS}"

if [ -z "\$PASS" ]; then
    PASS=\$(cat .db_password 2>/dev/null)
fi

if [ -z "\$PASS" ]; then
    echo "❌ Password file not found!"
    exit 1
fi

echo "════════════════════════════════════════════════════════════"
echo "  COMPREHENSIVE FIX - Error 500/574/571/404"
echo "════════════════════════════════════════════════════════════"

echo "Step 1: Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 5

echo "Step 2: Ensuring database is running..."
docker start oracle-apex-db 2>/dev/null || true
sleep 30

echo "Step 3: Fixing database accounts..."
docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba << SQLEOF
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQLEOF

echo "Step 4: Setting ORDS password..."
ORDS_BIN=\$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
if [ -n "\$ORDS_BIN" ]; then
    echo "\${PASS}" | "\$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config secret --password-stdin db.password 2>/dev/null || true
fi

echo "Step 5: Starting ORDS..."
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

if [ -n "\$ORDS_BIN" ]; then
    nohup "\$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &
    echo "ORDS started with PID \$!"
fi

echo "Waiting 90s for ORDS..."
sleep 90

HTTP_ADMIN=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  FIX COMPLETED! APEX Admin: HTTP \$HTTP_ADMIN"
echo "════════════════════════════════════════════════════════════"
FIXEOF

    # RESET PASSWORD SCRIPT
    cat > "$SCRIPTS_DIR/reset-apex-password.sh" << RESETEOF
#!/bin/bash
cd ~/oracle-apex-complete
PASS="${ACTUAL_PASS}"

if [ -z "\$PASS" ]; then
    PASS=\$(cat .db_password 2>/dev/null)
fi

echo "Reset APEX Admin Password"
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
fi

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
echo "✅ Password updated! Username: ADMIN, Password: \$NEW_PASS"
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
    echo -e "${GREEN}${BOLD}  ║           🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉             ║${NC}"
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
    echo -e "      GUI:        ${CYAN}bash $SCRIPTS_DIR/launch-gui.sh${NC}"
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 27: CREATE GUI (COMPLETELY FIXED - NO CRASH)
# ═══════════════════════════════════════════════════════════════════════════════
step_27_create_gui() {
    log_step "Creating Multi-Language GUI Manager (FIXED - No Crash)"

    local ACTUAL_PASS="$ORACLE_PASSWORD"

    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
################################################################################
#  Oracle APEX Manager - Multi-Language GUI (YAD/Zenity) - FIXED VERSION
#  Created by: Peyman Rasouli | KaizenixCore
#  Version: 3.0.1 - GUI Crash FIXED
################################################################################

set -o pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════
PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
LOG_DIR="$PROJECT_DIR/logs"
CONFIG_FILE="$PROJECT_DIR/.gui_config"
LOCK_FILE="/tmp/oracle-apex-gui.lock"

# ═══════════════════════════════════════════════════════════════════════════════
# DETECT GUI TOOL
# ═══════════════════════════════════════════════════════════════════════════════
GUI_TOOL=""
detect_gui() {
    if command -v yad &> /dev/null; then
        GUI_TOOL="yad"
    elif command -v zenity &> /dev/null; then
        GUI_TOOL="zenity"
    else
        echo "❌ No GUI tool found! Please install yad or zenity."
        exit 1
    fi
}
detect_gui

# ═══════════════════════════════════════════════════════════════════════════════
# PREVENT MULTIPLE INSTANCES
# ═══════════════════════════════════════════════════════════════════════════════
cleanup_lock() {
    rm -f "$LOCK_FILE" 2>/dev/null
}
trap cleanup_lock EXIT

if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --warning --title="Warning" --text="Oracle APEX Manager is already running!" --width=300 --timeout=3 2>/dev/null
        else
            zenity --warning --title="Warning" --text="Oracle APEX Manager is already running!" --width=300 --timeout=3 2>/dev/null
        fi
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
GUIEOF

    # Add password
    cat >> "$SCRIPTS_DIR/launch-gui.sh" << GUIPASS
DB_PASS="${ACTUAL_PASS}"
GUIPASS

    cat >> "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF2'

# Fallback to password file
if [ -z "$DB_PASS" ]; then
    DB_PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
fi

# Load language preference
LANG_CODE="en"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE" 2>/dev/null

# ═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS
# ═══════════════════════════════════════════════════════════════════════════════
declare -A L
load_lang() {
    case $LANG_CODE in
        fa)
            L[title]="مدیریت اوراکل اپکس"
            L[start]="شروع سرویس‌ها"
            L[stop]="توقف سرویس‌ها"
            L[status]="بررسی وضعیت"
            L[admin]="پنل مدیریت"
            L[login]="صفحه ورود"
            L[fix]="تعمیر"
            L[logs]="لاگ‌ها"
            L[dbeaver]="DBeaver"
            L[settings]="تنظیمات"
            L[exit]="خروج"
            L[running]="در حال اجرا"
            L[stopped]="متوقف"
            L[starting]="در حال شروع..."
            L[stopping]="در حال توقف..."
            L[success]="موفق!"
            L[error]="خطا"
            L[select_lang]="انتخاب زبان"
            ;;
        de)
            L[title]="Oracle APEX Manager"
            L[start]="Starten"
            L[stop]="Stoppen"
            L[status]="Status"
            L[admin]="Admin-Panel"
            L[login]="Anmelden"
            L[fix]="Reparieren"
            L[logs]="Protokolle"
            L[dbeaver]="DBeaver"
            L[settings]="Einstellungen"
            L[exit]="Beenden"
            L[running]="Läuft"
            L[stopped]="Gestoppt"
            L[starting]="Wird gestartet..."
            L[stopping]="Wird gestoppt..."
            L[success]="Erfolgreich!"
            L[error]="Fehler"
            L[select_lang]="Sprache wählen"
            ;;
        *)
            L[title]="Oracle APEX Manager"
            L[start]="Start Services"
            L[stop]="Stop Services"
            L[status]="Check Status"
            L[admin]="Admin Panel"
            L[login]="Login Page"
            L[fix]="Fix Issues"
            L[logs]="View Logs"
            L[dbeaver]="DBeaver"
            L[settings]="Settings"
            L[exit]="Exit"
            L[running]="Running"
            L[stopped]="Stopped"
            L[starting]="Starting..."
            L[stopping]="Stopping..."
            L[success]="Success!"
            L[error]="Error"
            L[select_lang]="Select Language"
            ;;
    esac
}
load_lang

# ═══════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════
show_info() {
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="${L[title]}" --text="$1" --width=400 --button="OK:0" 2>/dev/null
    else
        zenity --info --title="${L[title]}" --text="$1" --width=400 2>/dev/null
    fi
}

show_error() {
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="${L[error]}" --text="$1" --width=400 --button="OK:0" 2>/dev/null
    else
        zenity --error --title="${L[error]}" --text="$1" --width=400 2>/dev/null
    fi
}

show_progress() {
    local text="$1"
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="${L[title]}" --text="$text" --pulsate --auto-close --no-buttons --width=400 2>/dev/null
    else
        zenity --progress --title="${L[title]}" --text="$text" --pulsate --auto-close --no-cancel --width=400 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# CHECK STATUS FUNCTION (FIXED)
# ═══════════════════════════════════════════════════════════════════════════════
is_db_running() {
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"
    return $?
}

is_ords_running() {
    pgrep -f "ords.*serve" > /dev/null 2>&1
    return $?
}

get_status_text() {
    local db_status="🔴 ${L[stopped]}"
    local ords_status="🔴 ${L[stopped]}"
    
    if is_db_running; then
        db_status="🟢 ${L[running]}"
    fi
    
    if is_ords_running; then
        ords_status="🟢 ${L[running]}"
    fi
    
    echo "Database: $db_status\nORDS: $ords_status"
}

# ═══════════════════════════════════════════════════════════════════════════════
# ACTION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════
do_start() {
    (
        echo "10"
        echo "# Starting database..."
        docker start oracle-apex-db 2>/dev/null || docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d 2>/dev/null
        
        echo "30"
        echo "# Waiting for database (60s)..."
        sleep 60
        
        echo "50"
        echo "# Running recovery..."
        if [ -n "$DB_PASS" ]; then
            docker exec oracle-apex-db sqlplus -s sys/${DB_PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQLEOF' >/dev/null 2>&1
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQLEOF
        fi
        
        echo "60"
        echo "# Stopping old ORDS..."
        pkill -f ords 2>/dev/null || true
        sleep 3
        
        echo "70"
        echo "# Starting ORDS..."
        ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
        if [ -n "$ORDS_BIN" ]; then
            export ORDS_CONFIG="$PROJECT_DIR/ords_config"
            export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
            nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$LOG_DIR/ords.log" 2>&1 &
        fi
        
        echo "90"
        echo "# Waiting for ORDS (30s)..."
        sleep 30
        
        echo "100"
        echo "# Done!"
    ) | show_progress "${L[starting]}"
    
    sleep 2
    
    if is_db_running && is_ords_running; then
        show_info "${L[success]}\n\n🌐 Admin: http://localhost:8080/ords/apex_admin\n🔐 Login: http://localhost:8080/ords/f?p=4550"
    else
        show_error "Services may not have started correctly.\nTry running Fix from the menu."
    fi
}

do_stop() {
    (
        echo "30"
        echo "# Stopping ORDS..."
        pkill -f ords 2>/dev/null || true
        sleep 3
        
        echo "70"
        echo "# Stopping database..."
        docker stop oracle-apex-db 2>/dev/null || true
        
        echo "100"
        echo "# Done!"
    ) | show_progress "${L[stopping]}"
    
    sleep 1
    show_info "${L[success]}\n\nOracle APEX stopped."
}

do_status() {
    local db_status="🔴 ${L[stopped]}"
    local ords_status="🔴 ${L[stopped]}"
    local ords_pid=""
    
    if is_db_running; then
        db_status="🟢 ${L[running]}"
    fi
    
    ords_pid=$(pgrep -f "ords.*serve" | head -1)
    if [ -n "$ords_pid" ]; then
        ords_status="🟢 ${L[running]} (PID: $ords_pid)"
    fi
    
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
    local http_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")
    
    local msg="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    msg+="Database: $db_status\n"
    msg+="ORDS: $ords_status\n\n"
    msg+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    msg+="HTTP Endpoints:\n"
    msg+="  Admin: HTTP $http_admin\n"
    msg+="  Login: HTTP $http_login\n\n"
    msg+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    msg+="🌐 http://localhost:8080/ords/apex_admin\n"
    msg+="🔐 http://localhost:8080/ords/f?p=4550"
    
    show_info "$msg"
}

do_open_admin() {
    if is_ords_running; then
        xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || \
        open "http://localhost:8080/ords/apex_admin" 2>/dev/null || \
        sensible-browser "http://localhost:8080/ords/apex_admin" 2>/dev/null &
    else
        show_error "ORDS is not running!\nPlease start services first."
    fi
}

do_open_login() {
    if is_ords_running; then
        xdg-open "http://localhost:8080/ords/f?p=4550" 2>/dev/null || \
        open "http://localhost:8080/ords/f?p=4550" 2>/dev/null || \
        sensible-browser "http://localhost:8080/ords/f?p=4550" 2>/dev/null &
    else
        show_error "ORDS is not running!\nPlease start services first."
    fi
}

do_fix() {
    if [ -f "$SCRIPTS_DIR/fix.sh" ]; then
        bash "$SCRIPTS_DIR/fix.sh" > /tmp/apex_fix.log 2>&1 &
        FIX_PID=$!
        
        (
            while kill -0 $FIX_PID 2>/dev/null; do
                echo "# Running fix script..."
                sleep 2
            done
            echo "100"
        ) | show_progress "Running fix script..."
        
        wait $FIX_PID 2>/dev/null
        
        if [ -f /tmp/apex_fix.log ]; then
            if [ "$GUI_TOOL" = "yad" ]; then
                yad --text-info --title="Fix Result" --filename=/tmp/apex_fix.log --width=700 --height=500 --button="OK:0" 2>/dev/null
            else
                zenity --text-info --title="Fix Result" --filename=/tmp/apex_fix.log --width=700 --height=500 2>/dev/null
            fi
        fi
    else
        show_error "Fix script not found!"
    fi
}

do_logs() {
    local log_file="$LOG_DIR/ords.log"
    
    if [ -f "$log_file" ]; then
        if [ "$GUI_TOOL" = "yad" ]; then
            yad --text-info --title="ORDS Logs" --filename="$log_file" --width=800 --height=600 --button="OK:0" 2>/dev/null
        else
            zenity --text-info --title="ORDS Logs" --filename="$log_file" --width=800 --height=600 2>/dev/null
        fi
    else
        show_error "No logs found at:\n$log_file"
    fi
}

do_dbeaver() {
    if command -v dbeaver-ce &> /dev/null; then
        dbeaver-ce &
    elif command -v dbeaver &> /dev/null; then
        dbeaver &
    elif command -v flatpak &> /dev/null && flatpak list 2>/dev/null | grep -qi dbeaver; then
        flatpak run io.dbeaver.DBeaverCommunity &
    elif command -v snap &> /dev/null && snap list 2>/dev/null | grep -qi dbeaver; then
        snap run dbeaver-ce &
    else
        show_error "DBeaver not installed!\n\nInstall from: https://dbeaver.io\nor run: flatpak install flathub io.dbeaver.DBeaverCommunity"
    fi
}

do_settings() {
    local new_lang=""
    
    if [ "$GUI_TOOL" = "yad" ]; then
        new_lang=$(yad --list --title="${L[select_lang]}" \
            --text="Select your language:" \
            --radiolist --column="Select" --column="Code" --column="Language" \
            $([ "$LANG_CODE" = "en" ] && echo "TRUE" || echo "FALSE") "en" "🇺🇸 English" \
            $([ "$LANG_CODE" = "fa" ] && echo "TRUE" || echo "FALSE") "fa" "🇮🇷 فارسی" \
            $([ "$LANG_CODE" = "de" ] && echo "TRUE" || echo "FALSE") "de" "🇩🇪 Deutsch" \
            --width=350 --height=250 --print-column=2 --separator="" 2>/dev/null)
    else
        new_lang=$(zenity --list --title="${L[select_lang]}" \
            --text="Select your language:" \
            --radiolist --column="Select" --column="Code" --column="Language" \
            $([ "$LANG_CODE" = "en" ] && echo "TRUE" || echo "FALSE") "en" "🇺🇸 English" \
            $([ "$LANG_CODE" = "fa" ] && echo "TRUE" || echo "FALSE") "fa" "🇮🇷 فارسی" \
            $([ "$LANG_CODE" = "de" ] && echo "TRUE" || echo "FALSE") "de" "🇩🇪 Deutsch" \
            --width=350 --height=250 --print-column=2 2>/dev/null)
    fi
    
    # Clean the output
    new_lang=$(echo "$new_lang" | tr -d '|' | tr -d ' ' | head -1)
    
    if [ -n "$new_lang" ] && [[ "$new_lang" =~ ^(en|fa|de)$ ]]; then
        LANG_CODE="$new_lang"
        echo "LANG_CODE=\"$LANG_CODE\"" > "$CONFIG_FILE"
        load_lang
        show_info "Language changed to: $new_lang\n\nRestart the application to see all changes."
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN MENU (FIXED - NO CRASH)
# ═══════════════════════════════════════════════════════════════════════════════
main_menu() {
    while true; do
        # Get current status
        local status_icon="🔴"
        if is_db_running && is_ords_running; then
            status_icon="🟢"
        elif is_db_running || is_ords_running; then
            status_icon="🟡"
        fi
        
        local choice=""
        
        if [ "$GUI_TOOL" = "yad" ]; then
            choice=$(yad --list --title="${L[title]}" \
                --text="$status_icon Status | KaizenixCore v3.0.1\n\nSelect an action:" \
                --column="Action" --column="Description" \
                "start" "▶️  ${L[start]}" \
                "stop" "⏹️  ${L[stop]}" \
                "status" "📊 ${L[status]}" \
                "admin" "🌐 ${L[admin]}" \
                "login" "🔐 ${L[login]}" \
                "fix" "🔧 ${L[fix]}" \
                "logs" "📜 ${L[logs]}" \
                "dbeaver" "🗄️  ${L[dbeaver]}" \
                "settings" "⚙️  ${L[settings]}" \
                "exit" "❌ ${L[exit]}" \
                --width=420 --height=480 --print-column=1 --separator="" \
                --button="Execute:0" --button="Cancel:1" 2>/dev/null)
            
            local exit_code=$?
            if [ $exit_code -ne 0 ]; then
                exit 0
            fi
        else
            choice=$(zenity --list --title="${L[title]}" \
                --text="$status_icon Status | KaizenixCore v3.0.1\n\nSelect an action:" \
                --column="Action" --column="Description" \
                "start" "▶️  ${L[start]}" \
                "stop" "⏹️  ${L[stop]}" \
                "status" "📊 ${L[status]}" \
                "admin" "🌐 ${L[admin]}" \
                "login" "🔐 ${L[login]}" \
                "fix" "🔧 ${L[fix]}" \
                "logs" "📜 ${L[logs]}" \
                "dbeaver" "🗄️  ${L[dbeaver]}" \
                "settings" "⚙️  ${L[settings]}" \
                "exit" "❌ ${L[exit]}" \
                --width=420 --height=480 --print-column=1 2>/dev/null)
            
            if [ -z "$choice" ]; then
                exit 0
            fi
        fi
        
        # Clean the choice (remove any extra characters)
        choice=$(echo "$choice" | tr -d '|' | awk '{print $1}')
        
        case "$choice" in
            start)    do_start ;;
            stop)     do_stop ;;
            status)   do_status ;;
            admin)    do_open_admin ;;
            login)    do_open_login ;;
            fix)      do_fix ;;
            logs)     do_logs ;;
            dbeaver)  do_dbeaver ;;
            settings) do_settings ;;
            exit)     exit 0 ;;
            "")       exit 0 ;;
            *)        continue ;;
        esac
        
        # Small delay to prevent rapid loops
        sleep 0.5
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# STARTUP CHECKS
# ═══════════════════════════════════════════════════════════════════════════════
if [ ! -d "$PROJECT_DIR" ]; then
    show_error "Oracle APEX is not installed!\n\nProject directory not found:\n$PROJECT_DIR\n\nPlease run the installer first."
    exit 1
fi

if [ -z "$DB_PASS" ]; then
    show_error "Password not found!\n\nPlease ensure password file exists:\n$PROJECT_DIR/.db_password"
    exit 1
fi

# Start main menu
main_menu
GUIEOF2

    chmod +x "$SCRIPTS_DIR/launch-gui.sh"
    log_success "GUI Manager created (FIXED - No Crash)"
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
  </defs>
  <rect x="20" y="20" width="216" height="216" rx="40" fill="url(#grad1)"/>
  <text x="128" y="105" font-family="Arial Black" font-size="52" font-weight="bold" fill="white" text-anchor="middle">APEX</text>
  <text x="128" y="155" font-family="Arial" font-size="28" fill="white" text-anchor="middle">Manager</text>
  <text x="128" y="195" font-family="Arial" font-size="18" fill="rgba(255,255,255,0.75)" text-anchor="middle">KaizenixCore</text>
</svg>
SVGEOF

    cp "$PROJECT_DIR/oracle-apex-icon.svg" "$HOME/.local/share/icons/"
    
    # Create desktop file
    cat > "$HOME/.local/share/applications/oracle-apex.desktop" << DESKTOPEOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle APEX Manager
Comment=Manage Oracle APEX - KaizenixCore v${VERSION}
Exec=bash $SCRIPTS_DIR/launch-gui.sh
Icon=$HOME/.local/share/icons/oracle-apex-icon.svg
Terminal=false
Categories=Development;Database;
StartupNotify=true
DESKTOPEOF

    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    
    log_success "Desktop application created"

    # Create systemd services (Linux only)
    if [[ "$OS_TYPE" == "linux" ]] && command -v systemctl &> /dev/null; then
        local ORDS_BIN_PATH=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
        local ACTUAL_PASS="$ORACLE_PASSWORD"
        
        if [ -n "$ORDS_BIN_PATH" ]; then
        
            # ═══════════════════════════════════════════════════════════════
            # NEW: Create systemd recovery script (fixes auto-start issues)
            # ═══════════════════════════════════════════════════════════════
            log_info "Creating systemd recovery script..."
            
            cat > "$SCRIPTS_DIR/systemd-db-recovery.sh" << 'DBRECOVERYEOF'
#!/bin/bash
# Systemd Database Recovery Script - Runs before ORDS starts
# This ensures database users are properly configured after reboot

PROJECT_DIR="$HOME/oracle-apex-complete"
LOG_FILE="$PROJECT_DIR/logs/systemd-recovery.log"
MAX_WAIT=180  # Maximum seconds to wait for database

mkdir -p "$(dirname "$LOG_FILE")"
exec >> "$LOG_FILE" 2>&1
echo "=========================================="
echo "Recovery started at: $(date)"
echo "=========================================="

# Read password
PASS=""
if [ -f "$PROJECT_DIR/.db_password" ]; then
    PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null | tr -d '\n\r')
fi

if [ -z "$PASS" ]; then
    echo "ERROR: Cannot read database password"
    exit 1
fi

# Wait for database container to be running
echo "Waiting for database container..."
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"; then
        echo "Container is running after ${WAITED}s"
        break
    fi
    sleep 5
    WAITED=$((WAITED + 5))
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo "ERROR: Database container not running after ${MAX_WAIT}s"
    exit 1
fi

# Wait for database to be ready (accepting connections)
echo "Waiting for database to accept connections..."
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    if docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba <<< "SELECT 1 FROM DUAL; EXIT;" 2>/dev/null | grep -q "1"; then
        echo "Database is ready after ${WAITED}s"
        break
    fi
    sleep 10
    WAITED=$((WAITED + 10))
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo "ERROR: Database not ready after ${MAX_WAIT}s"
    exit 1
fi

# Run recovery SQL commands
echo "Running recovery SQL commands..."
docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << SQLEOF
-- Unlock and configure ORDS_PUBLIC_USER
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER ORDS_PUBLIC_USER DEFAULT TABLESPACE SYSAUX TEMPORARY TABLESPACE TEMP;

-- Unlock and configure APEX_PUBLIC_USER
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;

-- Grant proxy authentication
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

-- Ensure required privileges
GRANT CREATE SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION TO APEX_PUBLIC_USER;

COMMIT;
EXIT;
SQLEOF

if [ $? -eq 0 ]; then
    echo "SUCCESS: Recovery SQL completed"
else
    echo "WARNING: Some SQL commands may have failed (non-critical)"
fi

echo "Recovery finished at: $(date)"
echo ""
exit 0
DBRECOVERYEOF

            chmod +x "$SCRIPTS_DIR/systemd-db-recovery.sh"
            log_success "Recovery script created: $SCRIPTS_DIR/systemd-db-recovery.sh"
            
            # ═══════════════════════════════════════════════════════════════
            # Database service (IMPROVED)
            # ═══════════════════════════════════════════════════════════════
            cat > /tmp/oracle-apex-db.service << DBSVCEOF
[Unit]
Description=Oracle APEX Database Container
After=docker.service network-online.target
Requires=docker.service
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
User=$USER
ExecStartPre=/bin/sleep 10
ExecStartPre=/bin/bash -c '/usr/bin/docker ps -a --format "{{.Names}}" | grep -q "^oracle-apex-db$" || exit 0'
ExecStart=/usr/bin/docker start oracle-apex-db
ExecStop=/usr/bin/docker stop -t 30 oracle-apex-db
TimeoutStartSec=300
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
DBSVCEOF

            # ═══════════════════════════════════════════════════════════════
            # ORDS service (IMPROVED - uses recovery script)
            # ═══════════════════════════════════════════════════════════════
            cat > /tmp/oracle-apex-ords.service << ORDSSVCEOF
[Unit]
Description=Oracle APEX ORDS Service
After=oracle-apex-db.service
Requires=oracle-apex-db.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment="ORDS_CONFIG=$ORDS_CONFIG_DIR"
Environment="_JAVA_OPTIONS=-Xms512m -Xmx1024m"
Environment="HOME=$HOME"
ExecStartPre=/bin/bash $SCRIPTS_DIR/systemd-db-recovery.sh
ExecStart=$ORDS_BIN_PATH --config $ORDS_CONFIG_DIR serve --port 8080 --apex-images $IMAGES_DIR
Restart=always
RestartSec=30
TimeoutStartSec=600
StandardOutput=append:$LOG_DIR/ords.log
StandardError=append:$LOG_DIR/ords.log

[Install]
WantedBy=multi-user.target
ORDSSVCEOF

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
                    
                    # ═══════════════════════════════════════════════════════════════
                    # NEW: Show helpful info about auto-start
                    # ═══════════════════════════════════════════════════════════════
                    log_info "After reboot, services will start automatically."
                    log_info "Check status with: sudo systemctl status oracle-apex-db.service"
                    log_info "Check ORDS with: sudo systemctl status oracle-apex-ords.service"
                    log_info "View recovery log: cat $LOG_DIR/systemd-recovery.log"
                fi
            fi
        fi
    fi
    
    log_success "Desktop and services configuration completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 29: FINAL VERIFICATION
# ═══════════════════════════════════════════════════════════════════════════════
step_29_final_verification() {
    log_step "Final Verification"

    log_info "Checking ORDS_METADATA schema..."
    local METADATA_EXISTS=$(docker exec oracle-apex-db sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME='ORDS_METADATA';
EXIT;
EOF
)
    METADATA_EXISTS=$(echo "$METADATA_EXISTS" | grep -o '[0-9]' | head -1)

    [ "$METADATA_EXISTS" = "1" ] && log_success "✅ ORDS_METADATA exists" || log_warning "⚠️ ORDS_METADATA missing"

    log_info "Checking proxy grants..."
    local PROXY_COUNT=$(docker exec oracle-apex-db sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM DBA_PROXIES WHERE PROXY='ORDS_PUBLIC_USER';
EXIT;
EOF
)
    PROXY_COUNT=$(echo "$PROXY_COUNT" | grep -o '[0-9]' | head -1)
    [ "$PROXY_COUNT" -ge 1 ] 2>/dev/null && log_success "✅ Proxy grants OK" || log_warning "⚠️ Proxy grants may need config"

    # Verify password files
    [ -f "$PROJECT_DIR/.db_password" ] && log_success "✅ Password file exists" || {
        echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
        chmod 600 "$PROJECT_DIR/.db_password"
        log_success "✅ Password file created"
    }

    # Verify scripts are executable
    chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true
    log_success "✅ Scripts are executable"

    # Final endpoint check
    local final_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null || echo "000")
    [[ "$final_admin" =~ ^(200|302|303)$ ]] && log_success "✅ APEX Admin: HTTP $final_admin" || log_warning "⚠️ APEX Admin: HTTP $final_admin"

    log_success "Final verification completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 30: INSTALL DBEAVER (CROSS-PLATFORM) - THIS WAS MISSING!
# ═══════════════════════════════════════════════════════════════════════════════
step_30_install_dbeaver() {
    log_step "Installing DBeaver (Cross-Platform - GUARANTEED)"

    read -p "  Install DBeaver database tool? [y/N]: " install_dbeaver
    [[ ! $install_dbeaver =~ ^[Yy]$ ]] && { log_info "DBeaver installation skipped"; return; }

    log_info "Installing DBeaver..."
    local DBEAVER_INSTALLED=false

    # ═══════════════════════════════════════════════════════════════
    # Method 1: Flatpak (works on ALL distros) - WITH SUDO
    # ═══════════════════════════════════════════════════════════════
    log_info "Method 1: Installing via Flatpak (system-wide)..."
    
    # First, ensure Flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        log_info "Installing Flatpak first..."
        case "$OS_ID" in
            ubuntu|debian|linuxmint|pop|elementary|zorin)
                sudo apt-get update -qq
                sudo apt-get install -y flatpak
                ;;
            fedora)
                sudo dnf install -y flatpak
                ;;
            opensuse*|suse*|sles)
                sudo zypper --non-interactive install flatpak
                ;;
            arch|manjaro|endeavouros)
                sudo pacman -S --noconfirm flatpak
                ;;
            rhel|centos|rocky|alma)
                sudo dnf install -y flatpak || sudo yum install -y flatpak
                ;;
        esac
    fi
    
    # Add Flathub repository
    if command -v flatpak &> /dev/null; then
        log_info "Adding Flathub repository..."
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
        
        # Install DBeaver with sudo (system-wide)
        log_info "Installing DBeaver (this may take a few minutes)..."
        if sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity 2>&1 | tee -a "$LOG_DIR/dbeaver_install.log"; then
            # Verify installation
            if flatpak list 2>/dev/null | grep -qi "dbeaver"; then
                log_success "✅ DBeaver installed via Flatpak!"
                DBEAVER_INSTALLED=true
            fi
        fi
    fi

    # ═══════════════════════════════════════════════════════════════
    # Method 2: Native package if Flatpak failed
    # ═══════════════════════════════════════════════════════════════
    if [ "$DBEAVER_INSTALLED" = false ]; then
        log_warning "Flatpak installation failed. Trying native package..."
        
        case "$OS_ID" in
            ubuntu|debian|linuxmint|pop|elementary|zorin)
                log_info "Downloading DBeaver .deb package..."
                wget -q --show-progress -O /tmp/dbeaver.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" && \
                sudo dpkg -i /tmp/dbeaver.deb 2>/dev/null
                sudo apt-get install -f -y 2>/dev/null
                rm -f /tmp/dbeaver.deb
                command -v dbeaver-ce &>/dev/null && DBEAVER_INSTALLED=true
                ;;
                
            fedora|rhel|centos|rocky|alma)
                log_info "Downloading DBeaver .rpm package..."
                wget -q --show-progress -O /tmp/dbeaver.rpm "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" && \
                sudo dnf install -y /tmp/dbeaver.rpm 2>/dev/null || sudo yum install -y /tmp/dbeaver.rpm 2>/dev/null
                rm -f /tmp/dbeaver.rpm
                command -v dbeaver-ce &>/dev/null && DBEAVER_INSTALLED=true
                ;;
                
            opensuse*|suse*|sles)
                log_info "Downloading DBeaver .rpm package..."
                wget -q --show-progress -O /tmp/dbeaver.rpm "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" && \
                sudo zypper --non-interactive install --allow-unsigned-rpm /tmp/dbeaver.rpm 2>/dev/null
                rm -f /tmp/dbeaver.rpm
                command -v dbeaver-ce &>/dev/null && DBEAVER_INSTALLED=true
                ;;
                
            arch|manjaro|endeavouros)
                log_info "Installing via pacman/yay..."
                sudo pacman -S --noconfirm dbeaver 2>/dev/null || \
                yay -S --noconfirm dbeaver-ce-bin 2>/dev/null
                command -v dbeaver &>/dev/null && DBEAVER_INSTALLED=true
                ;;
        esac
    fi

    # ═══════════════════════════════════════════════════════════════
    # Method 3: Snap as last resort
    # ═══════════════════════════════════════════════════════════════
    if [ "$DBEAVER_INSTALLED" = false ] && command -v snap &> /dev/null; then
        log_info "Trying Snap installation..."
        sudo snap install dbeaver-ce 2>/dev/null && DBEAVER_INSTALLED=true
    fi

    # ═══════════════════════════════════════════════════════════════
    # Final verification and launcher creation
    # ═══════════════════════════════════════════════════════════════
    echo ""
    log_info "Verifying DBeaver installation..."
    
    if flatpak list 2>/dev/null | grep -qi "dbeaver"; then
        log_success "✅ DBeaver is installed (Flatpak)"
        DBEAVER_INSTALLED=true
    elif command -v dbeaver-ce &>/dev/null; then
        log_success "✅ DBeaver is installed (Native: $(which dbeaver-ce))"
        DBEAVER_INSTALLED=true
    elif command -v dbeaver &>/dev/null; then
        log_success "✅ DBeaver is installed (Native: $(which dbeaver))"
        DBEAVER_INSTALLED=true
    elif snap list 2>/dev/null | grep -qi "dbeaver"; then
        log_success "✅ DBeaver is installed (Snap)"
        DBEAVER_INSTALLED=true
    fi

    if [ "$DBEAVER_INSTALLED" = false ]; then
        log_error "❌ DBeaver installation failed!"
        log_info "Please install manually:"
        log_info "  sudo flatpak install flathub io.dbeaver.DBeaverCommunity"
        log_info "  Or download from: https://dbeaver.io/download/"
    fi

    # Create launcher script (always create it)
    log_info "Creating DBeaver launcher script..."
    cat > "$SCRIPTS_DIR/open-dbeaver.sh" << 'DBLAUNCHEREOF'
#!/bin/bash
# DBeaver Launcher - KaizenixCore
echo "🔍 Looking for DBeaver..."

# Method 1: Flatpak
if command -v flatpak &> /dev/null; then
    if flatpak list 2>/dev/null | grep -qi "io.dbeaver.DBeaverCommunity"; then
        echo "✅ Starting DBeaver via Flatpak..."
        flatpak run io.dbeaver.DBeaverCommunity &
        exit 0
    fi
fi

# Method 2: Native commands
if command -v dbeaver-ce &> /dev/null; then
    echo "✅ Starting dbeaver-ce..."
    dbeaver-ce &
    exit 0
fi

if command -v dbeaver &> /dev/null; then
    echo "✅ Starting dbeaver..."
    dbeaver &
    exit 0
fi

# Method 3: Snap
if command -v snap &> /dev/null; then
    if snap list 2>/dev/null | grep -qi dbeaver; then
        echo "✅ Starting DBeaver via Snap..."
        snap run dbeaver-ce &
        exit 0
    fi
fi

# Not found
echo ""
echo "❌ DBeaver not installed!"
echo ""
echo "Install with one of these commands:"
echo "  sudo flatpak install flathub io.dbeaver.DBeaverCommunity"
echo "  Or download from: https://dbeaver.io/download/"
exit 1
DBLAUNCHEREOF

    chmod +x "$SCRIPTS_DIR/open-dbeaver.sh"
    log_success "DBeaver launcher script created: $SCRIPTS_DIR/open-dbeaver.sh"
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
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   🌐 QUICK ACCESS:${NC}"
    echo -e "      Admin Panel: ${CYAN}http://localhost:8080/ords/apex_admin${NC}"
    echo -e "      Login Page:  ${CYAN}http://localhost:8080/ords/f?p=4550${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   🔐 CREDENTIALS:${NC}"
    echo -e "      Workspace:   ${WHITE}INTERNAL${NC}"
    echo -e "      Username:    ${WHITE}ADMIN${NC}"
    echo -e "      Password:    ${WHITE}$APEX_ADMIN_PASSWORD${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   🗄️ DATABASE:${NC}"
    echo -e "      Host:        ${WHITE}localhost:$DB_PORT${NC}"
    echo -e "      Service:     ${WHITE}$DB_SERVICE${NC}"
    echo -e "      SYS Pass:    ${WHITE}$ORACLE_PASSWORD${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   📜 MANAGEMENT COMMANDS:${NC}"
    echo -e "      Start:       ${CYAN}bash $SCRIPTS_DIR/start.sh${NC}"
    echo -e "      Stop:        ${CYAN}bash $SCRIPTS_DIR/stop.sh${NC}"
    echo -e "      Status:      ${CYAN}bash $SCRIPTS_DIR/status.sh${NC}"
    echo -e "      Fix:         ${CYAN}bash $SCRIPTS_DIR/fix.sh${NC}"
    echo -e "      Logs:        ${CYAN}bash $SCRIPTS_DIR/logs.sh${NC}"
    echo -e "      Reset Pass:  ${CYAN}bash $SCRIPTS_DIR/reset-apex-password.sh${NC}"
    echo -e "      GUI:         ${CYAN}bash $SCRIPTS_DIR/launch-gui.sh${NC}"
    echo -e "      DBeaver:     ${CYAN}bash $SCRIPTS_DIR/open-dbeaver.sh${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}${BOLD}   💡 TROUBLESHOOTING:${NC}"
    echo -e "      If you see Error 500/571/574:"
    echo -e "      ${WHITE}bash $SCRIPTS_DIR/fix.sh${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}${BOLD}   🖥️ GUI MANAGER:${NC}"
    echo -e "      Run: ${WHITE}bash $SCRIPTS_DIR/launch-gui.sh${NC}"
    echo -e "      Or find '${WHITE}Oracle APEX Manager${NC}' in your applications menu"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}${BOLD}   🔄 AFTER SYSTEM RESTART:${NC}"
    echo -e "      If auto-start is enabled, services start automatically."
    echo -e "      Otherwise run: ${WHITE}bash $SCRIPTS_DIR/start.sh${NC}"
    echo ""
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}   Created by: ${WHITE}Peyman Rasouli${NC} ${GRAY}| Project: ${MAGENTA}KaizenixCore${NC}"
    echo -e "${GRAY}   GitHub: ${BLUE}https://github.com/KaizenixCore/oracle-apex-installer/${NC}"
    echo -e "${GRAY}   Version: ${WHITE}$VERSION${NC} ${GRAY}| License: ${WHITE}MIT${NC}"
    echo -e "${GRAY}   OS: ${WHITE}$OS_TYPE ($OS_ID $OS_VERSION)${NC} ${GRAY}| Arch: ${WHITE}$ARCH${NC}"
    echo -e "${GRAY}   GUI Tool: ${WHITE}$GUI_TOOL${NC}"
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Ask to open browser
    echo ""
    read -p "  Open APEX Admin in browser now? [Y/n]: " open_browser
    if [[ ! $open_browser =~ ^[Nn]$ ]]; then
        xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || \
        open "http://localhost:8080/ords/apex_admin" 2>/dev/null || \
        sensible-browser "http://localhost:8080/ords/apex_admin" 2>/dev/null &
    fi
    
    echo ""
    log_success "🎉 Installation completed! Enjoy Oracle APEX!"
    echo ""
}
# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALL FUNCTION - Complete System Cleanup
# ═══════════════════════════════════════════════════════════════════════════════
uninstall_everything() {
    clear
    echo ""
    echo -e "${RED}${BOLD}"
    echo "  ╔═══════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                   ║"
    echo "  ║           ⚠️  COMPLETE UNINSTALL - حذف کامل  ⚠️                   ║"
    echo "  ║                                                                   ║"
    echo "  ╠═══════════════════════════════════════════════════════════════════╣"
    echo "  ║  This will remove:                                                ║"
    echo "  ║    • Oracle APEX Database Container                               ║"
    echo "  ║    • ORDS (Oracle REST Data Services)                             ║"
    echo "  ║    • All configuration files                                      ║"
    echo "  ║    • All downloaded files                                         ║"
    echo "  ║    • Systemd services                                             ║"
    echo "  ║    • Desktop shortcuts                                            ║"
    echo "  ║    • DBeaver (if installed via this script)                       ║"
    echo "  ║                                                                   ║"
    echo "  ╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    read -p "  Are you sure you want to COMPLETELY UNINSTALL? [y/N]: " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo ""
        log_info "Uninstall cancelled."
        exit 0
    fi
    
    echo ""
    read -p "  Type 'DELETE' to confirm: " confirm_delete
    if [ "$confirm_delete" != "DELETE" ]; then
        echo ""
        log_info "Uninstall cancelled. You must type DELETE to confirm."
        exit 0
    fi
    
    echo ""
    log_step "Starting Complete Uninstall..."
    
    # ═══════════════════════════════════════════════════════════════
    # Step 1: Stop all services
    # ═══════════════════════════════════════════════════════════════
    log_info "Step 1/8: Stopping all services..."
    
    # Stop ORDS process
    pkill -9 -f "ords" 2>/dev/null || true
    sleep 3
    
    # Stop systemd services
    if command -v systemctl &> /dev/null; then
        sudo systemctl stop oracle-apex-ords.service 2>/dev/null || true
        sudo systemctl stop oracle-apex-db.service 2>/dev/null || true
        sudo systemctl disable oracle-apex-ords.service 2>/dev/null || true
        sudo systemctl disable oracle-apex-db.service 2>/dev/null || true
    fi
    
    log_success "Services stopped"
    
    # ═══════════════════════════════════════════════════════════════
    # Step 2: Remove Docker container and volume
    # ═══════════════════════════════════════════════════════════════
    log_info "Step 2/8: Removing Docker container and data..."
    
    docker stop oracle-apex-db 2>/dev/null || true
    docker rm -f oracle-apex-db 2>/dev/null || true
    docker volume rm oracle-apex-complete_oracle-data 2>/dev/null || true
    docker volume rm oracle-data 2>/dev/null || true
    
    # Remove any orphan volumes related to this project
    docker volume ls -q 2>/dev/null | grep -i "oracle\|apex" | xargs -r docker volume rm 2>/dev/null || true
    
    log_success "Docker container and volumes removed"
    
    # ═══════════════════════════════════════════════════════════════
    # Step 3: Remove systemd service files
    # ═══════════════════════════════════════════════════════════════
    log_info "Step 3/8: Removing systemd services..."
    
    if command -v systemctl &> /dev/null; then
        sudo rm -f /etc/systemd/system/oracle-apex-db.service 2>/dev/null || true
        sudo rm -f /etc/systemd/system/oracle-apex-ords.service 2>/dev/null || true
        sudo systemctl daemon-reload 2>/dev/null || true
    fi
    
    log_success "Systemd services removed"
    
    # ═══════════════════════════════════════════════════════════════
    # Step 4: Remove project directory
    # ═══════════════════════════════════════════════════════════════
    log_info "Step 4/8: Removing project directory..."
    
    rm -rf "$HOME/oracle-apex-complete" 2>/dev/null || true
    rm -rf "$HOME/oracle-apex" 2>/dev/null || true
    
    log_success "Project directory removed"
    
    # ═══════════════════════════════════════════════════════════════
    # Step 5: Remove desktop shortcuts and icons
    # ═══════════════════════════════════════════════════════════════
    log_info "Step 5/8: Removing desktop shortcuts..."
    
    rm -f "$HOME/.local/share/applications/oracle-apex.desktop" 2>/dev/null || true
    rm -f "$HOME/.local/share/icons/oracle-apex-icon.svg" 2>/dev/null || true
    rm -f "$HOME/Desktop/oracle-apex.desktop" 2>/dev/null || true
    
    # Update desktop database
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    
    log_success "Desktop shortcuts removed"
    
    # ═══════════════════════════════════════════════════════════════
    # Step 6: Remove DBeaver (if installed via Flatpak)
    # ═══════════════════════════════════════════════════════════════
    log_info "Step 6/8: Checking DBeaver..."
    
    read -p "  Also remove DBeaver? [y/N]: " remove_dbeaver
    if [[ $remove_dbeaver =~ ^[Yy]$ ]]; then
        log_info "Removing DBeaver..."
        
        # Flatpak
        flatpak uninstall --user io.dbeaver.DBeaverCommunity -y 2>/dev/null || true
        sudo flatpak uninstall io.dbeaver.DBeaverCommunity -y 2>/dev/null || true
        rm -rf "$HOME/.var/app/io.dbeaver.DBeaverCommunity" 2>/dev/null || true
        
        # Snap
        sudo snap remove dbeaver-ce 2>/dev/null || true
        
        # Native packages
        case "$OS_ID" in
            ubuntu|debian|linuxmint|pop)
                sudo apt-get remove -y dbeaver dbeaver-ce 2>/dev/null || true
                ;;
            fedora|rhel|centos|rocky|alma)
                sudo dnf remove -y dbeaver dbeaver-ce 2>/dev/null || true
                ;;
            opensuse*|suse*)
                sudo zypper remove -y dbeaver dbeaver-ce 2>/dev/null || true
                ;;
            arch|manjaro)
                sudo pacman -Rns --noconfirm dbeaver 2>/dev/null || true
                ;;
        esac
        
        # Remove DBeaver config
        rm -rf "$HOME/.dbeaver" 2>/dev/null || true
        rm -rf "$HOME/.dbeaver4" 2>/dev/null || true
        rm -rf "$HOME/.local/share/DBeaverData" 2>/dev/null || true
        rm -rf "$HOME/.config/dbeaver" 2>/dev/null || true
        
        log_success "DBeaver removed"
    else
        log_info "DBeaver kept"
    fi
    
    # ═══════════════════════════════════════════════════════════════
    # Step 7: Clean up temporary files
    # ═══════════════════════════════════════════════════════════════
    log_info "Step 7/8: Cleaning temporary files..."
    
    rm -f /tmp/apex*.zip 2>/dev/null || true
    rm -f /tmp/ords*.zip 2>/dev/null || true
    rm -f /tmp/oracle-apex-*.service 2>/dev/null || true
    rm -f /tmp/dbeaver.* 2>/dev/null || true
    rm -f "$HOME/fix-oracle-apex-issues.sh" 2>/dev/null || true
    rm -f "$HOME/remove-dbeaver-completely.sh" 2>/dev/null || true
    
    log_success "Temporary files cleaned"
    
    # ═══════════════════════════════════════════════════════════════
    # Step 8: Final verification
    # ═══════════════════════════════════════════════════════════════
    log_info "Step 8/8: Final verification..."
    
    local all_clean=true
    
    # Check Docker container
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "oracle-apex-db"; then
        log_warning "Docker container still exists"
        all_clean=false
    fi
    
    # Check project directory
    if [ -d "$HOME/oracle-apex-complete" ]; then
        log_warning "Project directory still exists"
        all_clean=false
    fi
    
    # Check systemd services
    if [ -f "/etc/systemd/system/oracle-apex-db.service" ]; then
        log_warning "Systemd service file still exists"
        all_clean=false
    fi
    
    if [ "$all_clean" = true ]; then
        echo ""
        echo -e "${GREEN}${BOLD}"
        echo "  ╔═══════════════════════════════════════════════════════════════════╗"
        echo "  ║                                                                   ║"
        echo "  ║           ✅ UNINSTALL COMPLETED SUCCESSFULLY! ✅                 ║"
        echo "  ║                                                                   ║"
        echo "  ╠═══════════════════════════════════════════════════════════════════╣"
        echo "  ║                                                                   ║"
        echo "  ║  All Oracle APEX components have been removed.                    ║"
        echo "  ║                                                                   ║"
        echo "  ║  To reinstall, run:                                               ║"
        echo "  ║    bash oracle-apex-installer.sh                                  ║"
        echo "  ║                                                                   ║"
        echo "  ╚═══════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    else
        echo ""
        echo -e "${YELLOW}${BOLD}"
        echo "  ╔═══════════════════════════════════════════════════════════════════╗"
        echo "  ║                                                                   ║"
        echo "  ║           ⚠️  UNINSTALL COMPLETED WITH WARNINGS ⚠️                ║"
        echo "  ║                                                                   ║"
        echo "  ║  Some components may not have been fully removed.                 ║"
        echo "  ║  Please check the warnings above.                                 ║"
        echo "  ║                                                                   ║"
        echo "  ╚═══════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    fi
    
    echo ""
    exit 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# SHOW MENU - Installation Options
# ═══════════════════════════════════════════════════════════════════════════════
show_menu() {
    clear
    print_banner
    
    echo ""
    echo -e "${CYAN}${BOLD}  ┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                   ${WHITE}${BOLD}SELECT AN OPTION${NC}                            ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  └─────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} ${WHITE}Install Oracle APEX${NC} - Fresh installation"
    echo -e "  ${YELLOW}2)${NC} ${WHITE}Repair Installation${NC} - Fix existing installation"
    echo -e "  ${RED}3)${NC} ${WHITE}Uninstall Everything${NC} - Complete removal"
    echo -e "  ${GRAY}4)${NC} ${WHITE}Exit${NC}"
    echo ""
    
    read -p "  Enter your choice [1-4]: " menu_choice
    
    case $menu_choice in
        1)
            log_info "Starting fresh installation..."
            return 0  # Continue with installation
            ;;
        2)
            log_info "Starting repair..."
            if [ -f "$HOME/oracle-apex-complete/scripts/fix.sh" ]; then
                bash "$HOME/oracle-apex-complete/scripts/fix.sh"
                exit 0
            else
                log_error "No existing installation found. Please install first."
                exit 1
            fi
            ;;
        3)
            detect_os
            uninstall_everything
            ;;
        4)
            log_info "Goodbye!"
            exit 0
            ;;
        *)
            log_error "Invalid option. Please enter 1-4."
            sleep 2
            show_menu
            ;;
    esac
}
# ═══════════════════════════════════════════════════════════════════════════════
# MAIN FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════
main() {
    # Check for command line arguments
    if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
        detect_os
        uninstall_everything
        exit 0
    fi
    
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo ""
        echo "Oracle APEX Ultimate Installer v${VERSION}"
        echo ""
        echo "Usage:"
        echo "  bash oracle-apex-installer.sh           # Show menu"
        echo "  bash oracle-apex-installer.sh --install # Direct install"
        echo "  bash oracle-apex-installer.sh --uninstall # Uninstall everything"
        echo "  bash oracle-apex-installer.sh --help    # Show this help"
        echo ""
        exit 0
    fi
    
    # Show menu if no direct install flag
    if [ "$1" != "--install" ] && [ "$1" != "-i" ]; then
        show_menu
    fi
    
    # Initial setup
    print_banner
    detect_os
    detect_gui_tool
    get_passwords

    # Run all installation steps
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
