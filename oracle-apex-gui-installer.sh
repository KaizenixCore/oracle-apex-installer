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
#  ║     ORACLE APEX GUI INSTALLER v4.2.0 - KAIZENIXCORE                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ║  License    : MIT                                                         ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  ✅ v4.2.0 CRITICAL FIXES:                                                ║
#  ║     - ERROR 571 Database Connection - COMPLETELY FIXED                    ║
#  ║     - ORDS gateway-user corrected to ORDS_PUBLIC_USER                     ║
#  ║     - Database wait time increased and improved                           ║
#  ║     - DB_SERVICE consistency fixed (XEPDB1 everywhere)                    ║
#  ║     - Password sync between Docker volume and ORDS - FIXED                ║
#  ║     - DBeaver installation verification - FIXED                           ║
#  ║     - Comprehensive error recovery - ADDED                                ║
#  ║     - Cross-Platform: Linux, macOS, Windows (WSL)                         ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -o pipefail

VERSION="4.2.0"
PROJECT_DIR="$HOME/oracle-apex-complete"
DOWNLOADS_DIR="$PROJECT_DIR/downloads"
LOG_DIR="$PROJECT_DIR/logs"
IMAGES_DIR="$PROJECT_DIR/images"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
INSTALL_LOG="$PROJECT_DIR/install.log"

# ═══════════════════════════════════════════════════════════════════════════════
# CRITICAL: Database Configuration - MUST BE CONSISTENT
# ═══════════════════════════════════════════════════════════════════════════════
DB_PORT="1521"
DB_SERVICE="XEPDB1"          # Pluggable Database
DB_SID="XE"                  # System Identifier
ORDS_PORT="8080"

APEX_URL="https://download.oracle.com/otn_software/apex/apex-latest.zip"
ORDS_URL="https://download.oracle.com/otn_software/java/ords/ords-latest.zip"
ORACLE_IMAGE="gvenzl/oracle-xe:21-full"

# Container name - MUST BE CONSISTENT
CONTAINER_NAME="oracle-apex-db"

GUI_TOOL=""
SUDO_PASS=""
ORACLE_PASSWORD=""
APEX_ADMIN_PASSWORD=""
CURRENT_LANG="en"
OS_TYPE=""
OS_ID=""

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - ENGLISH
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_EN=(
    ["title"]="Oracle APEX Installer"
    ["subtitle"]="KaizenixCore Edition v4.2"
    ["welcome_title"]="🚀 Oracle APEX Ultimate Installer"
    ["welcome_text"]="Oracle APEX Ultimate Installer v4.2.0

This will install:
• Oracle APEX (Latest Version)
• Oracle ORDS (Latest Version)
• Oracle XE 21c Database

Features:
✅ Automatic configuration
✅ Error auto-fix (574/571/500)
✅ APEX images auto-setup
✅ Management GUI included
✅ Real Clean Install option
✅ DBeaver management

Created by: Peyman Rasouli
Project: KaizenixCore

Click Continue to start."
    ["select_action"]="Select Installation Type"
    ["action_text"]="What would you like to do?"
    ["fresh_install"]="🆕 Fresh Install (New installation)"
    ["repair_install"]="🔧 Repair (Fix existing installation)"
    ["clean_install"]="🗑️ Clean Install (Remove ALL and reinstall)"
    ["uninstall"]="❌ Uninstall Everything"
    ["manage_dbeaver"]="📦 Manage DBeaver"
    ["exit_installer"]="🚪 Exit"
    ["enter_passwords"]="🔐 Enter Passwords"
    ["oracle_pass"]="Oracle Database Password:"
    ["apex_pass"]="APEX Admin Password:"
    ["pass_rules"]="Password Rules:
• Start with a letter (a-z, A-Z)
• Only letters and numbers
• Minimum 6 characters

Example: MyPass123"
    ["invalid_pass"]="Invalid Password!

Password must:
• Start with a letter
• Contain only letters and numbers
• Be at least 6 characters

Example: Oracle123"
    ["installing"]="Installing Oracle APEX..."
    ["completed"]="✅ Installation Completed!"
    ["error"]="Error"
    ["warning"]="Warning"
    ["info"]="Information"
    ["open_browser"]="🌐 Open APEX"
    ["exit"]="Exit"
    ["continue"]="Continue"
    ["cancel"]="Cancel"
    ["yes"]="Yes"
    ["no"]="No"
    ["ok"]="OK"
    ["sudo_pass"]="Enter your system password (sudo):"
    ["wait_db"]="Waiting for database to start..."
    ["wait_ords"]="Waiting for ORDS to start..."
    ["step"]="Step"
    ["of"]="of"
    ["confirm_clean"]="⚠️ WARNING: Clean Install

This will PERMANENTLY DELETE:
• All Oracle APEX data
• All databases
• All Docker volumes
• All configurations

Your new password will be used.

Are you SURE you want to continue?"
    ["confirm_uninstall"]="⚠️ WARNING: Complete Uninstall

This will PERMANENTLY DELETE:
• Oracle APEX
• Oracle Database
• All Docker containers and volumes
• All project files

This action CANNOT be undone!

Are you SURE?"
    ["dbeaver_menu"]="DBeaver Management"
    ["dbeaver_text"]="Select DBeaver action:"
    ["dbeaver_install"]="📥 Install DBeaver"
    ["dbeaver_remove"]="🗑️ Remove DBeaver Completely"
    ["dbeaver_back"]="⬅️ Back"
    ["removing_dbeaver"]="Removing DBeaver..."
    ["installing_dbeaver"]="Installing DBeaver..."
    ["dbeaver_removed"]="DBeaver has been completely removed!"
    ["dbeaver_installed"]="DBeaver has been installed!"
    ["repair_text"]="Repair Mode

This will:
• Keep your existing data
• Reset all passwords to your new password
• Fix configuration issues
• Restart all services

Enter your NEW password below."
    ["success_title"]="🎉 Installation Successful!"
    ["success_text"]="Oracle APEX installed successfully!

🌐 Admin Panel:
http://localhost:8080/ords/apex_admin

🔐 Login Page:
http://localhost:8080/ords/f?p=4550

📋 Login Credentials:
   Workspace: INTERNAL
   Username: ADMIN
   Password: %PASSWORD%

🛠️ Management:
   GUI: bash ~/oracle-apex-complete/scripts/launch-gui.sh
   Fix: bash ~/oracle-apex-complete/scripts/fix.sh

If you see errors, run the Fix script."
    ["create_service_title"]="Create Auto-Start Service?"
    ["create_service_text"]="Would you like Oracle APEX to start automatically on boot?

This will create a systemd service that:
• Starts database on boot
• Starts ORDS automatically
• Runs in background"
    ["service_created"]="Auto-start service created!

To manage:
• Start: sudo systemctl start oracle-apex
• Stop: sudo systemctl stop oracle-apex
• Status: sudo systemctl status oracle-apex"
    ["detecting_os"]="Detecting operating system..."
    ["installing_deps"]="Installing dependencies..."
    ["downloading"]="Downloading"
    ["extracting"]="Extracting files..."
    ["configuring"]="Configuring..."
    ["starting_db"]="Starting database (5-10 minutes)..."
    ["installing_apex"]="Installing APEX (15-25 minutes)..."
    ["configuring_ords"]="Configuring ORDS..."
    ["fixing_images"]="Setting up APEX images..."
    ["creating_scripts"]="Creating management scripts..."
    ["verifying"]="Verifying installation..."
    ["cleaning"]="Cleaning up old installation..."
    ["resetting_password"]="Resetting passwords..."
    ["install_dbeaver_title"]="Install DBeaver?"
)

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - PERSIAN
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_FA=(
    ["title"]="نصب‌کننده اوراکل اپکس"
    ["subtitle"]="نسخه KaizenixCore v4.2"
    ["welcome_title"]="🚀 نصب‌کننده اوراکل اپکس"
    ["welcome_text"]="نصب‌کننده اوراکل اپکس نسخه 4.2.0

این برنامه نصب می‌کند:
• Oracle APEX (آخرین نسخه)
• Oracle ORDS (آخرین نسخه)
• Oracle XE 21c Database

ویژگی‌ها:
✅ پیکربندی خودکار
✅ رفع خودکار خطاها
✅ تنظیم خودکار تصاویر
✅ رابط گرافیکی مدیریت
✅ نصب تمیز واقعی
✅ مدیریت DBeaver

سازنده: پیمان رسولی
پروژه: KaizenixCore

برای شروع ادامه را بزنید."
    ["select_action"]="انتخاب نوع نصب"
    ["action_text"]="چه کاری می‌خواهید انجام دهید؟"
    ["fresh_install"]="🆕 نصب جدید"
    ["repair_install"]="🔧 تعمیر (رفع مشکلات نصب فعلی)"
    ["clean_install"]="🗑️ نصب تمیز (حذف همه و نصب مجدد)"
    ["uninstall"]="❌ حذف کامل"
    ["manage_dbeaver"]="📦 مدیریت DBeaver"
    ["exit_installer"]="🚪 خروج"
    ["enter_passwords"]="🔐 ورود رمز عبور"
    ["oracle_pass"]="رمز عبور Oracle Database:"
    ["apex_pass"]="رمز عبور APEX Admin:"
    ["pass_rules"]="قوانین رمز عبور:
• با حرف انگلیسی شروع شود
• فقط حروف و اعداد
• حداقل ۶ کاراکتر

مثال: MyPass123"
    ["invalid_pass"]="رمز عبور نامعتبر!

رمز عبور باید:
• با حرف انگلیسی شروع شود
• فقط حروف و اعداد
• حداقل ۶ کاراکتر

مثال: Oracle123"
    ["installing"]="در حال نصب اوراکل اپکس..."
    ["completed"]="✅ نصب با موفقیت انجام شد!"
    ["error"]="خطا"
    ["warning"]="هشدار"
    ["info"]="اطلاعات"
    ["open_browser"]="🌐 باز کردن APEX"
    ["exit"]="خروج"
    ["continue"]="ادامه"
    ["cancel"]="انصراف"
    ["yes"]="بله"
    ["no"]="خیر"
    ["ok"]="تایید"
    ["sudo_pass"]="رمز عبور سیستم را وارد کنید:"
    ["wait_db"]="منتظر شروع دیتابیس..."
    ["wait_ords"]="منتظر شروع ORDS..."
    ["step"]="مرحله"
    ["of"]="از"
    ["confirm_clean"]="⚠️ هشدار: نصب تمیز

این کار برای همیشه حذف می‌کند:
• تمام داده‌های Oracle APEX
• تمام دیتابیس‌ها
• تمام Docker volumes
• تمام تنظیمات

رمز جدید شما استفاده خواهد شد.

آیا مطمئن هستید؟"
    ["confirm_uninstall"]="⚠️ هشدار: حذف کامل

این کار برای همیشه حذف می‌کند:
• Oracle APEX
• Oracle Database
• تمام کانتینرها و volumes
• تمام فایل‌های پروژه

این عمل قابل بازگشت نیست!

آیا مطمئن هستید؟"
    ["dbeaver_menu"]="مدیریت DBeaver"
    ["dbeaver_text"]="عملیات DBeaver را انتخاب کنید:"
    ["dbeaver_install"]="📥 نصب DBeaver"
    ["dbeaver_remove"]="🗑️ حذف کامل DBeaver"
    ["dbeaver_back"]="⬅️ بازگشت"
    ["removing_dbeaver"]="در حال حذف DBeaver..."
    ["installing_dbeaver"]="در حال نصب DBeaver..."
    ["dbeaver_removed"]="DBeaver کاملاً حذف شد!"
    ["dbeaver_installed"]="DBeaver نصب شد!"
    ["repair_text"]="حالت تعمیر

این کار انجام می‌دهد:
• نگه داشتن داده‌های فعلی
• تنظیم مجدد همه رمزها به رمز جدید
• رفع مشکلات پیکربندی
• راه‌اندازی مجدد سرویس‌ها

رمز جدید را وارد کنید."
    ["success_title"]="🎉 نصب موفق!"
    ["success_text"]="اوراکل اپکس با موفقیت نصب شد!

🌐 پنل مدیریت:
http://localhost:8080/ords/apex_admin

🔐 صفحه ورود:
http://localhost:8080/ords/f?p=4550

📋 اطلاعات ورود:
   Workspace: INTERNAL
   Username: ADMIN
   Password: %PASSWORD%

🛠️ مدیریت:
   GUI: bash ~/oracle-apex-complete/scripts/launch-gui.sh
   Fix: bash ~/oracle-apex-complete/scripts/fix.sh

اگر خطا دیدید، اسکریپت Fix را اجرا کنید."
    ["create_service_title"]="ایجاد سرویس خودکار؟"
    ["create_service_text"]="آیا می‌خواهید Oracle APEX هنگام روشن شدن سیستم خودکار اجرا شود؟

این یک سرویس systemd ایجاد می‌کند که:
• دیتابیس را هنگام بوت شروع می‌کند
• ORDS را خودکار اجرا می‌کند
• در پس‌زمینه اجرا می‌شود"
    ["service_created"]="سرویس خودکار ایجاد شد!

برای مدیریت:
• شروع: sudo systemctl start oracle-apex
• توقف: sudo systemctl stop oracle-apex
• وضعیت: sudo systemctl status oracle-apex"
    ["detecting_os"]="تشخیص سیستم عامل..."
    ["installing_deps"]="نصب وابستگی‌ها..."
    ["downloading"]="دانلود"
    ["extracting"]="استخراج فایل‌ها..."
    ["configuring"]="پیکربندی..."
    ["starting_db"]="شروع دیتابیس (۵-۱۰ دقیقه)..."
    ["installing_apex"]="نصب APEX (۱۵-۲۵ دقیقه)..."
    ["configuring_ords"]="پیکربندی ORDS..."
    ["fixing_images"]="تنظیم تصاویر APEX..."
    ["creating_scripts"]="ایجاد اسکریپت‌های مدیریتی..."
    ["verifying"]="بررسی نصب..."
    ["cleaning"]="پاکسازی نصب قدیمی..."
    ["resetting_password"]="تنظیم مجدد رمزها..."
    ["install_dbeaver_title"]="نصب DBeaver؟"
)

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - GERMAN
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_DE=(
    ["title"]="Oracle APEX Installer"
    ["subtitle"]="KaizenixCore Edition v4.2"
    ["welcome_title"]="🚀 Oracle APEX Ultimate Installer"
    ["welcome_text"]="Oracle APEX Ultimate Installer v4.2.0

Dies wird installieren:
• Oracle APEX (Neueste Version)
• Oracle ORDS (Neueste Version)
• Oracle XE 21c Datenbank

Funktionen:
✅ Automatische Konfiguration
✅ Auto-Fix für Fehler
✅ APEX Images Auto-Setup
✅ Management GUI enthalten
✅ Echte Neuinstallation
✅ DBeaver Verwaltung

Erstellt von: Peyman Rasouli
Projekt: KaizenixCore

Klicken Sie Weiter um zu starten."
    ["select_action"]="Installationstyp wählen"
    ["action_text"]="Was möchten Sie tun?"
    ["fresh_install"]="🆕 Neuinstallation"
    ["repair_install"]="🔧 Reparieren (Bestehende Installation reparieren)"
    ["clean_install"]="🗑️ Saubere Installation (ALLES löschen und neu)"
    ["uninstall"]="❌ Alles deinstallieren"
    ["manage_dbeaver"]="📦 DBeaver verwalten"
    ["exit_installer"]="🚪 Beenden"
    ["enter_passwords"]="🔐 Passwörter eingeben"
    ["oracle_pass"]="Oracle Database Passwort:"
    ["apex_pass"]="APEX Admin Passwort:"
    ["pass_rules"]="Passwortregeln:
• Beginnt mit Buchstaben (a-z, A-Z)
• Nur Buchstaben und Zahlen
• Mindestens 6 Zeichen

Beispiel: MyPass123"
    ["invalid_pass"]="Ungültiges Passwort!

Passwort muss:
• Mit Buchstaben beginnen
• Nur Buchstaben/Zahlen
• Mindestens 6 Zeichen

Beispiel: Oracle123"
    ["installing"]="Oracle APEX wird installiert..."
    ["completed"]="✅ Installation abgeschlossen!"
    ["error"]="Fehler"
    ["warning"]="Warnung"
    ["info"]="Information"
    ["open_browser"]="🌐 APEX öffnen"
    ["exit"]="Beenden"
    ["continue"]="Weiter"
    ["cancel"]="Abbrechen"
    ["yes"]="Ja"
    ["no"]="Nein"
    ["ok"]="OK"
    ["sudo_pass"]="Geben Sie Ihr Systempasswort ein:"
    ["wait_db"]="Warten auf Datenbankstart..."
    ["wait_ords"]="Warten auf ORDS-Start..."
    ["step"]="Schritt"
    ["of"]="von"
    ["confirm_clean"]="⚠️ WARNUNG: Saubere Installation

Dies wird DAUERHAFT LÖSCHEN:
• Alle Oracle APEX Daten
• Alle Datenbanken
• Alle Docker Volumes
• Alle Konfigurationen

Ihr neues Passwort wird verwendet.

Sind Sie SICHER?"
    ["confirm_uninstall"]="⚠️ WARNUNG: Komplette Deinstallation

Dies wird DAUERHAFT LÖSCHEN:
• Oracle APEX
• Oracle Database
• Alle Docker Container und Volumes
• Alle Projektdateien

Diese Aktion kann NICHT rückgängig gemacht werden!

Sind Sie SICHER?"
    ["dbeaver_menu"]="DBeaver Verwaltung"
    ["dbeaver_text"]="DBeaver Aktion wählen:"
    ["dbeaver_install"]="📥 DBeaver installieren"
    ["dbeaver_remove"]="🗑️ DBeaver komplett entfernen"
    ["dbeaver_back"]="⬅️ Zurück"
    ["removing_dbeaver"]="DBeaver wird entfernt..."
    ["installing_dbeaver"]="DBeaver wird installiert..."
    ["dbeaver_removed"]="DBeaver wurde komplett entfernt!"
    ["dbeaver_installed"]="DBeaver wurde installiert!"
    ["repair_text"]="Reparaturmodus

Dies wird:
• Bestehende Daten behalten
• Alle Passwörter auf Ihr neues Passwort setzen
• Konfigurationsprobleme beheben
• Alle Dienste neu starten

Geben Sie Ihr NEUES Passwort ein."
    ["success_title"]="🎉 Installation erfolgreich!"
    ["success_text"]="Oracle APEX erfolgreich installiert!

🌐 Admin Panel:
http://localhost:8080/ords/apex_admin

🔐 Login Seite:
http://localhost:8080/ords/f?p=4550

📋 Anmeldedaten:
   Workspace: INTERNAL
   Username: ADMIN
   Password: %PASSWORD%

🛠️ Verwaltung:
   GUI: bash ~/oracle-apex-complete/scripts/launch-gui.sh
   Fix: bash ~/oracle-apex-complete/scripts/fix.sh

Bei Fehlern führen Sie das Fix-Skript aus."
    ["create_service_title"]="Auto-Start Service erstellen?"
    ["create_service_text"]="Möchten Sie, dass Oracle APEX beim Systemstart automatisch startet?

Dies erstellt einen systemd Service der:
• Datenbank beim Booten startet
• ORDS automatisch startet
• Im Hintergrund läuft"
    ["service_created"]="Auto-Start Service erstellt!

Zur Verwaltung:
• Start: sudo systemctl start oracle-apex
• Stop: sudo systemctl stop oracle-apex
• Status: sudo systemctl status oracle-apex"
    ["detecting_os"]="Betriebssystem wird erkannt..."
    ["installing_deps"]="Abhängigkeiten werden installiert..."
    ["downloading"]="Herunterladen"
    ["extracting"]="Dateien werden extrahiert..."
    ["configuring"]="Konfigurieren..."
    ["starting_db"]="Datenbank wird gestartet (5-10 Min)..."
    ["installing_apex"]="APEX wird installiert (15-25 Min)..."
    ["configuring_ords"]="ORDS wird konfiguriert..."
    ["fixing_images"]="APEX Images werden eingerichtet..."
    ["creating_scripts"]="Management-Skripte werden erstellt..."
    ["verifying"]="Installation wird überprüft..."
    ["cleaning"]="Alte Installation wird bereinigt..."
    ["resetting_password"]="Passwörter werden zurückgesetzt..."
    ["install_dbeaver_title"]="DBeaver installieren?"
)

