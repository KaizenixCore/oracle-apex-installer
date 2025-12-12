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
#  ║     ORACLE APEX ULTIMATE INSTALLER v3.1.0 - FULL DOCKER EDITION           ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore                             ║
#  ║  License    : MIT                                                         ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║                           FEATURES                                        ║
#  ├───────────────────────────────────────────────────────────────────────────┤
#  ║  ✅ 100% Docker-based - No local dependencies (Java, wget, unzip)         ║
#  ║  ✅ Cross-Platform: Linux, macOS, Windows (Docker Desktop)                ║
#  ║  ✅ Fully Automated Oracle APEX + ORDS + XE 21c Installation              ║
#  ║  ✅ Persistent Data Storage on Host System                                ║
#  ║  ✅ Error 571 & Proxy Authentication - FIXED                              ║
#  ║  ✅ Multi-Language GUI (English/Persian/German)                           ║
#  ║  ✅ Modern UI/UX with Zenity                                              ║
#  ║  ✅ One-Click Browser Launch                                              ║
#  ║  ✅ Desktop Application (.desktop file)                                   ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e
trap 'handle_error $LINENO' ERR

VERSION="3.1.0"
PROJECT_DIR="$HOME/oracle-apex-docker"
DATA_DIR="$PROJECT_DIR/data"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
CONFIG_DIR="$PROJECT_DIR/config"
LOG_DIR="$PROJECT_DIR/logs"

DB_HOST="oracle-db"
DB_SERVICE="XEPDB1"
DB_PORT="1521"
ORDS_PORT="8080"

ORACLE_IMAGE="gvenzl/oracle-xe:21-full"

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
TOTAL_STEPS=12

# ═══════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

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
    echo -e "${WHITE}${BOLD}  ║${NC}   ${MAGENTA}${BOLD}ORACLE APEX ULTIMATE INSTALLER${NC} ${WHITE}v${VERSION}${NC} ${CYAN}[FULL DOCKER]${NC}      ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} 100% Docker    ${GREEN}✓${NC} Cross-Platform    ${GREEN}✓${NC} One Command        ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}Created by:${NC} ${CYAN}Peyman Rasouli${NC}                                    ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}Project:${NC}    ${MAGENTA}KaizenixCore${NC}                                       ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}GitHub:${NC}     ${BLUE}https://github.com/KaizenixCore${NC}                     ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

get_passwords() {
    echo ""
    echo -e "${CYAN}${BOLD}  ┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                   ${WHITE}${BOLD}🔐 PASSWORD CONFIGURATION${NC}                    ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  └─────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}Important:${NC} Password must contain only letters and numbers"
    echo -e "  ${YELLOW}${BOLD}           ${NC}(no special characters), minimum 8 characters"
    echo ""

    while true; do
        read -p "  Enter Oracle Database Password: " ORACLE_PASSWORD
        echo
        read -p "  Enter APEX Admin Password: " APEX_ADMIN_PASSWORD
        echo

        if [[ ! "$ORACLE_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{7,}$ ]]; then
            echo -e "  ${RED}✗ Password must start with letter, only letters/numbers, min 8 chars${NC}"
            continue
        fi

        if [[ ! "$APEX_ADMIN_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{7,}$ ]]; then
            echo -e "  ${RED}✗ APEX Password must start with letter, only letters/numbers, min 8 chars${NC}"
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
    echo -e "${RED}${BOLD}  ║${NC}  Docker: ${CYAN}docker compose logs${NC}"
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

detect_os() {
    case "$(uname -s)" in
        Linux*)     OS_TYPE="linux" ;;
        Darwin*)    OS_TYPE="macos" ;;
        MINGW*|MSYS*|CYGWIN*) OS_TYPE="windows" ;;
        *)          OS_TYPE="unknown" ;;
    esac
    echo "$OS_TYPE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1: Check Docker
# ═══════════════════════════════════════════════════════════════════════════════

step_01_check_docker() {
    log_step "Checking Docker Installation"
    
    if ! command -v docker &>/dev/null; then
        log_error "Docker is not installed!"
        echo ""
        echo -e "${YELLOW}  Please install Docker first:${NC}"
        echo ""
        case $(detect_os) in
            linux)
                echo -e "  ${CYAN}curl -fsSL https://get.docker.com | sh${NC}"
                echo -e "  ${CYAN}sudo usermod -aG docker \$USER${NC}"
                echo -e "  ${CYAN}newgrp docker${NC}"
                ;;
            macos)
                echo -e "  ${CYAN}https://docs.docker.com/desktop/install/mac-install/${NC}"
                echo -e "  Or: ${CYAN}brew install --cask docker${NC}"
                ;;
            windows)
                echo -e "  ${CYAN}https://docs.docker.com/desktop/install/windows-install/${NC}"
                ;;
        esac
        echo ""
        exit 1
    fi
    
    if ! docker info &>/dev/null; then
        log_error "Docker is not running!"
        echo ""
        case $(detect_os) in
            linux)
                echo -e "  ${YELLOW}Run: ${CYAN}sudo systemctl start docker${NC}"
                ;;
            macos|windows)
                echo -e "  ${YELLOW}Please start Docker Desktop${NC}"
                ;;
        esac
        echo ""
        exit 1
    fi
    
    log_success "Docker is installed and running"
    log_info "Docker version: $(docker --version | cut -d' ' -f3 | tr -d ',')"
    
    # Check docker compose
    if docker compose version &>/dev/null; then
        COMPOSE_CMD="docker compose"
        log_success "Docker Compose (plugin) available"
    elif command -v docker-compose &>/dev/null; then
        COMPOSE_CMD="docker-compose"
        log_success "Docker Compose (standalone) available"
    else
        log_error "Docker Compose not found!"
        exit 1
    fi
    
    # Check disk space
    local free=$(df -BG "$HOME" 2>/dev/null | awk 'NR==2{print $4}' | sed 's/G//' || echo "20")
    [ "$free" -lt 15 ] && { log_error "Need 15GB free space, have ${free}GB"; exit 1; }
    log_success "Disk Space: ${free}GB available"
    
    log_info "OS: $(detect_os)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 2: Initialize Project
# ═══════════════════════════════════════════════════════════════════════════════

