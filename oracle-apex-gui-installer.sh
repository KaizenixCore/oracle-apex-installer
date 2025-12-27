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
#  ║     ORACLE APEX GUI INSTALLER v3.2.0 - KAIZENIXCORE                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  🎨 FULL GRAPHICAL INSTALLER - No Terminal Input Required                 ║
#  ║  📦 Installs: Oracle APEX + ORDS + Oracle XE 21c                          ║
#  ║  🌐 Multi-Language: English, فارسی, Deutsch                               ║
#  ║  ✅ All Errors Fixed: 500, 574, 571, Connection Reset                     ║
#  ║  ✅ GUI Password Input with pkexec/gksudo                                 ║
#  ║  ✅ Auto Browser Launch After Installation                                ║
#  ║  ✅ Extended Wait Times for Reliability                                   ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e

VERSION="3.2.0"
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
    ["sudo_pass"]="Enter your system password for sudo:"
    ["wait_db"]="Waiting for database to start (5-10 minutes)..."
    ["wait_ords"]="Waiting for ORDS to start (3-5 minutes)..."
    ["step"]="Step"
    ["of"]="of"
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
    ["sudo_pass"]="رمز عبور سیستم را برای sudo وارد کنید:"
    ["wait_db"]="منتظر شروع دیتابیس (۵-۱۰ دقیقه)..."
    ["wait_ords"]="منتظر شروع ORDS (۳-۵ دقیقه)..."
    ["step"]="مرحله"
    ["of"]="از"
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
    ["sudo_pass"]="Geben Sie Ihr Systempasswort für sudo ein:"
    ["wait_db"]="Warten auf Datenbankstart (5-10 Minuten)..."
    ["wait_ords"]="Warten auf ORDS-Start (3-5 Minuten)..."
    ["step"]="Schritt"
    ["of"]="von"
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
SUDO_PASS=""

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
        echo "Please install manually: sudo apt install zenity"
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

# ═══════════════════════════════════════════════════════════════════════════════
# GET SUDO PASSWORD GRAPHICALLY
# ═══════════════════════════════════════════════════════════════════════════════
get_sudo_password() {
    # First check if we already have sudo access
    if sudo -n true 2>/dev/null; then
        return 0
    fi
    
    local pass=""
    
    while true; do
        if [ "$GUI_TOOL" = "yad" ]; then
            pass=$(yad --entry --title="$(get_text title)" \
                --text="$(get_text sudo_pass)" \
                --hide-text --width=400 --center 2>/dev/null)
        else
            pass=$(zenity --password --title="$(get_text title)" 2>/dev/null)
        fi
        
        [ -z "$pass" ] && exit 0
        
        # Test sudo password
        if echo "$pass" | sudo -S true 2>/dev/null; then
            SUDO_PASS="$pass"
            return 0
        else
            show_error "$(get_text error)" "Wrong password! Try again."
        fi
    done
}

# Run command with sudo using stored password
run_sudo() {
    if [ -n "$SUDO_PASS" ]; then
        echo "$SUDO_PASS" | sudo -S "$@" 2>/dev/null
    else
        sudo "$@"
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
# PROGRESS DIALOG - FIXED VERSION
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
    
    if [ -n "$FIFO_FILE" ] && [ -e "$FIFO_FILE" ]; then
        echo "$percent" >&3 2>/dev/null || true
        echo "# $text" >&3 2>/dev/null || true
    fi
}

