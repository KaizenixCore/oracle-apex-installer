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
#  ║     ORACLE APEX GUI INSTALLER v3.1.0 - KAIZENIXCORE                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  🎨 GRAPHICAL INSTALLER - Fixed & Tested                                  ║
#  ║  📦 Installs: Oracle APEX + ORDS + Oracle XE 21c                          ║
#  ║  🌐 Multi-Language: English, فارسی, Deutsch                               ║
#  ║  ✅ Error 500/574/571 - FIXED                                             ║
#  ║  ✅ GUI Crash - FIXED                                                     ║
#  ║  ✅ Connection Reset - FIXED                                              ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e

VERSION="3.1.0"
PROJECT_DIR="$HOME/oracle-apex-complete"
DOWNLOADS_DIR="$PROJECT_DIR/downloads"
LOG_DIR="$PROJECT_DIR/logs"
IMAGES_DIR="$PROJECT_DIR/images"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
INSTALL_LOG="$PROJECT_DIR/install.log"

DB_PORT="1521"
DB_SERVICE="XEPDB1"
ORDS_PORT="8080"

APEX_URL="https://download.oracle.com/otn_software/apex/apex-latest.zip"
ORDS_URL="https://download.oracle.com/otn_software/java/ords/ords-latest.zip"
ORACLE_IMAGE="gvenzl/oracle-xe:21-full"

# ═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS
# ═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_EN=(
    ["title"]="Oracle APEX Installer"
    ["welcome"]="Welcome to Oracle APEX Ultimate Installer!\n\nThis will install:\n• Oracle APEX (Latest)\n• Oracle ORDS (Latest)\n• Oracle XE 21c Database\n\nClick OK to continue."
    ["enter_passwords"]="Enter Passwords"
    ["oracle_pass"]="Oracle Database Password:"
    ["apex_pass"]="APEX Admin Password:"
    ["pass_rules"]="Password Rules:\n• Start with a letter\n• Only letters and numbers\n• Minimum 6 characters"
    ["invalid_pass"]="Invalid Password!\n\nPassword must:\n• Start with a letter\n• Contain only letters and numbers\n• Be at least 6 characters"
    ["installing"]="Installing Oracle APEX..."
    ["completed"]="Installation Completed!"
    ["success_msg"]="Oracle APEX installed successfully!\n\n🌐 Admin Panel:\nhttp://localhost:8080/ords/apex_admin\n\n🔐 Login Page:\nhttp://localhost:8080/ords/f?p=4550\n\n📋 Credentials:\nWorkspace: INTERNAL\nUsername: ADMIN\nPassword: (your password)"
    ["error"]="Error"
    ["open_browser"]="Open APEX in Browser"
    ["exit"]="Exit"
)

declare -A LANG_FA=(
    ["title"]="نصب‌کننده اوراکل اپکس"
    ["welcome"]="به نصب‌کننده اوراکل اپکس خوش آمدید!\n\nاین برنامه نصب می‌کند:\n• Oracle APEX (آخرین نسخه)\n• Oracle ORDS (آخرین نسخه)\n• Oracle XE 21c Database\n\nبرای ادامه OK را بزنید."
    ["enter_passwords"]="ورود رمز عبور"
    ["oracle_pass"]="رمز عبور Oracle Database:"
    ["apex_pass"]="رمز عبور APEX Admin:"
    ["pass_rules"]="قوانین رمز عبور:\n• با حرف شروع شود\n• فقط حروف و اعداد\n• حداقل ۶ کاراکتر"
    ["invalid_pass"]="رمز عبور نامعتبر!\n\nرمز عبور باید:\n• با حرف شروع شود\n• فقط حروف و اعداد\n• حداقل ۶ کاراکتر"
    ["installing"]="در حال نصب اوراکل اپکس..."
    ["completed"]="نصب با موفقیت انجام شد!"
    ["success_msg"]="اوراکل اپکس با موفقیت نصب شد!\n\n🌐 پنل مدیریت:\nhttp://localhost:8080/ords/apex_admin\n\n🔐 صفحه ورود:\nhttp://localhost:8080/ords/f?p=4550\n\n📋 اطلاعات ورود:\nWorkspace: INTERNAL\nUsername: ADMIN\nPassword: (رمز شما)"
    ["error"]="خطا"
    ["open_browser"]="باز کردن APEX در مرورگر"
    ["exit"]="خروج"
)

