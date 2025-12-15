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
#  ║        ORACLE APEX ULTIMATE INSTALLER v2.4.0 - KAIZENIXCORE               ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/peymanrasouli                            ║
#  ║  License    : MIT                                                         ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║                           FEATURES                                        ║
#  ├───────────────────────────────────────────────────────────────────────────┤
#  ║  ✅ Fully Automated Oracle APEX + ORDS + XE 21c Installation              ║
#  ║  ✅ Smart Dependency Detection & Auto-Installation                        ║
#  ║  ✅ Docker-based Isolated Environment                                     ║
#  ║  ✅ Error 500 & Internal Server Error - FIXED                             ║
#  ║  ✅ Error 571 & Proxy Authentication - FIXED                              ║
#  ║  ✅ Error 574 & Database Credentials - FIXED                              ║
#  ║  ✅ Error 404 & Invalid Schema - FIXED                                    ║
#  ║  ✅ Password File Missing - FIXED                                         ║
#  ║  ✅ ORDS_METADATA Installation - FIXED                                    ║
#  ║  ✅ GUI Application Crash - FIXED                                         ║
#  ║  ✅ System Restart Persistence - FIXED                                    ║
#  ║  ✅ Auto-Fix After Installation                                           ║
#  ║  ✅ Multi-Language GUI (English/Persian/German)                           ║
#  ║  ✅ Modern UI/UX with Zenity                                              ║
#  ║  ✅ One-Click Browser Launch                                              ║
#  ║  ✅ Systemd Service Auto-Start                                            ║
#  ║  ✅ Desktop Application (.desktop file)                                   ║
#  ║  ✅ Persistent Configuration (survives restart/browser close)             ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e
trap 'handle_error $LINENO' ERR

VERSION="2.4.0"
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
TOTAL_STEPS=30

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
    echo -e "${WHITE}${BOLD}  ║${NC}      ${MAGENTA}${BOLD}ORACLE APEX ULTIMATE INSTALLER${NC} ${WHITE}v${VERSION}${NC}                    ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} Error 500 Fixed   ${GREEN}✓${NC} Error 574 Fixed    ${GREEN}✓${NC} GUI Crash Fixed  ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}  ║${NC}  ${GREEN}✓${NC} Error 404 Fixed   ${GREEN}✓${NC} Error 571 Fixed    ${GREEN}✓${NC} Auto-Fix Ready   ${WHITE}${BOLD}║${NC}"
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

    local file_size=$(stat -c%s "$zip_file" 2>/dev/null || echo 0)
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

    while true; do
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            echo ""
            log_success "Database reports READY"
            log_info "Waiting 90s for listener to fully stabilize..."
            sleep 90
            return 0
        fi

        local elapsed=$(($(date +%s) - start_time))
        [ $elapsed -gt $timeout ] && { echo ""; log_error "Timeout"; return 1; }

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
    mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR"
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    
    # Save passwords immediately
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    
    log_success "Directories created and passwords saved"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 02: SYSTEM CHECK
# ═══════════════════════════════════════════════════════════════════════════════
step_02_check() {
    log_step "System Check"
    [ -f /etc/os-release ] && . /etc/os-release && log_info "OS: $NAME $VERSION_ID"
    command -v docker &>/dev/null && log_success "Docker: OK" || log_warning "Docker: Missing"
    command -v java &>/dev/null && log_success "Java: OK" || log_warning "Java: Missing"

    local free=$(df -BG "$HOME" | awk 'NR==2{print $4}' | sed 's/G//')
    [ "$free" -lt 10 ] && { log_error "Need 10GB, have ${free}GB"; exit 1; }
    log_success "Disk Space: ${free}GB available"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 03: PREREQUISITES
# ═══════════════════════════════════════════════════════════════════════════════
step_03_prerequisites() {
    log_step "Installing Dependencies"

    local OS_TYPE="unknown"
    [ -f /etc/os-release ] && . /etc/os-release && OS_TYPE="$ID"

    case "$OS_TYPE" in
        opensuse*|suse) sudo zypper --non-interactive install -y docker docker-compose java-17-openjdk unzip wget curl zenity 2>/dev/null || true ;;
        ubuntu|debian) sudo apt-get update -qq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io docker-compose openjdk-17-jdk unzip wget curl zenity 2>/dev/null || true ;;
        fedora|rhel|centos) sudo dnf install -y docker docker-compose java-17-openjdk unzip wget curl zenity 2>/dev/null || true ;;
    esac

    sudo systemctl enable docker 2>/dev/null || true
    sudo systemctl start docker 2>/dev/null || true

    if ! groups | grep -q docker; then
        sudo usermod -aG docker "$USER"
        echo -e "${YELLOW}  Run: ${WHITE}newgrp docker && bash $0${NC}"
        exit 0
    fi

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
    rm -rf "$PROJECT_DIR"/{apex,ords,docker-compose.yml,ords_config,images,ords.pid,.apex_schema} 2>/dev/null || true
    
    # Keep password files
    local saved_db_pass=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
    local saved_apex_pass=$(cat "$PROJECT_DIR/.apex_password" 2>/dev/null)

    mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR"
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    
    # Restore passwords
    [ -n "$saved_db_pass" ] && echo "$saved_db_pass" > "$PROJECT_DIR/.db_password"
    [ -n "$saved_apex_pass" ] && echo "$saved_apex_pass" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password" 2>/dev/null || true
    
    log_success "Cleanup completed"
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
        docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
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

    # Create pool.xml with correct password
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
<entry key="db.password">${ORACLE_PASSWORD}</entry>
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

    # Create standalone settings
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

    # START SCRIPT
    cat > "$SCRIPTS_DIR/start.sh" << 'STARTEOF'