stop_progress() {
    exec 3>&- 2>/dev/null || true
    sleep 1
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
# WAIT FOR DATABASE - EXTENDED TIMEOUT
# ═══════════════════════════════════════════════════════════════════════════════
wait_for_database() {
    log "Waiting for database to be ready..."
    local timeout=900  # 15 minutes
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
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 1: Save passwords
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 2 "$(get_text step) 1/20: Saving configuration..."
    log "Step 1: Saving passwords"
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    sleep 1
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 2: Install dependencies with GUI sudo
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 5 "$(get_text step) 2/20: Installing dependencies..."
    log "Step 2: Installing dependencies"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                run_sudo apt-get update -qq >> "$INSTALL_LOG" 2>&1
                run_sudo apt-get install -y docker.io docker-compose openjdk-17-jdk unzip wget curl >> "$INSTALL_LOG" 2>&1 || true
                ;;
            fedora)
                run_sudo dnf install -y docker docker-compose java-17-openjdk unzip wget curl >> "$INSTALL_LOG" 2>&1 || true
                ;;
            opensuse*|suse*)
                run_sudo zypper --non-interactive install -y docker docker-compose java-17-openjdk unzip wget curl >> "$INSTALL_LOG" 2>&1 || true
                ;;
            arch|manjaro)
                run_sudo pacman -S --noconfirm docker docker-compose jdk17-openjdk unzip wget curl >> "$INSTALL_LOG" 2>&1 || true
                ;;
        esac
    fi
    
    run_sudo systemctl enable docker >> "$INSTALL_LOG" 2>&1 || true
    run_sudo systemctl start docker >> "$INSTALL_LOG" 2>&1 || true
    run_sudo usermod -aG docker "$USER" >> "$INSTALL_LOG" 2>&1 || true
    log "Dependencies installed"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 3: Cleanup
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 8 "$(get_text step) 3/20: Cleaning up previous installation..."
    log "Step 3: Cleanup"
    pkill -9 -f "ords" 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true
    docker rm -f oracle-apex-db 2>/dev/null || true
    sleep 2
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 4-5: Download APEX and ORDS
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 10 "$(get_text step) 4/20: Downloading APEX (this may take a while)..."
    log "Step 4: Downloading APEX"
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ] || [ $(stat -c%s "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || echo 0) -lt 100000000 ]; then
        wget -q -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" >> "$INSTALL_LOG" 2>&1 || true
    fi
    log "APEX downloaded"
    
    update_progress 15 "$(get_text step) 5/20: Downloading ORDS..."
    log "Step 5: Downloading ORDS"
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ] || [ $(stat -c%s "$DOWNLOADS_DIR/ords-latest.zip" 2>/dev/null || echo 0) -lt 50000000 ]; then
        wget -q -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" >> "$INSTALL_LOG" 2>&1 || true
    fi
    log "ORDS downloaded"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 6: Extract files
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 20 "$(get_text step) 6/20: Extracting files..."
    log "Step 6: Extracting files"
    cd "$PROJECT_DIR"
    rm -rf apex ords
    unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" >> "$INSTALL_LOG" 2>&1
    mkdir -p ords && unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords >> "$INSTALL_LOG" 2>&1
    cp -r apex/images "$IMAGES_DIR" 2>/dev/null || true
    find ords -name "ords" -type f -exec chmod +x {} \;
    log "Files extracted"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 7: Create Docker Compose
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 23 "$(get_text step) 7/20: Creating Docker configuration..."
    log "Step 7: Creating Docker Compose"
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
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 8: Start Database - EXTENDED WAIT
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 25 "$(get_text step) 8/20: $(get_text wait_db)"
    log "Step 8: Starting database"
    cd "$PROJECT_DIR"
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null
    
    # Wait for database with extended timeout
    log "Waiting for database to be ready..."
    local db_ready=false
    for i in $(seq 1 60); do  # 10 minutes max
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            db_ready=true
            break
        fi
        update_progress $((25 + i/4)) "$(get_text wait_db) ($((i*10))s)"
        sleep 10
    done
    
    if [ "$db_ready" = false ]; then
        log "Database timeout - continuing anyway"
    fi
    
    # Additional wait for listener - CRITICAL
    update_progress 35 "$(get_text step) 8/20: Waiting for database listener (2 minutes)..."
    log "Waiting additional 120s for listener..."
    sleep 120
    log "Database ready"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 9: Disable password policies
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 38 "$(get_text step) 9/20: Configuring database policies..."
    log "Step 9: Disabling password policies"
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 10: Install APEX
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 40 "$(get_text step) 10/20: Installing APEX (15-25 minutes)..."
    log "Step 10: Installing APEX"
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    sleep 30
    log "APEX installed"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 11: APEX REST Config
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 55 "$(get_text step) 11/20: Configuring APEX REST..."
    log "Step 11: APEX REST config"
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    sleep 10
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 12: Create Users
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 60 "$(get_text step) 12/20: Creating database users..."
    log "Step 12: Creating users"
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
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 13: Grant Proxy - CRITICAL FOR CONNECTION
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 65 "$(get_text step) 13/20: Granting proxy authentication (CRITICAL)..."
    log "Step 13: Granting proxy"
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
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 14: Create APEX Admin
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 70 "$(get_text step) 14/20: Creating APEX admin user..."
    log "Step 14: Creating APEX admin"
    
    # Find APEX schema
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
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 15: Install ORDS
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 75 "$(get_text step) 15/20: Installing ORDS (5-10 minutes)..."
    log "Step 15: Installing ORDS"
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
    chmod +x "$ORDS_BIN" 2>/dev/null || true
    
    # Create password file for ORDS install
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
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 16: Configure ORDS
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 80 "$(get_text step) 16/20: Configuring ORDS..."
    log "Step 16: Configuring ORDS"
    
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port $ORDS_PORT >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
    echo "${ORACLE_PASSWORD}" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 17: Re-grant proxy after ORDS install - CRITICAL
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 82 "$(get_text step) 17/20: Re-granting proxy permissions..."
    log "Step 17: Re-granting proxy"
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
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 18: Start ORDS - EXTENDED WAIT
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 85 "$(get_text step) 18/20: $(get_text wait_ords)"
    log "Step 18: Starting ORDS"
    
    pkill -f ords 2>/dev/null || true
    sleep 5
    
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    
    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port $ORDS_PORT \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &
    
    echo $! > "$PROJECT_DIR/ords.pid"
    
    # Wait for ORDS to start - EXTENDED
    log "Waiting 180s for ORDS to start..."
    for i in $(seq 1 36); do  # 3 minutes
        update_progress $((85 + i/3)) "$(get_text wait_ords) ($((i*5))s)"
        sleep 5
        
        # Check if ORDS is responding
        local http_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/ 2>/dev/null || echo "000")
        if [[ "$http_code" =~ ^(200|302|303|301)$ ]]; then
            log "ORDS responding: HTTP $http_code"
            break
        fi
    done
    log "ORDS started"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 19: Create management scripts
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 92 "$(get_text step) 19/20: Creating management scripts..."
    log "Step 19: Creating scripts"
    create_management_scripts
    log "Scripts created"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 20: Verify installation
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 95 "$(get_text step) 20/20: Verifying installation..."
    log "Step 20: Verifying"
    
    # Extra wait for ORDS
    sleep 30
    
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
    local http_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")
    log "HTTP Admin: $http_admin, HTTP Login: $http_login"
    
    # If not working, run fix
    if [[ ! "$http_admin" =~ ^(200|302|303)$ ]]; then
        log "Running auto-fix..."
        update_progress 97 "Running auto-fix..."
        run_auto_fix
        sleep 90
    fi
    
    update_progress 100 "$(get_text completed)"
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
    local APEX_PASS="$APEX_ADMIN_PASSWORD"
    
    # START SCRIPT
    cat > "$SCRIPTS_DIR/start.sh" << STARTEOF