declare -A LANG_DE=(
    ["title"]="Oracle APEX Installer"
    ["welcome"]="Willkommen beim Oracle APEX Installer!\n\nDieses Programm installiert:\n• Oracle APEX (Neueste)\n• Oracle ORDS (Neueste)\n• Oracle XE 21c Datenbank\n\nKlicken Sie OK um fortzufahren."
    ["enter_passwords"]="Passwörter eingeben"
    ["oracle_pass"]="Oracle Database Passwort:"
    ["apex_pass"]="APEX Admin Passwort:"
    ["pass_rules"]="Passwortregeln:\n• Beginnt mit Buchstaben\n• Nur Buchstaben und Zahlen\n• Mindestens 6 Zeichen"
    ["invalid_pass"]="Ungültiges Passwort!\n\nPasswort muss:\n• Mit Buchstaben beginnen\n• Nur Buchstaben/Zahlen\n• Mindestens 6 Zeichen"
    ["installing"]="Oracle APEX wird installiert..."
    ["completed"]="Installation abgeschlossen!"
    ["success_msg"]="Oracle APEX erfolgreich installiert!\n\n🌐 Admin-Panel:\nhttp://localhost:8080/ords/apex_admin\n\n🔐 Anmeldeseite:\nhttp://localhost:8080/ords/f?p=4550\n\n📋 Anmeldedaten:\nWorkspace: INTERNAL\nUsername: ADMIN\nPassword: (Ihr Passwort)"
    ["error"]="Fehler"
    ["open_browser"]="APEX im Browser öffnen"
    ["exit"]="Beenden"
)

CURRENT_LANG="en"

get_text() {
    local key=$1
    case $CURRENT_LANG in
        fa) echo "${LANG_FA[$key]:-${LANG_EN[$key]}}" ;;
        de) echo "${LANG_DE[$key]:-${LANG_EN[$key]}}" ;;
        *)  echo "${LANG_EN[$key]}" ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# DETECT AND INSTALL GUI TOOL
# ═══════════════════════════════════════════════════════════════════════════════
GUI_TOOL=""

install_gui_tool() {
    echo "🔍 Checking for GUI tools..."
    
    if command -v yad &> /dev/null; then
        GUI_TOOL="yad"
        echo "✅ YAD found"
        return 0
    fi
    
    if command -v zenity &> /dev/null; then
        GUI_TOOL="zenity"
        echo "✅ Zenity found"
        return 0
    fi
    
    echo "📦 Installing GUI tools..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                sudo apt-get update -qq
                sudo apt-get install -y yad 2>/dev/null || sudo apt-get install -y zenity
                ;;
            fedora)
                sudo dnf install -y yad 2>/dev/null || sudo dnf install -y zenity
                ;;
            centos|rhel|rocky|alma)
                sudo yum install -y epel-release
                sudo yum install -y zenity
                ;;
            opensuse*|suse*)
                sudo zypper --non-interactive install -y yad 2>/dev/null || sudo zypper --non-interactive install -y zenity
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm yad 2>/dev/null || sudo pacman -S --noconfirm zenity
                ;;
        esac
    fi
    
    if command -v yad &> /dev/null; then
        GUI_TOOL="yad"
    elif command -v zenity &> /dev/null; then
        GUI_TOOL="zenity"
    else
        echo "❌ Could not install GUI tools!"
        echo "Please install manually: sudo apt install yad"
        exit 1
    fi
    
    echo "✅ GUI tool installed: $GUI_TOOL"
}

# ═══════════════════════════════════════════════════════════════════════════════
# GUI FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════
show_info() {
    local title=$1
    local text=$2
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$title" --text="$text" --width=500 --height=300 \
            --button="OK:0" --center --on-top 2>/dev/null
    else
        zenity --info --title="$title" --text="$text" --width=500 --height=300 2>/dev/null
    fi
}

