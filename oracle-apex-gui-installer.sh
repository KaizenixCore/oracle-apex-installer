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
#  ║     ORACLE APEX GUI INSTALLER v1.1.0 - KAIZENIXCORE (FINAL FIXED)         ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ║  License    : MIT                                                         ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  ✅ FINAL FIXES v1.1.0:                                                     ║
#  ║     - Beautiful Modern UI with Zenity/YAD                                 ║
#  ║     - Cross-Platform: Linux, macOS, Windows (WSL)                         ║
#  ║     - APEX Images Fix - SOLVED ✓                                          ║
#  ║     - Error 574/571/500 - FIXED ✓                                         ║
#  ║     - ORDS Binary Detection - FIXED ✓                                     ║
#  ║     - Password Parsing - FIXED ✓                                          ║
#  ║     - File Permissions - FIXED ✓                                          ║
#  ║     - Repair Mode for existing installations                              ║
#  ║     - Clean Install option                                                ║
#  ║     - Optional DBeaver installation                                       ║
#  ║     - Systemd service for auto-start                                      ║
#  ║     - Multi-language: English, فارسی, Deutsch                             ║
#  ║     - All management scripts included                                     ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -euo pipefail

VERSION="5.0.0"
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
CURRENT_LANG="en"
OS_TYPE=""

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_EN=(
    ["title"]="Oracle APEX Installer"
    ["subtitle"]="KaizenixCore Edition v5.0"
    ["welcome_title"]="🚀 Welcome to Oracle APEX Ultimate Installer"
    ["welcome"]="<b>Oracle APEX Ultimate Installer v5.0</b>\n\n<b>This will install:</b>\n• Oracle APEX (Latest Version)\n• Oracle ORDS (Latest Version)  \n• Oracle XE 21c Database\n\n<b>Features:</b>\n✅ Automatic configuration\n✅ Error auto-fix (574/571/500)\n✅ APEX images auto-setup\n✅ Management GUI included\n\n<b>Created by:</b> Peyman Rasouli\n<b>Project:</b> KaizenixCore\n\nClick <b>Continue</b> to start installation."
    ["enter_passwords"]="🔐 Enter Passwords"
    ["oracle_pass"]="Oracle Database Password:"
    ["apex_pass"]="APEX Admin Password:"
    ["pass_rules"]="<b>Password Rules:</b>\n• Start with a letter (a-z, A-Z)\n• Only letters and numbers\n• Minimum 6 characters\n\n<b>Example:</b> MyPass123"
    ["invalid_pass"]="<b>❌ Invalid Password!</b>\n\nPassword must:\n• Start with a letter\n• Contain only letters and numbers\n• Be at least 6 characters\n\nExample: Oracle123"
    ["installing"]="Installing Oracle APEX..."
    ["completed"]="✅ Installation Completed!"
    ["error"]="Error"
    ["open_browser"]="🌐 Open APEX"
    ["exit"]="Exit"
    ["continue"]="Continue"
    ["cancel"]="Cancel"
    ["sudo_pass"]="Enter your system password (sudo):"
    ["wait_db"]="Waiting for database to start..."
    ["wait_ords"]="Waiting for ORDS to start..."
    ["step"]="Step"
    ["of"]="of"
    ["cleanup_title"]="⚠️ Previous Installation Found"
    ["cleanup_q"]="<b>A previous installation was detected.</b>\n\nWhat would you like to do?\n\n<b>🔄 Repair:</b>\n• Keep existing data\n• Fix configuration issues\n• Recommended if APEX was working before\n\n<b>🗑️ Clean Install:</b>\n• Remove ALL old data\n• Fresh installation\n• Fixes password mismatch errors"
    ["repair"]="🔄 Repair"
    ["clean_install"]="🗑️ Clean Install"
    ["install_dbeaver_title"]="📦 Install DBeaver?"
    ["install_dbeaver_q"]="<b>DBeaver</b> is a free database management tool.\n\nWould you like to install it?\n\n• Easy database browsing\n• SQL editor\n• Works with Oracle, MySQL, PostgreSQL, etc."
    ["yes"]="Yes"
    ["no"]="No"
    ["create_service_title"]="🔧 Create Auto-Start Service?"
    ["create_service_q"]="<b>Would you like Oracle APEX to start automatically on boot?</b>\n\nThis will create a systemd service that:\n• Starts database on boot\n• Starts ORDS automatically\n• Runs in background"
    ["success_msg"]="<b>🎉 Oracle APEX installed successfully!</b>\n\n<b>🌐 Admin Panel:</b>\nhttp://localhost:8080/ords/apex_admin\n\n<b>🔐 Login Page:</b>\nhttp://localhost:8080/ords/f?p=4550\n\n<b>📋 Credentials:</b>\n   Workspace: <b>INTERNAL</b>\n   Username: <b>ADMIN</b>\n   Password: <b>%PASSWORD%</b>\n\n<b>🛠️ Management:</b>\n   GUI: bash ~/oracle-apex-complete/scripts/launch-gui.sh\n   Fix: bash ~/oracle-apex-complete/scripts/fix.sh"
    ["detecting_os"]="Detecting operating system..."
    ["os_linux"]="Linux detected"
    ["os_macos"]="macOS detected"
    ["os_windows"]="Windows (WSL) detected"
    ["installing_deps"]="Installing dependencies..."
    ["downloading"]="Downloading"
    ["extracting"]="Extracting files..."
    ["configuring"]="Configuring..."
    ["starting_db"]="Starting database..."
    ["installing_apex"]="Installing APEX (15-25 min)..."
    ["configuring_ords"]="Configuring ORDS..."
    ["fixing_images"]="Setting up APEX images..."
    ["creating_scripts"]="Creating management scripts..."
    ["verifying"]="Verifying installation..."
)

