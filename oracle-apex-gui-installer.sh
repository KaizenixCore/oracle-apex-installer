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
#  ║     ORACLE APEX GUI INSTALLER v3.2.1 - KAIZENIXCORE                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  ✅ Fixes: Password mismatch (docker volume), APEX images not loaded,     ║
#  ║          ORDS connection reset, GUI sudo prompt, port conflicts           ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e

VERSION="3.2.1"
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

PRIMARY_GROUP=""
PRIMARY_GROUP=$(id -gn 2>/dev/null || echo "")
[ -z "$PRIMARY_GROUP" ] && PRIMARY_GROUP="users"

#──────────────────────────────────────────────────────────────────────────────
# LANGUAGE STRINGS
#──────────────────────────────────────────────────────────────────────────────
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
    ["error"]="Error"
    ["open_browser"]="Open APEX in Browser"
    ["exit"]="Exit"
    ["sudo_pass"]="Enter your system password (sudo):"
    ["wait_db"]="Waiting for database to start (5-10 minutes)..."
    ["wait_ords"]="Waiting for ORDS to start (3-5 minutes)..."
    ["step"]="Step"
    ["of"]="of"
    ["cleanup_q"]="Existing installation detected. Remove old database data?\n\nRecommended: YES (fixes password mismatch + most errors)\nWarning: This deletes existing database data!"
    ["cleanup_yes"]="Remove data (Recommended)"
    ["cleanup_no"]="Keep data"
    ["db_pass_fix"]="Resetting database password in container..."
    ["db_pass_bad"]="Database password check failed.\n\nThis happens when Docker volume already exists and ORACLE_PASSWORD is ignored.\n\nThe installer will try to fix it automatically."
    ["images_fix"]="Fixing APEX images folder..."
    ["port_fix"]="Port 8080 is in use. Attempting to free it..."
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
    ["error"]="خطا"
    ["open_browser"]="باز کردن APEX در مرورگر"
    ["exit"]="خروج"
    ["sudo_pass"]="رمز عبور سیستم را برای sudo وارد کنید:"
    ["wait_db"]="منتظر شروع دیتابیس (۵-۱۰ دقیقه)..."
    ["wait_ords"]="منتظر شروع ORDS (۳-۵ دقیقه)..."
    ["step"]="مرحله"
    ["of"]="از"
    ["cleanup_q"]="یک نصب قبلی پیدا شد. دیتابیس قبلی پاک شود؟\n\nپیشنهادی: بله (برای رفع مشکل رمز و خطاها)\nهشدار: اطلاعات دیتابیس پاک می‌شود!"
    ["cleanup_yes"]="پاک کردن (پیشنهادی)"
    ["cleanup_no"]="نگه داشتن"
    ["db_pass_fix"]="در حال ریست کردن رمز دیتابیس داخل کانتینر..."
    ["db_pass_bad"]="تست رمز دیتابیس ناموفق بود.\n\nاین معمولاً وقتی است که Docker Volume قبلی وجود دارد و ORACLE_PASSWORD نادیده گرفته می‌شود.\n\nنصاب تلاش می‌کند خودکار درستش کند."
    ["images_fix"]="در حال اصلاح مسیر تصاویر APEX..."
    ["port_fix"]="پورت 8080 در حال استفاده است. در حال آزادسازی..."
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
    ["error"]="Fehler"
    ["open_browser"]="APEX im Browser öffnen"
    ["exit"]="Beenden"
    ["sudo_pass"]="Geben Sie Ihr Systempasswort (sudo) ein:"
    ["wait_db"]="Warten auf Datenbankstart (5-10 Minuten)..."
    ["wait_ords"]="Warten auf ORDS-Start (3-5 Minuten)..."
    ["step"]="Schritt"
    ["of"]="von"
    ["cleanup_q"]="Vorhandene Installation gefunden. Alte Daten löschen?\n\nEmpfohlen: JA (behebt Passwort-Konflikt + Fehler)\nWarnung: Daten werden gelöscht!"
    ["cleanup_yes"]="Daten löschen (Empfohlen)"
    ["cleanup_no"]="Daten behalten"
    ["db_pass_fix"]="Setze Datenbank-Passwort im Container zurück..."
    ["db_pass_bad"]="Datenbank-Passwort-Test fehlgeschlagen.\n\nDies passiert, wenn ein Docker-Volume existiert und ORACLE_PASSWORD ignoriert wird.\n\nInstaller versucht es automatisch zu beheben."
    ["images_fix"]="APEX-Images werden repariert..."
    ["port_fix"]="Port 8080 ist belegt. Versuche ihn freizugeben..."
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

#──────────────────────────────────────────────────────────────────────────────
# GUI TOOL
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

    # If no GUI tool, attempt install with pkexec first (graphical sudo prompt)
    if command -v pkexec &> /dev/null && [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                pkexec sh -lc "apt-get update -qq && apt-get install -y zenity" 2>/dev/null || true
                ;;
            fedora)
                pkexec sh -lc "dnf install -y zenity" 2>/dev/null || true
                ;;
            opensuse*|suse*)
                pkexec sh -lc "zypper --non-interactive install -y zenity" 2>/dev/null || true
                ;;
            arch|manjaro)
                pkexec sh -lc "pacman -S --noconfirm zenity" 2>/dev/null || true
                ;;
        esac
    fi

    if command -v yad &> /dev/null; then
        GUI_TOOL="yad"
    elif command -v zenity &> /dev/null; then
        GUI_TOOL="zenity"
    else
        echo "No GUI tool found and could not install it. Install manually: zenity or yad"
        exit 1
    fi
}

show_info() {
    local title=$1
    local text=$2

    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$title" --text="$text" --width=520 --height=320 --center --on-top 2>/dev/null
    else
        zenity --info --title="$title" --text="$text" --width=520 --height=320 2>/dev/null
    fi
}

show_error() {
    local title=$1
    local text=$2

    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="$title" --text="$text" --width=520 --height=240 --center --on-top 2>/dev/null
    else
        zenity --error --title="$title" --text="$text" --width=520 --height=240 2>/dev/null
    fi
}

show_question_cleanup() {
    # returns 0 => remove, 1 => keep
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --question --title="$(get_text title)" --text="$(get_text cleanup_q)" \
            --button="$(get_text cleanup_yes):0" --button="$(get_text cleanup_no):1" \
            --width=520 --height=240 --center --on-top 2>/dev/null
        return $?
    else
        zenity --question --title="$(get_text title)" --text="$(get_text cleanup_q)" \
            --ok-label="$(get_text cleanup_yes)" --cancel-label="$(get_text cleanup_no)" \
            --width=520 --height=240 2>/dev/null
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
            FALSE "de" "🇩🇪 Deutsch" \
            --width=420 --height=300 --center --print-column=2 --hide-column=2 2>/dev/null)
    else
        result=$(zenity --list --title="🌐 Select Language" \
            --text="Select your preferred language:" \
            --radiolist --column="" --column="Code" --column="Language" \
            TRUE "en" "🇺🇸 English" \
            FALSE "fa" "🇮🇷 فارسی (Persian)" \
            FALSE "de" "🇩🇪 Deutsch" \
            --width=420 --height=300 --hide-column=2 2>/dev/null)
    fi

    [ -z "$result" ] && exit 0
    CURRENT_LANG=$(echo "$result" | tr -d '|')
}

get_sudo_password() {
    # If sudo already works, skip.
    if sudo -n true 2>/dev/null; then
        return 0
    fi

    local pass=""
    while true; do
        if [ "$GUI_TOOL" = "yad" ]; then
            pass=$(yad --entry --title="$(get_text title)" --text="$(get_text sudo_pass)" --hide-text \
                --width=420 --center --on-top 2>/dev/null)
        else
            pass=$(zenity --password --title="$(get_text title)" 2>/dev/null)
        fi

        [ -z "$pass" ] && exit 0

        if echo "$pass" | sudo -S true 2>/dev/null; then
            SUDO_PASS="$pass"
            return 0
        else
            show_error "$(get_text error)" "Wrong password! Try again."
        fi
    done
}

run_sudo() {
    if [ -n "$SUDO_PASS" ]; then
        echo "$SUDO_PASS" | sudo -S "$@" 2>/dev/null
    else
        sudo "$@"
    fi
}

get_passwords() {
    local result

    while true; do
        if [ "$GUI_TOOL" = "yad" ]; then
            result=$(yad --form --title="$(get_text title) - $(get_text enter_passwords)" \
                --text="$(get_text pass_rules)" \
                --field="$(get_text oracle_pass):H" "" \
                --field="$(get_text apex_pass):H" "" \
                --width=470 --height=300 --center --on-top \
                --button="Cancel:1" --button="OK:0" 2>/dev/null)
        else
            result=$(zenity --forms --title="$(get_text title)" \
                --text="$(get_text pass_rules)" \
                --add-password="$(get_text oracle_pass)" \
                --add-password="$(get_text apex_pass)" \
                --width=420 2>/dev/null)
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

#──────────────────────────────────────────────────────────────────────────────
# PROGRESS
#──────────────────────────────────────────────────────────────────────────────
FIFO_FILE=""
PROGRESS_PID=""

start_progress() {
    FIFO_FILE=$(mktemp -u)
    mkfifo "$FIFO_FILE"

    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="$(get_text title)" --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel --width=520 --height=150 --center --on-top < "$FIFO_FILE" &
        PROGRESS_PID=$!
    else
        zenity --progress --title="$(get_text title)" --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel --width=520 --height=150 < "$FIFO_FILE" &
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

#──────────────────────────────────────────────────────────────────────────────
# UTIL
#──────────────────────────────────────────────────────────────────────────────
log() {
    mkdir -p "$PROJECT_DIR" "$LOG_DIR" 2>/dev/null || true
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" >> "$INSTALL_LOG" 2>/dev/null || true
    echo "$msg"
}

ensure_permissions() {
    # Fix root-owned leftovers safely using stored sudo password.
    run_sudo mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR" 2>/dev/null || true
    run_sudo chown -R "$USER":"$PRIMARY_GROUP" "$PROJECT_DIR" 2>/dev/null || true
    run_sudo chmod -R u+rwX,go+rX "$PROJECT_DIR" 2>/dev/null || true
}

compose_up() {
    (cd "$PROJECT_DIR" && docker compose up -d 2>/dev/null) || (cd "$PROJECT_DIR" && docker-compose up -d 2>/dev/null)
}

compose_down() {
    (cd "$PROJECT_DIR" && docker compose down 2>/dev/null) || (cd "$PROJECT_DIR" && docker-compose down 2>/dev/null) || true
}

wait_for_database_ready() {
    log "Waiting for DB READY..."
    local timeout=900
    local start
    start=$(date +%s)

    while true; do
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            log "DB reports READY"
            return 0
        fi
        local elapsed=$(($(date +%s) - start))
        if [ "$elapsed" -gt "$timeout" ]; then
            return 1
        fi
        sleep 10
    done
}

reset_db_password_in_container() {
    # This fixes the exact issue you hit: existing volume => ORACLE_PASSWORD ignored.
    log "$(get_text db_pass_fix)"
    docker exec oracle-apex-db resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 20
}

db_test_sysdba() {
    # returns 0 when ok
    docker exec oracle-apex-db bash -c "echo \"SET HEADING OFF FEEDBACK OFF; SELECT 'DB_OK' FROM DUAL;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -q "DB_OK"
}

fix_images_folder() {
    update_progress 84 "$(get_text images_fix)"
    log "Fixing images folder..."

    # Self-heal from old broken state: images/images/*
    if [ -d "$IMAGES_DIR/images" ] && [ -f "$IMAGES_DIR/images/apex_version.txt" ] && [ ! -f "$IMAGES_DIR/apex_version.txt" ]; then
        rm -rf "$IMAGES_DIR"/* 2>/dev/null || true
        cp -r "$IMAGES_DIR/images/"* "$IMAGES_DIR/" 2>/dev/null || true
        rm -rf "$IMAGES_DIR/images" 2>/dev/null || true
    fi

    # Ensure correct layout
    if [ -d "$PROJECT_DIR/apex/images" ]; then
        rm -rf "$IMAGES_DIR" 2>/dev/null || true
        mkdir -p "$IMAGES_DIR"
        cp -r "$PROJECT_DIR/apex/images/"* "$IMAGES_DIR/" 2>/dev/null || cp -r "$PROJECT_DIR/apex/images/." "$IMAGES_DIR/" 2>/dev/null
    fi

    # Ensure file exists
    if [ ! -f "$IMAGES_DIR/apex_version.txt" ]; then
        log "WARNING: apex_version.txt not found in $IMAGES_DIR"
    else
        log "Images OK: $IMAGES_DIR/apex_version.txt"
    fi
}

free_ords_port() {
    update_progress 83 "$(get_text port_fix)"

    # Stop any docker container that binds 8080 (except oracle-apex-db)
    local containers
    containers=$(docker ps --format '{{.Names}} {{.Ports}}' | awk -v p=":${ORDS_PORT}->" '$0 ~ p {print $1}' | grep -v '^oracle-apex-db$' || true)
    for c in $containers; do
        docker stop "$c" 2>/dev/null || true
        docker rm -f "$c" 2>/dev/null || true
    done

    # Kill any process on port 8080
    if command -v fuser &> /dev/null; then
        run_sudo fuser -k "${ORDS_PORT}/tcp" 2>/dev/null || true
    fi
}

configure_ords_static() {
    local ORDS_BIN
    ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
    chmod +x "$ORDS_BIN" 2>/dev/null || true

    # ORDS needs correct /i/ mapping.
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port "$ORDS_PORT" >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i/ >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true

    # Set encrypted secret for db password
    echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
}

start_ords_and_wait() {
    local ORDS_BIN
    ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)

    pkill -f ords 2>/dev/null || true
    sleep 3
    free_ords_port

    # Ensure log file is writable
    mkdir -p "$LOG_DIR" || true
    : > "$LOG_DIR/ords.log" 2>/dev/null || true

    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve --port "$ORDS_PORT" --apex-images "$IMAGES_DIR" > "$LOG_DIR/ords.log" 2>&1 &

    # Wait up to 6 minutes for ORDS + images
    local ok=false
    for i in $(seq 1 72); do
        local code_admin
        local code_img
        code_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null || echo "000")
        code_img=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/i/apex_version.txt" 2>/dev/null || echo "000")

        if [[ "$code_admin" =~ ^(200|301|302|303)$ ]] && [[ "$code_img" =~ ^(200|301|302|303)$ ]]; then
            ok=true
            break
        fi

        # If images not ok but admin is ok, still likely missing images mapping
        if [ "$i" -eq 25 ]; then
            fix_images_folder
            configure_ords_static
            pkill -f ords 2>/dev/null || true
            sleep 3
            nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve --port "$ORDS_PORT" --apex-images "$IMAGES_DIR" > "$LOG_DIR/ords.log" 2>&1 &
        fi

        sleep 5
    done

    $ok
}

#──────────────────────────────────────────────────────────────────────────────
# MANAGEMENT SCRIPTS
#──────────────────────────────────────────────────────────────────────────────
create_management_scripts() {
    mkdir -p "$SCRIPTS_DIR" "$LOG_DIR" 2>/dev/null || true

    cat > "$SCRIPTS_DIR/fix-images.sh" << 'EOF'
#!/bin/bash
set -e
PROJECT_DIR="$HOME/oracle-apex-complete"
IMAGES_DIR="$PROJECT_DIR/images"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
LOG_DIR="$PROJECT_DIR/logs"

echo "[fix-images] Fixing APEX images folder..."

# If images/images exists, flatten it
if [ -d "$IMAGES_DIR/images" ] && [ -f "$IMAGES_DIR/images/apex_version.txt" ] && [ ! -f "$IMAGES_DIR/apex_version.txt" ]; then
  rm -rf "$IMAGES_DIR"/*
  cp -r "$IMAGES_DIR/images/"* "$IMAGES_DIR/" || true
  rm -rf "$IMAGES_DIR/images"
fi

# Ensure correct images are copied from apex folder
if [ -d "$PROJECT_DIR/apex/images" ]; then
  rm -rf "$IMAGES_DIR"
  mkdir -p "$IMAGES_DIR"
  cp -r "$PROJECT_DIR/apex/images/"* "$IMAGES_DIR/" || cp -r "$PROJECT_DIR/apex/images/." "$IMAGES_DIR/"
fi

echo "[fix-images] Verifying apex_version.txt..."
if [ -f "$IMAGES_DIR/apex_version.txt" ]; then
  echo "OK: $IMAGES_DIR/apex_version.txt"
else
  echo "WARNING: apex_version.txt not found in $IMAGES_DIR"
fi

ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
chmod +x "$ORDS_BIN" 2>/dev/null || true

"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i/ || true
"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" || true

pkill -f ords 2>/dev/null || true
sleep 2

export ORDS_CONFIG="$ORDS_CONFIG_DIR"
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve --port 8080 --apex-images "$IMAGES_DIR" > "$LOG_DIR/ords.log" 2>&1 &

echo "[fix-images] Waiting 60s..."
sleep 60

code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null || echo 000)
echo "Images HTTP: $code"
EOF
    chmod +x "$SCRIPTS_DIR/fix-images.sh"

    cat > "$SCRIPTS_DIR/reset-db-password.sh" << 'EOF'
#!/bin/bash
set -e
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS_FILE="$PROJECT_DIR/.db_password"

read -r -p "Enter new Oracle DB password (letters/numbers, start with letter): " NEWPASS
if [[ ! "$NEWPASS" =~ ^[a-zA-Z][a-zA-Z0-9]{5,}$ ]]; then
  echo "Invalid password format"; exit 1
fi

echo "$NEWPASS" > "$PASS_FILE"
chmod 600 "$PASS_FILE"

docker exec oracle-apex-db resetPassword "$NEWPASS" || true
sleep 10

echo "Done. Now run: bash ~/oracle-apex-complete/scripts/fix.sh"
EOF
    chmod +x "$SCRIPTS_DIR/reset-db-password.sh"

    cat > "$SCRIPTS_DIR/start.sh" << 'EOF'
#!/bin/bash
set -e
PROJECT_DIR="$HOME/oracle-apex-complete"
LOG_DIR="$PROJECT_DIR/logs"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null || true)

mkdir -p "$LOG_DIR"

if [ -z "$PASS" ]; then
  echo "Password not found in $PROJECT_DIR/.db_password"; exit 1
fi

# Start DB
(docker start oracle-apex-db 2>/dev/null) || (cd "$PROJECT_DIR" && docker compose up -d 2>/dev/null) || true

echo "Waiting 150s for DB..."
sleep 150

# Ensure password matches container (important when volume exists)
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 10

# Fix images mapping
bash "$PROJECT_DIR/scripts/fix-images.sh" || true

# Start ORDS
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
chmod +x "$ORDS_BIN" 2>/dev/null || true

export ORDS_CONFIG="$ORDS_CONFIG_DIR"
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

pkill -f ords 2>/dev/null || true
sleep 2
nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$LOG_DIR/ords.log" 2>&1 &

echo "Waiting 90s for ORDS..."
sleep 90

HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo 000)
echo "APEX Admin HTTP: $HTTP_ADMIN"
echo "http://localhost:8080/ords/apex_admin"
EOF
    chmod +x "$SCRIPTS_DIR/start.sh"

    cat > "$SCRIPTS_DIR/stop.sh" << 'EOF'
#!/bin/bash
pkill -f ords 2>/dev/null || true
sleep 2
docker stop oracle-apex-db 2>/dev/null || true
echo "Stopped"
EOF
    chmod +x "$SCRIPTS_DIR/stop.sh"

    cat > "$SCRIPTS_DIR/status.sh" << 'EOF'
#!/bin/bash
echo "Database: $(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo false)"
if pgrep -f "ords.*serve" >/dev/null 2>&1; then
  echo "ORDS: running"
else
  echo "ORDS: stopped"
fi
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo 000)
HTTP_IMG=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null || echo 000)
echo "APEX Admin: HTTP $HTTP_ADMIN"
echo "Images:    HTTP $HTTP_IMG"
EOF
    chmod +x "$SCRIPTS_DIR/status.sh"

    cat > "$SCRIPTS_DIR/fix.sh" << 'EOF'
#!/bin/bash
set -e
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null || true)
LOG_DIR="$PROJECT_DIR/logs"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"

if [ -z "$PASS" ]; then
  echo "Password file not found: $PROJECT_DIR/.db_password"; exit 1
fi

mkdir -p "$LOG_DIR"

echo "[fix] Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 2

echo "[fix] Ensuring DB running..."
docker start oracle-apex-db 2>/dev/null || true
sleep 30

echo "[fix] Resetting DB password in container..."
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 10

echo "[fix] Fixing accounts + proxy..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[fix] Fixing images..."
bash "$PROJECT_DIR/scripts/fix-images.sh" || true

ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
chmod +x "$ORDS_BIN" 2>/dev/null || true

echo "$PASS" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true

export ORDS_CONFIG="$ORDS_CONFIG_DIR"
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$LOG_DIR/ords.log" 2>&1 &

echo "[fix] Waiting 120s..."
sleep 120

HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo 000)
HTTP_IMG=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null || echo 000)
echo "APEX Admin: HTTP $HTTP_ADMIN"
echo "Images:    HTTP $HTTP_IMG"
EOF
    chmod +x "$SCRIPTS_DIR/fix.sh"

    # Simple GUI Manager (stable zenity/yad)
    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'EOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
LOG_DIR="$PROJECT_DIR/logs"

GUI=""
command -v yad >/dev/null 2>&1 && GUI="yad"
command -v zenity >/dev/null 2>&1 && [ -z "$GUI" ] && GUI="zenity"

if [ -z "$GUI" ]; then
  echo "No GUI tool (yad/zenity) found"; exit 1
fi

check() {
  docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null | grep -q true || return 1
  pgrep -f "ords.*serve" >/dev/null 2>&1 || return 1
  return 0
}

status_text() {
  DB=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo false)
  ORDS=$(pgrep -f "ords.*serve" >/dev/null 2>&1 && echo true || echo false)
  HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo 000)
  HTTP_IMG=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null || echo 000)
  printf "Database: %s\nORDS: %s\n\nAPEX Admin HTTP: %s\nImages HTTP: %s\n\nhttp://localhost:8080/ords/apex_admin" "$DB" "$ORDS" "$HTTP_ADMIN" "$HTTP_IMG"
}

while true; do
  ICON="🔴"; check && ICON="🟢"

  if [ "$GUI" = "yad" ]; then
    CHOICE=$(yad --list --title="Oracle APEX Manager" --text="$ICON Select action:" \
      --radiolist --column="" --column="id" --column="Action" \
      TRUE start "Start" FALSE stop "Stop" FALSE fix "Fix" FALSE status "Status" FALSE open "Open Admin" FALSE logs "View ORDS Log" FALSE exit "Exit" \
      --hide-column=2 --print-column=2 --width=420 --height=320 2>/dev/null)
  else
    CHOICE=$(zenity --list --title="Oracle APEX Manager" --text="$ICON Select action:" \
      --radiolist --column="" --column="id" --column="Action" \
      TRUE start "Start" FALSE stop "Stop" FALSE fix "Fix" FALSE status "Status" FALSE open "Open Admin" FALSE logs "View ORDS Log" FALSE exit "Exit" \
      --hide-column=2 --width=420 --height=320 2>/dev/null)
  fi

  [ -z "$CHOICE" ] && exit 0

  case "$CHOICE" in
    start)
      bash "$SCRIPTS_DIR/start.sh" > /tmp/apex_start.txt 2>&1 || true
      ;;
    stop)
      bash "$SCRIPTS_DIR/stop.sh" > /tmp/apex_stop.txt 2>&1 || true
      ;;
    fix)
      bash "$SCRIPTS_DIR/fix.sh" > /tmp/apex_fix.txt 2>&1 || true
      ;;
    status)
      TXT=$(status_text)
      [ "$GUI" = "yad" ] && yad --info --title="Status" --text="$TXT" --width=520 --height=260 2>/dev/null
      [ "$GUI" = "zenity" ] && zenity --info --title="Status" --text="$TXT" --width=520 --height=260 2>/dev/null
      ;;
    open)
      xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || true
      ;;
    logs)
      [ -f "$LOG_DIR/ords.log" ] || echo "No log" > "$LOG_DIR/ords.log"
      [ "$GUI" = "yad" ] && yad --text-info --title="ORDS Log" --filename="$LOG_DIR/ords.log" --width=900 --height=650 --fontname="monospace" 2>/dev/null
      [ "$GUI" = "zenity" ] && zenity --text-info --title="ORDS Log" --filename="$LOG_DIR/ords.log" --width=900 --height=650 2>/dev/null
      ;;
    exit)
      exit 0
      ;;
  esac

done
EOF
    chmod +x "$SCRIPTS_DIR/launch-gui.sh"

    mkdir -p "$HOME/.local/share/applications" 2>/dev/null || true
    cat > "$HOME/.local/share/applications/oracle-apex.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle APEX Manager
Comment=Manage Oracle APEX - KaizenixCore
Exec=bash $SCRIPTS_DIR/launch-gui.sh
Icon=applications-database
Terminal=false
Categories=Development;Database;
EOF
    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop" 2>/dev/null || true
}

#──────────────────────────────────────────────────────────────────────────────
# INSTALL
#──────────────────────────────────────────────────────────────────────────────
run_installation() {
    ensure_permissions
    mkdir -p "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR/databases/default" "$ORDS_CONFIG_DIR/global" 2>/dev/null || true
    : > "$INSTALL_LOG" 2>/dev/null || true

    start_progress

    update_progress 2 "$(get_text step) 1/20: Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    ensure_permissions

    update_progress 5 "$(get_text step) 2/20: Installing dependencies..."
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

    update_progress 8 "$(get_text step) 3/20: Cleaning up previous installation..."

    # If old volume exists, ask user whether to remove it.
    local remove_data=0
    if docker volume ls --format '{{.Name}}' | grep -q "oracle-apex-complete_oracle-data" 2>/dev/null; then
        show_question_cleanup
        remove_data=$?
    fi

    pkill -f ords 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true
    docker rm -f oracle-apex-db 2>/dev/null || true
    compose_down

    if [ "$remove_data" -eq 0 ]; then
        docker volume rm oracle-apex-complete_oracle-data 2>/dev/null || true
        docker volume rm oracle-data 2>/dev/null || true
    fi

    update_progress 10 "$(get_text step) 4/20: Downloading APEX (may take time)..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ] || [ $(stat -c%s "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || echo 0) -lt 100000000 ]; then
        wget -q -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" >> "$INSTALL_LOG" 2>&1 || true
    fi

    update_progress 15 "$(get_text step) 5/20: Downloading ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ] || [ $(stat -c%s "$DOWNLOADS_DIR/ords-latest.zip" 2>/dev/null || echo 0) -lt 50000000 ]; then
        wget -q -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" >> "$INSTALL_LOG" 2>&1 || true
    fi

    update_progress 20 "$(get_text step) 6/20: Extracting files..."
    cd "$PROJECT_DIR"
    rm -rf apex ords
    unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" >> "$INSTALL_LOG" 2>&1
    mkdir -p ords && unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords >> "$INSTALL_LOG" 2>&1
    find ords -name "ords" -type f -exec chmod +x {} \; 2>/dev/null || true

    # FIX: prevent images/images bug
    fix_images_folder

    update_progress 23 "$(get_text step) 7/20: Creating Docker configuration..."
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

    update_progress 25 "$(get_text step) 8/20: $(get_text wait_db)"
    compose_up

    # Wait for DB ready
    if ! wait_for_database_ready; then
        stop_progress
        show_error "$(get_text error)" "Database did not become ready in time. Check docker logs oracle-apex-db"
        exit 1
    fi

    update_progress 33 "$(get_text step) 8/20: Ensuring password works..."

    # ALWAYS reset password (fixes volume reuse issue)
    reset_db_password_in_container

    # Test DB connection; if still fails, show guidance.
    if ! db_test_sysdba; then
        log "DB test failed - trying reset once more"
        show_info "$(get_text title)" "$(get_text db_pass_bad)"
        reset_db_password_in_container
        if ! db_test_sysdba; then
            stop_progress
            show_error "$(get_text error)" "Database password still failing.\n\nRecommended fix:\n1) Re-run installer and choose 'Remove data'\nOR\n2) docker exec oracle-apex-db resetPassword <pass>"
            exit 1
        fi
    fi

    update_progress 38 "$(get_text step) 9/20: Configuring DB policies..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 40 "$(get_text step) 10/20: Installing APEX (15-25 minutes)..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    # Ensure image prefix is /i/
    update_progress 52 "$(get_text step) 10/20: Resetting APEX image prefix..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@utilities/reset_image_prefix.sql
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 55 "$(get_text step) 11/20: Configuring APEX REST..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 60 "$(get_text step) 12/20: Creating database users..."
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

    update_progress 65 "$(get_text step) 13/20: Granting proxy authentication..."
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

    update_progress 70 "$(get_text step) 14/20: Creating APEX admin user..."

    local apex_schema
    apex_schema=$(docker exec oracle-apex-db bash -c "echo \"SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ')
    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"

    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
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

    update_progress 75 "$(get_text step) 15/20: Installing ORDS (5-10 minutes)..."

    local ORDS_BIN
    ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f | head -1)
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

    rm -f "$PASS_FILE"

    update_progress 80 "$(get_text step) 16/20: Configuring ORDS..."
    configure_ords_static

    update_progress 82 "$(get_text step) 17/20: Re-granting proxy permissions..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
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

    update_progress 85 "$(get_text step) 18/20: $(get_text wait_ords)"

    # Final fix for images before starting ORDS
    fix_images_folder
    configure_ords_static

    if ! start_ords_and_wait; then
        update_progress 94 "Auto-fix: restarting ORDS and images..."
        fix_images_folder
        configure_ords_static
        start_ords_and_wait || true
    fi

    update_progress 92 "$(get_text step) 19/20: Creating management scripts..."
    create_management_scripts

    update_progress 95 "$(get_text step) 20/20: Verifying installation..."
    sleep 10

    local http_admin
    local http_img
    http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null || echo "000")
    http_img=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/i/apex_version.txt" 2>/dev/null || echo "000")

    log "HTTP Admin: $http_admin, Images: $http_img"

    update_progress 100 "$(get_text completed)"
    sleep 2
    stop_progress
}

open_browser() {
    local url="http://localhost:${ORDS_PORT}/ords/apex_admin"
    xdg-open "$url" 2>/dev/null || true
    (command -v gio >/dev/null 2>&1 && gio open "$url" 2>/dev/null) || true
    (command -v x-www-browser >/dev/null 2>&1 && x-www-browser "$url" 2>/dev/null) || true
}

show_success() {
    local msg
    msg="✅ Oracle APEX installed successfully!\n\n🌐 Admin Panel:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\n🔐 Login Page:\nhttp://localhost:${ORDS_PORT}/ords/f?p=4550\n\n📋 Credentials:\nWorkspace: INTERNAL\nUsername: ADMIN\nPassword: (your password)\n\n🛠️ If you see 'APEX images not loaded':\nRun: bash ~/oracle-apex-complete/scripts/fix-images.sh"

    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$(get_text completed)" --text="$msg" --width=560 --height=420 --center --on-top \
            --button="$(get_text open_browser):0" --button="$(get_text exit):1" 2>/dev/null
        if [ $? -eq 0 ]; then
            open_browser
        fi
    else
        zenity --info --title="$(get_text completed)" --text="$msg" --width=560 --height=420 2>/dev/null
        open_browser
    fi
}

main() {
    install_gui_tool
    select_language
    show_info "$(get_text title)" "$(get_text welcome)"

    # Get sudo password once (graphically)
    get_sudo_password

    get_passwords

    run_installation

    show_success
}

main "$@"