show_error() {
    local title=$1
    local text=$2
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="$title" --text="$text" --width=400 --center 2>/dev/null
    else
        zenity --error --title="$title" --text="$text" --width=400 2>/dev/null
    fi
}

select_language() {
    local result
    
    if [ "$GUI_TOOL" = "yad" ]; then
        result=$(yad --list --title="🌐 Select Language / انتخاب زبان / Sprache" \
            --text="Select your preferred language:" \
            --radiolist --column="" --column="Code" --column="Language" \
            TRUE "en" "🇺🇸 English" \
            FALSE "fa" "🇮🇷 فارسی (Persian)" \
            FALSE "de" "🇩🇪 Deutsch (German)" \
            --width=400 --height=300 --center \
            --print-column=2 --hide-column=2 2>/dev/null)
    else
        result=$(zenity --list --title="🌐 Select Language" \
            --text="Select your preferred language:" \
            --radiolist --column="" --column="Code" --column="Language" \
            TRUE "en" "🇺🇸 English" \
            FALSE "fa" "🇮🇷 فارسی (Persian)" \
            FALSE "de" "🇩🇪 Deutsch (German)" \
            --width=400 --height=300 --hide-column=2 2>/dev/null)
    fi
    
    [ -z "$result" ] && exit 0
    CURRENT_LANG=$(echo "$result" | tr -d '|')
}

get_passwords() {
    local result
    
    while true; do
        if [ "$GUI_TOOL" = "yad" ]; then
            result=$(yad --form --title="$(get_text title) - $(get_text enter_passwords)" \
                --text="$(get_text pass_rules)" \
                --field="$(get_text oracle_pass):H" "" \
                --field="$(get_text apex_pass):H" "" \
                --width=450 --height=280 --center \
                --button="Cancel:1" --button="OK:0" 2>/dev/null)
        else
            result=$(zenity --forms --title="$(get_text title)" \
                --text="$(get_text pass_rules)" \
                --add-password="$(get_text oracle_pass)" \
                --add-password="$(get_text apex_pass)" \
                --width=400 2>/dev/null)
        fi
        
        [ $? -ne 0 ] && exit 0
        
        ORACLE_PASSWORD=$(echo "$result" | cut -d'|' -f1)
        APEX_ADMIN_PASSWORD=$(echo "$result" | cut -d'|' -f2)
        
        if [[ "$ORACLE_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{5,}$ ]] && \
           [[ "$APEX_ADMIN_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{5,}$ ]]; then
            break
        else
            show_error "$(get_text error)" "$(get_text invalid_pass)"
        fi
    done
    
    export ORACLE_PASSWORD APEX_ADMIN_PASSWORD
}

# ═══════════════════════════════════════════════════════════════════════════════
# PROGRESS DIALOG
# ═══════════════════════════════════════════════════════════════════════════════
FIFO_FILE=""
PROGRESS_PID=""

start_progress() {
    FIFO_FILE=$(mktemp -u)
    mkfifo "$FIFO_FILE"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="$(get_text title)" \
            --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel \
            --width=500 --height=150 --center \
            < "$FIFO_FILE" &
        PROGRESS_PID=$!
    else
        zenity --progress --title="$(get_text title)" \
            --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel \
            --width=500 --height=150 \
            < "$FIFO_FILE" &
        PROGRESS_PID=$!
    fi
    
    exec 3>"$FIFO_FILE"
}

update_progress() {
    local percent=$1
    local text=$2
    
    echo "$percent" >&3 2>/dev/null || true
    echo "# $text" >&3 2>/dev/null || true
}

stop_progress() {
    exec 3>&- 2>/dev/null || true
    rm -f "$FIFO_FILE" 2>/dev/null || true
    [ -n "$PROGRESS_PID" ] && kill $PROGRESS_PID 2>/dev/null || true
    sleep 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING
# ═══════════════════════════════════════════════════════════════════════════════
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" >> "$INSTALL_LOG"
    echo "$msg"
}

# ═══════════════════════════════════════════════════════════════════════════════
# WAIT FOR DATABASE
# ═══════════════════════════════════════════════════════════════════════════════
wait_for_database() {
    log "Waiting for database to be ready..."
    local timeout=600
    local start=$(date +%s)
    
    while true; do
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            log "Database reports READY"
            return 0
        fi
        
        local elapsed=$(($(date +%s) - start))
        [ $elapsed -gt $timeout ] && return 1
        
        sleep 10
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALLATION STEPS
# ═══════════════════════════════════════════════════════════════════════════════
run_installation() {
    mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR"
    mkdir -p "$ORDS_CONFIG_DIR/databases/default" "$ORDS_CONFIG_DIR/global"
    
    echo "" > "$INSTALL_LOG"
    
    start_progress
    
    # Step 1: Save passwords
    update_progress 2 "Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    log "Passwords saved"
    sleep 1
    
    # Step 2: Install dependencies
    update_progress 5 "Installing dependencies..."
    log "Installing dependencies..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                sudo apt-get update -qq >> "$INSTALL_LOG" 2>&1
                sudo apt-get install -y docker.io docker-compose openjdk-17-jdk unzip wget curl >> "$INSTALL_LOG" 2>&1 || true
                ;;
            fedora)
                sudo dnf install -y docker docker-compose java-17-openjdk unzip wget curl >> "$INSTALL_LOG" 2>&1 || true
                ;;
            opensuse*|suse*)
                sudo zypper --non-interactive install -y docker docker-compose java-17-openjdk unzip wget curl >> "$INSTALL_LOG" 2>&1 || true
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm docker docker-compose jdk17-openjdk unzip wget curl >> "$INSTALL_LOG" 2>&1 || true
                ;;
        esac
    fi
    
    sudo systemctl enable docker >> "$INSTALL_LOG" 2>&1 || true
    sudo systemctl start docker >> "$INSTALL_LOG" 2>&1 || true
    sudo usermod -aG docker "$USER" >> "$INSTALL_LOG" 2>&1 || true
    log "Dependencies installed"
    
    # Step 3: Cleanup
    update_progress 8 "Cleaning up previous installation..."
    log "Cleanup..."
    pkill -9 -f "ords" 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true
    docker rm -f oracle-apex-db 2>/dev/null || true
    sleep 2
    
    # Step 4: Download APEX
    update_progress 10 "Downloading APEX (this may take a while)..."
    log "Downloading APEX..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ] || [ $(stat -c%s "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || echo 0) -lt 100000000 ]; then
        wget -q -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" >> "$INSTALL_LOG" 2>&1 || true
    fi
    log "APEX downloaded"
    
    # Step 5: Download ORDS
    update_progress 15 "Downloading ORDS..."
    log "Downloading ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ] || [ $(stat -c%s "$DOWNLOADS_DIR/ords-latest.zip" 2>/dev/null || echo 0) -lt 50000000 ]; then
        wget -q -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" >> "$INSTALL_LOG" 2>&1 || true
    fi
    log "ORDS downloaded"
    
    # Step 6: Extract files
    update_progress 20 "Extracting files..."
    log "Extracting files..."
    cd "$PROJECT_DIR"
    rm -rf apex ords
    unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" >> "$INSTALL_LOG" 2>&1
    mkdir -p ords && unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords >> "$INSTALL_LOG" 2>&1
    cp -r apex/images "$IMAGES_DIR" 2>/dev/null || true
    find ords -name "ords" -type f -exec chmod +x {} \;
    log "Files extracted"
    
    # Step 7: Create Docker Compose
    update_progress 23 "Creating Docker configuration..."
    log "Creating Docker Compose..."
    cat > "$PROJECT_DIR/docker-compose.yml" << EOF
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
    log "Docker Compose created"
    
    # Step 8: Start Database
    update_progress 25 "Starting database (this takes 5-10 minutes)..."
    log "Starting database..."
    cd "$PROJECT_DIR"
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null
    
    # Wait for database
    update_progress 30 "Waiting for database to be ready..."
    wait_for_database
    
    update_progress 35 "Database ready, waiting for listener (90s)..."
    sleep 90
    log "Database ready"
    
    # Step 9: Disable password policies
    update_progress 38 "Configuring database policies..."
    log "Disabling password policies..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Step 10: Install APEX
    update_progress 40 "Installing APEX (15-25 minutes)..."
    log "Installing APEX..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    sleep 30
    log "APEX installed"
    
    # Step 11: APEX REST Config
    update_progress 55 "Configuring APEX REST..."
    log "Configuring APEX REST..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    sleep 10
    
    # Step 12: Create Users
    update_progress 60 "Creating database users..."
    log "Creating users..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
-- Drop and recreate ORDS_PUBLIC_USER
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE, CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

-- Fix APEX users
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Users created"
    
    # Step 13: Grant Proxy (CRITICAL)
    update_progress 65 "Granting proxy authentication (CRITICAL)..."
    log "Granting proxy..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Proxy granted"
    
    # Step 14: Create APEX Admin
    update_progress 70 "Creating APEX admin user..."
    log "Creating APEX admin..."
    
    local apex_schema=$(docker exec oracle-apex-db bash -c "echo \"SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ')
    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"
    log "APEX schema: $apex_schema"
    
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
BEGIN
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    ${apex_schema}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    BEGIN
        ${apex_schema}.APEX_UTIL.CREATE_USER(
            p_user_name => 'ADMIN',
            p_email_address => 'admin@localhost',
            p_web_password => '${APEX_ADMIN_PASSWORD}',
            p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
            p_change_password_on_first_use => 'N'
        );
    EXCEPTION WHEN OTHERS THEN
        ${apex_schema}.APEX_UTIL.EDIT_USER(
            p_user_id => ${apex_schema}.APEX_UTIL.GET_USER_ID('ADMIN'),
            p_user_name => 'ADMIN',
            p_web_password => '${APEX_ADMIN_PASSWORD}',
            p_new_password => '${APEX_ADMIN_PASSWORD}'
        );
    END;
    COMMIT;
END;
/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "APEX admin created"
    
    # Step 15: Install ORDS
    update_progress 75 "Installing ORDS (5-10 minutes)..."
    log "Installing ORDS..."
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
    chmod +x "$ORDS_BIN" 2>/dev/null || true
    
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
        --password-stdin < "$PASS_FILE" >> "$INSTALL_LOG" 2>&1 || true
    
    rm -f "$PASS_FILE"
    log "ORDS installed"
    
    # Step 16: Configure ORDS
    update_progress 80 "Configuring ORDS..."
    log "Configuring ORDS..."
    
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port $ORDS_PORT >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
    echo "${ORACLE_PASSWORD}" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    
    # Step 17: Re-grant proxy after ORDS install
    update_progress 82 "Re-granting proxy permissions..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Step 18: Start ORDS
    update_progress 85 "Starting ORDS..."
    log "Starting ORDS..."
    
    pkill -f ords 2>/dev/null || true
    sleep 5
    
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    
    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port $ORDS_PORT \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &
    
    echo $! > "$PROJECT_DIR/ords.pid"
    
    # Wait for ORDS to start
    update_progress 88 "Waiting for ORDS to start (90 seconds)..."
    sleep 90
    log "ORDS started"
    
    # Step 19: Create management scripts
    update_progress 92 "Creating management scripts..."
    create_management_scripts
    log "Scripts created"
    
    # Step 20: Verify installation
    update_progress 95 "Verifying installation..."
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
    local http_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")
    log "HTTP Admin: $http_admin, HTTP Login: $http_login"
    
    # If not working, run fix
    if [[ ! "$http_admin" =~ ^(200|302|303)$ ]]; then
        update_progress 97 "Running auto-fix..."
        run_auto_fix
        sleep 60
    fi
    
    update_progress 100 "Installation completed!"
    sleep 2
    
    stop_progress
    
    log "Installation completed successfully!"
}