declare -A LANG_FA=(
    ["title"]="نصب‌کننده اوراکل اپکس"
    ["subtitle"]="نسخه KaizenixCore v5.0"
    ["welcome_title"]="🚀 به نصب‌کننده اوراکل اپکس خوش آمدید"
    ["welcome"]="<b>نصب‌کننده اوراکل اپکس نسخه 5.0</b>\n\n<b>این برنامه نصب می‌کند:</b>\n• Oracle APEX (آخرین نسخه)\n• Oracle ORDS (آخرین نسخه)\n• Oracle XE 21c Database\n\n<b>ویژگی‌ها:</b>\n✅ پیکربندی خودکار\n✅ رفع خودکار خطاها (574/571/500)\n✅ تنظیم خودکار تصاویر APEX\n✅ رابط گرافیکی مدیریت\n\n<b>سازنده:</b> پیمان رسولی\n<b>پروژه:</b> KaizenixCore\n\nبرای شروع نصب <b>ادامه</b> را بزنید."
    ["enter_passwords"]="🔐 ورود رمز عبور"
    ["oracle_pass"]="رمز عبور Oracle Database:"
    ["apex_pass"]="رمز عبور APEX Admin:"
    ["pass_rules"]="<b>قوانین رمز عبور:</b>\n• با حرف انگلیسی شروع شود\n• فقط حروف و اعداد\n• حداقل ۶ کاراکتر\n\n<b>مثال:</b> MyPass123"
    ["invalid_pass"]="<b>❌ رمز عبور نامعتبر!</b>\n\nرمز عبور باید:\n• با حرف انگلیسی شروع شود\n• فقط حروف و اعداد\n• حداقل ۶ کاراکتر\n\nمثال: Oracle123"
    ["installing"]="در حال نصب اوراکل اپکس..."
    ["completed"]="✅ نصب با موفقیت انجام شد!"
    ["error"]="خطا"
    ["open_browser"]="🌐 باز کردن APEX"
    ["exit"]="خروج"
    ["continue"]="ادامه"
    ["cancel"]="انصراف"
    ["sudo_pass"]="رمز عبور سیستم را وارد کنید:"
    ["wait_db"]="منتظر شروع دیتابیس..."
    ["wait_ords"]="منتظر شروع ORDS..."
    ["step"]="مرحله"
    ["of"]="از"
    ["cleanup_title"]="⚠️ نصب قبلی پیدا شد"
    ["cleanup_q"]="<b>یک نصب قبلی پیدا شد.</b>\n\nچه کاری می‌خواهید انجام دهید؟\n\n<b>🔄 تعمیر:</b>\n• نگه داشتن دیتای قبلی\n• رفع مشکلات پیکربندی\n• اگر APEX قبلاً کار می‌کرد پیشنهاد می‌شود\n\n<b>🗑️ نصب تمیز:</b>\n• حذف همه دیتای قبلی\n• نصب از صفر\n• رفع مشکل عدم تطابق رمز"
    ["repair"]="🔄 تعمیر"
    ["clean_install"]="🗑️ نصب تمیز"
    ["install_dbeaver_title"]="📦 نصب DBeaver؟"
    ["install_dbeaver_q"]="<b>DBeaver</b> یک ابزار رایگان مدیریت پایگاه داده است.\n\nآیا می‌خواهید نصب شود؟\n\n• مرور آسان پایگاه داده\n• ویرایشگر SQL\n• کار با Oracle، MySQL، PostgreSQL و..."
    ["yes"]="بله"
    ["no"]="خیر"
    ["create_service_title"]="🔧 ایجاد سرویس خودکار؟"
    ["create_service_q"]="<b>آیا می‌خواهید Oracle APEX هنگام روشن شدن سیستم خودکار اجرا شود؟</b>\n\nاین یک سرویس systemd ایجاد می‌کند که:\n• دیتابیس را هنگام بوت شروع می‌کند\n• ORDS را خودکار اجرا می‌کند\n• در پس‌زمینه اجرا می‌شود"
    ["success_msg"]="<b>🎉 اوراکل اپکس با موفقیت نصب شد!</b>\n\n<b>🌐 پنل مدیریت:</b>\nhttp://localhost:8080/ords/apex_admin\n\n<b>🔐 صفحه ورود:</b>\nhttp://localhost:8080/ords/f?p=4550\n\n<b>📋 اطلاعات ورود:</b>\n   Workspace: <b>INTERNAL</b>\n   Username: <b>ADMIN</b>\n   Password: <b>%PASSWORD%</b>\n\n<b>🛠️ مدیریت:</b>\n   GUI: bash ~/oracle-apex-complete/scripts/launch-gui.sh\n   Fix: bash ~/oracle-apex-complete/scripts/fix.sh"
    ["detecting_os"]="تشخیص سیستم عامل..."
    ["os_linux"]="لینوکس تشخیص داده شد"
    ["os_macos"]="macOS تشخیص داده شد"
    ["os_windows"]="ویندوز (WSL) تشخیص داده شد"
    ["installing_deps"]="نصب وابستگی‌ها..."
    ["downloading"]="دانلود"
    ["extracting"]="استخراج فایل‌ها..."
    ["configuring"]="پیکربندی..."
    ["starting_db"]="شروع دیتابیس..."
    ["installing_apex"]="نصب APEX (۱۵-۲۵ دقیقه)..."
    ["configuring_ords"]="پیکربندی ORDS..."
    ["fixing_images"]="تنظیم تصاویر APEX..."
    ["creating_scripts"]="ایجاد اسکریپت‌های مدیریتی..."
    ["verifying"]="بررسی نصب..."
)

declare -A LANG_DE=(
    ["title"]="Oracle APEX Installer"
    ["subtitle"]="KaizenixCore Edition v5.0"
    ["welcome_title"]="🚀 Willkommen beim Oracle APEX Installer"
    ["welcome"]="<b>Oracle APEX Ultimate Installer v5.0</b>\n\n<b>Dies wird installieren:</b>\n• Oracle APEX (Neueste Version)\n• Oracle ORDS (Neueste Version)\n• Oracle XE 21c Datenbank\n\n<b>Funktionen:</b>\n✅ Automatische Konfiguration\n✅ Auto-Fix für Fehler (574/571/500)\n✅ APEX Images Auto-Setup\n✅ Management GUI enthalten\n\n<b>Erstellt von:</b> Peyman Rasouli\n<b>Projekt:</b> KaizenixCore\n\nKlicken Sie <b>Weiter</b> um die Installation zu starten."
    ["enter_passwords"]="🔐 Passwörter eingeben"
    ["oracle_pass"]="Oracle Database Passwort:"
    ["apex_pass"]="APEX Admin Passwort:"
    ["pass_rules"]="<b>Passwortregeln:</b>\n• Beginnt mit Buchstaben (a-z, A-Z)\n• Nur Buchstaben und Zahlen\n• Mindestens 6 Zeichen\n\n<b>Beispiel:</b> MyPass123"
    ["invalid_pass"]="<b>❌ Ungültiges Passwort!</b>\n\nPasswort muss:\n• Mit Buchstaben beginnen\n• Nur Buchstaben/Zahlen\n• Mindestens 6 Zeichen\n\nBeispiel: Oracle123"
    ["installing"]="Oracle APEX wird installiert..."
    ["completed"]="✅ Installation abgeschlossen!"
    ["error"]="Fehler"
    ["open_browser"]="🌐 APEX öffnen"
    ["exit"]="Beenden"
    ["continue"]="Weiter"
    ["cancel"]="Abbrechen"
    ["sudo_pass"]="Geben Sie Ihr Systempasswort ein:"
    ["wait_db"]="Warten auf Datenbankstart..."
    ["wait_ords"]="Warten auf ORDS-Start..."
    ["step"]="Schritt"
    ["of"]="von"
    ["cleanup_title"]="⚠️ Vorherige Installation gefunden"
    ["cleanup_q"]="<b>Eine vorherige Installation wurde gefunden.</b>\n\nWas möchten Sie tun?\n\n<b>🔄 Reparieren:</b>\n• Bestehende Daten behalten\n• Konfigurationsprobleme beheben\n• Empfohlen wenn APEX vorher funktionierte\n\n<b>🗑️ Neuinstallation:</b>\n• ALLE alten Daten entfernen\n• Frische Installation\n• Behebt Passwort-Fehler"
    ["repair"]="🔄 Reparieren"
    ["clean_install"]="🗑️ Neuinstallation"
    ["install_dbeaver_title"]="📦 DBeaver installieren?"
    ["install_dbeaver_q"]="<b>DBeaver</b> ist ein kostenloses Datenbank-Management-Tool.\n\nMöchten Sie es installieren?\n\n• Einfaches Datenbank-Browsing\n• SQL Editor\n• Funktioniert mit Oracle, MySQL, PostgreSQL, etc."
    ["yes"]="Ja"
    ["no"]="Nein"
    ["create_service_title"]="🔧 Auto-Start Service erstellen?"
    ["create_service_q"]="<b>Möchten Sie, dass Oracle APEX beim Systemstart automatisch startet?</b>\n\nDies erstellt einen systemd Service der:\n• Datenbank beim Booten startet\n• ORDS automatisch startet\n• Im Hintergrund läuft"
    ["success_msg"]="<b>🎉 Oracle APEX erfolgreich installiert!</b>\n\n<b>🌐 Admin Panel:</b>\nhttp://localhost:8080/ords/apex_admin\n\n<b>🔐 Login Seite:</b>\nhttp://localhost:8080/ords/f?p=4550\n\n<b>📋 Anmeldedaten:</b>\n   Workspace: <b>INTERNAL</b>\n   Username: <b>ADMIN</b>\n   Password: <b>%PASSWORD%</b>\n\n<b>🛠️ Management:</b>\n   GUI: bash ~/oracle-apex-complete/scripts/launch-gui.sh\n   Fix: bash ~/oracle-apex-complete/scripts/fix.sh"
    ["detecting_os"]="Betriebssystem wird erkannt..."
    ["os_linux"]="Linux erkannt"
    ["os_macos"]="macOS erkannt"
    ["os_windows"]="Windows (WSL) erkannt"
    ["installing_deps"]="Abhängigkeiten werden installiert..."
    ["downloading"]="Herunterladen"
    ["extracting"]="Dateien werden extrahiert..."
    ["configuring"]="Konfigurieren..."
    ["starting_db"]="Datenbank wird gestartet..."
    ["installing_apex"]="APEX wird installiert (15-25 Min)..."
    ["configuring_ords"]="ORDS wird konfiguriert..."
    ["fixing_images"]="APEX Images werden eingerichtet..."
    ["creating_scripts"]="Management-Skripte werden erstellt..."
    ["verifying"]="Installation wird überprüft..."
)

get_text() {
    local key="$1"
    case $CURRENT_LANG in
        fa) echo "${LANG_FA[$key]:-${LANG_EN[$key]}}" ;;
        de) echo "${LANG_DE[$key]:-${LANG_EN[$key]}}" ;;
        *)  echo "${LANG_EN[$key]}" ;;
    esac
}

#═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
#═══════════════════════════════════════════════════════════════════════════════
safe_mkdir() {
    mkdir -p "$1" 2>/dev/null || sudo mkdir -p "$1" 2>/dev/null || true
    chmod 755 "$1" 2>/dev/null || sudo chmod 755 "$1" 2>/dev/null || true
}

safe_touch() {
    touch "$1" 2>/dev/null || sudo touch "$1" 2>/dev/null || true
    chmod 644 "$1" 2>/dev/null || sudo chmod 644 "$1" 2>/dev/null || true
}

log() {
    safe_mkdir "$PROJECT_DIR"
    safe_mkdir "$LOG_DIR"
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" >> "$INSTALL_LOG" 2>/dev/null || true
}

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            OS_TYPE="wsl"
        else
            OS_TYPE="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        OS_TYPE="windows"
    else
        OS_TYPE="linux"
    fi
    log "Detected OS: $OS_TYPE"
}

#═══════════════════════════════════════════════════════════════════════════════
# GUI TOOL DETECTION AND FUNCTIONS - FIXED
#═══════════════════════════════════════════════════════════════════════════════
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
        exit 1
    fi
}

show_info() {
    local title="$1"
    local text="$2"
    local width="${3:-600}"
    local height="${4:-450}"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$title" --text="$text" \
            --width=$width --height=$height --center \
            --button="$(get_text continue):0" \
            --borders=20 --text-align=left 2>/dev/null || true
    else
        zenity --info --title="$title" --text="$text" \
            --width=$width --height=$height --no-wrap 2>/dev/null || true
    fi
}

show_error() {
    local title="$1"
    local text="$2"
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="$title" --text="$text" \
            --width=500 --height=300 --center --borders=20 2>/dev/null || true
    else
        zenity --error --title="$title" --text="$text" \
            --width=500 --height=300 2>/dev/null || true
    fi
}

show_question() {
    local title="$1"
    local text="$2"
    local yes_label="${3:-$(get_text yes)}"
    local no_label="${4:-$(get_text no)}"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --question --title="$title" --text="$text" \
            --button="$yes_label:0" --button="$no_label:1" \
            --width=550 --height=400 --center --borders=20 2>/dev/null
        return $?
    else
        zenity --question --title="$title" --text="$text" \
            --ok-label="$yes_label" --cancel-label="$no_label" \
            --width=550 --height=400 2>/dev/null
        return $?
    fi
}

# FIXED: Language selection with proper parsing
select_language() {
    local result=""
    if [ "$GUI_TOOL" = "yad" ]; then
        result=$(yad --list --title="🌐 Select Language / انتخاب زبان / Sprache" \
            --text="<b>Select your preferred language:</b>\n<b>زبان مورد نظر خود را انتخاب کنید:</b>\n<b>Wählen Sie Ihre Sprache:</b>" \
            --radiolist --column="" --column="Code" --column="Language" \
            TRUE "en" "🇺🇸 English" \
            FALSE "fa" "🇮🇷 فارسی (Persian)" \
            FALSE "de" "🇩🇪 Deutsch (German)" \
            --width=450 --height=350 --center \
            --print-column=2 --hide-column=2 --borders=20 2>/dev/null) || true
        CURRENT_LANG=$(echo "$result" | tr -d '|' | tr -d ' ')
    else
        result=$(zenity --list --title="🌐 Select Language" \
            --text="Select your preferred language:\nزبان مورد نظر خود را انتخاب کنید:\nWählen Sie Ihre Sprache:" \
            --radiolist --column="" --column="Code" --column="Language" \
            TRUE "en" "🇺🇸 English" \
            FALSE "fa" "🇮🇷 فارسی (Persian)" \
            FALSE "de" "🇩🇪 Deutsch (German)" \
            --width=450 --height=350 --hide-column=2 2>/dev/null) || true
        CURRENT_LANG=$(echo "$result" | tr -d ' ')
    fi
    
    [ -z "$CURRENT_LANG" ] && CURRENT_LANG="en"
}

get_sudo_password() {
    if sudo -n true 2>/dev/null; then
        return 0
    fi

    local pass=""
    local attempts=0
    while [ $attempts -lt 3 ]; do
        if [ "$GUI_TOOL" = "yad" ]; then
            pass=$(yad --entry --title="$(get_text title)" \
                --text="<b>$(get_text sudo_pass)</b>" \
                --hide-text --width=450 --center --borders=20 2>/dev/null) || true
        else
            pass=$(zenity --password --title="$(get_text title)" 2>/dev/null) || true
        fi
        
        [ -z "$pass" ] && exit 0

        if echo "$pass" | sudo -S -k true 2>/dev/null; then
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

# FIXED: Password parsing for both zenity and yad
get_passwords() {
    local result=""
    while true; do
        if [ "$GUI_TOOL" = "yad" ]; then
            result=$(yad --form --title="$(get_text title) - $(get_text enter_passwords)" \
                --text="$(get_text pass_rules)" \
                --field="$(get_text oracle_pass):H" "" \
                --field="$(get_text apex_pass):H" "" \
                --width=550 --height=400 --center --borders=20 \
                --button="$(get_text cancel):1" --button="$(get_text continue):0" 2>/dev/null) || true
        else
            result=$(zenity --forms --title="$(get_text title)" \
                --text="$(get_text pass_rules)" \
                --add-password="$(get_text oracle_pass)" \
                --add-password="$(get_text apex_pass)" \
                --width=500 --height=350 2>/dev/null) || true
        fi
        
        [ -z "$result" ] && exit 0

        # Normalize: replace newlines with '|'
        local normalized
        normalized=$(echo "$result" | tr '\n' '|' | sed 's/|$//')

        ORACLE_PASSWORD=$(echo "$normalized" | cut -d'|' -f1)
        APEX_ADMIN_PASSWORD=$(echo "$normalized" | cut -d'|' -f2)

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

#═══════════════════════════════════════════════════════════════════════════════
# PROGRESS BAR - FIXED
#═══════════════════════════════════════════════════════════════════════════════
FIFO_FILE=""
PROGRESS_PID=""

start_progress() {
    FIFO_FILE="${TMPDIR:-/tmp}/oracle_apex_progress_$$"
    mkfifo "$FIFO_FILE" 2>/dev/null || true
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="$(get_text title)" --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel \
            --width=600 --height=180 --center --borders=20 < "$FIFO_FILE" 2>/dev/null &
        PROGRESS_PID=$!
    else
        zenity --progress --title="$(get_text title)" --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel \
            --width=600 --height=180 < "$FIFO_FILE" 2>/dev/null &
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
    [ -n "$PROGRESS_PID" ] && kill "$PROGRESS_PID" 2>/dev/null || true
    sleep 1
}

#═══════════════════════════════════════════════════════════════════════════════
# INSTALLATION CHECKS
#═══════════════════════════════════════════════════════════════════════════════
wait_for_database_ready() {
    log "Waiting for database..."
    local timeout=600
    local start_time=$(date +%s)
    
    while true; do
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            log "Database is READY"
            return 0
        fi
        
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        [ "$elapsed" -gt "$timeout" ] && { log "Database timeout"; return 1; }
        
        sleep 10
    done
}

check_previous_installation() {
    docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^oracle-apex-db$" && return 0
    docker volume ls --format '{{.Name}}' 2>/dev/null | grep -qi "oracle" && return 0
    [ -d "$PROJECT_DIR/apex" ] || [ -d "$PROJECT_DIR/ords" ] && return 0
    return 1
}

#═══════════════════════════════════════════════════════════════════════════════
# FIX APEX IMAGES
#═══════════════════════════════════════════════════════════════════════════════
fix_apex_images() {
    log "Fixing APEX images..."
    
    if [ ! -d "$IMAGES_DIR" ] || [ "$(find "$IMAGES_DIR" -type f 2>/dev/null | wc -l)" -lt 50 ]; then
        rm -rf "$IMAGES_DIR" 2>/dev/null || true
        if [ -d "$PROJECT_DIR/apex/images" ]; then
            cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR" 2>/dev/null || true
        fi
    fi
    chmod -R 755 "$IMAGES_DIR" 2>/dev/null || true

    local ORDS_BIN
    ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    if [ -n "$ORDS_BIN" ]; then
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" 2>/dev/null || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i 2>/dev/null || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" 2>/dev/null || true
    fi

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

    local APEX_SCHEMA
    APEX_SCHEMA=$(cat "$PROJECT_DIR/.apex_schema" 2>/dev/null)
    [ -z "$APEX_SCHEMA" ] && APEX_SCHEMA="APEX_240200"

    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" << SQL >/dev/null 2>&1 || true
BEGIN
    ${APEX_SCHEMA}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
EXIT;
SQL

    log "APEX images fixed"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE MANAGEMENT SCRIPTS
#═══════════════════════════════════════════════════════════════════════════════
create_scripts() {
    safe_mkdir "$SCRIPTS_DIR"
    safe_mkdir "$LOG_DIR"

    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
echo "════════════════════════════════════════════════════════════"
echo "  Oracle APEX Status"
echo "════════════════════════════════════════════════════════════"
echo ""
DB_RUN=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo "false")
[ "$DB_RUN" = "true" ] && echo "Database: 🟢 Running" || echo "Database: 🔴 Stopped"
pgrep -f "ords.*serve" >/dev/null 2>&1 && echo "ORDS:     🟢 Running" || echo "ORDS:     🔴 Stopped"
echo ""
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_IMG=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null || echo "000")
echo "APEX Admin: HTTP $HTTP_ADMIN"
echo "Images:     HTTP $HTTP_IMG"
echo ""
echo "URLs:"
echo "  http://localhost:8080/ords/apex_admin"
echo "  http://localhost:8080/ords/f?p=4550"
STATUSEOF
    chmod +x "$SCRIPTS_DIR/status.sh"

    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
echo "Stopping Oracle APEX..."
pkill -f ords 2>/dev/null || true
sleep 2
docker stop oracle-apex-db 2>/dev/null || true
echo "✅ Stopped"
STOPEOF
    chmod +x "$SCRIPTS_DIR/stop.sh"

    cat > "$SCRIPTS_DIR/start.sh" << 'STARTEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
[ -z "$PASS" ] && { echo "❌ Password file not found!"; exit 1; }
echo "Starting Oracle APEX..."
docker start oracle-apex-db 2>/dev/null || (cd "$PROJECT_DIR" && docker compose up -d 2>/dev/null) || true
echo "Waiting 90s for database..."
sleep 90
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 10
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << SQL
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQL" 2>/dev/null || true
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
[ -n "$ORDS_BIN" ] && echo "$PASS" | "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config secret --password-stdin db.password 2>/dev/null || true
pkill -f ords 2>/dev/null || true
sleep 3
if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG="$PROJECT_DIR/ords_config"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$PROJECT_DIR/logs/ords.log" 2>&1 &
fi
echo "Waiting 60s for ORDS..."
sleep 60
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
echo "APEX Admin: HTTP $HTTP"
echo "http://localhost:8080/ords/apex_admin"
STARTEOF
    chmod +x "$SCRIPTS_DIR/start.sh"

    cat > "$SCRIPTS_DIR/fix.sh" << 'FIXEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
[ -z "$PASS" ] && { echo "❌ Password file not found!"; exit 1; }
echo "════════════════════════════════════════════════════════════"
echo "  FIX SCRIPT - Fixing Error 574/571/500/Images"
echo "════════════════════════════════════════════════════════════"
echo "[1/8] Stopping ORDS..."
pkill -f ords 2>/dev/null || true
sleep 3
echo "[2/8] Starting database..."
docker start oracle-apex-db 2>/dev/null || true
sleep 60
echo "[3/8] Resetting database password..."
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 15
echo "[4/8] Fixing database users..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << SQL
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
echo "[5/8] Fixing ORDS password..."
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
[ -n "$ORDS_BIN" ] && echo "$PASS" | "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config secret --password-stdin db.password 2>/dev/null || true
echo "[6/8] Fixing images..."
rm -rf "$PROJECT_DIR/images" 2>/dev/null || true
[ -d "$PROJECT_DIR/apex/images" ] && cp -r "$PROJECT_DIR/apex/images" "$PROJECT_DIR/images"
chmod -R 755 "$PROJECT_DIR/images" 2>/dev/null || true
if [ -n "$ORDS_BIN" ]; then
    "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config set standalone.static.path "$PROJECT_DIR/images" 2>/dev/null || true
    "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config set standalone.static.context.path /i 2>/dev/null || true
fi
echo "[7/8] Setting IMAGE_PREFIX..."
APEX_SCHEMA=$(cat "$PROJECT_DIR/.apex_schema" 2>/dev/null)
[ -z "$APEX_SCHEMA" ] && APEX_SCHEMA="APEX_240200"
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << SQLEOF
BEGIN
    ${APEX_SCHEMA}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
EXIT;
SQLEOF" 2>/dev/null || true
echo "[8/8] Starting ORDS..."
if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG="$PROJECT_DIR/ords_config"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$PROJECT_DIR/logs/ords.log" 2>&1 &
fi
sleep 90
echo ""
echo "════════════════════════════════════════════════════════════"
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_IMG=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null || echo "000")
echo "APEX Admin: HTTP $HTTP_ADMIN"
echo "Images:     HTTP $HTTP_IMG"
if [[ "$HTTP_ADMIN" =~ ^(200|302|303)$ ]] && [[ "$HTTP_IMG" =~ ^(200|304)$ ]]; then
    echo ""
    echo "✅ APEX is working with images!"
    echo "   http://localhost:8080/ords/apex_admin"
else
    echo ""
    echo "⚠️ May need more time. Wait 2 minutes and refresh browser."
fi
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh"

    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
GUI=""
command -v yad >/dev/null 2>&1 && GUI="yad"
command -v zenity >/dev/null 2>&1 && [ -z "$GUI" ] && GUI="zenity"
[ -z "$GUI" ] && { echo "No GUI tool found"; exit 1; }
while true; do
    DB_RUN=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo "false")
    ORDS_RUN="false"
    pgrep -f "ords.*serve" >/dev/null 2>&1 && ORDS_RUN="true"
    [ "$DB_RUN" = "true" ] && [ "$ORDS_RUN" = "true" ] && ICON="🟢" || ICON="🔴"
    if [ "$GUI" = "yad" ]; then
        CHOICE=$(yad --list --title="Oracle APEX Manager $ICON" \
            --text="<b>Status:</b> Database=$DB_RUN, ORDS=$ORDS_RUN\n\n<b>Select action:</b>" \
            --column="ID" --column="Action" \
            "start" "▶️  Start Services" \
            "stop" "⏹️  Stop Services" \
            "fix" "🔧  Fix Problems" \
            "status" "📊  Check Status" \
            "open" "🌐  Open Admin Panel" \
            "login" "🔑  Open Login Page" \
            "logs" "📜  View Logs" \
            "exit" "❌  Exit" \
            --width=500 --height=450 --center --borders=20 2>/dev/null) || true
    else
        CHOICE=$(zenity --list --title="Oracle APEX Manager $ICON" \
            --text="Status: Database=$DB_RUN, ORDS=$ORDS_RUN\n\nSelect action:" \
            --radiolist --column="" --column="id" --column="Action" \
            TRUE start "▶️  Start Services" \
            FALSE stop "⏹️  Stop Services" \
            FALSE fix "🔧  Fix Problems" \
            FALSE status "📊  Check Status" \
            FALSE open "🌐  Open Browser" \
            FALSE logs "📜  View Logs" \
            FALSE exit "❌  Exit" \
            --hide-column=2 --width=500 --height=450 2>/dev/null) || true
    fi
    [ -z "$CHOICE" ] && exit 0
    case "$CHOICE" in
        "start") bash "$SCRIPTS_DIR/start.sh" ;;
        "stop") bash "$SCRIPTS_DIR/stop.sh" ;;
        "fix") bash "$SCRIPTS_DIR/fix.sh" ;;
        "status") bash "$SCRIPTS_DIR/status.sh"; read -p "Press Enter..." ;;
        "open") xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || true ;;
        "login") xdg-open "http://localhost:8080/ords/f?p=4550" 2>/dev/null || true ;;
        "logs") tail -100 "$PROJECT_DIR/logs/ords.log" 2>/dev/null | less ;;
        "exit") exit 0 ;;
    esac