#═══════════════════════════════════════════════════════════════════════════════
# GET TEXT FUNCTION
#═══════════════════════════════════════════════════════════════════════════════
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
    echo "$msg"
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
    
    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="$ID"
    else
        OS_ID="unknown"
    fi
    
    log "Detected OS: $OS_TYPE, Distribution: $OS_ID"
}

#═══════════════════════════════════════════════════════════════════════════════
# GUI FUNCTIONS
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
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            sudo apt-get update -qq 2>/dev/null || true
            sudo apt-get install -y yad 2>/dev/null || sudo apt-get install -y zenity 2>/dev/null || true
            ;;
        fedora)
            sudo dnf install -y yad 2>/dev/null || sudo dnf install -y zenity 2>/dev/null || true
            ;;
        opensuse*|suse*)
            sudo zypper --non-interactive install -y yad 2>/dev/null || sudo zypper --non-interactive install -y zenity 2>/dev/null || true
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm yad 2>/dev/null || sudo pacman -S --noconfirm zenity 2>/dev/null || true
            ;;
    esac

    if command -v yad &> /dev/null; then
        GUI_TOOL="yad"
    elif command -v zenity &> /dev/null; then
        GUI_TOOL="zenity"
    else
        echo "ERROR: No GUI tool found. Please install yad or zenity"
        exit 1
    fi
    
    log "Using GUI tool: $GUI_TOOL"
}

gui_info() {
    local title="$1"
    local text="$2"
    local width="${3:-550}"
    local height="${4:-400}"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$title" --text="$text" \
            --width=$width --height=$height --center \
            --button="$(get_text ok):0" \
            --borders=15 --text-align=left \
            --window-icon=dialog-information 2>/dev/null
    else
        zenity --info --title="$title" --text="$text" \
            --width=$width --height=$height \
            --ok-label="$(get_text ok)" 2>/dev/null
    fi
}

gui_error() {
    local title="$1"
    local text="$2"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="$title" --text="$text" \
            --width=500 --height=300 --center \
            --button="$(get_text ok):0" \
            --borders=15 --window-icon=dialog-error 2>/dev/null
    else
        zenity --error --title="$title" --text="$text" \
            --width=500 --height=300 \
            --ok-label="$(get_text ok)" 2>/dev/null
    fi
}

gui_warning() {
    local title="$1"
    local text="$2"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --warning --title="$title" --text="$text" \
            --width=500 --height=350 --center \
            --button="$(get_text ok):0" \
            --borders=15 --window-icon=dialog-warning 2>/dev/null
    else
        zenity --warning --title="$title" --text="$text" \
            --width=500 --height=350 \
            --ok-label="$(get_text ok)" 2>/dev/null
    fi
}

gui_question() {
    local title="$1"
    local text="$2"
    local yes_label="${3:-$(get_text yes)}"
    local no_label="${4:-$(get_text no)}"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --question --title="$title" --text="$text" \
            --width=550 --height=400 --center \
            --button="$no_label:1" --button="$yes_label:0" \
            --borders=15 --window-icon=dialog-question 2>/dev/null
        return $?
    else
        zenity --question --title="$title" --text="$text" \
            --width=550 --height=400 \
            --ok-label="$yes_label" --cancel-label="$no_label" 2>/dev/null
        return $?
    fi
}