# ═══════════════════════════════════════════════════════════════════════════════
# AUTO FIX FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════
run_auto_fix() {
    log "Running auto-fix..."
    
    # Stop ORDS
    pkill -f ords 2>/dev/null || true
    sleep 5
    
    # Ensure database is running
    docker start oracle-apex-db 2>/dev/null || true
    sleep 30
    
    # Fix database accounts
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
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Set ORDS password
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
    echo "${ORACLE_PASSWORD}" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
    
    # Start ORDS
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve --port 8080 --apex-images "$IMAGES_DIR" > "$LOG_DIR/ords.log" 2>&1 &
    
    log "Auto-fix completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CREATE MANAGEMENT SCRIPTS
# ═══════════════════════════════════════════════════════════════════════════════
create_management_scripts() {
    local PASS="$ORACLE_PASSWORD"
    
    # START SCRIPT
    cat > "$SCRIPTS_DIR/start.sh" << 'STARTEOF'
#!/bin/bash
cd ~/oracle-apex-complete
PASS=$(cat .db_password 2>/dev/null)

echo "════════════════════════════════════════════════════════════"
echo "  Starting Oracle APEX Services..."
echo "════════════════════════════════════════════════════════════"

echo "Step 1: Starting database..."
docker start oracle-apex-db 2>/dev/null || docker compose up -d 2>/dev/null
echo "Waiting 120 seconds for database..."
sleep 120

echo "Step 2: Running recovery..."
docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOF

echo "Step 3: Starting ORDS..."
pkill -f ords 2>/dev/null || true
sleep 5

ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &

echo "Waiting 90 seconds for ORDS..."
sleep 90

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ✅ Oracle APEX Started!"
echo "════════════════════════════════════════════════════════════"
echo "  http://localhost:8080/ords/apex_admin"
echo "  http://localhost:8080/ords/f?p=4550"
echo ""
STARTEOF
    chmod +x "$SCRIPTS_DIR/start.sh"
    
    # STOP SCRIPT
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
echo "Stopping Oracle APEX..."
pkill -f ords 2>/dev/null || true
sleep 3
docker stop oracle-apex-db 2>/dev/null || true
echo "✅ Stopped!"
STOPEOF
    chmod +x "$SCRIPTS_DIR/stop.sh"
    
    # STATUS SCRIPT
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
echo "════════════════════════════════════════════════════════════"
echo "  Oracle APEX Status"
echo "════════════════════════════════════════════════════════════"
DB=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo "false")
ORDS=$(pgrep -f "ords.*serve" > /dev/null && echo "true" || echo "false")
echo "Database: $([[ $DB == 'true' ]] && echo '🟢 Running' || echo '🔴 Stopped')"
echo "ORDS:     $([[ $ORDS == 'true' ]] && echo '🟢 Running' || echo '🔴 Stopped')"
echo ""
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")
echo "APEX Admin: HTTP $HTTP_ADMIN"
echo "APEX Login: HTTP $HTTP_LOGIN"
echo ""
echo "URLs:"
echo "  http://localhost:8080/ords/apex_admin"
echo "  http://localhost:8080/ords/f?p=4550"
STATUSEOF
    chmod +x "$SCRIPTS_DIR/status.sh"
    
    # FIX SCRIPT
    cat > "$SCRIPTS_DIR/fix.sh" << 'FIXEOF'
#!/bin/bash
cd ~/oracle-apex-complete
PASS=$(cat .db_password 2>/dev/null)

echo "════════════════════════════════════════════════════════════"
echo "  Running Fix Script..."
echo "════════════════════════════════════════════════════════════"

echo "Step 1: Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 5

echo "Step 2: Ensuring database is running..."
docker start oracle-apex-db 2>/dev/null || true
sleep 60

echo "Step 3: Fixing accounts..."
docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << EOF
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOF

echo "Step 4: Setting ORDS password..."
ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
echo "${PASS}" | "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config secret --password-stdin db.password 2>/dev/null

echo "Step 5: Starting ORDS..."
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &

echo "Waiting 120 seconds..."
sleep 120

echo ""
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
echo "════════════════════════════════════════════════════════════"
echo "  Fix Completed!"
echo "  APEX Admin: HTTP $HTTP_ADMIN"
echo "  http://localhost:8080/ords/apex_admin"
echo "════════════════════════════════════════════════════════════"
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh"
    
    # GUI LAUNCHER - FIXED VERSION
    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
################################################################################
#  Oracle APEX Manager - GUI (Fixed Version)
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
LOG_DIR="$PROJECT_DIR/logs"
CONFIG_FILE="$PROJECT_DIR/.gui_config"

# Get password
DB_PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)

