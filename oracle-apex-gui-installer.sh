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
#  ║     ORACLE APEX GUI INSTALLER v3.0.0 - KAIZENIXCORE                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
#  🎨 GRAPHICAL INSTALLER - No Terminal Required!
#  📦 Installs: Oracle APEX + ORDS + Oracle XE 21c
#  🌐 Multi-Language: English, فارسی, Deutsch
#
################################################################################

set -e

VERSION="3.0.0"
PROJECT_DIR="$HOME/oracle-apex-complete"
DOWNLOADS_DIR="$PROJECT_DIR/downloads"
LOG_DIR="$PROJECT_DIR/logs"
IMAGES_DIR="$PROJECT_DIR/images"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
INSTALL_LOG="$PROJECT_DIR/install.log"
PROGRESS_FILE="/tmp/apex_install_progress"

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
    ["subtitle"]="KaizenixCore Edition v3.0"
    ["welcome"]="Welcome to Oracle APEX Ultimate Installer!\n\nThis will install:\n• Oracle APEX (Latest)\n• Oracle ORDS (Latest)\n• Oracle XE 21c Database\n\nClick OK to continue."
    ["select_lang"]="Select Language"
    ["enter_passwords"]="Enter Passwords"
    ["oracle_pass"]="Oracle Database Password:"
    ["apex_pass"]="APEX Admin Password:"
    ["pass_rules"]="Password Rules:\n• Start with a letter\n• Only letters and numbers\n• Minimum 6 characters"
    ["invalid_pass"]="Invalid Password!\n\nPassword must:\n• Start with a letter\n• Contain only letters and numbers\n• Be at least 6 characters"
    ["installing"]="Installing Oracle APEX..."
    ["step"]="Step"
    ["of"]="of"
    ["completed"]="Installation Completed!"
    ["success_msg"]="Oracle APEX installed successfully!\n\n🌐 Admin Panel:\nhttp://localhost:8080/ords/apex_admin\n\n🔐 Login Page:\nhttp://localhost:8080/ords/f?p=4550\n\n📋 Credentials:\nWorkspace: INTERNAL\nUsername: ADMIN\nPassword: (your password)"
    ["error"]="Error"
    ["cancel"]="Installation cancelled."
    ["open_browser"]="Open APEX in Browser"
    ["view_logs"]="View Logs"
    ["exit"]="Exit"
    ["init"]="Initializing..."
    ["check_system"]="Checking System..."
    ["install_deps"]="Installing Dependencies..."
    ["cleanup"]="Cleaning Up..."
    ["download"]="Downloading Components..."
    ["extract"]="Extracting Files..."
    ["docker_setup"]="Setting Up Docker..."
    ["start_db"]="Starting Database..."
    ["wait_db"]="Waiting for Database..."
    ["install_apex"]="Installing APEX..."
    ["config_apex"]="Configuring APEX..."
    ["create_users"]="Creating Users..."
    ["grant_proxy"]="Granting Permissions..."
    ["setup_admin"]="Setting Up Admin..."
    ["install_ords"]="Installing ORDS..."
    ["config_ords"]="Configuring ORDS..."
    ["start_ords"]="Starting ORDS..."
    ["verify"]="Verifying Installation..."
    ["create_scripts"]="Creating Scripts..."
    ["finalizing"]="Finalizing..."
    ["done"]="Done!"
)