done
GUIEOF
    chmod +x "$SCRIPTS_DIR/launch-gui.sh"

    safe_mkdir "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/oracle-apex.desktop" << DESKTOPEOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle APEX Manager
Comment=Manage Oracle APEX - KaizenixCore v${VERSION}
Exec=bash $SCRIPTS_DIR/launch-gui.sh
Icon=applications-database
Terminal=false
Categories=Development;Database;
DESKTOPEOF
    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"

    log "Management scripts created"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE SYSTEMD SERVICE
#═══════════════════════════════════════════════════════════════════════════════
create_systemd_service() {
    if [ "$OS_TYPE" != "linux" ]; then
        return 0
    fi
    local ORDS_BIN
    ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    [ -z "$ORDS_BIN" ] && return 1

    run_sudo tee /etc/systemd/system/oracle-apex-db.service > /dev/null << DBSERVICEEOF
[Unit]
Description=Oracle APEX Database Container
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start oracle-apex-db
ExecStop=/usr/bin/docker stop oracle-apex-db
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
DBSERVICEEOF

    run_sudo tee /etc/systemd/system/oracle-apex-ords.service > /dev/null << ORDSSERVICEEOF
[Unit]
Description=Oracle APEX ORDS Service
After=oracle-apex-db.service
Requires=oracle-apex-db.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment="ORDS_CONFIG=$ORDS_CONFIG_DIR"
Environment="_JAVA_OPTIONS="-Xms512m -Xmx1024m"
ExecStartPre=/bin/sleep 60
ExecStart=$ORDS_BIN --config $ORDS_CONFIG_DIR serve --port $ORDS_PORT --apex-images $IMAGES_DIR
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
ORDSSERVICEEOF

    run_sudo systemctl daemon-reload
    run_sudo systemctl enable oracle-apex-db.service
    run_sudo systemctl enable oracle-apex-ords.service

    log "Systemd services created"
}

#═══════════════════════════════════════════════════════════════════════════════
# INSTALL DBEAVER
#═══════════════════════════════════════════════════════════════════════════════
install_dbeaver() {
    log "Installing DBeaver..."
    case "$OS_TYPE" in
        linux|wsl)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    ubuntu|debian|linuxmint|pop)
                        wget -q -O /tmp/dbeaver.gpg.key https://dbeaver.io/debs/dbeaver.gpg.key 2>/dev/null || true
                        run_sudo apt-key add /tmp/dbeaver.gpg.key 2>/dev/null || true
                        echo "deb https://dbeaver.io/debs/dbeaver-ce /" | run_sudo tee /etc/apt/sources.list.d/dbeaver.list > /dev/null
                        run_sudo apt-get update -qq || true
                        run_sudo apt-get install -y dbeaver-ce || true
                        rm -f /tmp/dbeaver.gpg.key
                        ;;
                    fedora)
                        run_sudo dnf install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm || true
                        ;;
                    arch|manjaro)
                        run_sudo pacman -S --noconfirm dbeaver || true
                        ;;
                    *)
                        wget -O /tmp/dbeaver.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" 2>/dev/null || true
                        run_sudo dpkg -i /tmp/dbeaver.deb || run_sudo apt-get install -f -y || true
                        rm -f /tmp/dbeaver.deb
                        ;;
                esac
            fi
            ;;
        macos)
            if command -v brew &> /dev/null; then
                brew install --cask dbeaver-community
            else
                echo "Please install DBeaver manually from: https://dbeaver.io/download/"
            fi
            ;;
    esac
    log "DBeaver installation completed"
}

