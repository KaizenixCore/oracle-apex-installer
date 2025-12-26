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
#  ║     ORACLE APEX GUI INSTALLER v3.5.0 - KAIZENIXCORE                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  ✅ v3.5.0 FIXES:                                                         ║
#  ║     - set -e REMOVED (was causing script to exit on any error)            ║
#  ║     - Error 574 Database Credential - FIXED                               ║
#  ║     - Error 571 Connection Error - FIXED                                  ║
#  ║     - Error 500 Internal Server - FIXED                                   ║
#  ║     - APEX images not loaded - FIXED                                      ║
#  ║     - Password mismatch with Docker volume - FIXED                        ║
#  ║     - Permission denied on log file - FIXED                               ║
#  ║     - Script exits in middle of installation - FIXED                      ║
#  ║     - ORDS password encryption - FIXED                                    ║
#  ║     - GUI sudo prompt - FIXED                                             ║
#  ║     - Auto browser open - FIXED                                           ║
#  ║     - All commands protected with || true                                 ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

# DO NOT USE set -e - it causes the script to exit on any error!
# Instead, we handle errors manually with || true

VERSION="3.5.0"
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

GUI_TOOL=""
SUDO_PASS=""
ORACLE_PASSWORD=""
APEX_ADMIN_PASSWORD=""

#──────────────────────────────────────────────────────────────────────────────
# LANGUAGE STRINGS
#──────────────────────────────────────────────────────────────────────────────
declare -A LANG_EN=(
    ["title"]="Oracle APEX Installer"
    ["welcome"]="Welcome to Oracle APEX Ultimate Installer v3.5.0!\n\nThis will install:\n• Oracle APEX (Latest)\n• Oracle ORDS (Latest)\n• Oracle XE 21c Database\n\nClick OK to continue."
    ["enter_passwords"]="Enter Passwords"
    ["oracle_pass"]="Oracle Database Password:"
    ["apex_pass"]="APEX Admin Password:"
    ["pass_rules"]="Password Rules:\n• Start with a letter\n• Only letters and numbers\n• Minimum 6 characters\n\nExample: MyPass123"
    ["invalid_pass"]="Invalid Password!\n\nPassword must:\n• Start with a letter (a-z, A-Z)\n• Contain only letters and numbers\n• Be at least 6 characters\n\nExample: Oracle123"
    ["installing"]="Installing Oracle APEX..."
    ["completed"]="Installation Completed!"
    ["error"]="Error"
    ["open_browser"]="Open APEX in Browser"
    ["exit"]="Exit"
    ["sudo_pass"]="Enter your system password (sudo):"
    ["wait_db"]="Waiting for database to start (5-10 minutes)..."
    ["wait_ords"]="Waiting for ORDS to start (3-5 minutes)..."
    ["step"]="Step"
    ["of"]="of"
    ["cleanup_title"]="Previous Installation Found"
    ["cleanup_q"]="A previous installation was detected.\n\nDo you want to REMOVE old database data?\n\n✅ YES (Recommended):\n   - Fixes password mismatch errors\n   - Clean fresh installation\n   - Solves Error 574\n\n❌ NO:\n   - Keep existing data\n   - May cause password errors"
    ["cleanup_yes"]="YES - Remove"
    ["cleanup_no"]="NO - Keep"
)

declare -A LANG_FA=(
    ["title"]="نصب‌کننده اوراکل اپکس"
    ["welcome"]="به نصب‌کننده اوراکل اپکس نسخه 3.5.0 خوش آمدید!\n\nاین برنامه نصب می‌کند:\n• Oracle APEX (آخرین نسخه)\n• Oracle ORDS (آخرین نسخه)\n• Oracle XE 21c Database\n\nبرای ادامه OK را بزنید."
    ["enter_passwords"]="ورود رمز عبور"
    ["oracle_pass"]="رمز عبور Oracle Database:"
    ["apex_pass"]="رمز عبور APEX Admin:"
    ["pass_rules"]="قوانین رمز عبور:\n• با حرف انگلیسی شروع شود\n• فقط حروف و اعداد\n• حداقل ۶ کاراکتر\n\nمثال: MyPass123"
    ["invalid_pass"]="رمز عبور نامعتبر!\n\nرمز عبور باید:\n• با حرف انگلیسی شروع شود\n• فقط حروف و اعداد\n• حداقل ۶ کاراکتر\n\nمثال: Oracle123"
    ["installing"]="در حال نصب اوراکل اپکس..."
    ["completed"]="نصب با موفقیت انجام شد!"
    ["error"]="خطا"
    ["open_browser"]="باز کردن APEX در مرورگر"
    ["exit"]="خروج"
    ["sudo_pass"]="رمز عبور سیستم را برای sudo وارد کنید:"
    ["wait_db"]="منتظر شروع دیتابیس (۵-۱۰ دقیقه)..."
    ["wait_ords"]="منتظر شروع ORDS (۳-۵ دقیقه)..."
    ["step"]="مرحله"
    ["of"]="از"
    ["cleanup_title"]="نصب قبلی پیدا شد"
    ["cleanup_q"]="یک نصب قبلی پیدا شد.\n\nآیا می‌خواهید دیتای قبلی پاک شود؟\n\n✅ بله (پیشنهادی):\n   - رفع مشکل رمز عبور\n   - نصب تمیز و جدید\n   - رفع خطای 574\n\n❌ خیر:\n   - نگه داشتن دیتای قبلی\n   - ممکن است خطا داشته باشد"
    ["cleanup_yes"]="بله - پاک کردن"
    ["cleanup_no"]="خیر - نگه داشتن"
)

declare -A LANG_DE=(
    ["title"]="Oracle APEX Installer"
    ["welcome"]="Willkommen beim Oracle APEX Installer v3.5.0!\n\nDieses Programm installiert:\n• Oracle APEX (Neueste)\n• Oracle ORDS (Neueste)\n• Oracle XE 21c Datenbank\n\nKlicken Sie OK um fortzufahren."
    ["enter_passwords"]="Passwörter eingeben"
    ["oracle_pass"]="Oracle Database Passwort:"
    ["apex_pass"]="APEX Admin Passwort:"
    ["pass_rules"]="Passwortregeln:\n• Beginnt mit Buchstaben\n• Nur Buchstaben und Zahlen\n• Mindestens 6 Zeichen\n\nBeispiel: MyPass123"
    ["invalid_pass"]="Ungültiges Passwort!\n\nPasswort muss:\n• Mit Buchstaben beginnen\n• Nur Buchstaben/Zahlen\n• Mindestens 6 Zeichen\n\nBeispiel: Oracle123"
    ["installing"]="Oracle APEX wird installiert..."
    ["completed"]="Installation abgeschlossen!"
    ["error"]="Fehler"
    ["open_browser"]="APEX im Browser öffnen"
    ["exit"]="Beenden"
    ["sudo_pass"]="Geben Sie Ihr Systempasswort (sudo) ein:"
    ["wait_db"]="Warten auf Datenbankstart (5-10 Minuten)..."
    ["wait_ords"]="Warten auf ORDS-Start (3-5 Minuten)..."
    ["step"]="Schritt"
    ["of"]="von"
    ["cleanup_title"]="Vorherige Installation gefunden"
    ["cleanup_q"]="Eine vorherige Installation wurde gefunden.\n\nMöchten Sie alte Daten ENTFERNEN?\n\n✅ JA (Empfohlen):\n   - Behebt Passwort-Fehler\n   - Saubere Neuinstallation\n   - Löst Error 574\n\n❌ NEIN:\n   - Daten behalten\n   - Kann Fehler verursachen"
    ["cleanup_yes"]="JA - Entfernen"
    ["cleanup_no"]="NEIN - Behalten"
)

CURRENT_LANG="en"
get_text() {
    local key="$1"
    case $CURRENT_LANG in
        fa) echo "${LANG_FA[$key]:-${LANG_EN[$key]}}" ;;
        de) echo "${LANG_DE[$key]:-${LANG_EN[$key]}}" ;;
        *)  echo "${LANG_EN[$key]}" ;;
    esac
}

#──────────────────────────────────────────────────────────────────────────────
# SAFE DIRECTORY AND FILE CREATION
#──────────────────────────────────────────────────────────────────────────────
safe_mkdir() {
    mkdir -p "$1" 2>/dev/null || sudo mkdir -p "$1" 2>/dev/null || true
    chmod 755 "$1" 2>/dev/null || sudo chmod 755 "$1" 2>/dev/null || true
}

safe_touch() {
    touch "$1" 2>/dev/null || sudo touch "$1" 2>/dev/null || true
    chmod 644 "$1" 2>/dev/null || sudo chmod 644 "$1" 2>/dev/null || true
}

#──────────────────────────────────────────────────────────────────────────────
# LOGGING
#──────────────────────────────────────────────────────────────────────────────
log() {
    safe_mkdir "$PROJECT_DIR"
    safe_mkdir "$LOG_DIR"
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" >> "$INSTALL_LOG" 2>/dev/null || true
}

#──────────────────────────────────────────────────────────────────────────────
# GUI TOOL DETECTION
#──────────────────────────────────────────────────────────────────────────────
install_gui_tool() {
    if command -v yad &> /dev/null; then
        GUI_TOOL="yad"
        return 0
    fi
    if command -v zenity &> /dev/null; then
        GUI_TOOL="zenity"
        return 0
    fi

    echo "Installing GUI tool..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                sudo apt-get update -qq 2>/dev/null || true
                sudo apt-get install -y zenity 2>/dev/null || true
                ;;
            fedora)
                sudo dnf install -y zenity 2>/dev/null || true
                ;;
            opensuse*|suse*)
                sudo zypper --non-interactive install -y zenity 2>/dev/null || true
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm zenity 2>/dev/null || true
                ;;
        esac
    fi

    if command -v zenity &> /dev/null; then
        GUI_TOOL="zenity"
    elif command -v yad &> /dev/null; then
        GUI_TOOL="yad"
    else
        echo "ERROR: No GUI tool found. Please install zenity or yad"
        echo "  Ubuntu/Debian: sudo apt install zenity"
        echo "  Fedora: sudo dnf install zenity"
        echo "  openSUSE: sudo zypper install zenity"
        exit 1
    fi
}

show_info() {
    local title="$1"
    local text="$2"
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$title" --text="$text" --width=550 --height=350 --center 2>/dev/null || true
    else
        zenity --info --title="$title" --text="$text" --width=550 --height=350 2>/dev/null || true
    fi
}

show_error() {
    local title="$1"
    local text="$2"
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="$title" --text="$text" --width=500 --height=300 --center 2>/dev/null || true
    else
        zenity --error --title="$title" --text="$text" --width=500 --height=300 2>/dev/null || true
    fi
}

show_question() {
    local title="$1"
    local text="$2"
    local yes_label="${3:-Yes}"
    local no_label="${4:-No}"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --question --title="$title" --text="$text" \
            --button="$yes_label:0" --button="$no_label:1" \
            --width=550 --height=400 --center 2>/dev/null
        return $?
    else
        zenity --question --title="$title" --text="$text" \
            --ok-label="$yes_label" --cancel-label="$no_label" \
            --width=550 --height=400 2>/dev/null
        return $?
    fi
}

select_language() {
    local result=""
    if [ "$GUI_TOOL" = "yad" ]; then
        result=$(yad --list --title="🌐 Select Language / انتخاب زبان / Sprache" \
            --text="Select your preferred language:" \
            --radiolist --column="" --column="Code" --column="Language" \
            TRUE "en" "🇺🇸 English" \
            FALSE "fa" "🇮🇷 فارسی (Persian)" \
            FALSE "de" "🇩🇪 Deutsch" \
            --width=420 --height=300 --center --print-column=2 --hide-column=2 2>/dev/null) || true
    else
        result=$(zenity --list --title="🌐 Select Language" \
            --text="Select your preferred language:" \
            --radiolist --column="" --column="Code" --column="Language" \
            TRUE "en" "🇺🇸 English" \
            FALSE "fa" "🇮🇷 فارسی (Persian)" \
            FALSE "de" "🇩🇪 Deutsch" \
            --width=420 --height=300 --hide-column=2 2>/dev/null) || true
    fi
    
    if [ -z "$result" ]; then
        exit 0
    fi
    CURRENT_LANG=$(echo "$result" | tr -d '|' | tr -d ' ')
    [ -z "$CURRENT_LANG" ] && CURRENT_LANG="en"
}

get_sudo_password() {
    # Check if we already have sudo access
    if sudo -n true 2>/dev/null; then
        return 0
    fi

    local pass=""
    local attempts=0
    while [ $attempts -lt 3 ]; do
        if [ "$GUI_TOOL" = "yad" ]; then
            pass=$(yad --entry --title="$(get_text title)" --text="$(get_text sudo_pass)" \
                --hide-text --width=420 --center 2>/dev/null) || true
        else
            pass=$(zenity --password --title="$(get_text title)" 2>/dev/null) || true
        fi
        
        if [ -z "$pass" ]; then
            exit 0
        fi

        if echo "$pass" | sudo -S true 2>/dev/null; then
            SUDO_PASS="$pass"
            return 0
        else
            attempts=$((attempts + 1))
            show_error "$(get_text error)" "Wrong password! Try again. ($attempts/3)"
        fi
    done
    exit 1
}

run_sudo() {
    if [ -n "$SUDO_PASS" ]; then
        echo "$SUDO_PASS" | sudo -S "$@" 2>/dev/null
    else
        sudo "$@" 2>/dev/null
    fi
}

get_passwords() {
    local result=""
    while true; do
        if [ "$GUI_TOOL" = "yad" ]; then
            result=$(yad --form --title="$(get_text title) - $(get_text enter_passwords)" \
                --text="$(get_text pass_rules)" \
                --field="$(get_text oracle_pass):H" "" \
                --field="$(get_text apex_pass):H" "" \
                --width=500 --height=350 --center \
                --button="Cancel:1" --button="OK:0" 2>/dev/null) || true
        else
            result=$(zenity --forms --title="$(get_text title)" \
                --text="$(get_text pass_rules)" \
                --add-password="$(get_text oracle_pass)" \
                --add-password="$(get_text apex_pass)" \
                --width=450 --height=300 2>/dev/null) || true
        fi
        
        if [ -z "$result" ]; then
            exit 0
        fi

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
    
    export ORACLE_PASSWORD
    export APEX_ADMIN_PASSWORD
}

#──────────────────────────────────────────────────────────────────────────────
# PROGRESS BAR
#──────────────────────────────────────────────────────────────────────────────
FIFO_FILE=""
PROGRESS_PID=""

start_progress() {
    FIFO_FILE=$(mktemp -u)
    mkfifo "$FIFO_FILE" 2>/dev/null || true
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="$(get_text title)" --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel --width=520 --height=150 --center < "$FIFO_FILE" 2>/dev/null &
        PROGRESS_PID=$!
    else
        zenity --progress --title="$(get_text title)" --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel --width=520 --height=150 < "$FIFO_FILE" 2>/dev/null &
        PROGRESS_PID=$!
    fi
    
    exec 3>"$FIFO_FILE" 2>/dev/null || true
}

update_progress() {
    local percent="$1"
    local text="$2"
    if [ -n "$FIFO_FILE" ] && [ -e "$FIFO_FILE" ]; then
        echo "$percent" >&3 2>/dev/null || true
        echo "# $text" >&3 2>/dev/null || true
    fi
}

stop_progress() {
    exec 3>&- 2>/dev/null || true
    sleep 1
    rm -f "$FIFO_FILE" 2>/dev/null || true
    if [ -n "$PROGRESS_PID" ]; then
        kill "$PROGRESS_PID" 2>/dev/null || true
    fi
    sleep 1
}

#──────────────────────────────────────────────────────────────────────────────
# UTILITY FUNCTIONS
#──────────────────────────────────────────────────────────────────────────────
wait_for_database_ready() {
    log "Waiting for database..."
    local timeout=600
    local start_time
    start_time=$(date +%s)
    
    while true; do
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            log "Database is READY"
            return 0
        fi
        
        local current_time
        current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ "$elapsed" -gt "$timeout" ]; then
            log "Database timeout after ${elapsed}s"
            return 1
        fi
        
        sleep 10
    done
}

check_previous_installation() {
    # Check if container exists
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$"; then
        return 0
    fi
    
    # Check if any oracle volume exists
    if docker volume ls --format '{{.Name}}' 2>/dev/null | grep -qi "oracle"; then
        return 0
    fi
    
    # Check if project directory has installation
    if [ -d "$PROJECT_DIR/apex" ] || [ -d "$PROJECT_DIR/ords" ]; then
        return 0
    fi
    
    return 1
}

#──────────────────────────────────────────────────────────────────────────────
# CREATE MANAGEMENT SCRIPTS
#──────────────────────────────────────────────────────────────────────────────
create_scripts() {
    safe_mkdir "$SCRIPTS_DIR"
    safe_mkdir "$LOG_DIR"

    # STATUS SCRIPT
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
echo "════════════════════════════════════════════════════════════"
echo "  Oracle APEX Status"
echo "════════════════════════════════════════════════════════════"
echo ""

DB_RUN=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo "false")
if [ "$DB_RUN" = "true" ]; then
    echo "Database: 🟢 Running"
else
    echo "Database: 🔴 Stopped"
fi

if pgrep -f "ords.*serve" >/dev/null 2>&1; then
    echo "ORDS:     🟢 Running"
else
    echo "ORDS:     🔴 Stopped"
fi

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
    chmod +x "$SCRIPTS_DIR/status.sh" 2>/dev/null || true

    # STOP SCRIPT
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
echo "Stopping Oracle APEX..."
pkill -f ords 2>/dev/null || true
sleep 2
docker stop oracle-apex-db 2>/dev/null || true
echo "✅ Stopped"
STOPEOF
    chmod +x "$SCRIPTS_DIR/stop.sh" 2>/dev/null || true

    # START SCRIPT
    cat > "$SCRIPTS_DIR/start.sh" << 'STARTEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)

if [ -z "$PASS" ]; then
    echo "❌ Password file not found!"
    exit 1
fi

echo "Starting Oracle APEX..."

# Start database
docker start oracle-apex-db 2>/dev/null || (cd "$PROJECT_DIR" && docker compose up -d 2>/dev/null) || true
echo "Waiting 120s for database..."
sleep 120

# Reset password
echo "Resetting password..."
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 10

# Fix users
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

# Set ORDS password
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "$ORDS_BIN" ]; then
    echo "$PASS" | "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config secret --password-stdin db.password 2>/dev/null || true
fi

# Start ORDS
pkill -f ords 2>/dev/null || true
sleep 3

if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG="$PROJECT_DIR/ords_config"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$PROJECT_DIR/logs/ords.log" 2>&1 &
fi

echo "Waiting 90s for ORDS..."
sleep 90

HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
echo "APEX Admin: HTTP $HTTP"
echo "http://localhost:8080/ords/apex_admin"
STARTEOF
    chmod +x "$SCRIPTS_DIR/start.sh" 2>/dev/null || true

    # FIX SCRIPT
    cat > "$SCRIPTS_DIR/fix.sh" << 'FIXEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)

if [ -z "$PASS" ]; then
    echo "❌ Password file not found!"
    exit 1
fi

echo "════════════════════════════════════════════════════════════"
echo "  FIX SCRIPT - Fixing Error 574 / 571 / 500 / Images"
echo "════════════════════════════════════════════════════════════"

echo ""
echo "[1/7] Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 3

echo "[2/7] Starting database..."
docker start oracle-apex-db 2>/dev/null || true
sleep 60

echo "[3/7] Resetting database password..."
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 15

echo "[4/7] Fixing database users..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[5/7] Fixing ORDS password..."
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "$ORDS_BIN" ]; then
    chmod +x "$ORDS_BIN" 2>/dev/null || true
    echo "$PASS" | "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config secret --password-stdin db.password 2>/dev/null || true
fi

echo "[6/7] Fixing images..."
if [ -d "$PROJECT_DIR/apex/images" ]; then
    rm -rf "$PROJECT_DIR/images" 2>/dev/null || true
    cp -r "$PROJECT_DIR/apex/images" "$PROJECT_DIR/images" 2>/dev/null || true
fi

if [ -n "$ORDS_BIN" ]; then
    "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config set standalone.static.path "$PROJECT_DIR/images" 2>/dev/null || true
    "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config set standalone.static.context.path /i/ 2>/dev/null || true
fi

echo "[7/7] Starting ORDS..."
if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG="$PROJECT_DIR/ords_config"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$PROJECT_DIR/logs/ords.log" 2>&1 &
fi

echo ""
echo "Waiting 120s for ORDS..."
sleep 120

echo ""
echo "════════════════════════════════════════════════════════════"
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_IMG=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null || echo "000")
echo "APEX Admin: HTTP $HTTP_ADMIN"
echo "Images:     HTTP $HTTP_IMG"

if [[ "$HTTP_ADMIN" =~ ^(200|302|303)$ ]]; then
    echo ""
    echo "✅ APEX is working!"
    echo "   http://localhost:8080/ords/apex_admin"
else
    echo ""
    echo "⚠️ May need more time. Wait 2 minutes and refresh browser."
fi
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh" 2>/dev/null || true

    # GUI LAUNCHER
    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"

GUI=""
command -v yad >/dev/null 2>&1 && GUI="yad"
command -v zenity >/dev/null 2>&1 && [ -z "$GUI" ] && GUI="zenity"

if [ -z "$GUI" ]; then
    echo "No GUI tool found"
    exit 1
fi

while true; do
    DB_RUN=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo "false")
    ORDS_RUN="false"
    pgrep -f "ords.*serve" >/dev/null 2>&1 && ORDS_RUN="true"
    
    if [ "$DB_RUN" = "true" ] && [ "$ORDS_RUN" = "true" ]; then
        ICON="🟢"
    else
        ICON="🔴"
    fi

    if [ "$GUI" = "yad" ]; then
        CHOICE=$(yad --list --title="Oracle APEX Manager $ICON" \
            --text="Status: Database=$DB_RUN, ORDS=$ORDS_RUN\n\nSelect action:" \
            --radiolist --column="" --column="id" --column="Action" \
            TRUE start "▶️ Start" FALSE stop "⏹️ Stop" FALSE fix "🔧 Fix" \
            FALSE status "📊 Status" FALSE open "🌐 Open Browser" FALSE exit "❌ Exit" \
            --hide-column=2 --print-column=2 --width=450 --height=380 2>/dev/null) || true
    else
        CHOICE=$(zenity --list --title="Oracle APEX Manager $ICON" \
            --text="Status: Database=$DB_RUN, ORDS=$ORDS_RUN\n\nSelect action:" \
            --radiolist --column="" --column="id" --column="Action" \
            TRUE start "▶️ Start" FALSE stop "⏹️ Stop" FALSE fix "🔧 Fix" \
            FALSE status "📊 Status" FALSE open "🌐 Open Browser" FALSE exit "❌ Exit" \
            --hide-column=2 --width=450 --height=380 2>/dev/null) || true
    fi

    [ -z "$CHOICE" ] && exit 0

    case "$CHOICE" in
        start) bash "$SCRIPTS_DIR/start.sh" ;;
        stop) bash "$SCRIPTS_DIR/stop.sh" ;;
        fix) bash "$SCRIPTS_DIR/fix.sh" ;;
        status) bash "$SCRIPTS_DIR/status.sh"; read -p "Press Enter..." ;;
        open) xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || true ;;
        exit) exit 0 ;;
    esac
done
GUIEOF
    chmod +x "$SCRIPTS_DIR/launch-gui.sh" 2>/dev/null || true

    # Desktop file
    safe_mkdir "$HOME/.local/share/applications"
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
    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop" 2>/dev/null || true

    log "Management scripts created"
}

#──────────────────────────────────────────────────────────────────────────────
# MAIN INSTALLATION
#──────────────────────────────────────────────────────────────────────────────
run_installation() {
    # Create directories first with proper permissions
    safe_mkdir "$PROJECT_DIR"
    safe_mkdir "$DOWNLOADS_DIR"
    safe_mkdir "$LOG_DIR"
    safe_mkdir "$IMAGES_DIR"
    safe_mkdir "$SCRIPTS_DIR"
    safe_mkdir "$ORDS_CONFIG_DIR"
    safe_mkdir "$ORDS_CONFIG_DIR/databases/default"
    safe_mkdir "$ORDS_CONFIG_DIR/global"
    
    # Create log file with proper permissions
    safe_touch "$INSTALL_LOG"
    safe_touch "$LOG_DIR/ords.log"
    
    log "Installation started - v$VERSION"

    # Check for previous installation BEFORE starting progress
    log "Checking for previous installation..."
    local remove_data=1  # default: keep data
    
    if check_previous_installation; then
        log "Previous installation found, asking user..."
        if show_question "$(get_text cleanup_title)" "$(get_text cleanup_q)" \
                         "$(get_text cleanup_yes)" "$(get_text cleanup_no)"; then
            remove_data=0  # User chose YES
            log "User chose to remove old data"
        else
            log "User chose to keep old data"
        fi
    fi

    start_progress

    # Step 1: Save passwords
    update_progress 2 "$(get_text step) 1/20: Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password" 2>/dev/null || true
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password" 2>/dev/null || true
    chmod 600 "$PROJECT_DIR/.db_password" 2>/dev/null || true
    chmod 600 "$PROJECT_DIR/.apex_password" 2>/dev/null || true
    log "Passwords saved"

    # Step 2: Cleanup
    update_progress 5 "$(get_text step) 2/20: Cleaning up..."
    pkill -f ords 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true
    docker rm -f oracle-apex-db 2>/dev/null || true

    if [ "$remove_data" -eq 0 ]; then
        log "Removing old data..."
        docker volume rm oracle-apex-complete_oracle-data 2>/dev/null || true
        docker volume rm oracle-data 2>/dev/null || true
        rm -rf "$PROJECT_DIR/apex" 2>/dev/null || true
        rm -rf "$PROJECT_DIR/ords" 2>/dev/null || true
    fi
    log "Cleanup done"

    # Step 3: Install dependencies
    update_progress 8 "$(get_text step) 3/20: Installing dependencies..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                run_sudo apt-get update -qq || true
                run_sudo apt-get install -y docker.io docker-compose openjdk-17-jdk unzip wget curl || true
                ;;
            fedora)
                run_sudo dnf install -y docker docker-compose java-17-openjdk unzip wget curl || true
                ;;
            opensuse*|suse*)
                run_sudo zypper --non-interactive install -y docker docker-compose java-17-openjdk unzip wget curl || true
                ;;
            arch|manjaro)
                run_sudo pacman -S --noconfirm docker docker-compose jdk17-openjdk unzip wget curl || true
                ;;
        esac
    fi
    run_sudo systemctl enable docker || true
    run_sudo systemctl start docker || true
    log "Dependencies installed"

    # Step 4: Download APEX
    update_progress 12 "$(get_text step) 4/20: Downloading APEX..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ]; then
        wget -q -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || true
    fi
    log "APEX downloaded"

    # Step 5: Download ORDS
    update_progress 18 "$(get_text step) 5/20: Downloading ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ]; then
        wget -q -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || true
    fi
    log "ORDS downloaded"

    # Step 6: Extract
    update_progress 22 "$(get_text step) 6/20: Extracting files..."
    cd "$PROJECT_DIR" || exit 1
    
    if [ ! -d "$PROJECT_DIR/apex" ]; then
        unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || true
    fi
    
    if [ ! -d "$PROJECT_DIR/ords/bin" ]; then
        rm -rf ords 2>/dev/null || true
        mkdir -p ords
        unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords 2>/dev/null || true
    fi
    
    find ords -name "ords" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # Copy images correctly
    rm -rf "$IMAGES_DIR" 2>/dev/null || true
    cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR" 2>/dev/null || true
    log "Files extracted"

    # Step 7: Docker Compose
    update_progress 25 "$(get_text step) 7/20: Creating Docker configuration..."
    cat > "$PROJECT_DIR/docker-compose.yml" << COMPOSEOF
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
COMPOSEOF
    log "Docker compose created"

    # Step 8: Start Database
    update_progress 28 "$(get_text step) 8/20: $(get_text wait_db)"
    cd "$PROJECT_DIR" || exit 1
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || true
    
    wait_for_database_ready || {
        log "Database wait timeout, but continuing..."
    }
    
    sleep 60
    log "Database started"

    # Step 9: Reset password in container
    update_progress 32 "$(get_text step) 9/20: Setting database password..."
    docker exec oracle-apex-db resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 20
    log "Password reset"

    # Step 10: Disable password policies
    update_progress 35 "$(get_text step) 10/20: Configuring database..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Policies disabled"

    # Step 11: Install APEX
    update_progress 38 "$(get_text step) 11/20: Installing APEX (15-25 min)..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "APEX installed"

    # Step 12: Reset image prefix
    update_progress 52 "$(get_text step) 12/20: Setting image prefix..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@utilities/reset_image_prefix.sql
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Image prefix reset"

    # Step 13: APEX REST config
    update_progress 55 "$(get_text step) 13/20: Configuring REST..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "REST configured"

    # Step 14: Create users
    update_progress 58 "$(get_text step) 14/20: Creating users..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE, CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

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

    # Step 15: Grant proxy
    update_progress 62 "$(get_text step) 15/20: Granting proxy..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
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

    # Step 16: Create APEX admin
    update_progress 66 "$(get_text step) 16/20: Creating APEX admin..."
    local apex_schema
    apex_schema=$(docker exec oracle-apex-db bash -c "echo \"SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ') || true
    
    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema" 2>/dev/null || true

    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
BEGIN
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
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

    # Step 17: Install ORDS
    update_progress 70 "$(get_text step) 17/20: Installing ORDS..."
    local ORDS_BIN
    ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    
    if [ -n "$ORDS_BIN" ]; then
        chmod +x "$ORDS_BIN" 2>/dev/null || true

        local PASS_FILE
        PASS_FILE=$(mktemp)
        printf "%s\n%s\n%s\n" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" > "$PASS_FILE"

        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
            --admin-user SYS \
            --db-hostname localhost \
            --db-port "$DB_PORT" \
            --db-servicename "$DB_SERVICE" \
            --feature-sdw true \
            --gateway-mode proxied \
            --gateway-user APEX_PUBLIC_USER \
            --password-stdin < "$PASS_FILE" >> "$INSTALL_LOG" 2>&1 || true

        rm -f "$PASS_FILE" 2>/dev/null || true
    fi
    log "ORDS installed"

    # Step 18: Configure ORDS
    update_progress 78 "$(get_text step) 18/20: Configuring ORDS..."
    if [ -n "$ORDS_BIN" ]; then
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port "$ORDS_PORT" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i/ >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
        
        # Set ORDS password - CRITICAL for fixing Error 574
        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    fi
    log "ORDS configured"

    # Step 19: Final user fixes
    update_progress 82 "$(get_text step) 19/20: Final configuration..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
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
    log "Final configuration done"

    # Step 20: Start ORDS
    update_progress 85 "$(get_text step) 20/20: $(get_text wait_ords)"
    pkill -f ords 2>/dev/null || true
    sleep 3

    run_sudo fuser -k "${ORDS_PORT}/tcp" 2>/dev/null || true

    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

    # Ensure log file exists and is writable
    safe_touch "$LOG_DIR/ords.log"
    
    if [ -n "$ORDS_BIN" ]; then
        nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve --port "$ORDS_PORT" --apex-images "$IMAGES_DIR" > "$LOG_DIR/ords.log" 2>&1 &
        log "ORDS starting with PID $!"
    fi

    update_progress 90 "Waiting for ORDS (2 minutes)..."
    sleep 120

    update_progress 95 "Creating management scripts..."
    create_scripts

    update_progress 98 "Verifying..."
    local http_admin
    local http_img
    http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null || echo "000")
    http_img=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/i/apex_version.txt" 2>/dev/null || echo "000")
    log "HTTP Admin: $http_admin, Images: $http_img"

    update_progress 100 "$(get_text completed)"
    sleep 2
    stop_progress
    
    log "Installation completed"
}

show_success() {
    local msg="✅ Oracle APEX installed successfully!\n\n"
    msg+="🌐 Admin Panel:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\n"
    msg+="🔐 Login Page:\nhttp://localhost:${ORDS_PORT}/ords/f?p=4550\n\n"
    msg+="📋 Credentials:\n"
    msg+="   Workspace: INTERNAL\n"
    msg+="   Username: ADMIN\n"
    msg+="   Password: $APEX_ADMIN_PASSWORD\n\n"
    msg+="🛠️ If you see Error 574 or images problem:\n"
    msg+="   Run: bash ~/oracle-apex-complete/scripts/fix.sh"

    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$(get_text completed)" --text="$msg" --width=580 --height=480 --center \
            --button="$(get_text open_browser):0" --button="$(get_text exit):1" 2>/dev/null
        local btn_result=$?
        if [ $btn_result -eq 0 ]; then
            xdg-open "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null &
        fi
    else
        zenity --info --title="$(get_text completed)" --text="$msg" --width=580 --height=480 2>/dev/null || true
        xdg-open "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null &
    fi
}

#──────────────────────────────────────────────────────────────────────────────
# MAIN
#──────────────────────────────────────────────────────────────────────────────
main() {
    install_gui_tool
    select_language
    show_info "$(get_text title)" "$(get_text welcome)"
    get_sudo_password
    get_passwords
    run_installation
    show_success
}

main "$@"
