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
#  ║     ORACLE APEX ULTIMATE INSTALLER v3.0.0 - FULL DOCKER EDITION           ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/peymanrasouli                            ║
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

VERSION="3.0.0"
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
# HELPER FUNCTIONS (Original Code Preserved)
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
    echo -e "${WHITE}${BOLD}  ║${NC}  ${DIM}GitHub:${NC}     ${BLUE}https://github.com/peymanrasouli${NC}                   ${WHITE}${BOLD}║${NC}"
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
# STEP 1: Check Docker (Only Dependency Required!)
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
    rm -f "$PROJECT_DIR/docker-compose.yml" 2>/dev/null || true
    rm -f "$PROJECT_DIR/Dockerfile.ords" 2>/dev/null || true
    
    mkdir -p "$DATA_DIR/oradata"
    mkdir -p "$DATA_DIR/ords_config"
    
    log_success "Cleanup completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4: Create Dockerfile for ORDS (Contains APEX, ORDS, Java, wget, unzip)
# ═══════════════════════════════════════════════════════════════════════════════

step_04_create_dockerfile() {
    log_step "Creating ORDS Dockerfile (All Dependencies Inside)"
    
    cat > "$PROJECT_DIR/Dockerfile.ords" << 'DOCKERFILE'
################################################################################
# ORDS + APEX Container - Full Docker Edition
# Created by: Peyman Rasouli | KaizenixCore
# 
# This container includes:
#   - Java 17 (Eclipse Temurin)
#   - Oracle ORDS (latest)
#   - Oracle APEX (latest)
#   - All required tools (wget, unzip, curl, sqlplus)
#
# No dependencies required on host system!
################################################################################

FROM container-registry.oracle.com/database/instantclient:21 AS sqlplus

FROM eclipse-temurin:17-jdk-jammy

LABEL maintainer="Peyman Rasouli <KaizenixCore>"
LABEL description="Oracle ORDS with APEX - Full Docker Edition"
LABEL version="3.0.0"

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    netcat-openbsd \
    libaio1 \
    && rm -rf /var/lib/apt/lists/*

# Copy SQL*Plus from Oracle Instant Client
COPY --from=sqlplus /usr/lib/oracle /usr/lib/oracle
COPY --from=sqlplus /usr/share/oracle /usr/share/oracle
ENV PATH="/usr/lib/oracle/21/client64/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/lib/oracle/21/client64/lib:${LD_LIBRARY_PATH}"
ENV ORACLE_HOME="/usr/lib/oracle/21/client64"

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
RUN echo "📥 Downloading APEX (this may take a few minutes)..." \
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

# Copy entrypoint script
COPY scripts/ords-entrypoint.sh /opt/oracle/scripts/
RUN chmod +x /opt/oracle/scripts/ords-entrypoint.sh

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=5 \
    CMD curl -f http://localhost:8080/ords/ || exit 1

ENTRYPOINT ["/opt/oracle/scripts/ords-entrypoint.sh"]
DOCKERFILE

    log_success "Dockerfile created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5: Create ORDS Entrypoint Script
# ═══════════════════════════════════════════════════════════════════════════════

step_05_create_entrypoint() {
    log_step "Creating ORDS Entrypoint Script"
    
    mkdir -p "$PROJECT_DIR/scripts"
    
    cat > "$PROJECT_DIR/scripts/ords-entrypoint.sh" << 'ENTRYPOINT'
#!/bin/bash
################################################################################
# ORDS Entrypoint Script - Full Docker Edition
# Created by: Peyman Rasouli | KaizenixCore
#
# This script handles:
#   1. Wait for database to be ready
#   2. Install APEX into database (if not already installed)
#   3. Configure APEX REST services
#   4. Create required users and grant proxy permissions
#   5. Configure and start ORDS
################################################################################

set -e

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║        🚀 ORDS Container Starting - KaizenixCore v3.0.0           ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Configuration from environment
DB_HOST="${DB_HOST:-oracle-db}"
DB_PORT="${DB_PORT:-1521}"
DB_SERVICE="${DB_SERVICE:-XEPDB1}"
ORACLE_PASSWORD="${ORACLE_PASSWORD:-}"
APEX_ADMIN_PASSWORD="${APEX_ADMIN_PASSWORD:-}"
ORDS_PORT="${ORDS_PORT:-8080}"

# Connection string
DB_CONN="sys/${ORACLE_PASSWORD}@//${DB_HOST}:${DB_PORT}/${DB_SERVICE} as sysdba"

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

wait_for_db() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ⏳ Waiting for Oracle Database to be ready..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local max_attempts=120
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; then
            echo "  ✓ Database port is open, testing connection..."
            
            # Test actual SQL connection
            if echo "SELECT 1 FROM DUAL;" | sqlplus -s "$DB_CONN" 2>/dev/null | grep -q "1"; then
                echo "  ✅ Database connection successful!"
                sleep 30  # Extra wait for stability
                return 0
            fi
        fi
        
        echo "  ⏳ Attempt $attempt/$max_attempts - waiting for database..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo "  ❌ Database connection timeout!"
    exit 1
}

check_apex_installed() {
    local count=$(echo "SELECT COUNT(*) FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%';" | \
        sqlplus -s "$DB_CONN" 2>/dev/null | grep -E "^[[:space:]]*[0-9]+" | head -1 | tr -d ' ')
    [ "$count" -gt 0 ] 2>/dev/null
}

install_apex() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📦 Installing Oracle APEX into Database"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if check_apex_installed; then
        echo "  ✅ APEX is already installed, skipping..."
        return 0
    fi
    
    echo "  ☕ Installing APEX (this takes 15-25 minutes)..."
    echo "     Time for coffee!"
    echo ""
    
    cd /opt/oracle/apex
    
    sqlplus -s "$DB_CONN" << EOSQL
WHENEVER SQLERROR CONTINUE
SET TIMING ON
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL

    sleep 30
    
    if check_apex_installed; then
        echo "  ✅ APEX installation completed!"
    else
        echo "  ⚠️ APEX installation may have issues, continuing..."
    fi
}

configure_apex_rest() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔧 Configuring APEX REST Services"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd /opt/oracle/apex
    
    sqlplus -s "$DB_CONN" << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL

    echo "  ✅ APEX REST configured"
}

disable_password_policies() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔓 Disabling Password Policies"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    sqlplus -s "$DB_CONN" << EOSQL
ALTER PROFILE DEFAULT LIMIT
    FAILED_LOGIN_ATTEMPTS UNLIMITED
    PASSWORD_LOCK_TIME UNLIMITED
    PASSWORD_LIFE_TIME UNLIMITED
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL

    echo "  ✅ Password policies disabled"
}

create_users() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  👤 Creating Database Users"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    sqlplus -s "$DB_CONN" << EOSQL
SET SERVEROUTPUT ON

-- Drop and recreate ORDS_PUBLIC_USER
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE TO ORDS_PUBLIC_USER;
GRANT CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

-- Update APEX users
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
DBMS_OUTPUT.PUT_LINE('✅ Users created successfully');
EXIT;
EOSQL

    echo "  ✅ Database users created"
}

grant_proxy() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔐 Granting Proxy Authentication (Error 571 Fix)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    sqlplus -s "$DB_CONN" << EOSQL
SET SERVEROUTPUT ON

-- Grant proxy authentication
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

-- Grant proxy to APEX schema
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

-- Grant execute permissions
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_UTILITY TO ORDS_PUBLIC_USER;

COMMIT;

-- Verify proxy grants
SELECT PROXY, CLIENT, AUTHENTICATION FROM DBA_PROXIES WHERE PROXY = 'ORDS_PUBLIC_USER';

EXIT;
EOSQL

    echo "  ✅ Proxy authentication granted"
}

create_apex_admin() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  👑 Creating APEX Admin User"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Get APEX schema name
    local apex_schema=$(echo "SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;" | \
        sqlplus -s "$DB_CONN" 2>/dev/null | grep "^APEX_" | head -1 | tr -d ' ')
    
    if [ -z "$apex_schema" ]; then
        echo "  ⚠️ Could not find APEX schema, using default"
        apex_schema="APEX_230200"
    fi
    
    echo "  Found APEX schema: $apex_schema"
    
    sqlplus -s "$DB_CONN" << EOSQL
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
EOSQL

    echo "  ✅ APEX Admin user configured"
}

grant_privileges() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔑 Granting Additional Privileges"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local apex_schema=$(echo "SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;" | \
        sqlplus -s "$DB_CONN" 2>/dev/null | grep "^APEX_" | head -1 | tr -d ' ')
    
    [ -z "$apex_schema" ] && apex_schema="APEX_230200"
    
    sqlplus -s "$DB_CONN" << EOSQL
BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON ${apex_schema}.WWV_FLOW_EPG_INCLUDE_MODULES TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

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
EOSQL

    echo "  ✅ Privileges granted"
}

configure_ords() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ⚙️ Configuring ORDS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Create pool.xml
    cat > /opt/oracle/ords_config/databases/default/pool.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>Database Connection Pool - KaizenixCore Docker Edition v3.0.0</comment>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">${DB_HOST}</entry>
<entry key="db.port">${DB_PORT}</entry>
<entry key="db.servicename">${DB_SERVICE}</entry>
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
    cat > /opt/oracle/ords_config/global/settings.xml << EOF
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
    cat > /opt/oracle/ords_config/settings.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>ORDS Standalone Settings</comment>
<entry key="standalone.context.path">/ords</entry>
<entry key="standalone.http.port">${ORDS_PORT}</entry>
<entry key="standalone.static.context.path">/i</entry>
<entry key="standalone.static.path">/opt/oracle/images</entry>
<entry key="standalone.doc.root">/opt/oracle/images</entry>
</properties>
EOF

    echo "  ✅ ORDS configuration files created"
    
    # Install ORDS schema
    echo "  📦 Installing ORDS schema into database..."
    
    echo "${ORACLE_PASSWORD}" | /opt/oracle/ords/bin/ords --config /opt/oracle/ords_config install \
        --admin-user sys \
        --db-hostname "$DB_HOST" \
        --db-port "$DB_PORT" \
        --db-servicename "$DB_SERVICE" \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --password-stdin 2>&1 || true
    
    echo "  ✅ ORDS schema installed"
}

final_unlock() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔓 Final Unlock and Verification"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    sqlplus -s "$DB_CONN" << EOSQL
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;

ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

COMMIT;
EXIT;
EOSQL

    echo "  ✅ All users unlocked and verified"
}

start_ords() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║           🎉 ORACLE APEX IS READY! 🎉                             ║"
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
    
    echo "🚀 Starting ORDS server on port ${ORDS_PORT}..."
    
    exec /opt/oracle/ords/bin/ords --config /opt/oracle/ords_config serve \
        --port "$ORDS_PORT" \
        --apex-images /opt/oracle/images
}

# Check if setup already done
check_setup_done() {
    [ -f "/opt/oracle/ords_config/.setup_complete" ]
}

mark_setup_done() {
    touch /opt/oracle/ords_config/.setup_complete
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    wait_for_db
    
    if ! check_setup_done; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  🆕 First Run - Setting up APEX and ORDS"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        disable_password_policies
        install_apex
        configure_apex_rest
        create_users
        grant_proxy
        create_apex_admin
        grant_privileges
        configure_ords
        final_unlock
        mark_setup_done
        
        echo ""
        echo "  ✅ First-time setup completed!"
    else
        echo ""
        echo "  ✅ Previous setup detected, starting ORDS..."
    fi
    
    start_ords
}

main
ENTRYPOINT

    chmod +x "$PROJECT_DIR/scripts/ords-entrypoint.sh"
    log_success "ORDS entrypoint script created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 6: Create Docker Compose
# ═══════════════════════════════════════════════════════════════════════════════

step_06_create_docker_compose() {
    log_step "Creating Docker Compose Configuration"
    
    cat > "$PROJECT_DIR/docker-compose.yml" << EOF
################################################################################
# Oracle APEX Full Docker Stack v3.0.0
# Created by: Peyman Rasouli | KaizenixCore
#
# This stack runs 100% in Docker:
#   - Oracle Database XE 21c
#   - ORDS + APEX (with Java, wget, unzip inside container)
#
# Only the database files are stored on your system!
################################################################################

version: '3.8'

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
      # Database files stored on host system
      - ${DATA_DIR}/oradata:/opt/oracle/oradata
    shm_size: 2g
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 20
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
      # ORDS config stored on host for persistence
      - ${DATA_DIR}/ords_config:/opt/oracle/ords_config
    depends_on:
      oracle-db:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - apex-network

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
    cat > "$SCRIPTS_DIR/start.sh" << SCRIPT
#!/bin/bash
cd "$PROJECT_DIR"
echo "🚀 Starting Oracle APEX (Full Docker)..."
$COMPOSE_CMD up -d
echo ""
echo "⏳ Services are starting..."
echo "   First run takes 15-30 minutes for APEX installation."
echo ""
echo "📊 Check status: $SCRIPTS_DIR/status.sh"
echo "📜 View logs: $SCRIPTS_DIR/logs.sh"
SCRIPT

    # Stop script
    cat > "$SCRIPTS_DIR/stop.sh" << SCRIPT
#!/bin/bash
cd "$PROJECT_DIR"
echo "⏹️ Stopping Oracle APEX..."
$COMPOSE_CMD down
echo "✅ Stopped"
SCRIPT

    # Status script
    cat > "$SCRIPTS_DIR/status.sh" << SCRIPT
#!/bin/bash
cd "$PROJECT_DIR"
echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                    📊 ORACLE APEX STATUS                          ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
$COMPOSE_CMD ps
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
HTTP_ORDS=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
HTTP_APEX=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
echo ""
if [[ "\$HTTP_ORDS" =~ ^(200|301|302|303)\$ ]]; then
    echo "  ✅ ORDS:       http://localhost:8080/ords/ (HTTP \$HTTP_ORDS)"
else
    echo "  ⚠️  ORDS:       Not responding (HTTP \$HTTP_ORDS)"
fi
if [[ "\$HTTP_APEX" =~ ^(200|301|302|303)\$ ]]; then
    echo "  ✅ APEX Admin: http://localhost:8080/ords/apex_admin (HTTP \$HTTP_APEX)"
else
    echo "  ⚠️  APEX Admin: Not responding (HTTP \$HTTP_APEX)"
fi
echo ""
SCRIPT

    # Logs script
    cat > "$SCRIPTS_DIR/logs.sh" << SCRIPT
#!/bin/bash
cd "$PROJECT_DIR"
$COMPOSE_CMD logs -f --tail=100
SCRIPT

    # Restart script
    cat > "$SCRIPTS_DIR/restart.sh" << SCRIPT
#!/bin/bash
cd "$PROJECT_DIR"
echo "🔄 Restarting Oracle APEX..."
$COMPOSE_CMD restart
echo "✅ Restarted"
SCRIPT

    # Fix script
    cat > "$SCRIPTS_DIR/fix.sh" << SCRIPT
#!/bin/bash
cd "$PROJECT_DIR"
PASS=\$(cat "$CONFIG_DIR/.db_password")

echo "🔧 Running comprehensive fix..."
echo ""

echo "Restarting ORDS container..."
$COMPOSE_CMD restart ords

echo ""
echo "Waiting 60s for ORDS to restart..."
sleep 60

bash "$SCRIPTS_DIR/status.sh"
SCRIPT

    # Reset password script
    cat > "$SCRIPTS_DIR/reset-apex-password.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"

PASS=$(cat "$CONFIG_DIR/.db_password")
read -p "Enter new APEX Admin password: " NEW_PASS

docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << EOF
DECLARE
    v_apex_schema VARCHAR2(30);
BEGIN
    SELECT USERNAME INTO v_apex_schema FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;
    
    EXECUTE IMMEDIATE 'BEGIN ' || v_apex_schema || '.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10); END;';
    EXECUTE IMMEDIATE 'BEGIN ' || v_apex_schema || '.APEX_UTIL.EDIT_USER(
        p_user_id => ' || v_apex_schema || '.APEX_UTIL.GET_USER_ID(''ADMIN''),
        p_user_name => ''ADMIN'',
        p_web_password => ''${NEW_PASS}'',
        p_new_password => ''${NEW_PASS}'',
        p_change_password_on_first_use => ''N'',
        p_account_locked => ''N''
    ); END;';
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
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Check for zenity
if ! command -v zenity &>/dev/null; then
    echo "Zenity not found. Installing..."
    case "$(uname -s)" in
        Linux*)
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y zenity 2>/dev/null
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y zenity 2>/dev/null
            elif command -v zypper &>/dev/null; then
                sudo zypper install -y zenity 2>/dev/null
            fi
            ;;
        Darwin*)
            brew install zenity 2>/dev/null || echo "Please install zenity: brew install zenity"
            ;;
    esac
fi

# Prevent multiple instances
LOCK_FILE="/tmp/oracle-apex-gui.lock"
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        zenity --warning --text="Oracle APEX Manager is already running!" --width=300 2>/dev/null
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# Language
LANG_CODE="en"
CONFIG_FILE="$PROJECT_DIR/config/.gui_config"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

# Strings
declare -A STRINGS_EN=(
    ["title"]="Oracle APEX Manager"
    ["subtitle"]="Docker Edition v3.0"
    ["select"]="Select an action:"
    ["start"]="▶️  Start Services"
    ["stop"]="⏹️  Stop Services"
    ["status"]="📊  Check Status"
    ["admin"]="🌐  Open Admin Panel"
    ["login"]="🔐  Open Login Page"
    ["logs"]="📜  View Logs"
    ["restart"]="🔄  Restart Services"
    ["settings"]="⚙️  Settings"
    ["exit"]="❌  Exit"
    ["starting"]="Starting Oracle APEX..."
    ["stopping"]="Stopping Oracle APEX..."
    ["wait"]="Please wait..."
    ["success_start"]="✅ Oracle APEX started!"
    ["success_stop"]="✅ Oracle APEX stopped!"
    ["running"]="🟢 Running"
    ["stopped"]="🔴 Stopped"
)

declare -A STRINGS_FA=(
    ["title"]="مدیریت اوراکل اپکس"
    ["subtitle"]="نسخه داکر 3.0"
    ["select"]="یک عملیات انتخاب کنید:"
    ["start"]="▶️  شروع سرویس‌ها"
    ["stop"]="⏹️  توقف سرویس‌ها"
    ["status"]="📊  بررسی وضعیت"
    ["admin"]="🌐  پنل مدیریت"
    ["login"]="🔐  صفحه ورود"
    ["logs"]="📜  مشاهده لاگ‌ها"
    ["restart"]="🔄  راه‌اندازی مجدد"
    ["settings"]="⚙️  تنظیمات"
    ["exit"]="❌  خروج"
    ["starting"]="در حال شروع..."
    ["stopping"]="در حال توقف..."
    ["wait"]="لطفاً صبر کنید..."
    ["success_start"]="✅ شروع شد!"
    ["success_stop"]="✅ متوقف شد!"
    ["running"]="🟢 در حال اجرا"
    ["stopped"]="🔴 متوقف"
)
declare -A STRINGS_DE=(
    ["title"]="Oracle APEX Manager"
    ["subtitle"]="Docker Edition v3.0"
    ["select"]="Wählen Sie eine Aktion:"
    ["start"]="▶️  Dienste starten"
    ["stop"]="⏹️  Dienste stoppen"
    ["status"]="📊  Status prüfen"
    ["admin"]="🌐  Admin-Panel"
    ["login"]="🔐  Anmeldeseite"
    ["logs"]="📜  Protokolle"
    ["restart"]="🔄  Neustart"
    ["settings"]="⚙️  Einstellungen"
    ["exit"]="❌  Beenden"
    ["starting"]="Wird gestartet..."
    ["stopping"]="Wird gestoppt..."
    ["wait"]="Bitte warten..."
    ["success_start"]="✅ Gestartet!"
    ["success_stop"]="✅ Gestoppt!"
    ["running"]="🟢 Läuft"
    ["stopped"]="🔴 Gestoppt"
)

get_str() {
    case $LANG_CODE in
        fa) echo "${STRINGS_FA[$1]}" ;;
        de) echo "${STRINGS_DE[$1]}" ;;
        *)  echo "${STRINGS_EN[$1]}" ;;
    esac
}

check_status() {
    docker compose ps --format json 2>/dev/null | grep -q '"running"' || \
    docker-compose ps 2>/dev/null | grep -q "Up"
}

# Detect compose command
if docker compose version &>/dev/null; then
    COMPOSE="docker compose"
else
    COMPOSE="docker-compose"
fi

while true; do
    if check_status; then
        STATUS_ICON="🟢"
    else
        STATUS_ICON="🔴"
    fi
    
    CHOICE=$(zenity --list \
        --title="$(get_str title) - $(get_str subtitle)" \
        --text="$STATUS_ICON $(get_str select)" \
        --radiolist \
        --column="" --column="Action" --column="Description" \
        TRUE "start" "$(get_str start)" \
        FALSE "stop" "$(get_str stop)" \
        FALSE "status" "$(get_str status)" \
        FALSE "admin" "$(get_str admin)" \
        FALSE "login" "$(get_str login)" \
        FALSE "logs" "$(get_str logs)" \
        FALSE "restart" "$(get_str restart)" \
        FALSE "settings" "$(get_str settings)" \
        FALSE "exit" "$(get_str exit)" \
        --width=500 --height=450 2>/dev/null)
    
    [ -z "$CHOICE" ] && exit 0
    
    case $CHOICE in
        start)
            (
                echo "10"; echo "# $(get_str starting)"
                cd "$PROJECT_DIR"
                $COMPOSE up -d 2>&1
                echo "50"; echo "# Waiting for services..."
                sleep 30
                echo "100"; echo "# Done!"
            ) | zenity --progress --title="$(get_str title)" --text="$(get_str wait)" --auto-close --width=400 2>/dev/null
            
            if check_status; then
                zenity --info --text="$(get_str success_start)\n\n🌐 http://localhost:8080/ords/apex_admin" --width=400 2>/dev/null
                if zenity --question --title="$(get_str title)" --text="Open Admin Panel in browser?" --width=300 2>/dev/null; then
                    xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
                fi
            fi
            ;;
        stop)
            (
                echo "30"; echo "# $(get_str stopping)"
                cd "$PROJECT_DIR"
                $COMPOSE down 2>&1
                echo "100"; echo "# Done!"
            ) | zenity --progress --title="$(get_str title)" --text="$(get_str wait)" --auto-close --width=400 2>/dev/null
            zenity --info --text="$(get_str success_stop)" --width=300 2>/dev/null
            ;;
        status)
            STATUS=$(cd "$PROJECT_DIR" && $COMPOSE ps 2>&1)
            HTTP_ORDS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
            HTTP_APEX=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
            zenity --info --title="$(get_str status)" --text="$STATUS\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nORDS: HTTP $HTTP_ORDS\nAPEX Admin: HTTP $HTTP_APEX\n\n🌐 http://localhost:8080/ords/apex_admin\n🔐 http://localhost:8080/ords/f?p=4550" --width=600 2>/dev/null
            ;;
        admin)
            xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
            ;;
        login)
            xdg-open "http://localhost:8080/ords/f?p=4550" 2>/dev/null || open "http://localhost:8080/ords/f?p=4550" 2>/dev/null &
            ;;
        logs)
            LOGS=$(cd "$PROJECT_DIR" && $COMPOSE logs --tail=200 2>&1)
            echo "$LOGS" | zenity --text-info --title="Logs" --width=900 --height=600 2>/dev/null
            ;;
        restart)
            (
                echo "30"; echo "# Restarting..."
                cd "$PROJECT_DIR"
                $COMPOSE restart 2>&1
                echo "100"; echo "# Done!"
            ) | zenity --progress --title="$(get_str title)" --text="$(get_str wait)" --auto-close --width=400 2>/dev/null
            ;;
        settings)
            NEW_LANG=$(zenity --list --title="Language" --radiolist \
                --column="" --column="Code" --column="Language" \
                $([ "$LANG_CODE" = "en" ] && echo "TRUE" || echo "FALSE") "en" "🇺🇸 English" \
                $([ "$LANG_CODE" = "fa" ] && echo "TRUE" || echo "FALSE") "fa" "🇮🇷 فارسی" \
                $([ "$LANG_CODE" = "de" ] && echo "TRUE" || echo "FALSE") "de" "🇩🇪 Deutsch" \
                --width=350 --height=250 2>/dev/null)
            [ -n "$NEW_LANG" ] && { LANG_CODE="$NEW_LANG"; echo "LANG_CODE=\"$LANG_CODE\"" > "$CONFIG_FILE"; }
            ;;
        exit)
            exit 0
            ;;
    esac
done
GUISCRIPT

    chmod +x "$SCRIPTS_DIR/launch-gui.sh"
    log_success "Multi-Language GUI Manager created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 9: Create Desktop Application
# ═══════════════════════════════════════════════════════════════════════════════

step_09_create_desktop() {
    log_step "Creating Desktop Application"
    
    # Only for Linux
    if [ "$(detect_os)" != "linux" ]; then
        log_info "Desktop application only available on Linux"
        return
    fi
    
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/share/icons"
    
    # Create SVG icon
    cat > "$PROJECT_DIR/oracle-apex-icon.svg" << 'SVGICON'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF4444;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#CC0000;stop-opacity:1" />
    </linearGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="2" dy="4" stdDeviation="4" flood-opacity="0.3"/>
    </filter>
  </defs>
  <rect x="20" y="20" width="216" height="216" rx="30" fill="url(#grad1)" filter="url(#shadow)"/>
  <text x="128" y="100" font-family="Arial Black, sans-serif" font-size="48" font-weight="bold" fill="white" text-anchor="middle">APEX</text>
  <text x="128" y="150" font-family="Arial, sans-serif" font-size="24" fill="rgba(255,255,255,0.9)" text-anchor="middle">Docker</text>
  <text x="128" y="190" font-family="Arial, sans-serif" font-size="16" fill="rgba(255,255,255,0.7)" text-anchor="middle">KaizenixCore</text>
</svg>
SVGICON

    cp "$PROJECT_DIR/oracle-apex-icon.svg" "$HOME/.local/share/icons/"
    
    cat > "$HOME/.local/share/applications/oracle-apex-docker.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle APEX Manager
Name[fa]=مدیریت اوراکل اپکس
Name[de]=Oracle APEX Manager
Comment=Manage Oracle APEX (Docker Edition) - KaizenixCore
Comment[fa]=مدیریت اوراکل اپکس (نسخه داکر) - کایزنیکس
Comment[de]=Oracle APEX verwalten (Docker Edition) - KaizenixCore
Exec=bash $SCRIPTS_DIR/launch-gui.sh
Icon=$HOME/.local/share/icons/oracle-apex-icon.svg
Terminal=false
Categories=Development;Database;
Keywords=oracle;apex;ords;database;docker;kaizenixcore;
StartupNotify=true
StartupWMClass=zenity
EOF

    chmod +x "$HOME/.local/share/applications/oracle-apex-docker.desktop"
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    
    log_success "Desktop application created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 10: Build Docker Images
# ═══════════════════════════════════════════════════════════════════════════════

step_10_build() {
    log_step "Building Docker Images"
    
    cd "$PROJECT_DIR"
    
    log_info "Building ORDS container (downloads APEX & ORDS inside)..."
    log_warning "This may take 10-15 minutes on first run..."
    echo ""
    
    $COMPOSE_CMD build --no-cache 2>&1 | tee "$LOG_DIR/build.log"
    
    log_success "Docker images built successfully"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 11: Start Services
# ═══════════════════════════════════════════════════════════════════════════════

step_11_start() {
    log_step "Starting Docker Containers"
    
    cd "$PROJECT_DIR"
    
    log_info "Starting Oracle Database and ORDS..."
    $COMPOSE_CMD up -d
    
    echo ""
    log_warning "First startup takes 15-30 minutes for APEX installation!"
    log_info "Database needs to initialize, then APEX will be installed automatically."
    echo ""
    log_info "Monitor progress with:"
    echo -e "  ${CYAN}cd $PROJECT_DIR && $COMPOSE_CMD logs -f${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 12: Print Summary
# ═══════════════════════════════════════════════════════════════════════════════

step_12_summary() {
    log_step "Installation Summary"

    echo ""
    echo -e "${GREEN}${BOLD}  ╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
    echo -e "${GREEN}${BOLD}  ║        🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉                ║${NC}"
    echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
    echo -e "${GREEN}${BOLD}  ║              100% Docker - No Local Dependencies!                ║${NC}"
    echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
    echo -e "${GREEN}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   🌐 APEX URLs (available after startup):${NC}"
    echo -e "      Admin Panel: ${CYAN}http://localhost:$ORDS_PORT/ords/apex_admin${NC}"
    echo -e "      Login Page:  ${CYAN}http://localhost:$ORDS_PORT/ords/f?p=4550${NC}"
    echo ""
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
    echo -e "${WHITE}${BOLD}   📜 Management Commands:${NC}"
    echo -e "      Start:     ${CYAN}bash $SCRIPTS_DIR/start.sh${NC}"
    echo -e "      Stop:      ${CYAN}bash $SCRIPTS_DIR/stop.sh${NC}"
    echo -e "      Status:    ${CYAN}bash $SCRIPTS_DIR/status.sh${NC}"
    echo -e "      Logs:      ${CYAN}bash $SCRIPTS_DIR/logs.sh${NC}"
    echo -e "      Restart:   ${CYAN}bash $SCRIPTS_DIR/restart.sh${NC}"
    echo -e "      GUI:       ${CYAN}bash $SCRIPTS_DIR/launch-gui.sh${NC}"
    echo ""
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}   📁 Project Location:${NC}"
    echo -e "      ${CYAN}$PROJECT_DIR${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}   💾 Data Storage (Persistent):${NC}"
    echo -e "      Database:  ${CYAN}$DATA_DIR/oradata${NC}"
    echo -e "      ORDS:      ${CYAN}$DATA_DIR/ords_config${NC}"
    echo ""
    echo -e "${YELLOW}${BOLD}   ⏳ First startup takes 15-30 minutes!${NC}"
    echo -e "${YELLOW}      Monitor with: ${WHITE}cd $PROJECT_DIR && $COMPOSE_CMD logs -f${NC}"
    echo ""
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}   Created by: ${WHITE}Peyman Rasouli${NC} ${GRAY}| Project: ${MAGENTA}KaizenixCore${NC}"
    echo -e "${GRAY}   GitHub: ${BLUE}https://github.com/KaizenixCore${NC}"
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    print_banner
    
    step_01_check_docker
    get_passwords
    step_02_init
    step_03_cleanup
    step_04_create_dockerfile
    step_05_create_entrypoint
    step_06_create_docker_compose
    step_07_create_scripts
    step_08_create_gui
    step_09_create_desktop
    step_10_build
    step_11_start
    step_12_summary
}

main "$@"