step_02_init() {
    log_step "Initializing Project Directories"
    
    mkdir -p "$PROJECT_DIR"
    mkdir -p "$DATA_DIR/oradata"
    mkdir -p "$DATA_DIR/ords_config"
    mkdir -p "$DATA_DIR/apex"
    mkdir -p "$SCRIPTS_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"
    
    # Save passwords securely
    echo "$ORACLE_PASSWORD" > "$CONFIG_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$CONFIG_DIR/.apex_password"
    chmod 600 "$CONFIG_DIR/.db_password" "$CONFIG_DIR/.apex_password"
    
    log_success "Directories created at: $PROJECT_DIR"
    log_info "Database data will be stored at: $DATA_DIR/oradata"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3: Cleanup Previous Installation
# ═══════════════════════════════════════════════════════════════════════════════

step_03_cleanup() {
    log_step "Cleanup Previous Installation"

    read -p "  Clean old installation? [Y/n]: " confirm
    [[ $confirm =~ ^[Nn]$ ]] && { log_info "Skipped"; return; }

    log_info "Cleaning..."
    
    cd "$PROJECT_DIR" 2>/dev/null || true
    $COMPOSE_CMD down -v 2>/dev/null || true
    
    docker stop oracle-apex-db oracle-apex-ords 2>/dev/null || true
    docker rm -f oracle-apex-db oracle-apex-ords 2>/dev/null || true
    docker network rm apex-network 2>/dev/null || true
    
    # Keep data directory but clean config
    rm -rf "$DATA_DIR/ords_config"/* 2>/dev/null || true
    rm -rf "$DATA_DIR/apex"/* 2>/dev/null || true
    rm -f "$PROJECT_DIR/docker-compose.yml" 2>/dev/null || true
    rm -f "$PROJECT_DIR/Dockerfile.ords" 2>/dev/null || true
    rm -f "$CONFIG_DIR/.setup_complete" 2>/dev/null || true
    
    mkdir -p "$DATA_DIR/oradata"
    mkdir -p "$DATA_DIR/ords_config"
    mkdir -p "$DATA_DIR/apex"
    
    log_success "Cleanup completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4: Create Dockerfile for ORDS (NO Oracle Registry - FIXED!)
# ═══════════════════════════════════════════════════════════════════════════════

step_04_create_dockerfile() {
    log_step "Creating ORDS Dockerfile (All Dependencies Inside)"
    
    cat > "$PROJECT_DIR/Dockerfile.ords" << 'DOCKERFILE'
################################################################################
# ORDS + APEX Container - Full Docker Edition v3.1.0
# Created by: Peyman Rasouli | KaizenixCore
# 
# This container includes:
#   - Java 17 (Eclipse Temurin)
#   - Oracle ORDS (latest)
#   - Oracle APEX (latest)
#   - All required tools (wget, unzip, curl)
#
# NO Oracle Registry login required!
# SQL commands run via docker exec to oracle-db container
################################################################################

FROM eclipse-temurin:17-jdk-jammy

LABEL maintainer="Peyman Rasouli <KaizenixCore>"
LABEL description="Oracle ORDS with APEX - Full Docker Edition"
LABEL version="3.1.0"

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /opt/oracle/ords \
    && mkdir -p /opt/oracle/apex \
    && mkdir -p /opt/oracle/images \
    && mkdir -p /opt/oracle/ords_config/databases/default \
    && mkdir -p /opt/oracle/ords_config/global \
    && mkdir -p /opt/oracle/scripts \
    && mkdir -p /opt/oracle/logs

WORKDIR /opt/oracle

# Download APEX and ORDS (inside container - no wget needed on host!)
RUN echo "📥 Downloading APEX..." \
    && wget -q --show-progress --progress=bar:force -O apex-latest.zip \
       "https://download.oracle.com/otn_software/apex/apex-latest.zip" \
    && echo "📥 Downloading ORDS..." \
    && wget -q --show-progress --progress=bar:force -O ords-latest.zip \
       "https://download.oracle.com/otn_software/java/ords/ords-latest.zip" \
    && echo "📦 Extracting APEX..." \
    && unzip -q apex-latest.zip \
    && cp -r apex/images/* /opt/oracle/images/ \
    && echo "📦 Extracting ORDS..." \
    && unzip -q ords-latest.zip -d /opt/oracle/ords \
    && rm -f apex-latest.zip ords-latest.zip \
    && chmod +x /opt/oracle/ords/bin/ords \
    && echo "✅ Downloads complete!"

# Environment variables
ENV ORDS_HOME=/opt/oracle/ords
ENV ORDS_CONFIG=/opt/oracle/ords_config
ENV APEX_HOME=/opt/oracle/apex
ENV APEX_IMAGES=/opt/oracle/images
ENV PATH="${ORDS_HOME}/bin:${PATH}"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=10 \
    CMD curl -f http://localhost:8080/ords/ || exit 1

# Default command - will be overridden by entrypoint in compose
CMD ["ords", "--config", "/opt/oracle/ords_config", "serve", "--port", "8080", "--apex-images", "/opt/oracle/images"]
DOCKERFILE

    log_success "Dockerfile created (No Oracle Registry required!)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5: Create Setup Script (runs on host, uses docker exec)
# ═══════════════════════════════════════════════════════════════════════════════

step_05_create_setup_script() {
    log_step "Creating Setup Script"
    
    cat > "$SCRIPTS_DIR/setup-apex.sh" << 'SETUPSCRIPT'
#!/bin/bash
################################################################################
# APEX Setup Script - Runs on host, configures database via docker exec
# Created by: Peyman Rasouli | KaizenixCore
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"
LOG_DIR="$PROJECT_DIR/logs"
DATA_DIR="$PROJECT_DIR/data"

ORACLE_PASSWORD=$(cat "$CONFIG_DIR/.db_password")
APEX_ADMIN_PASSWORD=$(cat "$CONFIG_DIR/.apex_password")

DB_CONTAINER="oracle-apex-db"
ORDS_CONTAINER="oracle-apex-ords"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "  ${BLUE}ℹ${NC}  $*"; }
log_success() { echo -e "  ${GREEN}✓${NC}  $*"; }
log_warning() { echo -e "  ${YELLOW}⚠${NC}  $*"; }
log_error() { echo -e "  ${RED}✗${NC}  $*"; }

# ═══════════════════════════════════════════════════════════════════════════════
# Wait for database
# ═══════════════════════════════════════════════════════════════════════════════

wait_for_db() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ⏳ Waiting for Oracle Database to be ready..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local max_attempts=120
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker logs $DB_CONTAINER 2>&1 | grep -q "DATABASE IS READY"; then
            log_success "Database reports READY"
            sleep 30
            return 0
        fi
        
        echo -ne "\r  ⏳ Attempt $attempt/$max_attempts - waiting...    "
        sleep 10
        attempt=$((attempt + 1))
    done
    
    log_error "Database timeout!"
    return 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# Run SQL command
# ═══════════════════════════════════════════════════════════════════════════════

run_sql() {
    local sql="$1"
    docker exec $DB_CONTAINER bash -c "echo \"$sql\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>&1
}

run_sql_script() {
    local script="$1"
    docker exec $DB_CONTAINER bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
$script
EXIT;
EOSQL" 2>&1
}

# ═══════════════════════════════════════════════════════════════════════════════
# Check if APEX installed
# ═══════════════════════════════════════════════════════════════════════════════

check_apex_installed() {
    local count=$(run_sql "SELECT COUNT(*) FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%';" | grep -E "^[[:space:]]*[0-9]+" | head -1 | tr -d ' ')
    [ "$count" -gt 0 ] 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# Copy APEX to database container
# ═══════════════════════════════════════════════════════════════════════════════

copy_apex_to_db() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📦 Copying APEX files to database container..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Copy from ORDS container to host, then to DB container
    docker cp $ORDS_CONTAINER:/opt/oracle/apex "$DATA_DIR/"
    docker cp "$DATA_DIR/apex" $DB_CONTAINER:/opt/oracle/
    
    log_success "APEX files copied to database container"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Install APEX
# ═══════════════════════════════════════════════════════════════════════════════

install_apex() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📦 Installing Oracle APEX into Database"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if check_apex_installed; then
        log_success "APEX is already installed, skipping..."
        return 0
    fi
    
    log_warning "Installing APEX (this takes 15-25 minutes)..."
    log_info "☕ Time for coffee!"
    echo ""
    
    docker exec $DB_CONTAINER bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
WHENEVER SQLERROR CONTINUE
SET TIMING ON
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/apex_install.log" | grep -iE "phase|complete|error|timing" || true

    sleep 30
    
    if check_apex_installed; then
        log_success "APEX installation completed!"
    else
        log_warning "APEX installation may have issues, continuing..."
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# Configure APEX REST
# ═══════════════════════════════════════════════════════════════════════════════

configure_apex_rest() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔧 Configuring APEX REST Services"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    docker exec $DB_CONTAINER bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/apex_rest.log" | grep -iE "complete|error" || true

    log_success "APEX REST configured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Disable password policies
# ═══════════════════════════════════════════════════════════════════════════════

disable_password_policies() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔓 Disabling Password Policies"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    run_sql_script "
ALTER PROFILE DEFAULT LIMIT
    FAILED_LOGIN_ATTEMPTS UNLIMITED
    PASSWORD_LOCK_TIME UNLIMITED
    PASSWORD_LIFE_TIME UNLIMITED
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
"
    log_success "Password policies disabled"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Create users
# ═══════════════════════════════════════════════════════════════════════════════

create_users() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  👤 Creating Database Users"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    run_sql_script "
SET SERVEROUTPUT ON

BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE TO ORDS_PUBLIC_USER;
GRANT CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

COMMIT;
" 2>&1 | tee "$LOG_DIR/users.log"

    log_success "Database users created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Grant proxy (Error 571 Fix)
# ═══════════════════════════════════════════════════════════════════════════════

grant_proxy() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔐 Granting Proxy Authentication (Error 571 Fix)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    run_sql_script "
SET SERVEROUTPUT ON

ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

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

GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_UTILITY TO ORDS_PUBLIC_USER;

COMMIT;

SELECT PROXY, CLIENT, AUTHENTICATION FROM DBA_PROXIES WHERE PROXY = 'ORDS_PUBLIC_USER';
" 2>&1 | tee "$LOG_DIR/proxy_grants.log"

    log_success "Proxy authentication granted"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Create APEX Admin
# ═══════════════════════════════════════════════════════════════════════════════

create_apex_admin() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  👑 Creating APEX Admin User"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local apex_schema=$(run_sql "SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;" | grep "^APEX_" | head -1 | tr -d ' ')
    
    [ -z "$apex_schema" ] && apex_schema="APEX_230200"
    
    log_info "Found APEX schema: $apex_schema"
    echo "$apex_schema" > "$CONFIG_DIR/.apex_schema"
    
    run_sql_script "
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
" 2>&1 | tee "$LOG_DIR/admin.log"

    log_success "APEX Admin user configured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Configure ORDS
# ═══════════════════════════════════════════════════════════════════════════════

configure_ords() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ⚙️ Configuring ORDS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    mkdir -p "$DATA_DIR/ords_config/databases/default"
    mkdir -p "$DATA_DIR/ords_config/global"
    
    # Create pool.xml
    cat > "$DATA_DIR/ords_config/databases/default/pool.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>Database Connection Pool - KaizenixCore Docker Edition v3.1.0</comment>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">oracle-db</entry>
<entry key="db.port">1521</entry>
<entry key="db.servicename">XEPDB1</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">${ORACLE_PASSWORD}</entry>
<entry key="plsql.gateway.mode">proxied</entry>
<entry key="feature.sdw">true</entry>
<entry key="restEnabledSql.active">true</entry>
<entry key="security.requestValidationFunction">wwv_flow_epg_include_modules.authorize</entry>
<entry key="jdbc.InitialLimit">3</entry>
<entry key="jdbc.MinLimit">1</entry>
<entry key="jdbc.MaxLimit">10</entry>
<entry key="jdbc.MaxConnectionReuseCount">1000</entry>
<entry key="jdbc.MaxConnectionReuseTime">900</entry>
</properties>
EOF

    # Create global settings
    cat > "$DATA_DIR/ords_config/global/settings.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>ORDS Global Settings</comment>
<entry key="database.api.enabled">true</entry>
<entry key="debug.printDebugToScreen">true</entry>
<entry key="misc.pagination.maxRows">1000</entry>
<entry key="security.verifySSL">false</entry>
</properties>
EOF

    # Create standalone settings
    cat > "$DATA_DIR/ords_config/settings.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>ORDS Standalone Settings</comment>
<entry key="standalone.context.path">/ords</entry>
<entry key="standalone.http.port">8080</entry>
<entry key="standalone.static.context.path">/i</entry>
<entry key="standalone.static.path">/opt/oracle/images</entry>
<entry key="standalone.doc.root">/opt/oracle/images</entry>
</properties>
EOF

    log_success "ORDS configuration files created"
    
    # Install ORDS schema
    log_info "Installing ORDS schema into database..."
    
    docker exec $ORDS_CONTAINER bash -c "echo '${ORACLE_PASSWORD}' | /opt/oracle/ords/bin/ords --config /opt/oracle/ords_config install \
        --admin-user sys \
        --db-hostname oracle-db \
        --db-port 1521 \
        --db-servicename XEPDB1 \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --password-stdin" 2>&1 | tee "$LOG_DIR/ords_install.log" || true
    
    log_success "ORDS schema installed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Restart ORDS
# ═══════════════════════════════════════════════════════════════════════════════

restart_ords() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔄 Restarting ORDS Container"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd "$PROJECT_DIR"
    
    if docker compose version &>/dev/null; then
        docker compose restart ords
    else
        docker-compose restart ords
    fi
    
    log_info "Waiting 60s for ORDS to restart..."
    sleep 60
    
    log_success "ORDS restarted"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Verify installation
# ═══════════════════════════════════════════════════════════════════════════════

verify_installation() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ✅ Verifying Installation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local ords_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/" 2>/dev/null || echo "000")
    local apex_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
    
    echo ""
    if [[ "$ords_code" =~ ^(200|301|302|303)$ ]]; then
        log_success "ORDS Root: http://localhost:8080/ords/ (HTTP $ords_code)"
    else
        log_warning "ORDS Root: HTTP $ords_code"
    fi
    
    if [[ "$apex_code" =~ ^(200|301|302|303)$ ]]; then
        log_success "APEX Admin: http://localhost:8080/ords/apex_admin (HTTP $apex_code)"
    else
        log_warning "APEX Admin: HTTP $apex_code"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║        🚀 APEX Setup Script - KaizenixCore v3.1.0                 ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Check if already setup
    if [ -f "$CONFIG_DIR/.setup_complete" ]; then
        log_info "Setup already completed. To re-run, delete: $CONFIG_DIR/.setup_complete"
        verify_installation
        exit 0
    fi
    
    wait_for_db
    copy_apex_to_db
    disable_password_policies
    install_apex
    configure_apex_rest
    create_users
    grant_proxy
    create_apex_admin
    configure_ords
    restart_ords
    verify_installation
    
    # Mark setup complete
    touch "$CONFIG_DIR/.setup_complete"
    
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║           🎉 SETUP COMPLETED SUCCESSFULLY! 🎉                     ║"
    echo "║                                                                   ║"
    echo "╠═══════════════════════════════════════════════════════════════════╣"
    echo "║                                                                   ║"
    echo "║   🌐 Admin Panel: http://localhost:8080/ords/apex_admin           ║"
    echo "║   🔐 Login Page:  http://localhost:8080/ords/f?p=4550             ║"
    echo "║                                                                   ║"
    echo "║   📋 Credentials:                                                 ║"
    echo "║      Workspace: INTERNAL                                          ║"
    echo "║      Username:  ADMIN                                             ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""
}

main "$@"
SETUPSCRIPT

    chmod +x "$SCRIPTS_DIR/setup-apex.sh"
    log_success "Setup script created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 6: Create Docker Compose
# ═══════════════════════════════════════════════════════════════════════════════

step_06_create_docker_compose() {
    log_step "Creating Docker Compose Configuration"
    
    cat > "$PROJECT_DIR/docker-compose.yml" << EOF
################################################################################
# Oracle APEX Full Docker Stack v3.1.0
# Created by: Peyman Rasouli | KaizenixCore
#
# This stack runs 100% in Docker:
#   - Oracle Database XE 21c
#   - ORDS + APEX (with Java, wget, unzip inside container)
#
# Only the database files are stored on your system!
################################################################################

services:
  # ═══════════════════════════════════════════════════════════════════════════
  # Oracle Database XE 21c
  # ═══════════════════════════════════════════════════════════════════════════
  oracle-db:
    image: ${ORACLE_IMAGE}
    container_name: oracle-apex-db
    hostname: oracle-db
    environment:
      - ORACLE_PASSWORD=${ORACLE_PASSWORD}
    ports:
      - "${DB_PORT}:1521"
    volumes:
      - ${DATA_DIR}/oradata:/opt/oracle/oradata
    shm_size: 2g
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 30
      start_period: 300s
    networks:
      - apex-network

  # ═══════════════════════════════════════════════════════════════════════════
  # ORDS + APEX Container (Java, wget, unzip all inside!)
  # ═══════════════════════════════════════════════════════════════════════════
  ords:
    build:
      context: .
      dockerfile: Dockerfile.ords
    container_name: oracle-apex-ords
    hostname: ords
    environment:
      - DB_HOST=oracle-db
      - DB_PORT=1521
      - DB_SERVICE=XEPDB1
      - ORACLE_PASSWORD=${ORACLE_PASSWORD}
      - APEX_ADMIN_PASSWORD=${APEX_ADMIN_PASSWORD}
      - ORDS_PORT=8080
    ports:
      - "${ORDS_PORT}:8080"
    volumes:
      - ${DATA_DIR}/ords_config:/opt/oracle/ords_config
    depends_on:
      oracle-db:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - apex-network
    command: ["ords", "--config", "/opt/oracle/ords_config", "serve", "--port", "8080", "--apex-images", "/opt/oracle/images"]

# ═══════════════════════════════════════════════════════════════════════════
# Network
# ═══════════════════════════════════════════════════════════════════════════
networks:
  apex-network:
    driver: bridge
    name: apex-network
EOF

    log_success "Docker Compose file created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 7: Create Management Scripts
# ═══════════════════════════════════════════════════════════════════════════════

step_07_create_scripts() {
    log_step "Creating Management Scripts"

    # Start script
    cat > "$SCRIPTS_DIR/start.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "🚀 Starting Oracle APEX (Full Docker)..."

if docker compose version &>/dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

echo ""
echo "⏳ Services are starting..."
echo "   Database takes 3-5 minutes to initialize."
echo ""
echo "📊 Check status: bash $SCRIPT_DIR/status.sh"
echo "📜 View logs: bash $SCRIPT_DIR/logs.sh"
echo ""
echo "🔧 After database is ready, run setup:"
echo "   bash $SCRIPT_DIR/setup-apex.sh"
SCRIPT

    # Stop script
    cat > "$SCRIPTS_DIR/stop.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "⏹️ Stopping Oracle APEX..."

if docker compose version &>/dev/null; then
    docker compose down
else
    docker-compose down
fi

echo "✅ Stopped"
SCRIPT

    # Status script
    cat > "$SCRIPTS_DIR/status.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                    📊 ORACLE APEX STATUS                          ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

if docker compose version &>/dev/null; then
    docker compose ps
else
    docker-compose ps
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check database
if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
    echo "  ✅ Database: READY"
else
    echo "  ⏳ Database: Starting..."
fi

HTTP_ORDS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
HTTP_APEX=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")

echo ""
if [[ "$HTTP_ORDS" =~ ^(200|301|302|303)$ ]]; then
    echo "  ✅ ORDS:       http://localhost:8080/ords/ (HTTP $HTTP_ORDS)"
else
    echo "  ⚠️  ORDS:       Not responding (HTTP $HTTP_ORDS)"
fi

if [[ "$HTTP_APEX" =~ ^(200|301|302|303)$ ]]; then
    echo "  ✅ APEX Admin: http://localhost:8080/ords/apex_admin (HTTP $HTTP_APEX)"
else
    echo "  ⚠️  APEX Admin: Not responding (HTTP $HTTP_APEX)"
fi
echo ""
SCRIPT

    # Logs script
    cat > "$SCRIPTS_DIR/logs.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

if docker compose version &>/dev/null; then
    docker compose logs -f --tail=100
else
    docker-compose logs -f --tail=100
fi
SCRIPT

    # Restart script
    cat > "$SCRIPTS_DIR/restart.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "🔄 Restarting Oracle APEX..."

if docker compose version &>/dev/null; then
    docker compose restart
else
    docker-compose restart
fi

echo "✅ Restarted"
SCRIPT

    # Fix script
    cat > "$SCRIPTS_DIR/fix.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"

cd "$PROJECT_DIR"

PASS=$(cat "$CONFIG_DIR/.db_password")

echo "🔧 Running comprehensive fix..."
echo ""

echo "Fixing database accounts and proxy permissions..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << EOF
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;

ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

COMMIT;
EXIT;
EOF"

echo ""
echo "Restarting ORDS container..."

if docker compose version &>/dev/null; then
    docker compose restart ords
else
    docker-compose restart ords
fi

echo ""
echo "Waiting 60s for ORDS to restart..."
sleep 60

bash "$SCRIPT_DIR/status.sh"
SCRIPT

    # Reset password script
    cat > "$SCRIPTS_DIR/reset-apex-password.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"

PASS=$(cat "$CONFIG_DIR/.db_password")
read -p "Enter new APEX Admin password: " NEW_PASS

APEX_SCHEMA=$(cat "$CONFIG_DIR/.apex_schema" 2>/dev/null)
if [ -z "$APEX_SCHEMA" ]; then
    APEX_SCHEMA=$(docker exec oracle-apex-db bash -c "echo \"SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep "^APEX_" | head -1 | tr -d ' ')
fi

echo "Using APEX schema: $APEX_SCHEMA"

docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << EOF
BEGIN
    ${APEX_SCHEMA}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    ${APEX_SCHEMA}.APEX_UTIL.EDIT_USER(
        p_user_id => ${APEX_SCHEMA}.APEX_UTIL.GET_USER_ID('ADMIN'),
        p_user_name => 'ADMIN',
        p_web_password => '${NEW_PASS}',
        p_new_password => '${NEW_PASS}',
        p_change_password_on_first_use => 'N',
        p_account_locked => 'N'
    );
    COMMIT;
END;
/
EXIT;
EOF"

echo "✅ Password updated!"
echo "$NEW_PASS" > "$CONFIG_DIR/.apex_password"
SCRIPT

    chmod +x "$SCRIPTS_DIR"/*.sh
    log_success "Management scripts created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 8: Create GUI Launcher
# ═══════════════════════════════════════════════════════════════════════════════

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
#  ║     ORACLE APEX ULTIMATE INSTALLER v3.1.0 - FULL DOCKER EDITION           ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore                             ║
#  ║  License    : MIT                                                         ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║                           FEATURES                                        ║
#  ├───────────────────────────────────────────────────────────────────────────┤
#  ║  ✅ 100% Docker-based - No local dependencies (Java, wget, unzip)         ║
#  ║  ✅ Cross-Platform: Linux, macOS, Windows (Docker Desktop)                ║
#  ║  ✅ Fully Automated Oracle APEX + ORDS + XE 21c Installation              ║
#  ║  ✅ Persistent Data Storage on Host System                                ║
#  ║  ✅ Error 571 & Proxy Authentication - FIXED                              ║
#  ║  ✅ Multi-Language GUI (English/Persian/German)                           ║
#  ║  ✅ Modern UI/UX with Zenity                                              ║
#  ║  ✅ One-Click Browser Launch                                              ║
#  ║  ✅ Desktop Application (.desktop file)                                   ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e
trap 'handle_error $LINENO' ERR

VERSION="3.1.0"
PROJECT_DIR="$HOME/oracle-apex-docker"
DATA_DIR="$PROJECT_DIR/data"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
CONFIG_DIR="$PROJECT_DIR/config"
LOG_DIR="$PROJECT_DIR/logs"

DB_HOST="oracle-db"
DB_SERVICE="XEPDB1"
DB_PORT="1521"
ORDS_PORT="8080"

ORACLE_IMAGE="gvenzl/oracle-xe:21-full"

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
TOTAL_STEPS=12

# ═══════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

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
    echo -e "${WHITE}${BOLD}  ║${NC}   ${MAGENTA}${BOLD}ORACLE APEX ULTIMATE INSTALLER${NC} ${WHITE}v${VERSION}${NC} ${CYAN}[FULL DOCKER]${NC}      ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} 100% Docker    ${GREEN}✓${NC} Cross-Platform    ${GREEN}✓${NC} One Command        ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}Created by:${NC} ${CYAN}Peyman Rasouli${NC}                                    ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}Project:${NC}    ${MAGENTA}KaizenixCore${NC}                                       ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}GitHub:${NC}     ${BLUE}https://github.com/KaizenixCore${NC}                     ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

get_passwords() {
    echo ""
    echo -e "${CYAN}${BOLD}  ┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                   ${WHITE}${BOLD}🔐 PASSWORD CONFIGURATION${NC}                    ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  └─────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}Important:${NC} Password must contain only letters and numbers"
    echo -e "  ${YELLOW}${BOLD}           ${NC}(no special characters), minimum 8 characters"
    echo ""

    while true; do
        read -p "  Enter Oracle Database Password: " ORACLE_PASSWORD
        echo
        read -p "  Enter APEX Admin Password: " APEX_ADMIN_PASSWORD
        echo

        if [[ ! "$ORACLE_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{7,}$ ]]; then
            echo -e "  ${RED}✗ Password must start with letter, only letters/numbers, min 8 chars${NC}"
            continue
        fi

        if [[ ! "$APEX_ADMIN_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{7,}$ ]]; then
            echo -e "  ${RED}✗ APEX Password must start with letter, only letters/numbers, min 8 chars${NC}"
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
    echo -e "${RED}${BOLD}  ║${NC}  Docker: ${CYAN}docker compose logs${NC}"
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

detect_os() {
    case "$(uname -s)" in
        Linux*)     OS_TYPE="linux" ;;
        Darwin*)    OS_TYPE="macos" ;;
        MINGW*|MSYS*|CYGWIN*) OS_TYPE="windows" ;;
        *)          OS_TYPE="unknown" ;;
    esac
    echo "$OS_TYPE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1: Check Docker
# ═══════════════════════════════════════════════════════════════════════════════

step_01_check_docker() {
    log_step "Checking Docker Installation"
    
    if ! command -v docker &>/dev/null; then
        log_error "Docker is not installed!"
        echo ""
        echo -e "${YELLOW}  Please install Docker first:${NC}"
        echo ""
        case $(detect_os) in
            linux)
                echo -e "  ${CYAN}curl -fsSL https://get.docker.com | sh${NC}"
                echo -e "  ${CYAN}sudo usermod -aG docker \$USER${NC}"
                echo -e "  ${CYAN}newgrp docker${NC}"
                ;;
            macos)
                echo -e "  ${CYAN}https://docs.docker.com/desktop/install/mac-install/${NC}"
                echo -e "  Or: ${CYAN}brew install --cask docker${NC}"
                ;;
            windows)
                echo -e "  ${CYAN}https://docs.docker.com/desktop/install/windows-install/${NC}"
                ;;
        esac
        echo ""
        exit 1
    fi
    
    if ! docker info &>/dev/null; then
        log_error "Docker is not running!"
        echo ""
        case $(detect_os) in
            linux)
                echo -e "  ${YELLOW}Run: ${CYAN}sudo systemctl start docker${NC}"
                ;;
            macos|windows)
                echo -e "  ${YELLOW}Please start Docker Desktop${NC}"
                ;;
        esac
        echo ""
        exit 1
    fi
    
    log_success "Docker is installed and running"
    log_info "Docker version: $(docker --version | cut -d' ' -f3 | tr -d ',')"
    
    # Check docker compose
    if docker compose version &>/dev/null; then
        COMPOSE_CMD="docker compose"
        log_success "Docker Compose (plugin) available"
    elif command -v docker-compose &>/dev/null; then
        COMPOSE_CMD="docker-compose"
        log_success "Docker Compose (standalone) available"
    else
        log_error "Docker Compose not found!"
        exit 1
    fi
    
    # Check disk space
    local free=$(df -BG "$HOME" 2>/dev/null | awk 'NR==2{print $4}' | sed 's/G//' || echo "20")
    [ "$free" -lt 15 ] && { log_error "Need 15GB free space, have ${free}GB"; exit 1; }
    log_success "Disk Space: ${free}GB available"
    
    log_info "OS: $(detect_os)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 2: Initialize Project
# ═══════════════════════════════════════════════════════════════════════════════

step_02_init() {
    log_step "Initializing Project Directories"
    
    mkdir -p "$PROJECT_DIR"
    mkdir -p "$DATA_DIR/oradata"
    mkdir -p "$DATA_DIR/ords_config"
    mkdir -p "$DATA_DIR/apex"
    mkdir -p "$SCRIPTS_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"
    
    # Save passwords securely
    echo "$ORACLE_PASSWORD" > "$CONFIG_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$CONFIG_DIR/.apex_password"
    chmod 600 "$CONFIG_DIR/.db_password" "$CONFIG_DIR/.apex_password"
    
    log_success "Directories created at: $PROJECT_DIR"
    log_info "Database data will be stored at: $DATA_DIR/oradata"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3: Cleanup Previous Installation
# ═══════════════════════════════════════════════════════════════════════════════

step_03_cleanup() {
    log_step "Cleanup Previous Installation"

    read -p "  Clean old installation? [Y/n]: " confirm
    [[ $confirm =~ ^[Nn]$ ]] && { log_info "Skipped"; return; }

    log_info "Cleaning..."
    
    cd "$PROJECT_DIR" 2>/dev/null || true
    $COMPOSE_CMD down -v 2>/dev/null || true
    
    docker stop oracle-apex-db oracle-apex-ords 2>/dev/null || true
    docker rm -f oracle-apex-db oracle-apex-ords 2>/dev/null || true
    docker network rm apex-network 2>/dev/null || true
    
    # Keep data directory but clean config
    rm -rf "$DATA_DIR/ords_config"/* 2>/dev/null || true
    rm -rf "$DATA_DIR/apex"/* 2>/dev/null || true
    rm -f "$PROJECT_DIR/docker-compose.yml" 2>/dev/null || true
    rm -f "$PROJECT_DIR/Dockerfile.ords" 2>/dev/null || true
    rm -f "$CONFIG_DIR/.setup_complete" 2>/dev/null || true
    
    mkdir -p "$DATA_DIR/oradata"
    mkdir -p "$DATA_DIR/ords_config"
    mkdir -p "$DATA_DIR/apex"
    
    log_success "Cleanup completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4: Create Dockerfile for ORDS (NO Oracle Registry - FIXED!)
# ═══════════════════════════════════════════════════════════════════════════════

step_04_create_dockerfile() {
    log_step "Creating ORDS Dockerfile (All Dependencies Inside)"
    
    cat > "$PROJECT_DIR/Dockerfile.ords" << 'DOCKERFILE'
################################################################################
# ORDS + APEX Container - Full Docker Edition v3.1.0
# Created by: Peyman Rasouli | KaizenixCore
# 
# This container includes:
#   - Java 17 (Eclipse Temurin)
#   - Oracle ORDS (latest)
#   - Oracle APEX (latest)
#   - All required tools (wget, unzip, curl)
#
# NO Oracle Registry login required!
# SQL commands run via docker exec to oracle-db container
################################################################################

FROM eclipse-temurin:17-jdk-jammy

LABEL maintainer="Peyman Rasouli <KaizenixCore>"
LABEL description="Oracle ORDS with APEX - Full Docker Edition"
LABEL version="3.1.0"

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /opt/oracle/ords \
    && mkdir -p /opt/oracle/apex \
    && mkdir -p /opt/oracle/images \
    && mkdir -p /opt/oracle/ords_config/databases/default \
    && mkdir -p /opt/oracle/ords_config/global \
    && mkdir -p /opt/oracle/scripts \
    && mkdir -p /opt/oracle/logs

WORKDIR /opt/oracle

# Download APEX and ORDS (inside container - no wget needed on host!)
RUN echo "📥 Downloading APEX..." \
    && wget -q --show-progress --progress=bar:force -O apex-latest.zip \
       "https://download.oracle.com/otn_software/apex/apex-latest.zip" \
    && echo "📥 Downloading ORDS..." \
    && wget -q --show-progress --progress=bar:force -O ords-latest.zip \
       "https://download.oracle.com/otn_software/java/ords/ords-latest.zip" \
    && echo "📦 Extracting APEX..." \
    && unzip -q apex-latest.zip \
    && cp -r apex/images/* /opt/oracle/images/ \
    && echo "📦 Extracting ORDS..." \
    && unzip -q ords-latest.zip -d /opt/oracle/ords \
    && rm -f apex-latest.zip ords-latest.zip \
    && chmod +x /opt/oracle/ords/bin/ords \
    && echo "✅ Downloads complete!"

# Environment variables
ENV ORDS_HOME=/opt/oracle/ords
ENV ORDS_CONFIG=/opt/oracle/ords_config
ENV APEX_HOME=/opt/oracle/apex
ENV APEX_IMAGES=/opt/oracle/images
ENV PATH="${ORDS_HOME}/bin:${PATH}"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=10 \
    CMD curl -f http://localhost:8080/ords/ || exit 1

# Default command - will be overridden by entrypoint in compose
CMD ["ords", "--config", "/opt/oracle/ords_config", "serve", "--port", "8080", "--apex-images", "/opt/oracle/images"]
DOCKERFILE

    log_success "Dockerfile created (No Oracle Registry required!)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5: Create Setup Script (runs on host, uses docker exec)
# ═══════════════════════════════════════════════════════════════════════════════

step_05_create_setup_script() {
    log_step "Creating Setup Script"
    
    cat > "$SCRIPTS_DIR/setup-apex.sh" << 'SETUPSCRIPT'
#!/bin/bash
################################################################################
# APEX Setup Script - Runs on host, configures database via docker exec
# Created by: Peyman Rasouli | KaizenixCore
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"
LOG_DIR="$PROJECT_DIR/logs"
DATA_DIR="$PROJECT_DIR/data"

ORACLE_PASSWORD=$(cat "$CONFIG_DIR/.db_password")
APEX_ADMIN_PASSWORD=$(cat "$CONFIG_DIR/.apex_password")

DB_CONTAINER="oracle-apex-db"
ORDS_CONTAINER="oracle-apex-ords"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "  ${BLUE}ℹ${NC}  $*"; }
log_success() { echo -e "  ${GREEN}✓${NC}  $*"; }
log_warning() { echo -e "  ${YELLOW}⚠${NC}  $*"; }
log_error() { echo -e "  ${RED}✗${NC}  $*"; }

# ═══════════════════════════════════════════════════════════════════════════════
# Wait for database
# ═══════════════════════════════════════════════════════════════════════════════

wait_for_db() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ⏳ Waiting for Oracle Database to be ready..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local max_attempts=120
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker logs $DB_CONTAINER 2>&1 | grep -q "DATABASE IS READY"; then
            log_success "Database reports READY"
            sleep 30
            return 0
        fi
        
        echo -ne "\r  ⏳ Attempt $attempt/$max_attempts - waiting...    "
        sleep 10
        attempt=$((attempt + 1))
    done
    
    log_error "Database timeout!"
    return 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# Run SQL command
# ═══════════════════════════════════════════════════════════════════════════════

run_sql() {
    local sql="$1"
    docker exec $DB_CONTAINER bash -c "echo \"$sql\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>&1
}

run_sql_script() {
    local script="$1"
    docker exec $DB_CONTAINER bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
$script
EXIT;
EOSQL" 2>&1
}

# ═══════════════════════════════════════════════════════════════════════════════
# Check if APEX installed
# ═══════════════════════════════════════════════════════════════════════════════

check_apex_installed() {
    local count=$(run_sql "SELECT COUNT(*) FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%';" | grep -E "^[[:space:]]*[0-9]+" | head -1 | tr -d ' ')
    [ "$count" -gt 0 ] 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# Copy APEX to database container
# ═══════════════════════════════════════════════════════════════════════════════

copy_apex_to_db() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📦 Copying APEX files to database container..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Copy from ORDS container to host, then to DB container
    docker cp $ORDS_CONTAINER:/opt/oracle/apex "$DATA_DIR/"
    docker cp "$DATA_DIR/apex" $DB_CONTAINER:/opt/oracle/
    
    log_success "APEX files copied to database container"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Install APEX
# ═══════════════════════════════════════════════════════════════════════════════

install_apex() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📦 Installing Oracle APEX into Database"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if check_apex_installed; then
        log_success "APEX is already installed, skipping..."
        return 0
    fi
    
    log_warning "Installing APEX (this takes 15-25 minutes)..."
    log_info "☕ Time for coffee!"
    echo ""
    
    docker exec $DB_CONTAINER bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
WHENEVER SQLERROR CONTINUE
SET TIMING ON
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/apex_install.log" | grep -iE "phase|complete|error|timing" || true

    sleep 30
    
    if check_apex_installed; then
        log_success "APEX installation completed!"
    else
        log_warning "APEX installation may have issues, continuing..."
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# Configure APEX REST
# ═══════════════════════════════════════════════════════════════════════════════

configure_apex_rest() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔧 Configuring APEX REST Services"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    docker exec $DB_CONTAINER bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/apex_rest.log" | grep -iE "complete|error" || true

    log_success "APEX REST configured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Disable password policies
# ═══════════════════════════════════════════════════════════════════════════════

disable_password_policies() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔓 Disabling Password Policies"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    run_sql_script "
ALTER PROFILE DEFAULT LIMIT
    FAILED_LOGIN_ATTEMPTS UNLIMITED
    PASSWORD_LOCK_TIME UNLIMITED
    PASSWORD_LIFE_TIME UNLIMITED
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
"
    log_success "Password policies disabled"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Create users
# ═══════════════════════════════════════════════════════════════════════════════

create_users() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  👤 Creating Database Users"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    run_sql_script "
SET SERVEROUTPUT ON

BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE TO ORDS_PUBLIC_USER;
GRANT CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

COMMIT;
" 2>&1 | tee "$LOG_DIR/users.log"

    log_success "Database users created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Grant proxy (Error 571 Fix)
# ═══════════════════════════════════════════════════════════════════════════════

grant_proxy() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔐 Granting Proxy Authentication (Error 571 Fix)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    run_sql_script "
SET SERVEROUTPUT ON

ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

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

GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_UTILITY TO ORDS_PUBLIC_USER;

COMMIT;

SELECT PROXY, CLIENT, AUTHENTICATION FROM DBA_PROXIES WHERE PROXY = 'ORDS_PUBLIC_USER';
" 2>&1 | tee "$LOG_DIR/proxy_grants.log"

    log_success "Proxy authentication granted"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Create APEX Admin
# ═══════════════════════════════════════════════════════════════════════════════

create_apex_admin() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  👑 Creating APEX Admin User"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local apex_schema=$(run_sql "SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;" | grep "^APEX_" | head -1 | tr -d ' ')
    
    [ -z "$apex_schema" ] && apex_schema="APEX_230200"
    
    log_info "Found APEX schema: $apex_schema"
    echo "$apex_schema" > "$CONFIG_DIR/.apex_schema"
    
    run_sql_script "
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
" 2>&1 | tee "$LOG_DIR/admin.log"

    log_success "APEX Admin user configured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Configure ORDS
# ═══════════════════════════════════════════════════════════════════════════════

configure_ords() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ⚙️ Configuring ORDS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    mkdir -p "$DATA_DIR/ords_config/databases/default"
    mkdir -p "$DATA_DIR/ords_config/global"
    
    # Create pool.xml
    cat > "$DATA_DIR/ords_config/databases/default/pool.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>Database Connection Pool - KaizenixCore Docker Edition v3.1.0</comment>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">oracle-db</entry>
<entry key="db.port">1521</entry>
<entry key="db.servicename">XEPDB1</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">${ORACLE_PASSWORD}</entry>
<entry key="plsql.gateway.mode">proxied</entry>
<entry key="feature.sdw">true</entry>
<entry key="restEnabledSql.active">true</entry>
<entry key="security.requestValidationFunction">wwv_flow_epg_include_modules.authorize</entry>
<entry key="jdbc.InitialLimit">3</entry>
<entry key="jdbc.MinLimit">1</entry>
<entry key="jdbc.MaxLimit">10</entry>
<entry key="jdbc.MaxConnectionReuseCount">1000</entry>
<entry key="jdbc.MaxConnectionReuseTime">900</entry>
</properties>
EOF

    # Create global settings
    cat > "$DATA_DIR/ords_config/global/settings.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>ORDS Global Settings</comment>
<entry key="database.api.enabled">true</entry>
<entry key="debug.printDebugToScreen">true</entry>
<entry key="misc.pagination.maxRows">1000</entry>
<entry key="security.verifySSL">false</entry>
</properties>
EOF

    # Create standalone settings
    cat > "$DATA_DIR/ords_config/settings.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>ORDS Standalone Settings</comment>
<entry key="standalone.context.path">/ords</entry>
<entry key="standalone.http.port">8080</entry>
<entry key="standalone.static.context.path">/i</entry>
<entry key="standalone.static.path">/opt/oracle/images</entry>
<entry key="standalone.doc.root">/opt/oracle/images</entry>
</properties>
EOF

    log_success "ORDS configuration files created"
    
    # Install ORDS schema
    log_info "Installing ORDS schema into database..."
    
    docker exec $ORDS_CONTAINER bash -c "echo '${ORACLE_PASSWORD}' | /opt/oracle/ords/bin/ords --config /opt/oracle/ords_config install \
        --admin-user sys \
        --db-hostname oracle-db \
        --db-port 1521 \
        --db-servicename XEPDB1 \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --password-stdin" 2>&1 | tee "$LOG_DIR/ords_install.log" || true
    
    log_success "ORDS schema installed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Restart ORDS
# ═══════════════════════════════════════════════════════════════════════════════

restart_ords() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔄 Restarting ORDS Container"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd "$PROJECT_DIR"
    
    if docker compose version &>/dev/null; then
        docker compose restart ords
    else
        docker-compose restart ords
    fi
    
    log_info "Waiting 60s for ORDS to restart..."
    sleep 60
    
    log_success "ORDS restarted"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Verify installation
# ═══════════════════════════════════════════════════════════════════════════════

verify_installation() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ✅ Verifying Installation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local ords_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/" 2>/dev/null || echo "000")
    local apex_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
    
    echo ""
    if [[ "$ords_code" =~ ^(200|301|302|303)$ ]]; then
        log_success "ORDS Root: http://localhost:8080/ords/ (HTTP $ords_code)"
    else
        log_warning "ORDS Root: HTTP $ords_code"
    fi
    
    if [[ "$apex_code" =~ ^(200|301|302|303)$ ]]; then
        log_success "APEX Admin: http://localhost:8080/ords/apex_admin (HTTP $apex_code)"
    else
        log_warning "APEX Admin: HTTP $apex_code"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║        🚀 APEX Setup Script - KaizenixCore v3.1.0                 ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Check if already setup
    if [ -f "$CONFIG_DIR/.setup_complete" ]; then
        log_info "Setup already completed. To re-run, delete: $CONFIG_DIR/.setup_complete"
        verify_installation
        exit 0
    fi
    
    wait_for_db
    copy_apex_to_db
    disable_password_policies
    install_apex
    configure_apex_rest
    create_users
    grant_proxy
    create_apex_admin
    configure_ords
    restart_ords
    verify_installation
    
    # Mark setup complete
    touch "$CONFIG_DIR/.setup_complete"
    
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║           🎉 SETUP COMPLETED SUCCESSFULLY! 🎉                     ║"
    echo "║                                                                   ║"
    echo "╠═══════════════════════════════════════════════════════════════════╣"
    echo "║                                                                   ║"
    echo "║   🌐 Admin Panel: http://localhost:8080/ords/apex_admin           ║"
    echo "║   🔐 Login Page:  http://localhost:8080/ords/f?p=4550             ║"
    echo "║                                                                   ║"
    echo "║   📋 Credentials:                                                 ║"
    echo "║      Workspace: INTERNAL                                          ║"
    echo "║      Username:  ADMIN                                             ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""
}

main "$@"
SETUPSCRIPT

    chmod +x "$SCRIPTS_DIR/setup-apex.sh"
    log_success "Setup script created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 6: Create Docker Compose
# ═══════════════════════════════════════════════════════════════════════════════

step_06_create_docker_compose() {
    log_step "Creating Docker Compose Configuration"
    
    cat > "$PROJECT_DIR/docker-compose.yml" << EOF
################################################################################
# Oracle APEX Full Docker Stack v3.1.0
# Created by: Peyman Rasouli | KaizenixCore
#
# This stack runs 100% in Docker:
#   - Oracle Database XE 21c
#   - ORDS + APEX (with Java, wget, unzip inside container)
#
# Only the database files are stored on your system!
################################################################################

services:
  # ═══════════════════════════════════════════════════════════════════════════
  # Oracle Database XE 21c
  # ═══════════════════════════════════════════════════════════════════════════
  oracle-db:
    image: ${ORACLE_IMAGE}
    container_name: oracle-apex-db
    hostname: oracle-db
    environment:
      - ORACLE_PASSWORD=${ORACLE_PASSWORD}
    ports:
      - "${DB_PORT}:1521"
    volumes:
      - ${DATA_DIR}/oradata:/opt/oracle/oradata
    shm_size: 2g
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 30
      start_period: 300s
    networks:
      - apex-network

  # ═══════════════════════════════════════════════════════════════════════════
  # ORDS + APEX Container (Java, wget, unzip all inside!)
  # ═══════════════════════════════════════════════════════════════════════════
  ords:
    build:
      context: .
      dockerfile: Dockerfile.ords
    container_name: oracle-apex-ords
    hostname: ords
    environment:
      - DB_HOST=oracle-db
      - DB_PORT=1521
      - DB_SERVICE=XEPDB1
      - ORACLE_PASSWORD=${ORACLE_PASSWORD}
      - APEX_ADMIN_PASSWORD=${APEX_ADMIN_PASSWORD}
      - ORDS_PORT=8080
    ports:
      - "${ORDS_PORT}:8080"
    volumes:
      - ${DATA_DIR}/ords_config:/opt/oracle/ords_config
    depends_on:
      oracle-db:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - apex-network
    command: ["ords", "--config", "/opt/oracle/ords_config", "serve", "--port", "8080", "--apex-images", "/opt/oracle/images"]

# ═══════════════════════════════════════════════════════════════════════════
# Network
# ═══════════════════════════════════════════════════════════════════════════
networks:
  apex-network:
    driver: bridge
    name: apex-network
EOF

    log_success "Docker Compose file created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 7: Create Management Scripts
# ═══════════════════════════════════════════════════════════════════════════════

step_07_create_scripts() {
    log_step "Creating Management Scripts"

    # Start script
    cat > "$SCRIPTS_DIR/start.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "🚀 Starting Oracle APEX (Full Docker)..."

if docker compose version &>/dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

echo ""
echo "⏳ Services are starting..."
echo "   Database takes 3-5 minutes to initialize."
echo ""
echo "📊 Check status: bash $SCRIPT_DIR/status.sh"
echo "📜 View logs: bash $SCRIPT_DIR/logs.sh"
echo ""
echo "🔧 After database is ready, run setup:"
echo "   bash $SCRIPT_DIR/setup-apex.sh"
SCRIPT

    # Stop script
    cat > "$SCRIPTS_DIR/stop.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "⏹️ Stopping Oracle APEX..."

if docker compose version &>/dev/null; then
    docker compose down
else
    docker-compose down
fi

echo "✅ Stopped"
SCRIPT

    # Status script
    cat > "$SCRIPTS_DIR/status.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                    📊 ORACLE APEX STATUS                          ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

if docker compose version &>/dev/null; then
    docker compose ps
else
    docker-compose ps
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check database
if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
    echo "  ✅ Database: READY"
else
    echo "  ⏳ Database: Starting..."
fi

HTTP_ORDS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
HTTP_APEX=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")

echo ""
if [[ "$HTTP_ORDS" =~ ^(200|301|302|303)$ ]]; then
    echo "  ✅ ORDS:       http://localhost:8080/ords/ (HTTP $HTTP_ORDS)"
else
    echo "  ⚠️  ORDS:       Not responding (HTTP $HTTP_ORDS)"
fi

if [[ "$HTTP_APEX" =~ ^(200|301|302|303)$ ]]; then
    echo "  ✅ APEX Admin: http://localhost:8080/ords/apex_admin (HTTP $HTTP_APEX)"
else
    echo "  ⚠️  APEX Admin: Not responding (HTTP $HTTP_APEX)"
fi
echo ""
SCRIPT

    # Logs script
    cat > "$SCRIPTS_DIR/logs.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

if docker compose version &>/dev/null; then
    docker compose logs -f --tail=100
else
    docker-compose logs -f --tail=100
fi
SCRIPT

    # Restart script
    cat > "$SCRIPTS_DIR/restart.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "🔄 Restarting Oracle APEX..."

if docker compose version &>/dev/null; then
    docker compose restart
else
    docker-compose restart
fi

echo "✅ Restarted"
SCRIPT

    # Fix script
    cat > "$SCRIPTS_DIR/fix.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"

cd "$PROJECT_DIR"

PASS=$(cat "$CONFIG_DIR/.db_password")

echo "🔧 Running comprehensive fix..."
echo ""

echo "Fixing database accounts and proxy permissions..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << EOF
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;

ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

COMMIT;
EXIT;
EOF"

echo ""
echo "Restarting ORDS container..."

if docker compose version &>/dev/null; then
    docker compose restart ords
else
    docker-compose restart ords
fi

echo ""
echo "Waiting 60s for ORDS to restart..."
sleep 60

bash "$SCRIPT_DIR/status.sh"
SCRIPT

    # Reset password script
    cat > "$SCRIPTS_DIR/reset-apex-password.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"

PASS=$(cat "$CONFIG_DIR/.db_password")
read -p "Enter new APEX Admin password: " NEW_PASS

APEX_SCHEMA=$(cat "$CONFIG_DIR/.apex_schema" 2>/dev/null)
if [ -z "$APEX_SCHEMA" ]; then
    APEX_SCHEMA=$(docker exec oracle-apex-db bash -c "echo \"SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep "^APEX_" | head -1 | tr -d ' ')
fi

echo "Using APEX schema: $APEX_SCHEMA"

docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << EOF
BEGIN
    ${APEX_SCHEMA}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    ${APEX_SCHEMA}.APEX_UTIL.EDIT_USER(
        p_user_id => ${APEX_SCHEMA}.APEX_UTIL.GET_USER_ID('ADMIN'),
        p_user_name => 'ADMIN',
        p_web_password => '${NEW_PASS}',
        p_new_password => '${NEW_PASS}',
        p_change_password_on_first_use => 'N',
        p_account_locked => 'N'
    );
    COMMIT;
END;
/
EXIT;
EOF"

echo "✅ Password updated!"
echo "$NEW_PASS" > "$CONFIG_DIR/.apex_password"
SCRIPT

    chmod +x "$SCRIPTS_DIR"/*.sh
    log_success "Management scripts created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 8: Create GUI Launcher
# ═══════════════════════════════════════════════════════════════════════════════

step_08_create_gui() {
    log_step "Creating Multi-Language GUI Manager"

    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUISCRIPT'
#!/bin/bash
################################################################################
#  Oracle APEX Manager - Multi-Language GUI (Docker Edition)
#  Created by: Peyman Rasouli | KaizenixCore
#  Languages: English, فارسی, Deutsch
################################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR
