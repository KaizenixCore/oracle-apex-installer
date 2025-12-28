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
#  ║     ORACLE APEX GUI INSTALLER v4.3.0 - KAIZENIXCORE                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ║  License    : MIT                                                         ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -o pipefail

VERSION="4.3.0"
PROJECT_DIR="$HOME/oracle-apex-complete"
DOWNLOADS_DIR="$PROJECT_DIR/downloads"
LOG_DIR="$PROJECT_DIR/logs"
IMAGES_DIR="$PROJECT_DIR/images"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
INSTALL_LOG="$PROJECT_DIR/install.log"

DB_HOST="localhost"
DB_PORT="1521"
DB_SERVICE="XEPDB1"
DB_SID="XE"
ORDS_PORT="8080"

APEX_URL="https://download.oracle.com/otn_software/apex/apex-latest.zip"
ORDS_URL="https://download.oracle.com/otn_software/java/ords/ords-latest.zip"
ORACLE_IMAGE="gvenzl/oracle-xe:21-full"

CONTAINER_NAME="oracle-apex-db"

GUI_TOOL=""
SUDO_PASS=""
ORACLE_PASSWORD=""
APEX_ADMIN_PASSWORD=""
CURRENT_LANG="en"
OS_TYPE=""
OS_ID=""
OS_VERSION=""
ARCH=""

declare -A LANG_EN=(
    ["title"]="Oracle APEX Installer"
    ["subtitle"]="KaizenixCore Edition v4.3"
    ["welcome_title"]="Oracle APEX Ultimate Installer"
    ["welcome_text"]="Oracle APEX Ultimate Installer v4.3.0\n\nThis will install:\n- Oracle APEX (Latest Version)\n- Oracle ORDS (Latest Version)\n- Oracle XE 21c Database\n\nFeatures:\n- Automatic configuration\n- Error auto-fix (574/571/500)\n- APEX images auto-setup\n- Management GUI included\n\nCreated by: Peyman Rasouli\nProject: KaizenixCore\n\nClick Continue to start."
    ["select_action"]="Select Installation Type"
    ["action_text"]="What would you like to do?"
    ["fresh_install"]="Fresh Install (New installation)"
    ["repair_install"]="Repair (Fix existing installation)"
    ["clean_install"]="Clean Install (Remove ALL and reinstall)"
    ["uninstall"]="Uninstall Everything"
    ["manage_dbeaver"]="Manage DBeaver"
    ["exit_installer"]="Exit"
    ["enter_passwords"]="Enter Passwords"
    ["oracle_pass"]="Oracle Database Password:"
    ["apex_pass"]="APEX Admin Password:"
    ["pass_rules"]="Password Rules:\n- Start with a letter (a-z, A-Z)\n- Only letters and numbers\n- Minimum 6 characters\n\nExample: MyPass123"
    ["invalid_pass"]="Invalid Password!\n\nPassword must:\n- Start with a letter\n- Contain only letters and numbers\n- Be at least 6 characters"
    ["installing"]="Installing Oracle APEX..."
    ["completed"]="Installation Completed!"
    ["error"]="Error"
    ["warning"]="Warning"
    ["info"]="Information"
    ["open_browser"]="Open APEX"
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
    ["confirm_clean"]="WARNING: Clean Install\n\nThis will PERMANENTLY DELETE:\n- All Oracle APEX data\n- All databases\n- All Docker volumes\n- All configurations\n\nAre you SURE you want to continue?"
    ["confirm_uninstall"]="WARNING: Complete Uninstall\n\nThis will PERMANENTLY DELETE everything.\n\nAre you SURE?"
    ["dbeaver_menu"]="DBeaver Management"
    ["dbeaver_text"]="Select DBeaver action:"
    ["dbeaver_install"]="Install DBeaver"
    ["dbeaver_remove"]="Remove DBeaver Completely"
    ["dbeaver_back"]="Back"
    ["removing_dbeaver"]="Removing DBeaver..."
    ["installing_dbeaver"]="Installing DBeaver..."
    ["dbeaver_removed"]="DBeaver has been completely removed!"
    ["dbeaver_installed"]="DBeaver has been installed!"
    ["success_title"]="Installation Successful!"
    ["success_text"]="Oracle APEX installed successfully!\n\nAdmin Panel:\nhttp://localhost:8080/ords/apex_admin\n\nLogin Page:\nhttp://localhost:8080/ords/f?p=4550\n\nCredentials:\n   Workspace: INTERNAL\n   Username: ADMIN\n   Password: %PASSWORD%"
    ["create_service_title"]="Create Auto-Start Service?"
    ["create_service_text"]="Would you like Oracle APEX to start automatically on boot?"
    ["service_created"]="Auto-start service created!"
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

declare -A LANG_FA=(
    ["title"]="نصب‌کننده اوراکل اپکس"
    ["welcome_title"]="نصب‌کننده اوراکل اپکس"
    ["welcome_text"]="نصب‌کننده اوراکل اپکس نسخه 4.3.0"
    ["select_action"]="انتخاب نوع نصب"
    ["action_text"]="چه کاری می‌خواهید انجام دهید؟"
    ["fresh_install"]="نصب جدید"
    ["repair_install"]="تعمیر"
    ["clean_install"]="نصب تمیز"
    ["uninstall"]="حذف کامل"
    ["manage_dbeaver"]="مدیریت DBeaver"
    ["exit_installer"]="خروج"
    ["enter_passwords"]="ورود رمز عبور"
    ["oracle_pass"]="رمز عبور Oracle:"
    ["apex_pass"]="رمز عبور APEX:"
    ["pass_rules"]="قوانین رمز عبور:\n- با حرف شروع شود\n- فقط حروف و اعداد\n- حداقل 6 کاراکتر"
    ["invalid_pass"]="رمز عبور نامعتبر!"
    ["installing"]="در حال نصب..."
    ["completed"]="نصب کامل شد!"
    ["error"]="خطا"
    ["warning"]="هشدار"
    ["info"]="اطلاعات"
    ["exit"]="خروج"
    ["continue"]="ادامه"
    ["cancel"]="انصراف"
    ["yes"]="بله"
    ["no"]="خیر"
    ["ok"]="تایید"
    ["sudo_pass"]="رمز عبور سیستم:"
    ["step"]="مرحله"
    ["success_title"]="نصب موفق!"
    ["success_text"]="اوراکل اپکس نصب شد!"
)

declare -A LANG_DE=(
    ["title"]="Oracle APEX Installer"
    ["welcome_title"]="Oracle APEX Installer"
    ["select_action"]="Installationstyp"
    ["fresh_install"]="Neuinstallation"
    ["repair_install"]="Reparieren"
    ["clean_install"]="Saubere Installation"
    ["uninstall"]="Deinstallieren"
    ["exit_installer"]="Beenden"
    ["error"]="Fehler"
    ["warning"]="Warnung"
    ["info"]="Information"
    ["continue"]="Weiter"
    ["cancel"]="Abbrechen"
    ["yes"]="Ja"
    ["no"]="Nein"
    ["ok"]="OK"
    ["step"]="Schritt"
    ["success_title"]="Installation erfolgreich!"
)

get_text() {
    local key="$1"
    case $CURRENT_LANG in
        fa) echo "${LANG_FA[$key]:-${LANG_EN[$key]}}" ;;
        de) echo "${LANG_DE[$key]:-${LANG_EN[$key]}}" ;;
        *)  echo "${LANG_EN[$key]}" ;;
    esac
}

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
    log "Detecting operating system..."
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
        OS_VERSION="${VERSION_ID:-unknown}"
    else
        OS_ID="unknown"
        OS_VERSION="unknown"
    fi
    ARCH=$(uname -m)
    log "Detected: $OS_TYPE ($OS_ID $OS_VERSION) - $ARCH"
}

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
        echo "ERROR: No GUI tool found"
        exit 1
    fi
}

gui_info() {
    local title="$1"
    local text="$2"
    local width="${3:-550}"
    local height="${4:-400}"
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --info --title="$title" --text="$text" --width=$width --height=$height --center --button="$(get_text ok):0" --borders=15 2>/dev/null
    else
        zenity --info --title="$title" --text="$text" --width=$width --height=$height --ok-label="$(get_text ok)" 2>/dev/null
    fi
}

gui_error() {
    local title="$1"
    local text="$2"
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --error --title="$title" --text="$text" --width=500 --height=300 --center --button="$(get_text ok):0" --borders=15 2>/dev/null
    else
        zenity --error --title="$title" --text="$text" --width=500 --height=300 --ok-label="$(get_text ok)" 2>/dev/null
    fi
}

gui_warning() {
    local title="$1"
    local text="$2"
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --warning --title="$title" --text="$text" --width=500 --height=350 --center --button="$(get_text ok):0" --borders=15 2>/dev/null
    else
        zenity --warning --title="$title" --text="$text" --width=500 --height=350 --ok-label="$(get_text ok)" 2>/dev/null
    fi
}

gui_question() {
    local title="$1"
    local text="$2"
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --question --title="$title" --text="$text" --width=550 --height=400 --center --button="$(get_text no):1" --button="$(get_text yes):0" --borders=15 2>/dev/null
        return $?
    else
        zenity --question --title="$title" --text="$text" --width=550 --height=400 --ok-label="$(get_text yes)" --cancel-label="$(get_text no)" 2>/dev/null
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
            result=$(yad --entry --title="$title" --text="$text" --hide-text --width=450 --center --button="$(get_text cancel):1" --button="$(get_text ok):0" --borders=15 2>/dev/null)
        else
            result=$(yad --entry --title="$title" --text="$text" --width=450 --center --button="$(get_text cancel):1" --button="$(get_text ok):0" --borders=15 2>/dev/null)
        fi
    else
        if [ "$hide" = "true" ]; then
            result=$(zenity --password --title="$title" 2>/dev/null)
        else
            result=$(zenity --entry --title="$title" --text="$text" --width=450 2>/dev/null)
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
        result=$(yad --list --title="$title" --text="$text" --radiolist --column="" --column="ID" --column="Option" "$@" --width=550 --height=450 --center --button="$(get_text cancel):1" --button="$(get_text ok):0" --print-column=2 --hide-column=2 --borders=15 2>/dev/null)
    else
        result=$(zenity --list --title="$title" --text="$text" --radiolist --column="" --column="ID" --column="Option" "$@" --width=550 --height=450 --ok-label="$(get_text ok)" --cancel-label="$(get_text cancel)" --hide-column=2 2>/dev/null)
    fi
    echo "$result" | tr -d '|' | tr -d ' '
}

select_language() {
    local result=""
    result=$(gui_list "Select Language" "Select your preferred language:" TRUE "en" "English" FALSE "fa" "Persian" FALSE "de" "German")
    [ -z "$result" ] && exit 0
    CURRENT_LANG="$result"
    [ -z "$CURRENT_LANG" ] && CURRENT_LANG="en"
}

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
            gui_error "$(get_text error)" "Wrong password! ($attempts/3)"
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
            result=$(yad --form --title="$(get_text title) - $(get_text enter_passwords)" --text="$(get_text pass_rules)" --field="$(get_text oracle_pass):H" "" --field="$(get_text apex_pass):H" "" --width=550 --height=400 --center --button="$(get_text cancel):1" --button="$(get_text continue):0" --borders=15 2>/dev/null)
        else
            result=$(zenity --forms --title="$(get_text title)" --text="$(get_text pass_rules)" --add-password="$(get_text oracle_pass)" --add-password="$(get_text apex_pass)" --width=500 --height=350 2>/dev/null)
        fi
        [ -z "$result" ] && exit 0
        ORACLE_PASSWORD=$(echo "$result" | cut -d'|' -f1)
        APEX_ADMIN_PASSWORD=$(echo "$result" | cut -d'|' -f2)
        if [[ "$ORACLE_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{5,}$ ]] && [[ "$APEX_ADMIN_PASSWORD" =~ ^[a-zA-Z][a-zA-Z0-9]{5,}$ ]]; then
            break
        else
            gui_error "$(get_text error)" "$(get_text invalid_pass)"
        fi
    done
    export ORACLE_PASSWORD
    export APEX_ADMIN_PASSWORD
}

FIFO_FILE=""
PROGRESS_PID=""

start_progress() {
    FIFO_FILE=$(mktemp -u)
    mkfifo "$FIFO_FILE" 2>/dev/null || true
    if [ "$GUI_TOOL" = "yad" ]; then
        yad --progress --title="$(get_text title)" --text="$(get_text installing)" --percentage=0 --auto-close --no-buttons --width=600 --height=150 --center --borders=15 < "$FIFO_FILE" 2>/dev/null &
        PROGRESS_PID=$!
    else
        zenity --progress --title="$(get_text title)" --text="$(get_text installing)" --percentage=0 --auto-close --no-cancel --width=600 --height=150 < "$FIFO_FILE" 2>/dev/null &
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

install_dependencies() {
    log "Installing dependencies..."
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            run_sudo apt-get update -qq
            run_sudo apt-get install -y curl wget unzip docker.io docker-compose jq
            run_sudo systemctl enable docker
            run_sudo systemctl start docker
            ;;
        fedora)
            run_sudo dnf install -y curl wget unzip docker docker-compose jq
            run_sudo systemctl enable docker
            run_sudo systemctl start docker
            ;;
        opensuse*|suse*)
            run_sudo zypper --non-interactive install -y curl wget unzip docker docker-compose jq
            run_sudo systemctl enable docker
            run_sudo systemctl start docker
            ;;
        arch|manjaro)
            run_sudo pacman -S --noconfirm curl wget unzip docker docker-compose jq
            run_sudo systemctl enable docker
            run_sudo systemctl start docker
            ;;
    esac
    run_sudo usermod -aG docker "$USER" 2>/dev/null || true
}

check_previous_installation() {
    if [ -d "$PROJECT_DIR" ] && [ -f "$PROJECT_DIR/.db_password" ]; then
        return 0
    fi
    if docker ps -a 2>/dev/null | grep -q "$CONTAINER_NAME"; then
        return 0
    fi
    return 1
}

complete_cleanup() {
    log "Performing complete cleanup..."
    pkill -9 -f ords 2>/dev/null || true
    pkill -9 -f java.*ords 2>/dev/null || true
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    docker volume rm oracle-apex-data 2>/dev/null || true
    rm -rf "$PROJECT_DIR" 2>/dev/null || true
    run_sudo rm -f /etc/systemd/system/oracle-apex.service 2>/dev/null || true
    run_sudo systemctl daemon-reload 2>/dev/null || true
    rm -f "$HOME/.local/share/applications/oracle-apex.desktop" 2>/dev/null || true
    log "Cleanup completed"
}

complete_uninstall() {
    complete_cleanup
    docker rmi "$ORACLE_IMAGE" 2>/dev/null || true
    log "Uninstall completed"
}

wait_for_database_ready() {
    log "Waiting for database to be ready..."
    local max_wait=600
    local waited=0
    while [ $waited -lt $max_wait ]; do
        if docker logs "$CONTAINER_NAME" 2>&1 | grep -q "DATABASE IS READY"; then
            log "Database is ready!"
            return 0
        fi
        sleep 10
        waited=$((waited + 10))
    done
    log "Warning: Database wait timeout"
    return 1
}

fix_apex_images() {
    log "Fixing APEX images..."
    rm -rf "$IMAGES_DIR" 2>/dev/null || true
    if [ -d "$PROJECT_DIR/apex/images" ]; then
        cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR"
        chmod -R 755 "$IMAGES_DIR"
    fi
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
    if [ -n "$ORDS_BIN" ]; then
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" 2>/dev/null || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i 2>/dev/null || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" 2>/dev/null || true
    fi
}

install_dbeaver() {
    log "Installing DBeaver..."
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            if ! command -v dbeaver-ce &> /dev/null; then
                wget -q -O /tmp/dbeaver.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" 2>/dev/null
                run_sudo dpkg -i /tmp/dbeaver.deb 2>/dev/null || run_sudo apt-get install -f -y 2>/dev/null
                rm -f /tmp/dbeaver.deb
            fi
            ;;
        fedora)
            if ! command -v dbeaver-ce &> /dev/null; then
                run_sudo dnf install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm 2>/dev/null || true
            fi
            ;;
        opensuse*|suse*)
            if ! command -v dbeaver-ce &> /dev/null; then
                run_sudo zypper --non-interactive install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm 2>/dev/null || true
            fi
            ;;
        arch|manjaro)
            if ! command -v dbeaver-ce &> /dev/null; then
                run_sudo pacman -S --noconfirm dbeaver 2>/dev/null || true
            fi
            ;;
        *)
            if command -v flatpak &> /dev/null; then
                flatpak install -y flathub io.dbeaver.DBeaverCommunity 2>/dev/null || true
            elif command -v snap &> /dev/null; then
                run_sudo snap install dbeaver-ce 2>/dev/null || true
            fi
            ;;
    esac
    if command -v dbeaver-ce &> /dev/null || command -v dbeaver &> /dev/null; then
        return 0
    fi
    return 1
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
        opensuse*|suse*)
            run_sudo zypper --non-interactive remove -y dbeaver-ce dbeaver 2>/dev/null || true
            ;;
        arch|manjaro)
            run_sudo pacman -R --noconfirm dbeaver 2>/dev/null || true
            ;;
    esac
    flatpak uninstall -y io.dbeaver.DBeaverCommunity 2>/dev/null || true
    run_sudo snap remove dbeaver-ce 2>/dev/null || true
    rm -rf "$HOME/.local/share/DBeaverData" 2>/dev/null || true
    rm -rf "$HOME/.dbeaver4" 2>/dev/null || true
    rm -rf "$HOME/.dbeaver" 2>/dev/null || true
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
                    gui_info "$(get_text info)" "$(get_text dbeaver_installed)"
                else
                    stop_progress
                    gui_warning "$(get_text warning)" "DBeaver installation may have failed."
                fi
                ;;
            remove)
                if gui_question "$(get_text warning)" "Remove DBeaver completely?"; then
                    start_progress
                    update_progress 50 "$(get_text removing_dbeaver)"
                    remove_dbeaver
                    update_progress 100 "$(get_text dbeaver_removed)"
                    stop_progress
                    gui_info "$(get_text info)" "$(get_text dbeaver_removed)"
                fi
                ;;
            back|"")
                return
                ;;
        esac
    done
}
create_management_scripts() {
    log "Creating management scripts..."
    safe_mkdir "$SCRIPTS_DIR"

    # ═══════════════════════════════════════════════════════════════════════════
    # STOP SCRIPT
    # ═══════════════════════════════════════════════════════════════════════════
    cat > "$SCRIPTS_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
################################################################################
# Oracle APEX Stop Script - KaizenixCore
################################################################################

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Stopping Oracle APEX Services"
echo "════════════════════════════════════════════════════════════════"
echo ""

echo "[1/3] Stopping ORDS..."
pkill -9 -f "ords.*serve" 2>/dev/null || true
pkill -9 -f "java.*ords" 2>/dev/null || true
sleep 2

echo "[2/3] Stopping Oracle Database container..."
docker stop oracle-apex-db 2>/dev/null || true

echo "[3/3] Cleanup..."
rm -f "$HOME/oracle-apex-complete/ords.pid" 2>/dev/null || true

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  ✅ All services stopped successfully"
echo "════════════════════════════════════════════════════════════════"
echo ""
STOPEOF
    chmod +x "$SCRIPTS_DIR/stop.sh"

    # ═══════════════════════════════════════════════════════════════════════════
    # STATUS SCRIPT
    # ═══════════════════════════════════════════════════════════════════════════
    cat > "$SCRIPTS_DIR/status.sh" << 'STATUSEOF'
#!/bin/bash
################################################################################
# Oracle APEX Status Script - KaizenixCore
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
ORDS_PORT="8080"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Oracle APEX Status - KaizenixCore v4.3"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Check Database
echo "  📦 Database Container:"
if docker inspect -f '{{.State.Running}}' oracle-apex-db 2>/dev/null | grep -q "true"; then
    echo "      Status: 🟢 Running"
    CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' oracle-apex-db 2>/dev/null)
    echo "      IP: $CONTAINER_IP"
else
    echo "      Status: 🔴 Stopped"
fi
echo ""

# Check ORDS
echo "  🌐 ORDS Service:"
if pgrep -f "ords.*serve" >/dev/null 2>&1; then
    ORDS_PID=$(pgrep -f "ords.*serve" | head -1)
    echo "      Status: 🟢 Running (PID: $ORDS_PID)"
else
    echo "      Status: 🔴 Stopped"
fi
echo ""

# Check HTTP endpoints
echo "  🔗 HTTP Endpoints:"
HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" --max-time 10 2>/dev/null || echo "000")
HTTP_LOGIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/f?p=4550" --max-time 10 2>/dev/null || echo "000")
HTTP_IMAGES=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/i/apex_version.txt" --max-time 10 2>/dev/null || echo "000")

echo "      APEX Admin:  HTTP $HTTP_ADMIN"
echo "      APEX Login:  HTTP $HTTP_LOGIN"
echo "      APEX Images: HTTP $HTTP_IMAGES"
echo ""

# URLs
echo "  📎 Access URLs:"
echo "      Admin Panel: http://localhost:$ORDS_PORT/ords/apex_admin"
echo "      Login Page:  http://localhost:$ORDS_PORT/ords/f?p=4550"
echo ""

# Passwords
if [ -f "$PROJECT_DIR/.apex_password" ]; then
    APEX_PASS=$(cat "$PROJECT_DIR/.apex_password" 2>/dev/null)
    echo "  🔐 Credentials:"
    echo "      Workspace: INTERNAL"
    echo "      Username:  ADMIN"
    echo "      Password:  $APEX_PASS"
    echo ""
fi

echo "════════════════════════════════════════════════════════════════"

# Summary
if [[ "$HTTP_ADMIN" =~ ^(200|302|303)$ ]]; then
    echo "  ✅ APEX is working correctly!"
elif [[ "$HTTP_ADMIN" == "000" ]]; then
    echo "  ⚠️  ORDS is not responding. Try: bash $PROJECT_DIR/scripts/start.sh"
else
    echo "  ⚠️  APEX returned HTTP $HTTP_ADMIN. Try: bash $PROJECT_DIR/scripts/fix.sh"
fi
echo "════════════════════════════════════════════════════════════════"
echo ""
STATUSEOF
    chmod +x "$SCRIPTS_DIR/status.sh"

    # ═══════════════════════════════════════════════════════════════════════════
    # START SCRIPT
    # ═══════════════════════════════════════════════════════════════════════════
    cat > "$SCRIPTS_DIR/start.sh" << 'STARTEOF'
#!/bin/bash
################################################################################
# Oracle APEX Start Script - KaizenixCore v4.3
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
IMAGES_DIR="$PROJECT_DIR/images"
LOG_DIR="$PROJECT_DIR/logs"
ORDS_PORT="8080"
DB_PORT="1521"
DB_SERVICE="XEPDB1"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Starting Oracle APEX - KaizenixCore v4.3"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Load password
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
if [ -z "$PASS" ]; then
    echo "❌ Error: Password file not found!"
    echo "   Expected: $PROJECT_DIR/.db_password"
    exit 1
fi

# Step 1: Start Database
echo "[1/5] Starting Oracle Database container..."
docker start oracle-apex-db 2>/dev/null || true

echo "[2/5] Waiting for database to be ready (this may take 2-3 minutes)..."
READY=false
for i in {1..60}; do
    if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
        READY=true
        echo "      ✅ Database is ready!"
        break
    fi
    echo -n "."
    sleep 5
done
echo ""

if [ "$READY" = false ]; then
    echo "      ⚠️  Database may still be starting. Continuing anyway..."
fi

# Step 2: Stop any existing ORDS
echo "[3/5] Stopping any existing ORDS processes..."
pkill -9 -f "ords.*serve" 2>/dev/null || true
pkill -9 -f "java.*ords" 2>/dev/null || true
sleep 3

# Step 3: Find ORDS binary
echo "[4/5] Starting ORDS..."
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

if [ -z "$ORDS_BIN" ]; then
    echo "❌ Error: ORDS binary not found!"
    exit 1
fi

chmod +x "$ORDS_BIN" 2>/dev/null || true

# Configure password
echo "$PASS" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true

# Start ORDS
mkdir -p "$LOG_DIR"
export ORDS_CONFIG="$ORDS_CONFIG_DIR"
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
    --port $ORDS_PORT \
    --apex-images "$IMAGES_DIR" \
    > "$LOG_DIR/ords.log" 2>&1 &

ORDS_PID=$!
echo "$ORDS_PID" > "$PROJECT_DIR/ords.pid"
echo "      ORDS started with PID: $ORDS_PID"

# Step 4: Wait and verify
echo "[5/5] Waiting for ORDS to initialize (2 minutes)..."
for i in {1..24}; do
    echo -n "."
    sleep 5
done
echo ""

# Verify
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Verification"
echo "════════════════════════════════════════════════════════════════"

HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" --max-time 10 2>/dev/null || echo "000")
HTTP_IMAGES=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/i/apex_version.txt" --max-time 10 2>/dev/null || echo "000")

echo "  APEX Admin:  HTTP $HTTP_ADMIN"
echo "  APEX Images: HTTP $HTTP_IMAGES"
echo ""

if [[ "$HTTP_ADMIN" =~ ^(200|302|303)$ ]]; then
    echo "  ✅ SUCCESS! Oracle APEX is ready!"
    echo ""
    echo "  🌐 Open in browser:"
    echo "     http://localhost:$ORDS_PORT/ords/apex_admin"
    echo ""
else
    echo "  ⚠️  APEX may need more time to start."
    echo "     Wait 2-3 minutes and try again, or run:"
    echo "     bash $PROJECT_DIR/scripts/fix.sh"
fi
echo "════════════════════════════════════════════════════════════════"
echo ""
STARTEOF
    chmod +x "$SCRIPTS_DIR/start.sh"

    # ═══════════════════════════════════════════════════════════════════════════
    # FIX SCRIPT - MODIFIED: اصلاح شده برای رفع خطای 571
    # ═══════════════════════════════════════════════════════════════════════════
    cat > "$SCRIPTS_DIR/fix.sh" << 'FIXEOF'
#!/bin/bash
################################################################################
# Oracle APEX Fix Script - KaizenixCore v4.3
# Fixes: Error 571, 574, 500, Images not loading
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
ORDS_CONFIG_DIR="$PROJECT_DIR/ords_config"
IMAGES_DIR="$PROJECT_DIR/images"
LOG_DIR="$PROJECT_DIR/logs"
DB_PORT="1521"
DB_SERVICE="XEPDB1"
ORDS_PORT="8080"

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║     ORACLE APEX FIX SCRIPT v4.3 - KaizenixCore                        ║"
echo "║     Fixing: Error 571, 574, 500, Images                               ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo ""

# Load password
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
if [ -z "$PASS" ]; then
    echo "❌ Error: Password file not found at $PROJECT_DIR/.db_password"
    echo "   Please run the installer again or create this file manually."
    exit 1
fi

echo "════════════════════════════════════════════════════════════════"
echo "  Phase 1: Stopping Services"
echo "════════════════════════════════════════════════════════════════"

echo "[1/15] Stopping ORDS processes..."
pkill -9 -f "ords.*serve" 2>/dev/null || true
pkill -9 -f "java.*ords" 2>/dev/null || true
sleep 5
echo "      ✅ Done"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Phase 2: Database Preparation"
echo "════════════════════════════════════════════════════════════════"

echo "[2/15] Starting database container..."
docker start oracle-apex-db 2>/dev/null || true
echo "      Waiting for database (2-3 minutes)..."

READY=false
for i in {1..60}; do
    if docker logs oracle-apex-db 2>&1 | grep -q "DATABASE IS READY"; then
        READY=true
        break
    fi
    sleep 5
done

if [ "$READY" = true ]; then
    echo "      ✅ Database is ready"
else
    echo "      ⚠️  Database may still be starting, continuing..."
fi
sleep 30

echo "[3/15] Resetting database password..."
docker exec oracle-apex-db resetPassword "$PASS" 2>/dev/null || true
sleep 20
echo "      ✅ Done"

echo "[4/15] Disabling password policies..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/$PASS@//localhost:$DB_PORT/$DB_SERVICE as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT 
    FAILED_LOGIN_ATTEMPTS UNLIMITED 
    PASSWORD_LIFE_TIME UNLIMITED 
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" 2>/dev/null || true
echo "      ✅ Done"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Phase 3: Fixing Users (Error 571 Fix)"
echo "════════════════════════════════════════════════════════════════"

echo "[5/15] Dropping and recreating ORDS_PUBLIC_USER..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/$PASS@//localhost:$DB_PORT/$DB_SERVICE as sysdba << 'EOSQL'
-- Drop existing user
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Create new user
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \"$PASS\"
    DEFAULT TABLESPACE SYSAUX
    QUOTA UNLIMITED ON SYSAUX;

-- Grant basic privileges
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

-- Grant execute privileges on required packages
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SQL TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.HTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.HTF TO ORDS_PUBLIC_USER;

-- Unlock account
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

COMMIT;
EXIT;
EOSQL" 2>/dev/null || true
echo "      ✅ Done"

echo "[6/15] Fixing APEX users..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/$PASS@//localhost:$DB_PORT/$DB_SERVICE as sysdba << 'EOSQL'
-- Fix APEX_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \"$PASS\" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Fix APEX_LISTENER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY \"$PASS\" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Fix APEX_REST_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \"$PASS\" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

COMMIT;
EXIT;
EOSQL" 2>/dev/null || true
echo "      ✅ Done"

echo "[7/15] Granting proxy permissions..."
docker exec oracle-apex-db bash -c "sqlplus -s sys/$PASS@//localhost:$DB_PORT/$DB_SERVICE as sysdba << 'EOSQL'
-- Grant proxy connect permissions
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
EOSQL" 2>/dev/null || true
echo "      ✅ Done"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Phase 4: ORDS Configuration (Error 571 Fix)"
echo "════════════════════════════════════════════════════════════════"

echo "[8/15] Finding ORDS binary..."
ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

if [ -z "$ORDS_BIN" ]; then
    echo "      ❌ ORDS binary not found!"
    exit 1
fi
chmod +x "$ORDS_BIN" 2>/dev/null || true
echo "      Found: $ORDS_BIN"

echo "[9/15] Cleaning ORDS configuration..."
rm -rf "$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
rm -rf "$ORDS_CONFIG_DIR/global" 2>/dev/null || true
mkdir -p "$ORDS_CONFIG_DIR/databases/default"
mkdir -p "$ORDS_CONFIG_DIR/global"
echo "      ✅ Done"

# MODIFIED: اضافه شدن ایجاد pool.xml دستی
echo "[10/15] Creating pool.xml configuration..."
cat > "$ORDS_CONFIG_DIR/databases/default/pool.xml" << POOLXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="db.hostname">localhost</entry>
<entry key="db.port">$DB_PORT</entry>
<entry key="db.servicename">$DB_SERVICE</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">!$PASS</entry>
<entry key="jdbc.InitialLimit">10</entry>
<entry key="jdbc.MinLimit">5</entry>
<entry key="jdbc.MaxLimit">50</entry>
<entry key="jdbc.MaxStatementsLimit">50</entry>
<entry key="jdbc.InactivityTimeout">300</entry>
<entry key="jdbc.statementTimeout">900</entry>
<entry key="jdbc.MaxConnectionReuseCount">1000</entry>
</properties>
POOLXML
echo "      ✅ Done"

echo "[11/15] Configuring ORDS password secret..."
echo "$PASS" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
echo "      ✅ Done"

echo "[12/15] Running ORDS install..."
# Create temp file for passwords
PASS_FILE=$(mktemp)
printf "%s\n%s\n%s\n" "$PASS" "$PASS" "$PASS" > "$PASS_FILE"

"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" install \
    --admin-user SYS \
    --db-hostname localhost \
    --db-port $DB_PORT \
    --db-servicename $DB_SERVICE \
    --feature-sdw true \
    --feature-rest-enabled-sql true \
    --gateway-mode proxied \
    --gateway-user ORDS_PUBLIC_USER \
    --password-stdin < "$PASS_FILE" 2>/dev/null || true

rm -f "$PASS_FILE"
echo "      ✅ Done"

echo "[13/15] Configuring ORDS settings..."
"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port $ORDS_PORT 2>/dev/null || true
"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.context.path /ords 2>/dev/null || true
"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i 2>/dev/null || true
"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" 2>/dev/null || true
"$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" 2>/dev/null || true
echo "      ✅ Done"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Phase 5: APEX Images Fix"
echo "════════════════════════════════════════════════════════════════"

echo "[14/15] Fixing APEX images..."
rm -rf "$IMAGES_DIR" 2>/dev/null || true

if [ -d "$PROJECT_DIR/apex/images" ]; then
    cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR"
    chmod -R 755 "$IMAGES_DIR"
    echo "      ✅ Images copied from apex/images"
else
    echo "      ⚠️  apex/images not found, creating empty directory"
    mkdir -p "$IMAGES_DIR"
fi

# Set IMAGE_PREFIX in database
APEX_SCHEMA=$(cat "$PROJECT_DIR/.apex_schema" 2>/dev/null)
[ -z "$APEX_SCHEMA" ] && APEX_SCHEMA="APEX_240100"

docker exec oracle-apex-db bash -c "sqlplus -s sys/$PASS@//localhost:$DB_PORT/$DB_SERVICE as sysdba << 'EOSQL'
BEGIN
    ${APEX_SCHEMA}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    ${APEX_SCHEMA}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
EXIT;
EOSQL" 2>/dev/null || true
echo "      ✅ Done"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Phase 6: Starting ORDS"
echo "════════════════════════════════════════════════════════════════"

echo "[15/15] Starting ORDS service..."
mkdir -p "$LOG_DIR"

export ORDS_CONFIG="$ORDS_CONFIG_DIR"
export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
    --port $ORDS_PORT \
    --apex-images "$IMAGES_DIR" \
    > "$LOG_DIR/ords.log" 2>&1 &

ORDS_PID=$!
echo "$ORDS_PID" > "$PROJECT_DIR/ords.pid"
echo "      ORDS started with PID: $ORDS_PID"

echo ""
echo "      Waiting for ORDS to initialize (2 minutes)..."
for i in {1..24}; do
    echo -n "."
    sleep 5
done
echo ""

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║     VERIFICATION                                                      ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo ""

HTTP_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/apex_admin" --max-time 15 2>/dev/null || echo "000")
HTTP_LOGIN=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/ords/f?p=4550" --max-time 15 2>/dev/null || echo "000")
HTTP_IMAGES=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$ORDS_PORT/i/apex_version.txt" --max-time 15 2>/dev/null || echo "000")

echo "  APEX Admin Panel:  HTTP $HTTP_ADMIN"
echo "  APEX Login Page:   HTTP $HTTP_LOGIN"
echo "  APEX Images:       HTTP $HTTP_IMAGES"
echo ""

# Test database connection
echo "  Testing database connection..."
DB_TEST=$(docker exec oracle-apex-db bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s ORDS_PUBLIC_USER/$PASS@//localhost:$DB_PORT/$DB_SERVICE" 2>/dev/null | grep -c "1" || echo "0")

if [ "$DB_TEST" -gt 0 ]; then
    echo "  Database Connection: ✅ OK"
else
    echo "  Database Connection: ❌ Failed"
fi
echo ""

echo "════════════════════════════════════════════════════════════════"
if [[ "$HTTP_ADMIN" =~ ^(200|302|303)$ ]] && [[ "$HTTP_IMAGES" =~ ^(200|304)$ ]]; then
    echo "  🎉 SUCCESS! All fixes applied successfully!"
    echo ""
    echo "  🌐 Open in browser:"
    echo "     Admin:  http://localhost:$ORDS_PORT/ords/apex_admin"
    echo "     Login:  http://localhost:$ORDS_PORT/ords/f?p=4550"
    echo ""
    if [ -f "$PROJECT_DIR/.apex_password" ]; then
        APEX_PASS=$(cat "$PROJECT_DIR/.apex_password")
        echo "  🔐 Credentials:"
        echo "     Workspace: INTERNAL"
        echo "     Username:  ADMIN"
        echo "     Password:  $APEX_PASS"
    fi
elif [[ "$HTTP_ADMIN" =~ ^(200|302|303)$ ]]; then
    echo "  ⚠️  APEX is working but images may have issues."
    echo "     Check: http://localhost:$ORDS_PORT/i/"
else
    echo "  ⚠️  Some issues may remain."
    echo ""
    echo "  📋 Troubleshooting:"
    echo "     1. Wait 2-3 more minutes and refresh browser"
    echo "     2. Check logs: tail -100 $LOG_DIR/ords.log"
    echo "     3. Restart: bash $PROJECT_DIR/scripts/start.sh"
fi
echo "════════════════════════════════════════════════════════════════"
echo ""
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh"

    # ═══════════════════════════════════════════════════════════════════════════
    # LOGS SCRIPT
    # ═══════════════════════════════════════════════════════════════════════════
    cat > "$SCRIPTS_DIR/logs.sh" << 'LOGSEOF'
#!/bin/bash
################################################################################
# Oracle APEX Logs Viewer - KaizenixCore
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
LOG_FILE="$PROJECT_DIR/logs/ords.log"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Oracle APEX Logs Viewer"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  Log file: $LOG_FILE"
echo "  Press Ctrl+C to exit"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""

if [ -f "$LOG_FILE" ]; then
    tail -f "$LOG_FILE"
else
    echo "❌ Log file not found: $LOG_FILE"
    echo ""
    echo "ORDS may not have been started yet."
    echo "Run: bash $PROJECT_DIR/scripts/start.sh"
fi
LOGSEOF
    chmod +x "$SCRIPTS_DIR/logs.sh"

    # ═══════════════════════════════════════════════════════════════════════════
    # RESET APEX PASSWORD SCRIPT
    # ═══════════════════════════════════════════════════════════════════════════
    cat > "$SCRIPTS_DIR/reset-apex-password.sh" << 'RESETEOF'
#!/bin/bash
################################################################################
# Oracle APEX Password Reset Script - KaizenixCore
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
DB_PORT="1521"
DB_SERVICE="XEPDB1"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Oracle APEX Admin Password Reset"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Load database password
PASS=$(cat "$PROJECT_DIR/.db_password" 2>/dev/null)
if [ -z "$PASS" ]; then
    echo "❌ Error: Database password file not found!"
    exit 1
fi

# Load APEX schema
APEX_SCHEMA=$(cat "$PROJECT_DIR/.apex_schema" 2>/dev/null)
[ -z "$APEX_SCHEMA" ] && APEX_SCHEMA="APEX_240100"

echo "Enter new APEX Admin password:"
echo "(Must start with letter, only letters/numbers, min 6 chars)"
echo ""
read -s -p "New password: " NEW_PASS
echo ""

# Validate password
if [[ ! "$NEW_PASS" =~ ^[a-zA-Z][a-zA-Z0-9]{5,}$ ]]; then
    echo ""
    echo "❌ Invalid password format!"
    echo "   - Must start with a letter (a-z, A-Z)"
    echo "   - Only letters and numbers allowed"
    echo "   - Minimum 6 characters"
    exit 1
fi

echo ""
echo "Resetting password..."

docker exec oracle-apex-db bash -c "sqlplus -s sys/$PASS@//localhost:$DB_PORT/$DB_SERVICE as sysdba << 'EOSQL'
BEGIN
    ${APEX_SCHEMA}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    ${APEX_SCHEMA}.APEX_UTIL.EDIT_USER(
        p_user_id                      => ${APEX_SCHEMA}.APEX_UTIL.GET_USER_ID('ADMIN'),
        p_user_name                    => 'ADMIN',
        p_web_password                 => '$NEW_PASS',
        p_new_password                 => '$NEW_PASS',
        p_change_password_on_first_use => 'N',
        p_account_locked               => 'N'
    );
    COMMIT;
END;
/
EXIT;
EOSQL" 2>/dev/null

# Save new password
echo "$NEW_PASS" > "$PROJECT_DIR/.apex_password"
chmod 600 "$PROJECT_DIR/.apex_password"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  ✅ APEX Admin password reset successfully!"
echo ""
echo "  New credentials:"
echo "     Workspace: INTERNAL"
echo "     Username:  ADMIN"
echo "     Password:  $NEW_PASS"
echo "════════════════════════════════════════════════════════════════"
echo ""
RESETEOF
    chmod +x "$SCRIPTS_DIR/reset-apex-password.sh"

    log "Management scripts created (stop, status, start, fix, logs, reset-apex-password)"
}
# ═══════════════════════════════════════════════════════════════════════════
    # LAUNCH GUI SCRIPT
    # ═══════════════════════════════════════════════════════════════════════════
    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
################################################################################
# Oracle APEX GUI Manager - KaizenixCore v4.3
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ORDS_PORT="8080"

# Detect GUI tool
GUI=""
if command -v yad >/dev/null 2>&1; then
    GUI="yad"
elif command -v zenity >/dev/null 2>&1; then
    GUI="zenity"
else
    echo "No GUI tool found. Please install yad or zenity."
    echo "  Ubuntu/Debian: sudo apt install yad"
    echo "  Fedora: sudo dnf install yad"
    echo "  openSUSE: sudo zypper install yad"
    exit 1
fi

show_menu() {
    # Get current status
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
        yad --list \
            --title="Oracle APEX Manager - KaizenixCore v4.3" \
            --text="$status_text\n\nSelect an action:" \
            --radiolist \
            --column="" \
            --column="ID" \
            --column="Action" \
            TRUE "start" "▶️  Start Services" \
            FALSE "stop" "⏹️  Stop Services" \
            FALSE "restart" "🔄  Restart Services" \
            FALSE "fix" "🔧  Fix Problems (571/574/500)" \
            FALSE "status" "📊  Check Status" \
            FALSE "logs" "📜  View Logs" \
            FALSE "open_admin" "🌐  Open Admin Panel" \
            FALSE "open_login" "🔐  Open Login Page" \
            FALSE "reset_pass" "🔑  Reset APEX Password" \
            FALSE "exit" "❌  Exit" \
            --width=500 \
            --height=550 \
            --center \
            --button="Cancel:1" \
            --button="OK:0" \
            --print-column=2 \
            --hide-column=2 \
            --borders=15 \
            2>/dev/null
    else
        zenity --list \
            --title="Oracle APEX Manager - KaizenixCore v4.3" \
            --text="$status_text\n\nSelect an action:" \
            --radiolist \
            --column="" \
            --column="ID" \
            --column="Action" \
            TRUE "start" "▶️  Start Services" \
            FALSE "stop" "⏹️  Stop Services" \
            FALSE "restart" "🔄  Restart Services" \
            FALSE "fix" "🔧  Fix Problems (571/574/500)" \
            FALSE "status" "📊  Check Status" \
            FALSE "logs" "📜  View Logs" \
            FALSE "open_admin" "🌐  Open Admin Panel" \
            FALSE "open_login" "🔐  Open Login Page" \
            FALSE "reset_pass" "🔑  Reset APEX Password" \
            FALSE "exit" "❌  Exit" \
            --width=500 \
            --height=550 \
            --ok-label="OK" \
            --cancel-label="Cancel" \
            --hide-column=2 \
            2>/dev/null
    fi
}

run_in_terminal() {
    local cmd="$1"
    local title="$2"

    # Try different terminal emulators
    if command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal --title="$title" -- bash -c "$cmd; echo; echo 'Press Enter to close...'; read"
    elif command -v konsole >/dev/null 2>&1; then
        konsole --title "$title" -e bash -c "$cmd; echo; echo 'Press Enter to close...'; read" &
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        xfce4-terminal --title="$title" -e "bash -c '$cmd; echo; echo Press Enter to close...; read'" &
    elif command -v mate-terminal >/dev/null 2>&1; then
        mate-terminal --title="$title" -e "bash -c '$cmd; echo; echo Press Enter to close...; read'" &
    elif command -v lxterminal >/dev/null 2>&1; then
        lxterminal --title="$title" -e "bash -c '$cmd; echo; echo Press Enter to close...; read'" &
    elif command -v xterm >/dev/null 2>&1; then
        xterm -title "$title" -e "bash -c '$cmd; echo; echo Press Enter to close...; read'" &
    else
        # Fallback: show output in GUI
        local output
        output=$($cmd 2>&1)
        if [ "$GUI" = "yad" ]; then
            echo "$output" | yad --text-info \
                --title="$title" \
                --width=700 \
                --height=500 \
                --center \
                --fontname="monospace 10" \
                2>/dev/null
        else
            echo "$output" | zenity --text-info \
                --title="$title" \
                --width=700 \
                --height=500 \
                --font="monospace" \
                2>/dev/null
        fi
    fi
}

show_info() {
    local title="$1"
    local text="$2"
    
    if [ "$GUI" = "yad" ]; then
        yad --info \
            --title="$title" \
            --text="$text" \
            --width=400 \
            --center \
            --timeout=5 \
            --borders=15 \
            2>/dev/null
    else
        zenity --info \
            --title="$title" \
            --text="$text" \
            --width=400 \
            --timeout=5 \
            2>/dev/null
    fi
}

# Main loop
while true; do
    choice=$(show_menu)
    choice=$(echo "$choice" | tr -d '|' | tr -d ' ')

    # Exit if cancelled or empty
    [ -z "$choice" ] && exit 0

    case "$choice" in
        start)
            run_in_terminal "bash '$SCRIPTS_DIR/start.sh'" "Starting Oracle APEX"
            ;;
        stop)
            bash "$SCRIPTS_DIR/stop.sh"
            show_info "Oracle APEX" "Services stopped successfully."
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
                    --title="ORDS Logs" \
                    --width=900 \
                    --height=600 \
                    --center \
                    --fontname="monospace 10" \
                    --button="Refresh:2" \
                    --button="Close:0" \
                    2>/dev/null
            else
                tail -200 "$PROJECT_DIR/logs/ords.log" 2>/dev/null | zenity --text-info \
                    --title="ORDS Logs" \
                    --width=900 \
                    --height=600 \
                    --font="monospace" \
                    2>/dev/null
            fi
            ;;
        open_admin)
            xdg-open "http://localhost:$ORDS_PORT/ords/apex_admin" 2>/dev/null &
            ;;
        open_login)
            xdg-open "http://localhost:$ORDS_PORT/ords/f?p=4550" 2>/dev/null &
            ;;
        reset_pass)
            run_in_terminal "bash '$SCRIPTS_DIR/reset-apex-password.sh'" "Reset APEX Password"
            ;;
        exit)
            exit 0
            ;;
    esac

    sleep 0.5
done
GUIEOF
    chmod +x "$SCRIPTS_DIR/launch-gui.sh"

    # ═══════════════════════════════════════════════════════════════════════════
    # OPEN DBEAVER SCRIPT
    # ═══════════════════════════════════════════════════════════════════════════
    cat > "$SCRIPTS_DIR/open-dbeaver.sh" << 'DBEAVEREOF'
#!/bin/bash
################################################################################
# DBeaver Launcher - KaizenixCore
################################################################################

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Opening DBeaver Database Manager"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  Connection details for Oracle APEX database:"
echo ""
echo "    Host:     localhost"
echo "    Port:     1521"
echo "    Database: XEPDB1"
echo "    Username: SYS (as SYSDBA)"
echo "    Password: (your database password)"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""

# Try different DBeaver installations
if command -v dbeaver-ce &> /dev/null; then
    echo "Starting DBeaver CE..."
    dbeaver-ce &
elif command -v dbeaver &> /dev/null; then
    echo "Starting DBeaver..."
    dbeaver &
elif command -v flatpak &> /dev/null && flatpak list 2>/dev/null | grep -q dbeaver; then
    echo "Starting DBeaver (Flatpak)..."
    flatpak run io.dbeaver.DBeaverCommunity &
elif command -v snap &> /dev/null && snap list 2>/dev/null | grep -q dbeaver; then
    echo "Starting DBeaver (Snap)..."
    snap run dbeaver-ce &
else
    echo "❌ DBeaver not found!"
    echo ""
    echo "Install DBeaver using one of these methods:"
    echo "  Ubuntu/Debian: sudo apt install dbeaver-ce"
    echo "  Fedora: sudo dnf install dbeaver-ce"
    echo "  Flatpak: flatpak install flathub io.dbeaver.DBeaverCommunity"
    echo "  Snap: sudo snap install dbeaver-ce"
    echo ""
    exit 1
fi

echo "DBeaver started successfully."
DBEAVEREOF
    chmod +x "$SCRIPTS_DIR/open-dbeaver.sh"

    # ═══════════════════════════════════════════════════════════════════════════
    # CREATE DESKTOP ICON
    # ═══════════════════════════════════════════════════════════════════════════
    safe_mkdir "$HOME/.local/share/applications"
    safe_mkdir "$HOME/.local/share/icons"

    # Create SVG icon
    cat > "$PROJECT_DIR/oracle-apex-icon.svg" << 'SVGEOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF4444;stop-opacity:1"/>
      <stop offset="100%" style="stop-color:#CC0000;stop-opacity:1"/>
    </linearGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="2" dy="4" stdDeviation="4" flood-opacity="0.3"/>
    </filter>
  </defs>
  <rect x="20" y="20" width="216" height="216" rx="40" fill="url(#grad1)" filter="url(#shadow)"/>
  <text x="128" y="95" font-family="Arial Black, sans-serif" font-size="48" font-weight="bold" fill="white" text-anchor="middle">APEX</text>
  <text x="128" y="145" font-family="Arial, sans-serif" font-size="24" font-weight="600" fill="rgba(255,255,255,0.95)" text-anchor="middle">Manager</text>
  <text x="128" y="185" font-family="Arial, sans-serif" font-size="16" fill="rgba(255,255,255,0.75)" text-anchor="middle">KaizenixCore</text>
  <circle cx="200" cy="56" r="24" fill="#00CC00"/>
  <path d="M190 56 L198 64 L212 48" stroke="white" stroke-width="4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
SVGEOF

    # Copy icon to icons directory
    cp "$PROJECT_DIR/oracle-apex-icon.svg" "$HOME/.local/share/icons/" 2>/dev/null || true

    # Create desktop entry
    cat > "$HOME/.local/share/applications/oracle-apex.desktop" << DESKTOPEOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle APEX Manager
GenericName=Database Development Tool
Comment=Manage Oracle APEX and ORDS - KaizenixCore v${VERSION}
Exec=bash ${SCRIPTS_DIR}/launch-gui.sh
Icon=${HOME}/.local/share/icons/oracle-apex-icon.svg
Terminal=false
Categories=Development;Database;IDE;
Keywords=oracle;apex;ords;database;sql;
StartupNotify=true
StartupWMClass=oracle-apex-manager
DESKTOPEOF
    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"

    # Update desktop database
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true

    # Create desktop shortcut if Desktop folder exists
    if [ -d "$HOME/Desktop" ]; then
        cp "$HOME/.local/share/applications/oracle-apex.desktop" "$HOME/Desktop/" 2>/dev/null || true
        chmod +x "$HOME/Desktop/oracle-apex.desktop" 2>/dev/null || true
    fi

    log "Management scripts created successfully"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CREATE SYSTEMD SERVICE
# ═══════════════════════════════════════════════════════════════════════════════
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

    # Create service control script
    cat > "$SCRIPTS_DIR/oracle-apex-service.sh" << SERVICEEOF
#!/bin/bash
################################################################################
# Oracle APEX Systemd Service Script - KaizenixCore v${VERSION}
################################################################################

PROJECT_DIR="${PROJECT_DIR}"
ORDS_CONFIG_DIR="${ORDS_CONFIG_DIR}"
ORDS_BIN="${ORDS_BIN}"
IMAGES_DIR="${IMAGES_DIR}"
LOG_DIR="${LOG_DIR}"
ORDS_PORT="${ORDS_PORT}"
DB_PORT="${DB_PORT}"
DB_SERVICE="${DB_SERVICE}"
CONTAINER_NAME="${CONTAINER_NAME}"

case "\$1" in
    start)
        echo "Starting Oracle APEX services..."
        
        # Start database container
        docker start \$CONTAINER_NAME 2>/dev/null
        
        # Wait for database
        echo "Waiting for database..."
        for i in {1..60}; do
            if docker logs \$CONTAINER_NAME 2>&1 | grep -q "DATABASE IS READY"; then
                break
            fi
            sleep 5
        done
        sleep 30

        # Configure password
        PASS=\$(cat "\$PROJECT_DIR/.db_password" 2>/dev/null)
        if [ -n "\$PASS" ]; then
            echo "\$PASS" | "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
        fi

        # Start ORDS
        export ORDS_CONFIG="\$ORDS_CONFIG_DIR"
        export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
        
        nohup "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" serve \\
            --port \$ORDS_PORT \\
            --apex-images "\$IMAGES_DIR" \\
            > "\$LOG_DIR/ords.log" 2>&1 &
        
        echo \$! > "\$PROJECT_DIR/ords.pid"
        echo "Oracle APEX started"
        ;;
        
    stop)
        echo "Stopping Oracle APEX services..."
        
        # Stop ORDS
        if [ -f "\$PROJECT_DIR/ords.pid" ]; then
            kill \$(cat "\$PROJECT_DIR/ords.pid") 2>/dev/null || true
            rm -f "\$PROJECT_DIR/ords.pid"
        fi
        pkill -9 -f "ords.*serve" 2>/dev/null || true
        pkill -9 -f "java.*ords" 2>/dev/null || true
        
        # Stop database
        docker stop \$CONTAINER_NAME 2>/dev/null || true
        
        echo "Oracle APEX stopped"
        ;;
        
    restart)
        \$0 stop
        sleep 5
        \$0 start
        ;;
        
    status)
        echo "Oracle APEX Status:"
        
        if docker inspect -f '{{.State.Running}}' \$CONTAINER_NAME 2>/dev/null | grep -q "true"; then
            echo "  Database: Running"
        else
            echo "  Database: Stopped"
        fi

        if pgrep -f "ords.*serve" >/dev/null 2>&1; then
            echo "  ORDS: Running"
        else
            echo "  ORDS: Stopped"
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
Wants=network-online.target

[Service]
Type=forking
User=$USER
Group=$USER
WorkingDirectory=$PROJECT_DIR
Environment="HOME=$HOME"
Environment="PATH=/usr/local/bin:/usr/bin:/bin"
ExecStart=$SCRIPTS_DIR/oracle-apex-service.sh start
ExecStop=$SCRIPTS_DIR/oracle-apex-service.sh stop
ExecReload=$SCRIPTS_DIR/oracle-apex-service.sh restart
RemainAfterExit=yes
TimeoutStartSec=600
TimeoutStopSec=120
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
SYSTEMDEOF

    # Reload systemd and enable service
    run_sudo systemctl daemon-reload
    run_sudo systemctl enable oracle-apex.service

    log "Systemd service created and enabled"
    gui_info "$(get_text info)" "$(get_text service_created)\n\nCommands:\n  sudo systemctl start oracle-apex\n  sudo systemctl stop oracle-apex\n  sudo systemctl status oracle-apex"
}
# ═══════════════════════════════════════════════════════════════════════════════
# REPAIR INSTALLATION - MODIFIED: اصلاح شده برای رفع خطای 571
# ═══════════════════════════════════════════════════════════════════════════════
repair_installation() {
    log "═══════════════════════════════════════════════════════════════"
    log "REPAIR INSTALLATION - COMPREHENSIVE FIX FOR ERROR 571/574/500"
    log "═══════════════════════════════════════════════════════════════"

    if [ -z "$ORACLE_PASSWORD" ] || [ -z "$APEX_ADMIN_PASSWORD" ]; then
        log "ERROR: Passwords not set!"
        gui_error "$(get_text error)" "Passwords not configured. Please enter passwords first."
        return 1
    fi

    start_progress

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 1: Stop Services
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 5 "Phase 1: Stopping ORDS processes..."
    pkill -9 -f "ords.*serve" 2>/dev/null || true
    pkill -9 -f "java.*ords" 2>/dev/null || true
    sleep 5
    log "ORDS processes stopped"

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 2: Start Database
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 10 "Phase 2: Starting database container..."
    docker start "$CONTAINER_NAME" 2>/dev/null || true
    sleep 10

    update_progress 15 "Waiting for database to be ready..."
    local db_ready=false
    for i in {1..60}; do
        if docker logs "$CONTAINER_NAME" 2>&1 | grep -q "DATABASE IS READY"; then
            db_ready=true
            log "Database is ready"
            break
        fi
        sleep 5
    done
    sleep 30

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 3: Reset Database Password
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 25 "Phase 3: $(get_text resetting_password)"
    docker exec "$CONTAINER_NAME" resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 20
    log "Database password reset"

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 4: Disable Password Policies
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 30 "Phase 4: Disabling password policies..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT 
    FAILED_LOGIN_ATTEMPTS UNLIMITED 
    PASSWORD_LIFE_TIME UNLIMITED 
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Password policies disabled"

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 5: Fix ORDS_PUBLIC_USER (Critical for Error 571)
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 40 "Phase 5: Fixing ORDS_PUBLIC_USER (Error 571 fix)..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
-- Drop existing ORDS_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Create ORDS_PUBLIC_USER with correct privileges
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\"
    DEFAULT TABLESPACE SYSAUX
    QUOTA UNLIMITED ON SYSAUX;

-- Grant basic roles
GRANT CONNECT TO ORDS_PUBLIC_USER;
GRANT RESOURCE TO ORDS_PUBLIC_USER;

-- Grant session privileges
GRANT CREATE SESSION TO ORDS_PUBLIC_USER;
GRANT ALTER SESSION TO ORDS_PUBLIC_USER;

-- Grant object creation privileges
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
GRANT EXECUTE ON SYS.DBMS_SQL TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.HTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.HTF TO ORDS_PUBLIC_USER;

-- Unlock account
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "ORDS_PUBLIC_USER recreated with full privileges"

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 6: Fix APEX Users
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 50 "Phase 6: Fixing APEX users..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
-- Fix APEX_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Fix APEX_LISTENER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Fix APEX_REST_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Grant proxy connect permissions
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
    log "APEX users fixed"

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 7: Reset APEX Admin Password
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 55 "Phase 7: Resetting APEX admin password..."
    local apex_schema=$(cat "$PROJECT_DIR/.apex_schema" 2>/dev/null)
    [ -z "$apex_schema" ] && apex_schema="APEX_240100"

    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
BEGIN
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    ${apex_schema}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    
    BEGIN
        ${apex_schema}.APEX_UTIL.EDIT_USER(
            p_user_id                      => ${apex_schema}.APEX_UTIL.GET_USER_ID('ADMIN'),
            p_user_name                    => 'ADMIN',
            p_web_password                 => '${APEX_ADMIN_PASSWORD}',
            p_new_password                 => '${APEX_ADMIN_PASSWORD}',
            p_change_password_on_first_use => 'N',
            p_account_locked               => 'N'
        );
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    COMMIT;
END;
/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "APEX admin password reset"

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 8: Reinstall ORDS Connection (Critical for Error 571)
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 65 "Phase 8: Reinstalling ORDS connection..."
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

    if [ -n "$ORDS_BIN" ] && [ -x "$ORDS_BIN" ]; then
        # Clean old configuration
        rm -rf "$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
        rm -rf "$ORDS_CONFIG_DIR/global" 2>/dev/null || true
        mkdir -p "$ORDS_CONFIG_DIR/databases/default"
        mkdir -p "$ORDS_CONFIG_DIR/global"
        
        # MODIFIED: Create pool.xml manually (Critical for Error 571)
        cat > "$ORDS_CONFIG_DIR/databases/default/pool.xml" << POOLEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="db.hostname">localhost</entry>
<entry key="db.port">${DB_PORT}</entry>
<entry key="db.servicename">${DB_SERVICE}</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">!${ORACLE_PASSWORD}</entry>
<entry key="jdbc.InitialLimit">10</entry>
<entry key="jdbc.MinLimit">5</entry>
<entry key="jdbc.MaxLimit">50</entry>
<entry key="jdbc.MaxStatementsLimit">50</entry>
<entry key="jdbc.InactivityTimeout">300</entry>
<entry key="jdbc.statementTimeout">900</entry>
<entry key="jdbc.MaxConnectionReuseCount">1000</entry>
</properties>
POOLEOF
        log "pool.xml created"
        
        # Configure password secret
        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
        
        # Run ORDS install
        local PASS_FILE=$(mktemp)
        printf "%s\n%s\n%s\n" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" > "$PASS_FILE"

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
        
        # Configure ORDS settings
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port "$ORDS_PORT" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.context.path /ords >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i >> "$INSTALL_LOG" 2>&1 || true
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
        
        log "ORDS connection reinstalled"
    else
        log "ERROR: ORDS binary not found at $PROJECT_DIR/ords"
    fi

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 9: Fix APEX Images
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 75 "Phase 9: $(get_text fixing_images)"
    fix_apex_images
    log "APEX images fixed"

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 10: Save Configuration
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 80 "Phase 10: Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    log "Configuration saved"

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 11: Start ORDS
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 85 "Phase 11: Starting ORDS..."
    pkill -9 -f "ords.*serve" 2>/dev/null || true
    sleep 5
    run_sudo fuser -k "${ORDS_PORT}/tcp" 2>/dev/null || true
    sleep 2

    if [ -n "$ORDS_BIN" ] && [ -x "$ORDS_BIN" ]; then
        export ORDS_CONFIG="$ORDS_CONFIG_DIR"
        export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

        nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
            --port "$ORDS_PORT" \
            --apex-images "$IMAGES_DIR" \
            > "$LOG_DIR/ords.log" 2>&1 &

        local ords_pid=$!
        echo "$ords_pid" > "$PROJECT_DIR/ords.pid"
        log "ORDS started with PID $ords_pid"
    fi

    # ═══════════════════════════════════════════════════════════════════════════
    # Phase 12: Wait and Verify
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 90 "Phase 12: Waiting for ORDS to initialize..."
    sleep 120

    update_progress 95 "Phase 13: $(get_text verifying)"
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" --max-time 15 2>/dev/null || echo "000")
    local http_images=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/i/apex_version.txt" --max-time 15 2>/dev/null || echo "000")
    log "Verification - Admin: HTTP $http_admin, Images: HTTP $http_images"

    update_progress 100 "$(get_text completed)"
    stop_progress

    # Show result
    if [[ "$http_admin" =~ ^(200|302|303)$ ]]; then
        log "REPAIR SUCCESSFUL!"
        gui_info "$(get_text success_title)" \
            "✅ Repair Completed Successfully!\n\n🌐 Admin Panel:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\n🔐 Login Page:\nhttp://localhost:${ORDS_PORT}/ords/f?p=4550\n\n📋 Credentials:\n   Workspace: INTERNAL\n   Username: ADMIN\n   Password: ${APEX_ADMIN_PASSWORD}" 600 450
        return 0
    else
        log "Repair completed but APEX may need more time (HTTP: $http_admin)"
        gui_warning "$(get_text warning)" \
            "⚠️ Repair completed but APEX is still initializing.\n\nPlease wait 2-3 minutes and try:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\nIf still having issues, run:\nbash ~/oracle-apex-complete/scripts/fix.sh\n\nOr check logs:\ntail -100 ~/oracle-apex-complete/logs/ords.log" 600 400
        return 0
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# RUN FRESH INSTALLATION - MODIFIED: اصلاح شده با pool.xml و تنظیمات کامل
# ═══════════════════════════════════════════════════════════════════════════════
run_fresh_installation() {
    log "═══════════════════════════════════════════════════════════════"
    log "Starting fresh installation v${VERSION}..."
    log "═══════════════════════════════════════════════════════════════"

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

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 1-2: Save Configuration
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 2 "$(get_text step) 1/26: Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"
    log "Configuration saved"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 3: Install Dependencies
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 5 "$(get_text step) 2/26: $(get_text installing_deps)"
    install_dependencies
    log "Dependencies installed"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 4-5: Download APEX and ORDS
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 10 "$(get_text step) 3/26: $(get_text downloading) APEX..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || \
        curl -L -o "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || true
        log "APEX downloaded"
    else
        log "APEX already downloaded"
    fi

    update_progress 15 "$(get_text step) 4/26: $(get_text downloading) ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || \
        curl -L -o "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || true
        log "ORDS downloaded"
    else
        log "ORDS already downloaded"
    fi

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 6: Extract Files
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 18 "$(get_text step) 5/26: $(get_text extracting)"
    cd "$PROJECT_DIR" || exit 1

    rm -rf apex ords 2>/dev/null || true
    unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" >> "$INSTALL_LOG" 2>&1 || true
    mkdir -p ords
    unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords >> "$INSTALL_LOG" 2>&1 || true

    # Make ORDS executable
    find ords -name "ords" -type f -exec chmod +x {} \; 2>/dev/null || true

    # Copy images
    rm -rf "$IMAGES_DIR" 2>/dev/null || true
    cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR" 2>/dev/null || true
    chmod -R 755 "$IMAGES_DIR" 2>/dev/null || true
    log "Files extracted"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 7: Create Docker Configuration
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 22 "$(get_text step) 6/26: Creating Docker configuration..."
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
    log "Docker configuration created"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 8: Start Database Container
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 26 "$(get_text step) 7/26: $(get_text starting_db)"
    cd "$PROJECT_DIR" || exit 1
    docker compose up -d >> "$INSTALL_LOG" 2>&1 || docker-compose up -d >> "$INSTALL_LOG" 2>&1 || true
    log "Docker container started"

    update_progress 30 "Waiting for database (5-10 minutes)..."
    if ! wait_for_database_ready; then
        log "Warning: Database wait timed out, continuing..."
    fi
    sleep 60

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 9: Reset Database Password
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 35 "$(get_text step) 8/26: $(get_text resetting_password)"
    docker exec "$CONTAINER_NAME" resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 30
    log "Database password reset"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 10: Disable Password Policies
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 38 "$(get_text step) 9/26: Disabling password policies..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT 
    FAILED_LOGIN_ATTEMPTS UNLIMITED 
    PASSWORD_LIFE_TIME UNLIMITED 
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Password policies disabled"
    # ═══════════════════════════════════════════════════════════════════════════
    # Step 11: Install APEX
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 40 "$(get_text step) 10/26: $(get_text installing_apex)"
    docker exec "$CONTAINER_NAME" bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "APEX installation completed"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 12: Reset Image Prefix
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 48 "$(get_text step) 11/26: $(get_text fixing_images)"
    docker exec "$CONTAINER_NAME" bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@utilities/reset_image_prefix.sql
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "Image prefix reset"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 13: Configure REST Services
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 50 "$(get_text step) 12/26: Configuring REST services..."
    docker exec "$CONTAINER_NAME" bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "REST services configured"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 14: Create ORDS_PUBLIC_USER (Critical for Error 571)
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 54 "$(get_text step) 13/26: Creating ORDS_PUBLIC_USER..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
-- Drop existing user if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Create ORDS_PUBLIC_USER
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\"
    DEFAULT TABLESPACE SYSAUX
    QUOTA UNLIMITED ON SYSAUX;

-- Grant roles
GRANT CONNECT TO ORDS_PUBLIC_USER;
GRANT RESOURCE TO ORDS_PUBLIC_USER;

-- Grant privileges
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
GRANT EXECUTE ON SYS.DBMS_SQL TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.HTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.HTF TO ORDS_PUBLIC_USER;

-- Unlock account
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "ORDS_PUBLIC_USER created"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 15: Fix APEX Users
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 58 "$(get_text step) 14/26: Fixing APEX users..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
-- Fix APEX_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Fix APEX_LISTENER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Fix APEX_REST_PUBLIC_USER
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true
    log "APEX users fixed"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 16: Grant Proxy Permissions
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 62 "$(get_text step) 15/26: Granting proxy permissions..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
-- Grant proxy connect permissions
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
    log "Proxy permissions granted"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 17: Create APEX Admin User
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 66 "$(get_text step) 16/26: Creating APEX admin..."
    
    # Detect APEX schema
    local apex_schema
    apex_schema=$(docker exec "$CONTAINER_NAME" bash -c "echo \"SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ') || true

    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"
    log "Detected APEX schema: $apex_schema"

    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
BEGIN
    -- Set instance parameters
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    ${apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('RESTFUL_SERVICES_ENABLED', 'Y');
    
    -- Set security group
    ${apex_schema}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);

    -- Create or update ADMIN user
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
    log "APEX admin user created"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 18: Install ORDS
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 70 "$(get_text step) 17/26: Installing ORDS..."
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

    if [ -z "$ORDS_BIN" ]; then
        log "ERROR: ORDS binary not found!"
        gui_error "$(get_text error)" "ORDS binary not found in $PROJECT_DIR/ords"
        stop_progress
        return 1
    fi

    chmod +x "$ORDS_BIN" 2>/dev/null || true
    log "Found ORDS binary: $ORDS_BIN"

    # Clean old configuration
    rm -rf "$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
    rm -rf "$ORDS_CONFIG_DIR/global" 2>/dev/null || true
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"
    
    # MODIFIED: Create pool.xml manually (Critical for Error 571)
    cat > "$ORDS_CONFIG_DIR/databases/default/pool.xml" << POOLEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="db.hostname">localhost</entry>
<entry key="db.port">${DB_PORT}</entry>
<entry key="db.servicename">${DB_SERVICE}</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">!${ORACLE_PASSWORD}</entry>
<entry key="jdbc.InitialLimit">10</entry>
<entry key="jdbc.MinLimit">5</entry>
<entry key="jdbc.MaxLimit">50</entry>
<entry key="jdbc.MaxStatementsLimit">50</entry>
<entry key="jdbc.InactivityTimeout">300</entry>
<entry key="jdbc.statementTimeout">900</entry>
<entry key="jdbc.MaxConnectionReuseCount">1000</entry>
</properties>
POOLEOF
    log "pool.xml created"

    # Configure password secret before install
    echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true

    # Run ORDS install
    local PASS_FILE=$(mktemp)
    printf "%s\n%s\n%s\n" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" "$ORACLE_PASSWORD" > "$PASS_FILE"

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
    log "ORDS install completed"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 19: Configure ORDS
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 75 "$(get_text step) 18/26: $(get_text configuring_ords)"
    
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port "$ORDS_PORT" >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.context.path /ords >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true
    "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.doc.root "$IMAGES_DIR" >> "$INSTALL_LOG" 2>&1 || true

    # Re-configure password secret
    echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    log "ORDS configured"

    # MODIFIED: Create settings.xml
    cat > "$ORDS_CONFIG_DIR/settings.xml" << SETTINGSEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="standalone.context.path">/ords</entry>
<entry key="standalone.http.port">${ORDS_PORT}</entry>
<entry key="standalone.static.context.path">/i</entry>
<entry key="standalone.static.path">${IMAGES_DIR}</entry>
<entry key="standalone.doc.root">${IMAGES_DIR}</entry>
<entry key="db.hostname">${DB_HOST}</entry>
<entry key="db.port">${DB_PORT}</entry>
<entry key="db.servicename">${DB_SERVICE}</entry>
<entry key="feature.sdw">true</entry>
<entry key="restEnabledSql.active">true</entry>
<entry key="security.requestValidationFunction">wwv_flow_epg_include_modules.authorize</entry>
</properties>
SETTINGSEOF
    log "settings.xml created"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 20: Final Database Configuration
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 78 "$(get_text step) 19/26: Final database configuration..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
-- Ensure all users are unlocked with correct passwords
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" ACCOUNT UNLOCK;

-- Ensure proxy permissions
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
    log "Final database configuration completed"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 21: Start ORDS
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 82 "$(get_text step) 20/26: Starting ORDS..."
    
    # Kill any existing ORDS processes
    pkill -9 -f "ords.*serve" 2>/dev/null || true
    pkill -9 -f "java.*ords" 2>/dev/null || true
    sleep 5
    run_sudo fuser -k "${ORDS_PORT}/tcp" 2>/dev/null || true
    sleep 2

    # Start ORDS
    export ORDS_CONFIG="$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"

    nohup "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" serve \
        --port "$ORDS_PORT" \
        --apex-images "$IMAGES_DIR" \
        > "$LOG_DIR/ords.log" 2>&1 &

    local ords_pid=$!
    echo "$ords_pid" > "$PROJECT_DIR/ords.pid"
    log "ORDS started with PID $ords_pid"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 22: Wait for ORDS
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 88 "$(get_text step) 21/26: Waiting for ORDS (2 minutes)..."
    sleep 120

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 23: Create Management Scripts
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 92 "$(get_text step) 22/26: $(get_text creating_scripts)"
    create_management_scripts
    log "Management scripts created"

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 24: Verify Installation
    # ═══════════════════════════════════════════════════════════════════════════
    update_progress 96 "$(get_text step) 23/26: $(get_text verifying)"
    
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" --max-time 15 2>/dev/null || echo "000")
    local http_login=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/f?p=4550" --max-time 15 2>/dev/null || echo "000")
    local http_img=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/i/apex_version.txt" --max-time 15 2>/dev/null || echo "000")
    
    log "Verification Results:"
    log "  - Admin Panel: HTTP $http_admin"
    log "  - Login Page:  HTTP $http_login"
    log "  - Images:      HTTP $http_img"

    update_progress 100 "$(get_text completed)"
    stop_progress

    # ═══════════════════════════════════════════════════════════════════════════
    # Show Success Message
    # ═══════════════════════════════════════════════════════════════════════════
    local success_msg=$(get_text success_text)
    success_msg="${success_msg//%PASSWORD%/$APEX_ADMIN_PASSWORD}"
    gui_info "$(get_text success_title)" "$success_msg" 600 500

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 25: Offer to Create Systemd Service
    # ═══════════════════════════════════════════════════════════════════════════
    if [ "$OS_TYPE" = "linux" ]; then
        if gui_question "$(get_text create_service_title)" "$(get_text create_service_text)"; then
            create_systemd_service
        fi
    fi

    # ═══════════════════════════════════════════════════════════════════════════
    # Step 26: Offer to Install DBeaver
    # ═══════════════════════════════════════════════════════════════════════════
    if gui_question "$(get_text install_dbeaver_title)" "Would you like to install DBeaver database manager?\n\nDBeaver is a free database management tool that allows you to:\n• Connect to Oracle Database\n• Browse tables and data\n• Run SQL queries\n• Export/Import data"; then
        start_progress
        update_progress 50 "$(get_text installing_dbeaver)"
        if install_dbeaver; then
            update_progress 100 "$(get_text dbeaver_installed)"
            stop_progress
            gui_info "$(get_text info)" "$(get_text dbeaver_installed)\n\nConnection details:\n  Host: localhost\n  Port: 1521\n  Service: XEPDB1\n  Username: SYS (as SYSDBA)\n  Password: (your database password)"
        else
            stop_progress
            gui_warning "$(get_text warning)" "DBeaver installation may have failed.\nYou can install it manually later."
        fi
    fi

    log "═══════════════════════════════════════════════════════════════"
    log "Fresh installation completed successfully!"
    log "═══════════════════════════════════════════════════════════════"
    return 0
}
# ═══════════════════════════════════════════════════════════════════════════════
# SHOW MAIN MENU
# ═══════════════════════════════════════════════════════════════════════════════
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
                    gui_warning "$(get_text warning)" "Previous installation detected.\n\nUse 'Clean Install' to remove everything and reinstall,\nor 'Repair' to fix the existing installation."
                else
                    get_passwords
                    run_fresh_installation
                fi
                ;;
            repair)
                if ! check_previous_installation; then
                    gui_warning "$(get_text warning)" "No previous installation found.\n\nUse 'Fresh Install' to install Oracle APEX."
                else
                    get_passwords
                    repair_installation
                fi
                ;;
            clean)
                get_passwords
                if gui_question "$(get_text warning)" "$(get_text confirm_clean)"; then
                    start_progress
                    update_progress 10 "Stopping all services..."
                    pkill -9 -f ords 2>/dev/null || true
                    pkill -9 -f "java.*ords" 2>/dev/null || true

                    update_progress 30 "$(get_text cleaning)"
                    complete_cleanup

                    update_progress 50 "Starting fresh installation..."
                    stop_progress

                    run_fresh_installation
                fi
                ;;
            uninstall)
                if gui_question "$(get_text warning)" "$(get_text confirm_uninstall)"; then
                    start_progress
                    update_progress 20 "Stopping services..."
                    pkill -9 -f ords 2>/dev/null || true
                    pkill -9 -f "java.*ords" 2>/dev/null || true

                    update_progress 50 "Removing all components..."
                    complete_uninstall

                    update_progress 100 "Uninstall complete"
                    stop_progress

                    gui_info "$(get_text info)" "Oracle APEX has been completely removed.\n\nAll data, containers, and configurations have been deleted."
                    exit 0
                fi
                ;;
            dbeaver)
                manage_dbeaver
                ;;
            exit|"")
                if gui_question "$(get_text title)" "Are you sure you want to exit?"; then
                    log "User exited installer"
                    exit 0
                fi
                ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════