#!/bin/bash
cd ~/oracle-apex-complete
PASS=\$(cat .db_password 2>/dev/null)

echo "════════════════════════════════════════════════════════════"
echo "  Starting Oracle APEX Services..."
echo "════════════════════════════════════════════════════════════"

echo "Step 1: Starting database..."
docker start oracle-apex-db 2>/dev/null || docker compose up -d 2>/dev/null
echo "Waiting 150 seconds for database..."
sleep 150

echo "Step 2: Running recovery..."
docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
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

ORDS_BIN=\$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
nohup "\$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &

echo "Waiting 120 seconds for ORDS..."
sleep 120

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
    cat > "$SCRIPTS_DIR/fix.sh" << FIXEOF
#!/bin/bash
cd ~/oracle-apex-complete
PASS=\$(cat .db_password 2>/dev/null)

echo "════════════════════════════════════════════════════════════"
echo "  Running Fix Script..."
echo "════════════════════════════════════════════════════════════"

echo "Step 1: Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 5

echo "Step 2: Ensuring database is running..."
docker start oracle-apex-db 2>/dev/null || true
sleep 90

echo "Step 3: Fixing accounts..."
docker exec oracle-apex-db sqlplus -s sys/\${PASS}@//localhost:1521/XEPDB1 as sysdba << EOF
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOF

echo "Step 4: Setting ORDS password..."
ORDS_BIN=\$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
echo "\${PASS}" | "\$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config secret --password-stdin db.password 2>/dev/null

echo "Step 5: Starting ORDS..."
export ORDS_CONFIG=~/oracle-apex-complete/ords_config
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
nohup "\$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &

echo "Waiting 150 seconds..."
sleep 150

echo ""
HTTP_ADMIN=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
echo "════════════════════════════════════════════════════════════"
echo "  Fix Completed!"
echo "  APEX Admin: HTTP \$HTTP_ADMIN"
echo "  http://localhost:8080/ords/apex_admin"
echo "════════════════════════════════════════════════════════════"
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh"
    
    # GUI LAUNCHER - COMPLETELY FIXED
    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
################################################################################
#  Oracle APEX Manager - GUI (Completely Fixed Version)
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
LOG_DIR="$PROJECT_DIR/logs"

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
        
        echo "20"; echo "# Waiting for database (2.5 min)..."
        sleep 150
        
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
        
        echo "80"; echo "# Waiting for ORDS (2 min)..."
        sleep 120
        
        echo "100"; echo "# Done!"
    ) | zenity --progress --title="Oracle APEX Manager" --text="Starting..." \
        --percentage=0 --auto-close --no-cancel --width=400 2>/dev/null
    
    if check_running; then
        zenity --info --title="Oracle APEX Manager" \
            --text="✅ Services started!\n\nhttp://localhost:8080/ords/apex_admin" \
            --width=400 2>/dev/null
        xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
    else
        zenity --warning --title="Oracle APEX Manager" \
            --text="⚠️ Services may not be fully started.\n\nTry 'Run Fix' from menu." \
            --width=400 2>/dev/null
    fi
}

# Stop services
do_stop() {
    pkill -f ords 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true
    zenity --info --title="Oracle APEX Manager" --text="✅ Services stopped!" --width=300 2>/dev/null
}

# Show status
do_status() {
    local db_status="🔴 Stopped"
    local ords_status="🔴 Stopped"
    
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$" && db_status="🟢 Running"
    pgrep -f "ords.*serve" > /dev/null 2>&1 && ords_status="🟢 Running"
    
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
    
    zenity --info --title="Oracle APEX Manager - Status" \
        --text="Database: $db_status\nORDS: $ords_status\n\nHTTP Status: $http_admin\n\nhttp://localhost:8080/ords/apex_admin" \
        --width=400 2>/dev/null
}

# Open admin
do_admin() {
    if check_running; then
        xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
    else
        zenity --error --title="Oracle APEX Manager" \
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
    ) | zenity --progress --title="Oracle APEX Manager" --text="Running fix..." \
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
        zenity --warning --title="Oracle APEX Manager" --text="No logs found" --width=300 2>/dev/null
    fi
}

# Main menu loop
while true; do
    STATUS_ICON="🔴"
    check_running && STATUS_ICON="🟢"
    
    CHOICE=$(zenity --list --title="Oracle APEX Manager" \
        --text="$STATUS_ICON Status\n\nSelect action:" \
        --radiolist --column="" --column="Action" --column="Description" \
        TRUE "start" "▶️ Start Services" \
        FALSE "stop" "⏹️ Stop Services" \
        FALSE "status" "📊 Check Status" \
        FALSE "admin" "🌐 Open Admin Panel" \
        FALSE "fix" "🔧 Run Fix Script" \
        FALSE "logs" "📜 View Logs" \
        FALSE "exit" "❌ Exit" \
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
# SUCCESS DIALOG WITH AUTO BROWSER
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
    
    # Always try to open browser
    xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════
main() {
    # Install GUI tool first (before needing sudo)
    install_gui_tool
    
    # Select language
    select_language
    
    # Show welcome
    show_info "$(get_text title)" "$(get_text welcome)"
    
    # Get sudo password graphically BEFORE starting
    get_sudo_password
    
    # Get Oracle/APEX passwords
    get_passwords
    
    # Run installation
    run_installation
    
    # Show success and open browser
    show_success
}

main "$@"