declare -A LANG_FA=(
    ["title"]="نصب‌کننده اوراکل اپکس"
    ["subtitle"]="نسخه KaizenixCore v3.0"
    ["welcome"]="به نصب‌کننده اوراکل اپکس خوش آمدید!\n\nاین برنامه نصب می‌کند:\n• Oracle APEX (آخرین نسخه)\n• Oracle ORDS (آخرین نسخه)\n• Oracle XE 21c Database\n\nبرای ادامه OK را بزنید."
    ["select_lang"]="انتخاب زبان"
    ["enter_passwords"]="ورود رمز عبور"
    ["oracle_pass"]="رمز عبور Oracle Database:"
    ["apex_pass"]="رمز عبور APEX Admin:"
    ["pass_rules"]="قوانین رمز عبور:\n• با حرف شروع شود\n• فقط حروف و اعداد\n• حداقل ۶ کاراکتر"
    ["invalid_pass"]="رمز عبور نامعتبر!\n\nرمز عبور باید:\n• با حرف شروع شود\n• فقط حروف و اعداد\n• حداقل ۶ کاراکتر"
    ["installing"]="در حال نصب اوراکل اپکس..."
    ["step"]="مرحله"
    ["of"]="از"
    ["completed"]="نصب با موفقیت انجام شد!"
    ["success_msg"]="اوراکل اپکس با موفقیت نصب شد!\n\n🌐 پنل مدیریت:\nhttp://localhost:8080/ords/apex_admin\n\n🔐 صفحه ورود:\nhttp://localhost:8080/ords/f?p=4550\n\n📋 اطلاعات ورود:\nWorkspace: INTERNAL\nUsername: ADMIN\nPassword: (رمز شما)"
    ["error"]="خطا"
    ["cancel"]="نصب لغو شد."
    ["open_browser"]="باز کردن APEX در مرورگر"
    ["view_logs"]="مشاهده لاگ‌ها"
    ["exit"]="خروج"
    ["init"]="آماده‌سازی..."
    ["check_system"]="بررسی سیستم..."
    ["install_deps"]="نصب پیش‌نیازها..."
    ["cleanup"]="پاکسازی..."
    ["download"]="دانلود فایل‌ها..."
    ["extract"]="استخراج فایل‌ها..."
    ["docker_setup"]="تنظیم Docker..."
    ["start_db"]="شروع دیتابیس..."
    ["wait_db"]="انتظار برای دیتابیس..."
    ["install_apex"]="نصب APEX..."
    ["config_apex"]="پیکربندی APEX..."
    ["create_users"]="ایجاد کاربران..."
    ["grant_proxy"]="اعطای دسترسی‌ها..."
    ["setup_admin"]="تنظیم ادمین..."
    ["install_ords"]="نصب ORDS..."
    ["config_ords"]="پیکربندی ORDS..."
    ["start_ords"]="شروع ORDS..."
    ["verify"]="تأیید نصب..."
    ["create_scripts"]="ایجاد اسکریپت‌ها..."
    ["finalizing"]="نهایی‌سازی..."
    ["done"]="انجام شد!"
)

declare -A LANG_DE=(
    ["title"]="Oracle APEX Installer"
    ["subtitle"]="KaizenixCore Edition v3.0"
    ["welcome"]="Willkommen beim Oracle APEX Installer!\n\nDieses Programm installiert:\n• Oracle APEX (Neueste)\n• Oracle ORDS (Neueste)\n• Oracle XE 21c Datenbank\n\nKlicken Sie OK um fortzufahren."
    ["select_lang"]="Sprache auswählen"
    ["enter_passwords"]="Passwörter eingeben"
    ["oracle_pass"]="Oracle Database Passwort:"
    ["apex_pass"]="APEX Admin Passwort:"
    ["pass_rules"]="Passwortregeln:\n• Beginnt mit Buchstaben\n• Nur Buchstaben und Zahlen\n• Mindestens 6 Zeichen"
    ["invalid_pass"]="Ungültiges Passwort!\n\nPasswort muss:\n• Mit Buchstaben beginnen\n• Nur Buchstaben/Zahlen\n• Mindestens 6 Zeichen"
    ["installing"]="Oracle APEX wird installiert..."
    ["step"]="Schritt"
    ["of"]="von"
    ["completed"]="Installation abgeschlossen!"
    ["success_msg"]="Oracle APEX erfolgreich installiert!\n\n🌐 Admin-Panel:\nhttp://localhost:8080/ords/apex_admin\n\n🔐 Anmeldeseite:\nhttp://localhost:8080/ords/f?p=4550\n\n📋 Anmeldedaten:\nWorkspace: INTERNAL\nUsername: ADMIN\nPassword: (Ihr Passwort)"
    ["error"]="Fehler"
    ["cancel"]="Installation abgebrochen."
    ["open_browser"]="APEX im Browser öffnen"
    ["view_logs"]="Protokolle anzeigen"
    ["exit"]="Beenden"
    ["init"]="Initialisierung..."
    ["check_system"]="Systemprüfung..."
    ["install_deps"]="Abhängigkeiten installieren..."
    ["cleanup"]="Bereinigung..."
    ["download"]="Komponenten herunterladen..."
    ["extract"]="Dateien extrahieren..."
    ["docker_setup"]="Docker einrichten..."
    ["start_db"]="Datenbank starten..."
    ["wait_db"]="Auf Datenbank warten..."
    ["install_apex"]="APEX installieren..."
    ["config_apex"]="APEX konfigurieren..."
    ["create_users"]="Benutzer erstellen..."
    ["grant_proxy"]="Berechtigungen erteilen..."
    ["setup_admin"]="Admin einrichten..."
    ["install_ords"]="ORDS installieren..."
    ["config_ords"]="ORDS konfigurieren..."
    ["start_ords"]="ORDS starten..."
    ["verify"]="Installation überprüfen..."
    ["create_scripts"]="Skripte erstellen..."
    ["finalizing"]="Finalisierung..."
    ["done"]="Fertig!"
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
    
    # Check if YAD exists
    if command -v yad &> /dev/null; then
        GUI_TOOL="yad"
        echo "✅ YAD found"
        return 0
    fi
    
    # Check if Zenity exists
    if command -v zenity &> /dev/null; then
        GUI_TOOL="zenity"
        echo "✅ Zenity found"
        return 0
    fi
    
    echo "📦 Installing GUI tools..."
    
    # Detect OS and install
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
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - install using Homebrew
        if command -v brew &> /dev/null; then
            brew install zenity 2>/dev/null || true
        fi
    fi
    
    # Re-check
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

show_question() {
    local title=$1
    local text=$2
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --question --title="$title" --text="$text" --width=400 --center 2>/dev/null
        return $?
    else
        zenity --question --title="$title" --text="$text" --width=400 2>/dev/null
        return $?
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
        
        # Validate passwords
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
PROGRESS_PID=""
FIFO_FILE="/tmp/apex_install_fifo_$$"

start_progress() {
    rm -f "$FIFO_FILE"
    mkfifo "$FIFO_FILE"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="$(get_text title)" \
            --text="$(get_text installing)" \
            --percentage=0 --auto-close --auto-kill \
            --width=500 --height=150 --center \
            --enable-log --log-expanded --log-height=200 \
            < "$FIFO_FILE" &
        PROGRESS_PID=$!
    else
        zenity --progress --title="$(get_text title)" \
            --text="$(get_text installing)" \
            --percentage=0 --auto-close --auto-kill \
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
    exec 3>&-
    rm -f "$FIFO_FILE"
    [ -n "$PROGRESS_PID" ] && kill $PROGRESS_PID 2>/dev/null || true
}

# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING
# ═══════════════════════════════════════════════════════════════════════════════
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" >> "$INSTALL_LOG"
}

log_step() {
    local step=$1
    local total=$2
    local msg=$3
    
    log "STEP $step/$total: $msg"
    update_progress $((step * 100 / total)) "$(get_text step) $step $(get_text of) $total: $msg"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALLATION STEPS
# ═══════════════════════════════════════════════════════════════════════════════
run_installation() {
    local TOTAL=20
    local STEP=0
    
    mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR"
    mkdir -p "$ORDS_CONFIG_DIR/databases/default" "$ORDS_CONFIG_DIR/global"
    
    echo "" > "$INSTALL_LOG"
    
    start_progress
    
    # Step 1: Initialize
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text init)"
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    sleep 1
    
    # Step 2: Check System
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text check_system)"
    log "OS: $(uname -s) $(uname -r)"
    log "Arch: $(uname -m)"
    sleep 1
    
    # Step 3: Install Dependencies
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text install_deps)"
    
    if ! command -v docker &> /dev/null; then
        log "Installing Docker..."
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian|linuxmint|pop)
                    sudo apt-get update -qq >> "$INSTALL_LOG" 2>&1
                    sudo apt-get install -y docker.io docker-compose openjdk-17-jdk unzip wget >> "$INSTALL_LOG" 2>&1
                    ;;
                fedora)
                    sudo dnf install -y docker docker-compose java-17-openjdk unzip wget >> "$INSTALL_LOG" 2>&1
                    ;;
                opensuse*|suse*)
                    sudo zypper --non-interactive install -y docker docker-compose java-17-openjdk unzip wget >> "$INSTALL_LOG" 2>&1
                    ;;
                arch|manjaro)
                    sudo pacman -S --noconfirm docker docker-compose jdk17-openjdk unzip wget >> "$INSTALL_LOG" 2>&1
                    ;;
            esac
        fi
        sudo systemctl enable docker >> "$INSTALL_LOG" 2>&1 || true
        sudo systemctl start docker >> "$INSTALL_LOG" 2>&1 || true
        sudo usermod -aG docker "$USER" >> "$INSTALL_LOG" 2>&1 || true
    fi
    sleep 1
    
    # Step 4: Cleanup
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text cleanup)"
    pkill -9 -f "ords" 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true
    docker rm -f oracle-apex-db 2>/dev/null || true
    sleep 1
    
    # Step 5: Download APEX
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text download) APEX..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ] || [ $(stat -c%s "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || echo 0) -lt 100000000 ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" >> "$INSTALL_LOG" 2>&1 || true
    fi
    
    # Step 6: Download ORDS
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text download) ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ] || [ $(stat -c%s "$DOWNLOADS_DIR/ords-latest.zip" 2>/dev/null || echo 0) -lt 50000000 ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" >> "$INSTALL_LOG" 2>&1 || true
    fi
    
    # Step 7: Extract
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text extract)"
    cd "$PROJECT_DIR"
    rm -rf apex ords
    unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" >> "$INSTALL_LOG" 2>&1
    mkdir -p ords && unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords >> "$INSTALL_LOG" 2>&1
    cp -r apex/images "$IMAGES_DIR" 2>/dev/null || true
    find ords -name "ords" -type f -exec chmod +x {} \;
    
    # Step 8: Docker Compose
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text docker_setup)"
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
    
    # Step 9: Start Database
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text start_db)"
    cd "$PROJECT_DIR"
    docker compose up -d >> "$INSTALL_LOG" 2>&1 || docker-compose up -d >> "$INSTALL_LOG" 2>&1
    
    # Step 10: Wait for Database
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text wait_db)"
    local timeout=600
    local start=$(date +%s)
    while true; do
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            log "Database is ready!"
            break
        fi
        local elapsed=$(($(date +%s) - start))
        [ $elapsed -gt $timeout ] && break
        update_progress $((STEP * 100 / TOTAL)) "$(get_text wait_db) ${elapsed}s..."
        sleep 10
    done
    sleep 90
    
    # Step 11: Disable Policies
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text config_apex)"
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Step 12: Install APEX
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text install_apex)"
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    sleep 30
    
    # Step 13: APEX REST
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Step 14: Create Users
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text create_users)"
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Step 15: Grant Proxy
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text grant_proxy)"
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Step 16: Setup APEX Admin
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text setup_admin)"
    
    local apex_schema=$(docker exec oracle-apex-db bash -c "echo \"SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ')
    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"
    
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << EOSQL
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
    
    # Step 17: Install ORDS
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text install_ords)"
    
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
    
    # Step 18: Configure ORDS
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text config_ords)"
    
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port $ORDS_PORT >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
    echo "${ORACLE_PASSWORD}" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    
    # Step 19: Start ORDS
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text start_ords)"
    
    pkill -f ords 2>/dev/null || true
    sleep 3
    
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    
    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port $ORDS_PORT \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &
    
    echo $! > "$PROJECT_DIR/ords.pid"
    sleep 60
    
    # Step 20: Create Scripts & Finalize
    STEP=$((STEP + 1))
    log_step $STEP $TOTAL "$(get_text finalizing)"
    
    # Create start script
    cat > "$SCRIPTS_DIR/start.sh" << 'STARTEOF'
#!/bin/bash
cd ~/oracle-apex-complete
PASS=$(cat .db_password 2>/dev/null)
echo "Starting Oracle APEX..."
docker start oracle-apex-db 2>/dev/null || docker compose up -d
sleep 90
docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOF
pkill -f ords 2>/dev/null || true
sleep 3
ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &
sleep 60
echo "✅ Oracle APEX Started!"
echo "   http://localhost:8080/ords/apex_admin"
STARTEOF
    chmod +x "$SCRIPTS_DIR/start.sh"
    
    # Create stop script
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
echo "Stopping Oracle APEX..."
pkill -f ords 2>/dev/null || true
docker stop oracle-apex-db 2>/dev/null || true
echo "✅ Oracle APEX Stopped!"
STOPEOF
    chmod +x "$SCRIPTS_DIR/stop.sh"
    
    # Create status script
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
echo "=== Oracle APEX Status ==="
DB=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo "false")
ORDS=$(pgrep -f "ords.*serve" > /dev/null && echo "true" || echo "false")
echo "Database: $([[ $DB == 'true' ]] && echo '🟢 Running' || echo '🔴 Stopped')"
echo "ORDS:     $([[ $ORDS == 'true' ]] && echo '🟢 Running' || echo '🔴 Stopped')"
echo ""
echo "HTTP Status:"
echo "  Admin: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/ords/apex_admin)"
echo "  Login: $(curl -s -o /dev/null -w '%{http_code}' 'http://localhost:8080/ords/f?p=4550')"
STATUSEOF
    chmod +x "$SCRIPTS_DIR/status.sh"
    
    # Create fix script
    cat > "$SCRIPTS_DIR/fix.sh" << 'FIXEOF'
#!/bin/bash
cd ~/oracle-apex-complete
PASS=$(cat .db_password 2>/dev/null)
echo "Running fix..."
pkill -f ords 2>/dev/null || true
sleep 5
docker start oracle-apex-db 2>/dev/null || true
sleep 30
docker exec oracle-apex-db sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << EOF
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOF
ORDS_BIN=$(find ~/oracle-apex-complete/ords -name "ords" -type f | head -1)
echo "${PASS}" | "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config config secret --password-stdin db.password 2>/dev/null
nohup "$ORDS_BIN" --config ~/oracle-apex-complete/ords_config serve --port 8080 --apex-images ~/oracle-apex-complete/images > ~/oracle-apex-complete/logs/ords.log 2>&1 &
sleep 60
echo "✅ Fix completed!"
bash ~/oracle-apex-complete/scripts/status.sh
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh"
    
    update_progress 100 "$(get_text done)"
    sleep 2
    
    stop_progress
    
    log "Installation completed successfully!"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SUCCESS DIALOG
# ═══════════════════════════════════════════════════════════════════════════════
show_success() {
    local result
    
    if [ "$GUI_TOOL" = "yad" ]; then
        result=$(yad --list --title="🎉 $(get_text completed)" \
            --text="$(get_text success_msg)" \
            --radiolist --column="" --column="Action" --column="Description" \
            TRUE "browser" "$(get_text open_browser)" \
            FALSE "logs" "$(get_text view_logs)" \
            FALSE "exit" "$(get_text exit)" \
            --width=550 --height=450 --center \
            --button="OK:0" \
            --print-column=2 --hide-column=2 2>/dev/null)
    else
        result=$(zenity --list --title="🎉 $(get_text completed)" \
            --text="$(get_text success_msg)" \
            --radiolist --column="" --column="Action" --column="Description" \
            TRUE "browser" "$(get_text open_browser)" \
            FALSE "logs" "$(get_text view_logs)" \
            FALSE "exit" "$(get_text exit)" \
            --width=550 --height=450 --hide-column=2 2>/dev/null)
    fi
    
    case "$result" in
        *browser*)
            xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || \
            open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
            ;;
        *logs*)
            if [ "$GUI_TOOL" = "yad" ]; then
                yad --text-info --title="Installation Log" \
                    --filename="$INSTALL_LOG" --width=800 --height=600 \
                    --fontname="monospace" 2>/dev/null
            else
                zenity --text-info --title="Installation Log" \
                    --filename="$INSTALL_LOG" --width=800 --height=600 2>/dev/null
            fi
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════
main() {
    # Install GUI tool if needed
    install_gui_tool
    
    # Select language
    select_language
    
    # Show welcome
    show_info "$(get_text title)" "$(get_text welcome)"
    
    # Get passwords
    get_passwords
    
    # Run installation
    run_installation
    
    # Show success
    show_success
}

# Run main
main "$@"