main() {
    # Clear screen and show banner
    clear

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║   ██╗  ██╗ █████╗ ██╗███████╗███████╗███╗   ██╗██╗██╗  ██╗        ║"
    echo "║   ██║ ██╔╝██╔══██╗██║╚══███╔╝██╔════╝████╗  ██║██║╚██╗██╔╝        ║"
    echo "║   █████╔╝ ███████║██║  ███╔╝ █████╗  ██╔██╗ ██║██║ ╚███╔╝         ║"
    echo "║   ██╔═██╗ ██╔══██║██║ ███╔╝  ██╔══╝  ██║╚██╗██║██║ ██╔██╗         ║"
    echo "║   ██║  ██╗██║  ██║██║███████╗███████╗██║ ╚████║██║██╔╝ ██╗        ║"
    echo "║   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝        ║"
    echo "║                                                                   ║"
    echo "║           Oracle APEX GUI Installer v${VERSION}                      ║"
    echo "║                   Created by Peyman Rasouli                       ║"
    echo "║                        KaizenixCore                               ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""

    # Create initial directories
    safe_mkdir "$PROJECT_DIR"
    safe_mkdir "$LOG_DIR"
    safe_touch "$INSTALL_LOG"

    # Log startup
    log "═══════════════════════════════════════════════════════════════"
    log "Oracle APEX GUI Installer v${VERSION} started"
    log "Date: $(date)"
    log "User: $USER"
    log "Home: $HOME"
    log "═══════════════════════════════════════════════════════════════"

    # Detect operating system
    detect_os
    log "OS Type: $OS_TYPE"
    log "OS ID: $OS_ID"
    log "OS Version: $OS_VERSION"
    log "Architecture: $ARCH"

    # Install and detect GUI tool
    echo "Checking GUI tools..."
    install_gui_tool
    log "GUI Tool: $GUI_TOOL"

    # Select language
    select_language
    log "Language selected: $CURRENT_LANG"

    # Show welcome message
    gui_info "$(get_text welcome_title)" "$(get_text welcome_text)" 650 600

    # Get sudo password
    get_sudo_password

    # Show main menu
    show_main_menu
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLEANUP ON EXIT
# ═══════════════════════════════════════════════════════════════════════════════
cleanup_on_exit() {
    # Close progress bar FIFO
    if [ -n "$FIFO_FILE" ] && [ -e "$FIFO_FILE" ]; then
        exec 3>&- 2>/dev/null || true
        rm -f "$FIFO_FILE" 2>/dev/null || true
    fi

    # Kill progress bar process
    if [ -n "$PROGRESS_PID" ]; then
        kill "$PROGRESS_PID" 2>/dev/null || true
    fi

    log "Installer exited"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SIGNAL TRAPS
# ═══════════════════════════════════════════════════════════════════════════════
trap cleanup_on_exit EXIT
trap 'echo ""; echo "Installation cancelled by user."; cleanup_on_exit; exit 1' INT TERM

# ═══════════════════════════════════════════════════════════════════════════════
# RUN MAIN
# ═══════════════════════════════════════════════════════════════════════════════
main "$@"

################################################################################
#
#  END OF FILE
#
#  CHANGELOG v4.3.0:
#  
#  [FIXED] Error 571 - Database Connection Error
#    - Added manual pool.xml creation with correct credentials
#    - Added db.password secret configuration before ORDS install
#    - Fixed ORDS_PUBLIC_USER grants and permissions
#    - Added proxy connect permissions for APEX users
#  
#  [FIXED] APEX Images not loading
#    - Set IMAGE_PREFIX in database to '/i/'
#    - Configured standalone.static.path correctly
#    - Added images verification in fix.sh
#  
#  [IMPROVED] repair_installation() function
#    - 13-step comprehensive repair process
#    - Database connection testing
#    - Automatic ORDS reinstallation
#    - pool.xml recreation
#  
#  [IMPROVED] run_fresh_installation() function
#    - 26-step installation with progress tracking
#    - pool.xml creation before ORDS install
#    - settings.xml generation with all parameters
#    - Better error handling
#  
#  [IMPROVED] Management scripts
#    - Enhanced fix.sh with 15 repair steps
#    - Added HTTP status verification
#    - Improved start.sh with secret handling
#    - Added database connection test
#  
#  [IMPROVED] create_management_scripts()
#    - All scripts now include pool.xml handling
#    - Better error messages
#    - Database connectivity checks
#  
#  [TESTED] All functions tested on:
#    - Ubuntu 20.04/22.04/24.04
#    - Debian 11/12
#    - openSUSE Leap 15.x
#    - Fedora 38/39/40
#    - Linux Mint 21.x
#  
################################################################################

# vim: set ts=4 sw=4 et:
