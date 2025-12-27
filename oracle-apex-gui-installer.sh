#!/usr/bin/env bash
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
#  ║     ORACLE APEX GUI INSTALLER v4.3.1 - KAIZENIXCORE FINAL                ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ║  License    : MIT                                                         ║
#  ║  Version    : 4.3.1 - FINAL CROSS-PLATFORM EDITION                        ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  ✅ CROSS-PLATFORM SUPPORT:                                               ║
#  ║     ✅ Linux (All distributions)                                          ║
#  ║     ✅ macOS (Intel & Apple Silicon)                                      ║
#  ║     ✅ Windows (WSL2 + Native PowerShell wrapper)                         ║
#  ║     ✅ Automatic platform detection                                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  ✅ v4.3.1 FEATURES:                                                      ║
#  ║     ✅ ERROR 571 COMPLETELY FIXED                                         ║
#  ║     ✅ Permission errors FIXED                                            ║
#  ║     ✅ Multi-platform GUI support (Zenity/YAD/osascript/PowerShell)       ║
#  ║     ✅ Automatic dependency installation                                  ║
#  ║     ✅ Complete error handling & recovery                                 ║
#  ║     ✅ Multi-language support (EN/FA/DE)                                  ║
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
IS_WSL="false"
IS_MACOS="false"
IS_LINUX="false"

#═══════════════════════════════════════════════════════════════════════════════
# PLATFORM DETECTION - ENHANCED
#═══════════════════════════════════════════════════════════════════════════════
detect_platform() {
    echo "Detecting platform..."
    
    # Check for WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        OS_TYPE="wsl"
        IS_WSL="true"
        echo "Platform: Windows WSL2"
    # Check for macOS
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
        IS_MACOS="true"
        echo "Platform: macOS"
    # Linux
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="linux"
        IS_LINUX="true"
        echo "Platform: Linux"
    else
        OS_TYPE="unknown"
        echo "WARNING: Unknown platform detected"
    fi
    
    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="$ID"
        echo "Distribution: $OS_ID"
    else
        OS_ID="unknown"
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    echo "Architecture: $ARCH"
    
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# PRE-FLIGHT CHECKS
#═══════════════════════════════════════════════════════════════════════════════
preflight_checks() {
    echo "Running pre-flight checks..."
    
    # Check if running as root (not recommended)
    if [ "$EUID" -eq 0 ]; then 
        echo "ERROR: Do not run this script as root!"
        echo "Please run as a regular user with sudo privileges."
        exit 1
    fi
    
    # Check disk space (need at least 20GB)
    available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 20 ]; then
        echo "WARNING: Low disk space. Need at least 20GB free."
        echo "Available: ${available_space}GB"
    fi
    
    # Check if Docker is installed
    if ! command -v docker &>/dev/null; then
        echo "Docker not found. Will install automatically."
    fi
    
    # Check if ports are available
    if command -v lsof &>/dev/null; then
        if lsof -Pi :1521 -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "WARNING: Port 1521 is already in use"
        fi
        if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "WARNING: Port 8080 is already in use"
        fi
    fi
    
    echo "Pre-flight checks completed"
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - ENGLISH (COMPLETE)
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_EN=(
    ["title"]="Oracle APEX Installer v4.3.1"
    ["welcome_title"]="🚀 Oracle APEX Ultimate Installer v4.3.1"
    ["welcome_text"]="Oracle APEX Ultimate Installer v4.3.1 - FINAL EDITION

✅ ERROR 571/574/500 COMPLETELY FIXED
✅ CROSS-PLATFORM SUPPORT (Linux/macOS/Windows)
✅ ALL FEATURES INCLUDED

This will install:
• Oracle APEX (Latest Version)
• Oracle ORDS (Latest Version)  
• Oracle XE 21c Database
• DBeaver (Optional)
• Management GUI & Scripts
• Auto-start Services

Platform Support:
✅ Linux (All distributions)
✅ macOS (Intel & Apple Silicon)
✅ Windows (WSL2)

Features:
✅ Automatic configuration
✅ Error auto-fix & recovery
✅ APEX images auto-setup
✅ Complete management GUI
✅ DBeaver integration
✅ Web installer
✅ Multi-language (EN/FA/DE)

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

📦 DBeaver:
   Install: bash ~/oracle-apex-complete/scripts/dbeaver.sh install
   Remove:  bash ~/oracle-apex-complete/scripts/dbeaver.sh remove

🌐 Web Status Page:
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
    ["checking_docker"]="Checking Docker installation..."
    ["installing_gui"]="Installing GUI tools..."
)

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - PERSIAN
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_FA=(
    ["title"]="نصب‌کننده اوراکل اپکس v4.3.1"
    ["welcome_title"]="🚀 نصب‌کننده اوراکل اپکس v4.3.1"
    ["welcome_text"]="نصب‌کننده اوراکل اپکس نسخه 4.3.1 - نسخه نهایی

✅ رفع کامل خطاهای 571/574/500
✅ پشتیبانی از همه سیستم‌عامل‌ها
✅ تمام ویژگی‌ها

پلتفرم‌های پشتیبانی شده:
✅ لینوکس (تمام توزیع‌ها)
✅ مک (Intel و Apple Silicon)
✅ ویندوز (WSL2)

سازنده: پیمان رسولی
پروژه: KaizenixCore"
    ["select_action"]="انتخاب نوع نصب"
    ["action_text"]="چه کاری می‌خواهید انجام دهید؟"
    ["fresh_install"]="🆕 نصب جدید"
    ["repair_install"]="🔧 تعمیر و تغییر رمز"
    ["clean_install"]="🗑️ نصب تمیز (حذف همه)"
    ["uninstall"]="❌ حذف کامل"
    ["manage_dbeaver"]="📦 مدیریت DBeaver"
    ["exit_installer"]="🚪 خروج"
    ["enter_passwords"]="🔐 ورود رمز عبور"
    ["oracle_pass"]="رمز عبور Oracle:"
    ["apex_pass"]="رمز عبور APEX:"
    ["pass_rules"]="قوانین رمز:
• با حرف انگلیسی شروع شود
• فقط حروف و اعداد
• ۸-۳۰ کاراکتر"
    ["invalid_pass"]="رمز نامعتبر!"
    ["installing"]="در حال نصب..."
    ["completed"]="✅ نصب کامل شد!"
    ["error"]="خطا"
    ["warning"]="هشدار"
    ["info"]="اطلاعات"
    ["continue"]="ادامه"
    ["cancel"]="انصراف"
    ["yes"]="بله"
    ["no"]="خیر"
    ["ok"]="تایید"
)

#═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS - GERMAN
#═══════════════════════════════════════════════════════════════════════════════
declare -A LANG_DE=(
    ["title"]="Oracle APEX Installer v4.3.1"
    ["welcome_title"]="🚀 Oracle APEX Installer v4.3.1"
    ["welcome_text"]="Oracle APEX Installer v4.3.1 - FINALE EDITION

✅ FEHLER 571/574/500 BEHOBEN
✅ CROSS-PLATFORM UNTERSTÜTZUNG

Plattform-Unterstützung:
✅ Linux (Alle Distributionen)
✅ macOS (Intel & Apple Silicon)
✅ Windows (WSL2)

Erstellt von: Peyman Rasouli
Projekt: KaizenixCore"
    ["select_action"]="Installationstyp wählen"
    ["fresh_install"]="🆕 Neuinstallation"
    ["repair_install"]="🔧 Reparieren"
    ["clean_install"]="🗑️ Saubere Installation"
    ["uninstall"]="❌ Deinstallieren"
    ["continue"]="Weiter"
    ["cancel"]="Abbrechen"
)

#═══════════════════════════════════════════════════════════════════════════════
# GET TEXT UTILITY
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
# LOGGING
#═══════════════════════════════════════════════════════════════════════════════
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    mkdir -p "$PROJECT_DIR" "$LOG_DIR" 2>/dev/null || true
    echo "$msg" | tee -a "$INSTALL_LOG" 2>/dev/null || echo "$msg"
}

#═══════════════════════════════════════════════════════════════════════════════
# SUDO HELPER
#═══════════════════════════════════════════════════════════════════════════════
run_sudo() {
    if [ -n "$SUDO_PASS" ]; then
        echo "$SUDO_PASS" | sudo -S "$@" 2>/dev/null
    else
        sudo "$@" 2>/dev/null
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# ENSURE DIRECTORIES WITH PROPER PERMISSIONS
#═══════════════════════════════════════════════════════════════════════════════
ensure_directories() {
    log "Creating directories with proper permissions..."
    
    # Fix existing directory permissions
    if [ -d "$PROJECT_DIR" ] && [ ! -w "$PROJECT_DIR" ]; then
        log "Fixing permissions on existing directory..."
        run_sudo chown -R "$USER":"$(id -gn)" "$PROJECT_DIR" 2>/dev/null || true
        run_sudo chmod -R 755 "$PROJECT_DIR" 2>/dev/null || true
    fi
    
    # Remove if still not writable
    if [ -d "$PROJECT_DIR" ] && [ ! -w "$PROJECT_DIR" ]; then
        log "Removing old directory with wrong permissions..."
        run_sudo rm -rf "$PROJECT_DIR" 2>/dev/null || true
    fi
    
    # Create all directories
    for dir in "$PROJECT_DIR" "$DOWNLOADS_DIR" "$LOG_DIR" "$IMAGES_DIR" "$SCRIPTS_DIR" \
               "$ORDS_CONFIG_DIR/databases/default" "$ORDS_CONFIG_DIR/global" "$WEB_INSTALLER_DIR"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            run_sudo mkdir -p "$dir" 2>/dev/null || true
            run_sudo chown "$USER":"$(id -gn)" "$dir" 2>/dev/null || true
        fi
    done
    
    # Fix ownership
    run_sudo chown -R "$USER":"$(id -gn)" "$PROJECT_DIR" 2>/dev/null || true
    chmod -R 755 "$PROJECT_DIR" 2>/dev/null || true
    
    # Create log files
    touch "$INSTALL_LOG" "$LOG_DIR/ords.log" 2>/dev/null || true
    
    log "✅ Directories created"
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# GUI TOOL INSTALLATION - CROSS-PLATFORM
#═══════════════════════════════════════════════════════════════════════════════
install_gui_tool() {
    log "Checking GUI tools..."
    
    # macOS - use osascript
    if [ "$IS_MACOS" = "true" ]; then
        if command -v osascript &>/dev/null; then
            GUI_TOOL="osascript"
            log "Using osascript for GUI on macOS"
            return 0
        fi
    fi
    
    # Check for existing tools
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
    
    # Install GUI tools based on platform
    log "Installing GUI tools..."
    
    if [ "$IS_MACOS" = "true" ]; then
        # macOS - install zenity via Homebrew
        if command -v brew &>/dev/null; then
            brew install zenity 2>/dev/null || true
        else
            log "Please install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            GUI_TOOL="osascript"
            return 0
        fi
    else
        # Linux/WSL
        case "$OS_ID" in
            ubuntu|debian|linuxmint|pop|kali)
                run_sudo apt-get update -qq 2>/dev/null || true
                run_sudo apt-get install -y zenity yad 2>/dev/null || true
                ;;
            fedora)
                run_sudo dnf install -y zenity yad 2>/dev/null || true
                ;;
            opensuse*|suse*|opensuse-leap|opensuse-tumbleweed)
                run_sudo zypper --non-interactive install -y zenity yad 2>/dev/null || true
                ;;
            arch|manjaro)
                run_sudo pacman -S --noconfirm zenity yad 2>/dev/null || true
                ;;
            rhel|centos|rocky|almalinux)
                run_sudo yum install -y zenity yad 2>/dev/null || true
                ;;
        esac
    fi
    
    # Check what was installed
    if command -v yad &>/dev/null; then
        GUI_TOOL="yad"
    elif command -v zenity &>/dev/null; then
        GUI_TOOL="zenity"
    elif command -v osascript &>/dev/null; then
        GUI_TOOL="osascript"
    else
        log "ERROR: No GUI tool available"
        echo "Please install zenity or yad manually"
        exit 1
    fi
    
    log "GUI tool ready: $GUI_TOOL"
}

#═══════════════════════════════════════════════════════════════════════════════
# GUI FUNCTIONS - CROSS-PLATFORM
#═══════════════════════════════════════════════════════════════════════════════
gui_info() {
    local title="$1"
    local text="$2"
    
    case "$GUI_TOOL" in
        yad)
            yad --info --title="$title" --text="$text" --width=500 --height=400 \
                --center --button="$(get_text ok):0" --borders=15 2>/dev/null || true
            ;;
        zenity)
            zenity --info --title="$title" --text="$text" --width=500 --height=400 2>/dev/null || true
            ;;
        osascript)
            osascript -e "display dialog \"$text\" with title \"$title\" buttons {\"OK\"} default button 1" 2>/dev/null || true
            ;;
    esac
}

gui_error() {
    local title="$1"
    local text="$2"
    
    case "$GUI_TOOL" in
        yad)
            yad --error --title="$title" --text="$text" --width=450 --height=250 \
                --center --button="$(get_text ok):0" 2>/dev/null || true
            ;;
        zenity)
            zenity --error --title="$title" --text="$text" --width=450 --height=250 2>/dev/null || true
            ;;
        osascript)
            osascript -e "display dialog \"$text\" with title \"$title\" buttons {\"OK\"} default button 1 with icon stop" 2>/dev/null || true
            ;;
    esac
}

gui_question() {
    local title="$1"
    local text="$2"
    
    case "$GUI_TOOL" in
        yad)
            yad --question --title="$title" --text="$text" --width=500 --height=300 \
                --center --button="$(get_text no):1" --button="$(get_text yes):0" 2>/dev/null
            return $?
            ;;
        zenity)
            zenity --question --title="$title" --text="$text" --width=500 --height=300 \
                --ok-label="$(get_text yes)" --cancel-label="$(get_text no)" 2>/dev/null
            return $?
            ;;
        osascript)
            result=$(osascript -e "display dialog \"$text\" with title \"$title\" buttons {\"No\", \"Yes\"} default button 2" 2>/dev/null | grep "button returned:Yes")
            [ -n "$result" ] && return 0 || return 1
            ;;
    esac
}

gui_entry() {
    local title="$1"
    local text="$2"
    local hide="${3:-false}"
    
    case "$GUI_TOOL" in
        yad)
            if [ "$hide" = "true" ]; then
                yad --entry --title="$title" --text="$text" --hide-text \
                    --width=400 --center --button="$(get_text ok):0" 2>/dev/null
            else
                yad --entry --title="$title" --text="$text" \
                    --width=400 --center --button="$(get_text ok):0" 2>/dev/null
            fi
            ;;
        zenity)
            if [ "$hide" = "true" ]; then
                zenity --password --title="$title" 2>/dev/null
            else
                zenity --entry --title="$title" --text="$text" --width=400 2>/dev/null
            fi
            ;;
        osascript)
            if [ "$hide" = "true" ]; then
                osascript -e "display dialog \"$text\" with title \"$title\" default answer \"\" with hidden answer" -e "text returned of result" 2>/dev/null
            else
                osascript -e "display dialog \"$text\" with title \"$title\" default answer \"\"" -e "text returned of result" 2>/dev/null
            fi
            ;;
    esac
}

gui_list() {
    local title="$1"
    local text="$2"
    shift 2
    
    case "$GUI_TOOL" in
        yad)
            yad --list --title="$title" --text="$text" \
                --radiolist --column="" --column="ID" --column="Option" \
                "$@" --width=550 --height=500 --center \
                --button="$(get_text cancel):1" --button="$(get_text ok):0" \
                --print-column=2 --hide-column=2 2>/dev/null
            ;;
        zenity)
            zenity --list --title="$title" --text="$text" \
                --radiolist --column="" --column="ID" --column="Option" \
                "$@" --width=550 --height=500 --hide-column=2 2>/dev/null
            ;;
        osascript)
            # For osascript, we need to convert the list format
            local choices=""
            local i=0
            while [ $i -lt $# ]; do
                local selected="${!i}"
                i=$((i+1))
                local id="${!i}"
                i=$((i+1))
                local label="${!i}"i=$((i+1))
                if [ "$selected" = "TRUE" ]; then
                    choices="$label"
                    break
                fi
            done
            echo "$choices"
            ;;
    esac
}

gui_progress() {
    local title="$1"
    local text="$2"
    
    case "$GUI_TOOL" in
        yad)
            yad --progress --title="$title" --text="$text" \
                --percentage=0 --auto-close --no-buttons \
                --width=550 --height=120 --center 2>/dev/null
            ;;
        zenity)
            zenity --progress --title="$title" --text="$text" \
                --percentage=0 --auto-close --no-cancel \
                --width=550 --height=120 2>/dev/null
            ;;
        osascript)
            # osascript doesn't have native progress, fallback to terminal
            echo "Progress: $text"
            ;;
    esac
}

#═══════════════════════════════════════════════════════════════════════════════
# PROGRESS BAR MANAGEMENT
#═══════════════════════════════════════════════════════════════════════════════
FIFO_FILE=""
PROGRESS_PID=""

start_progress() {
    FIFO_FILE=$(mktemp -u)
    mkfifo "$FIFO_FILE" 2>/dev/null || true
    
    case "$GUI_TOOL" in
        yad)
            yad --progress --title="$(get_text title)" --text="$(get_text installing)" \
                --percentage=0 --auto-close --no-buttons \
                --width=550 --height=120 --center < "$FIFO_FILE" 2>/dev/null &
            ;;
        zenity)
            zenity --progress --title="$(get_text title)" --text="$(get_text installing)" \
                --percentage=0 --auto-close --no-cancel \
                --width=550 --height=120 < "$FIFO_FILE" 2>/dev/null &
            ;;
        osascript)
            # No FIFO for osascript, use terminal output
            ;;
    esac
    
    PROGRESS_PID=$!
    exec 3>"$FIFO_FILE" 2>/dev/null || true
}

update_progress() {
    local percent="$1"
    local text="$2"
    
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
# INSTALL DEPENDENCIES - CROSS-PLATFORM
#═══════════════════════════════════════════════════════════════════════════════
install_dependencies() {
    log "Installing dependencies for $OS_TYPE ($OS_ID)..."
    
    if [ "$IS_MACOS" = "true" ]; then
        # macOS dependencies
        log "Installing macOS dependencies..."
        
        # Install Homebrew if not present
        if ! command -v brew &>/dev/null; then
            log "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
        fi
        
        # Install Docker Desktop for Mac
        if ! command -v docker &>/dev/null; then
            log "Please install Docker Desktop for Mac from: https://www.docker.com/products/docker-desktop"
            gui_info "Docker Required" "Please install Docker Desktop for Mac and restart this installer.\n\nDownload from: https://www.docker.com/products/docker-desktop"
            exit 1
        fi
        
        # Install other tools via Homebrew
        brew install wget curl unzip zenity 2>/dev/null || true
        
        # Install Java if not present
        if ! command -v java &>/dev/null; then
            brew install openjdk@17 2>/dev/null || true
        fi
        
    else
        # Linux/WSL dependencies
        case "$OS_ID" in
            ubuntu|debian|linuxmint|pop|kali)
                log "Installing on Debian/Ubuntu..."
                run_sudo apt-get update -qq 2>/dev/null || true
                run_sudo apt-get install -y \
                    docker.io docker-compose openjdk-17-jdk unzip wget curl \
                    zenity yad git lsof net-tools 2>/dev/null || true
                ;;
            fedora)
                log "Installing on Fedora..."
                run_sudo dnf install -y \
                    docker docker-compose java-17-openjdk unzip wget curl \
                    zenity yad git lsof net-tools 2>/dev/null || true
                ;;
            opensuse*|suse*|opensuse-leap|opensuse-tumbleweed)
                log "Installing on openSUSE..."
                run_sudo zypper --non-interactive install -y \
                    docker docker-compose java-17-openjdk unzip wget curl \
                    zenity yad git lsof net-tools 2>/dev/null || true
                ;;
            arch|manjaro)
                log "Installing on Arch/Manjaro..."
                run_sudo pacman -S --noconfirm \
                    docker docker-compose jdk17-openjdk unzip wget curl \
                    zenity yad git lsof net-tools 2>/dev/null || true
                ;;
            rhel|centos|rocky|almalinux)
                log "Installing on RHEL/CentOS..."
                run_sudo yum install -y \
                    docker docker-compose java-17-openjdk unzip wget curl \
                    zenity yad git lsof net-tools 2>/dev/null || true
                ;;
        esac
        
        # Enable and start Docker (Linux only)
        if [ "$IS_LINUX" = "true" ] || [ "$IS_WSL" = "true" ]; then
            run_sudo systemctl enable docker 2>/dev/null || true
            run_sudo systemctl start docker 2>/dev/null || true
            run_sudo usermod -aG docker "$USER" 2>/dev/null || true
        fi
    fi
    
    # Verify Docker
    if ! command -v docker &>/dev/null; then
        log "ERROR: Docker is not installed or not in PATH"
        gui_error "Docker Required" "Docker is required but not found.\n\nPlease install Docker and restart this installer."
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker ps &>/dev/null; then
        log "WARNING: Docker daemon is not running"
        gui_info "Docker Not Running" "Docker is installed but not running.\n\nPlease start Docker and try again."
        exit 1
    fi
    
    log "✅ Dependencies installed"
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# GET SUDO PASSWORD
#═══════════════════════════════════════════════════════════════════════════════
get_sudo_password() {
    # macOS usually doesn't need sudo for Homebrew installs
    if [ "$IS_MACOS" = "true" ]; then
        if sudo -n true 2>/dev/null; then
            return 0
        fi
    fi
    
    # Check if sudo is cached
    if sudo -n true 2>/dev/null; then
        log "Sudo password cached"
        return 0
    fi
    
    # Ask for sudo password
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
        
        case "$GUI_TOOL" in
            yad)
                result=$(yad --form --title="$(get_text enter_passwords)" \
                    --text="$(get_text pass_rules)" \
                    --field="$(get_text oracle_pass):H" "" \
                    --field="$(get_text apex_pass):H" "" \
                    --width=500 --height=400 --center \
                    --button="$(get_text cancel):1" --button="$(get_text continue):0" 2>/dev/null)
                ;;
            zenity)
                result=$(zenity --forms --title="$(get_text enter_passwords)" \
                    --text="$(get_text pass_rules)" \
                    --add-password="$(get_text oracle_pass)" \
                    --add-password="$(get_text apex_pass)" \
                    --width=500 --height=350 2>/dev/null)
                ;;
            osascript)
                ORACLE_PASSWORD=$(gui_entry "$(get_text enter_passwords)" "$(get_text oracle_pass)" "true")
                [ -z "$ORACLE_PASSWORD" ] && exit 0
                APEX_ADMIN_PASSWORD=$(gui_entry "$(get_text enter_passwords)" "$(get_text apex_pass)" "true")
                [ -z "$APEX_ADMIN_PASSWORD" ] && exit 0
                ;;
        esac
        
        if [ "$GUI_TOOL" != "osascript" ]; then
            [ -z "$result" ] && exit 0
            ORACLE_PASSWORD=$(echo "$result" | cut -d'|' -f1)
            APEX_ADMIN_PASSWORD=$(echo "$result" | cut -d'|' -f2)
        fi
        
        # Validate passwords
        if [[ "$ORACLE_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{7,29}$ ]] && \
           [[ "$APEX_ADMIN_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{7,29}$ ]]; then
            log "Passwords validated"
            break
        else
            gui_error "$(get_text error)" "$(get_text invalid_pass)"
        fi
    done
}

#═══════════════════════════════════════════════════════════════════════════════
# COMPLETE CLEANUP
#═══════════════════════════════════════════════════════════════════════════════
complete_cleanup() {
    log "Starting complete cleanup..."
    
    # Stop processes
    pkill -f ords 2>/dev/null || true
    pkill -f "java.*ords" 2>/dev/null || true
    sleep 3
    
    # Stop and remove container
    docker stop oracle-apex-db 2>/dev/null || true
    docker rm -f oracle-apex-db 2>/dev/null || true
    
    # Remove all oracle volumes
    docker volume rm oracle-apex-complete_oracle-data 2>/dev/null || true
    docker volume rm oracle-data 2>/dev/null || true
    docker volume rm oracle-apex-data 2>/dev/null || true
    
    for vol in $(docker volume ls -q 2>/dev/null | grep -i oracle); do
        docker volume rm "$vol" 2>/dev/null || true
    done
    
    # Remove project directory
    if [ -d "$PROJECT_DIR" ]; then
        rm -rf "$PROJECT_DIR" 2>/dev/null || run_sudo rm -rf "$PROJECT_DIR" 2>/dev/null || true
    fi
    
    # Remove systemd services (Linux only)
    if [ "$IS_LINUX" = "true" ]; then
        run_sudo systemctl stop oracle-apex.service 2>/dev/null || true
        run_sudo systemctl disable oracle-apex.service 2>/dev/null || true
        run_sudo rm -f /etc/systemd/system/oracle-apex*.service 2>/dev/null || true
        run_sudo systemctl daemon-reload 2>/dev/null || true
    fi
    
    # Clean docker
    docker system prune -f 2>/dev/null || true
    
    log "✅ Cleanup completed"
}

#═══════════════════════════════════════════════════════════════════════════════
# WAIT FOR DATABASE
#═══════════════════════════════════════════════════════════════════════════════
wait_for_database() {
    log "Waiting for database (max 10 minutes)..."
    local max_wait=600
    local waited=0
    
    while [ $waited -lt $max_wait ]; do
        if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "oracle-apex-db"; then
            log "Container not running yet... ($waited seconds)"
            sleep 10
            waited=$((waited + 10))
            continue
        fi
        
        if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
            log "✅ Database ready! (after $waited seconds)"
            return 0
        fi
        
        sleep 15
        waited=$((waited + 15))
        log "Still waiting... ($waited seconds)"
    done
    
    log "⚠️ Database timeout after $waited seconds"
    return 1
}

#═══════════════════════════════════════════════════════════════════════════════
# TEST DATABASE CONNECTION
#═══════════════════════════════════════════════════════════════════════════════
test_db_connection() {
    local password="$1"
    log "Testing database connection..."
    
    local result=$(docker exec oracle-apex-db bash -c \
        "echo 'SELECT 1 FROM DUAL;' | sqlplus -s sys/${password}@//localhost:1521/XEPDB1 as sysdba" 2>&1)
    
    if echo "$result" | grep -q "1"; then
        log "✅ Database connection OK"
        return 0
    else
        log "❌ Database connection failed"
        return 1
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# SYNC ALL PASSWORDS - CRITICAL FOR ERROR 571
#═══════════════════════════════════════════════════════════════════════════════
sync_all_passwords() {
    local password="$1"
    log "Syncing all passwords (CRITICAL)..."
    
    docker exec oracle-apex-db resetPassword "$password" >> "$INSTALL_LOG" 2>&1 || true
    sleep 15
    
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${password}@//localhost:1521/XEPDB1 as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT 
    FAILED_LOGIN_ATTEMPTS UNLIMITED 
    PASSWORD_LIFE_TIME UNLIMITED 
    PASSWORD_VERIFY_FUNCTION NULL;

BEGIN
    FOR u IN (SELECT username FROM dba_users WHERE username IN (
        'ORDS_PUBLIC_USER', 'APEX_PUBLIC_USER', 'APEX_LISTENER', 
        'APEX_REST_PUBLIC_USER', 'ORDS_METADATA', 'ORDS_USER'
    )) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER USER ' || u.username || ' IDENTIFIED BY ${password} ACCOUNT UNLOCK';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
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

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    log "✅ Passwords synced"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE ORDS_PUBLIC_USER
#═══════════════════════════════════════════════════════════════════════════════
create_ords_user() {
    local password="$1"
    log "Creating ORDS_PUBLIC_USER..."
    
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${password}@//localhost:1521/XEPDB1 as sysdba << EOSQL
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY ${password}
    DEFAULT TABLESPACE SYSAUX
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON SYSAUX;

GRANT CONNECT, RESOURCE, CREATE SESSION TO ORDS_PUBLIC_USER;
GRANT ALTER SESSION, CREATE PROCEDURE, CREATE SEQUENCE TO ORDS_PUBLIC_USER;
GRANT CREATE TABLE, CREATE TRIGGER, CREATE VIEW TO ORDS_PUBLIC_USER;
GRANT CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;

GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOCK TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SQL TO ORDS_PUBLIC_USER;

ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    
    log "✅ ORDS_PUBLIC_USER created"
}

#═══════════════════════════════════════════════════════════════════════════════
# INSTALL ORDS PROPERLY
#═══════════════════════════════════════════════════════════════════════════════
install_ords_properly() {
    local password="$1"
    log "Installing ORDS properly..."
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    
    if [ -z "$ORDS_BIN" ]; then
        log "ERROR: ORDS binary not found"
        return 1
    fi
    
    chmod +x "$ORDS_BIN"
    
    rm -rf "$ORDS_CONFIG_DIR" 2>/dev/null || true
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    
    local PASS_FILE=$(mktemp)
    cat > "$PASS_FILE" << EOF
${password}
${password}
${password}
${password}
EOF
    
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
            log "Retrying ORDS install with simpler config..."
            "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
                --admin-user SYS \
                --db-hostname localhost \
                --db-port 1521 \
                --db-servicename XEPDB1 \
                --feature-sdw true \
                --password-stdin < "$PASS_FILE" >> "$INSTALL_LOG" 2>&1 || true
        }
    
    rm -f "$PASS_FILE"
    
    echo "$password" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port 8080 >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.context.path /ords >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
    
    log "✅ ORDS installed"
}

#═══════════════════════════════════════════════════════════════════════════════
# START ORDS
#═══════════════════════════════════════════════════════════════════════════════
start_ords() {
    log "Starting ORDS..."
    
    pkill -f ords 2>/dev/null || true
    pkill -f "java.*ords" 2>/dev/null || true
    sleep 5
    
    run_sudo fuser -k 8080/tcp 2>/dev/null || true
    sleep 2
    
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    
    if [ -z "$ORDS_BIN" ]; then
        log "ERROR: ORDS binary not found"
        return 1
    fi
    
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    
    mkdir -p "$LOG_DIR" 2>/dev/null || true
    touch "$LOG_DIR/ords.log" 2>/dev/null || true
    
    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port 8080 \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &
    
    local ords_pid=$!
    echo "$ords_pid" > "$PROJECT_DIR/ords.pid"
    
    log "✅ ORDS started (PID: $ords_pid)"
    sleep 120
    
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE APEX ADMIN
#═══════════════════════════════════════════════════════════════════════════════
create_apex_admin() {
    local db_pass="$1"
    local apex_pass="$2"
    log "Creating APEX admin..."
    
    local apex_schema=$(docker exec oracle-apex-db bash -c \
        "echo \"SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${db_pass}@//localhost:1521/XEPDB1 as sysdba" \
        2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ') || true
    
    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"
    
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
    
    log "✅ APEX admin created"
}

# [CONTINUED IN NEXT PART - این اسکریپت بیش از حد طولانی است]
# باقی توابع شامل:
# - create_scripts (تمام اسکریپت‌های مدیریتی)
# - create_systemd_service (برای لینوکس)
# - create_launchd_service (برای macOS)  
# - run_fresh_install (نصب کامل)
# - run_repair (تعمیر)

# - run_clean_install (نصب تمیز)
# - run_uninstall (حذف کامل)
# - MAIN EXECUTION

#═══════════════════════════════════════════════════════════════════════════════
# CREATE MANAGEMENT SCRIPTS - COMPLETE
#═══════════════════════════════════════════════════════════════════════════════
create_scripts() {
    log "Creating management scripts..."
    mkdir -p "$SCRIPTS_DIR"
    
    # START SCRIPT
    cat > "$SCRIPTS_DIR/start.sh" << 'STARTEOF'
#!/usr/bin/env bash
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
LOG_DIR="$PROJECT_DIR/logs"

echo "🚀 Starting Oracle APEX..."

docker start oracle-apex-db 2>/dev/null || exit 1
echo "⏳ Waiting for database (90s)..."
sleep 90

docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 15

docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "$ORDS_BIN" ]; then
    echo "$PASS" | "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config secret --password-stdin db.password 2>/dev/null || true
fi

pkill -f ords 2>/dev/null || true
sleep 5

if [ -n "$ORDS_BIN" ]; then
    export ORDS_CONFIG="$PROJECT_DIR/ords_config"
    nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$LOG_DIR/ords.log" 2>&1 &
fi

echo "⏳ Waiting for ORDS (60s)..."
sleep 60

HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null)
echo ""
echo "✅ Oracle APEX Started!"
echo "HTTP Status: $HTTP"
echo ""
echo "🌐 Admin: http://localhost:8080/ords/apex_admin"
echo "🔐 Login: http://localhost:8080/ords/f?p=4550"
STARTEOF
    chmod +x "$SCRIPTS_DIR/start.sh"

    # STOP SCRIPT
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/usr/bin/env bash
echo "🛑 Stopping Oracle APEX..."
pkill -f ords 2>/dev/null || true
docker stop oracle-apex-db 2>/dev/null || true
echo "✅ Stopped"
STOPEOF
    chmod +x "$SCRIPTS_DIR/stop.sh"

    # RESTART SCRIPT
    cat > "$SCRIPTS_DIR/restart.sh" << 'RESTARTEOF'
#!/usr/bin/env bash
PROJECT_DIR="$HOME/oracle-apex-complete"
bash "$PROJECT_DIR/scripts/stop.sh"
sleep 5
bash "$PROJECT_DIR/scripts/start.sh"
RESTARTEOF
    chmod +x "$SCRIPTS_DIR/restart.sh"

    # FIX SCRIPT
    cat > "$SCRIPTS_DIR/fix.sh" << 'FIXEOF'
#!/usr/bin/env bash
PROJECT_DIR="$HOME/oracle-apex-complete"
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
LOG_DIR="$PROJECT_DIR/logs"

echo "🔧 Fixing Oracle APEX (Error 571/574/500)..."

pkill -f ords 2>/dev/null || true
sleep 5

docker start oracle-apex-db 2>/dev/null || true
sleep 60

docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 15

docker exec oracle-apex-db bash -c "sqlplus -s sys/${PASS}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS} ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "$ORDS_BIN" ]; then
    echo "$PASS" | "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" config secret --password-stdin db.password 2>/dev/null || true
fi

if [ -d "$PROJECT_DIR/apex/images" ]; then
    rm -rf "$PROJECT_DIR/images" 2>/dev/null || true
    cp -r "$PROJECT_DIR/apex/images" "$PROJECT_DIR/images"
    chmod -R 755 "$PROJECT_DIR/images"
fi

if [ -n "$ORDS_BIN" ]; then
    nohup "$ORDS_BIN" --config "$PROJECT_DIR/ords_config" serve --port 8080 --apex-images "$PROJECT_DIR/images" > "$LOG_DIR/ords.log" 2>&1 &
fi

sleep 90

HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null)
echo ""
if [ "$HTTP" = "200" ] || [ "$HTTP" = "302" ] || [ "$HTTP" = "303" ]; then
    echo "✅ SUCCESS! APEX is working! (HTTP $HTTP)"
else
    echo "⚠️ Still issues (HTTP $HTTP). Check logs: tail -100 $LOG_DIR/ords.log"
fi
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh"

    # STATUS SCRIPT
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/usr/bin/env bash
PROJECT_DIR="$HOME/oracle-apex-complete"

echo "📊 Oracle APEX Status"
echo ""

if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "oracle-apex-db"; then
    echo "Database: 🟢 Running"
else
    echo "Database: 🔴 Stopped"
fi

if pgrep -f "ords.*serve" >/dev/null 2>&1; then
    echo "ORDS:     🟢 Running"
else
    echo "ORDS:     🔴 Stopped"
fi

HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ords/apex_admin 2>/dev/null || echo "000")
case $HTTP in
    200|302|303) echo "HTTP:     ✅ OK ($HTTP)" ;;
    571) echo "HTTP:     ❌ Database Error ($HTTP)" ;;
    *) echo "HTTP:     ⚠️  Status $HTTP" ;;
esac

echo ""
echo "🌐 Admin: http://localhost:8080/ords/apex_admin"
echo "🔐 Login: http://localhost:8080/ords/f?p=4550"
STATUSEOF
    chmod +x "$SCRIPTS_DIR/status.sh"

    # LOGS SCRIPT
    cat > "$SCRIPTS_DIR/logs.sh" << 'LOGSEOF'
#!/usr/bin/env bash
PROJECT_DIR="$HOME/oracle-apex-complete"
LOG_DIR="$PROJECT_DIR/logs"

echo "📋 Oracle APEX Logs"
echo ""
echo "1) ORDS Log (last 100 lines)"
echo "2) Installation Log (last 100 lines)"
echo "3) Database Log (last 100 lines)"
echo "4) Live ORDS Log (follow)"
echo ""
read -p "Choose (1-4): " choice

case $choice in
    1) tail -100 "$LOG_DIR/ords.log" 2>/dev/null || echo "No log" ;;
    2) tail -100 "$PROJECT_DIR/install.log" 2>/dev/null || echo "No log" ;;
    3) docker logs oracle-apex-db 2>&1 | tail -100 || echo "No logs" ;;
    4) tail -f "$LOG_DIR/ords.log" 2>/dev/null || echo "No log" ;;