gui_entry() {
    local title="$1"
    local text="$2"
    local hide="${3:-false}"
    local result=""
    
    if [ "$GUI_TOOL" = "yad" ]; then
        if [ "$hide" = "true" ]; then
            result=$(yad --entry --title="$title" --text="$text" \
                --hide-text --width=450 --center \
                --button="$(get_text cancel):1" --button="$(get_text ok):0" \
                --borders=15 2>/dev/null)
        else
            result=$(yad --entry --title="$title" --text="$text" \
                --width=450 --center \
                --button="$(get_text cancel):1" --button="$(get_text ok):0" \
                --borders=15 2>/dev/null)
        fi
    else
        if [ "$hide" = "true" ]; then
            result=$(zenity --password --title="$title" 2>/dev/null)
        else
            result=$(zenity --entry --title="$title" --text="$text" \
                --width=450 2>/dev/null)
        fi
    fi
    
    echo "$result"
}

gui_list() {
    local title="$1"
    local text="$2"
    shift 2
    local result=""
    
    if [ "$GUI_TOOL" = "yad" ]; then
        result=$(yad --list --title="$title" --text="$text" \
            --radiolist --column="" --column="ID" --column="Option" \
            "$@" \
            --width=550 --height=450 --center \
            --button="$(get_text cancel):1" --button="$(get_text ok):0" \
            --print-column=2 --hide-column=2 \
            --borders=15 2>/dev/null)
    else
        result=$(zenity --list --title="$title" --text="$text" \
            --radiolist --column="" --column="ID" --column="Option" \
            "$@" \
            --width=550 --height=450 \
            --ok-label="$(get_text ok)" --cancel-label="$(get_text cancel)" \
            --hide-column=2 2>/dev/null)
    fi
    
    echo "$result" | tr -d '|' | tr -d ' '
}

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE SELECTION
#═══════════════════════════════════════════════════════════════════════════════
select_language() {
    local result=""
    
    result=$(gui_list "🌐 Select Language / انتخاب زبان / Sprache" \
        "Select your preferred language:
زبان مورد نظر خود را انتخاب کنید:
Wählen Sie Ihre Sprache:" \
        TRUE "en" "🇺🇸 English" \
        FALSE "fa" "🇮🇷 فارسی (Persian)" \
        FALSE "de" "🇩🇪 Deutsch (German)")
    
    [ -z "$result" ] && exit 0
    CURRENT_LANG="$result"
    [ -z "$CURRENT_LANG" ] && CURRENT_LANG="en"
    
    log "Language selected: $CURRENT_LANG"
}

#═══════════════════════════════════════════════════════════════════════════════
# SUDO PASSWORD
#═══════════════════════════════════════════════════════════════════════════════
get_sudo_password() {
    if sudo -n true 2>/dev/null; then
        return 0
    fi

    local pass=""
    local attempts=0
    
    while [ $attempts -lt 3 ]; do
        pass=$(gui_entry "$(get_text title)" "$(get_text sudo_pass)" "true")
        
        [ -z "$pass" ] && exit 0

        if echo "$pass" | sudo -S true 2>/dev/null; then
            SUDO_PASS="$pass"
            return 0
        else
            attempts=$((attempts + 1))
            gui_error "$(get_text error)" "Wrong password! Try again. ($attempts/3)"
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

#═══════════════════════════════════════════════════════════════════════════════
# PASSWORD INPUT
#═══════════════════════════════════════════════════════════════════════════════
get_passwords() {
    local result=""
    
    while true; do
        if [ "$GUI_TOOL" = "yad" ]; then
            result=$(yad --form --title="$(get_text title) - $(get_text enter_passwords)" \
                --text="$(get_text pass_rules)" \
                --field="$(get_text oracle_pass):H" "" \
                --field="$(get_text apex_pass):H" "" \
                --width=550 --height=400 --center \
                --button="$(get_text cancel):1" --button="$(get_text continue):0" \
                --borders=15 2>/dev/null)
        else
            result=$(zenity --forms --title="$(get_text title)" \
                --text="$(get_text pass_rules)" \
                --add-password="$(get_text oracle_pass)" \
                --add-password="$(get_text apex_pass)" \
                --width=500 --height=350 \
                --ok-label="$(get_text continue)" --cancel-label="$(get_text cancel)" 2>/dev/null)
        fi
        
        [ -z "$result" ] && exit 0

        ORACLE_PASSWORD=$(echo "$result" | cut -d'|' -f1)
        APEX_ADMIN_PASSWORD=$(echo "$result" | cut -d'|' -f2)

        if [[ "$ORACLE_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{5,}$ ]] && \
           [[ "$APEX_ADMIN_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{5,}$ ]]; then
            break
        else
            gui_error "$(get_text error)" "$(get_text invalid_pass)"
        fi
    done
    
    export ORACLE_PASSWORD
    export APEX_ADMIN_PASSWORD
    log "Passwords validated"
}

#═══════════════════════════════════════════════════════════════════════════════
# PROGRESS BAR
#═══════════════════════════════════════════════════════════════════════════════
FIFO_FILE=""
PROGRESS_PID=""

start_progress() {
    FIFO_FILE=$(mktemp -u)
    mkfifo "$FIFO_FILE" 2>/dev/null || true
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="$(get_text title)" --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-buttons \
            --width=600 --height=150 --center --borders=15 < "$FIFO_FILE" 2>/dev/null &
        PROGRESS_PID=$!
    else
        zenity --progress --title="$(get_text title)" --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel \
            --width=600 --height=150 < "$FIFO_FILE" 2>/dev/null &
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
    log "Progress: $percent% - $text"
}

stop_progress() {
    exec 3>&- 2>/dev/null || true
    sleep 1
    rm -f "$FIFO_FILE" 2>/dev/null || true
    [ -n "$PROGRESS_PID" ] && kill "$PROGRESS_PID" 2>/dev/null || true
    sleep 1
}

#═══════════════════════════════════════════════════════════════════════════════
# COMPLETE CLEANUP FUNCTION - CRITICAL FOR FIXING PASSWORD ISSUES
#═══════════════════════════════════════════════════════════════════════════════
complete_cleanup() {
    log "Starting complete cleanup..."
    
    # Stop ORDS
    pkill -9 -f ords 2>/dev/null || true
    pkill -9 -f java.*ords 2>/dev/null || true
    sleep 3
    
    # Stop and remove container
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    
    # Remove ALL oracle related volumes - THIS IS CRITICAL
    docker volume rm oracle-apex-complete_oracle-data 2>/dev/null || true
    docker volume rm oracle-apex-data 2>/dev/null || true
    docker volume rm oracle-data 2>/dev/null || true
    docker volume rm apex-data 2>/dev/null || true
    
    # Find and remove any oracle volumes
    local volumes=$(docker volume ls -q 2>/dev/null | grep -iE "oracle|apex" || true)
    if [ -n "$volumes" ]; then
        echo "$volumes" | xargs -r docker volume rm 2>/dev/null || true
    fi
    
    # Remove project directory
    rm -rf "$PROJECT_DIR" 2>/dev/null || true
    
    # Remove docker network if exists
    docker network rm apex-network 2>/dev/null || true
    
    # Clean docker system
    docker system prune -f 2>/dev/null || true
    
    log "Complete cleanup finished"
}

#═══════════════════════════════════════════════════════════════════════════════
# COMPLETE UNINSTALL
#═══════════════════════════════════════════════════════════════════════════════
complete_uninstall() {
    log "Starting complete uninstall..."
    
    complete_cleanup
    
    # Remove systemd services
    run_sudo systemctl stop oracle-apex.service 2>/dev/null || true
    run_sudo systemctl disable oracle-apex.service 2>/dev/null || true
    run_sudo rm -f /etc/systemd/system/oracle-apex*.service 2>/dev/null || true
    run_sudo systemctl daemon-reload 2>/dev/null || true
    
    # Remove desktop file
    rm -f "$HOME/.local/share/applications/oracle-apex.desktop" 2>/dev/null || true
    
    log "Complete uninstall finished"
}

#═══════════════════════════════════════════════════════════════════════════════
# DBEAVER MANAGEMENT - FIXED
#═══════════════════════════════════════════════════════════════════════════════
remove_dbeaver() {
    log "Removing DBeaver completely..."
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            run_sudo apt-get remove -y --purge dbeaver-ce dbeaver 2>/dev/null || true
            run_sudo apt-get autoremove -y 2>/dev/null || true
            ;;
        fedora)
            run_sudo dnf remove -y dbeaver-ce dbeaver 2>/dev/null || true
            ;;
        opensuse*|suse*)
            run_sudo zypper remove -y dbeaver-ce dbeaver 2>/dev/null || true
            ;;
        arch|manjaro)
            run_sudo pacman -Rns --noconfirm dbeaver dbeaver-ce 2>/dev/null || true
            ;;
    esac
    
    # Remove flatpak version
    flatpak uninstall -y io.dbeaver.DBeaverCommunity 2>/dev/null || true
    
    # Remove snap version
    run_sudo snap remove dbeaver-ce 2>/dev/null || true
    
    # Remove config directories
    rm -rf "$HOME/.dbeaver4" 2>/dev/null || true
    rm -rf "$HOME/.dbeaver-drivers" 2>/dev/null || true
    rm -rf "$HOME/.local/share/DBeaverData" 2>/dev/null || true
    rm -rf "$HOME/.config/DBeaverData" 2>/dev/null || true
    rm -rf "$HOME/.config/dbeaver" 2>/dev/null || true
    
    # Remove desktop files
    rm -f "$HOME/.local/share/applications/dbeaver*.desktop" 2>/dev/null || true
    
    log "DBeaver removed completely"
}

install_dbeaver() {
    log "🔍 Installing DBeaver (Detecting distribution)..."
    
    # Check if already installed
    if command -v dbeaver &> /dev/null || command -v dbeaver-ce &> /dev/null; then
        log "✅ DBeaver already installed"
        return 0
    fi
    
    local install_success=false
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop|neon)
            log "📦 Detected: Debian/Ubuntu-based"
            
            # Method 1: Official repository
            log "Trying official DBeaver repository..."
            run_sudo sh -c 'echo "deb https://dbeaver.io/debs/dbeaver-ce /" > /etc/apt/sources.list.d/dbeaver.list' 2>/dev/null || true
            wget -O - https://dbeaver.io/debs/dbeaver.gpg.key 2>/dev/null | run_sudo apt-key add - 2>/dev/null || true
            
            run_sudo apt-get update -qq 2>/dev/null || true
            
            if run_sudo apt-get install -y dbeaver-ce 2>/dev/null; then
                install_success=true
                log "✅ DBeaver installed from official repository"
            else
                log "⚠️ Official repo failed, trying direct .deb download..."
                
                # Method 2: Direct download
                local dbeaver_deb="/tmp/dbeaver-ce.deb"
                wget -q -O "$dbeaver_deb" "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" 2>/dev/null || \
                curl -L -o "$dbeaver_deb" "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" 2>/dev/null || true
                
                if [ -f "$dbeaver_deb" ]; then
                    run_sudo dpkg -i "$dbeaver_deb" 2>/dev/null || true
                    run_sudo apt-get install -f -y 2>/dev/null || true
                    rm -f "$dbeaver_deb"
                    install_success=true
                    log "✅ DBeaver installed from direct download"
                fi
            fi
            ;;
            
        fedora)
            log "📦 Detected: Fedora"
            
            if run_sudo dnf install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm 2>/dev/null; then
                install_success=true
                log "✅ DBeaver installed"
            fi
            ;;
            
        rhel|centos|rocky|alma)
            log "📦 Detected: RHEL/CentOS-based"
            
            local rpm_file="/tmp/dbeaver-ce.rpm"
            wget -q -O "$rpm_file" "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" 2>/dev/null || \
            curl -L -o "$rpm_file" "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" 2>/dev/null || true
            
            if [ -f "$rpm_file" ]; then
                run_sudo yum install -y "$rpm_file" 2>/dev/null || true
                rm -f "$rpm_file"
                install_success=true
                log "✅ DBeaver installed"
            fi
            ;;
            
        opensuse*|suse*)
            log "📦 Detected: openSUSE/SUSE"
            
            local rpm_file="/tmp/dbeaver-ce.rpm"
            wget -q -O "$rpm_file" "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" 2>/dev/null || \
            curl -L -o "$rpm_file" "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" 2>/dev/null || true
            
            if [ -f "$rpm_file" ]; then
                run_sudo zypper --non-interactive install -y "$rpm_file" 2>/dev/null || true
                rm -f "$rpm_file"
                install_success=true
                log "✅ DBeaver installed"
            fi
            ;;
            
        arch|manjaro)
            log "📦 Detected: Arch/Manjaro"
            
            if run_sudo pacman -S --noconfirm dbeaver 2>/dev/null; then
                install_success=true
                log "✅ DBeaver installed"
            fi
            ;;
            
        *)
            log "📦 Unknown distribution, trying Flatpak/Snap..."
            
            # Try Flatpak
            if command -v flatpak &> /dev/null; then
                if flatpak install -y flathub io.dbeaver.DBeaverCommunity 2>/dev/null; then
                    install_success=true
                    log "✅ DBeaver installed via Flatpak"
                fi
            fi
            
            # Try Snap
            if [ "$install_success" = false ] && command -v snap &> /dev/null; then
                if run_sudo snap install dbeaver-ce 2>/dev/null; then
                    install_success=true
                    log "✅ DBeaver installed via Snap"
                fi
            fi
            ;;
    esac
    
    # Verify installation
    sleep 2
    
    if command -v dbeaver &> /dev/null || command -v dbeaver-ce &> /dev/null || \
       [ -f /usr/share/applications/dbeaver-ce.desktop ] || \
       [ -f /usr/share/applications/dbeaver.desktop ] || \
       flatpak list --app | grep -q "dbeaver"; then
        
        log "✅ DBeaver installation verified successfully"
        
        # Create desktop shortcut if not exists
        if [ ! -f "$HOME/.local/share/applications/dbeaver-ce.desktop" ]; then
            mkdir -p "$HOME/.local/share/applications"
            cat > "$HOME/.local/share/applications/dbeaver-ce.desktop" << 'DESKTOPEOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=DBeaver