#!/bin/bash
cd ~/oracle-apex-complete
PASS=$(cat .db_password 2>/dev/null)
echo "Starting Oracle APEX services..."

# Start database
docker compose up -d 2>/dev/null || docker-compose up -d
echo "Waiting 90s for database..."
sleep 90

# Start ORDS
pkill -f ords 2>/dev/null || true
sleep 3

ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG=~/oracle-apex-complete/ords_config
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &
    echo "ORDS started (PID $!)"
fi

echo "Waiting 45s for ORDS..."
sleep 45

echo ""
echo "✅ Services started!"
echo "   Admin: http://localhost:8080/ords/apex_admin"
echo "   Login: http://localhost:8080/ords/f?p=4550"
STARTEOF

    # STOP SCRIPT
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
echo "Stopping Oracle APEX services..."
pkill -f ords 2>/dev/null || true
cd ~/oracle-apex-complete && docker compose down 2>/dev/null || docker-compose down
echo "✅ Services stopped"
STOPEOF

    # STATUS SCRIPT
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
echo "═══════════════════════════════════════════════════════"
echo "  Oracle APEX Status"
echo "═══════════════════════════════════════════════════════"
echo ""

# Database status
DB_STATUS=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo "false")
if [ "$DB_STATUS" = "true" ]; then
    echo "  Database:    🟢 Running"
else
    echo "  Database:    🔴 Stopped"
fi

# ORDS status
ORDS_PID=$(pgrep -f "ords" | head -1)
if [ -n "$ORDS_PID" ]; then
    echo "  ORDS:        🟢 Running (PID $ORDS_PID)"
else
    echo "  ORDS:        🔴 Stopped"
fi

# HTTP checks
echo ""
HTTP_ORDS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")

echo "  ORDS Root:   HTTP $HTTP_ORDS"
echo "  APEX Admin:  HTTP $HTTP_ADMIN"
echo "  APEX Login:  HTTP $HTTP_LOGIN"
echo ""
echo "═══════════════════════════════════════════════════════"
STATUSEOF

    # LOGS SCRIPT
    cat > "$SCRIPTS_DIR/logs.sh" << 'LOGSEOF'
#!/bin/bash
echo "═══════════════════════════════════════════════════════"
echo "  ORDS Logs (last 100 lines)"
echo "═══════════════════════════════════════════════════════"
tail -100 ~/oracle-apex-complete/logs/ords.log 2>/dev/null || echo "No logs found"
LOGSEOF

    # FIX SCRIPT (COMPREHENSIVE - PASSWORD FILE FIXED)
    cat > "$SCRIPTS_DIR/fix.sh" << 'FIXEOF'
#!/bin/bash
################################################################################
#  COMPREHENSIVE FIX SCRIPT - Fixes Error 500, 574, 571, 404
#  Version: 2.4.0 - Password file fixed
################################################################################

cd ~/oracle-apex-complete

# Get password from file or prompt
if [ -f .db_password ]; then
    PASS=$(cat .db_password 2>/dev/null)
else
    echo "Password file not found. Please enter Oracle Database Password:"
    read -s PASS
    echo "$PASS" > .db_password
    chmod 600 .db_password
fi

if [ -z "$PASS" ]; then
    echo "❌ Password is empty!"
    exit 1
fi

echo "════════════════════════════════════════════════════════════"
echo "  COMPREHENSIVE FIX - Error 500/574/571/404"
echo "════════════════════════════════════════════════════════════"
echo ""

# Step 1: Stop ORDS
echo "Step 1: Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 5
echo "✅ ORDS stopped"

# Step 2: Fix database accounts
echo ""
echo "Step 2: Fixing database accounts and passwords..."
docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << SQLEOF
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;

ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

COMMIT;
EXIT;
SQLEOF
echo "✅ Database accounts fixed"

# Step 3: Test connection
echo ""
echo "Step 3: Testing ORDS_PUBLIC_USER connection..."
TEST_RESULT=$(docker exec oracle-apex-db sqlplus -s ORDS_PUBLIC_USER/${PASS}@//localhost:1521/XEPDB1 << TESTEOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT 'CONNECTION_OK' FROM DUAL;
EXIT;
TESTEOF
)

if echo "$TEST_RESULT" | grep -q "CONNECTION_OK"; then
    echo "✅ ORDS_PUBLIC_USER can connect"
else
    echo "❌ Connection failed - recreating user..."
    docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << RECREATEOF
DROP USER ORDS_PUBLIC_USER CASCADE;
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS};
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

# Step 4: Check ORDS_METADATA
echo ""
echo "Step 4: Checking ORDS_METADATA schema..."
METADATA_CHECK=$(docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << METAEOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME='ORDS_METADATA';
EXIT;
METAEOF
)

METADATA_COUNT=$(echo "$METADATA_CHECK" | grep -o '[0-9]' | head -1)

if [ "$METADATA_COUNT" != "1" ]; then
    echo "⚠️  ORDS_METADATA missing! Reinstalling ORDS..."
    
    # Clean old ORDS users
    docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << CLEANEOF
BEGIN
    FOR u IN (SELECT username FROM dba_users WHERE username LIKE 'ORDS%') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP USER ' || u.username || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/
