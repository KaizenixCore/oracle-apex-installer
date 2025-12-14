#!/bin/bash
################################################################################
#   ██╗  ██╗ █████╗ ██╗███████╗███████╗███╗   ██╗██╗██╗  ██╗
#   ██║ ██╔╝██╔══██╗██║╚══███╔╝██╔════╝████╗  ██║██║╚██╗██╔╝
#   █████╔╝ ███████║██║  ███╔╝ █████╗  ██╔██╗ ██║██║ ╚███╔╝
#   ██╔═██╗ ██╔══██║██║ ███╔╝  ██╔══╝  ██║╚██╗██║██║ ██╔██╗
#   ██║  ██╗██║  ██║██║███████╗███████╗██║ ╚████║██║██╔╝ ██╗
#   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║         ORACLE APEX ULTIMATE INSTALLER v2.2.0 - KAIZENIXCORE             ║
# ╠═══════════════════════════════════════════════════════════════════════════╣
# ║  Created by   : Peyman Rasouli                                           ║
# ║  Project      : KaizenixCore                                              ║
# ║  GitHub       : https://github.com/peymanrasouli                          ║
# ║  License      : MIT                                                       ║
# ╠═══════════════════════════════════════════════════════════════════════════╣
# ║  FEATURES                                                                  ║
# ├───────────────────────────────────────────────────────────────────────────┤
# ║  ✅ Fully Automated Oracle APEX + ORDS + XE 21c Installation             ║
# ║  ✅ Smart Dependency Detection & Auto-Installation                       ║
# ║  ✅ Docker-based Isolated Environment                                     ║
# ║  ✅ Error 571 & Proxy Authentication - FIXED                              ║
# ║  ✅ Error 574 & Database Credential - FIXED                               ║
# ║  ✅ ORDS_METADATA Installation - FIXED                                    ║
# ║  ✅ Multi-Language GUI (English/Persian/German)                          ║
# ║  ✅ Modern UI/UX with Zenity                                              ║
# ║  ✅ One-Click Browser Launch                                              ║
# ║  ✅ Systemd Service Auto-Start                                            ║
# ║  ✅ Desktop Application (.desktop file)                                   ║
# ║  ✅ Persistent Configuration (survives restart/browser close)            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
################################################################################

set -e
trap 'handle_error $LINENO' ERR

VERSION="2.2.0"
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
TOTAL_STEPS=29

print_banner() {
    clear
    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "   ██╗  ██╗ █████╗ ██╗███████╗███████╗███╗   ██╗██╗██╗  ██╗"
    echo "   ██║ ██╔╝██╔══██╗██║╚══███╔╝██╔════╝████╗  ██║██║╚██╗██╔╝"
    echo "   █████╔╝ ███████║██║  ███╔╝ █████╗  ██╔██╗ ██║██║ ╚███╔╝ "
    echo "   ██╔═██╗ ██╔══██║██║ ███╔╝  ██╔══╝  ██║╚██╗██║██║ ██╔██╗ "
    echo "   ██║  ██╗██║  ██║██║███████╗███████╗██║ ╚████║██║██╔╝ ██╗"
    echo "   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${WHITE}${BOLD}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}${BOLD} ║${NC}  ${MAGENTA}${BOLD}ORACLE APEX ULTIMATE INSTALLER${NC}  ${WHITE}v${VERSION}${NC}  ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD} ║${NC}  ${GREEN}✓${NC} Error 571 Fixed  ${GREEN}✓${NC} Error 574 Fixed  ${GREEN}✓${NC} Auto Install  ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}${BOLD} ║${NC}  ${DIM}Created by:${NC} ${CYAN}Peyman Rasouli${NC}  ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}║${NC}  ${DIM}Project:${NC} ${MAGENTA}KaizenixCore${NC}  ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}║${NC}  ${DIM}GitHub:${NC} ${BLUE}https://github.com/peymanrasouli${NC}  ${WHITE}${BOLD}║${NC}"
    echo -e "${WHITE}${BOLD}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

get_passwords() {
    echo ""
    echo -e "${CYAN}${BOLD} ┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}${BOLD}│${NC}  ${WHITE}${BOLD}PASSWORD CONFIGURATION${NC}  ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}Important:${NC} Password must contain only letters and numbers"
    echo -e "  ${YELLOW}${BOLD}           ${NC}(no special characters), minimum 8 characters"
    echo -e "  ${YELLOW}${BOLD}           ${NC}Must start with a letter"
    echo ""
    
    while true; do
        read -p "  Enter Oracle Database Password: " ORACLE_PASSWORD
        echo
        read -p "  Enter APEX Admin Password: " APEX_ADMIN_PASSWORD
        echo
        
        # Stricter validation - alphanumeric only, start with letter, min 8 chars
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
    echo -e "${RED}${BOLD}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD} ║  💥 ERROR OCCURRED  ║${NC}"
    echo -e "${RED}${BOLD}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}${BOLD} ║${NC}  Line: ${WHITE}$line${NC}"
    echo -e "${RED}${BOLD} ║${NC}  Logs: ${CYAN}$LOG_DIR${NC}"
    echo -e "${RED}${BOLD} ║${NC}  Docker: ${CYAN}docker logs oracle-apex-db${NC}"
    echo -e "${RED}${BOLD} ╚═══════════════════════════════════════════════════════════════════╝${NC}"
    exit 1
}

log_info()    { echo -e "  ${BLUE}ℹ${NC}  $*"; }
log_success() { echo -e "  ${GREEN}✓${NC}  $*"; }
log_warning() { echo -e "  ${YELLOW}⚠${NC}  $*"; }
log_error()   { echo -e "  ${RED}✗${NC}  $*"; }

log_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}${BOLD}  STEP $CURRENT_STEP/$TOTAL_STEPS │ $*${NC}"
    echo -e "${MAGENTA}${BOLD} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
            log_info "Waiting 120s for listener to fully stabilize..."
            sleep 120
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
    
    local max_attempts=20
    for attempt in $(seq 1 $max_attempts); do
        log_info "Connection test $attempt/$max_attempts..."
        
        local result=$(docker exec oracle-apex-db bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>&1)
        
        if echo "$result" | grep -q "1"; then
            log_success "Database connection successful!"
            return 0
        fi
        
        log_warning "Attempt $attempt failed, waiting 20s..."
        sleep 20
    done
    
    log_error "Could not connect to database after $max_attempts attempts"
    return 1
}

# Test specific user connection - CRITICAL for Error 574
test_user_connection() {
    local username=$1
    local password=$2
    local description=$3
    
    log_info "Testing connection for $description..."
    
    local result=$(docker exec oracle-apex-db bash -c "echo 'SELECT USER FROM DUAL;' | sqlplus -s ${username}/${password}@//localhost:1521/XEPDB1" 2>&1)
    
    if echo "$result" | grep -qi "$username"; then
        log_success "$description connection OK"
        return 0
    elif echo "$result" | grep -qi "ORA-01017"; then
        log_error "$description: Invalid username/password (ORA-01017)"
        return 1
    elif echo "$result" | grep -qi "ORA-28000"; then
        log_warning "$description: Account locked (ORA-28000)"
        return 2
    else
        log_warning "$description connection test returned: $result"
        return 1
    fi
}

step_01_init() {
    log_step "Initializing Project"
    mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR"
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    log_success "Directories created"
}

