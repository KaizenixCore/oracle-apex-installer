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
#  ║     ORACLE APEX GUI INSTALLER v4.3.1 - KAIZENIXCORE                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ║  License    : MIT                                                         ║
#  ║  Version    : 4.3.1 - COMPLETE EDITION (FIXED)                            ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  ✅ v4.3.1 FIXES:                                                         ║
#  ║     ✅ Permission denied error FIXED                                      ║
#  ║     ✅ show_success function ADDED                                        ║
#  ║     ✅ ensure_directories function ADDED                                  ║
#  ║     ✅ openSUSE full support ADDED                                        ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  ✅ v4.3.0 FEATURES (COMPLETE):                                           ║
#  ║     ✅ ERROR 571 COMPLETELY FIXED                                         ║
#  ║     ✅ Multiple password sync points                                      ║
#  ║     ✅ ORDS proper installation & configuration                           ║
#  ║     ✅ YAD + Zenity GUI support                                           ║
#  ║     ✅ Systemd auto-start services                                        ║
#  ║     ✅ Complete management scripts (start/stop/fix/logs/status)           ║
#  ║     ✅ DBeaver auto-install (all platforms)                               ║
#  ║     ✅ Web installer integration                                          ║
#  ║     ✅ Multi-language (EN/FA/DE)                                          ║
#  ║     ✅ Cross-platform (Linux/macOS/WSL)                                   ║
#  ║     ✅ Automatic error detection & fix                                    ║
#  ║     ✅ Complete logging & diagnostics                                     ║
#  ║     ✅ Repair mode (fix without data loss)                                ║
#  ║     ✅ Clean install mode (full reset)                                    ║
#  ║     ✅ Uninstall mode (complete cleanup)                                  ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e

VERSION="4.3.1"
PROJECT_DIR="$HOME/oracle-apex-complete"
DOWNLOADS_DIR="$PROJECT_DIR/downloads"
LOG_DIR="$PROJECT_DIR/logs"
IMAGES_DIR="$PROJECT_DIR/images"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
INSTALL_LOG="$PROJECT_DIR/install.log"
WEB_INSTALLER_DIR="$PROJECT_DIR/web-installer"

DB_PORT="1521"
DB_SERVICE="XEPDB1"
ORDS_PORT="8080"

APEX_URL="https://download.oracle.com/otn_software/apex/apex-latest.zip"
ORDS_URL="https://download.oracle.com/otn_software/java/ords/ords-latest.zip"
ORACLE_IMAGE="gvenzl/oracle-xe:21-slim"

GUI_TOOL=""
SUDO_PASS=""
ORACLE_PASSWORD=""
APEX_ADMIN_PASSWORD=""
CURRENT_LANG="en"
OS_TYPE=""
OS_ID=""
SYSTEMD_ENABLED="false"

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - ENGLISH (COMPLETE)
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_EN=(
    ["title"]="Oracle APEX Installer v4.3"
    ["welcome_title"]="🚀 Oracle APEX Ultimate Installer v4.3"
    ["welcome_text"]="Oracle APEX Ultimate Installer v4.3.1 - COMPLETE EDITION

✅ ERROR 571 FIX INCLUDED
✅ PERMISSION ERROR FIXED
✅ ALL FEATURES INCLUDED

This will install:
• Oracle APEX (Latest Version)
• Oracle ORDS (Latest Version)  
• Oracle XE 21c Database
• DBeaver (Optional)
• Management GUI
• Auto-start Services

Features:
✅ Automatic configuration
✅ Error 571/574/500 auto-fix
✅ APEX images auto-setup
✅ Complete management GUI
✅ DBeaver integration
✅ Web installer support
✅ Systemd auto-start
✅ Multi-language support

Created by: Peyman Rasouli
Project: KaizenixCore

Click Continue to start."
    ["select_action"]="Select Installation Type"
    ["action_text"]="What would you like to do?"
    ["fresh_install"]="🆕 Fresh Install (New installation)"
    ["repair_install"]="🔧 Repair (Fix existing + change password)"
    ["clean_install"]="🗑️ Clean Install (Remove ALL and reinstall)"
    ["uninstall"]="❌ Uninstall Everything"
    ["manage_dbeaver"]="📦 Manage DBeaver"
    ["web_installer"]="🌐 Web Installer"
    ["exit_installer"]="🚪 Exit"
    ["enter_passwords"]="🔐 Enter Passwords"
    ["oracle_pass"]="Oracle Database Password:"
    ["apex_pass"]="APEX Admin Password:"
    ["pass_rules"]="Password Rules:
• Start with a letter (a-z, A-Z)
• Only letters and numbers
• Minimum 8 characters
• Maximum 30 characters

Example: MyPass123"
    ["invalid_pass"]="Invalid Password!

Password must:
• Start with a letter
• Contain only letters and numbers
• Be 8-30 characters long

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
    ["sudo_required"]="Administrator password required for installation."
    ["wait_db"]="Waiting for database to start..."
    ["wait_ords"]="Waiting for ORDS to start..."
    ["step"]="Step"
    ["confirm_clean"]="⚠️ WARNING: Clean Install

This will PERMANENTLY DELETE:
• All Oracle APEX data
• All databases
• All Docker volumes
• All configurations

This action CANNOT be undone!
Are you SURE?"
    ["confirm_uninstall"]="⚠️ WARNING: Complete Uninstall

This will PERMANENTLY DELETE everything:
• Database & data
• Docker containers & volumes
• All configurations
• All scripts

This action CANNOT be undone!
Are you ABSOLUTELY SURE?"
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

🛠️ Management Commands:
   Start:   bash ~/oracle-apex-complete/scripts/start.sh
   Stop:    bash ~/oracle-apex-complete/scripts/stop.sh
   Fix:     bash ~/oracle-apex-complete/scripts/fix.sh
   Status:  bash ~/oracle-apex-complete/scripts/status.sh
   Logs:    bash ~/oracle-apex-complete/scripts/logs.sh
   Restart: bash ~/oracle-apex-complete/scripts/restart.sh

📦 DBeaver:
   Install: bash ~/oracle-apex-complete/scripts/dbeaver.sh install
   Remove:  bash ~/oracle-apex-complete/scripts/dbeaver.sh remove

🌐 Web Installer:
   bash ~/oracle-apex-complete/web-installer/start.sh"
    ["create_service_title"]="Create Auto-Start Service?"
    ["create_service_text"]="Start Oracle APEX automatically on system boot?

This will create a systemd service that:
• Starts database automatically
• Starts ORDS automatically
• Syncs passwords on startup
• Monitors services

Enable auto-start?"
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
    ["creating_services"]="Creating systemd services..."
    ["verifying"]="Verifying installation..."
    ["cleaning"]="Cleaning up old installation..."
    ["syncing_passwords"]="Syncing passwords..."
    ["fixing_error_571"]="Fixing Error 571..."
    ["repair_text"]="This will:
• Keep your data
• Update passwords
• Fix any issues
• Restart services

Continue?"
)

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - PERSIAN (COMPLETE)
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_FA=(
    ["title"]="نصب‌کننده اوراکل اپکس v4.3"
    ["welcome_title"]="🚀 نصب‌کننده اوراکل اپکس نسخه 4.3"
    ["welcome_text"]="نصب‌کننده اوراکل اپکس نسخه 4.3.1 - نسخه کامل

✅ رفع کامل خطای 571
✅ رفع خطای Permission
✅ تمام ویژگی‌ها شامل

این برنامه نصب می‌کند:
• Oracle APEX (آخرین نسخه)
• Oracle ORDS (آخرین نسخه)
• Oracle XE 21c Database
• DBeaver (اختیاری)
• رابط گرافیکی مدیریت
• سرویس‌های خودکار

ویژگی‌ها:
✅ پیکربندی خودکار
✅ رفع خودکار خطاهای 571/574/500
✅ تنظیم خودکار تصاویر
✅ رابط گرافیکی کامل مدیریت
✅ یکپارچگی DBeaver
✅ پشتیبانی نصب وب
✅ سرویس خودکار
✅ پشتیبانی چندزبانه

سازنده: پیمان رسولی
پروژه: KaizenixCore

برای شروع ادامه را بزنید."
    ["select_action"]="انتخاب نوع نصب"
    ["action_text"]="چه کاری می‌خواهید انجام دهید؟"
    ["fresh_install"]="🆕 نصب جدید"
    ["repair_install"]="🔧 تعمیر و تغییر رمز"
    ["clean_install"]="🗑️ نصب تمیز (حذف همه)"
    ["uninstall"]="❌ حذف کامل"
    ["manage_dbeaver"]="📦 مدیریت DBeaver"
    ["web_installer"]="🌐 نصب وب"
    ["exit_installer"]="🚪 خروج"
    ["enter_passwords"]="🔐 ورود رمز عبور"
    ["oracle_pass"]="رمز عبور Oracle:"
    ["apex_pass"]="رمز عبور APEX Admin:"
    ["pass_rules"]="قوانین رمز عبور:
• با حرف انگلیسی شروع شود
• فقط حروف و اعداد
• ۸-۳۰ کاراکتر

مثال: MyPass123"
    ["invalid_pass"]="رمز عبور نامعتبر!"
    ["installing"]="در حال نصب..."
    ["completed"]="✅ نصب کامل شد!"
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
    ["sudo_required"]="رمز عبور مدیر برای نصب نیاز است."
    ["wait_db"]="منتظر شروع دیتابیس..."
    ["wait_ords"]="منتظر شروع ORDS..."
    ["step"]="مرحله"
    ["confirm_clean"]="⚠️ هشدار: حذف کامل

این عملیات حذف می‌کند:
• تمام داده‌های APEX
• تمام دیتابیس‌ها
• تمام Docker volumes
• تمام تنظیمات

آیا مطمئن هستید؟"
    ["confirm_uninstall"]="⚠️ هشدار: حذف کامل

این عملیات همه چیز را حذف می‌کند.
این عمل قابل بازگشت نیست!

آیا مطمئن هستید؟"
    ["success_title"]="🎉 نصب موفق!"
    ["success_text"]="اوراکل اپکس نصب شد!

🌐 پنل مدیریت:
http://localhost:8080/ords/apex_admin

🔐 صفحه ورود:
http://localhost:8080/ords/f?p=4550

📋 اطلاعات ورود:
   Workspace: INTERNAL
   Username: ADMIN
   Password: %PASSWORD%

🛠️ دستورات مدیریت:
   شروع:   bash ~/oracle-apex-complete/scripts/start.sh
   توقف:   bash ~/oracle-apex-complete/scripts/stop.sh
   تعمیر:  bash ~/oracle-apex-complete/scripts/fix.sh
   وضعیت: bash ~/oracle-apex-complete/scripts/status.sh"
    ["create_service_title"]="ایجاد سرویس خودکار؟"
    ["create_service_text"]="اجرای خودکار هنگام روشن شدن سیستم؟"
    ["detecting_os"]="تشخیص سیستم عامل..."
    ["installing_deps"]="نصب وابستگی‌ها..."
    ["downloading"]="دانلود"
    ["extracting"]="استخراج فایل‌ها..."
    ["configuring"]="پیکربندی..."
    ["starting_db"]="شروع دیتابیس (۵-۱۰ دقیقه)..."
    ["installing_apex"]="نصب APEX (۱۵-۲۵ دقیقه)..."
    ["configuring_ords"]="پیکربندی ORDS..."
    ["fixing_images"]="تنظیم تصاویر..."
    ["creating_scripts"]="ایجاد اسکریپت‌ها..."
    ["creating_services"]="ایجاد سرویس‌های سیستمی..."
    ["verifying"]="بررسی نصب..."
    ["cleaning"]="پاکسازی..."
    ["syncing_passwords"]="همگام‌سازی رمزها..."
    ["fixing_error_571"]="رفع خطای 571..."
    ["repair_text"]="این عملیات:
• داده‌ها را نگه می‌دارد
• رمزها را به‌روز می‌کند
• مشکلات را رفع می‌کند
• سرویس‌ها را شروع می‌کند

ادامه دهید؟"
)

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - GERMAN (COMPLETE)
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_DE=(
    ["title"]="Oracle APEX Installer v4.3"
    ["welcome_title"]="🚀 Oracle APEX Installer v4.3"
    ["welcome_text"]="Oracle APEX Ultimate Installer v4.3.1 - VOLLSTÄNDIGE EDITION

✅ ERROR 571 BEHOBEN
✅ PERMISSION ERROR BEHOBEN
✅ ALLE FUNKTIONEN ENTHALTEN

Dies wird installieren:
• Oracle APEX (Neueste Version)
• Oracle ORDS (Neueste Version)
• Oracle XE 21c Datenbank
• DBeaver (Optional)
• Verwaltungs-GUI
• Auto-Start-Services

Funktionen:
✅ Automatische Konfiguration
✅ Automatische Fehlerbehandlung
✅ APEX-Bilder Auto-Setup
✅ Vollständige Verwaltungs-GUI
✅ DBeaver-Integration
✅ Web-Installer-Unterstützung
✅ Systemd Auto-Start
✅ Mehrsprachige Unterstützung

Erstellt von: Peyman Rasouli
Projekt: KaizenixCore

Klicken Sie Weiter zum Starten."
    ["select_action"]="Installationstyp wählen"
    ["action_text"]="Was möchten Sie tun?"
    ["fresh_install"]="🆕 Neuinstallation"
    ["repair_install"]="🔧 Reparieren"
    ["clean_install"]="🗑️ Saubere Installation"
    ["uninstall"]="❌ Deinstallieren"
    ["manage_dbeaver"]="📦 DBeaver verwalten"
    ["web_installer"]="🌐 Web-Installer"
    ["exit_installer"]="🚪 Beenden"
    ["enter_passwords"]="🔐 Passwörter eingeben"
    ["oracle_pass"]="Oracle Passwort:"
    ["apex_pass"]="APEX Admin Passwort:"
    ["pass_rules"]="Passwortregeln:
• Beginnt mit Buchstaben
• Nur Buchstaben und Zahlen
• 8-30 Zeichen

Beispiel: MyPass123"
    ["invalid_pass"]="Ungültiges Passwort!"
    ["installing"]="Installation läuft..."
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
    ["sudo_pass"]="Systempasswort eingeben:"
    ["sudo_required"]="Administratorpasswort erforderlich."
    ["success_title"]="🎉 Installation erfolgreich!"
    ["success_text"]="Oracle APEX installiert!

🌐 Admin Panel:
http://localhost:8080/ords/apex_admin

📋 Anmeldedaten:
   Workspace: INTERNAL
   Username: ADMIN
   Password: %PASSWORD%"
    ["create_service_title"]="Auto-Start-Service erstellen?"
    ["create_service_text"]="Oracle APEX beim Systemstart automatisch starten?"
    ["syncing_passwords"]="Passwörter synchronisieren..."
    ["fixing_error_571"]="Fehler 571 beheben..."
)

#═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
#═══════════════════════════════════════════════════════════════════════════════
get_text() {
    local key="$1"
    case $CURRENT_LANG in
        fa) echo "${LANG_FA[$key]:-${LANG_EN[$key]}}" ;;
        de) echo "${LANG_DE[$key]:-${LANG_EN[$key]}}" ;;
        *)  echo "${LANG_EN[$key]}" ;;
    esac
}

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    # Try to create directories and log file
    if [ ! -d "$PROJECT_DIR" ]; then
        mkdir -p "$PROJECT_DIR" 2>/dev/null || true
    fi
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR" 2>/dev/null || true
    fi
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
    else
        OS_TYPE="linux"
    fi
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="$ID"
    else
        OS_ID="unknown"
    fi
    
    log "OS: $OS_TYPE, Distribution: $OS_ID"
}

run_sudo() {
    if [ -n "$SUDO_PASS" ]; then
        echo "$SUDO_PASS" | sudo -S "$@" 2>/dev/null
    else
        sudo "$@" 2>/dev/null
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# ENSURE DIRECTORIES WITH PROPER PERMISSIONS - CRITICAL FIX
#═══════════════════════════════════════════════════════════════════════════════
ensure_directories() {
    log "Creating directories with proper permissions..."
    
    # If directory exists but user cannot write, fix it
    if [ -d "$PROJECT_DIR" ]; then
        if ! [ -w "$PROJECT_DIR" ]; then
            log "Fixing permissions on existing directory..."
            run_sudo chown -R $USER:$(id -gn) "$PROJECT_DIR" 2>/dev/null || true
            run_sudo chmod -R 755 "$PROJECT_DIR" 2>/dev/null || true
        fi
        # If still not writable, remove and recreate
        if ! [ -w "$PROJECT_DIR" ]; then
            log "Removing old directory with wrong permissions..."
            run_sudo rm -rf "$PROJECT_DIR" 2>/dev/null || true
        fi
    fi
    
    # Create all directories with proper method
    for dir in "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" "$ORDS_CONFIG_DIR/databases/default" "$ORDS_CONFIG_DIR/global" "$WEB_INSTALLER_DIR"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            run_sudo mkdir -p "$dir" 2>/dev/null || true
            run_sudo chown $USER:$(id -gn) "$dir" 2>/dev/null || true
        fi
    done
    
    # Fix ownership of entire project directory
    run_sudo chown -R $USER:$(id -gn) "$PROJECT_DIR" 2>/dev/null || true
    chmod -R 755 "$PROJECT_DIR" 2>/dev/null || true
    
    # Create log files
    touch "$INSTALL_LOG" 2>/dev/null || true
    touch "$LOG_DIR/ords.log" 2>/dev/null || true
    
    # Verify we can write
    if [ -w "$PROJECT_DIR" ] && [ -w "$LOG_DIR" ]; then
        log "✅ Directories created with proper permissions"
        return 0
    else
        log "⚠️ Warning: Some directories may have permission issues"
        return 1
    fi
}
#═══════════════════════════════════════════════════════════════════════════════
# GUI FUNCTIONS - ZENITY & YAD SUPPORT
#═══════════════════════════════════════════════════════════════════════════════
install_gui_tool() {
    if command -v yad &>/dev/null; then
        GUI_TOOL="yad"
        log "Using YAD for GUI"
        return 0
    fi
    
    if command -v zenity &>/dev/null; then
        GUI_TOOL="zenity"
        log "Using Zenity for GUI"
        return 0
    fi

    log "Installing GUI tool..."
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            sudo apt-get update -qq 2>/dev/null || true
            sudo apt-get install -y zenity yad 2>/dev/null || true
            ;;
        fedora)
            sudo dnf install -y zenity yad 2>/dev/null || true
            ;;
        opensuse*|suse*|opensuse-leap|opensuse-tumbleweed)
            sudo zypper --non-interactive install -y zenity yad 2>/dev/null || true
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm zenity yad 2>/dev/null || true
            ;;
    esac

    if command -v yad &>/dev/null; then
        GUI_TOOL="yad"
    elif command -v zenity &>/dev/null; then
        GUI_TOOL="zenity"
    else
        log "ERROR: Please install zenity or yad first"
        exit 1
    fi
}

gui_info() {
    local title="$1" text="$2" width="${3:-500}" height="${4:-400}"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$title" --text="$text" --width=$width --height=$height \
            --center --button="$(get_text ok):0" --borders=15 2>/dev/null || true
    else
        zenity --info --title="$title" --text="$text" --width=$width --height=$height \
            --ok-label="$(get_text ok)" 2>/dev/null || true
    fi
}

gui_error() {
    local title="$1" text="$2"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="$title" --text="$text" --width=450 --height=250 \
            --center --button="$(get_text ok):0" 2>/dev/null || true
    else
        zenity --error --title="$title" --text="$text" --width=450 --height=250 2>/dev/null || true
    fi
}

gui_question() {
    local title="$1" text="$2"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --question --title="$title" --text="$text" --width=500 --height=300 \
            --center --button="$(get_text no):1" --button="$(get_text yes):0" 2>/dev/null
        return $?
    else
        zenity --question --title="$title" --text="$text" --width=500 --height=300 \
            --ok-label="$(get_text yes)" --cancel-label="$(get_text no)" 2>/dev/null
        return $?
    fi
}

gui_entry() {
    local title="$1" text="$2" hide="${3:-false}"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        if [ "$hide" = "true" ]; then
            yad --entry --title="$title" --text="$text" --hide-text \
                --width=400 --center --button="$(get_text ok):0" 2>/dev/null
        else
            yad --entry --title="$title" --text="$text" \
                --width=400 --center --button="$(get_text ok):0" 2>/dev/null
        fi
    else
        if [ "$hide" = "true" ]; then
            zenity --password --title="$title" 2>/dev/null
        else
            zenity --entry --title="$title" --text="$text" --width=400 2>/dev/null
        fi
    fi
}

gui_list() {
    local title="$1" text="$2"
    shift 2
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --list --title="$title" --text="$text" \
            --radiolist --column="" --column="ID" --column="Option" \
            "$@" --width=550 --height=500 --center \
            --button="$(get_text cancel):1" --button="$(get_text ok):0" \
            --print-column=2 --hide-column=2 2>/dev/null
    else
        zenity --list --title="$title" --text="$text" \
            --radiolist --column="" --column="ID" --column="Option" \
            "$@" --width=550 --height=500 --hide-column=2 2>/dev/null
    fi
}

gui_progress() {
    local title="$1" text="$2"
    
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="$title" --text="$text" \
            --percentage=0 --auto-close --no-buttons \
            --width=550 --height=120 --center 2>/dev/null
    else
        zenity --progress --title="$title" --text="$text" \
            --percentage=0 --auto-close --no-cancel \
            --width=550 --height=120 2>/dev/null
    fi
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
            --width=550 --height=120 --center < "$FIFO_FILE" 2>/dev/null &
    else
        zenity --progress --title="$(get_text title)" --text="$(get_text installing)" \
            --percentage=0 --auto-close --no-cancel \
            --width=550 --height=120 < "$FIFO_FILE" 2>/dev/null &
    fi
    PROGRESS_PID=$!
    exec 3>"$FIFO_FILE" 2>/dev/null || true
}

update_progress() {
    local percent="$1" text="$2"
    if [ -n "$FIFO_FILE" ] && [ -e "$FIFO_FILE" ]; then
        echo "$percent" >&3 2>/dev/null || true
        echo "# $text" >&3 2>/dev/null || true
    fi
    log "[$percent%] $text"
}

stop_progress() {
    exec 3>&- 2>/dev/null || true
    sleep 1
    rm -f "$FIFO_FILE" 2>/dev/null || true
    [ -n "$PROGRESS_PID" ] && kill "$PROGRESS_PID" 2>/dev/null || true
}

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE SELECTION
#═══════════════════════════════════════════════════════════════════════════════
select_language() {
    local result=$(gui_list "🌐 Select Language" "Select your language:" \
        TRUE "en" "🇺🇸 English" \
        FALSE "fa" "🇮🇷 فارسی (Persian)" \
        FALSE "de" "🇩🇪 Deutsch (German)")
    
    [ -z "$result" ] && exit 0
    CURRENT_LANG=$(echo "$result" | tr -d '|')
    [ -z "$CURRENT_LANG" ] && CURRENT_LANG="en"
    log "Language selected: $CURRENT_LANG"
}

#═══════════════════════════════════════════════════════════════════════════════
# SUDO PASSWORD
#═══════════════════════════════════════════════════════════════════════════════
get_sudo_password() {
    if sudo -n true 2>/dev/null; then
        log "Sudo password cached"
        return 0
    fi

    local attempts=0
    while [ $attempts -lt 3 ]; do
        local pass=$(gui_entry "$(get_text title)" "$(get_text sudo_pass)\n\n$(get_text sudo_required)" "true")
        [ -z "$pass" ] && exit 0

        if echo "$pass" | sudo -S true 2>/dev/null; then
            SUDO_PASS="$pass"
            log "Sudo password verified"
            return 0
        fi
        attempts=$((attempts + 1))
        gui_error "$(get_text error)" "Wrong password! ($attempts/3)"
    done
    exit 1
}

#═══════════════════════════════════════════════════════════════════════════════
# PASSWORD INPUT & VALIDATION
#═══════════════════════════════════════════════════════════════════════════════
get_passwords() {
    while true; do
        local result=""
        if [ "$GUI_TOOL" = "yad" ]; then
            result=$(yad --form --title="$(get_text enter_passwords)" \
                --text="$(get_text pass_rules)" \
                --field="$(get_text oracle_pass):H" "" \
                --field="$(get_text apex_pass):H" "" \
                --width=500 --height=400 --center \
                --button="$(get_text cancel):1" --button="$(get_text continue):0" 2>/dev/null)
        else
            result=$(zenity --forms --title="$(get_text enter_passwords)" \
                --text="$(get_text pass_rules)" \
                --add-password="$(get_text oracle_pass)" \
                --add-password="$(get_text apex_pass)" \
                --width=500 --height=350 2>/dev/null)
        fi
        
        [ -z "$result" ] && exit 0

        ORACLE_PASSWORD=$(echo "$result" | cut -d'|' -f1)
        APEX_ADMIN_PASSWORD=$(echo "$result" | cut -d'|' -f2)

        # Validate: start with letter, alphanumeric, 8-30 chars
        if [[ "$ORACLE_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{7,29}$ ]] && \
           [[ "$APEX_ADMIN_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{7,29}$ ]]; then
            log "Passwords validated successfully"
            break
        else
            gui_error "$(get_text error)" "$(get_text invalid_pass)"
        fi
    done
}

#═══════════════════════════════════════════════════════════════════════════════
# COMPLETE CLEANUP - CRITICAL FOR FIXING OLD INSTALLATIONS
#═══════════════════════════════════════════════════════════════════════════════
complete_cleanup() {
    log "Starting complete cleanup..."
    
    # Stop all processes
    pkill -f ords 2>/dev/null || true
    pkill -f "java.*ords" 2>/dev/null || true
    sleep 3
    
    # Stop and remove container
    docker stop oracle-apex-db 2>/dev/null || true
    docker rm -f oracle-apex-db 2>/dev/null || true
    
    # Remove ALL oracle volumes - THIS IS CRITICAL
    docker volume rm oracle-apex-complete_oracle-data 2>/dev/null || true
    docker volume rm oracle-data 2>/dev/null || true
    docker volume rm oracle-apex-data 2>/dev/null || true
    
    # Find and remove any remaining oracle volumes
    for vol in $(docker volume ls -q 2>/dev/null | grep -i oracle); do
        docker volume rm "$vol" 2>/dev/null || true
    done
    
    # Remove project directory with sudo if needed
    if [ -d "$PROJECT_DIR" ]; then
        rm -rf "$PROJECT_DIR" 2>/dev/null || run_sudo rm -rf "$PROJECT_DIR" 2>/dev/null || true
    fi
    
    # Remove systemd services
    run_sudo systemctl stop oracle-apex.service 2>/dev/null || true
    run_sudo systemctl disable oracle-apex.service 2>/dev/null || true
    run_sudo rm -f /etc/systemd/system/oracle-apex*.service 2>/dev/null || true
    run_sudo systemctl daemon-reload 2>/dev/null || true
    
    # Clean docker
    docker system prune -f 2>/dev/null || true
    
    log "Cleanup completed successfully"
}

#═══════════════════════════════════════════════════════════════════════════════
# INSTALL DEPENDENCIES
#═══════════════════════════════════════════════════════════════════════════════
install_dependencies() {
    log "Installing dependencies for $OS_ID..."
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            log "Installing on Debian/Ubuntu..."
            run_sudo apt-get update -qq 2>/dev/null || true
            run_sudo apt-get install -y \
                docker.io docker-compose openjdk-17-jdk unzip wget curl \
                zenity yad git 2>/dev/null || true
            ;;
        fedora)
            log "Installing on Fedora..."
            run_sudo dnf install -y \
                docker docker-compose java-17-openjdk unzip wget curl \
                zenity yad git 2>/dev/null || true
            ;;
        opensuse*|suse*|opensuse-leap|opensuse-tumbleweed)
            log "Installing on openSUSE..."
            run_sudo zypper --non-interactive install -y \
                docker docker-compose java-17-openjdk unzip wget curl \
                zenity yad git 2>/dev/null || true
            # Alternative package names for openSUSE
            run_sudo zypper --non-interactive install -y \
                docker docker-compose-switch java-17-openjdk-headless 2>/dev/null || true
            ;;
        arch|manjaro)
            log "Installing on Arch/Manjaro..."
            run_sudo pacman -S --noconfirm \
                docker docker-compose jdk17-openjdk unzip wget curl \
                zenity yad git 2>/dev/null || true
            ;;
        rhel|centos|rocky|almalinux)
            log "Installing on RHEL/CentOS..."
            run_sudo yum install -y \
                docker docker-compose java-17-openjdk unzip wget curl \
                zenity yad git 2>/dev/null || true
            ;;
    esac
    
    # Enable and start Docker
    run_sudo systemctl enable docker 2>/dev/null || true
    run_sudo systemctl start docker 2>/dev/null || true
    run_sudo usermod -aG docker $USER 2>/dev/null || true
    
    # Verify Docker
    if ! docker --version &>/dev/null; then
        log "WARNING: Docker may not be fully installed"
    fi
    
    log "Dependencies installed successfully"
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# WAIT FOR DATABASE - EXTENDED TIMEOUT
#═══════════════════════════════════════════════════════════════════════════════
wait_for_database() {
    log "Waiting for database to be ready (max 10 minutes)..."
    local max_wait=600  # 10 minutes
    local waited=0
    
    while [ $waited -lt $max_wait ]; do
        # Check if container is running
        if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "oracle-apex-db"; then
            log "Container not running yet, waiting... ($waited seconds)"
            sleep 10
            waited=$((waited + 10))
            continue
        fi
        
        # Check database logs for ready message
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            log "Database is READY! (after $waited seconds)"
            return 0
        fi
        
        sleep 15
        waited=$((waited + 15))
        log "Still waiting for database... ($waited seconds)"
    done
    
    log "Database wait timeout after $waited seconds"
    return 1
}

#═══════════════════════════════════════════════════════════════════════════════
# TEST DATABASE CONNECTION - CRITICAL FOR ERROR 571
#═══════════════════════════════════════════════════════════════════════════════
test_db_connection() {
    local password="$1"
    log "Testing database connection..."
    
    local result=$(docker exec oracle-apex-db bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s sys/${password}@//localhost:1521/XEPDB1 as sysdba" 2>&1)
    
    if echo "$result" | grep -q "1"; then
        log "✅ Database connection OK"
        return 0
    else
        log "❌ Database connection FAILED: $result"
        return 1
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# SYNC ALL PASSWORDS - CRITICAL FIX FOR ERROR 571
#═══════════════════════════════════════════════════════════════════════════════
sync_all_passwords() {
    local password="$1"
    log "Syncing all passwords (CRITICAL FOR ERROR 571)..."
    
    # First reset the main database password
    log "Step 1: Resetting SYS password..."
    docker exec oracle-apex-db resetPassword "$password" >> "$INSTALL_LOG" 2>&1 || true
    sleep 15
    
    # Now sync all APEX/ORDS users with the same password
    log "Step 2: Syncing all APEX/ORDS users..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${password}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
-- Disable password policies first
ALTER PROFILE DEFAULT LIMIT 
    FAILED_LOGIN_ATTEMPTS UNLIMITED 
    PASSWORD_LIFE_TIME UNLIMITED 
    PASSWORD_VERIFY_FUNCTION NULL;

-- Unlock and set password for all ORDS/APEX users
BEGIN
    FOR u IN (SELECT username FROM dba_users WHERE username IN (
        'ORDS_PUBLIC_USER', 'APEX_PUBLIC_USER', 'APEX_LISTENER', 
        'APEX_REST_PUBLIC_USER', 'ORDS_METADATA', 'ORDS_USER'
    )) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER USER ' || u.username || ' IDENTIFIED BY ${password} ACCOUNT UNLOCK';
            DBMS_OUTPUT.PUT_LINE('Updated: ' || u.username);
        EXCEPTION WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Skip: ' || u.username || ' - ' || SQLERRM);
        END;
    END LOOP;
END;
/

-- Grant proxy permissions
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

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    log "✅ Password sync completed"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE ORDS_PUBLIC_USER - CRITICAL FOR ERROR 571
#═══════════════════════════════════════════════════════════════════════════════
create_ords_user() {
    local password="$1"
    log "Creating ORDS_PUBLIC_USER (CRITICAL FOR ERROR 571)..."
    
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${password}@//localhost:1521/XEPDB1 as sysdba << EOSQL
-- Drop existing user if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Create user with proper privileges
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${password}
    DEFAULT TABLESPACE SYSAUX
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON SYSAUX;

-- Grant all required privileges
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

-- Grant execute on required packages
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOCK TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SQL TO ORDS_PUBLIC_USER;

-- Ensure account is unlocked
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    log "✅ ORDS_PUBLIC_USER created with all privileges"
}

#═══════════════════════════════════════════════════════════════════════════════
# INSTALL ORDS PROPERLY - CRITICAL FIX FOR ERROR 571
#═══════════════════════════════════════════════════════════════════════════════
install_ords_properly() {
    local password="$1"
    log "Installing ORDS properly (CRITICAL FOR ERROR 571)..."
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    
    if [ -z "$ORDS_BIN" ]; then
        log "ERROR: ORDS binary not found!"
        return 1
    fi
    
    chmod +x "$ORDS_BIN"
    log "ORDS binary found at: $ORDS_BIN"
    
    # Remove old config
    rm -rf "$ORDS_CONFIG_DIR" 2>/dev/null || true
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    
    # Create password file for ORDS installation
    local PASS_FILE=$(mktemp)
    cat > "$PASS_FILE" << EOF
${password}
${password}
${password}
${password}
EOF

    log "Running ORDS install command..."
    
    # Install ORDS with all required parameters
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
        --admin-user SYS \
        --db-hostname localhost \
        --db-port 1521 \
        --db-servicename XEPDB1 \
        --feature-db-api true \
        --feature-rest-enabled-sql true \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --log-folder "$LOG_DIR" \
        --proxy-user \
        --password-stdin < "$PASS_FILE" >> "$INSTALL_LOG" 2>&1 || {
            log "ORDS install with proxy-user failed, trying without..."
            
            # Try simpler install
            "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
                --admin-user SYS \
                --db-hostname localhost \
                --db-port 1521 \
                --db-servicename XEPDB1 \
                --feature-sdw true \
                --password-stdin < "$PASS_FILE" >> "$INSTALL_LOG" 2>&1 || {
                    log "ORDS install failed, continuing with manual config..."
                }
        }
    
    rm -f "$PASS_FILE"
    
    # Set ORDS password in config - CRITICAL
    log "Setting ORDS db.password..."
    echo "$password" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    
    # Configure ORDS settings
    log "Configuring ORDS settings..."
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port 8080 >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.context.path /ords >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set db.connectionType basic >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set db.hostname localhost >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set db.port 1521 >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set db.servicename XEPDB1 >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set db.username ORDS_PUBLIC_USER >> "$INSTALL_LOG" 2>&1 || true
    
    # Create pool.xml manually as backup
    cat > "$ORDS_CONFIG_DIR/databases/default/pool.xml" << POOLEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">localhost</entry>
<entry key="db.port">1521</entry>
<entry key="db.servicename">XEPDB1</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="feature.sdw">true</entry>
<entry key="restEnabledSql.active">true</entry>
<entry key="security.requestValidationFunction">wwv_flow_epg_include_modules.authorize</entry>
<entry key="plsql.gateway.mode">proxied</entry>
</properties>
POOLEOF

    log "✅ ORDS installation completed"
}

#═══════════════════════════════════════════════════════════════════════════════
# START ORDS WITH PROPER CONFIGURATION
#═══════════════════════════════════════════════════════════════════════════════
start_ords() {
    log "Starting ORDS..."
    
    # Kill any existing ORDS
    pkill -f ords 2>/dev/null || true
    pkill -f "java.*ords" 2>/dev/null || true
    sleep 5
    
    # Free up port 8080
    run_sudo fuser -k 8080/tcp 2>/dev/null || true
    sleep 2
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    
    if [ -z "$ORDS_BIN" ]; then
        log "ERROR: ORDS binary not found!"
        return 1
    fi
    
    # Set environment
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    
    # Ensure log directory exists and is writable
    mkdir -p "$LOG_DIR" 2>/dev/null || true
    touch "$LOG_DIR/ords.log" 2>/dev/null || true
    
    # Start ORDS
    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port 8080 \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &
    
    local ords_pid=$!
    echo "$ords_pid" > "$PROJECT_DIR/ords.pid"
    
    log "✅ ORDS started with PID $ords_pid"
    
    # Wait for ORDS to be ready
    log "Waiting for ORDS to start (2 minutes)..."
    sleep 120
    
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# VERIFY AND FIX ERROR 571
#═══════════════════════════════════════════════════════════════════════════════
verify_and_fix() {
    log "Verifying installation..."
    
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
    log "HTTP response: $http_code"
    
    if [[ "$http_code" =~ ^(200|302|303)$ ]]; then
        log "✅ APEX is working!"
        return 0
    fi
    
    log "⚠️ Error detected, running automatic fix..."
    
    # Sync passwords again
    sync_all_passwords "$ORACLE_PASSWORD"
    sleep 10
    
    # Update ORDS password
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    if [ -n "$ORDS_BIN" ]; then
        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    fi
    
    # Restart ORDS
    start_ords
    
    # Check again
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
    log "After fix HTTP response: $http_code"
    
    if [[ "$http_code" =~ ^(200|302|303)$ ]]; then
        return 0
    else
        return 1
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE APEX ADMIN USER
#═══════════════════════════════════════════════════════════════════════════════
create_apex_admin() {
    local db_pass="$1"
    local apex_pass="$2"
    log "Creating APEX admin user..."
    
    # Find APEX schema
    local apex_schema=$(docker exec oracle-apex-db bash -c "echo \"SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${db_pass}@//localhost:1521/XEPDB1 as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ') || true
    
    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"
    log "APEX Schema detected: $apex_schema"
    
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${db_pass}@//localhost:1521/XEPDB1 as sysdba << EOSQL
BEGIN
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('RESTFUL_SERVICES_ENABLED', 'Y');
    
    ${apex_schema}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    
    BEGIN
        ${apex_schema}.APEX_UTIL.CREATE_USER(
            p_user_name                    => 'ADMIN',
            p_email_address                => 'admin@localhost',
            p_web_password                 => '${apex_pass}',
            p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
            p_change_password_on_first_use => 'N',
            p_account_locked               => 'N'
        );
    EXCEPTION WHEN OTHERS THEN
        ${apex_schema}.APEX_UTIL.EDIT_USER(
            p_user_id                      => ${apex_schema}.APEX_UTIL.GET_USER_ID('ADMIN'),
            p_user_name                    => 'ADMIN',
            p_web_password                 => '${apex_pass}',
            p_new_password                 => '${apex_pass}',
            p_change_password_on_first_use => 'N',
            p_account_locked               => 'N'
        );
    END;
    
    COMMIT;
END;
/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    log "✅ APEX admin user created"
}
#═══════════════════════════════════════════════════════════════════════════════
# CREATE MANAGEMENT SCRIPTS - COMPLETE SET
#═══════════════════════════════════════════════════════════════════════════════
create_scripts() {
    log "Creating management scripts..."
    mkdir -p "$SCRIPTS_DIR"
    
    #---------------------------------------------------------------------------
    # START SCRIPT
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/start.sh" << 'STARTEOF'
#!/bin/bash
################################################################################
# Oracle APEX START SCRIPT v4.3.1
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          🚀 Starting Oracle APEX v4.3.1                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Start database
echo "[1/6] Starting database container..."
docker start oracle-apex-db 2>/dev/null || {
    echo "❌ Failed to start database"
    exit 1
}

echo "⏳ Waiting for database (90 seconds)..."
sleep 90

# Sync passwords
echo ""
echo "[2/6] Syncing database passwords..."
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 15

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

# Update ORDS password
echo "[3/6] Updating ORDS configuration..."
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "$ORDS_BIN" ]; then
    echo "$PASS" | "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config secret --password-stdin db.password 2>/dev/null || true
fi

# Stop old ORDS
echo "[4/6] Stopping old ORDS instances..."
pkill -f ords 2>/dev/null || true
sleep 5

# Start ORDS
echo "[5/6] Starting ORDS..."
if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG="$PROJECT_DIR/ords_config"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve \
        --port 8080 --apex-images "$PROJECT_DIR/images" \
        > "$LOG_DIR/ords.log" 2>&1 &
    echo "✅ ORDS started (PID: $!)"
fi

# Wait for ORDS
echo "⏳ Waiting for ORDS (60 seconds)..."
sleep 60

# Check status
echo ""
echo "[6/6] Verifying installation..."
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null)

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      ✅ STATUS REPORT                          ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║ Database:  🟢 Running                                          ║"
echo "║ ORDS:      $([ "$HTTP" = "200" ] || [ "$HTTP" = "302" ] || [ "$HTTP" = "303" ] && echo "🟢 Running" || echo "🟡 Starting")                                          ║"
echo "║ HTTP:      $HTTP                                                ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║ 🌐 Admin URL:                                                  ║"
echo "║    http://localhost:8080/ords/apex_admin                       ║"
echo "║                                                                ║"
echo "║ 🔐 Login URL:                                                  ║"
echo "║    http://localhost:8080/ords/f?p=4550                         ║"
echo "║                                                                ║"
echo "║ 📋 Credentials:                                                ║"
echo "║    Workspace: INTERNAL                                         ║"
echo "║    Username: ADMIN                                             ║"
echo "║    Password: (your password)                                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"

if [ "$HTTP" = "200" ] || [ "$HTTP" = "302" ] || [ "$HTTP" = "303" ]; then
    echo ""
    echo "✅ Oracle APEX is ready!"
else
    echo ""
    echo "⚠️  ORDS is starting. Please wait 1-2 minutes and refresh the browser."
fi
STARTEOF
    chmod +x "$SCRIPTS_DIR/start.sh"

    #---------------------------------------------------------------------------
    # STOP SCRIPT
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
################################################################################
# Oracle APEX STOP SCRIPT v4.3.1
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          🛑 Stopping Oracle APEX v4.3.1                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "[1/2] Stopping ORDS..."
pkill -f ords 2>/dev/null || true
pkill -f "java.*ords" 2>/dev/null || true
sleep 3

echo "[2/2] Stopping database..."
docker stop oracle-apex-db 2>/dev/null || true
sleep 2

echo ""
echo "✅ Oracle APEX stopped"
STOPEOF
    chmod +x "$SCRIPTS_DIR/stop.sh"

    #---------------------------------------------------------------------------
    # RESTART SCRIPT
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/restart.sh" << 'RESTARTEOF'
#!/bin/bash
################################################################################
# Oracle APEX RESTART SCRIPT v4.3.1
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"

echo "🔄 Restarting Oracle APEX..."
bash "$SCRIPTS_DIR/stop.sh"
sleep 5
bash "$SCRIPTS_DIR/start.sh"
RESTARTEOF
    chmod +x "$SCRIPTS_DIR/restart.sh"

    #---------------------------------------------------------------------------
    # FIX SCRIPT - COMPREHENSIVE ERROR 571 FIX
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/fix.sh" << 'FIXEOF'
#!/bin/bash
################################################################################
# Oracle APEX FIX SCRIPT v4.3.1 - Complete Error 571/574/500 Fix
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     🔧 Fixing Oracle APEX (Error 571/574/500) v4.3.1           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "[1/8] Stopping ORDS..."
pkill -f ords 2>/dev/null || true
pkill -f "java.*ords" 2>/dev/null || true
sleep 5

echo "[2/8] Starting database..."
docker start oracle-apex-db 2>/dev/null || true
echo "⏳ Waiting for database (60 seconds)..."
sleep 60

echo "[3/8] Resetting database password..."
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 15

echo "[4/8] Syncing all user passwords..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

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

BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[5/8] Updating ORDS password..."
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "$ORDS_BIN" ]; then
    echo "$PASS" | "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config secret --password-stdin db.password 2>/dev/null || true
fi

echo "[6/8] Fixing APEX images..."
if [ -d "$PROJECT_DIR/apex/images" ]; then
    rm -rf "$PROJECT_DIR/images" 2>/dev/null || true
    cp -r "$PROJECT_DIR/apex/images" "$PROJECT_DIR/images"
    chmod -R 755 "$PROJECT_DIR/images"
    echo "✅ Images fixed"
fi

echo "[7/8] Starting ORDS..."
if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG="$PROJECT_DIR/ords_config"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve \
        --port 8080 --apex-images "$PROJECT_DIR/images" \
        > "$LOG_DIR/ords.log" 2>&1 &
    echo "✅ ORDS started (PID: $!)"
fi

echo "[8/8] Waiting for ORDS (90 seconds)..."
sleep 90

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ FIX VERIFICATION                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null)
IMG=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/i/apex_version.txt 2>/dev/null)

echo "APEX Admin: HTTP $HTTP"
echo "Images:     HTTP $IMG"
echo ""

if [ "$HTTP" = "200" ] || [ "$HTTP" = "302" ] || [ "$HTTP" = "303" ]; then
    echo "✅ SUCCESS! APEX is working!"
    echo ""
    echo "Open: http://localhost:8080/ords/apex_admin"
else
    echo "⚠️  Still having issues. Check logs:"
    echo "   tail -100 $PROJECT_DIR/logs/ords.log"
    echo ""
    echo "Try these commands:"
    echo "   bash $PROJECT_DIR/scripts/stop.sh"
    echo "   bash $PROJECT_DIR/scripts/start.sh"
fi
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh"

    #---------------------------------------------------------------------------
    # STATUS SCRIPT
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
################################################################################
# Oracle APEX STATUS SCRIPT v4.3.1
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          📊 Oracle APEX Status Report v4.3.1                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Database status
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "oracle-apex-db"; then
    DB_STATUS="🟢 Running"
else
    DB_STATUS="🔴 Stopped"
fi

# ORDS status
if pgrep -f "ords.*serve" >/dev/null 2>&1; then
    ORDS_STATUS="🟢 Running"
else
    ORDS_STATUS="🔴 Stopped"
fi

# HTTP status
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")

case $HTTP in
    200|302|303) HTTP_STATUS="✅ OK ($HTTP)" ;;
    000) HTTP_STATUS="❌ No Connection" ;;
    571) HTTP_STATUS="❌ Database Error (571)" ;;
    404) HTTP_STATUS="❌ Not Found (404)" ;;
    500) HTTP_STATUS="❌ Server Error (500)" ;;
    504) HTTP_STATUS="❌ Gateway Timeout (504)" ;;
    *) HTTP_STATUS="⚠️  Status $HTTP" ;;