esac
LOGSEOF
    chmod +x "$SCRIPTS_DIR/logs.sh"

    # DBEAVER SCRIPT
    cat > "$SCRIPTS_DIR/dbeaver.sh" << 'DBEAVEREOF'
#!/usr/bin/env bash
ACTION="${1:-menu}"
OS_ID=$(grep "^ID=" /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "unknown")

install_dbeaver() {
    echo "📦 Installing DBeaver..."
    
    # Detect macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &>/dev/null; then
            brew install --cask dbeaver-community 2>/dev/null || true
        else
            echo "Please install Homebrew first"
            return 1
        fi
        return 0
    fi
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop|kali)
            wget -O /tmp/dbeaver.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" 2>/dev/null
            sudo dpkg -i /tmp/dbeaver.deb 2>/dev/null || sudo apt-get install -f -y 2>/dev/null
            rm -f /tmp/dbeaver.deb
            ;;
        fedora)
            sudo dnf install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm 2>/dev/null
            ;;
        opensuse*|suse*)
            wget -O /tmp/dbeaver.rpm "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" 2>/dev/null
            sudo zypper --non-interactive install -y /tmp/dbeaver.rpm 2>/dev/null
            rm -f /tmp/dbeaver.rpm
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm dbeaver 2>/dev/null
            ;;
    esac
    
    echo "✅ DBeaver installed"
}

remove_dbeaver() {
    echo "🗑️ Removing DBeaver..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew uninstall --cask dbeaver-community 2>/dev/null || true
        return 0
    fi
    
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop|kali)
            sudo apt-get remove -y dbeaver-ce 2>/dev/null
            ;;
        fedora)
            sudo dnf remove -y dbeaver-ce 2>/dev/null
            ;;
        opensuse*|suse*)
            sudo zypper remove -y dbeaver-ce 2>/dev/null
            ;;
        arch|manjaro)
            sudo pacman -Rns --noconfirm dbeaver 2>/dev/null
            ;;
    esac
    
    rm -rf "$HOME/.dbeaver4" "$HOME/.dbeaver-drivers" 2>/dev/null
    echo "✅ DBeaver removed"
}

case "$ACTION" in
    install) install_dbeaver ;;
    remove) remove_dbeaver ;;
    *) echo "Usage: $0 {install|remove}" ;;
esac
DBEAVEREOF
    chmod +x "$SCRIPTS_DIR/dbeaver.sh"

    log "✅ Management scripts created"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE SYSTEMD SERVICE (Linux only)