#═══════════════════════════════════════════════════════════════════════════════
# MAIN INSTALLATION - COMPLETE & FIXED
#═══════════════════════════════════════════════════════════════════════════════
run_installation() {
    safe_mkdir "$PROJECT_DIR"
    safe_mkdir "$DOWNLOADS_DIR"
    safe_mkdir "$LOG_DIR"
    safe_mkdir "$IMAGES_DIR"
    safe_mkdir "$SCRIPTS_DIR"
    safe_mkdir "$ORDS_CONFIG_DIR"
    safe_mkdir "$ORDS_CONFIG_DIR/databases/default"
    safe_mkdir "$ORDS_CONFIG_DIR/global"
    safe_touch "$INSTALL_LOG"
    
    # FIXED: Proper log file permissions
    touch "$LOG_DIR/ords.log" 2>/dev/null || true
    chmod 666 "$LOG_DIR/ords.log" 2>/dev/null || true

    log "Installation started - v$VERSION"

    local install_mode="clean"
    if check_previous_installation; then
        if show_question "$(get_text cleanup_title)" "$(get_text cleanup_q)" \
                         "$(get_text repair)" "$(get_text clean_install)"; then
            install_mode="repair"
            log "Repair mode selected"
        else
            install_mode="clean"
            log "Clean install mode selected"
        fi
    fi

    start_progress

    # Step 1: Save passwords
    update_progress 2 "$(get_text step) 1/22: Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    log "Passwords saved"

    # Step 2: Cleanup
    update_progress 5 "$(get_text step) 2/22: Preparing environment..."
    pkill -f ords 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true

    if [ "$install_mode" = "clean" ]; then
        docker rm -f oracle-apex-db 2>/dev/null || true
        docker volume rm oracle-apex-complete_oracle-data 2>/dev/null || true
        docker volume rm oracle-data 2>/dev/null || true
        rm -rf "$PROJECT_DIR/apex" "$PROJECT_DIR/ords" 2>/dev/null || true
    fi
    log "Cleanup done"

    # Step 3: Install dependencies
    update_progress 8 "$(get_text step) 3/22: $(get_text installing_deps)"
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
    run_sudo usermod -aG docker $USER 2>/dev/null || true
    log "Dependencies installed"

    # Step 4: Download APEX
    update_progress 12 "$(get_text step) 4/22: $(get_text downloading) APEX..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || true
    fi
    log "APEX downloaded"

    # Step 5: Download ORDS
    update_progress 18 "$(get_text step) 5/22: $(get_text downloading) ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || true
    fi
    log "ORDS downloaded"

    # Step 6: Extract - FIXED: Proper ORDS binary detection
    update_progress 22 "$(get_text step) 6/22: $(get_text extracting)"
    cd "$PROJECT_DIR" || exit 1

    if [ ! -d "$PROJECT_DIR/apex" ] || [ "$install_mode" = "clean" ]; then
        rm -rf apex 2>/dev/null || true
        unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || true
    fi

    if [ ! -d "$PROJECT_DIR/ords/bin" ] || [ "$install_mode" = "clean" ]; then
        rm -rf ords 2>/dev/null || true
        mkdir -p ords
        unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords 2>/dev/null || true
    fi

    find ords -name "ords" -type f -exec chmod +x {} \; 2>/dev/null || true

    # FIXED: Verify ORDS binary exists
    if [ ! -f "$PROJECT_DIR/ords/bin/ords" ]; then
        log "ERROR: ORDS binary not found after extraction!"
        ls -la "$PROJECT_DIR/ords/bin/" 2>/dev/null || true
    fi

    rm -rf "$IMAGES_DIR" 2>/dev/null || true
    [ -d "$PROJECT_DIR/apex/images" ] && cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR" 2>/dev/null || true
    chmod -R 755 "$IMAGES_DIR" 2>/dev/null || true
    log "Files extracted, images copied"

    # Step 7: Docker Compose
    update_progress 25 "$(get_text step) 7/22: Creating Docker configuration..."
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
    update_progress 28 "$(get_text step) 8/22: $(get_text starting_db)"
    cd "$PROJECT_DIR" || exit 1
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || true

    wait_for_database_ready || log "Database wait timeout, continuing..."
    sleep 60
    log "Database started"

    # Step 9: Reset password
    update_progress 32 "$(get_text step) 9/22: Setting database password..."
    docker exec oracle-apex-db resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 20
    log "Password reset"

    # Step 10: Disable password policies
    update_progress 35 "$(get_text step) 10/22: $(get_text configuring)"
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Policies disabled"

    # Step 11: Install APEX
    update_progress 38 "$(get_text step) 11/22: $(get_text installing_apex)"
    local apex_installed=$(docker exec oracle-apex-db bash -c "echo \"SELECT COUNT(*) FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%';\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -E "^[[:space:]]*[0-9]+" | head -1 | tr -d ' ') || true
    
    if [ -n "$apex_installed" ] && [ "$apex_installed" -gt 0 ] 2>/dev/null && [ "$install_mode" = "repair" ]; then
        log "APEX already installed, skipping installation"
    else
        docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
        log "APEX installed"
    fi

    # Step 12: Reset image prefix
    update_progress 52 "$(get_text step) 12/22: $(get_text fixing_images)"
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
@utilities/reset_image_prefix.sql
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Image prefix reset"

    # Step 13: APEX REST config
    update_progress 55 "$(get_text step) 13/22: Configuring REST services..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "REST configured"

    # Step 14: Create users
    update_progress 58 "$(get_text step) 14/22: Creating database users..."
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
    update_progress 62 "$(get_text step) 15/22: Granting proxy permissions..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Proxy granted"

    # Step 16: Create APEX admin
    update_progress 66 "$(get_text step) 16/22: Creating APEX admin..."
    local apex_schema
    apex_schema=$(docker exec oracle-apex-db bash -c "echo \"SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ') || true
    
    [ -z "$apex_schema" ] && apex_schema="APEX_240200"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"

    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
BEGIN
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('WALLET_TYPE', 'NONE');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('RESTFUL_SERVICES_ENABLED', 'Y');
    ${apex_schema}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    BEGIN
        ${apex_schema}.APEX_UTIL.CREATE_USER(
            p_user_name => 'ADMIN',
            p_email_address => 'admin@localhost',
            p_web_password => '${APEX_ADMIN_PASSWORD}',
            p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
            p_change_password_on_first_use => 'N',
            p_account_locked => 'N'
        );
    EXCEPTION WHEN OTHERS THEN
        ${apex_schema}.APEX_UTIL.EDIT_USER(
            p_user_id => ${apex_schema}.APEX_UTIL.GET_USER_ID('ADMIN'),
            p_user_name => 'ADMIN',
            p_web_password => '${APEX_ADMIN_PASSWORD}',
            p_new_password => '${APEX_ADMIN_PASSWORD}',
            p_change_password_on_first_use => 'N',
            p_account_locked => 'N'
        );
    END;
    COMMIT;
END;
/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "APEX admin created"

    # Step 17: Install ORDS
    update_progress 70 "$(get_text step) 17/22: Installing ORDS..."
    local ORDS_BIN
    ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

    if [ -n "$ORDS_BIN" ]; then
        chmod +x "$ORDS_BIN" 2>/dev/null || true

        local PASS_FILE=$(mktemp)
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
    fi
    log "ORDS installed"

    # Step 18: Configure ORDS
    update_progress 75 "$(get_text step) 18/22: $(get_text configuring_ords)"
    if [ -n "$ORDS_BIN" ]; then
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port "$ORDS_PORT" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set security.requestValidationFunction "wwv_flow_epg_include_modules.authorize" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.context.path /ords >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    fi

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
    log "ORDS configured"

    # Step 19: Final configuration
    update_progress 80 "$(get_text step) 19/22: Final configuration..."
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
    update_progress 85 "$(get_text step) 20/22: $(get_text wait_ords)"
    pkill -f ords 2>/dev/null || true
    sleep 3
    run_sudo fuser -k "${ORDS_PORT}/tcp" 2>/dev/null || true

    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

    if [ -n "$ORDS_BIN" ]; then
        nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
            --port "$ORDS_PORT" \
            --apex-images "$IMAGES_DIR" \
            > "$LOG_DIR/ords.log" 2>&1 &
        log "ORDS starting with PID $! and --apex-images $IMAGES_DIR"
    fi

    update_progress 88 "Waiting for ORDS to start (2 minutes)..."
    sleep 120

    # Step 21: Create management scripts
    update_progress 92 "$(get_text step) 21/22: $(get_text creating_scripts)"
    create_scripts
    log "Scripts created"

    # Step 22: Verify installation
    update_progress 95 "$(get_text step) 22/22: $(get_text verifying)"
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null || echo "000")
    local http_img=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/i/apex_version.txt" 2>/dev/null || echo "000")
    local http_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/f?p=4550" 2>/dev/null || echo "000")
    log "HTTP Admin: $http_admin, Images: $http_img, Login: $http_login"

    if [[ ! "$http_img" =~ ^(200|304)$ ]]; then
        log "Images not working, running fix..."
        fix_apex_images
    fi

    update_progress 100 "$(get_text completed)"
    sleep 2
    stop_progress

    log "Installation completed successfully"
}

#═══════════════════════════════════════════════════════════════════════════════
# POST-INSTALLATION OPTIONS
#═══════════════════════════════════════════════════════════════════════════════
post_installation() {
    if [ "$OS_TYPE" = "linux" ]; then
        if show_question "$(get_text create_service_title)" "$(get_text create_service_q)" \
                         "$(get_text yes)" "$(get_text no)"; then
            create_systemd_service
            log "Systemd service created"
        fi
    fi

    if show_question "$(get_text install_dbeaver_title)" "$(get_text install_dbeaver_q)" \
                     "$(get_text yes)" "$(get_text no)"; then
        install_dbeaver
        log "DBeaver installed"
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# SHOW SUCCESS MESSAGE
#═══════════════════════════════════════════════════════════════════════════════
show_success() {
    local msg=$(get_text success_msg)
    msg="${msg//%PASSWORD%/$APEX_ADMIN_PASSWORD}"

    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$(get_text completed)" --text="$msg" \
            --width=650 --height=550 --center --borders=20 \
            --button="$(get_text open_browser):0" --button="$(get_text exit):1" 2>/dev/null
        local btn_result=$?
        if [ $btn_result -eq 0 ]; then
            xdg-open "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null &
        fi
    else
        zenity --info --title="$(get_text completed)" --text="$msg" \
            --width=650 --height=550 --no-wrap 2>/dev/null || true

        if show_question "$(get_text title)" "Open APEX in browser now?" \
                         "$(get_text yes)" "$(get_text no)"; then
            xdg-open "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null &
        fi
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# MAIN FUNCTION
#═══════════════════════════════════════════════════════════════════════════════
main() {
    detect_os
    install_gui_tool
    select_language
    show_info "$(get_text welcome_title)" "$(get_text welcome)" 650 550
    get_sudo_password
    get_passwords
    run_installation
    post_installation
    show_success
}

#═══════════════════════════════════════════════════════════════════════════════
# RUN MAIN
#═══════════════════════════════════════════════════════════════════════════════
main "$@"