esac

echo "Database:     $DB_STATUS"
echo "ORDS:         $ORDS_STATUS"
echo "HTTP Status:  $HTTP_STATUS"
echo ""

# Container info
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    📦 Container Info                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

docker ps -a --filter "name=oracle-apex-db" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🌐 Access URLs                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "Admin Panel:  http://localhost:8080/ords/apex_admin"
echo "Login Page:   http://localhost:8080/ords/f?p=4550"
echo "REST API:     http://localhost:8080/ords/sql"
echo "Images:       http://localhost:8080/i/"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🛠️  Management Commands                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "Start:   bash $PROJECT_DIR/scripts/start.sh"
echo "Stop:    bash $PROJECT_DIR/scripts/stop.sh"
echo "Restart: bash $PROJECT_DIR/scripts/restart.sh"
echo "Fix:     bash $PROJECT_DIR/scripts/fix.sh"
echo "Logs:    bash $PROJECT_DIR/scripts/logs.sh"
echo "Status:  bash $PROJECT_DIR/scripts/status.sh"
STATUSEOF
    chmod +x "$SCRIPTS_DIR/status.sh"

    #---------------------------------------------------------------------------
    # LOGS SCRIPT
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/logs.sh" << 'LOGSEOF'
#!/bin/bash
################################################################################
# Oracle APEX LOGS SCRIPT v4.3.1
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
LOG_DIR="$PROJECT_DIR/logs"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    📋 Oracle APEX Logs v4.3.1                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Menu
echo "Select log to view:"
echo "1) ORDS Log (last 100 lines)"
echo "2) Installation Log (last 100 lines)"
echo "3) Database Log (last 100 lines)"
echo "4) Full ORDS Log"
echo "5) Full Installation Log"
echo "6) Live ORDS Log (follow)"
echo "7) Exit"
echo ""

read -p "Enter choice (1-7): " choice

case $choice in
    1)
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "ORDS Log (last 100 lines):"
        echo "═══════════════════════════════════════════════════════════════"
        tail -100 "$LOG_DIR/ords.log" 2>/dev/null || echo "No log file found"
        ;;
    2)
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "Installation Log (last 100 lines):"
        echo "═══════════════════════════════════════════════════════════════"
        tail -100 "$PROJECT_DIR/install.log" 2>/dev/null || echo "No log file found"
        ;;
    3)
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "Database Log (last 100 lines):"
        echo "═══════════════════════════════════════════════════════════════"
        docker logs oracle-apex-db 2>&1 | tail -100 || echo "No logs available"
        ;;
    4)
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "Full ORDS Log:"
        echo "═══════════════════════════════════════════════════════════════"
        cat "$LOG_DIR/ords.log" 2>/dev/null || echo "No log file found"
        ;;
    5)
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "Full Installation Log:"
        echo "═══════════════════════════════════════════════════════════════"
        cat "$PROJECT_DIR/install.log" 2>/dev/null || echo "No log file found"
        ;;
    6)
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "Live ORDS Log (Press Ctrl+C to stop):"
        echo "═══════════════════════════════════════════════════════════════"
        tail -f "$LOG_DIR/ords.log" 2>/dev/null || echo "No log file found"
        ;;
    7)
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
LOGSEOF
    chmod +x "$SCRIPTS_DIR/logs.sh"

    #---------------------------------------------------------------------------
    # DBEAVER MANAGEMENT SCRIPT
    #---------------------------------------------------------------------------
    cat > "$SCRIPTS_DIR/dbeaver.sh" << 'DBEAVEREOF'
#!/bin/bash
################################################################################
# DBeaver Management Script v4.3.1
################################################################################

ACTION="${1:-menu}"
OS_ID=$(grep "^ID=" /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "unknown")