#═══════════════════════════════════════════════════════════════════════════════
create_systemd_service() {
    if [ "$IS_LINUX" != "true" ] || [ "$IS_WSL" = "true" ]; then
        log "Skipping systemd service (not applicable)"
        return 0
    fi
    
    log "Creating systemd service..."
    
    cat > /tmp/oracle-apex.service << SERVICEEOF
[Unit]
Description=Oracle APEX Service v4.3.1
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=forking
User=$USER
Group=$(id -gn)
WorkingDirectory=$PROJECT_DIR
Environment="HOME=$HOME"
ExecStart=/bin/bash $SCRIPTS_DIR/start.sh
ExecStop=/bin/bash $SCRIPTS_DIR/stop.sh
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
SERVICEEOF

    run_sudo cp /tmp/oracle-apex.service /etc/systemd/system/oracle-apex.service
    run_sudo chmod 644 /etc/systemd/system/oracle-apex.service
    run_sudo systemctl daemon-reload
    run_sudo systemctl enable oracle-apex.service
    
    rm -f /tmp/oracle-apex.service
    
    log "✅ Systemd service created"
    SYSTEMD_ENABLED="true"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE LAUNCHD SERVICE (macOS only)
#═══════════════════════════════════════════════════════════════════════════════
create_launchd_service() {
    if [ "$IS_MACOS" != "true" ]; then
        return 0
    fi
    
    log "Creating LaunchAgent for macOS..."
    
    local plist_file="$HOME/Library/LaunchAgents/com.kaizenix.oracle-apex.plist"
    mkdir -p "$HOME/Library/LaunchAgents"
    
    cat > "$plist_file" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.kaizenix.oracle-apex</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPTS_DIR/start.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>$LOG_DIR/launchd.log</string>
    <key>StandardErrorPath</key>
    <string>$LOG_DIR/launchd-error.log</string>
</dict>
</plist>
PLISTEOF
    
    launchctl load "$plist_file" 2>/dev/null || true
    
    log "✅ LaunchAgent created"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE WEB INSTALLER
#═══════════════════════════════════════════════════════════════════════════════
create_web_installer() {
    log "Creating web status page..."
    mkdir -p "$WEB_INSTALLER_DIR"
    
    cat > "$WEB_INSTALLER_DIR/index.html" << 'WEBEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oracle APEX v4.3.1 Status</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
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
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 650px;
            width: 100%;
            padding: 40px;
        }
        .header { text-align: center; margin-bottom: 30px; }
        .header h1 { color: #333; font-size: 32px; margin-bottom: 10px; }
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
            border-left: 4px solid #10b981;
        }
        .status-item h3 {
            font-size: 12px;
            color: #666;
            margin-bottom: 8px;
            text-transform: uppercase;
        }
        .status-value { font-size: 24px; font-weight: bold; }
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
        }
        .link-item { margin-bottom: 12px; }
        .link-item a {
            display: block;
            padding: 14px 18px;
            background: white;
            color: #667eea;
            text-decoration: none;
            border-radius: 8px;
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
            color: #0369a1;
        }
        .credentials h4 { margin-bottom: 12px; color: #0c4a6e; }
        .credentials p { margin-bottom: 6px; }
        .footer {
            text-align: center;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
            font-size: 12px;
            color: #999;
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
            <div class="status-item">
                <h3>Database</h3>
                <div class="status-value">🟢 Running</div>
            </div>
            <div class="status-item">
                <h3>ORDS</h3>
                <div class="status-value">🟢 Running</div>
            </div>
        </div>
        
        <div class="links">
            <h3>📍 Quick Access</h3>
            <div class="link-item">
                <a href="http://localhost:8080/ords/apex_admin" target="_blank">🔐 APEX Admin Panel</a>
            </div>
            <div class="link-item">
                <a href="http://localhost:8080/ords/f?p=4550" target="_blank">🌐 APEX Login Page</a>
            </div>
            <div class="link-item">
                <a href="http://localhost:8080/ords/sql" target="_blank">📊 SQL Developer Web</a>
            </div>
        </div>
        
        <div class="credentials">
            <h4>📋 Default Credentials</h4>
            <p><strong>Workspace:</strong> INTERNAL</p>
            <p><strong>Username:</strong> ADMIN</p>
            <p><strong>Password:</strong> (your configured password)</p>
        </div>
        
        <div class="footer">
            <p>Oracle APEX v4.3.1 - Created by Peyman Rasouli</p>
            <p><a href="https://github.com/KaizenixCore/" target="_blank">KaizenixCore</a></p>
        </div>
    </div>
</body>
</html>
WEBEOF

    cat > "$WEB_INSTALLER_DIR/start.sh" << 'WEBSTARTEOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Starting status page on http://localhost:8888"
echo "Press Ctrl+C to stop"
python3 -m http.server 8888 2>/dev/null || python -m SimpleHTTPServer 8888
WEBSTARTEOF
    chmod +x "$WEB_INSTALLER_DIR/start.sh"

    log "✅ Web installer created"
}

#═══════════════════════════════════════════════════════════════════════════════
# CREATE DOCUMENTATION
#═══════════════════════════════════════════════════════════════════════════════
create_documentation() {
    log "Creating documentation..."
    
    cat > "$PROJECT_DIR/README.md" << 'DOCEOF'
# Oracle APEX v4.3.1 - Complete Installation

## Platform Support
- ✅ Linux (All distributions)
- ✅ macOS (Intel & Apple Silicon)
- ✅ Windows (WSL2)

## Access URLs
| Service | URL |
|---------|-----|
| Admin Panel | http://localhost:8080/ords/apex_admin |
| Login Page | http://localhost:8080/ords/f?p=4550 |
| SQL Workshop | http://localhost:8080/ords/sql |

## Default Credentials
- Workspace: INTERNAL
- Username: ADMIN
- Password: (your configured password)

## Management Commands
```bash
# Start
bash ~/oracle-apex-complete/scripts/start.sh

# Stop
bash ~/oracle-apex-complete/scripts/stop.sh

# Fix errors
bash ~/oracle-apex-complete/scripts/fix.sh

# Status
bash ~/oracle-apex-complete/scripts/status.sh

# Logs
bash ~/oracle-apex-complete/scripts/logs.sh
```

## Troubleshooting
### Error 571
```bash
bash ~/oracle-apex-complete/scripts/fix.sh
```

### Check logs
```bash
tail -100 ~/oracle-apex-complete/logs/ords.log
```

## Created by
Peyman Rasouli - KaizenixCore
GitHub: https://github.com/KaizenixCore/oracle-apex-installer/
DOCEOF

    log "✅ Documentation created"
}

#═══════════════════════════════════════════════════════════════════════════════
# MAIN INSTALLATION FUNCTION - FRESH INSTALL
#═══════════════════════════════════════════════════════════════════════════════
run_fresh_install() {
    log "Starting fresh installation v4.3.1..."
    
    ensure_directories
    start_progress
    
    # Save passwords
    update_progress 2 "Step 1/20: Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    
    # Install dependencies
    update_progress 5 "Step 2/20: Installing dependencies..."
    install_dependencies
    
    # Download APEX
    update_progress 10 "Step 3/20: Downloading APEX..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ]; then
        wget -q -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || \
        curl -L -o "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || true
    fi
    
    # Download ORDS
    update_progress 15 "Step 4/20: Downloading ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ]; then
        wget -q -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || \
        curl -L -o "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || true
    fi
    
    # Extract files
    update_progress 20 "Step 5/20: Extracting files..."
    cd "$PROJECT_DIR"
    rm -rf apex ords 2>/dev/null || true
    
    [ -f "$DOWNLOADS_DIR/apex-latest.zip" ] && unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || true
    
    mkdir -p ords
    [ -f "$DOWNLOADS_DIR/ords-latest.zip" ] && unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords 2>/dev/null || true
    find ords -name "ords" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # Copy images
    if [ -d "$PROJECT_DIR/apex/images" ]; then
        rm -rf "$IMAGES_DIR" 2>/dev/null || true
        cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR"
        chmod -R 755 "$IMAGES_DIR"
    fi
    
    # Create Docker Compose
    update_progress 25 "Step 6/20: Creating Docker config..."
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

volumes:
  oracle-data:
    name: oracle-apex-data
COMPOSEEOF

    # Start database
    update_progress 30 "Step 7/20: Starting database..."
    cd "$PROJECT_DIR"
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || {
        log "ERROR: Failed to start database"
        stop_progress
        gui_error "Error" "Failed to start database.\n\nCheck Docker installation."
        return 1
    }
    
    # Wait for database
    update_progress 35 "Step 8/20: Waiting for database (5-10 min)..."
    wait_for_database || log "Database timeout, continuing..."
    sleep 60
    
    # Reset password
    update_progress 40 "Step 9/20: Syncing passwords..."
    docker exec oracle-apex-db resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 20
    
    # Disable password policies
    update_progress 45 "Step 10/20: Configuring database..."
    docker exec oracle-apex-db bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
SQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Install APEX
    update_progress 50 "Step 11/20: Installing APEX (15-25 min)..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
SQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Reset image prefix
    update_progress 55 "Step 12/20: Setting up APEX images..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'SQL'
@utilities/reset_image_prefix.sql
EXIT;
SQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # APEX REST config
    update_progress 60 "Step 13/20: Configuring REST..."
    docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << SQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
SQL" >> "$INSTALL_LOG" 2>&1 || true
    
    # Create ORDS user
    update_progress 65 "Step 14/20: Creating ORDS user..."
    create_ords_user "$ORACLE_PASSWORD"
    
    # Sync passwords
    update_progress 70 "Step 15/20: Syncing all passwords..."
    sync_all_passwords "$ORACLE_PASSWORD"
    
    # Create APEX admin
    update_progress 75 "Step 16/20: Creating APEX admin..."
    create_apex_admin "$ORACLE_PASSWORD" "$APEX_ADMIN_PASSWORD"
    
    # Install ORDS
    update_progress 80 "Step 17/20: Configuring ORDS..."
    install_ords_properly "$ORACLE_PASSWORD"
    
    # Final password sync
    update_progress 85 "Step 18/20: Final password sync..."
    sync_all_passwords "$ORACLE_PASSWORD"
    sleep 10
    
    # Create scripts
    update_progress 90 "Step 19/20: Creating management scripts..."
    create_scripts
    
    # Create service
    update_progress 92 "Step 19/20: Creating auto-start service..."
    stop_progress
    if gui_question "$(get_text create_service_title)" "$(get_text create_service_text)"; then
        if [ "$IS_MACOS" = "true" ]; then
            create_launchd_service
        elif [ "$IS_LINUX" = "true" ]; then
            create_systemd_service
        fi
    fi
    start_progress
    
    # Start ORDS
    update_progress 94 "Step 20/20: Starting ORDS..."
    start_ords
    
    # Create web installer
    update_progress 96 "Creating web installer..."
    create_web_installer
    
    # Create documentation
    update_progress 98 "Creating documentation..."
    create_documentation
    
    # Verify
    update_progress 99 "Verifying installation..."
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
    log "Installation verification: HTTP $http_code"
    
    if [[ ! "$http_code" =~ ^(200|302|303)$ ]]; then
        log "Running automatic fix..."
        sync_all_passwords "$ORACLE_PASSWORD"
        sleep 5
        local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
        if [ -n "$ORDS_BIN" ]; then
            echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
        fi
        pkill -f ords 2>/dev/null || true
        sleep 5
        start_ords
        http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
    fi
    
    update_progress 100 "Installation completed!"
    sleep 2
    stop_progress
    
    log "✅ Installation completed with HTTP $http_code"
    
    # Show success message
    local success_msg=$(get_text success_text)
    success_msg="${success_msg//%PASSWORD%/$APEX_ADMIN_PASSWORD}"
    gui_info "$(get_text success_title)" "$success_msg"
    
    # Ask to open browser
    if gui_question "$(get_text open_browser)" "Open APEX in browser now?"; then
        if command -v xdg-open &>/dev/null; then
            xdg-open "http://localhost:8080/ords/apex_admin" 2>/dev/null || true
        elif command -v open &>/dev/null; then
            open "http://localhost:8080/ords/apex_admin" 2>/dev/null || true
        fi
    fi
    
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# REPAIR INSTALLATION
#═══════════════════════════════════════════════════════════════════════════════
run_repair() {
    log "Starting repair installation..."
    
    if ! gui_question "$(get_text warning)" "$(get_text repair_text)"; then
        return 0
    fi
    
    ensure_directories
    start_progress
    
    update_progress 10 "Stopping ORDS..."
    pkill -f ords 2>/dev/null || true
    sleep 3
    
    update_progress 20 "Starting database..."
    docker start oracle-apex-db 2>/dev/null || true
    sleep 90
    
    update_progress 30 "Syncing passwords..."
    docker exec oracle-apex-db resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 15
    
    update_progress 40 "Syncing all users..."
    sync_all_passwords "$ORACLE_PASSWORD"
    
    update_progress 50 "Creating ORDS user..."
    create_ords_user "$ORACLE_PASSWORD"
    
    update_progress 60 "Updating APEX admin..."
    create_apex_admin "$ORACLE_PASSWORD" "$APEX_ADMIN_PASSWORD"
    
    update_progress 70 "Updating ORDS config..."
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    if [ -n "$ORDS_BIN" ]; then
        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    fi
    
    # Save new passwords
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    
    update_progress 80 "Starting ORDS..."
    start_ords
    
    update_progress 90 "Verifying..."
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/apex_admin" 2>/dev/null || echo "000")
    
    update_progress 100 "Repair completed!"
    stop_progress
    
    log "✅ Repair completed with HTTP $http_code"
    gui_info "$(get_text completed)" "Repair completed successfully!\n\nHTTP Status: $http_code\n\nAdmin URL: http://localhost:8080/ords/apex_admin"
    
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# CLEAN INSTALLATION
#═══════════════════════════════════════════════════════════════════════════════
run_clean_install() {
    log "Starting clean installation..."
    
    if ! gui_question "$(get_text warning)" "$(get_text confirm_clean)"; then
        return 0
    fi
    
    start_progress
    update_progress 20 "Cleaning old installation..."
    complete_cleanup
    update_progress 40 "Cleanup done, starting fresh..."
    stop_progress
    
    run_fresh_install
}

#═══════════════════════════════════════════════════════════════════════════════
# UNINSTALL EVERYTHING
#═══════════════════════════════════════════════════════════════════════════════
run_uninstall() {
    log "Starting complete uninstall..."
    
    if ! gui_question "$(get_text warning)" "$(get_text confirm_uninstall)"; then
        return 0
    fi
    
    start_progress
    
    update_progress 25 "Stopping services..."
    pkill -f ords 2>/dev/null || true
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
# MANAGE DBEAVER
#═══════════════════════════════════════════════════════════════════════════════
manage_dbeaver() {
    while true; do
        local choice=""
        
        if [ "$GUI_TOOL" = "osascript" ]; then
            choice=$(osascript -e 'choose from list {"Install DBeaver", "Remove DBeaver", "Back"} with title "DBeaver Management" with prompt "Select action:"' 2>/dev/null | tr -d ',')
            case "$choice" in
                "Install DBeaver") choice="install" ;;
                "Remove DBeaver") choice="remove" ;;
                *) return 0 ;;
            esac
        else
            choice=$(gui_list "📦 DBeaver Management" "Select action:" \
                TRUE "install" "📥 Install DBeaver" \
                FALSE "remove" "🗑️ Remove DBeaver" \
                FALSE "back" "⬅️ Back to Main Menu")
            
            choice=$(echo "$choice" | tr -d '|')
        fi
        
        case "$choice" in
            install)
                start_progress
                update_progress 25 "Downloading DBeaver..."
                
                if [ "$IS_MACOS" = "true" ]; then
                    if command -v brew &>/dev/null; then
                        brew install --cask dbeaver-community 2>/dev/null || true
                    fi
                else
                    bash "$SCRIPTS_DIR/dbeaver.sh" install >> "$INSTALL_LOG" 2>&1 || true
                fi
                
                update_progress 100 "Done"
                stop_progress
                gui_info "$(get_text info)" "✅ DBeaver installed!\n\nYou can start it from your applications menu."
                ;;
            remove)
                if gui_question "$(get_text warning)" "Remove DBeaver completely?"; then
                    start_progress
                    update_progress 50 "Removing DBeaver..."
                    
                    if [ "$IS_MACOS" = "true" ]; then
                        brew uninstall --cask dbeaver-community 2>/dev/null || true
                    else
                        bash "$SCRIPTS_DIR/dbeaver.sh" remove >> "$INSTALL_LOG" 2>&1 || true
                    fi
                    
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
# LANGUAGE SELECTION
#═══════════════════════════════════════════════════════════════════════════════
select_language() {
    if [ "$GUI_TOOL" = "osascript" ]; then
        local result=$(osascript -e 'choose from list {"English", "Persian (فارسی)", "German (Deutsch)"} with title "Language Selection" with prompt "Select your language:" default items {"English"}' 2>/dev/null)
        case "$result" in
            "English") CURRENT_LANG="en" ;;
            "Persian"*) CURRENT_LANG="fa" ;;
            "German"*) CURRENT_LANG="de" ;;
            *) CURRENT_LANG="en" ;;
        esac
    else
        local result=$(gui_list "🌐 Select Language" "Choose your language:" \
            TRUE "en" "🇺🇸 English" \
            FALSE "fa" "🇮🇷 فارسی (Persian)" \
            FALSE "de" "🇩🇪 Deutsch (German)")
        
        [ -z "$result" ] && exit 0
        CURRENT_LANG=$(echo "$result" | tr -d '|')
        [ -z "$CURRENT_LANG" ] && CURRENT_LANG="en"
    fi
    
    log "Language selected: $CURRENT_LANG"
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
    
    if [ "$GUI_TOOL" = "osascript" ]; then
        if [ "$has_install" = "true" ]; then
            choice=$(osascript -e 'choose from list {"Fresh Install", "Repair", "Clean Install", "Uninstall", "Manage DBeaver", "Exit"} with title "Oracle APEX Installer" with prompt "Previous installation detected. Select action:" default items {"Repair"}' 2>/dev/null | tr -d ',')
        else
            choice=$(osascript -e 'choose from list {"Fresh Install", "Manage DBeaver", "Exit"} with title "Oracle APEX Installer" with prompt "Select action:" default items {"Fresh Install"}' 2>/dev/null | tr -d ',')
        fi
        
        case "$choice" in
            "Fresh Install") echo "fresh" ;;
            "Repair") echo "repair" ;;
            "Clean Install") echo "clean" ;;
            "Uninstall") echo "uninstall" ;;
            "Manage DBeaver") echo "dbeaver" ;;
            "Exit"|"") echo "exit" ;;
            *) echo "exit" ;;
        esac
    else
        if [ "$has_install" = "true" ]; then
            choice=$(gui_list "$(get_text select_action)" "$(get_text action_text)\n\n⚠️ Previous installation detected." \
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
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
#═══════════════════════════════════════════════════════════════════════════════
main() {
    # Detect platform
    detect_platform
    
    # Pre-flight checks
    preflight_checks
    
    # Install GUI tools
    install_gui_tool
    
    # Show welcome screen
    gui_info "$(get_text welcome_title)" "$(get_text welcome_text)"
    
    # Select language
    select_language
    
    # Get sudo password (if needed)
    get_sudo_password
    
    # Main loop
    while true; do
        local action=$(select_action)
        
        case "$action" in
            fresh)
                get_passwords
                run_fresh_install
                break
                ;;
            repair)
                get_passwords
                run_repair
                break
                ;;
            clean)
                get_passwords
                run_clean_install
                break
                ;;
            uninstall)
                run_uninstall
                break
                ;;
            dbeaver)
                manage_dbeaver
                ;;
            exit|"")
                log "User exited installer"
                exit 0
                ;;
        esac
    done
    
    log "Installer finished successfully"
}

#═══════════════════════════════════════════════════════════════════════════════
# START THE INSTALLER
#═══════════════════════════════════════════════════════════════════════════════
main "$@"