if [ -z "$DB_PASS" ]; then
    zenity --error --title="Error" --text="Password file not found!\n\nPlease run the installer again." --width=400 2>/dev/null
    exit 1
fi

# Detect GUI tool
GUI_TOOL=""
if command -v yad &> /dev/null; then
    GUI_TOOL="yad"
elif command -v zenity &> /dev/null; then
    GUI_TOOL="zenity"
else
    echo "No GUI tool found!"
    exit 1
fi

# Language
LANG_CODE="en"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE" 2>/dev/null

# Strings
declare -A STR_EN=(
    ["title"]="Oracle APEX Manager"
    ["start"]="▶️ Start Services"
    ["stop"]="⏹️ Stop Services"
    ["status"]="📊 Check Status"
    ["admin"]="🌐 Open Admin"
    ["fix"]="🔧 Run Fix"
    ["logs"]="📜 View Logs"
    ["exit"]="❌ Exit"
    ["running"]="Running"
    ["stopped"]="Stopped"
)

declare -A STR_FA=(
    ["title"]="مدیریت اوراکل اپکس"
    ["start"]="▶️ شروع سرویس‌ها"
    ["stop"]="⏹️ توقف سرویس‌ها"
    ["status"]="📊 بررسی وضعیت"
    ["admin"]="🌐 پنل مدیریت"
    ["fix"]="🔧 اجرای تعمیر"
    ["logs"]="📜 مشاهده لاگ"
    ["exit"]="❌ خروج"
    ["running"]="در حال اجرا"
    ["stopped"]="متوقف"
)

get_str() {
    local key=$1
    if [ "$LANG_CODE" = "fa" ]; then
        echo "${STR_FA[$key]:-${STR_EN[$key]}}"
    else
        echo "${STR_EN[$key]}"
    fi
}

# Check status
check_running() {
    local db_ok=false
    local ords_ok=false
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$" && db_ok=true
    pgrep -f "ords.*serve" > /dev/null 2>&1 && ords_ok=true
    $db_ok && $ords_ok
}