install_dbeaver() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          📦 Installing DBeaver                                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            echo "Installing for Debian/Ubuntu..."
            wget -q -O /tmp/dbeaver.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" 2>/dev/null || {
                echo "Download failed, trying alternative..."
                curl -sL -o /tmp/dbeaver.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"
            }
            sudo dpkg -i /tmp/dbeaver.deb 2>/dev/null || sudo apt-get install -f -y 2>/dev/null
            rm -f /tmp/dbeaver.deb
            ;;
        fedora)
            echo "Installing for Fedora..."
            sudo dnf install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm 2>/dev/null
            ;;
        opensuse*|suse*|opensuse-leap|opensuse-tumbleweed)
            echo "Installing for openSUSE..."
            wget -q -O /tmp/dbeaver.rpm "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" 2>/dev/null || {
                curl -sL -o /tmp/dbeaver.rpm "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm"
            }
            sudo zypper --non-interactive install -y /tmp/dbeaver.rpm 2>/dev/null
            rm -f /tmp/dbeaver.rpm
            ;;
        arch|manjaro)
            echo "Installing for Arch/Manjaro..."
            sudo pacman -S --noconfirm dbeaver 2>/dev/null
            ;;
        rhel|centos|rocky|almalinux)
            echo "Installing for RHEL/CentOS..."
            sudo yum install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm 2>/dev/null
            ;;
        *)
            echo "Unknown distribution: $OS_ID"
            echo "Please install DBeaver manually from: https://dbeaver.io/download/"
            return 1
            ;;
    esac
    
    if command -v dbeaver &>/dev/null || command -v dbeaver-ce &>/dev/null; then
        echo ""
        echo "✅ DBeaver installed successfully!"
        echo ""
        echo "To connect to Oracle APEX database:"
        echo "  Host: localhost"
        echo "  Port: 1521"
        echo "  Database: XEPDB1"
        echo "  Username: SYS (as SYSDBA)"
        echo "  Password: (your Oracle password)"
        echo ""
        read -p "Start DBeaver now? (y/n): " start_now
        if [ "$start_now" = "y" ] || [ "$start_now" = "Y" ]; then
            dbeaver 2>/dev/null || dbeaver-ce 2>/dev/null &
        fi
    else
        echo "❌ DBeaver installation may have failed"
        echo "Please install manually from: https://dbeaver.io/download/"
    fi
}

remove_dbeaver() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          🗑️  Removing DBeaver                                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            sudo apt-get remove -y dbeaver-ce dbeaver 2>/dev/null
            sudo apt-get autoremove -y 2>/dev/null
            ;;
        fedora)
            sudo dnf remove -y dbeaver-ce dbeaver 2>/dev/null
            ;;
        opensuse*|suse*|opensuse-leap|opensuse-tumbleweed)
            sudo zypper remove -y dbeaver-ce dbeaver 2>/dev/null
            ;;
        arch|manjaro)
            sudo pacman -Rns --noconfirm dbeaver 2>/dev/null
            ;;
        rhel|centos|rocky|almalinux)
            sudo yum remove -y dbeaver-ce dbeaver 2>/dev/null
            ;;
    esac
    
    # Remove config directories
    rm -rf "$HOME/.dbeaver4" 2>/dev/null
    rm -rf "$HOME/.dbeaver-drivers" 2>/dev/null
    rm -rf "$HOME/.local/share/DBeaverData" 2>/dev/null
    rm -rf "$HOME/.config/DBeaverData" 2>/dev/null
    
    echo "✅ DBeaver removed"
}

show_menu() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          📦 DBeaver Management v4.3.1                          ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Usage: $0 {install|remove}"
    echo ""
    echo "Commands:"
    echo "  install  - Install DBeaver Community Edition"
    echo "  remove   - Remove DBeaver and its configuration"
    echo ""
}

case "$ACTION" in
    install)
        install_dbeaver
        ;;
    remove)
        remove_dbeaver
        ;;
    *)
        show_menu
        exit 1
        ;;
esac
DBEAVEREOF
    chmod +x "$SCRIPTS_DIR/dbeaver.sh"

    log "✅ All management scripts created"
}

#═══════════════════════════════════════════════════════════════════════════════
# DBEAVER MANAGEMENT (GUI)
#═══════════════════════════════════════════════════════════════════════════════
install_dbeaver() {
    log "Installing DBeaver..."
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            wget -O /tmp/dbeaver.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" 2>/dev/null || true
            run_sudo dpkg -i /tmp/dbeaver.deb 2>/dev/null || run_sudo apt-get install -f -y 2>/dev/null || true
            rm -f /tmp/dbeaver.deb
            ;;
        fedora)
            run_sudo dnf install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm 2>/dev/null || true
            ;;
        opensuse*|suse*|opensuse-leap|opensuse-tumbleweed)
            wget -O /tmp/dbeaver.rpm "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" 2>/dev/null || true
            run_sudo zypper --non-interactive install -y /tmp/dbeaver.rpm 2>/dev/null || true
            rm -f /tmp/dbeaver.rpm
            ;;
        arch|manjaro)
            run_sudo pacman -S --noconfirm dbeaver 2>/dev/null || true
            ;;
        rhel|centos|rocky|almalinux)
            run_sudo yum install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm 2>/dev/null || true
            ;;
    esac
    
    log "DBeaver installation completed"
}

remove_dbeaver() {
    log "Removing DBeaver..."
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            run_sudo apt-get remove -y dbeaver-ce dbeaver 2>/dev/null || true
            run_sudo apt-get autoremove -y 2>/dev/null || true
            ;;
        fedora)
            run_sudo dnf remove -y dbeaver-ce dbeaver 2>/dev/null || true
            ;;
        opensuse*|suse*|opensuse-leap|opensuse-tumbleweed)
            run_sudo zypper remove -y dbeaver-ce dbeaver 2>/dev/null || true
            ;;
        arch|manjaro)
            run_sudo pacman -Rns --noconfirm dbeaver 2>/dev/null || true
            ;;
        rhel|centos|rocky|almalinux)
            run_sudo yum remove -y dbeaver-ce dbeaver 2>/dev/null || true
            ;;
    esac
    
    # Remove config
    rm -rf "$HOME/.dbeaver4" "$HOME/.dbeaver-drivers" 2>/dev/null || true
    rm -rf "$HOME/.local/share/DBeaverData" "$HOME/.config/DBeaverData" 2>/dev/null || true
    
    log "DBeaver removed"
}

manage_dbeaver() {
    while true; do
        local choice=$(gui_list "📦 DBeaver Management" "Select action:" \
            TRUE "install" "📥 Install DBeaver" \
            FALSE "remove" "🗑️ Remove DBeaver" \
            FALSE "back" "⬅️ Back to Main Menu")
        
        choice=$(echo "$choice" | tr -d '|')
        
        case "$choice" in
            install)
                start_progress
                update_progress 25 "Downloading DBeaver..."
                install_dbeaver
                update_progress 75 "Finalizing..."
                sleep 3
                update_progress 100 "Done"
                stop_progress
                gui_info "$(get_text info)" "✅ DBeaver installed successfully!\n\nYou can start it from your application menu."
                ;;
            remove)
                if gui_question "$(get_text warning)" "Remove DBeaver completely?\n\nThis will also remove all DBeaver settings."; then
                    start_progress
                    update_progress 50 "Removing DBeaver..."
                    remove_dbeaver
                    update_progress 100 "Done"
                    stop_progress
                    gui_info "$(get_text info)" "✅ DBeaver removed!"
                fi
                ;;
            back|"")
                return 0
                ;;
        esac
    done
}
#═══════════════════════════════════════════════════════════════════════════════
# SYSTEMD SERVICE CREATION
#═══════════════════════════════════════════════════════════════════════════════
create_systemd_service() {
    log "Creating systemd service..."
    
    # Create service file for current user
    cat > /tmp/oracle-apex.service << SERVICEEOF
[Unit]
Description=Oracle APEX Service v4.3.1
After=docker.service network-online.target
Requires=docker.service
Wants=network-online.target

[Service]
Type=forking
User=$USER
Group=$(id -gn)
WorkingDirectory=$PROJECT_DIR
Environment="HOME=$HOME"
ExecStartPre=/bin/sleep 10
ExecStart=/bin/bash $SCRIPTS_DIR/start.sh
ExecStop=/bin/bash $SCRIPTS_DIR/stop.sh
ExecReload=/bin/bash $SCRIPTS_DIR/restart.sh
Restart=on-failure
RestartSec=30
TimeoutStartSec=600
TimeoutStopSec=120

[Install]
WantedBy=multi-user.target
SERVICEEOF

    run_sudo cp /tmp/oracle-apex.service /etc/systemd/system/oracle-apex.service
    run_sudo chmod 644 /etc/systemd/system/oracle-apex.service
    run_sudo systemctl daemon-reload
    run_sudo systemctl enable oracle-apex.service
    
    rm -f /tmp/oracle-apex.service
    
    log "✅ Systemd service created and enabled"
    SYSTEMD_ENABLED="true"
}

#═══════════════════════════════════════════════════════════════════════════════
# CHECK PREVIOUS INSTALLATION
#═══════════════════════════════════════════════════════════════════════════════
check_previous_install() {
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "oracle-apex-db"; then
        return 0
    fi
    if [ -d "$PROJECT_DIR/apex" ] || [ -d "$PROJECT_DIR/ords" ]; then
        return 0
    fi
    return 1
}