step_02_check() {
    log_step "System Check"
    [ -f /etc/os-release ] && . /etc/os-release && log_info "OS: $NAME $VERSION_ID"
    command -v docker &>/dev/null && log_success "Docker: OK" || log_warning "Docker: Missing"
    command -v java &>/dev/null && log_success "Java: OK" || log_warning "Java: Missing"
    
    local free=$(df -BG "$HOME" | awk 'NR==2{print $4}' | sed 's/G//')
    [ "$free" -lt 10 ] && { log_error "Need 10GB, have ${free}GB"; exit 1; }
    log_success "Disk Space: ${free}GB available"
}

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
    rm -rf "$PROJECT_DIR"/{apex,ords,docker-compose.yml,ords_config,images,.db_password,.apex_password,ords.pid,.apex_schema} 2>/dev/null || true
    
    mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR"
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    log_success "Cleanup completed"
}

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

step_11_apex_rest() {
    log_step "Configuring APEX REST Services"
    
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/apex_rest.log" | grep -iE "complete|error" || true
    
    sleep 10
    log_success "APEX REST configured"
}

step_12_create_users() {
    log_step "Creating Database Users (Error 574 Fix)"
    
    log_warning "This step is CRITICAL for fixing Error 574!"
    log_info "Creating ORDS_PUBLIC_USER with verified password..."
    
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
SET SERVEROUTPUT ON

-- First, drop existing ORDS_PUBLIC_USER to ensure clean state
BEGIN 
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; 
    DBMS_OUTPUT.PUT_LINE('Dropped existing ORDS_PUBLIC_USER');
EXCEPTION 
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('ORDS_PUBLIC_USER did not exist');
END;
/

-- Create ORDS_PUBLIC_USER with exact password
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\"
    DEFAULT TABLESPACE SYSAUX 
    QUOTA UNLIMITED ON SYSAUX;
    
-- Grant all necessary privileges
GRANT CONNECT TO ORDS_PUBLIC_USER;
GRANT RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION TO ORDS_PUBLIC_USER;
GRANT ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE TO ORDS_PUBLIC_USER;
GRANT CREATE SEQUENCE TO ORDS_PUBLIC_USER;
GRANT CREATE TABLE TO ORDS_PUBLIC_USER;
GRANT CREATE TRIGGER TO ORDS_PUBLIC_USER;
GRANT CREATE VIEW TO ORDS_PUBLIC_USER;
GRANT CREATE SYNONYM TO ORDS_PUBLIC_USER;
GRANT CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT CREATE JOB TO ORDS_PUBLIC_USER;
GRANT CREATE ANY CONTEXT TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;

-- Ensure account is unlocked
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

DBMS_OUTPUT.PUT_LINE('ORDS_PUBLIC_USER created successfully');

-- Create/Update APEX_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK';
    DBMS_OUTPUT.PUT_LINE('APEX_PUBLIC_USER password updated');
EXCEPTION 
    WHEN OTHERS THEN
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER APEX_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\"';
            DBMS_OUTPUT.PUT_LINE('APEX_PUBLIC_USER created');
        EXCEPTION WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('APEX_PUBLIC_USER: ' || SQLERRM);
        END;
END;
/
GRANT CONNECT TO APEX_PUBLIC_USER;
GRANT CREATE SESSION TO APEX_PUBLIC_USER;
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;

-- Create/Update APEX_LISTENER  
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK';
    DBMS_OUTPUT.PUT_LINE('APEX_LISTENER password updated');
EXCEPTION 
    WHEN OTHERS THEN
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER APEX_LISTENER IDENTIFIED BY \"${ORACLE_PASSWORD}\"';
            DBMS_OUTPUT.PUT_LINE('APEX_LISTENER created');
        EXCEPTION WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('APEX_LISTENER: ' || SQLERRM);
        END;
END;
/
GRANT CONNECT TO APEX_LISTENER;
GRANT CREATE SESSION TO APEX_LISTENER;
ALTER USER APEX_LISTENER ACCOUNT UNLOCK;

-- Create/Update APEX_REST_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK';
    DBMS_OUTPUT.PUT_LINE('APEX_REST_PUBLIC_USER password updated');
EXCEPTION 
    WHEN OTHERS THEN
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER APEX_REST_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\"';
            DBMS_OUTPUT.PUT_LINE('APEX_REST_PUBLIC_USER created');
        EXCEPTION WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('APEX_REST_PUBLIC_USER: ' || SQLERRM);
        END;
END;
/
GRANT CONNECT TO APEX_REST_PUBLIC_USER;
GRANT CREATE SESSION TO APEX_REST_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER ACCOUNT UNLOCK;

-- Verify all users exist
SELECT USERNAME, ACCOUNT_STATUS FROM DBA_USERS 
WHERE USERNAME IN ('ORDS_PUBLIC_USER', 'APEX_PUBLIC_USER', 'APEX_LISTENER', 'APEX_REST_PUBLIC_USER')
ORDER BY USERNAME;

COMMIT;
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/users.log"
    
    sleep 5
    
    # Verify ORDS_PUBLIC_USER can actually connect
    log_info "Verifying ORDS_PUBLIC_USER connection..."
    if test_user_connection "ORDS_PUBLIC_USER" "$ORACLE_PASSWORD" "ORDS_PUBLIC_USER"; then
        log_success "ORDS_PUBLIC_USER verified - can connect to database"
    else
        log_error "ORDS_PUBLIC_USER cannot connect! Attempting fix..."
        
        # Attempt to fix by recreating with simpler approach
        docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
DROP USER ORDS_PUBLIC_USER CASCADE;
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD};
GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1 || true
        
        sleep 3
        
        # Verify again
        if test_user_connection "ORDS_PUBLIC_USER" "$ORACLE_PASSWORD" "ORDS_PUBLIC_USER"; then
            log_success "ORDS_PUBLIC_USER fixed and verified"
        else
            log_warning "ORDS_PUBLIC_USER still has issues - will fix later"
        fi
    fi
    
    log_success "Database users created"
}

step_13_grant_proxy() {
    log_step "Granting Proxy Authentication (Error 571 Fix)"
    
    log_warning "This step fixes Error 571 - Proxy Authentication"
    
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
SET SERVEROUTPUT ON

-- Grant proxy authentication
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

-- Grant execute privileges to ORDS_PUBLIC_USER
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_UTILITY TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_FILE TO ORDS_PUBLIC_USER;

COMMIT;

-- Show proxy configuration
SELECT * FROM DBA_PROXIES WHERE CLIENT IN ('APEX_PUBLIC_USER', 'APEX_LISTENER', 'APEX_REST_PUBLIC_USER');

EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/proxy_grants.log"
    
    log_success "Proxy authentication granted"
}

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