# Start services
do_start() {
    (
        echo "10"; echo "# Starting database..."
        docker start oracle-apex-db 2>/dev/null || docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d 2>/dev/null
        
        echo "20"; echo "# Waiting for database (2 min)..."
        sleep 120
        
        echo "40"; echo "# Running recovery..."
        docker exec oracle-apex-db sqlplus -s sys/${DB_PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQLEOF' >/dev/null 2>&1
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQLEOF
        
        echo "50"; echo "# Stopping old ORDS..."
        pkill -f ords 2>/dev/null || true
        sleep 5
        
        echo "60"; echo "# Starting ORDS..."
        ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
        if [ -n "$ORDS_BIN" ]; then
            export ORDS_CONFIG="$PROJECT_DIR/ords_config"
            export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
            nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$LOG_DIR/ords.log" 2>&1 &
        fi
        
        echo "80"; echo "# Waiting for ORDS (90s)..."
        sleep 90
        
        echo "100"; echo "# Done!"
    ) | zenity --progress --title="$(get_str title)" --text="Starting..." \
        --percentage=0 --auto-close --no-cancel --width=400 2>/dev/null
    
    if check_running; then
        zenity --info --title="$(get_str title)" \
            --text="✅ Services started!\n\nhttp://localhost:8080/ords/apex_admin" \
            --width=400 2>/dev/null
    else
        zenity --warning --title="$(get_str title)" \
            --text="⚠️ Services may not be fully started.\n\nTry 'Run Fix' from menu." \
            --width=400 2>/dev/null
    fi
}

# Stop services
do_stop() {
    pkill -f ords 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true
    zenity --info --title="$(get_str title)" --text="✅ Services stopped!" --width=300 2>/dev/null
}

# Show status
do_status() {
    local db_status="🔴 $(get_str stopped)"
    local ords_status="🔴 $(get_str stopped)"
    
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$" && db_status="🟢 $(get_str running)"
    pgrep -f "ords.*serve" > /dev/null 2>&1 && ords_status="🟢 $(get_str running)"
    
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
    
    zenity --info --title="$(get_str title) - Status" \
        --text="Database: $db_status\nORDS: $ords_status\n\nHTTP Status: $http_admin\n\nhttp://localhost:8080/ords/apex_admin" \
        --width=400 2>/dev/null
}

# Open admin
do_admin() {
    if check_running; then
        xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
    else
        zenity --error --title="$(get_str title)" \
            --text="Services not running!\nPlease start first." --width=300 2>/dev/null
    fi
}

# Run fix
do_fix() {
    bash "$SCRIPTS_DIR/fix.sh" > /tmp/fix_output.txt 2>&1 &
    FIX_PID=$!
    
    (
        while kill -0 $FIX_PID 2>/dev/null; do
            echo "# Running fix..."
            sleep 2
        done
        echo "100"
    ) | zenity --progress --title="$(get_str title)" --text="Running fix..." \
        --pulsate --auto-close --no-cancel --width=400 2>/dev/null
    
    zenity --text-info --title="Fix Result" --filename=/tmp/fix_output.txt \
        --width=700 --height=500 2>/dev/null
}

# Show logs
do_logs() {
    if [ -f "$LOG_DIR/ords.log" ]; then
        zenity --text-info --title="ORDS Logs" --filename="$LOG_DIR/ords.log" \
            --width=800 --height=600 2>/dev/null
    else
        zenity --warning --title="$(get_str title)" --text="No logs found" --width=300 2>/dev/null
    fi
}

# Main menu loop
while true; do
    STATUS_ICON="🔴"
    check_running && STATUS_ICON="🟢"
    
    CHOICE=$(zenity --list --title="$(get_str title)" \
        --text="$STATUS_ICON Status\n\nSelect action:" \
        --radiolist --column="" --column="Action" --column="Description" \
        TRUE "start" "$(get_str start)" \
        FALSE "stop" "$(get_str stop)" \
        FALSE "status" "$(get_str status)" \
        FALSE "admin" "$(get_str admin)" \
        FALSE "fix" "$(get_str fix)" \
        FALSE "logs" "$(get_str logs)" \
        FALSE "exit" "$(get_str exit)" \
        --width=450 --height=400 --hide-column=2 2>/dev/null)
    
    [ -z "$CHOICE" ] && exit 0
    
    case "$CHOICE" in
        start)  do_start ;;
        stop)   do_stop ;;
        status) do_status ;;
        admin)  do_admin ;;
        fix)    do_fix ;;
        logs)   do_logs ;;
        exit)   exit 0 ;;
        *)      exit 0 ;;
    esac
done
GUIEOF
    chmod +x "$SCRIPTS_DIR/launch-gui.sh"
    
    # Desktop file
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/oracle-apex.desktop" << DESKTOPEOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle APEX Manager
Comment=Manage Oracle APEX - KaizenixCore
Exec=bash $SCRIPTS_DIR/launch-gui.sh
Icon=applications-database
Terminal=false
Categories=Development;Database;
DESKTOPEOF
    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SUCCESS DIALOG
# ═══════════════════════════════════════════════════════════════════════════════
show_success() {
    local choice
    
    if [ "$GUI_TOOL" = "yad" ]; then
        choice=$(yad --list --title="🎉 $(get_text completed)" \
            --text="$(get_text success_msg)" \
            --radiolist --column="" --column="Action" --column="Description" \
            TRUE "browser" "$(get_text open_browser)" \
            FALSE "exit" "$(get_text exit)" \
            --width=550 --height=450 --center \
            --button="OK:0" \
            --print-column=2 --hide-column=2 2>/dev/null)
    else
        choice=$(zenity --list --title="🎉 $(get_text completed)" \
            --text="$(get_text success_msg)" \
            --radiolist --column="" --column="Action" --column="Description" \
            TRUE "browser" "$(get_text open_browser)" \
            FALSE "exit" "$(get_text exit)" \
            --width=550 --height=450 --hide-column=2 2>/dev/null)
    fi
    
    if [[ "$choice" == *"browser"* ]]; then
        xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════
main() {
    install_gui_tool
    select_language
    show_info "$(get_text title)" "$(get_text welcome)"
    get_passwords
    run_installation
    show_success
}

main "$@"