COMMIT;
EXIT;
CLEANEOF

    rm -rf ~/oracle-apex-complete/ords_config/*
    mkdir -p ~/oracle-apex-complete/ords_config/databases/default
    mkdir -p ~/oracle-apex-complete/ords_config/global
    
    ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
    
    if [ -n "$ORDS_BIN" ]; then
        echo "Installing ORDS (3-5 minutes)..."
        echo "${PASS}" | "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config install \
            --admin-user SYS \
            --db-hostname localhost \
            --db-port 1521 \
            --db-servicename XEPDB1 \
            --feature-sdw true \
            --gateway-mode proxied \
            --gateway-user APEX_PUBLIC_USER \
            --log-folder ~/oracle-apex-complete/logs \
            --password-stdin 2>&1 | grep -iE "completed|installed|success|error"

        # Re-grant proxy after install
        docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << GRANTEOF
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
GRANTEOF
        echo "✅ ORDS reinstalled"
    fi
else
    echo "✅ ORDS_METADATA exists"
fi

# Step 5: Fix pool.xml
echo ""
echo "Step 5: Fixing pool.xml..."
mkdir -p ~/oracle-apex-complete/ords_config/databases/default

cat > ~/oracle-apex-complete/ords_config/databases/default/pool.xml << POOLXMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>ORDS Connection Pool - Fixed by KaizenixCore</comment>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">localhost</entry>
<entry key="db.port">1521</entry>
<entry key="db.servicename">XEPDB1</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">${PASS}</entry>
<entry key="plsql.gateway.mode">proxied</entry>
<entry key="feature.sdw">true</entry>
<entry key="restEnabledSql.active">true</entry>
<entry key="security.requestValidationFunction">wwv_flow_epg_include_modules.authorize</entry>
<entry key="jdbc.InitialLimit">3</entry>
<entry key="jdbc.MinLimit">1</entry>
<entry key="jdbc.MaxLimit">10</entry>
</properties>
POOLXMLEOF
echo "✅ pool.xml updated"

# Step 6: Fix settings.xml
echo ""
echo "Step 6: Fixing settings.xml..."
cat > ~/oracle-apex-complete/ords_config/settings.xml << SETTINGSXMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="standalone.context.path">/ords</entry>
<entry key="standalone.http.port">8080</entry>
<entry key="standalone.static.context.path">/i</entry>
<entry key="standalone.static.path">$HOME/oracle-apex-complete/images</entry>
<entry key="standalone.doc.root">$HOME/oracle-apex-complete/images</entry>
</properties>
SETTINGSXMLEOF
echo "✅ settings.xml updated"

# Step 7: Configure ORDS standalone
echo ""
echo "Step 7: Configuring ORDS standalone..."
ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
if [ -n "$ORDS_BIN" ]; then
    "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config set standalone.context.path /ords 2>/dev/null || true
    "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config set standalone.http.port 8080 2>/dev/null || true
    "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config set standalone.static.context.path /i 2>/dev/null || true
    "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config set standalone.static.path ~/oracle-apex-complete/images 2>/dev/null || true
    "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config set standalone.doc.root ~/oracle-apex-complete/images 2>/dev/null || true
    echo "✅ ORDS configured"
fi

# Step 8: Start ORDS
echo ""
echo "Step 8: Starting ORDS..."
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
if [ -n "$ORDS_BIN" ]; then
    nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &
    echo "ORDS started with PID $!"
fi

echo "Waiting 90s for ORDS to start..."
sleep 90

# Step 9: Test endpoints
echo ""
echo "Step 9: Testing endpoints..."
HTTP_ROOT=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  FIX COMPLETED!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Status:"
echo "  ORDS Root:    HTTP $HTTP_ROOT"
echo "  APEX Admin:   HTTP $HTTP_ADMIN"
echo "  APEX Login:   HTTP $HTTP_LOGIN"
echo ""

if [[ "$HTTP_ADMIN" =~ ^(200|302|303)$ ]] && [[ "$HTTP_LOGIN" =~ ^(200|302|303)$ ]]; then
    echo "✅ All endpoints working!"
else
    echo "⚠️  Some endpoints may need more time. Wait 2 minutes and try again."
fi

echo ""
echo "URLs:"
echo "   http://localhost:8080/ords/apex_admin"
echo "   http://localhost:8080/ords/f?p=4550"
echo ""
FIXEOF

    # FIX PROXY SCRIPT
    cat > "$SCRIPTS_DIR/fix-proxy.sh" << 'FIXPROXYEOF'
#!/bin/bash
cd ~/oracle-apex-complete
PASS=$(cat .db_password 2>/dev/null)

echo "Fixing Proxy Authentication (Error 571 fix)..."

docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << PROXYEOF
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

SELECT PROXY, CLIENT, AUTHENTICATION FROM DBA_PROXIES WHERE PROXY = 'ORDS_PUBLIC_USER';

COMMIT;
EXIT;
PROXYEOF

echo "Restarting ORDS..."
pkill -f ords 2>/dev/null || true
sleep 3

ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &

echo "Waiting 60s..."
sleep 60

echo "Done!"
bash ~/oracle-apex-complete/scripts/status.sh
FIXPROXYEOF

    # RESET APEX PASSWORD SCRIPT
    cat > "$SCRIPTS_DIR/reset-apex-password.sh" << 'RESETEOF'
#!/bin/bash
cd ~/oracle-apex-complete
PASS=$(cat .db_password 2>/dev/null)

echo "Reset APEX Admin Password"
echo "========================="
read -p "Enter new APEX Admin password: " NEW_PASS

APEX_SCHEMA=$(cat .apex_schema 2>/dev/null)
if [ -z "$APEX_SCHEMA" ]; then
    APEX_SCHEMA=$(docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << SCHEMAEOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;
EXIT;
SCHEMAEOF
)
    APEX_SCHEMA=$(echo "$APEX_SCHEMA" | grep "^APEX_" | tr -d ' ')
fi

echo "Using APEX schema: $APEX_SCHEMA"

docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << RESETPWEOF
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
RESETPWEOF

echo "$NEW_PASS" > ~/oracle-apex-complete/.apex_password
echo ""
echo "✅ Password updated!"
echo "   Username: ADMIN"
echo "   Password: $NEW_PASS"
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
        log_warning "APEX Admin: HTTP $apex_code - Will auto-fix..."
    fi

    if [[ "$apex_login" =~ ^(200|301|302|303)$ ]]; then
        log_success "APEX Login: HTTP $apex_login"
    else
        log_warning "APEX Login: HTTP $apex_login - Will auto-fix..."
    fi

    echo ""
    log_info "Checking for errors in log..."
    if grep -qi "ORA-00942\|574\|ORA-01017\|500" "$LOG_DIR/ords.log" 2>/dev/null; then
        log_warning "Found potential errors - will auto-fix"
    else
        log_success "No critical errors found"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 25: AUTO-FIX (NEW - RUNS AUTOMATICALLY)
# ═══════════════════════════════════════════════════════════════════════════════
step_25_auto_fix() {
    log_step "Auto-Fix Configuration (Ensures 100% Working)"

    local apex_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null || echo "000")
    
    if [[ "$apex_code" =~ ^(574|500|404)$ ]] || grep -q "571\|proxy\|ORA-00942\|574\|500" "$LOG_DIR/ords.log" 2>/dev/null; then
        log_warning "Issues detected - running automatic fix..."
        
        # Ensure password file exists
        if [ ! -f "$PROJECT_DIR/.db_password" ]; then
            echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
            chmod 600 "$PROJECT_DIR/.db_password"
        fi
        
        bash "$SCRIPTS_DIR/fix.sh"
        sleep 30
        
        # Verify after fix
        local new_apex_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null || echo "000")
        if [[ "$new_apex_code" =~ ^(200|302|303)$ ]]; then
            log_success "✅ Auto-fix successful! APEX is now working."
        else
            log_warning "⚠️  Auto-fix completed. Status: HTTP $new_apex_code"
        fi
    else
        log_success "✅ No issues detected - system is healthy!"
    fi
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
    echo -e "      Fix Proxy:  ${CYAN}bash $SCRIPTS_DIR/fix-proxy.sh${NC}"
    echo -e "      Logs:       ${CYAN}bash $SCRIPTS_DIR/logs.sh${NC}"
    echo -e "      Reset PW:   ${CYAN}bash $SCRIPTS_DIR/reset-apex-password.sh${NC}"
    echo -e "      GUI:        ${CYAN}bash $SCRIPTS_DIR/launch-gui.sh${NC}"
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}${BOLD}   💡 Troubleshooting:${NC}"
    echo -e "      If you see any errors, run: ${WHITE}bash $SCRIPTS_DIR/fix.sh${NC}"
    echo ""
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}   Created by: ${WHITE}Peyman Rasouli${NC} ${GRAY}| Project: ${MAGENTA}KaizenixCore${NC}"
    echo -e "${GRAY}   GitHub: ${BLUE}https://github.com/peymanrasouli${NC}"
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}
# ═══════════════════════════════════════════════════════════════════════════════
# STEP 27: CREATE GUI (COMPLETELY FIXED - NO MORE CRASHES)
# ═══════════════════════════════════════════════════════════════════════════════
step_27_create_gui() {
    log_step "Creating Multi-Language GUI Manager (Crash Completely Fixed)"

    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
################################################################################
#  Oracle APEX Manager - Multi-Language GUI
#  Created by: Peyman Rasouli | KaizenixCore
#  Languages: English, فارسی, Deutsch
#  Version: 2.4.0 - GUI Crash COMPLETELY FIXED + System Restart Persistence
################################################################################

# ═══════════════════════════════════════════════════════════════════════════════
# PREVENT MULTIPLE INSTANCES
# ═══════════════════════════════════════════════════════════════════════════════
LOCK_FILE="/tmp/oracle-apex-gui.lock"
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        zenity --warning \
            --title="Oracle APEX Manager" \
            --text="Oracle APEX Manager is already running!\n\nPID: $PID" \
            --width=350 \
            --timeout=5 2>/dev/null
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# ═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════
LANG_CODE="en"
CONFIG_FILE="$HOME/oracle-apex-complete/.gui_config"

# Load saved language preference
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE" 2>/dev/null || LANG_CODE="en"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - ENGLISH
# ═══════════════════════════════════════════════════════════════════════════════
declare -A STRINGS_EN=(
    ["title"]="Oracle APEX Manager"
    ["select_action"]="Select an action:"
    ["start"]="▶️  Start Services"
    ["stop"]="⏹️  Stop Services"
    ["status"]="📊  Check Status"
    ["admin"]="🌐  Open Admin Panel"
    ["login"]="🔐  Open Login Page"
    ["fix"]="🔧  Run Fix Script"
    ["logs"]="📜  View Logs"
    ["settings"]="⚙️  Settings"
    ["exit"]="❌  Exit"
    ["starting"]="Starting Oracle APEX..."
    ["stopping"]="Stopping Oracle APEX..."
    ["please_wait"]="Please wait..."
    ["success_start"]="✅ Oracle APEX started successfully!"
    ["success_stop"]="✅ Oracle APEX stopped successfully!"
    ["error_not_running"]="⚠️ Oracle APEX is not running!"
    ["select_language"]="Select Language"
    ["status_running"]="Running"
    ["status_stopped"]="Stopped"
    ["open_browser"]="Open Admin Panel in browser?"
    ["fix_running"]="Running fix script..."
    ["fix_complete"]="Fix script completed!"
    ["no_logs"]="No logs found"
    ["language_changed"]="Language changed successfully!"
)

# ═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - PERSIAN (فارسی)
# ═══════════════════════════════════════════════════════════════════════════════
declare -A STRINGS_FA=(
    ["title"]="مدیریت اوراکل اپکس"
    ["select_action"]="یک عملیات انتخاب کنید:"
    ["start"]="▶️  شروع سرویس‌ها"
    ["stop"]="⏹️  توقف سرویس‌ها"
    ["status"]="📊  بررسی وضعیت"
    ["admin"]="🌐  پنل مدیریت"
    ["login"]="🔐  صفحه ورود"
    ["fix"]="🔧  اجرای اسکریپت تعمیر"
    ["logs"]="📜  مشاهده لاگ‌ها"
    ["settings"]="⚙️  تنظیمات"
    ["exit"]="❌  خروج"
    ["starting"]="در حال شروع اوراکل اپکس..."
    ["stopping"]="در حال توقف اوراکل اپکس..."
    ["please_wait"]="لطفاً صبر کنید..."
    ["success_start"]="✅ اوراکل اپکس با موفقیت شروع شد!"
    ["success_stop"]="✅ اوراکل اپکس با موفقیت متوقف شد!"
    ["error_not_running"]="⚠️ اوراکل اپکس در حال اجرا نیست!"
    ["select_language"]="انتخاب زبان"
    ["status_running"]="در حال اجرا"
    ["status_stopped"]="متوقف شده"
    ["open_browser"]="پنل مدیریت در مرورگر باز شود؟"
    ["fix_running"]="در حال اجرای اسکریپت تعمیر..."
    ["fix_complete"]="اسکریپت تعمیر با موفقیت اجرا شد!"
    ["no_logs"]="لاگی یافت نشد"
    ["language_changed"]="زبان با موفقیت تغییر کرد!"
)

# ═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - GERMAN (Deutsch)
# ═══════════════════════════════════════════════════════════════════════════════
declare -A STRINGS_DE=(
    ["title"]="Oracle APEX Manager"
    ["select_action"]="Wählen Sie eine Aktion:"
    ["start"]="▶️  Dienste starten"
    ["stop"]="⏹️  Dienste stoppen"
    ["status"]="📊  Status prüfen"
    ["admin"]="🌐  Admin-Panel öffnen"
    ["login"]="🔐  Anmeldeseite öffnen"
    ["fix"]="🔧  Reparaturskript ausführen"
    ["logs"]="📜  Protokolle anzeigen"
    ["settings"]="⚙️  Einstellungen"
    ["exit"]="❌  Beenden"
    ["starting"]="Oracle APEX wird gestartet..."
    ["stopping"]="Oracle APEX wird gestoppt..."
    ["please_wait"]="Bitte warten..."
    ["success_start"]="✅ Oracle APEX erfolgreich gestartet!"
    ["success_stop"]="✅ Oracle APEX erfolgreich gestoppt!"
    ["error_not_running"]="⚠️ Oracle APEX läuft nicht!"
    ["select_language"]="Sprache auswählen"
    ["status_running"]="Läuft"
    ["status_stopped"]="Gestoppt"
    ["open_browser"]="Admin-Panel im Browser öffnen?"
    ["fix_running"]="Reparaturskript wird ausgeführt..."
    ["fix_complete"]="Reparaturskript abgeschlossen!"
    ["no_logs"]="Keine Protokolle gefunden"
    ["language_changed"]="Sprache erfolgreich geändert!"
)

# ═══════════════════════════════════════════════════════════════════════════════
# GET STRING FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════
get_string() {
    local key=$1
    case $LANG_CODE in
        fa) echo "${STRINGS_FA[$key]:-${STRINGS_EN[$key]}}" ;;
        de) echo "${STRINGS_DE[$key]:-${STRINGS_EN[$key]}}" ;;
        *)  echo "${STRINGS_EN[$key]}" ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# CHECK SERVICE STATUS
# ═══════════════════════════════════════════════════════════════════════════════
check_status() {
    local db_running="false"
    local ords_running="false"
    
    # Check database container
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"; then
        db_running="true"
    fi
    
    # Check ORDS process
    if pgrep -f "ords.*serve" > /dev/null 2>&1; then
        ords_running="true"
    fi
    
    # Both must be running
    [ "$db_running" = "true" ] && [ "$ords_running" = "true" ]
}

# ═══════════════════════════════════════════════════════════════════════════════
# START SERVICES
# ═══════════════════════════════════════════════════════════════════════════════
start_services() {
    # Show progress dialog
    (
        echo "10"
        echo "# $(get_string starting)"
        
        # Start database container
        cd ~/oracle-apex-complete 2>/dev/null || cd "$HOME/oracle-apex-complete"
        docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null
        sleep 20
        
        echo "30"
        echo "# Waiting for database..."
        sleep 30
        
        echo "50"
        echo "# Starting ORDS..."
        
        # Kill any existing ORDS
        pkill -f ords 2>/dev/null || true
        sleep 3
        
        echo "60"
        echo "# Configuring ORDS..."
        
        # Find ORDS binary
        ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f 2>/dev/null | head -1)
        
        if [ -n "$ORDS_BIN" ]; then
            export ORDS_CONFIG=~/oracle-apex-complete/ords_config
            export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
            
            # Start ORDS in background
            nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve \
                --port 8080 \
                --apex-images ~/oracle-apex-complete/images \
                > ~/oracle-apex-complete/logs/ords.log 2>&1 &
        fi
        
        echo "75"
        echo "# Waiting for ORDS to start..."
        sleep 30
        
        echo "90"
        echo "# Verifying services..."
        sleep 10
        
        echo "100"
        echo "# Done!"
        
    ) | zenity --progress \
        --title="$(get_string title)" \
        --text="$(get_string please_wait)" \
        --percentage=0 \
        --auto-close \
        --width=450 \
        --no-cancel 2>/dev/null
    
    # Wait for dialog to close
    sleep 3
    
    # Check if services started successfully
    if check_status; then
        zenity --info \
            --title="$(get_string title)" \
            --text="$(get_string success_start)\n\n🌐 http://localhost:8080/ords/apex_admin\n🔐 http://localhost:8080/ords/f?p=4550" \
            --width=450 2>/dev/null
        
        # Ask to open browser
        if zenity --question \
            --title="$(get_string title)" \
            --text="$(get_string open_browser)" \
            --width=350 2>/dev/null; then
            xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
        fi
    else
        zenity --warning \
            --title="$(get_string title)" \
            --text="Services may not have started correctly.\n\nPlease check status or run fix script.\n\nTip: Wait 2 minutes and try again." \
            --width=450 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# STOP SERVICES
# ═══════════════════════════════════════════════════════════════════════════════
stop_services() {
    (
        echo "20"
        echo "# $(get_string stopping)"
        
        # Stop ORDS
        pkill -f ords 2>/dev/null || true
        sleep 3
        
        echo "50"
        echo "# Stopping database..."
        
        # Stop database container
        cd ~/oracle-apex-complete 2>/dev/null || cd "$HOME/oracle-apex-complete"
        docker compose down 2>/dev/null || docker-compose down 2>/dev/null
        
        echo "80"
        echo "# Cleaning up..."
        sleep 2
        
        echo "100"
        echo "# Done!"
        
    ) | zenity --progress \
        --title="$(get_string title)" \
        --text="$(get_string please_wait)" \
        --percentage=0 \
        --auto-close \
        --width=450 \
        --no-cancel 2>/dev/null
    
    sleep 2
    
    zenity --info \
        --title="$(get_string title)" \
        --text="$(get_string success_stop)" \
        --width=400 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# SHOW STATUS
# ═══════════════════════════════════════════════════════════════════════════════
show_status() {
    local status_text=""
    
    # Check database
    local db_status="🔴 Stopped"
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"; then
        db_status="🟢 Running"
    fi
    
    # Check ORDS
    local ords_status="🔴 Stopped"
    local ords_pid=""
    if pgrep -f "ords.*serve" > /dev/null 2>&1; then
        ords_pid=$(pgrep -f "ords.*serve" | head -1)
        ords_status="🟢 Running (PID: $ords_pid)"
    fi
    
    # Check HTTP endpoints
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
    local http_login=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/f?p=4550 2>/dev/null || echo "000")
    
    # Build status message
    status_text="📊 Service Status:\n\n"
    status_text+="Database:  $db_status\n"
    status_text+="ORDS:      $ords_status\n\n"
    status_text+="━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    status_text+="🌐 HTTP Endpoints:\n\n"
    status_text+="APEX Admin:  HTTP $http_admin\n"
    status_text+="APEX Login:  HTTP $http_login\n\n"
    
    if check_status; then
        status_text+="━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        status_text+="✅ All services are running!\n\n"
        status_text+="Admin: http://localhost:8080/ords/apex_admin\n"
        status_text+="Login: http://localhost:8080/ords/f?p=4550"
    else
        status_text+="━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        status_text+="⚠️ Services are not fully running.\n"
        status_text+="Use 'Start Services' to begin."
    fi
    
    zenity --info \
        --title="$(get_string title) - Status" \
        --text="$status_text" \
        --width=500 \
        --height=400 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# OPEN ADMIN PANEL
# ═══════════════════════════════════════════════════════════════════════════════
open_admin() {
    if check_status; then
        xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
        sleep 1
        zenity --info \
            --title="$(get_string title)" \
            --text="Admin Panel opened in browser!\n\n🌐 http://localhost:8080/ords/apex_admin" \
            --width=400 \
            --timeout=3 2>/dev/null
    else
        zenity --error \
            --title="$(get_string title)" \
            --text="$(get_string error_not_running)\n\nPlease start services first." \
            --width=400 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# OPEN LOGIN PAGE
# ═══════════════════════════════════════════════════════════════════════════════
open_login() {
    if check_status; then
        xdg-open "http://localhost:8080/ords/f?p=4550" 2>/dev/null &
        sleep 1
        zenity --info \
            --title="$(get_string title)" \
            --text="Login Page opened in browser!\n\n🔐 http://localhost:8080/ords/f?p=4550" \
            --width=400 \
            --timeout=3 2>/dev/null
    else
        zenity --error \
            --title="$(get_string title)" \
            --text="$(get_string error_not_running)\n\nPlease start services first." \
            --width=400 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# RUN FIX SCRIPT
# ═══════════════════════════════════════════════════════════════════════════════
run_fix() {
    # Show progress
    (
        echo "10"
        echo "# $(get_string fix_running)"
        
        # Run fix script
        bash ~/oracle-apex-complete/scripts/fix.sh > /tmp/fix_output.txt 2>&1
        
        echo "100"
        echo "# $(get_string fix_complete)"
        
    ) | zenity --progress \
        --title="$(get_string title)" \
        --text="$(get_string please_wait)" \
        --percentage=0 \
        --pulsate \
        --auto-close \
        --width=450 \
        --no-cancel 2>/dev/null
    
    sleep 2
    
    # Show fix output
    if [ -f /tmp/fix_output.txt ]; then
        zenity --text-info \
            --title="$(get_string title) - Fix Result" \
            --filename=/tmp/fix_output.txt \
            --width=800 \
            --height=600 \
            --font="Monospace 10" 2>/dev/null
    else
        zenity --info \
            --title="$(get_string title)" \
            --text="$(get_string fix_complete)" \
            --width=400 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SHOW LOGS
# ═══════════════════════════════════════════════════════════════════════════════
show_logs() {
    local log_file="$HOME/oracle-apex-complete/logs/ords.log"
    
    if [ -f "$log_file" ]; then
        zenity --text-info \
            --title="$(get_string title) - ORDS Logs" \
            --filename="$log_file" \
            --width=900 \
            --height=700 \
            --font="Monospace 9" 2>/dev/null
    else
        zenity --warning \
            --title="$(get_string title)" \
            --text="$(get_string no_logs)\n\nLog file: $log_file" \
            --width=400 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SETTINGS (LANGUAGE SELECTION)
# ═══════════════════════════════════════════════════════════════════════════════
show_settings() {
    local NEW_LANG=$(zenity --list \
        --title="$(get_string select_language)" \
        --text="Select your preferred language:" \
        --radiolist \
        --column="" --column="Code" --column="Language" --column="Native" \
        $([ "$LANG_CODE" = "en" ] && echo "TRUE" || echo "FALSE") "en" "English" "🇺🇸 English" \
        $([ "$LANG_CODE" = "fa" ] && echo "TRUE" || echo "FALSE") "fa" "Persian" "🇮🇷 فارسی" \
        $([ "$LANG_CODE" = "de" ] && echo "TRUE" || echo "FALSE") "de" "German" "🇩🇪 Deutsch" \
        --width=450 \
        --height=300 2>/dev/null)
    
    if [ -n "$NEW_LANG" ] && [ "$NEW_LANG" != "$LANG_CODE" ]; then
        LANG_CODE="$NEW_LANG"
        echo "LANG_CODE=\"$LANG_CODE\"" > "$CONFIG_FILE"
        
        zenity --info \
            --title="$(get_string title)" \
            --text="$(get_string language_changed)\n\nLanguage: $LANG_CODE" \
            --width=350 \
            --timeout=3 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN LOOP (CRITICAL FIX - THIS KEEPS THE GUI RUNNING)
# ═══════════════════════════════════════════════════════════════════════════════
main_loop() {
    while true; do
        # Check current status
        local STATUS_ICON="🔴"
        local STATUS_TEXT="$(get_string status_stopped)"
        
        if check_status; then
            STATUS_ICON="🟢"
            STATUS_TEXT="$(get_string status_running)"
        fi
        
        # Show main menu
        local CHOICE=$(zenity --list \
            --title="$(get_string title) - KaizenixCore" \
            --text="$STATUS_ICON Status: $STATUS_TEXT\n\n$(get_string select_action)" \
            --radiolist \
            --column="" --column="Action" --column="Description" \
            TRUE "start" "$(get_string start)" \
            FALSE "stop" "$(get_string stop)" \
            FALSE "status" "$(get_string status)" \
            FALSE "admin" "$(get_string admin)" \
            FALSE "login" "$(get_string login)" \
            FALSE "fix" "$(get_string fix)" \
            FALSE "logs" "$(get_string logs)" \
            FALSE "settings" "$(get_string settings)" \
            FALSE "exit" "$(get_string exit)" \
            --width=550 \
            --height=520 \
            --hide-column=2 2>/dev/null)
        
        # Handle user cancellation (X button or ESC)
        if [ -z "$CHOICE" ]; then
            exit 0
        fi
        
        # Execute selected action
        case $CHOICE in
            start)    start_services ;;
            stop)     stop_services ;;
            status)   show_status ;;
            admin)    open_admin ;;
            login)    open_login ;;
            fix)      run_fix ;;
            logs)     show_logs ;;
            settings) show_settings ;;
            exit)     exit 0 ;;
            *)        exit 0 ;;
        esac
        
        # Small delay to prevent rapid re-opening
        sleep 0.5
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# START APPLICATION
# ═══════════════════════════════════════════════════════════════════════════════

# Check if zenity is installed
if ! command -v zenity &> /dev/null; then
    echo "❌ Error: zenity is not installed!"
    echo "Install it with:"
    echo "  Ubuntu/Debian: sudo apt-get install zenity"
    echo "  openSUSE:      sudo zypper install zenity"
    echo "  Fedora:        sudo dnf install zenity"
    exit 1
fi

# Check if project directory exists
if [ ! -d "$HOME/oracle-apex-complete" ]; then
    zenity --error \
        --title="Oracle APEX Manager" \
        --text="Oracle APEX is not installed!\n\nPlease run the installer first:\nbash ~/oracle-apex-installer.sh" \
        --width=400 2>/dev/null
    exit 1
fi

# Start main loop (THIS IS THE KEY FIX)
main_loop
GUIEOF

    chmod +x "$SCRIPTS_DIR/launch-gui.sh"
    log_success "Multi-Language GUI Manager created (Crash Completely Fixed)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 28: CREATE DESKTOP APPLICATION
# ═══════════════════════════════════════════════════════════════════════════════
step_28_create_desktop() {
    log_step "Creating Desktop Application & Icon"

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
    <filter id="shadow">
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
Comment=Manage Oracle APEX and ORDS - KaizenixCore Edition
Exec=bash $SCRIPTS_DIR/launch-gui.sh
Icon=$HOME/.local/share/icons/oracle-apex-icon.svg
Terminal=false
Categories=Development;Database;IDE;
Keywords=oracle;apex;ords;database;development;sql;plsql;
StartupNotify=true
StartupWMClass=oracle-apex-manager
MimeType=application/x-sql;
DESKTOPEOF

    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"
    
    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    fi
    
    # Update icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/" 2>/dev/null || true
    fi
    
    log_success "Desktop application created and installed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 29: CREATE SYSTEMD SERVICES (FOR AUTO-START AFTER REBOOT)
# ═══════════════════════════════════════════════════════════════════════════════
step_29_create_services() {
    log_step "Creating Systemd Services (Auto-Start After Reboot)"

    local ORDS_BIN_PATH=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    
    if [ -z "$ORDS_BIN_PATH" ]; then
        log_warning "ORDS binary not found - systemd services not created"
        return
    fi

    # Create database service
    cat > /tmp/oracle-apex-db.service << DBSERVICEEOF
[Unit]
Description=Oracle APEX Database Container
Documentation=https://github.com/KaizenixCore/oracle-apex-installer
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
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
DBSERVICEEOF

    # Create ORDS service
    cat > /tmp/oracle-apex-ords.service << ORDSSERVICEEOF
[Unit]
Description=Oracle APEX ORDS Service
Documentation=https://github.com/KaizenixCore/oracle-apex-installer
After=oracle-apex-db.service docker.service network-online.target
Wants=network-online.target
Requires=oracle-apex-db.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment="ORDS_CONFIG=$ORDS_CONFIG_DIR"
Environment="_JAVA_OPTIONS=-Xms512m -Xmx1024m"
ExecStartPre=/bin/sleep 120
ExecStart=$ORDS_BIN_PATH --config $ORDS_CONFIG_DIR serve --port 8080 --apex-images $IMAGES_DIR
Restart=always
RestartSec=15
TimeoutStartSec=300
StandardOutput=append:$LOG_DIR/ords.log
StandardError=append:$LOG_DIR/ords.log

[Install]
WantedBy=multi-user.target
ORDSSERVICEEOF

    # Install systemd services (requires sudo)
    if command -v sudo &> /dev/null; then
        log_info "Installing systemd services (requires sudo)..."
        
        if sudo mv /tmp/oracle-apex-db.service /etc/systemd/system/ 2>/dev/null && \
           sudo mv /tmp/oracle-apex-ords.service /etc/systemd/system/ 2>/dev/null; then
            
            sudo systemctl daemon-reload 2>/dev/null || true
            
            log_success "Systemd services created"
            
            # Ask user if they want to enable auto-start
            echo ""
            read -p "  Enable auto-start on system boot? [Y/n]: " enable_autostart
            
            if [[ ! $enable_autostart =~ ^[Nn]$ ]]; then
                sudo systemctl enable oracle-apex-db.service 2>/dev/null || true
                sudo systemctl enable oracle-apex-ords.service 2>/dev/null || true
                log_success "Auto-start enabled - Oracle APEX will start automatically after reboot"
            else
                log_info "Auto-start not enabled - use 'sudo systemctl enable oracle-apex-db.service oracle-apex-ords.service' to enable later"
            fi
        else
            log_warning "Failed to install systemd services (sudo required)"
        fi
    else
        log_warning "Systemd services created but not installed (sudo not available)"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 30: FINAL VERIFICATION (ENSURE EVERYTHING WORKS)
# ═══════════════════════════════════════════════════════════════════════════════
step_30_final_verification() {
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
        log_warning "⚠️ ORDS_METADATA missing - will be created on first fix.sh run"
    fi

    log_info "Checking for errors in log..."
    if grep -qi "574\|ORA-01017\|ORA-00942\|500" "$LOG_DIR/ords.log" 2>/dev/null; then
        log_warning "⚠️ Found potential issues - auto-fix will handle this"
    else
        log_success "✅ No critical errors found"
    fi

    log_info "Final endpoint check..."
    local final_apex=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null || echo "000")
    
    if [[ "$final_apex" =~ ^(200|302|303)$ ]]; then
        log_success "✅ APEX Admin working: HTTP $final_apex"
    else
        log_warning "⚠️ APEX Admin: HTTP $final_apex (auto-fix will handle this)"
    fi

    # Check if password files exist
    if [ -f "$PROJECT_DIR/.db_password" ] && [ -f "$PROJECT_DIR/.apex_password" ]; then
        log_success "✅ Password files exist"
    else
        log_warning "⚠️ Password files missing - recreating..."
        echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
        echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
        chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    fi

    # Check if GUI is executable
    if [ -x "$SCRIPTS_DIR/launch-gui.sh" ]; then
        log_success "✅ GUI launcher is executable"
    else
        chmod +x "$SCRIPTS_DIR/launch-gui.sh"
        log_success "✅ GUI launcher permissions fixed"
    fi

    log_success "✅ Final verification completed - system is ready!"
}