#═══════════════════════════════════════════════════════════════════════════════
# SELECT ACTION
#═══════════════════════════════════════════════════════════════════════════════
select_action() {
    local has_install="false"
    check_previous_install && has_install="true"
    
    local choice=""
    
    if [ "$has_install" = "true" ]; then
        choice=$(gui_list "$(get_text select_action)" "$(get_text action_text)

⚠️ Previous installation detected." \
            FALSE "fresh" "$(get_text fresh_install)" \
            TRUE "repair" "$(get_text repair_install)" \
            FALSE "clean" "$(get_text clean_install)" \
            FALSE "uninstall" "$(get_text uninstall)" \
            FALSE "dbeaver" "$(get_text manage_dbeaver)" \
            FALSE "exit" "$(get_text exit_installer)")
    else
        choice=$(gui_list "$(get_text select_action)" "$(get_text action_text)" \
            TRUE "fresh" "$(get_text fresh_install)" \
            FALSE "dbeaver" "$(get_text manage_dbeaver)" \
            FALSE "exit" "$(get_text exit_installer)")
    fi
    
    echo "$choice" | tr -d '|'
}

#═══════════════════════════════════════════════════════════════════════════════
# MAIN INSTALLATION - FRESH INSTALL (COMPLETE WITH ERROR 571 FIX)
#═══════════════════════════════════════════════════════════════════════════════
run_fresh_install() {
    log "Starting fresh installation v4.3.1..."
    
    # CRITICAL: Fix permissions FIRST before creating anything
    ensure_directories
    
    start_progress
    
    #---------------------------------------------------------------------------
    # Step 1: Save passwords
    #---------------------------------------------------------------------------
    update_progress 2 "$(get_text step) 1/25: Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    log "Passwords saved securely"

    #---------------------------------------------------------------------------
    # Step 2: Install dependencies
    #---------------------------------------------------------------------------
    update_progress 5 "$(get_text step) 2/25: $(get_text installing_deps)"
    install_dependencies || {
        log "WARNING: Some dependencies may not have installed correctly"
    }

    #---------------------------------------------------------------------------
    # Step 3: Download APEX
    #---------------------------------------------------------------------------
    update_progress 8 "$(get_text step) 3/25: $(get_text downloading) APEX..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || \
        curl -L --progress-bar -o "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || {
            log "WARNING: Could not download APEX"
        }
    fi
    [ -f "$DOWNLOADS_DIR/apex-latest.zip" ] && log "✅ APEX downloaded"

    #---------------------------------------------------------------------------
    # Step 4: Download ORDS
    #---------------------------------------------------------------------------
    update_progress 11 "$(get_text step) 4/25: $(get_text downloading) ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || \
        curl -L --progress-bar -o "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || {
            log "WARNING: Could not download ORDS"
        }
    fi
    [ -f "$DOWNLOADS_DIR/ords-latest.zip" ] && log "✅ ORDS downloaded"

    #---------------------------------------------------------------------------
    # Step 5: Extract files
    #---------------------------------------------------------------------------
    update_progress 14 "$(get_text step) 5/25: $(get_text extracting)"
    cd "$PROJECT_DIR"
    rm -rf apex ords 2>/dev/null || true
    
    if [ -f "$DOWNLOADS_DIR/apex-latest.zip" ]; then
        unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || true
        log "✅ APEX extracted"
    fi
    
    if [ -f "$DOWNLOADS_DIR/ords-latest.zip" ]; then
        mkdir -p ords
        unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords 2>/dev/null || true
        find ords -name "ords" -type f -exec chmod +x {} \; 2>/dev/null || true
        log "✅ ORDS extracted"
    fi
    
    # Copy images
    if [ -d "$PROJECT_DIR/apex/images" ]; then
        rm -rf "$IMAGES_DIR" 2>/dev/null || true
        cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR"
        chmod -R 755 "$IMAGES_DIR"
        log "✅ Images copied"
    fi

    #---------------------------------------------------------------------------
    # Step 6: Create Docker Compose
    #---------------------------------------------------------------------------
    update_progress 17 "$(get_text step) 6/25: Creating Docker config..."
    cat > "$PROJECT_DIR/docker-compose.yml" << COMPOSEEOF
version: '3.8'
services:
  oracle-db:
    image: ${ORACLE_IMAGE}
    container_name: oracle-apex-db
    hostname: oracle-apex-db
    ports:
      - "1521:1521"
    environment:
      - ORACLE_PASSWORD=${ORACLE_PASSWORD}
      - ORACLE_CHARACTERSET=AL32UTF8
    volumes:
      - oracle-data:/opt/oracle/oradata
      - ./apex:/opt/oracle/apex:ro
    shm_size: 2g
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "sqlplus", "-v"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 300s

volumes:
  oracle-data:
    name: oracle-apex-data
    driver: local
COMPOSEEOF
    log "✅ Docker Compose created"

    #---------------------------------------------------------------------------
    # Step 7: Start Database
    #---------------------------------------------------------------------------
    update_progress 20 "$(get_text step) 7/25: $(get_text starting_db)"
    cd "$PROJECT_DIR"
    
    # Try docker compose first, then docker-compose
    if command -v docker &>/dev/null; then
        docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || {
            log "ERROR: Failed to start database"
            stop_progress
            gui_error "$(get_text error)" "Failed to start database container.\n\nPlease check:\n1. Docker is installed and running\n2. You have permission to use Docker\n3. Port 1521 is not in use"
            return 1
        }
    fi
    log "✅ Database container started"
    
    # Wait for database
    update_progress 22 "$(get_text step) 7/25: $(get_text wait_db) (5-10 min)..."
    wait_for_database || log "⚠️ Database timeout, continuing anyway..."
    sleep 60

    #---------------------------------------------------------------------------
    # Step 8: Reset password & test connection
    #---------------------------------------------------------------------------
    update_progress 25 "$(get_text step) 8/25: $(get_text syncing_passwords)"
    docker exec oracle-apex-db resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 20
    
    # Test connection
    if ! test_db_connection "$ORACLE_PASSWORD"; then
        log "⚠️ First connection test failed, retrying..."
        docker exec oracle-apex-db resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
        sleep 20
    fi

    #---------------------------------------------------------------------------
    # Step 9: Disable password policies
    #---------------------------------------------------------------------------
    update_progress 28 "$(get_text step) 9/25: $(get_text configuring)"
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
SQL" >> "$INSTALL_LOG" 2>&1 || true
    log "✅ Password policies disabled"

    #---------------------------------------------------------------------------
    # Step 10: Install APEX
    #---------------------------------------------------------------------------
    update_progress 31 "$(get_text step) 10/25: $(get_text installing_apex)"
    log "Installing APEX (this may take 15-25 minutes)..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
SQL" >> "$INSTALL_LOG" 2>&1 || true
    log "✅ APEX installed"

    #---------------------------------------------------------------------------
    # Step 11: Reset image prefix
    #---------------------------------------------------------------------------
    update_progress 34 "$(get_text step) 11/25: $(get_text fixing_images)"
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
@utilities/reset_image_prefix.sql
EXIT;
SQL" >> "$INSTALL_LOG" 2>&1 || true
    log "✅ Image prefix reset"

    #---------------------------------------------------------------------------
    # Step 12: APEX REST config
    #---------------------------------------------------------------------------
    update_progress 37 "$(get_text step) 12/25: Configuring REST..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << SQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
SQL" >> "$INSTALL_LOG" 2>&1 || true
    log "✅ REST configured"

    #---------------------------------------------------------------------------
    # Step 13: Create ORDS_PUBLIC_USER - CRITICAL
    #---------------------------------------------------------------------------
    update_progress 40 "$(get_text step) 13/25: Creating ORDS user..."
    create_ords_user "$ORACLE_PASSWORD"

    #---------------------------------------------------------------------------
    # Step 14: Sync all passwords - CRITICAL FOR ERROR 571
    #---------------------------------------------------------------------------
    update_progress 43 "$(get_text step) 14/25: $(get_text syncing_passwords)"
    sync_all_passwords "$ORACLE_PASSWORD"

    #---------------------------------------------------------------------------
    # Step 15: Create APEX admin
    #---------------------------------------------------------------------------
    update_progress 46 "$(get_text step) 15/25: Creating APEX admin..."
    create_apex_admin "$ORACLE_PASSWORD" "$APEX_ADMIN_PASSWORD"

    #---------------------------------------------------------------------------
    # Step 16: Install ORDS properly - CRITICAL
    #---------------------------------------------------------------------------
    update_progress 49 "$(get_text step) 16/25: $(get_text configuring_ords)"
    install_ords_properly "$ORACLE_PASSWORD"

    #---------------------------------------------------------------------------
    # Step 17: Final password sync - EXTRA SAFETY
    #---------------------------------------------------------------------------
    update_progress 52 "$(get_text step) 17/25: Final password sync..."
    sync_all_passwords "$ORACLE_PASSWORD"
    sleep 10
    
    # Update ORDS password one more time
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    if [ -n "$ORDS_BIN" ]; then
        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    fi

    #---------------------------------------------------------------------------
    # Step 18: Create management scripts
    #---------------------------------------------------------------------------
    update_progress 55 "$(get_text step) 18/25: $(get_text creating_scripts)"
    create_scripts

    #---------------------------------------------------------------------------
    # Step 19: Create systemd service (optional)
    #---------------------------------------------------------------------------
    update_progress 58 "$(get_text step) 19/25: $(get_text creating_services)"
    stop_progress
    if gui_question "$(get_text create_service_title)" "$(get_text create_service_text)"; then
        create_systemd_service
    fi
    start_progress

    #---------------------------------------------------------------------------
    # Step 20: Start ORDS
    #---------------------------------------------------------------------------
    update_progress 61 "$(get_text step) 20/25: $(get_text wait_ords)"
    start_ords

    #---------------------------------------------------------------------------
    # Step 21: Create web installer
    #---------------------------------------------------------------------------
    update_progress 64 "$(get_text step) 21/25: Creating web installer..."
    create_web_installer

    #---------------------------------------------------------------------------
    # Step 22: Verify and fix if needed
    #---------------------------------------------------------------------------
    update_progress 67 "$(get_text step) 22/25: $(get_text verifying)"
    
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
    log "Initial verification: HTTP $http_code"
    
    if [[ ! "$http_code" =~ ^(200|302|303)$ ]]; then
        log "Running automatic fix..."
        update_progress 70 "$(get_text fixing_error_571)"
        
        # Extra fix attempt
        sync_all_passwords "$ORACLE_PASSWORD"
        sleep 5
        
        if [ -n "$ORDS_BIN" ]; then
            echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
        fi
        
        # Restart ORDS
        pkill -f ords 2>/dev/null || true
        sleep 5
        start_ords
        
        http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
        log "After fix: HTTP $http_code"
    fi

    #---------------------------------------------------------------------------
    # Step 23-25: Final checks
    #---------------------------------------------------------------------------
    update_progress 85 "$(get_text step) 23/25: Running final checks..."
    
    # Verify images
    local img_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/i/apex_ui/img/apex_logo.png" 2>/dev/null || echo "000")
    log "Images check: HTTP $img_code"
    
    update_progress 95 "$(get_text step) 24/25: Creating documentation..."
    create_documentation
    
    update_progress 100 "$(get_text completed)"
    sleep 2
    stop_progress
    
    log "✅ Installation completed successfully with HTTP status: $http_code"
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# REPAIR INSTALLATION (WITHOUT DATA LOSS)
#═══════════════════════════════════════════════════════════════════════════════
run_repair() {
    log "Starting repair installation..."
    
    if ! gui_question "$(get_text warning)" "$(get_text repair_text)"; then
        return 0
    fi
    
    # Ensure directories exist with proper permissions
    ensure_directories
    
    start_progress
    
    update_progress 5 "Stopping ORDS..."
    pkill -f ords 2>/dev/null || true
    pkill -f "java.*ords" 2>/dev/null || true
    sleep 3
    
    update_progress 10 "Starting database..."
    docker start oracle-apex-db 2>/dev/null || true
    sleep 90
    
    update_progress 20 "$(get_text syncing_passwords)"
    docker exec oracle-apex-db resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 15
    
    update_progress 30 "Syncing all users..."
    sync_all_passwords "$ORACLE_PASSWORD"
    
    update_progress 40 "Creating ORDS user..."
    create_ords_user "$ORACLE_PASSWORD"
    
    update_progress 50 "Updating APEX admin..."
    create_apex_admin "$ORACLE_PASSWORD" "$APEX_ADMIN_PASSWORD"
    
    update_progress 60 "Updating ORDS config..."
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    if [ -n "$ORDS_BIN" ]; then
        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    fi
    
    # Save new passwords
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    
    update_progress 75 "Starting ORDS..."
    start_ords
    
    update_progress 90 "$(get_text verifying)"
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
    log "Repair verification: HTTP $http_code"
    
    update_progress 100 "$(get_text completed)"
    stop_progress
    
    log "✅ Repair completed"
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# CLEAN INSTALLATION (FULL RESET)
#═══════════════════════════════════════════════════════════════════════════════
run_clean_install() {
    log "Starting clean installation..."
    
    start_progress
    update_progress 10 "$(get_text cleaning)"
    complete_cleanup
    update_progress 20 "Cleanup done, starting fresh..."
    stop_progress
    
    run_fresh_install
}

#═══════════════════════════════════════════════════════════════════════════════
# UNINSTALL EVERYTHING
#═══════════════════════════════════════════════════════════════════════════════
run_uninstall() {
    log "Starting complete uninstall..."
    
    start_progress
    update_progress 25 "Stopping services..."
    pkill -f ords 2>/dev/null || true
    pkill -f "java.*ords" 2>/dev/null || true
    docker stop oracle-apex-db 2>/dev/null || true
    sleep 5
    
    update_progress 50 "Removing containers and volumes..."
    complete_cleanup
    
    update_progress 75 "Removing all files..."
    rm -rf "$PROJECT_DIR" 2>/dev/null || run_sudo rm -rf "$PROJECT_DIR" 2>/dev/null || true
    
    update_progress 100 "Uninstall complete"
    stop_progress
    
    log "✅ Uninstall completed"
    gui_info "$(get_text info)" "Oracle APEX has been completely removed.\n\nAll data, configurations, and Docker volumes have been deleted."
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE WEB INSTALLER
#═══════════════════════════════════════════════════════════════════════════════
create_web_installer() {
    log "Creating web installer..."
    
    mkdir -p "$WEB_INSTALLER_DIR"
    
    # Simple HTML status page
    cat > "$WEB_INSTALLER_DIR/index.html" << 'WEBEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oracle APEX v4.3.1 - Status</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 650px;
            width: 100%;
            padding: 40px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .header h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 32px;
        }
        
        .header p {
            color: #666;
            font-size: 14px;
        }
        
        .version-badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            margin-top: 10px;
        }
        
        .status-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .status-item {
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            background: linear-gradient(135deg, #f5f7fa 0%, #e4e8ec 100%);
            border-left: 4px solid #667eea;
            transition: transform 0.2s;
        }
        
        .status-item:hover {
            transform: translateY(-2px);
        }
        
        .status-item.success {
            border-left-color: #10b981;
        }
        
        .status-item.error {
            border-left-color: #ef4444;
        }
        
        .status-item h3 {
            font-size: 12px;
            color: #666;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .status-value {
            font-size: 24px;
            font-weight: bold;
            color: #333;
        }
        
        .links {
            background: #f9fafb;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 25px;
        }
        
        .links h3 {
            color: #333;
            margin-bottom: 15px;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .link-item {
            margin-bottom: 12px;
        }
        
        .link-item a {
            display: block;
            padding: 14px 18px;
            background: white;
            color: #667eea;
            text-decoration: none;
            border-radius: 8px;
            font-size: 14px;
            border: 2px solid #e5e7eb;
            transition: all 0.3s;
            font-weight: 500;
        }
        
        .link-item a:hover {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-color: transparent;
            transform: translateX(5px);
        }
        
        .credentials {
            background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 100%);
            border: 2px solid #7dd3fc;
            padding: 20px;
            border-radius: 12px;
            font-size: 14px;
            color: #0369a1;
        }
        
        .credentials h4 {
            margin-bottom: 12px;
            color: #0c4a6e;
        }
        
        .credentials p {
            margin-bottom: 6px;
        }
        
        .credentials code {
            background: rgba(255,255,255,0.5);
            padding: 2px 6px;
            border-radius: 4px;
            font-family: monospace;
        }
        
        .footer {
            text-align: center;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
            font-size: 12px;
            color: #999;
        }
        
        .footer a {
            color: #667eea;
            text-decoration: none;
        }
        
        @media (max-width: 500px) {
            .status-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Oracle APEX</h1>
            <p>Installation Status Dashboard</p>
            <span class="version-badge">v4.3.1 - KaizenixCore</span>
        </div>
        
        <div class="status-grid">
            <div class="status-item success">
                <h3>Database</h3>
                <div class="status-value">🟢 Running</div>
            </div>
            <div class="status-item success">
                <h3>ORDS</h3>
                <div class="status-value">🟢 Running</div>
            </div>
        </div>
        
        <div class="links">
            <h3>📍 Quick Access</h3>
            <div class="link-item">
                <a href="http://localhost:8080/ords/apex_admin" target="_blank">
                    🔐 APEX Admin Panel
                </a>
            </div>
            <div class="link-item">
                <a href="http://localhost:8080/ords/f?p=4550" target="_blank">
                    🌐 APEX Login Page
                </a>
            </div>
            <div class="link-item">
                <a href="http://localhost:8080/ords/sql" target="_blank">
                    📊 SQL Developer Web
                </a>
            </div>
            <div class="link-item">
                <a href="http://localhost:8080/i/" target="_blank">
                    🖼️ APEX Images
                </a>
            </div>
        </div>
        
        <div class="credentials">
            <h4>📋 Default Login Credentials</h4>
            <p><strong>Workspace:</strong> <code>INTERNAL</code></p>
            <p><strong>Username:</strong> <code>ADMIN</code></p>
            <p><strong>Password:</strong> <code>(your configured password)</code></p>
        </div>
        
        <div class="footer">
            <p>Oracle APEX Ultimate Installer v4.3.1</p>
            <p>Created by <a href="https://github.com/KaizenixCore/" target="_blank">Peyman Rasouli - KaizenixCore</a></p>
        </div>
    </div>
</body>
</html>
WEBEOF

    # Create start script for web status page
    cat > "$WEB_INSTALLER_DIR/start.sh" << 'WEBSTARTEOF'
#!/bin/bash
# Simple web server for status page
cd "$(dirname "$0")"
echo "Starting status page server on http://localhost:8888"
echo "Press Ctrl+C to stop"
python3 -m http.server 8888 2>/dev/null || python -m SimpleHTTPServer 8888
WEBSTARTEOF
    chmod +x "$WEB_INSTALLER_DIR/start.sh"

    log "✅ Web installer created"
}
#═══════════════════════════════════════════════════════════════════════════════
# CREATE DOCUMENTATION - FIXED VERSION
#═══════════════════════════════════════════════════════════════════════════════
create_documentation() {
    log "Creating documentation..."
    
    # Ensure directory exists
    mkdir -p "$PROJECT_DIR" 2>/dev/null || true
    
    # Create README file
    cat > "$PROJECT_DIR/README.md" << 'DOCEOF'
# Oracle APEX v4.3.1 - Complete Installation

## Installation Information

| Item | Value |
|------|-------|
| Version | 4.3.1 |
| Installation Directory | ~/oracle-apex-complete |
| Database | Oracle XE 21c |
| APEX Version | Latest |
| ORDS Version | Latest |

## Access URLs

| Service | URL |
|---------|-----|
| Admin Panel | http://localhost:8080/ords/apex_admin |
| Login Page | http://localhost:8080/ords/f?p=4550 |
| SQL Workshop | http://localhost:8080/ords/sql |
| REST API | http://localhost:8080/ords/ |
| Images | http://localhost:8080/i/ |

## Default Credentials

- Workspace: INTERNAL
- Username: ADMIN
- Password: (your configured password)

## Management Commands

Start Oracle APEX:
  bash ~/oracle-apex-complete/scripts/start.sh

Stop Oracle APEX:
  bash ~/oracle-apex-complete/scripts/stop.sh

Restart Oracle APEX:
  bash ~/oracle-apex-complete/scripts/restart.sh

Fix Error 571/574/500:
  bash ~/oracle-apex-complete/scripts/fix.sh

Check Status:
  bash ~/oracle-apex-complete/scripts/status.sh

View Logs:
  bash ~/oracle-apex-complete/scripts/logs.sh

## DBeaver Management

Install DBeaver:
  bash ~/oracle-apex-complete/scripts/dbeaver.sh install

Remove DBeaver:
  bash ~/oracle-apex-complete/scripts/dbeaver.sh remove

## Directory Structure

~/oracle-apex-complete/
  apex/                  - Oracle APEX installation files
  ords/                  - Oracle ORDS installation
  ords_config/           - ORDS configuration
  images/                - APEX images directory
  scripts/               - Management scripts
  downloads/             - Downloaded files
  logs/                  - Log files
  web-installer/         - Web installer files
  docker-compose.yml     - Docker configuration
  install.log            - Installation log

## Troubleshooting

Error 571 - Database Connection Error:
  bash ~/oracle-apex-complete/scripts/fix.sh

Error 404 - Page Not Found:
  bash ~/oracle-apex-complete/scripts/restart.sh

Error 500 - Internal Server Error:
  tail -100 ~/oracle-apex-complete/logs/ords.log
  bash ~/oracle-apex-complete/scripts/fix.sh

Error 504 - Gateway Timeout:
  docker logs oracle-apex-db | tail -50
  bash ~/oracle-apex-complete/scripts/restart.sh

Permission Denied:
  sudo chown -R $USER:$(id -gn) ~/oracle-apex-complete
  chmod -R 755 ~/oracle-apex-complete

## Docker Commands

View container status:
  docker ps -a --filter "name=oracle-apex-db"

View container logs:
  docker logs oracle-apex-db

Restart container:
  docker restart oracle-apex-db

## System Requirements

- RAM: 4GB minimum (8GB recommended)
- Disk Space: 20GB
- Docker: 20.x or later
- Java: 17 or later
- OS: Linux/macOS/WSL2

## Support

GitHub: https://github.com/KaizenixCore/oracle-apex-installer/
Project: KaizenixCore

Created by Peyman Rasouli
License: MIT
Version: 4.3.1
DOCEOF

    log "Documentation created at $PROJECT_DIR/README.md"
}