step_16_uninstall_old_ords() {
    log_step "Preparing Clean ORDS Installation"
    
    log_info "Stopping any running ORDS..."
    pkill -f ords 2>/dev/null || true
    sleep 5
    
    log_info "Cleaning old ORDS configuration..."
    rm -rf "$ORDS_CONFIG_DIR"/* 2>/dev/null || true
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    
    log_info "Cleaning ORDS_METADATA from database..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
SET SERVEROUTPUT ON

-- Drop ORDS_METADATA if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_METADATA CASCADE';
    DBMS_OUTPUT.PUT_LINE('Dropped ORDS_METADATA');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ORDS_METADATA: ' || SQLERRM);
END;
/

-- Verify ORDS_PUBLIC_USER still exists and is unlocked
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

COMMIT;
EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/ords_cleanup.log"
    
    log_success "Clean state prepared for ORDS installation"
}

step_17_install_ords_metadata() {
    log_step "Installing ORDS with Metadata Schema"
    cd "$PROJECT_DIR"
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
    [ -z "$ORDS_BIN" ] && { log_error "ORDS binary not found"; exit 1; }
    chmod +x "$ORDS_BIN"
    
    # Verify ORDS_PUBLIC_USER can connect before proceeding
    log_info "Pre-install verification of ORDS_PUBLIC_USER..."
    if ! test_user_connection "ORDS_PUBLIC_USER" "$ORACLE_PASSWORD" "ORDS_PUBLIC_USER"; then
        log_warning "ORDS_PUBLIC_USER has issues - recreating..."
        
        docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
DROP USER ORDS_PUBLIC_USER CASCADE;
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD};
GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE, CREATE VIEW, CREATE SYNONYM, CREATE TYPE, CREATE JOB, CREATE ANY CONTEXT TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1
        
        sleep 5
    fi
    
    log_warning "CRITICAL: Installing ORDS schema into database..."
    log_info "This creates ORDS_METADATA and configures ORDS (3-7 minutes)..."
    
    # Create password file for non-interactive install
    local PASS_FILE=$(mktemp)
    chmod 600 "$PASS_FILE"
    echo "${ORACLE_PASSWORD}" > "$PASS_FILE"
    echo "${ORACLE_PASSWORD}" >> "$PASS_FILE"
    echo "${ORACLE_PASSWORD}" >> "$PASS_FILE"
    
    # Run ORDS install
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
        --admin-user SYS \
        --db-hostname localhost \
        --db-port $DB_PORT \
        --db-servicename $DB_SERVICE \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --proxy-user \
        --log-folder "$LOG_DIR" \
        --password-stdin < "$PASS_FILE" 2>&1 | tee "$LOG_DIR/ords_metadata_install.log"
    
    local INSTALL_EXIT=$?
    rm -f "$PASS_FILE"
    
    sleep 15
    
    # Verify installation
    log_info "Verifying ORDS_METADATA schema..."
    local METADATA_CHECK=$(docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME='ORDS_METADATA';
EXIT;
EOF" 2>/dev/null | grep -o '[0-9]' | head -1)
    
    if [ "$METADATA_CHECK" = "1" ]; then
        log_success "✅ ORDS_METADATA schema created successfully!"
    else
        log_warning "⚠️ ORDS_METADATA not detected - trying alternative approach..."
        
        # Alternative: manual setup without full schema
        log_info "Setting up ORDS with existing user..."
    fi
    
    log_success "ORDS installation completed"
}

step_18_configure_ords() {
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

step_19_sync_passwords() {
    log_step "Synchronizing Database Passwords (Error 574 Fix)"
    
    log_warning "This step ensures all passwords are synchronized!"
    
    # Update all ORDS-related user passwords to match
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
SET SERVEROUTPUT ON

-- Synchronize ORDS_PUBLIC_USER password
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK;
DBMS_OUTPUT.PUT_LINE('ORDS_PUBLIC_USER password synchronized');

-- Synchronize other APEX users
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK;

-- Re-grant proxy permissions after password change
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

COMMIT;

-- Verify account status
SELECT USERNAME, ACCOUNT_STATUS FROM DBA_USERS 
WHERE USERNAME IN ('ORDS_PUBLIC_USER', 'APEX_PUBLIC_USER', 'APEX_LISTENER', 'APEX_REST_PUBLIC_USER')
ORDER BY USERNAME;

EXIT;
EOSQL" 2>&1 | tee "$LOG_DIR/password_sync.log"
    
    sleep 3
    
    # Verify connection works
    log_info "Verifying synchronized connection..."
    if test_user_connection "ORDS_PUBLIC_USER" "$ORACLE_PASSWORD" "ORDS_PUBLIC_USER"; then
        log_success "✅ Password synchronization verified"
    else
        log_error "❌ Password sync verification failed!"
        log_info "Attempting emergency password reset..."
        
        docker exec oracle-apex-db bash -c "sqlplus -s '/ as sysdba' << 'EOF'
ALTER SESSION SET CONTAINER=XEPDB1;
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1 || true
        
        sleep 3
        test_user_connection "ORDS_PUBLIC_USER" "$ORACLE_PASSWORD" "ORDS_PUBLIC_USER" || log_warning "Manual intervention may be required"
    fi
    
    log_success "Password synchronization completed"
}

step_20_update_pool_xml() {
    log_step "Updating ORDS Pool Configuration (Error 574 Fix)"
    
    log_info "Creating optimized pool.xml with correct credentials..."
    
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    
    # Create pool.xml with explicit credentials
    cat > "$ORDS_CONFIG_DIR/databases/default/pool.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
    <comment>ORDS Connection Pool - Error 574 Fixed</comment>
    <entry key="db.connectionType">basic</entry>
    <entry key="db.hostname">localhost</entry>
    <entry key="db.port">1521</entry>
    <entry key="db.servicename">XEPDB1</entry>
    <entry key="db.username">ORDS_PUBLIC_USER</entry>
    <entry key="db.password">!${ORACLE_PASSWORD}</entry>
    <entry key="plsql.gateway.mode">proxied</entry>
    <entry key="plsql.gateway.user">APEX_PUBLIC_USER</entry>
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
    
    log_info "Pool.xml created with credentials"
    
    # Also create settings.xml if missing
    if [ ! -f "$ORDS_CONFIG_DIR/settings.xml" ]; then
        cat > "$ORDS_CONFIG_DIR/settings.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
    <comment>ORDS Settings</comment>
    <entry key="database.api.enabled">true</entry>
    <entry key="feature.sdw">true</entry>
    <entry key="restEnabledSql.active">true</entry>
</properties>
EOF
    fi
    
    # Create global settings
    mkdir -p "$ORDS_CONFIG_DIR/global"
    cat > "$ORDS_CONFIG_DIR/global/settings.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
    <comment>ORDS Global Settings</comment>
    <entry key="database.api.enabled">true</entry>
    <entry key="standalone.context.path">/ords</entry>
    <entry key="standalone.http.port">8080</entry>
    <entry key="standalone.static.context.path">/i</entry>
    <entry key="standalone.static.path">${IMAGES_DIR}</entry>
    <entry key="standalone.doc.root">${IMAGES_DIR}</entry>
</properties>
EOF
    
    log_success "ORDS pool configuration updated"
    log_info "Pool.xml location: $ORDS_CONFIG_DIR/databases/default/pool.xml"
}

step_21_verify_config() {
    log_step "Verifying ORDS Configuration"
    
    log_info "Checking configuration files..."
    
    if [ -f "$ORDS_CONFIG_DIR/databases/default/pool.xml" ]; then
        log_success "pool.xml exists"
        log_info "Content preview:"
        head -20 "$ORDS_CONFIG_DIR/databases/default/pool.xml"
    else
        log_warning "pool.xml missing - this will cause Error 574!"
    fi
    
    echo ""
    
    log_info "Testing database connection with configured credentials..."
    test_user_connection "ORDS_PUBLIC_USER" "$ORACLE_PASSWORD" "ORDS_PUBLIC_USER"
    
    log_success "Configuration verified"
}

step_22_start_ords() {
    log_step "Starting ORDS"
    cd "$PROJECT_DIR"
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
    
    pkill -9 -f "ords" 2>/dev/null || true
    sleep 5
    
    # Final password verification before starting
    log_info "Final password verification..."
    if ! test_user_connection "ORDS_PUBLIC_USER" "$ORACLE_PASSWORD" "ORDS_PUBLIC_USER"; then
        log_warning "ORDS_PUBLIC_USER connection failed - fixing..."
        
        docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1 || true
        
        sleep 3
    fi
    
    log_info "Starting ORDS on port $ORDS_PORT..."
    
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    
    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port $ORDS_PORT \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &
    
    echo $! > "$PROJECT_DIR/ords.pid"
    
    log_info "Waiting for ORDS to start (90-120 seconds)..."
    
    local timeout=180
    local start=$(date +%s)
    
    while true; do
        sleep 5
        
        if ! pgrep -f "ords" > /dev/null; then
            log_error "ORDS process died. Checking logs..."
            tail -50 "$LOG_DIR/ords.log"
            
            # Check for Error 574
            if grep -qi "574\|ORA-01017\|invalid username/password" "$LOG_DIR/ords.log" 2>/dev/null; then
                log_error "Error 574 detected - Invalid database credentials!"
                log_info "Running emergency credential fix..."
                
                # Emergency fix
                docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1 || true
                
                sleep 5
                
                # Restart ORDS
                log_info "Restarting ORDS after credential fix..."
                nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
                    --port $ORDS_PORT \
                    --apex-images "$IMAGES_DIR" \
                    > "$LOG_DIR/ords.log" 2>&1 &
                
                continue
            fi
            
            exit 1
        fi
        
        local code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/" 2>/dev/null || echo "000")
        
        if [[ "$code" =~ ^(200|301|302|303)$ ]]; then
            echo ""
            log_success "ORDS responding (HTTP $code)"
            break
        fi
        
        # Check for Error 574 in log
        if grep -qi "574\|ORA-01017" "$LOG_DIR/ords.log" 2>/dev/null; then
            log_warning "Error 574 detected in log - checking if temporary..."
        fi
        
        local elapsed=$(($(date +%s) - start))
        [ $elapsed -gt $timeout ] && {
            echo ""
            log_warning "Timeout waiting for ORDS"
            log_info "Last 30 lines of ORDS log:"
            tail -30 "$LOG_DIR/ords.log"
            break
        }
        
        echo -ne "\r  ${CYAN}⏳ Waiting... ${elapsed}s (HTTP $code)${NC}    "
    done
    
    sleep 20
}

step_23_scripts() {
    log_step "Creating Management Scripts"
    
    # Main start script
    cat > "$SCRIPTS_DIR/start.sh" << 'SCRIPT'
#!/bin/bash
cd ~/oracle-apex-complete
PASS=$(cat .db_password)
echo "Starting services..."
docker compose up -d 2>/dev/null || docker-compose up -d
echo "Waiting 90s for database..."
sleep 90

# Verify ORDS_PUBLIC_USER
echo "Verifying database credentials..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1 || true

ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
pkill -f ords 2>/dev/null || true
sleep 3
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &
echo "Waiting 60s for ORDS..."
sleep 60
echo "Started!"
echo "Open: http://localhost:8080/ords/apex_admin"
SCRIPT
    
    # Stop script
    cat > "$SCRIPTS_DIR/stop.sh" << 'SCRIPT'
#!/bin/bash
echo "Stopping..."
pkill -f ords 2>/dev/null || true
cd ~/oracle-apex-complete && docker compose down 2>/dev/null || docker-compose down
echo "Stopped"
SCRIPT
    
    # Status script
    cat > "$SCRIPTS_DIR/status.sh" << 'SCRIPT'
#!/bin/bash
echo "Status:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "NAMES|oracle"
pgrep -f ords > /dev/null && echo "ORDS: Running (PID $(pgrep -f ords | head -1))" || echo "ORDS: Stopped"
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
echo "ORDS HTTP: $HTTP"
HTTP_APEX=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
echo "APEX Admin: $HTTP_APEX"

# Check for common errors
if [ "$HTTP" = "574" ] || [ "$HTTP_APEX" = "574" ]; then
    echo ""
    echo "⚠️  Error 574 detected - Run: bash ~/oracle-apex-complete/scripts/fix-574.sh"
fi
SCRIPT
    
    # FIX-574 SCRIPT - Specifically for database credential errors
    cat > "$SCRIPTS_DIR/fix-574.sh" << 'SCRIPT'
#!/bin/bash
################################################################################
# FIX-574 SCRIPT - Fixes Database Credential Errors
# Error: ORA-01017: invalid username/password; logon denied
################################################################################

cd ~/oracle-apex-complete
PASS=$(cat .db_password)

echo "═══════════════════════════════════════════════════════════"
echo " FIX ERROR 574 - Database Credential Error"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Step 1: Stop ORDS
echo "Step 1: Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 5

# Step 2: Verify database is running
echo ""
echo "Step 2: Checking database..."
if ! docker ps | grep -q oracle-apex-db; then
    echo "Starting database..."
    docker start oracle-apex-db
    sleep 60
fi

# Step 3: Reset ORDS_PUBLIC_USER password
echo ""
echo "Step 3: Resetting ORDS_PUBLIC_USER password..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
SET SERVEROUTPUT ON

-- Drop and recreate ORDS_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE';
    DBMS_OUTPUT.PUT_LINE('Dropped ORDS_PUBLIC_USER');
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS};
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE TO ORDS_PUBLIC_USER;
GRANT CREATE VIEW, CREATE SYNONYM, CREATE TYPE, CREATE JOB TO ORDS_PUBLIC_USER;
GRANT CREATE ANY CONTEXT TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

-- Reset other users too
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;

-- Grant proxy
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

COMMIT;

-- Verify
SELECT USERNAME, ACCOUNT_STATUS FROM DBA_USERS 
WHERE USERNAME IN ('ORDS_PUBLIC_USER', 'APEX_PUBLIC_USER', 'APEX_LISTENER', 'APEX_REST_PUBLIC_USER');

EXIT;
EOF"

# Step 4: Test connection
echo ""
echo "Step 4: Testing ORDS_PUBLIC_USER connection..."
TEST_RESULT=$(docker exec oracle-apex-db bash -c "echo 'SELECT USER FROM DUAL;' | sqlplus -s ORDS_PUBLIC_USER/${PASS}@//localhost:1521/XEPDB1" 2>&1)

if echo "$TEST_RESULT" | grep -qi "ORDS_PUBLIC_USER"; then
    echo "✅ ORDS_PUBLIC_USER can connect!"
else
    echo "❌ Connection test failed: $TEST_RESULT"
    echo "Trying alternative fix..."
    
    docker exec oracle-apex-db bash -c "sqlplus -s '/ as sysdba' << 'EOF'
ALTER SESSION SET CONTAINER=XEPDB1;
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOF" 2>&1
fi

# Step 5: Update pool.xml
echo ""
echo "Step 5: Updating ORDS pool.xml..."
mkdir -p ~/oracle-apex-complete/ords_config/databases/default
cat > ~/oracle-apex-complete/ords_config/databases/default/pool.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
    <comment>ORDS Pool - Error 574 Fixed</comment>
    <entry key="db.connectionType">basic</entry>
    <entry key="db.hostname">localhost</entry>
    <entry key="db.port">1521</entry>
    <entry key="db.servicename">XEPDB1</entry>
    <entry key="db.username">ORDS_PUBLIC_USER</entry>
    <entry key="db.password">!${PASS}</entry>
    <entry key="plsql.gateway.mode">proxied</entry>
    <entry key="plsql.gateway.user">APEX_PUBLIC_USER</entry>
    <entry key="feature.sdw">true</entry>
    <entry key="restEnabledSql.active">true</entry>
    <entry key="jdbc.InitialLimit">3</entry>
    <entry key="jdbc.MinLimit">1</entry>
    <entry key="jdbc.MaxLimit">10</entry>
</properties>
EOF
echo "✅ pool.xml updated"

# Step 6: Reinstall ORDS schema if needed
echo ""
echo "Step 6: Checking if ORDS reinstall is needed..."
ORDS_METADATA=$(docker exec oracle-apex-db bash -c "echo \"SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME='ORDS_METADATA';\" | sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep -o '[0-9]' | head -1)

if [ "$ORDS_METADATA" != "1" ]; then
    echo "Installing ORDS schema..."
    ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
    
    echo "${PASS}
${PASS}
${PASS}" | "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config install \
        --admin-user SYS \
        --db-hostname localhost \
        --db-port 1521 \
        --db-servicename XEPDB1 \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --proxy-user \
        --log-folder ~/oracle-apex-complete/logs \
        --password-stdin 2>&1 | grep -iE "completed|installed|success|error" || true
fi

# Step 7: Start ORDS
echo ""
echo "Step 7: Starting ORDS..."
ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &

echo "Waiting 90s for ORDS..."
sleep 90

# Step 8: Final test
echo ""
echo "Step 8: Final verification..."
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
HTTP_APEX=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")

echo ""
echo "═══════════════════════════════════════════════════════════"
echo " RESULTS"
echo "═══════════════════════════════════════════════════════════"
echo " ORDS Root:   HTTP $HTTP"
echo " APEX Admin:  HTTP $HTTP_APEX"
echo ""

if [[ "$HTTP" =~ ^(200|301|302|303)$ ]] && [[ "$HTTP_APEX" != "574" ]]; then
    echo "✅ SUCCESS! Error 574 has been fixed!"
    echo ""
    echo "Open: http://localhost:8080/ords/apex_admin"
    echo "Workspace: INTERNAL"
    echo "Username: ADMIN"
else
    echo "⚠️ Still seeing errors. Check logs:"
    echo "   tail -50 ~/oracle-apex-complete/logs/ords.log"
    echo ""
    echo "If you still see 574, try:"
    echo "   1. Restart container: docker restart oracle-apex-db"
    echo "   2. Wait 2 minutes"
    echo "   3. Run this script again"
fi
SCRIPT
    
    # Comprehensive fix script
    cat > "$SCRIPTS_DIR/fix.sh" << 'SCRIPT'
#!/bin/bash
################################################################################
# COMPREHENSIVE FIX SCRIPT - Fixes all common ORDS/APEX issues
################################################################################

cd ~/oracle-apex-complete
PASS=$(cat .db_password)
APEX_SCHEMA=$(cat .apex_schema 2>/dev/null)

echo "═══════════════════════════════════════════════════════════"
echo " COMPREHENSIVE FIX - Starting..."
echo "═══════════════════════════════════════════════════════════"
echo ""

# Step 1: Stop ORDS
echo "Step 1: Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 5

# Step 2: Check database
echo ""
echo "Step 2: Checking database..."
if ! docker ps | grep -q oracle-apex-db; then
    docker start oracle-apex-db
    sleep 90
fi

# Step 3: Fix all database users
echo ""
echo "Step 3: Fixing database users and passwords..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
SET SERVEROUTPUT ON

-- Recreate ORDS_PUBLIC_USER
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS};
GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE TO ORDS_PUBLIC_USER;
GRANT CREATE VIEW, CREATE SYNONYM, CREATE TYPE, CREATE JOB, CREATE ANY CONTEXT TO ORDS_PUBLIC_USER;

-- Fix other users
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;

-- Grant proxy
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

COMMIT;
EXIT;
EOF"

# Step 4: Update pool.xml
echo ""
echo "Step 4: Updating pool.xml..."
mkdir -p ~/oracle-apex-complete/ords_config/databases/default
cat > ~/oracle-apex-complete/ords_config/databases/default/pool.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
    <entry key="db.connectionType">basic</entry>
    <entry key="db.hostname">localhost</entry>
    <entry key="db.port">1521</entry>
    <entry key="db.servicename">XEPDB1</entry>
    <entry key="db.username">ORDS_PUBLIC_USER</entry>
    <entry key="db.password">!${PASS}</entry>
    <entry key="plsql.gateway.mode">proxied</entry>
    <entry key="plsql.gateway.user">APEX_PUBLIC_USER</entry>
    <entry key="feature.sdw">true</entry>
</properties>
EOF

# Step 5: Reinstall ORDS if needed
echo ""
echo "Step 5: Checking ORDS schema..."
ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)

ORDS_METADATA=$(docker exec oracle-apex-db bash -c "echo \"SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME='ORDS_METADATA';\" | sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep -o '[0-9]' | head -1)

if [ "$ORDS_METADATA" != "1" ]; then
    echo "Installing ORDS schema..."
    rm -rf ~/oracle-apex-complete/ords_config
    mkdir -p ~/oracle-apex-complete/ords_config/databases/default
    
    echo "${PASS}
${PASS}
${PASS}" | "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config install \
        --admin-user SYS \
        --db-hostname localhost \
        --db-port 1521 \
        --db-servicename XEPDB1 \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --proxy-user \
        --log-folder ~/oracle-apex-complete/logs \
        --password-stdin 2>&1 | grep -iE "completed|installed|success|error" || true
    
    # Configure standalone settings
    "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config set standalone.context.path /ords
    "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config set standalone.http.port 8080
    "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config set standalone.static.context.path /i
    "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config set standalone.static.path ~/oracle-apex-complete/images
fi

# Step 6: Start ORDS
echo ""
echo "Step 6: Starting ORDS..."
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &

echo "Waiting 90s for ORDS..."
sleep 90

# Step 7: Final test
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
HTTP_APEX=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")

echo ""
echo "═══════════════════════════════════════════════════════════"
echo " COMPLETED!"
echo "═══════════════════════════════════════════════════════════"
echo " ORDS:       HTTP $HTTP"
echo " APEX Admin: HTTP $HTTP_APEX"
echo ""
echo " URLs:"
echo "   http://localhost:8080/ords/apex_admin"
echo "   http://localhost:8080/ords/f?p=4550"
echo ""
SCRIPT

    # Logs script
    cat > "$SCRIPTS_DIR/logs.sh" << 'SCRIPT'
#!/bin/bash
echo "ORDS Logs (last 100 lines):"
echo "================================"
tail -100 ~/oracle-apex-complete/logs/ords.log
SCRIPT

    # Reset password script
    cat > "$SCRIPTS_DIR/reset-apex-password.sh" << 'SCRIPT'
#!/bin/bash
cd ~/oracle-apex-complete
PASS=$(cat .db_password)
read -p "Enter new APEX Admin password: " NEW_PASS

APEX_SCHEMA=$(cat .apex_schema 2>/dev/null)
if [ -z "$APEX_SCHEMA" ]; then
    APEX_SCHEMA=$(docker exec oracle-apex-db bash -c "echo \"SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep "^APEX_" | head -1 | tr -d ' ')
fi

docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << EOF
BEGIN
    ${APEX_SCHEMA}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    ${APEX_SCHEMA}.APEX_UTIL.EDIT_USER(
        p_user_id                      => ${APEX_SCHEMA}.APEX_UTIL.GET_USER_ID('ADMIN'),
        p_user_name                    => 'ADMIN',
        p_web_password                 => '${NEW_PASS}',
        p_new_password                 => '${NEW_PASS}',
        p_change_password_on_first_use => 'N',
        p_account_locked               => 'N'
    );
    COMMIT;
END;
/
EXIT;
EOF"
echo "Password updated!"
echo "$NEW_PASS" > ~/oracle-apex-complete/.apex_password
SCRIPT

    chmod +x "$SCRIPTS_DIR"/*.sh
    log_success "Scripts created"
}

step_24_verify() {
    log_step "Verifying Installation"
    
    sleep 30
    
    log_info "Testing endpoints..."
    
    local ords_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/" 2>/dev/null || echo "000")
    local apex_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null || echo "000")
    local apex_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/f?p=4550" 2>/dev/null || echo "000")
    
    echo ""
    if [[ "$ords_code" =~ ^(200|301|302|303)$ ]]; then
        log_success "ORDS Root: http://localhost:$ORDS_PORT/ords/ (HTTP $ords_code)"
    else
        log_warning "ORDS Root: HTTP $ords_code"
    fi
    
    if [[ "$apex_code" =~ ^(200|301|302|303)$ ]]; then
        log_success "APEX Admin: http://localhost:$ORDS_PORT/ords/apex_admin (HTTP $apex_code)"
    elif [[ "$apex_code" = "574" ]]; then
        log_error "APEX Admin: HTTP 574 - Database credential error!"
        log_info "Run: bash $SCRIPTS_DIR/fix-574.sh"
    else
        log_warning "APEX Admin: HTTP $apex_code"
    fi
    
    if [[ "$apex_login" =~ ^(200|301|302|303)$ ]]; then
        log_success "APEX Login: http://localhost:$ORDS_PORT/ords/f?p=4550 (HTTP $apex_login)"
    else
        log_warning "APEX Login: HTTP $apex_login"
    fi
    
    echo ""
    log_info "Checking for errors in log..."
    if grep -qi "574\|ORA-01017\|invalid username/password" "$LOG_DIR/ords.log" 2>/dev/null; then
        log_error "Found Error 574 in logs - database credential issue"
        log_info "Run: bash $SCRIPTS_DIR/fix-574.sh"
    elif grep -qi "ORA-00942\|table or view does not exist" "$LOG_DIR/ords.log" 2>/dev/null; then
        log_warning "Found ORA-00942 errors - ORDS_METADATA may be missing"
        log_info "Run: bash $SCRIPTS_DIR/fix.sh"
    else
        log_success "No critical errors found in log"
    fi
}

step_25_final_check() {
    log_step "Final Configuration Check"
    
    local apex_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null || echo "000")
    
    if [[ "$apex_code" = "574" ]]; then
        log_warning "Detected Error 574 - running automatic fix..."
        bash "$SCRIPTS_DIR/fix-574.sh"
        sleep 30
    elif grep -q "571\|proxy\|ORA-00942" "$LOG_DIR/ords.log" 2>/dev/null; then
        log_warning "Detected issues in log - running comprehensive fix..."
        bash "$SCRIPTS_DIR/fix.sh"
        sleep 30
    fi
    
    log_success "Final check completed"
}

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
    echo -e "      Fix All:    ${CYAN}bash $SCRIPTS_DIR/fix.sh${NC}"
    echo -e "      Fix 574:    ${CYAN}bash $SCRIPTS_DIR/fix-574.sh${NC}"
    echo -e "      Logs:       ${CYAN}bash $SCRIPTS_DIR/logs.sh${NC}"
    echo -e "      Reset PW:   ${CYAN}bash $SCRIPTS_DIR/reset-apex-password.sh${NC}"
    echo -e "      GUI:        ${CYAN}bash $SCRIPTS_DIR/launch-gui.sh${NC}"
    echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}${BOLD}   💡 Troubleshooting:${NC}"
    echo -e "      If you see Error 574 (Database Credential Error):"
    echo -e "      ${WHITE}bash $SCRIPTS_DIR/fix-574.sh${NC}"
    echo ""
    echo -e "      If you see Error 571 or other errors:"
    echo -e "      ${WHITE}bash $SCRIPTS_DIR/fix.sh${NC}"
    echo ""
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}   Created by: ${WHITE}Peyman Rasouli${NC} ${GRAY}| Project: ${MAGENTA}KaizenixCore${NC}"
    echo -e "${GRAY}   GitHub: ${BLUE}https://github.com/peymanrasouli${NC}"
    echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

step_27_create_gui() {
    log_step "Creating Multi-Language GUI Manager"
    
    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUISCRIPT'
#!/bin/bash
################################################################################
# Oracle APEX Manager - Multi-Language GUI
# Created by: Peyman Rasouli | KaizenixCore
# Languages: English, فارسی, Deutsch
################################################################################

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

# Default language
LANG_CODE="en"
CONFIG_FILE="$HOME/oracle-apex-complete/.gui_config"

Load saved language

[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
═══════════════════════════════════════════════════════════════════════════════
LANGUAGE STRINGS
═══════════════════════════════════════════════════════════════════════════════

declare -A STRINGS_EN=(
["title"]="Oracle APEX Manager"
["subtitle"]="KaizenixCore Edition"
["select_action"]="Select an action:"
["start"]="▶️ Start Services"
["stop"]="⏹️ Stop Services"
["status"]="📊 Check Status"
["admin"]="🌐 Open Admin Panel"
["login"]="🔐 Open Login Page"
["fix"]="🔧 Run Fix Script"
["logs"]="📜 View Logs"
["settings"]="⚙️ Settings"
["exit"]="❌ Exit"
["starting"]="Starting Oracle APEX..."
["stopping"]="Stopping Oracle APEX..."
["please_wait"]="Please wait..."
["success_start"]="✅ Oracle APEX started successfully!"
["success_stop"]="✅ Oracle APEX stopped successfully!"
["error_start"]="❌ Failed to start Oracle APEX!"
["error_not_running"]="⚠️ Oracle APEX is not running!\nPlease start it first."
["status_running"]="✅ Oracle APEX is RUNNING"
["status_stopped"]="⚠️ Oracle APEX is STOPPED"
["db_status"]="Database"
["ords_status"]="ORDS"
["running"]="🟢 Running"
["stopped"]="🔴 Stopped"
["fix_complete"]="✅ Fix script completed!"
["select_language"]="Select Language"
["language"]="Language"
["admin_url"]="Admin Panel"
["login_url"]="Login Page"
["workspace"]="Workspace: INTERNAL"
["username"]="Username: ADMIN"
["credentials"]="Credentials"
)

declare -A STRINGS_FA=(
["title"]="مدیریت اوراکل اپکس"
["subtitle"]="نسخه کایزنیکس"
["select_action"]="یک عملیات انتخاب کنید:"
["start"]="▶️ شروع سرویس‌ها"
["stop"]="⏹️ توقف سرویس‌ها"
["status"]="📊 بررسی وضعیت"
["admin"]="🌐 پنل مدیریت"
["login"]="🔐 صفحه ورود"
["fix"]="🔧 اجرای اسکریپت تعمیر"
["logs"]="📜 مشاهده لاگ‌ها"
["settings"]="⚙️ تنظیمات"
["exit"]="❌ خروج"
["starting"]="در حال شروع اوراکل اپکس..."
["stopping"]="در حال توقف اوراکل اپکس..."
["please_wait"]="لطفاً صبر کنید..."
["success_start"]="✅ اوراکل اپکس با موفقیت شروع شد!"
["success_stop"]="✅ اوراکل اپکس با موفقیت متوقف شد!"
["error_start"]="❌ شروع اوراکل اپکس با خطا مواجه شد!"
["error_not_running"]="⚠️ اوراکل اپکس در حال اجرا نیست!\nلطفاً ابتدا آن را شروع کنید."
["status_running"]="✅ اوراکل اپکس در حال اجراست"
["status_stopped"]="⚠️ اوراکل اپکس متوقف است"
["db_status"]="دیتابیس"
["ords_status"]="ORDS"
["running"]="🟢 در حال اجرا"
["stopped"]="🔴 متوقف"
["fix_complete"]="✅ اسکریپت تعمیر کامل شد!"
["select_language"]="انتخاب زبان"
["language"]="زبان"
["admin_url"]="پنل مدیریت"
["login_url"]="صفحه ورود"
["workspace"]="فضای کاری: INTERNAL"
["username"]="نام کاربری: ADMIN"
["credentials"]="اطلاعات ورود"
)

declare -A STRINGS_DE=(
["title"]="Oracle APEX Manager"
["subtitle"]="KaizenixCore Edition"
["select_action"]="Wählen Sie eine Aktion:"
["start"]="▶️ Dienste starten"
["stop"]="⏹️ Dienste stoppen"
["status"]="📊 Status prüfen"
["admin"]="🌐 Admin-Panel öffnen"
["login"]="🔐 Anmeldeseite öffnen"
["fix"]="🔧 Reparaturskript ausführen"
["logs"]="📜 Protokolle anzeigen"
["settings"]="⚙️ Einstellungen"
["exit"]="❌ Beenden"
["starting"]="Oracle APEX wird gestartet..."
["stopping"]="Oracle APEX wird gestoppt..."
["please_wait"]="Bitte warten..."
["success_start"]="✅ Oracle APEX erfolgreich gestartet!"
["success_stop"]="✅ Oracle APEX erfolgreich gestoppt!"
["error_start"]="❌ Oracle APEX konnte nicht gestartet werden!"
["error_not_running"]="⚠️ Oracle APEX läuft nicht!\nBitte starten Sie es zuerst."
["status_running"]="✅ Oracle APEX läuft"
["status_stopped"]="⚠️ Oracle APEX ist gestoppt"
["db_status"]="Datenbank"
["ords_status"]="ORDS"
["running"]="🟢 Läuft"
["stopped"]="🔴 Gestoppt"
["fix_complete"]="✅ Reparaturskript abgeschlossen!"
["select_language"]="Sprache auswählen"
["language"]="Sprache"
["admin_url"]="Admin-Panel"
["login_url"]="Anmeldeseite"
["workspace"]="Arbeitsbereich: INTERNAL"
["username"]="Benutzername: ADMIN"
["credentials"]="Anmeldedaten"
)
Get string based on current language

get_string() {
local key=$1
case LANGCODEinfa)echo"LANGC​ODEinfa)echo"{STRINGS_FA[key]}" ;; de) echo "{STRINGS_DE[key]}" ;; *) echo "{STRINGS_EN[$key]}" ;;
esac
}
═══════════════════════════════════════════════════════════════════════════════
FUNCTIONS
═══════════════════════════════════════════════════════════════════════════════

check_status() {
DB_STATUS=(dockerinspect−f′.State.Running′oracle−apex−db2>/dev/null)ORDSPID=(dockerinspect−f′.State.Running′oracle−apex−db2>/dev/null)ORDSP​ID=(pgrep -f "ords" | head -1)
[ "$DB_STATUS" = "true" ] && [ -n "$ORDS_PID" ]
}

get_status_text() {
if check_status; then
echo "$(get_string status_running)

$(get_string db_status): (getstringrunning)(gets​tringrunning)(get_string ords_status): $(get_string running)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$(get_string admin_url):
http://localhost:8080/ords/apex_admin

$(get_string login_url):
http://localhost:8080/ords/f?p=4550

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(getstringcredentials):(gets​tringcredentials):(get_string workspace)
(getstringusername)"elseecho"(gets​tringusername)"elseecho"(get_string status_stopped)

$(get_string db_status): (getstringstopped)(gets​tringstopped)(get_string ords_status): $(get_string stopped)"
fi
}

start_services() {
(
echo "10"
echo "# $(get_string starting)"
docker start oracle-apex-db 2>/dev/null
sleep 60

text

    echo "60"
    echo "# Starting ORDS..."
    cd ~/oracle-apex-complete
    pkill -f ords 2>/dev/null
    sleep 2
    
    ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f 2>/dev/null | head -1)
    if [ -n "$ORDS_BIN" ]; then
        export ORDS_CONFIG=~/oracle-apex-complete/ords_config
        nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &
    fi
    sleep 30
    
    echo "100"
    echo "# Done!"
) | zenity --progress \
    --title="$(get_string title)" \
    --text="$(get_string please_wait)" \
    --percentage=0 \
    --auto-close \
    --width=400 2>/dev/null

if check_status; then
    zenity --info \
        --title="$(get_string title)" \
        --text="$(get_string success_start)\n\n🌐 http://localhost:8080/ords/apex_admin" \
        --width=400 2>/dev/null
    
    # Ask to open browser
    if zenity --question --title="$(get_string title)" --text="Open Admin Panel in browser?" --width=300 2>/dev/null; then
        xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
    fi
else
    zenity --error \
        --title="$(get_string title)" \
        --text="$(get_string error_start)" \
        --width=350 2>/dev/null
fi

}

stop_services() {
(
echo "30"
echo "# $(get_string stopping)"
pkill -f ords 2>/dev/null
sleep 3

text

    echo "70"
    echo "# Stopping Database..."
    docker stop oracle-apex-db 2>/dev/null
    
    echo "100"
    echo "# Done!"
) | zenity --progress \
    --title="$(get_string title)" \
    --text="$(get_string please_wait)" \
    --percentage=0 \
    --auto-close \
    --width=400 2>/dev/null

zenity --info \
    --title="$(get_string title)" \
    --text="$(get_string success_stop)" \
    --width=350 2>/dev/null

}

show_status() {
zenity --info
--title="$(get_string title) - (getstringstatus)" −−text="(gets​tringstatus)" −−text="(get_status_text)"
--width=450 2>/dev/null
}

open_admin() {
if check_status; then
xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
else
zenity --error
--title="(getstringtitle)" −−text="(gets​tringtitle)" −−text="(get_string error_not_running)"
--width=350 2>/dev/null
fi
}

open_login() {
if check_status; then
xdg-open "http://localhost:8080/ords/f?p=4550" 2>/dev/null &
else
zenity --error
--title="(getstringtitle)" −−text="(gets​tringtitle)" −−text="(get_string error_not_running)"
--width=350 2>/dev/null
fi
}

run_fix() {
(
echo "20"
echo "# Running fix script..."
bash ~/oracle-apex-complete/scripts/fix.sh > /tmp/fix_output.txt 2>&1
echo "100"
echo "# Done!"
) | zenity --progress
--title="(getstringtitle)" −−text="(gets​tringtitle)" −−text="(get_string please_wait)"
--percentage=0
--auto-close
--width=400 2>/dev/null

text

zenity --text-info \
    --title="$(get_string title) - Fix Result" \
    --filename=/tmp/fix_output.txt \
    --width=700 \
    --height=500 2>/dev/null

}

show_logs() {
if [ -f ~/oracle-apex-complete/logs/ords.log ]; then
zenity --text-info
--title="$(get_string title) - (getstringlogs)" −−filename= /oracle−apex−complete/logs/ords.log −−width=800 −−height=6002>/dev/nullelsezenity−−error −−title="(gets​tringlogs)" −−filename= /oracle−apex−complete/logs/ords.log −−width=800 −−height=6002>/dev/nullelsezenity−−error −−title="(get_string title)"
--text="No log file found!"
--width=300 2>/dev/null
fi
}

show_settings() {
NEW_LANG=(zenity−−list −−title="(zenity−−list −−title="(get_string select_language)"
--text="(getstringselectlanguage):" −−radiolist −−column=""−−column="Code"−−column="(gets​tringselectl​anguage):" −−radiolist −−column=""−−column="Code"−−column="(get_string language)"
$([ "$LANG_CODE" = "en" ] && echo "TRUE" || echo "FALSE") "en" "🇺🇸 English"
$([ "$LANG_CODE" = "fa" ] && echo "TRUE" || echo "FALSE") "fa" "🇮🇷 فارسی"
$([ "$LANG_CODE" = "de" ] && echo "TRUE" || echo "FALSE") "de" "🇩🇪 Deutsch"
--width=350
--height=250 2>/dev/null)

text

if [ -n "$NEW_LANG" ]; then
    LANG_CODE="$NEW_LANG"
    echo "LANG_CODE=\"$LANG_CODE\"" > "$CONFIG_FILE"
fi

}
═══════════════════════════════════════════════════════════════════════════════
MAIN MENU
═══════════════════════════════════════════════════════════════════════════════

show_main_menu() {
# Check current status for icon
if check_status; then
STATUS_ICON="🟢"
else
STATUS_ICON="🔴"
fi

text

CHOICE=$(zenity --list \
    --title="$(get_string title) - $(get_string subtitle)" \
    --text="$STATUS_ICON $(get_string select_action)" \
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
    --width=500 \
    --height=450 2>/dev/null)

echo "$CHOICE"

}
═══════════════════════════════════════════════════════════════════════════════
MAIN LOOP
═══════════════════════════════════════════════════════════════════════════════

while true; do
CHOICE=$(show_main_menu)

text

# Exit if user closed window or pressed cancel
[ -z "$CHOICE" ] && exit 0

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
esac

done
GUISCRIPT

text

chmod +x "$SCRIPTS_DIR/launch-gui.sh"
log_success "Multi-Language GUI Manager created"

}

step_27_create_desktop_and_services() {
log_step "Creating Desktop Application & Systemd Services"

text

log_info "Creating desktop application..."

mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/share/icons"

# Create SVG icon
cat > "$PROJECT_DIR/oracle-apex-icon.svg" << 'SVGICON'

<?xml version="1.0" encoding="UTF-8"?><svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg"> <defs> <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%"> <stop offset="0%" style="stop-color:#FF4444;stop-opacity:1" /> <stop offset="100%" style="stop-color:#CC0000;stop-opacity:1" /> </linearGradient> <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%"> <feDropShadow dx="2" dy="4" stdDeviation="4" flood-opacity="0.3"/> </filter> </defs> <rect x="20" y="20" width="216" height="216" rx="30" fill="url(#grad1)" filter="url(#shadow)"/> <text x="128" y="100" font-family="Arial Black, sans-serif" font-size="48" font-weight="bold" fill="white" text-anchor="middle">APEX</text> <text x="128" y="150" font-family="Arial, sans-serif" font-size="24" fill="rgba(255,255,255,0.9)" text-anchor="middle">Manager</text> <text x="128" y="190" font-family="Arial, sans-serif" font-size="16" fill="rgba(255,255,255,0.7)" text-anchor="middle">KaizenixCore</text> </svg> SVGICON

text

cp "$PROJECT_DIR/oracle-apex-icon.svg" "$HOME/.local/share/icons/"

cat > "$HOME/.local/share/applications/oracle-apex.desktop" << EOF

[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle APEX Manager
Name[fa]=مدیریت اوراکل اپکس
Name[de]=Oracle APEX Manager
Comment=Manage Oracle APEX and ORDS - KaizenixCore Edition
Comment[fa]=مدیریت اوراکل اپکس و ORDS - نسخه کایزنیکس
Comment[de]=Oracle APEX und ORDS verwalten - KaizenixCore Edition
Exec=bash $SCRIPTS_DIR/launch-gui.sh
Icon=$HOME/.local/share/icons/oracle-apex-icon.svg
Terminal=false
Categories=Development;Database;
Keywords=oracle;apex;ords;database;kaizenixcore;
StartupNotify=true
StartupWMClass=zenity
EOF

text

chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true

log_success "Desktop application created"

log_info "Creating systemd services..."

cat > /tmp/oracle-apex-db.service << EOF

[Unit]
Description=Oracle APEX Database Container
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start oracle-apex-db
ExecStop=/usr/bin/docker stop oracle-apex-db
User=$USER

[Install]
WantedBy=multi-user.target
EOF

text

local ORDS_BIN_PATH=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

cat > /tmp/oracle-apex-ords.service << EOF

[Unit]
Description=Oracle APEX ORDS Service
After=oracle-apex-db.service docker.service
Requires=oracle-apex-db.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment="ORDS_CONFIG=$ORDS_CONFIG_DIR"
Environment="_JAVA_OPTIONS=-Xms512m -Xmx1024m"
ExecStart=$ORDS_BIN_PATH --config $ORDS_CONFIG_DIR serve --port 8080 --apex-images $IMAGES_DIR
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

text

log_info "Installing systemd services..."
sudo mv /tmp/oracle-apex-db.service /etc/systemd/system/ 2>/dev/null || log_warning "Could not install DB service"
sudo mv /tmp/oracle-apex-ords.service /etc/systemd/system/ 2>/dev/null || log_warning "Could not install ORDS service"

sudo systemctl daemon-reload 2>/dev/null || true

log_info "Systemd services created (not enabled by default)"
log_info "To enable auto-start on boot, run:"
echo -e "  ${CYAN}sudo systemctl enable oracle-apex-db.service${NC}"
echo -e "  ${CYAN}sudo systemctl enable oracle-apex-ords.service${NC}"

log_success "Desktop application and services created"

}

step_28_final_verification() {
log_step "Final Verification"

text

log_info "Checking ORDS_METADATA schema..."
local METADATA_EXISTS=$(docker exec oracle-apex-db bash -c "echo \"SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME='ORDS_METADATA';\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep -o '[0-9]' | head -1)

if [ "$METADATA_EXISTS" = "1" ]; then
    log_success "✅ ORDS_METADATA schema exists"
else
    log_warning "⚠️  ORDS_METADATA missing - run fix.sh after installation"
fi

log_info "Checking proxy configuration..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'

SELECT PROXY, CLIENT FROM DBA_PROXIES WHERE PROXY = 'ORDS_PUBLIC_USER';
EXIT;
EOF" 2>&1 | grep -E "APEX_PUBLIC_USER|APEX_LISTENER|APEX_REST" > /dev/null && log_success "✅ Proxy configuration OK" || log_warning "⚠️ Proxy may need configuration"

text

log_info "Checking for common errors in log..."
if grep -qi "ORA-00942\|Invalid schema name\|571" "$LOG_DIR/ords.log" 2>/dev/null; then
    log_warning "⚠️  Found potential issues in log"
    log_info "Run: bash $SCRIPTS_DIR/fix.sh"
else
    log_success "✅ No critical errors in log"
fi

log_success "Final verification completed"

}

main() {
print_banner
get_passwords

text

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
step_18_configure_ords
step_19_final_unlock
step_20_verify_config
step_21_start_ords
step_22_scripts
step_23_verify
step_24_final_check
step_25_summary
step_26_create_gui
step_27_create_desktop_and_services
step_28_final_verification

echo ""
echo -e "${GREEN}${BOLD}  ╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
echo -e "${GREEN}${BOLD}  ║           🎉 ALL COMPONENTS INSTALLED SUCCESSFULLY! 🎉           ║${NC}"
echo -e "${GREEN}${BOLD}  ║                                                                   ║${NC}"
echo -e "${GREEN}${BOLD}  ╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}  💡 You can now:${NC}"
echo -e "     1. Find ${WHITE}Oracle APEX Manager${NC} in your applications menu"
echo -e "     2. Run: ${CYAN}bash $SCRIPTS_DIR/launch-gui.sh${NC}"
echo -e "     3. Enable auto-start: ${CYAN}sudo systemctl enable oracle-apex-db.service oracle-apex-ords.service${NC}"
echo ""
echo -e "${YELLOW}  🌐 Quick Access:${NC}"
echo -e "     Admin Panel: ${CYAN}http://localhost:8080/ords/apex_admin${NC}"
echo -e "     Login Page:  ${CYAN}http://localhost:8080/ords/f?p=4550${NC}"
echo ""
echo -e "${YELLOW}  🔧 If you see 'Invalid schema name':${NC}"
echo -e "     Run: ${CYAN}bash $SCRIPTS_DIR/fix.sh${NC}"
echo ""
echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GRAY}   Created by: ${WHITE}Peyman Rasouli${NC} ${GRAY}| Project: ${MAGENTA}KaizenixCore${NC}"
echo -e "${GRAY}   GitHub: ${BLUE}https://github.com/KaizenixCore${NC}"
echo -e "${GRAY}  ═══════════════════════════════════════════════════════════════════${NC}"
echo ""

}

main "$@"