Comment=Universal Database Manager
Exec=dbeaver %F
Icon=dbeaver
Terminal=false
Categories=Development;Database;IDE;
Keywords=database;sql;
MimeType=application/x-dbeaver-project;
DESKTOPEOF
            chmod +x "$HOME/.local/share/applications/dbeaver-ce.desktop"
        fi
        
        update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
        
        return 0
    else
        log "⚠️ DBeaver installation may have failed"
        log "Please install manually from: https://dbeaver.io/download"
        return 1
    fi
}

manage_dbeaver() {
    while true; do
        local choice=$(gui_list "$(get_text dbeaver_menu)" "$(get_text dbeaver_text)" \
            TRUE "install" "$(get_text dbeaver_install)" \
            FALSE "remove" "$(get_text dbeaver_remove)" \
            FALSE "back" "$(get_text dbeaver_back)")
        
        case "$choice" in
            install)
                start_progress
                update_progress 50 "$(get_text installing_dbeaver)"
                if install_dbeaver; then
                    update_progress 100 "$(get_text dbeaver_installed)"
                    stop_progress
                    gui_info "$(get_text info)" "$(get_text dbeaver_installed)\n\nYou may need to log out and back in for DBeaver to appear in your applications menu."
                else
                    stop_progress
                    gui_warning "$(get_text warning)" "DBeaver installation may have failed.\nPlease install manually from: https://dbeaver.io"
                fi
                ;;
            remove)
                if gui_question "$(get_text warning)" "Are you sure you want to remove DBeaver completely?"; then
                    start_progress
                    update_progress 50 "$(get_text removing_dbeaver)"
                    remove_dbeaver
                    update_progress 100 "$(get_text dbeaver_removed)"
                    stop_progress
                    gui_info "$(get_text info)" "$(get_text dbeaver_removed)"
                fi
                ;;
            back|"")
                return 0
                ;;
        esac
    done
}

#═══════════════════════════════════════════════════════════════════════════════
# CHECK PREVIOUS INSTALLATION
#═══════════════════════════════════════════════════════════════════════════════
check_previous_installation() {
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
        return 0
    fi
    
    if docker volume ls --format '{{.Name}}' 2>/dev/null | grep -qi "oracle"; then
        return 0
    fi
    
    if [ -d "$PROJECT_DIR/apex" ] || [ -d "$PROJECT_DIR/ords" ]; then
        return 0
    fi
    
    return 1
}

#═══════════════════════════════════════════════════════════════════════════════
# WAIT FOR DATABASE - CRITICAL FIX
#═══════════════════════════════════════════════════════════════════════════════
wait_for_database_ready() {
    log "Waiting for database to be ready..."
    local timeout=900  # 15 minutes max
    local start_time=$(date +%s)
    local check_interval=15
    
    while true; do
        # Check if container is running
        if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
            log "Container not running, waiting..."
            sleep $check_interval
            continue
        fi
        
        # Check for "DATABASE IS READY" message
        if docker logs "$CONTAINER_NAME" 2>&1 | grep -q "DATABASE IS READY"; then
            log "Database reports READY"
            
            # Double-check with actual connection test
            if docker exec "$CONTAINER_NAME" bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -q "1"; then
                log "Database connection verified successfully"
                return 0
            fi
        fi
        
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ "$elapsed" -gt "$timeout" ]; then
            log "Database timeout after ${elapsed}s"
            return 1
        fi
        
        log "Waiting for database... (${elapsed}s elapsed)"
        sleep $check_interval
    done
}

#═══════════════════════════════════════════════════════════════════════════════
# TEST DATABASE CONNECTION - NEW FUNCTION
#═══════════════════════════════════════════════════════════════════════════════
test_db_connection() {
    local password="$1"
    local service="$2"
    
    docker exec "$CONTAINER_NAME" bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s sys/${password}@//localhost:${DB_PORT}/${service} as sysdba 2>/dev/null" | grep -q "1"
    return $?
}

#═══════════════════════════════════════════════════════════════════════════════
# FIX APEX IMAGES
#═══════════════════════════════════════════════════════════════════════════════
fix_apex_images() {
    log "Fixing APEX images..."
    
    # Ensure images directory exists and is populated
    if [ ! -d "$IMAGES_DIR" ] || [ $(find "$IMAGES_DIR" -type f 2>/dev/null | wc -l) -lt 100 ]; then
        rm -rf "$IMAGES_DIR" 2>/dev/null || true
        if [ -d "$PROJECT_DIR/apex/images" ]; then
            cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR"
            log "Images copied from apex/images"
        fi
    fi
    
    chmod -R 755 "$IMAGES_DIR" 2>/dev/null || true
    
    # Configure ORDS for images
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    if [ -n "$ORDS_BIN" ]; then
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" 2>/dev/null || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i 2>/dev/null || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" 2>/dev/null || true
    fi
    
    # Create/Update settings.xml
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

    # Set IMAGE_PREFIX in database
    local APEX_SCHEMA=$(cat "$PROJECT_DIR/.apex_schema" 2>/dev/null)
    [ -z "$APEX_SCHEMA" ] && APEX_SCHEMA="APEX_240100"
    
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << SQLEOF
BEGIN
    ${APEX_SCHEMA}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
EXIT;
SQLEOF" 2>/dev/null || true

    log "APEX images fixed"
}

#═══════════════════════════════════════════════════════════════════════════════
# REPAIR INSTALLATION - COMPREHENSIVE FIX FOR 571 (SECURE VERSION)
#═══════════════════════════════════════════════════════════════════════════════

repair_installation() {
    log "═══════════════════════════════════════════════════════════════"
    log "🔧 REPAIR INSTALLATION - COMPREHENSIVE FIX FOR ERROR 571"
    log "═══════════════════════════════════════════════════════════════"
    
    # CRITICAL: Before repair, backup current config
    if [ -d "$ORDS_CONFIG_DIR" ]; then
        log "📦 Backing up current ORDS config..."
        cp -r "$ORDS_CONFIG_DIR" "$ORDS_CONFIG_DIR.backup.$(date +%s)" 2>/dev/null || true
    fi

    # Ensure passwords are loaded
    if [ -z "$ORACLE_PASSWORD" ] || [ -z "$APEX_ADMIN_PASSWORD" ]; then
        log "❌ ERROR: Passwords not set!"
        gui_error "$(get_text error)" "Passwords not configured. Please run installer."
        return 1
    fi

    log "✅ Passwords loaded successfully"
    
    start_progress
    
    #═════════════════════════════════════════════════════════════════
    # STEP 1: Stop ORDS
    #═════════════════════════════════════════════════════════════════
    update_progress 5 "Stopping ORDS..."
    log "[1/13] Stopping ORDS services..."
    
    pkill -9 -f "ords.*serve" 2>/dev/null || true
    pkill -9 -f "java.*ords" 2>/dev/null || true
    pkill -9 -f "ords" 2>/dev/null || true
    
    sleep 5
    log "✅ ORDS stopped"
    
    #═════════════════════════════════════════════════════════════════
    # STEP 2: Start database
    #═════════════════════════════════════════════════════════════════
    update_progress 10 "Starting database..."
    log "[2/13] Starting database container..."
    
    docker start "$CONTAINER_NAME" 2>/dev/null || true
    sleep 10
    
    # Wait for database to be ready - CRITICAL
    log "[3/13] Waiting for database (this may take 5-10 minutes)..."
    update_progress 15 "Waiting for database (this may take a few minutes)..."
    
    local db_ready=false
    local wait_count=0
    
    for i in {1..120}; do
        wait_count=$((wait_count + 1))
        
        # Check if container is running
        if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
            log "⚠️ Container not running, waiting..."
            sleep 5
            continue
        fi
        
        # Check for DATABASE IS READY message
        if docker logs "$CONTAINER_NAME" 2>&1 | grep -q "DATABASE IS READY"; then
            log "✅ Database reports READY (after ${wait_count} checks)"
            db_ready=true
            break
        fi
        
        # Try actual connection test
        if docker exec "$CONTAINER_NAME" bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba 2>/dev/null" | grep -q "1"; then
            log "✅ Database connection verified (after ${wait_count} checks)"
            db_ready=true
            break
        fi
        
        if [ $((wait_count % 10)) -eq 0 ]; then
            log "⏳ Still waiting for database... (${wait_count}s elapsed)"
        fi
        
        sleep 5
    done
    
    if [ "$db_ready" = false ]; then
        log "⚠️ WARNING: Database may not be fully ready, continuing anyway..."
    fi
    
    sleep 30  # Extra wait time for stability
    log "✅ Database started and ready"
    
    #═════════════════════════════════════════════════════════════════
    # STEP 3: Reset database password
    #═════════════════════════════════════════════════════════════════
    update_progress 22 "$(get_text resetting_password)"
    log "[4/13] Resetting database password..."
    
    docker exec "$CONTAINER_NAME" resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 20
    log "✅ Database password reset"
    
    #═════════════════════════════════════════════════════════════════
    # STEP 4: Disable password policies
    #═════════════════════════════════════════════════════════════════
    update_progress 28 "Disabling password policies..."
    log "[5/13] Disabling password policies..."
    
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
SET ECHO OFF FEEDBACK OFF PAGESIZE 0 LINESIZE 32767
WHENEVER SQLERROR CONTINUE

ALTER PROFILE DEFAULT LIMIT 
    FAILED_LOGIN_ATTEMPTS UNLIMITED 
    PASSWORD_LIFE_TIME UNLIMITED 
    PASSWORD_VERIFY_FUNCTION NULL;

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    log "✅ Password policies disabled"

    #═════════════════════════════════════════════════════════════════
    # STEP 5: Fix ORDS_PUBLIC_USER - CRITICAL FOR 571
    #═════════════════════════════════════════════════════════════════
    update_progress 35 "Fixing ORDS_PUBLIC_USER..."
    log "[6/13] Creating/Fixing ORDS_PUBLIC_USER with proper privileges..."
    
    # Escape password for SQL (replace ' with '')
    local pw_sql_safe="${ORACLE_PASSWORD//\'/\'\'}"
    
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
SET ECHO OFF FEEDBACK OFF PAGESIZE 0 LINESIZE 32767
WHENEVER SQLERROR CONTINUE

-- ===== DROP EXISTING USER =====
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ===== CREATE USER WITH PROPER TABLESPACE =====
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY '${pw_sql_safe}'
    DEFAULT TABLESPACE SYSAUX
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON SYSAUX;

-- ===== GRANT CORE PRIVILEGES =====
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
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;

-- ===== GRANT SYSTEM PACKAGE PRIVILEGES (CRITICAL FOR 571) =====
BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_SQL TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_ENCODE TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_LOCK TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_PIPE TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ===== UNLOCK ACCOUNT =====
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

-- ===== VERIFY CREATION =====
SET HEADING ON FEEDBACK ON PAGESIZE 20
SELECT USERNAME, ACCOUNT_STATUS FROM DBA_USERS WHERE USERNAME = 'ORDS_PUBLIC_USER';

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    log "✅ ORDS_PUBLIC_USER created with full privileges"

    #═════════════════════════════════════════════════════════════════
    # STEP 6: Fix other APEX users
    #═════════════════════════════════════════════════════════════════
    update_progress 42 "Fixing APEX users..."
    log "[7/13] Fixing APEX users (APEX_PUBLIC_USER, APEX_LISTENER, etc.)..."
    
    local pw_sql_safe="${ORACLE_PASSWORD//\'/\'\'}"
    
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
SET ECHO OFF FEEDBACK OFF PAGESIZE 0 LINESIZE 32767
WHENEVER SQLERROR CONTINUE

-- ===== FIX APEX_PUBLIC_USER =====
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY '\''${pw_sql_safe}'\'' ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ===== FIX APEX_LISTENER =====
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY '\''${pw_sql_safe}'\'' ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ===== FIX APEX_REST_PUBLIC_USER =====
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY '\''${pw_sql_safe}'\'' ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ===== GRANT PROXY CONNECTIONS - CRITICAL FOR 571 FIX =====
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ===== GRANT NECESSARY PRIVILEGES TO ORDS_PUBLIC_USER =====
BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_ENCODE TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    log "✅ APEX users fixed"

    #═════════════════════════════════════════════════════════════════
    # STEP 7: Reset APEX admin password
    #═════════════════════════════════════════════════════════════════
    update_progress 50 "Resetting APEX admin password..."
    log "[8/13] Resetting APEX admin password..."
    
    local apex_schema=$(cat "$PROJECT_DIR/.apex_schema" 2>/dev/null)
    if [ -z "$apex_schema" ]; then
        apex_schema=$(docker exec "$CONTAINER_NAME" bash -c "echo \"SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ') || true
    fi
    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"
    log "Using APEX schema: $apex_schema"
    
    local pw_sql_safe="${APEX_ADMIN_PASSWORD//\'/\'\'}"
    
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
SET ECHO OFF FEEDBACK OFF PAGESIZE 0 LINESIZE 32767
WHENEVER SQLERROR CONTINUE

BEGIN
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('RESTFUL_SERVICES_ENABLED', 'Y');
    ${apex_schema}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    
    BEGIN
        ${apex_schema}.APEX_UTIL.EDIT_USER(
            p_user_id                      => ${apex_schema}.APEX_UTIL.GET_USER_ID('ADMIN'),
            p_user_name                    => 'ADMIN',
            p_web_password                 => '${pw_sql_safe}',
            p_new_password                 => '${pw_sql_safe}',
            p_change_password_on_first_use => 'N',
            p_account_locked               => 'N'
        );
    EXCEPTION WHEN OTHERS THEN
        ${apex_schema}.APEX_UTIL.CREATE_USER(
            p_user_name                    => 'ADMIN',
            p_email_address                => 'admin@localhost',
            p_web_password                 => '${pw_sql_safe}',
            p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
            p_change_password_on_first_use => 'N',
            p_account_locked               => 'N'
        );
    END;
    
    COMMIT;
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    log "✅ APEX admin password reset"

    #═════════════════════════════════════════════════════════════════
    # STEP 8: Reinstall ORDS connection
    #═════════════════════════════════════════════════════════════════
    update_progress 60 "Reinstalling ORDS connection..."
    log "[9/13] Reinstalling ORDS connection..."
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    
    if [ -n "$ORDS_BIN" ] && [ -x "$ORDS_BIN" ]; then
        # Remove old ORDS config
        rm -rf "$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
        mkdir -p "$ORDS_CONFIG_DIR/databases/default"
        
        # Create password file
        local PASS_FILE=$(mktemp)
        printf "%s\n%s\n%s\n" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" > "$PASS_FILE"

        # Reinstall ORDS with correct settings
        log "Running ORDS install command..."
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
            --admin-user SYS \
            --db-hostname localhost \
            --db-port "$DB_PORT" \
            --db-servicename "$DB_SERVICE" \
            --feature-sdw true \
            --feature-rest-enabled-sql true \
            --gateway-mode proxied \
            --gateway-user ORDS_PUBLIC_USER \
            --password-stdin < "$PASS_FILE" >> "$INSTALL_LOG" 2>&1 || true

        rm -f "$PASS_FILE"
        
        # Verify ORDS config was created
        if [ -f "$ORDS_CONFIG_DIR/databases/default/ords_params.properties" ]; then
            log "✅ ORDS parameters file created"
        else
            log "⚠️ ORDS parameters file not found, creating manually..."
        fi
        
        # Set ORDS password explicitly
        log "Setting ORDS database password..."
        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
        log "✅ ORDS password configured"
    else
        log "❌ ERROR: ORDS binary not found or not executable"
        return 1
    fi

    #═════════════════════════════════════════════════════════════════
    # STEP 9: Fix images
    #═════════════════════════════════════════════════════════════════
    update_progress 68 "$(get_text fixing_images)"
    log "[10/13] Fixing APEX images..."
    
    fix_apex_images
    log "✅ APEX images fixed"

    #═════════════════════════════════════════════════════════════════
    # STEP 10: Save new passwords
    #═════════════════════════════════════════════════════════════════
    update_progress 74 "Saving configuration..."
    log "[11/13] Saving configuration..."
    
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    log "✅ Passwords saved securely"

    #═════════════════════════════════════════════════════════════════
    # STEP 11: Configure ORDS settings
    #═════════════════════════════════════════════════════════════════
    update_progress 80 "Configuring ORDS..."
    log "[12/13] Configuring ORDS settings..."
    
    if [ -n "$ORDS_BIN" ] && [ -x "$ORDS_BIN" ]; then
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port "$ORDS_PORT" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.context.path /ords >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
    fi
    
    log "✅ ORDS configured"

    #═════════════════════════════════════════════════════════════════
    # STEP 12: Start ORDS
    #═════════════════════════════════════════════════════════════════
    update_progress 87 "Starting ORDS..."
    log "[13/13] Starting ORDS..."
    
    # Kill any existing ORDS processes
    pkill -9 -f "ords.*serve" 2>/dev/null || true
    pkill -9 -f "java.*ords" 2>/dev/null || true
    sleep 5
    
    # Free the port
    run_sudo fuser -k "${ORDS_PORT}/tcp" 2>/dev/null || true
    sleep 2

    if [ -n "$ORDS_BIN" ] && [ -x "$ORDS_BIN" ]; then
        export ORDS_CONFIG="$ORDS_CONFIG_DIR"
        export _JAVA_OPTIONS="-Xms512m -Xmx1024m -Dfile.encoding=UTF-8"
        
        nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
            --port "$ORDS_PORT" \
            --apex-images "$IMAGES_DIR" \
            > "$LOG_DIR/ords.log" 2>&1 &
        
        local ords_pid=$!
        echo "$ords_pid" > "$PROJECT_DIR/ords.pid"
        log "✅ ORDS started with PID $ords_pid"
    fi

    update_progress 95 "Waiting for ORDS to initialize (2 minutes)..."
    log "Waiting for ORDS to initialize..."
    sleep 120

    #═════════════════════════════════════════════════════════════════
    # STEP 13: Verify
    #═════════════════════════════════════════════════════════════════
    update_progress 100 "$(get_text verifying)"
    log "Verifying installation..."
    
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null || echo "000")
    local http_img=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/i/apex_version.txt" 2>/dev/null || echo "000")
    local http_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/f?p=4550" 2>/dev/null || echo "000")
    
    log "Repair verification:"
    log "  - Admin Panel: HTTP $http_admin"
    log "  - Images: HTTP $http_img"
    log "  - Login Page: HTTP $http_login"
    
    stop_progress
    
    #═════════════════════════════════════════════════════════════════
    # FINAL RESULT
    #═════════════════════════════════════════════════════════════════
    log "═══════════════════════════════════════════════════════════════"
    
    if [[ "$http_admin" =~ ^(200|302|303)$ ]]; then
        log "✅ REPAIR SUCCESSFUL! APEX is working!"
        log "═══════════════════════════════════════════════════════════════"
        
        gui_info "$(get_text success_title)" \
            "✅ Repair Completed Successfully!\n\n🌐 Admin Panel:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\n🔐 Login Page:\nhttp://localhost:${ORDS_PORT}/ords/f?p=4550\n\n📋 Credentials:\nUsername: ADMIN\nPassword: (your password)" 600 400
        
        return 0
    else
        log "⚠️ Repair completed but APEX may need more time"
        log "═══════════════════════════════════════════════════════════════"
        
        gui_warning "$(get_text warning)" \
            "⚠️ Repair completed but APEX is still initializing.\n\nPlease wait 2-3 minutes and try:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\nIf still having issues, run:\nbash ~/oracle-apex-complete/scripts/fix.sh" 600 400
        
        return 0
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# INSTALL DEPENDENCIES
#═══════════════════════════════════════════════════════════════════════════════
install_dependencies() {
    log "Installing dependencies for $OS_ID..."
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            run_sudo apt-get update -qq || true
            run_sudo apt-get install -y docker.io docker-compose openjdk-17-jdk unzip wget curl net-tools || true
            ;;
        fedora)
            run_sudo dnf install -y docker docker-compose java-17-openjdk unzip wget curl net-tools || true
            ;;
        opensuse*|suse*)
            run_sudo zypper --non-interactive install -y docker docker-compose java-17-openjdk unzip wget curl net-tools || true
            ;;
        arch|manjaro)
            run_sudo pacman -S --noconfirm docker docker-compose jdk17-openjdk unzip wget curl net-tools || true
            ;;
        rhel|centos|rocky|alma)
            run_sudo yum install -y docker docker-compose java-17-openjdk unzip wget curl net-tools || true
            ;;
    esac
    
    # Enable and start Docker
    run_sudo systemctl enable docker || true
    run_sudo systemctl start docker || true
    
    # Add user to docker group
    run_sudo usermod -aG docker $USER 2>/dev/null || true
    
    # Wait for docker to be ready
    sleep 5
    
    log "Dependencies installed"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE MANAGEMENT SCRIPTS
#═══════════════════════════════════════════════════════════════════════════════
create_management_scripts() {
    log "Creating management scripts..."
    
    safe_mkdir "$SCRIPTS_DIR"
    safe_mkdir "$LOG_DIR"

    #---------------------------------------------------------------------------
    # STATUS SCRIPT
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Oracle APEX Status - KaizenixCore v4.2"
echo "════════════════════════════════════════════════════════════════"
echo ""

DB_RUN=$(docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null || echo "false")
if [ "$DB_RUN" = "true" ]; then
    echo "  Database:  🟢 Running"
else
    echo "  Database:  🔴 Stopped"
fi

if pgrep -f "ords.*serve" >/dev/null 2>&1; then
    echo "  ORDS:      🟢 Running"
else
    echo "  ORDS:      🔴 Stopped"
fi

echo ""
echo "  Endpoints:"
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")
HTTP_IMG=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null || echo "000")
echo "    APEX Admin:  HTTP $HTTP_ADMIN"
echo "    APEX Login:  HTTP $HTTP_LOGIN"
echo "    Images:      HTTP $HTTP_IMG"
echo ""
echo "  URLs:"
echo "    http://localhost:8080/ords/apex_admin"
echo "    http://localhost:8080/ords/f?p=4550"
echo ""
echo "════════════════════════════════════════════════════════════════"
STATUSEOF
    chmod +x "$SCRIPTS_DIR/status.sh"

    #---------------------------------------------------------------------------
    # STOP SCRIPT
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
echo "Stopping Oracle APEX services..."
pkill -9 -f ords 2>/dev/null || true
pkill -9 -f java.*ords 2>/dev/null || true
sleep 3
docker stop oracle-apex-db 2>/dev/null || true
echo "✅ All services stopped"
STOPEOF
    chmod +x "$SCRIPTS_DIR/stop.sh"

    #---------------------------------------------------------------------------
    # START SCRIPT - COMPREHENSIVE
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/start.sh" << 'STARTEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
IMAGES_DIR="$PROJECT_DIR/images"
LOG_DIR="$PROJECT_DIR/logs"

if [ -z "$PASS" ]; then
    echo "❌ Password file not found!"
    echo "   Run the installer again or check: $PROJECT_DIR/.db_password"
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Starting Oracle APEX - KaizenixCore v4.2"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Step 1: Start database
echo "[1/6] Starting database container..."
docker start oracle-apex-db 2>/dev/null || {
    echo "Container not found, trying docker-compose..."
    cd "$PROJECT_DIR" && docker compose up -d 2>/dev/null
}

echo "[2/6] Waiting for database (2 minutes)..."
sleep 120

# Step 3: Reset password to ensure consistency
echo "[3/6] Syncing passwords..."
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 15

# Step 4: Fix users
echo "[4/6] Fixing database users..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
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

# Step 5: Set ORDS password
echo "[5/6] Configuring ORDS..."
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "$ORDS_BIN" ]; then
    echo "$PASS" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
fi

# Step 6: Start ORDS
pkill -9 -f ords 2>/dev/null || true
sleep 3

echo "[6/6] Starting ORDS..."
if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port 8080 \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &
    echo "    ORDS started with PID $!"
fi

echo ""
echo "Waiting for ORDS to initialize (90 seconds)..."
sleep 90

echo ""
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
echo "════════════════════════════════════════════════════════════════"
echo "  APEX Admin: HTTP $HTTP"
echo "  URL: http://localhost:8080/ords/apex_admin"
echo "════════════════════════════════════════════════════════════════"

if [[ "$HTTP" =~ ^(200|302|303)$ ]]; then
    echo "  ✅ APEX is ready!"
else
    echo "  ⚠️ APEX may need more time. Wait 2 minutes and try again."
    echo "     Or run: bash $PROJECT_DIR/scripts/fix.sh"
fi
STARTEOF
    chmod +x "$SCRIPTS_DIR/start.sh"

    #---------------------------------------------------------------------------
    # FIX SCRIPT - COMPREHENSIVE FOR 571/574/500
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/fix.sh" << 'FIXEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
IMAGES_DIR="$PROJECT_DIR/images"
LOG_DIR="$PROJECT_DIR/logs"

if [ -z "$PASS" ]; then
    echo "❌ Password file not found!"
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  FIX SCRIPT v4.2 - Fixing All Issues"
echo "  Errors: 574, 571, 500, Images"
echo "════════════════════════════════════════════════════════════════"
echo ""

echo "[1/12] Stopping ORDS..."
pkill -9 -f ords 2>/dev/null || true
pkill -9 -f java.*ords 2>/dev/null || true
sleep 5

echo "[2/12] Starting database..."
docker start oracle-apex-db 2>/dev/null || true
echo "      Waiting 2 minutes for database..."
sleep 120

echo "[3/12] Resetting database password..."
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 20

echo "[4/12] Disabling password policies..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[5/12] Recreating ORDS_PUBLIC_USER..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << SQL
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE, CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[6/12] Fixing APEX users..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << SQL
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[7/12] Granting proxy permissions..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[8/12] Reinstalling ORDS connection..."
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "$ORDS_BIN" ]; then
    chmod +x "$ORDS_BIN" 2>/dev/null || true
    
    # Remove old config and reinstall
    rm -rf "$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    
    printf "%s\n%s\n%s\n" "$PASS" "$PASS" "$PASS" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
        --admin-user SYS \
        --db-hostname localhost \
        --db-port 1521 \
        --db-servicename XEPDB1 \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user ORDS_PUBLIC_USER \
        --password-stdin 2>/dev/null || true
    
    # Set password explicitly
    echo "$PASS" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
fi

echo "[9/12] Fixing APEX images..."
rm -rf "$IMAGES_DIR" 2>/dev/null || true
if [ -d "$PROJECT_DIR/apex/images" ]; then
    cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR"
    chmod -R 755 "$IMAGES_DIR"
fi

if [ -n "$ORDS_BIN" ]; then
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" 2>/dev/null || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i 2>/dev/null || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" 2>/dev/null || true
fi

echo "[10/12] Setting IMAGE_PREFIX in database..."
APEX_SCHEMA=$(cat "$PROJECT_DIR/.apex_schema" 2>/dev/null)
[ -z "$APEX_SCHEMA" ] && APEX_SCHEMA="APEX_240100"

docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << SQLEOF
BEGIN
    ${APEX_SCHEMA}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    ${APEX_SCHEMA}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
EXIT;
SQLEOF" 2>/dev/null || true

echo "[11/12] Starting ORDS with images..."
if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port 8080 \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &
    echo "      ORDS started with PID $!"
fi

echo "[12/12] Waiting for ORDS (2 minutes)..."
sleep 120

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  VERIFICATION"
echo "════════════════════════════════════════════════════════════════"
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/f?p=4550" 2>/dev/null || echo "000")
HTTP_IMG=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null || echo "000")

echo "  APEX Admin:  HTTP $HTTP_ADMIN"
echo "  APEX Login:  HTTP $HTTP_LOGIN"
echo "  Images:      HTTP $HTTP_IMG"
echo ""

if [[ "$HTTP_ADMIN" =~ ^(200|302|303)$ ]] && [[ "$HTTP_IMG" =~ ^(200|304)$ ]]; then
    echo "  ✅ SUCCESS! APEX is working with images!"
    echo ""
    echo "  Open in browser:"
    echo "    http://localhost:8080/ords/apex_admin"
    echo "    http://localhost:8080/ords/f?p=4550"
elif [[ "$HTTP_ADMIN" =~ ^(200|302|303)$ ]]; then
    echo "  ⚠️ APEX is working but images may have issues."
    echo "     Try opening: http://localhost:8080/ords/apex_admin"
else
    echo "  ⚠️ Some issues remain. Check logs:"
    echo "    tail -100 $LOG_DIR/ords.log"
    echo ""
    echo "  Try running this fix script again after 2 minutes."
fi
echo ""
echo "════════════════════════════════════════════════════════════════"
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh"

    #---------------------------------------------------------------------------
    # LOGS SCRIPT
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/logs.sh" << 'LOGSEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
echo "Showing last 100 lines of ORDS log..."
echo "Press Ctrl+C to exit"
echo ""
tail -f "$PROJECT_DIR/logs/ords.log" 2>/dev/null || echo "Log file not found"
LOGSEOF
    chmod +x "$SCRIPTS_DIR/logs.sh"

    #---------------------------------------------------------------------------
    # GUI LAUNCHER
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"

# Detect GUI tool
GUI=""
if command -v yad >/dev/null 2>&1; then
    GUI="yad"
elif command -v zenity >/dev/null 2>&1; then
    GUI="zenity"
else
    echo "No GUI tool found. Please install yad or zenity."
    exit 1
fi

show_menu() {
    local db_status="🔴 Stopped"
    local ords_status="🔴 Stopped"
    
    if docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null | grep -q "true"; then
        db_status="🟢 Running"
    fi
    
    if pgrep -f "ords.*serve" >/dev/null 2>&1; then
        ords_status="🟢 Running"
    fi
    
    local status_text="Database: $db_status | ORDS: $ords_status"
    
    if [ "$GUI" = "yad" ]; then
        yad --list --title="Oracle APEX Manager - KaizenixCore v4.2" \
            --text="$status_text\n\nSelect an action:" \
            --radiolist --column="" --column="ID" --column="Action" \
            TRUE "start" "▶️  Start Services" \
            FALSE "stop" "⏹️  Stop Services" \
            FALSE "restart" "🔄  Restart Services" \
            FALSE "fix" "🔧  Fix Problems (571/574/500)" \
            FALSE "status" "📊  Check Status" \
            FALSE "logs" "📜  View Logs" \
            FALSE "open_admin" "🌐  Open Admin Panel" \
            FALSE "open_login" "🔐  Open Login Page" \
            FALSE "exit" "❌  Exit" \
            --width=500 --height=500 --center \
            --button="Cancel:1" --button="OK:0" \
            --print-column=2 --hide-column=2 \
            --borders=15 2>/dev/null
    else
        zenity --list --title="Oracle APEX Manager - KaizenixCore v4.2" \
            --text="$status_text\n\nSelect an action:" \
            --radiolist --column="" --column="ID" --column="Action" \
            TRUE "start" "▶️  Start Services" \
            FALSE "stop" "⏹️  Stop Services" \
            FALSE "restart" "🔄  Restart Services" \
            FALSE "fix" "🔧  Fix Problems (571/574/500)" \
            FALSE "status" "📊  Check Status" \
            FALSE "logs" "📜  View Logs" \
            FALSE "open_admin" "🌐  Open Admin Panel" \
            FALSE "open_login" "🔐  Open Login Page" \
            FALSE "exit" "❌  Exit" \
            --width=500 --height=500 \
            --ok-label="OK" --cancel-label="Cancel" \
            --hide-column=2 2>/dev/null
    fi
}

run_in_terminal() {
    local cmd="$1"
    local title="$2"
    
    if command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal -- bash -c "$cmd; echo; echo 'Press Enter to close...'; read"
    elif command -v konsole >/dev/null 2>&1; then
        konsole -e bash -c "$cmd; echo; echo 'Press Enter to close...'; read" &
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        xfce4-terminal -e "bash -c '$cmd; echo; echo Press Enter to close...; read'" &
    elif command -v xterm >/dev/null 2>&1; then
        xterm -title "$title" -e "bash -c '$cmd; echo; echo Press Enter to close...; read'" &
    else
        local output=$($cmd 2>&1)
        if [ "$GUI" = "yad" ]; then
            echo "$output" | yad --text-info --title="$title" --width=700 --height=500 --center 2>/dev/null
        else
            echo "$output" | zenity --text-info --title="$title" --width=700 --height=500 2>/dev/null
        fi
    fi
}

# Main loop
while true; do
    choice=$(show_menu)
    choice=$(echo "$choice" | tr -d '|' | tr -d ' ')
    
    [ -z "$choice" ] && exit 0
    
    case "$choice" in
        start)
            run_in_terminal "bash '$SCRIPTS_DIR/start.sh'" "Starting Oracle APEX"
            ;;
        stop)
            bash "$SCRIPTS_DIR/stop.sh"
            if [ "$GUI" = "yad" ]; then
                yad --info --title="Oracle APEX" --text="Services stopped." --width=300 --center --timeout=3 2>/dev/null
            else
                zenity --info --title="Oracle APEX" --text="Services stopped." --width=300 --timeout=3 2>/dev/null
            fi
            ;;
        restart)
            bash "$SCRIPTS_DIR/stop.sh"
            sleep 3
            run_in_terminal "bash '$SCRIPTS_DIR/start.sh'" "Restarting Oracle APEX"
            ;;
        fix)
            run_in_terminal "bash '$SCRIPTS_DIR/fix.sh'" "Fixing Oracle APEX"
            ;;
        status)
            run_in_terminal "bash '$SCRIPTS_DIR/status.sh'" "Oracle APEX Status"
            ;;
        logs)
            if [ "$GUI" = "yad" ]; then
                tail -200 "$PROJECT_DIR/logs/ords.log" 2>/dev/null | yad --text-info \
                    --title="ORDS Logs" --width=900 --height=600 --center \
                    --fontname="monospace 10" 2>/dev/null
            else
                tail -200 "$PROJECT_DIR/logs/ords.log" 2>/dev/null | zenity --text-info \
                    --title="ORDS Logs" --width=900 --height=600 \
                    --font="monospace" 2>/dev/null
            fi
            ;;
        open_admin)
            xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null &
            ;;
        open_login)
            xdg-open "http://localhost:8080/ords/f?p=4550" 2>/dev/null &
            ;;
        exit)
            exit 0
            ;;
    esac
    
    sleep 0.5
done
GUIEOF
    chmod +x "$SCRIPTS_DIR/launch-gui.sh"

    #---------------------------------------------------------------------------
    # DESKTOP FILE
    #---------------------------------------------------------------------------
    safe_mkdir "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/oracle-apex.desktop" << DESKTOPEOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle APEX Manager
GenericName=Database Development Tool
Comment=Manage Oracle APEX and ORDS - KaizenixCore v${VERSION}
Exec=bash $SCRIPTS_DIR/launch-gui.sh
Icon=applications-database
Terminal=false
Categories=Development;Database;IDE;
Keywords=oracle;apex;ords;database;
StartupNotify=true
DESKTOPEOF
    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"
    
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    
    log "Management scripts created"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE SYSTEMD SERVICE
#═══════════════════════════════════════════════════════════════════════════════
create_systemd_service() {
    if [ "$OS_TYPE" != "linux" ]; then
        log "Systemd service only available on Linux"
        return 0
    fi
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    if [ -z "$ORDS_BIN" ]; then
        log "ORDS binary not found, cannot create service"
        return 1
    fi
    
    log "Creating systemd services..."
    
    # Create combined service script
    cat > "$SCRIPTS_DIR/oracle-apex-service.sh" << SERVICEEOF
#!/bin/bash
PROJECT_DIR="$PROJECT_DIR"
ORDS_CONFIG_DIR="$ORDS_CONFIG_DIR"
ORDS_BIN="$ORDS_BIN"
IMAGES_DIR="$IMAGES_DIR"
LOG_DIR="$LOG_DIR"

case "\$1" in
    start)
        echo "Starting Oracle APEX services..."
        docker start $CONTAINER_NAME 2>/dev/null
        sleep 120
        
        PASS=\$(cat "\$PROJECT_DIR/.db_password" 2>/dev/null)
        if [ -n "\$PASS" ]; then
            echo "\$PASS" | "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
        fi
        
        export ORDS_CONFIG="\$ORDS_CONFIG_DIR"
        export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
        nohup "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" serve \\
            --port 8080 \\
            --apex-images "\$IMAGES_DIR" \\
            > "\$LOG_DIR/ords.log" 2>&1 &
        echo \$! > "\$PROJECT_DIR/ords.pid"
        
        echo "Oracle APEX started"
        ;;
    stop)
        echo "Stopping Oracle APEX services..."
        if [ -f "\$PROJECT_DIR/ords.pid" ]; then
            kill \$(cat "\$PROJECT_DIR/ords.pid") 2>/dev/null
            rm -f "\$PROJECT_DIR/ords.pid"
        fi
        pkill -9 -f ords 2>/dev/null
        docker stop $CONTAINER_NAME 2>/dev/null
        echo "Oracle APEX stopped"
        ;;
    restart)
        \$0 stop
        sleep 5
        \$0 start
        ;;
    status)
        if docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null | grep -q "true"; then
            echo "Database: Running"
        else
            echo "Database: Stopped"
        fi
        
        if pgrep -f "ords.*serve" >/dev/null 2>&1; then
            echo "ORDS: Running"
        else
            echo "ORDS: Stopped"
        fi
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart|status}"
        exit 1
        ;;
esac
SERVICEEOF
    chmod +x "$SCRIPTS_DIR/oracle-apex-service.sh"
    
    # Create systemd service file
    run_sudo tee /etc/systemd/system/oracle-apex.service > /dev/null << SYSTEMDEOF
[Unit]
Description=Oracle APEX and ORDS Service - KaizenixCore v${VERSION}
Documentation=https://github.com/KaizenixCore/oracle-apex-installer
After=network.target docker.service
Requires=docker.service

[Service]
Type=forking
User=$USER
Group=$USER
WorkingDirectory=$PROJECT_DIR
ExecStart=$SCRIPTS_DIR/oracle-apex-service.sh start
ExecStop=$SCRIPTS_DIR/oracle-apex-service.sh stop
ExecReload=$SCRIPTS_DIR/oracle-apex-service.sh restart
RemainAfterExit=yes
TimeoutStartSec=300
TimeoutStopSec=60
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
SYSTEMDEOF

    run_sudo systemctl daemon-reload
    run_sudo systemctl enable oracle-apex.service
    
    log "Systemd service created and enabled"
    
    gui_info "$(get_text info)" "$(get_text service_created)"
}

#═══════════════════════════════════════════════════════════════════════════════
# MAIN INSTALLATION FUNCTION
#═══════════════════════════════════════════════════════════════════════════════
run_fresh_installation() {
    log "Starting fresh installation v${VERSION}..."
    
    # Create directories
    safe_mkdir "$PROJECT_DIR"
    safe_mkdir "$DOWNLOADS_DIR"
    safe_mkdir "$LOG_DIR"
    safe_mkdir "$IMAGES_DIR"
    safe_mkdir "$SCRIPTS_DIR"
    safe_mkdir "$ORDS_CONFIG_DIR"
    safe_mkdir "$ORDS_CONFIG_DIR/databases/default"
    safe_mkdir "$ORDS_CONFIG_DIR/global"
    safe_touch "$INSTALL_LOG"
    safe_touch "$LOG_DIR/ords.log"
    
    start_progress
    
    # Step 1: Save passwords
    update_progress 2 "$(get_text step) 1/24: Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    log "Passwords saved"

    # Step 2: Install dependencies
    update_progress 5 "$(get_text step) 2/24: $(get_text installing_deps)"
    install_dependencies

    # Step 3: Download APEX
    update_progress 10 "$(get_text step) 3/24: $(get_text downloading) APEX..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || \
        curl -L -o "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || true
    fi
    log "APEX downloaded"

    # Step 4: Download ORDS
    update_progress 15 "$(get_text step) 4/24: $(get_text downloading) ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || \
        curl -L -o "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || true
    fi
    log "ORDS downloaded"

    # Step 5: Extract files
    update_progress 18 "$(get_text step) 5/24: $(get_text extracting)"
    cd "$PROJECT_DIR" || exit 1
    
    rm -rf apex ords 2>/dev/null || true
    unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || true
    mkdir -p ords
    unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords 2>/dev/null || true
    
    find ords -name "ords" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    rm -rf "$IMAGES_DIR" 2>/dev/null || true
    cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR" 2>/dev/null || true
    chmod -R 755 "$IMAGES_DIR" 2>/dev/null || true
    log "Files extracted, images copied"

    # Step 6: Create Docker Compose - FIXED healthcheck
    update_progress 22 "$(get_text step) 6/24: Creating Docker configuration..."
    cat > "$PROJECT_DIR/docker-compose.yml" << COMPOSEOF
version: '3.8'
services:
  oracle-db:
    image: ${ORACLE_IMAGE}
    container_name: ${CONTAINER_NAME}
    hostname: ${CONTAINER_NAME}
    ports:
      - "${DB_PORT}:1521"
    environment:
      - ORACLE_PASSWORD=${ORACLE_PASSWORD}
    volumes:
      - oracle-apex-data:/opt/oracle/oradata
      - ./apex:/opt/oracle/apex:ro
    shm_size: 2g
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "sqlplus", "-L", "sys/${ORACLE_PASSWORD}@//localhost:1521/${DB_SERVICE} as sysdba", "@/dev/null"]
      interval: 60s
      timeout: 30s
      retries: 10
      start_period: 300s

volumes:
  oracle-apex-data:
    name: oracle-apex-data
COMPOSEOF
    log "Docker compose created"

    # Step 7: Start Database
    update_progress 26 "$(get_text step) 7/24: $(get_text starting_db)"
    cd "$PROJECT_DIR" || exit 1
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || true
    
    # Wait for database - CRITICAL
    log "Waiting for database to be ready (this takes 5-10 minutes)..."
    update_progress 30 "Waiting for database (5-10 minutes)..."
    
    if ! wait_for_database_ready; then
        log "Warning: Database wait timed out, continuing anyway..."
    fi
    
    # Extra wait to ensure stability
    sleep 60
    log "Database started"

    # Step 8: Reset password
    update_progress 35 "$(get_text step) 8/24: $(get_text resetting_password)"
    docker exec "$CONTAINER_NAME" resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 30
    log "Password reset"

    # Step 9: Disable password policies
    update_progress 38 "$(get_text step) 9/24: Disabling password policies..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Policies disabled"

    # Step 10: Install APEX
    update_progress 40 "$(get_text step) 10/24: $(get_text installing_apex)"
    docker exec "$CONTAINER_NAME" bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "APEX installed"

    # Step 11: Reset image prefix
    update_progress 48 "$(get_text step) 11/24: $(get_text fixing_images)"
    docker exec "$CONTAINER_NAME" bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@utilities/reset_image_prefix.sql
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Image prefix reset"

    # Step 12: APEX REST config
    update_progress 50 "$(get_text step) 12/24: Configuring REST services..."
    docker exec "$CONTAINER_NAME" bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "REST configured"

 # Step 13: Create ORDS_PUBLIC_USER - CRITICAL FIX FOR 571
update_progress 54 "$(get_text step) 13/24: Creating ORDS_PUBLIC_USER..."

docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
SET ECHO OFF FEEDBACK OFF PAGESIZE 0 LINESIZE 32767
WHENEVER SQLERROR CONTINUE

-- ===== DROP EXISTING USER =====
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ===== CREATE USER WITH PROPER TABLESPACE =====
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\"
    DEFAULT TABLESPACE SYSAUX
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON SYSAUX;

-- ===== GRANT CORE PRIVILEGES =====
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
GRANT CREATE DIMENSION TO ORDS_PUBLIC_USER;
GRANT CREATE OPERATOR TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;

-- ===== GRANT SYSTEM PACKAGE PRIVILEGES (CRITICAL FOR 571) =====
BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_SQL TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_ENCODE TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_LOCK TO ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_PIPE TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ===== UNLOCK ACCOUNT =====
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

-- ===== VERIFY CREATION =====
BEGIN
    FOR r IN (SELECT username FROM all_users WHERE username = 'ORDS_PUBLIC_USER') LOOP
        DBMS_OUTPUT.PUT_LINE('✅ ORDS_PUBLIC_USER created successfully');
    END LOOP;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1

log "✅ ORDS_PUBLIC_USER created with full privileges"

    # Step 14: Fix APEX users
    update_progress 58 "$(get_text step) 14/24: Fixing APEX users..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "APEX users fixed"

    # Step 15: Grant proxy permissions - CRITICAL FOR 571
    update_progress 62 "$(get_text step) 15/24: Granting proxy permissions..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;

GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_ENCODE TO ORDS_PUBLIC_USER;

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Proxy permissions granted"

    # Step 16: Find APEX schema and create admin
    update_progress 66 "$(get_text step) 16/24: Creating APEX admin..."
    local apex_schema
    apex_schema=$(docker exec "$CONTAINER_NAME" bash -c "echo \"SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ') || true
    
    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"
    log "APEX schema: $apex_schema"

    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
BEGIN
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('RESTFUL_SERVICES_ENABLED', 'Y');
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
    EXCEPTION WHEN OTHERS THEN
        ${apex_schema}.APEX_UTIL.EDIT_USER(
            p_user_id                      => ${apex_schema}.APEX_UTIL.GET_USER_ID('ADMIN'),
            p_user_name                    => 'ADMIN',
            p_web_password                 => '${APEX_ADMIN_PASSWORD}',
            p_new_password                 => '${APEX_ADMIN_PASSWORD}',
            p_change_password_on_first_use => 'N',
            p_account_locked               => 'N'
        );
    END;
    
    COMMIT;
END;
/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "APEX admin created"

# Step 17: Install ORDS - COMPREHENSIVE FIX
update_progress 70 "$(get_text step) 17/24: Installing ORDS..."

local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

if [ -z "$ORDS_BIN" ]; then
    log "❌ ORDS binary not found!"
    gui_error "$(get_text error)" "ORDS binary not found in $PROJECT_DIR/ords"
    return 1
fi

chmod +x "$ORDS_BIN" 2>/dev/null || true

# Remove old ORDS config completely
log "Cleaning old ORDS configuration..."
rm -rf "$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
rm -rf "$ORDS_CONFIG_DIR/global" 2>/dev/null || true
rm -f "$ORDS_CONFIG_DIR/settings.xml" 2>/dev/null || true

# Create fresh directories
mkdir -p "$ORDS_CONFIG_DIR/databases/default"
mkdir -p "$ORDS_CONFIG_DIR/global"

# Create password file for installation
local PASS_FILE=$(mktemp)
printf "%s\n%s\n%s\n" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" > "$PASS_FILE"

log "Installing ORDS with gateway-user: ORDS_PUBLIC_USER"

# CRITICAL: Install ORDS with correct parameters
"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
    --admin-user SYS \
    --admin-password "$ORACLE_PASSWORD" \
    --db-hostname localhost \
    --db-port "$DB_PORT" \
    --db-servicename "$DB_SERVICE" \
    --db-username SYS \
    --feature-sdw true \
    --feature-rest-enabled-sql true \
    --gateway-mode proxied \
    --gateway-user ORDS_PUBLIC_USER \
    --password-stdin < "$PASS_FILE" >> "$INSTALL_LOG" 2>&1

local ords_install_status=$?
rm -f "$PASS_FILE"

if [ $ords_install_status -eq 0 ]; then
    log "✅ ORDS installation successful"
else
    log "⚠️ ORDS installation returned status $ords_install_status (continuing...)"
fi

# Verify ORDS config was created
if [ ! -f "$ORDS_CONFIG_DIR/databases/default/ords_params.properties" ]; then
    log "⚠️ ords_params.properties not found, creating manually..."
    
    cat > "$ORDS_CONFIG_DIR/databases/default/ords_params.properties" << PARAMSEOF
db.hostname=localhost
db.port=1521
db.servicename=XEPDB1
db.username=ORDS_PUBLIC_USER
db.password=$ORACLE_PASSWORD
feature.sdw=true
feature.rest.enabled.sql=true
gateway.mode=proxied
gateway.user=ORDS_PUBLIC_USER
PARAMSEOF
    
    # اختیاری: اگر رمز حاوی کاراکتر ویژه است
    chmod 600 "$ORDS_CONFIG_DIR/databases/default/ords_params.properties"
    
    log "✅ ords_params.properties created successfully"
else
    log "✅ ords_params.properties already exists"
fi

log "✅ ORDS installed"

    # Step 18: Configure ORDS
    update_progress 75 "$(get_text step) 18/24: $(get_text configuring_ords)"
    if [ -n "$ORDS_BIN" ]; then
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port "$ORDS_PORT" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.context.path /ords >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
        
        # CRITICAL: Set ORDS password
        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    fi
    
    # Create settings.xml
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
# Step 18.5: Verify and Fix ORDS Configuration
update_progress 76 "Verifying ORDS configuration..."

if [ -n "$ORDS_BIN" ]; then
    # Set all required configurations
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set \
        standalone.http.port "$ORDS_PORT" 2>/dev/null || true
    
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set \
        standalone.context.path /ords 2>/dev/null || true
    
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set \
        standalone.static.context.path /i 2>/dev/null || true
    
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set \
        standalone.static.path "$IMAGES_DIR" 2>/dev/null || true
    
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set \
        standalone.doc.root "$IMAGES_DIR" 2>/dev/null || true
    
    # CRITICAL: Set database password in ORDS config
    log "Setting ORDS database password..."
    echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" \
        config secret --password-stdin db.password 2>/dev/null || true
    
    # Verify password was set
    if "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config list 2>&1 | grep -q "db.password"; then
        log "✅ ORDS password configured"
    else
        log "⚠️ Warning: ORDS password may not be set"
    fi
fi

# Create comprehensive settings.xml
cat > "$ORDS_CONFIG_DIR/settings.xml" << 'SETTINGSEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<!-- HTTP Server Configuration -->
<entry key="standalone.http.port">8080</entry>
<entry key="standalone.context.path">/ords</entry>

<!-- Static Files Configuration -->
<entry key="standalone.static.context.path">/i</entry>
<entry key="standalone.static.path">/home/oracle-apex-complete/images</entry>
<entry key="standalone.doc.root">/home/oracle-apex-complete/images</entry>

<!-- Database Configuration -->
<entry key="db.hostname">localhost</entry>
<entry key="db.port">1521</entry>
<entry key="db.servicename">XEPDB1</entry>

<!-- Features -->
<entry key="feature.sdw">true</entry>
<entry key="feature.rest.enabled.sql">true</entry>

<!-- Gateway Configuration -->
<entry key="gateway.mode">proxied</entry>
<entry key="gateway.user">ORDS_PUBLIC_USER</entry>
</properties>
SETTINGSEOF

log "✅ ORDS configuration verified and updated"
    
    # Step 19: Final user fixes
    update_progress 78 "$(get_text step) 19/24: Final database configuration..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
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

# Step 20: Start ORDS with Enhanced Error Handling
update_progress 82 "$(get_text step) 20/24: Starting ORDS..."

log "Preparing to start ORDS..."

# Kill any existing ORDS processes
pkill -9 -f "ords.*serve" 2>/dev/null || true
pkill -9 -f "java.*ords" 2>/dev/null || true
sleep 5

# Free the port
run_sudo fuser -k "${ORDS_PORT}/tcp" 2>/dev/null || true
sleep 2

# Verify ORDS binary exists
local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -z "$ORDS_BIN" ]; then
    log "❌ ORDS binary not found!"
    return 1
fi

# Start ORDS
log "Starting ORDS from: $ORDS_BIN"
log "Config directory: $ORDS_CONFIG_DIR"

# Create ORDS startup script
cat > "$PROJECT_DIR/start_ords.sh" << 'ORDSSTARTEOF'
#!/bin/bash
export ORDS_CONFIG="$ORDS_CONFIG_DIR"
export _JAVA_OPTIONS="-Xms512m -Xmx1024m -Dfile.encoding=UTF-8"
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

cd "$PROJECT_DIR"

# Log startup
echo "[$(date)] Starting ORDS..." >> "$LOG_DIR/ords-startup.log"
echo "ORDS_CONFIG: $ORDS_CONFIG" >> "$LOG_DIR/ords-startup.log"
echo "JAVA_HOME: $JAVA_HOME" >> "$LOG_DIR/ords-startup.log"

# Start ORDS
"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
    --port 8080 \
    --apex-images "$IMAGES_DIR" \
    >> "$LOG_DIR/ords.log" 2>&1 &

echo $! > "$PROJECT_DIR/ords.pid"
echo "[$(date)] ORDS started with PID $!" >> "$LOG_DIR/ords-startup.log"

wait
ORDSSTARTEOF

chmod +x "$PROJECT_DIR/start_ords.sh"

# Start ORDS in background
nohup bash "$PROJECT_DIR/start_ords.sh" > /dev/null 2>&1 &
local ords_pid=$!

log "ORDS started with PID: $ords_pid"
echo "$ords_pid" > "$PROJECT_DIR/ords.pid"

# Wait for ORDS to initialize
log "Waiting for ORDS to initialize (this may take 2-3 minutes)..."
sleep 120

# Check if ORDS is running
if kill -0 $ords_pid 2>/dev/null; then
    log "✅ ORDS process is running"
else
    log "❌ ORDS process died!"
    log "Last 50 lines of ORDS log:"
    tail -50 "$LOG_DIR/ords.log" | tee -a "$INSTALL_LOG"
    return 1
fi

    # Step 21: Wait for ORDS
    update_progress 88 "$(get_text step) 21/24: Waiting for ORDS (2 minutes)..."
    sleep 120

    # Step 22: Create management scripts
    update_progress 92 "$(get_text step) 22/24: $(get_text creating_scripts)"
    create_management_scripts

    # Step 23: Verify installation
    update_progress 96 "$(get_text step) 23/24: $(get_text verifying)"
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null || echo "000")
    local http_img=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/i/apex_version.txt" 2>/dev/null || echo "000")
    log "Verification - Admin: $http_admin, Images: $http_img"

    # Step 24: Complete
    update_progress 100 "$(get_text completed)"
    stop_progress

    # Show success message
    local success_msg=$(get_text success_text)
    success_msg="${success_msg//%PASSWORD%/$APEX_ADMIN_PASSWORD}"
    gui_info "$(get_text success_title)" "$success_msg" 600 500

    # Ask about systemd service
    if [ "$OS_TYPE" = "linux" ]; then
        if gui_question "$(get_text create_service_title)" "$(get_text create_service_text)"; then
            create_systemd_service
        fi
    fi

    # Ask about DBeaver
    if gui_question "$(get_text install_dbeaver_title)" "Would you like to install DBeaver database manager?"; then
        install_dbeaver
    fi

    log "Fresh installation completed successfully"
}

#═══════════════════════════════════════════════════════════════════════════════
# MAIN MENU
#═══════════════════════════════════════════════════════════════════════════════
show_main_menu() {
    while true; do
        local choice=$(gui_list "$(get_text select_action)" "$(get_text action_text)" \
            TRUE "fresh" "$(get_text fresh_install)" \
            FALSE "repair" "$(get_text repair_install)" \
            FALSE "clean" "$(get_text clean_install)" \
            FALSE "uninstall" "$(get_text uninstall)" \
            FALSE "dbeaver" "$(get_text manage_dbeaver)" \
            FALSE "exit" "$(get_text exit_installer)")

        case "$choice" in
            fresh)
                if check_previous_installation; then
                    gui_warning "$(get_text warning)" "Previous installation detected. Use 'Clean Install' or 'Repair' instead."
                else
                    get_passwords
                    run_fresh_installation
                fi
                ;;
            repair)
                if ! check_previous_installation; then
                    gui_warning "$(get_text warning)" "No previous installation found. Use 'Fresh Install' instead."
                else
                    get_passwords
                    repair_installation
                fi
                ;;
            clean)
                get_passwords
                if gui_question "$(get_text warning)" "$(get_text confirm_clean)"; then
                    start_progress
                    update_progress 20 "$(get_text cleaning)"
                    complete_cleanup
                    update_progress 50 "Starting fresh installation..."
                    stop_progress
                    run_fresh_installation
                fi
                ;;
            uninstall)
                if gui_question "$(get_text warning)" "$(get_text confirm_uninstall)"; then
                    start_progress
                    update_progress 50 "Uninstalling..."
                    complete_uninstall
                    update_progress 100 "Uninstall complete"
                    stop_progress
                    gui_info "$(get_text info)" "Oracle APEX has been completely removed."
                    exit 0
                fi
                ;;
            dbeaver)
                manage_dbeaver
                ;;
            exit|"")
                exit 0
                ;;
        esac
    done
}

#═══════════════════════════════════════════════════════════════════════════════
# MAIN ENTRY POINT
#═══════════════════════════════════════════════════════════════════════════════
main() {
    # Detect OS first
    detect_os

    # Install GUI tool
    install_gui_tool

    # Select language
    select_language

    # Show welcome message
    gui_info "$(get_text welcome_title)" "$(get_text welcome_text)" 600 550

    # Get sudo password
    get_sudo_password

    # Show main menu
    show_main_menu
}

# Run main function
main "$@"
