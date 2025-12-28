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

    cat > "$SCRIPTS_DIR/stop.sh" << STOPEOF
#!/bin/bash
echo "Stopping Oracle APEX services..."
pkill -9 -f "ords.*serve" 2>/dev/null || true
pkill -9 -f "java.*ords" 2>/dev/null || true
docker stop ${CONTAINER_NAME} 2>/dev/null || true
echo "Services stopped."
STOPEOF
    chmod +x "$SCRIPTS_DIR/stop.sh"

    cat > "$SCRIPTS_DIR/status.sh" << STATUSEOF
#!/bin/bash
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Oracle APEX Status - KaizenixCore v${VERSION}"
echo "════════════════════════════════════════════════════════════════"
echo ""
if docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME} 2>/dev/null | grep -q "true"; then
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
HTTP=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${ORDS_PORT}/ords/apex_admin 2>/dev/null || echo "000")
echo "  APEX Admin: HTTP \$HTTP"
echo ""
echo "  URLs:"
echo "    Admin: http://localhost:${ORDS_PORT}/ords/apex_admin"
echo "    Login: http://localhost:${ORDS_PORT}/ords/f?p=4550"
echo ""
echo "════════════════════════════════════════════════════════════════"
STATUSEOF
    chmod +x "$SCRIPTS_DIR/status.sh"

    cat > "$SCRIPTS_DIR/start.sh" << STARTEOF
#!/bin/bash
PROJECT_DIR="${PROJECT_DIR}"
ORDS_CONFIG_DIR="${ORDS_CONFIG_DIR}"
IMAGES_DIR="${IMAGES_DIR}"
LOG_DIR="${LOG_DIR}"
ORDS_PORT="${ORDS_PORT}"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Starting Oracle APEX - KaizenixCore v${VERSION}"
echo "════════════════════════════════════════════════════════════════"
echo ""

PASS=\$(cat "\$PROJECT_DIR/.db_password" 2>/dev/null)
if [ -z "\$PASS" ]; then
    echo "❌ Password file not found!"
    exit 1
fi

echo "[1/4] Starting database..."
docker start ${CONTAINER_NAME} 2>/dev/null || true
echo "      Waiting 2 minutes for database..."
sleep 120

echo "[2/4] Stopping old ORDS..."
pkill -9 -f ords 2>/dev/null || true
sleep 5

echo "[3/4] Starting ORDS..."
ORDS_BIN=\$(find "\$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "\$ORDS_BIN" ]; then
    echo "\$PASS" | "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
    export ORDS_CONFIG="\$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" serve --port \$ORDS_PORT --apex-images "\$IMAGES_DIR" > "\$LOG_DIR/ords.log" 2>&1 &
    echo "      ORDS started with PID \$!"
fi

echo "[4/4] Waiting for ORDS (2 minutes)..."
sleep 120

echo ""
HTTP=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:\$ORDS_PORT/ords/apex_admin 2>/dev/null || echo "000")
echo "════════════════════════════════════════════════════════════════"
echo "  APEX Admin: HTTP \$HTTP"
echo "  URL: http://localhost:\$ORDS_PORT/ords/apex_admin"
echo "════════════════════════════════════════════════════════════════"

if [[ "\$HTTP" =~ ^(200|302|303)\$ ]]; then
    echo "  ✅ APEX is ready!"
else
    echo "  ⚠️ APEX may need more time. Wait 2 minutes and try again."
    echo "     Or run: bash \$PROJECT_DIR/scripts/fix.sh"
fi
echo ""
STARTEOF
    chmod +x "$SCRIPTS_DIR/start.sh"

    cat > "$SCRIPTS_DIR/fix.sh" << FIXEOF
#!/bin/bash
PROJECT_DIR="${PROJECT_DIR}"
ORDS_CONFIG_DIR="${ORDS_CONFIG_DIR}"
IMAGES_DIR="${IMAGES_DIR}"
LOG_DIR="${LOG_DIR}"
DB_PORT="${DB_PORT}"
DB_SERVICE="${DB_SERVICE}"
ORDS_PORT="${ORDS_PORT}"

PASS=\$(cat "\$PROJECT_DIR/.db_password" 2>/dev/null)

if [ -z "\$PASS" ]; then
    echo "❌ Password file not found!"
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  FIX SCRIPT v4.3 - Fixing All Issues"
echo "  Errors: 574, 571, 500, Images"
echo "════════════════════════════════════════════════════════════════"
echo ""

echo "[1/12] Stopping ORDS..."
pkill -9 -f ords 2>/dev/null || true
pkill -9 -f java.*ords 2>/dev/null || true
sleep 5

echo "[2/12] Starting database..."
docker start ${CONTAINER_NAME} 2>/dev/null || true
echo "      Waiting 2 minutes for database..."
sleep 120

echo "[3/12] Resetting database password..."
docker exec ${CONTAINER_NAME} resetPassword "\$PASS" 2>/dev/null || true
sleep 20

echo "[4/12] Disabling password policies..."
docker exec ${CONTAINER_NAME} bash -c "sqlplus -s sys/\${PASS}@//localhost:\${DB_PORT}/\${DB_SERVICE} as sysdba << 'SQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[5/12] Recreating ORDS_PUBLIC_USER..."
docker exec ${CONTAINER_NAME} bash -c "sqlplus -s sys/\${PASS}@//localhost:\${DB_PORT}/\${DB_SERVICE} as sysdba << SQL
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \${PASS} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE, CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[6/12] Fixing APEX users..."
docker exec ${CONTAINER_NAME} bash -c "sqlplus -s sys/\${PASS}@//localhost:\${DB_PORT}/\${DB_SERVICE} as sysdba << SQL
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY \${PASS} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
COMMIT;
EXIT;
SQL" 2>/dev/null || true

echo "[7/12] Granting proxy permissions..."
docker exec ${CONTAINER_NAME} bash -c "sqlplus -s sys/\${PASS}@//localhost:\${DB_PORT}/\${DB_SERVICE} as sysdba << 'SQL'
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
ORDS_BIN=\$(find "\$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)
if [ -n "\$ORDS_BIN" ]; then
    chmod +x "\$ORDS_BIN" 2>/dev/null || true
    rm -rf "\$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
    mkdir -p "\$ORDS_CONFIG_DIR/databases/default"
    printf "%s\n%s\n%s\n" "\$PASS" "\$PASS" "\$PASS" | "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" install \
        --admin-user SYS \
        --db-hostname localhost \
        --db-port \$DB_PORT \
        --db-servicename \$DB_SERVICE \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user ORDS_PUBLIC_USER \
        --password-stdin 2>/dev/null || true
    echo "\$PASS" | "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
fi

echo "[9/12] Fixing APEX images..."
rm -rf "\$IMAGES_DIR" 2>/dev/null || true
if [ -d "\$PROJECT_DIR/apex/images" ]; then
    cp -r "\$PROJECT_DIR/apex/images" "\$IMAGES_DIR"
    chmod -R 755 "\$IMAGES_DIR"
fi
if [ -n "\$ORDS_BIN" ]; then
    "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" config set standalone.static.path "\$IMAGES_DIR" 2>/dev/null || true
    "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" config set standalone.static.context.path /i 2>/dev/null || true
    "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" config set standalone.doc.root "\$IMAGES_DIR" 2>/dev/null || true
fi

echo "[10/12] Setting IMAGE_PREFIX in database..."
APEX_SCHEMA=\$(cat "\$PROJECT_DIR/.apex_schema" 2>/dev/null)
[ -z "\$APEX_SCHEMA" ] && APEX_SCHEMA="APEX_240100"
docker exec ${CONTAINER_NAME} bash -c "sqlplus -s sys/\${PASS}@//localhost:\${DB_PORT}/\${DB_SERVICE} as sysdba << SQLEOF
BEGIN
    \${APEX_SCHEMA}.APEX_INSTANCE_ADMIN.SET_PARAMETER('IMAGE_PREFIX', '/i/');
    \${APEX_SCHEMA}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
EXIT;
SQLEOF" 2>/dev/null || true

echo "[11/12] Starting ORDS with images..."
if [ -n "\$ORDS_BIN" ]; then
    export ORDS_CONFIG="\$ORDS_CONFIG_DIR"
    export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
    nohup "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" serve --port \$ORDS_PORT --apex-images "\$IMAGES_DIR" > "\$LOG_DIR/ords.log" 2>&1 &
    echo "      ORDS started with PID \$!"
fi

echo "[12/12] Waiting for ORDS (2 minutes)..."
sleep 120

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  VERIFICATION"
echo "════════════════════════════════════════════════════════════════"
HTTP_ADMIN=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:\$ORDS_PORT/ords/apex_admin 2>/dev/null || echo "000")
HTTP_LOGIN=\$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:\$ORDS_PORT/ords/f?p=4550" 2>/dev/null || echo "000")
HTTP_IMG=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:\$ORDS_PORT/i/apex_version.txt 2>/dev/null || echo "000")
echo "  APEX Admin:  HTTP \$HTTP_ADMIN"
echo "  APEX Login:  HTTP \$HTTP_LOGIN"
echo "  Images:      HTTP \$HTTP_IMG"
echo ""
if [[ "\$HTTP_ADMIN" =~ ^(200|302|303)\$ ]] && [[ "\$HTTP_IMG" =~ ^(200|304)\$ ]]; then
    echo "  ✅ SUCCESS! APEX is working with images!"
    echo ""
    echo "  Open in browser:"
    echo "    http://localhost:\$ORDS_PORT/ords/apex_admin"
    echo "    http://localhost:\$ORDS_PORT/ords/f?p=4550"
elif [[ "\$HTTP_ADMIN" =~ ^(200|302|303)\$ ]]; then
    echo "  ⚠️ APEX is working but images may have issues."
else
    echo "  ⚠️ Some issues remain. Check logs:"
    echo "    tail -100 \$LOG_DIR/ords.log"
fi
echo ""
echo "════════════════════════════════════════════════════════════════"
FIXEOF
    chmod +x "$SCRIPTS_DIR/fix.sh"

    cat > "$SCRIPTS_DIR/logs.sh" << LOGSEOF
#!/bin/bash
PROJECT_DIR="${PROJECT_DIR}"
echo "Showing last 100 lines of ORDS log..."
echo "Press Ctrl+C to exit"
echo ""
tail -f "\$PROJECT_DIR/logs/ords.log" 2>/dev/null || echo "Log file not found"
LOGSEOF
    chmod +x "$SCRIPTS_DIR/logs.sh"

    cat > "$SCRIPTS_DIR/reset-apex-password.sh" << RESETEOF
#!/bin/bash
PROJECT_DIR="${PROJECT_DIR}"
DB_PORT="${DB_PORT}"
DB_SERVICE="${DB_SERVICE}"

PASS=\$(cat "\$PROJECT_DIR/.db_password" 2>/dev/null)
APEX_SCHEMA=\$(cat "\$PROJECT_DIR/.apex_schema" 2>/dev/null)
[ -z "\$APEX_SCHEMA" ] && APEX_SCHEMA="APEX_240100"

if [ -z "\$PASS" ]; then
    echo "❌ Password file not found!"
    exit 1
fi

echo "Enter new APEX Admin password:"
read -s NEW_PASS

if [[ ! "\$NEW_PASS" =~ ^[a-zA-Z][a-zA-Z0-9]{5,}\$ ]]; then
    echo "❌ Invalid password! Must start with letter, only letters/numbers, min 6 chars"
    exit 1
fi

docker exec ${CONTAINER_NAME} bash -c "sqlplus -s sys/\${PASS}@//localhost:\${DB_PORT}/\${DB_SERVICE} as sysdba << SQLEOF
BEGIN
    \${APEX_SCHEMA}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    \${APEX_SCHEMA}.APEX_UTIL.EDIT_USER(
        p_user_id                      => \${APEX_SCHEMA}.APEX_UTIL.GET_USER_ID('ADMIN'),
        p_user_name                    => 'ADMIN',
        p_web_password                 => '\${NEW_PASS}',
        p_new_password                 => '\${NEW_PASS}',
        p_change_password_on_first_use => 'N',
        p_account_locked               => 'N'
    );
    COMMIT;
END;
/
EXIT;
SQLEOF"

echo "\$NEW_PASS" > "\$PROJECT_DIR/.apex_password"
chmod 600 "\$PROJECT_DIR/.apex_password"
echo "✅ APEX Admin password reset successfully!"
RESETEOF
    chmod +x "$SCRIPTS_DIR/reset-apex-password.sh"
    cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ORDS_PORT="8080"

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
        yad --list --title="Oracle APEX Manager - KaizenixCore v4.3" \
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
            FALSE "reset_pass" "🔑  Reset APEX Password" \
            FALSE "exit" "❌  Exit" \
            --width=500 --height=550 --center \
            --button="Cancel:1" --button="OK:0" \
            --print-column=2 --hide-column=2 \
            --borders=15 2>/dev/null
    else
        zenity --list --title="Oracle APEX Manager - KaizenixCore v4.3" \
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
            FALSE "reset_pass" "🔑  Reset APEX Password" \
            FALSE "exit" "❌  Exit" \
            --width=500 --height=550 \
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

    cat > "$SCRIPTS_DIR/open-dbeaver.sh" << 'DBEAVEREOF'
#!/bin/bash
echo "Opening DBeaver..."
echo ""
echo "Connection details for Oracle APEX database:"
echo "  Host:     localhost"
echo "  Port:     1521"
echo "  Database: XEPDB1"
echo "  Username: SYS (as SYSDBA)"
echo "  Password: (your database password)"
echo ""

if command -v dbeaver-ce &> /dev/null; then
    dbeaver-ce &
elif command -v dbeaver &> /dev/null; then
    dbeaver &
elif command -v flatpak &> /dev/null && flatpak list | grep -q dbeaver; then
    flatpak run io.dbeaver.DBeaverCommunity &
elif command -v snap &> /dev/null && snap list | grep -q dbeaver; then
    snap run dbeaver-ce &
else
    echo "DBeaver not found. Please install it first."
    exit 1
fi
DBEAVEREOF
    chmod +x "$SCRIPTS_DIR/open-dbeaver.sh"

    safe_mkdir "$HOME/.local/share/applications"
    safe_mkdir "$HOME/.local/share/icons"

    cat > "$PROJECT_DIR/oracle-apex-icon.svg" << 'SVGEOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF4444;stop-opacity:1"/>
      <stop offset="100%" style="stop-color:#CC0000;stop-opacity:1"/>
    </linearGradient>
  </defs>
  <rect x="20" y="20" width="216" height="216" rx="40" fill="url(#grad1)"/>
  <text x="128" y="105" font-family="Arial Black, sans-serif" font-size="52" font-weight="bold" fill="white" text-anchor="middle">APEX</text>
  <text x="128" y="155" font-family="Arial, sans-serif" font-size="28" font-weight="600" fill="rgba(255,255,255,0.95)" text-anchor="middle">Manager</text>
  <text x="128" y="195" font-family="Arial, sans-serif" font-size="18" fill="rgba(255,255,255,0.75)" text-anchor="middle">KaizenixCore</text>
</svg>
SVGEOF

    cp "$PROJECT_DIR/oracle-apex-icon.svg" "$HOME/.local/share/icons/" 2>/dev/null || true

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
Keywords=oracle;apex;ords;database;
StartupNotify=true
DESKTOPEOF
    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"

    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true

    log "Management scripts created"
}

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

    cat > "$SCRIPTS_DIR/oracle-apex-service.sh" << SERVICEEOF
#!/bin/bash
PROJECT_DIR="${PROJECT_DIR}"
ORDS_CONFIG_DIR="${ORDS_CONFIG_DIR}"
ORDS_BIN="${ORDS_BIN}"
IMAGES_DIR="${IMAGES_DIR}"
LOG_DIR="${LOG_DIR}"
ORDS_PORT="${ORDS_PORT}"
DB_PORT="${DB_PORT}"
DB_SERVICE="${DB_SERVICE}"

case "\$1" in
    start)
        echo "Starting Oracle APEX services..."
        docker start ${CONTAINER_NAME} 2>/dev/null
        sleep 120

        PASS=\$(cat "\$PROJECT_DIR/.db_password" 2>/dev/null)
        if [ -n "\$PASS" ]; then
            echo "\$PASS" | "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
        fi

        export ORDS_CONFIG="\$ORDS_CONFIG_DIR"
        export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
        nohup "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" serve \
            --port \$ORDS_PORT \
            --apex-images "\$IMAGES_DIR" \
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
        docker stop ${CONTAINER_NAME} 2>/dev/null
        echo "Oracle APEX stopped"
        ;;
    restart)
        \$0 stop
        sleep 5
        \$0 start
        ;;
    status)
        if docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME} 2>/dev/null | grep -q "true"; then
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

repair_installation() {
    log "REPAIR INSTALLATION - COMPREHENSIVE FIX FOR ERROR 571"

    if [ -z "$ORACLE_PASSWORD" ] || [ -z "$APEX_ADMIN_PASSWORD" ]; then
        log "Passwords not set!"
        gui_error "$(get_text error)" "Passwords not configured."
        return 1
    fi

    start_progress

    update_progress 5 "Stopping ORDS..."
    pkill -9 -f "ords.*serve" 2>/dev/null || true
    pkill -9 -f "java.*ords" 2>/dev/null || true
    sleep 5

    update_progress 10 "Starting database..."
    docker start "$CONTAINER_NAME" 2>/dev/null || true
    sleep 10

    update_progress 15 "Waiting for database..."
    local db_ready=false
    for i in {1..120}; do
        if docker logs "$CONTAINER_NAME" 2>&1 | grep -q "DATABASE IS READY"; then
            db_ready=true
            break
        fi
        sleep 5
    done
    sleep 30

    update_progress 25 "$(get_text resetting_password)"
    docker exec "$CONTAINER_NAME" resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 20

    update_progress 30 "Disabling password policies..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 40 "Fixing ORDS_PUBLIC_USER..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE, CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 50 "Fixing APEX users..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 55 "Resetting APEX admin password..."
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

    update_progress 65 "Reinstalling ORDS connection..."
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

    if [ -n "$ORDS_BIN" ] && [ -x "$ORDS_BIN" ]; then
        rm -rf "$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
        mkdir -p "$ORDS_CONFIG_DIR/databases/default"

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

        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    fi

    update_progress 75 "$(get_text fixing_images)"
    fix_apex_images

    update_progress 80 "Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"

    update_progress 85 "Starting ORDS..."
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

    update_progress 95 "Waiting for ORDS..."
    sleep 120

    update_progress 100 "$(get_text verifying)"

    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null || echo "000")
    log "Verification - Admin: HTTP $http_admin"

    stop_progress

    if [[ "$http_admin" =~ ^(200|302|303)$ ]]; then
        log "REPAIR SUCCESSFUL!"
        gui_info "$(get_text success_title)" \
            "✅ Repair Completed Successfully!\n\n🌐 Admin Panel:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\n🔐 Login Page:\nhttp://localhost:${ORDS_PORT}/ords/f?p=4550\n\n📋 Credentials:\nUsername: ADMIN\nPassword: (your password)" 600 400
        return 0
    else
        log "Repair completed but APEX may need more time"
        gui_warning "$(get_text warning)" \
            "⚠️ Repair completed but APEX is still initializing.\n\nPlease wait 2-3 minutes and try:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\nIf still having issues, run:\nbash ~/oracle-apex-complete/scripts/fix.sh" 600 400
        return 0
    fi
}
cat > "$SCRIPTS_DIR/launch-gui.sh" << 'GUIEOF'
#!/bin/bash
PROJECT_DIR="$HOME/oracle-apex-complete"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ORDS_PORT="8080"

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
        yad --list --title="Oracle APEX Manager - KaizenixCore v4.3" \
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
            FALSE "reset_pass" "🔑  Reset APEX Password" \
            FALSE "exit" "❌  Exit" \
            --width=500 --height=550 --center \
            --button="Cancel:1" --button="OK:0" \
            --print-column=2 --hide-column=2 \
            --borders=15 2>/dev/null
    else
        zenity --list --title="Oracle APEX Manager - KaizenixCore v4.3" \
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
            FALSE "reset_pass" "🔑  Reset APEX Password" \
            FALSE "exit" "❌  Exit" \
            --width=500 --height=550 \
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

    cat > "$SCRIPTS_DIR/open-dbeaver.sh" << 'DBEAVEREOF'
#!/bin/bash
echo "Opening DBeaver..."
echo ""
echo "Connection details for Oracle APEX database:"
echo "  Host:     localhost"
echo "  Port:     1521"
echo "  Database: XEPDB1"
echo "  Username: SYS (as SYSDBA)"
echo "  Password: (your database password)"
echo ""

if command -v dbeaver-ce &> /dev/null; then
    dbeaver-ce &
elif command -v dbeaver &> /dev/null; then
    dbeaver &
elif command -v flatpak &> /dev/null && flatpak list | grep -q dbeaver; then
    flatpak run io.dbeaver.DBeaverCommunity &
elif command -v snap &> /dev/null && snap list | grep -q dbeaver; then
    snap run dbeaver-ce &
else
    echo "DBeaver not found. Please install it first."
    exit 1
fi
DBEAVEREOF
    chmod +x "$SCRIPTS_DIR/open-dbeaver.sh"

    safe_mkdir "$HOME/.local/share/applications"
    safe_mkdir "$HOME/.local/share/icons"

    cat > "$PROJECT_DIR/oracle-apex-icon.svg" << 'SVGEOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF4444;stop-opacity:1"/>
      <stop offset="100%" style="stop-color:#CC0000;stop-opacity:1"/>
    </linearGradient>
  </defs>
  <rect x="20" y="20" width="216" height="216" rx="40" fill="url(#grad1)"/>
  <text x="128" y="105" font-family="Arial Black, sans-serif" font-size="52" font-weight="bold" fill="white" text-anchor="middle">APEX</text>
  <text x="128" y="155" font-family="Arial, sans-serif" font-size="28" font-weight="600" fill="rgba(255,255,255,0.95)" text-anchor="middle">Manager</text>
  <text x="128" y="195" font-family="Arial, sans-serif" font-size="18" fill="rgba(255,255,255,0.75)" text-anchor="middle">KaizenixCore</text>
</svg>
SVGEOF

    cp "$PROJECT_DIR/oracle-apex-icon.svg" "$HOME/.local/share/icons/" 2>/dev/null || true

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
Keywords=oracle;apex;ords;database;
StartupNotify=true
DESKTOPEOF
    chmod +x "$HOME/.local/share/applications/oracle-apex.desktop"

    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true

    log "Management scripts created"


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

    cat > "$SCRIPTS_DIR/oracle-apex-service.sh" << SERVICEEOF
#!/bin/bash
PROJECT_DIR="${PROJECT_DIR}"
ORDS_CONFIG_DIR="${ORDS_CONFIG_DIR}"
ORDS_BIN="${ORDS_BIN}"
IMAGES_DIR="${IMAGES_DIR}"
LOG_DIR="${LOG_DIR}"
ORDS_PORT="${ORDS_PORT}"
DB_PORT="${DB_PORT}"
DB_SERVICE="${DB_SERVICE}"

case "\$1" in
    start)
        echo "Starting Oracle APEX services..."
        docker start ${CONTAINER_NAME} 2>/dev/null
        sleep 120

        PASS=\$(cat "\$PROJECT_DIR/.db_password" 2>/dev/null)
        if [ -n "\$PASS" ]; then
            echo "\$PASS" | "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" config secret --password-stdin db.password 2>/dev/null || true
        fi

        export ORDS_CONFIG="\$ORDS_CONFIG_DIR"
        export _JAVA_OPTIONS="-Xms512m -Xmx1024m"
        nohup "\$ORDS_BIN" --config "\$ORDS_CONFIG_DIR" serve \
            --port \$ORDS_PORT \
            --apex-images "\$IMAGES_DIR" \
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
        docker stop ${CONTAINER_NAME} 2>/dev/null
        echo "Oracle APEX stopped"
        ;;
    restart)
        \$0 stop
        sleep 5
        \$0 start
        ;;
    status)
        if docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME} 2>/dev/null | grep -q "true"; then
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

repair_installation() {
    log "REPAIR INSTALLATION - COMPREHENSIVE FIX FOR ERROR 571"

    if [ -z "$ORACLE_PASSWORD" ] || [ -z "$APEX_ADMIN_PASSWORD" ]; then
        log "Passwords not set!"
        gui_error "$(get_text error)" "Passwords not configured."
        return 1
    fi

    start_progress

    update_progress 5 "Stopping ORDS..."
    pkill -9 -f "ords.*serve" 2>/dev/null || true
    pkill -9 -f "java.*ords" 2>/dev/null || true
    sleep 5

    update_progress 10 "Starting database..."
    docker start "$CONTAINER_NAME" 2>/dev/null || true
    sleep 10

    update_progress 15 "Waiting for database..."
    local db_ready=false
    for i in {1..120}; do
        if docker logs "$CONTAINER_NAME" 2>&1 | grep -q "DATABASE IS READY"; then
            db_ready=true
            break
        fi
        sleep 5
    done
    sleep 30

    update_progress 25 "$(get_text resetting_password)"
    docker exec "$CONTAINER_NAME" resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 20

    update_progress 30 "Disabling password policies..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 40 "Fixing ORDS_PUBLIC_USER..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE, CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 50 "Fixing APEX users..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORACLE_PASSWORD} ACCOUNT UNLOCK'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 55 "Resetting APEX admin password..."
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

    update_progress 65 "Reinstalling ORDS connection..."
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

    if [ -n "$ORDS_BIN" ] && [ -x "$ORDS_BIN" ]; then
        rm -rf "$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
        mkdir -p "$ORDS_CONFIG_DIR/databases/default"

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

        echo "$ORACLE_PASSWORD" | "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config secret --password-stdin db.password >> "$INSTALL_LOG" 2>&1 || true
    fi

    update_progress 75 "$(get_text fixing_images)"
    fix_apex_images

    update_progress 80 "Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"

    update_progress 85 "Starting ORDS..."
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

    update_progress 95 "Waiting for ORDS..."
    sleep 120

    update_progress 100 "$(get_text verifying)"

    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null || echo "000")
    log "Verification - Admin: HTTP $http_admin"

    stop_progress

    if [[ "$http_admin" =~ ^(200|302|303)$ ]]; then
        log "REPAIR SUCCESSFUL!"
        gui_info "$(get_text success_title)" \
            "✅ Repair Completed Successfully!\n\n🌐 Admin Panel:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\n🔐 Login Page:\nhttp://localhost:${ORDS_PORT}/ords/f?p=4550\n\n📋 Credentials:\nUsername: ADMIN\nPassword: (your password)" 600 400
        return 0
    else
        log "Repair completed but APEX may need more time"
        gui_warning "$(get_text warning)" \
            "⚠️ Repair completed but APEX is still initializing.\n\nPlease wait 2-3 minutes and try:\nhttp://localhost:${ORDS_PORT}/ords/apex_admin\n\nIf still having issues, run:\nbash ~/oracle-apex-complete/scripts/fix.sh" 600 400
        return 0
    fi
}
run_fresh_installation() {
    log "Starting fresh installation v${VERSION}..."

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

    update_progress 2 "$(get_text step) 1/26: Saving configuration..."
    echo "$ORACLE_PASSWORD" > "$PROJECT_DIR/.db_password"
    echo "$APEX_ADMIN_PASSWORD" > "$PROJECT_DIR/.apex_password"
    chmod 600 "$PROJECT_DIR/.db_password" "$PROJECT_DIR/.apex_password"

    update_progress 5 "$(get_text step) 2/26: $(get_text installing_deps)"
    install_dependencies

    update_progress 10 "$(get_text step) 3/26: $(get_text downloading) APEX..."
    if [ ! -f "$DOWNLOADS_DIR/apex-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || \
        curl -L -o "$DOWNLOADS_DIR/apex-latest.zip" "$APEX_URL" 2>/dev/null || true
    fi

    update_progress 15 "$(get_text step) 4/26: $(get_text downloading) ORDS..."
    if [ ! -f "$DOWNLOADS_DIR/ords-latest.zip" ]; then
        wget -q --show-progress -O "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || \
        curl -L -o "$DOWNLOADS_DIR/ords-latest.zip" "$ORDS_URL" 2>/dev/null || true
    fi

    update_progress 18 "$(get_text step) 5/26: $(get_text extracting)"
    cd "$PROJECT_DIR" || exit 1

    rm -rf apex ords 2>/dev/null || true
    unzip -q -o "$DOWNLOADS_DIR/apex-latest.zip" 2>/dev/null || true
    mkdir -p ords
    unzip -q -o "$DOWNLOADS_DIR/ords-latest.zip" -d ords 2>/dev/null || true

    find ords -name "ords" -type f -exec chmod +x {} \; 2>/dev/null || true

    rm -rf "$IMAGES_DIR" 2>/dev/null || true
    cp -r "$PROJECT_DIR/apex/images" "$IMAGES_DIR" 2>/dev/null || true
    chmod -R 755 "$IMAGES_DIR" 2>/dev/null || true

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

    update_progress 26 "$(get_text step) 7/26: $(get_text starting_db)"
    cd "$PROJECT_DIR" || exit 1
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || true

    update_progress 30 "Waiting for database (5-10 minutes)..."
    if ! wait_for_database_ready; then
        log "Warning: Database wait timed out, continuing..."
    fi
    sleep 60

    update_progress 35 "$(get_text step) 8/26: $(get_text resetting_password)"
    docker exec "$CONTAINER_NAME" resetPassword "$ORACLE_PASSWORD" >> "$INSTALL_LOG" 2>&1 || true
    sleep 30

    update_progress 38 "$(get_text step) 9/26: Disabling password policies..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 40 "$(get_text step) 10/26: $(get_text installing_apex)"
    docker exec "$CONTAINER_NAME" bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 48 "$(get_text step) 11/26: $(get_text fixing_images)"
    docker exec "$CONTAINER_NAME" bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
@utilities/reset_image_prefix.sql
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 50 "$(get_text step) 12/26: Configuring REST services..."
    docker exec "$CONTAINER_NAME" bash -c "cd /opt/oracle/apex && sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << EOSQL
@apex_rest_config.sql ${ORACLE_PASSWORD} ${ORACLE_PASSWORD}
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 54 "$(get_text step) 13/26: Creating ORDS_PUBLIC_USER..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY \"${ORACLE_PASSWORD}\" DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE TABLE, CREATE TRIGGER, CREATE VIEW, CREATE SYNONYM, CREATE TYPE TO ORDS_PUBLIC_USER;
GRANT UNLIMITED TABLESPACE TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_LOB TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_OUTPUT TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_HTTP TO ORDS_PUBLIC_USER;
GRANT EXECUTE ON SYS.UTL_RAW TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 58 "$(get_text step) 14/26: Fixing APEX users..."
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

    update_progress 62 "$(get_text step) 15/26: Granting proxy permissions..."
    docker exec "$CONTAINER_NAME" bash -c "sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba << 'EOSQL'
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOSQL" >> "$INSTALL_LOG" 2>&1 || true

    update_progress 66 "$(get_text step) 16/26: Creating APEX admin..."
    local apex_schema
    apex_schema=$(docker exec "$CONTAINER_NAME" bash -c "echo \"SET HEADING OFF FEEDBACK OFF PAGESIZE 0; SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;\" | sqlplus -s sys/${ORACLE_PASSWORD}@//localhost:${DB_PORT}/${DB_SERVICE} as sysdba" 2>/dev/null | grep -E "^APEX_" | head -1 | tr -d ' ') || true

    [ -z "$apex_schema" ] && apex_schema="APEX_240100"
    echo "$apex_schema" > "$PROJECT_DIR/.apex_schema"

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

    update_progress 70 "$(get_text step) 17/26: Installing ORDS..."
    local ORDS_BIN=$(find "$PROJECT_DIR/ords" -name "ords" -type f 2>/dev/null | head -1)

    if [ -z "$ORDS_BIN" ]; then
        log "ORDS binary not found!"
        gui_error "$(get_text error)" "ORDS binary not found"
        return 1
    fi

    chmod +x "$ORDS_BIN" 2>/dev/null || true

    rm -rf "$ORDS_CONFIG_DIR/databases" 2>/dev/null || true
    mkdir -p "$ORDS_CONFIG_DIR/databases/default"
    mkdir -p "$ORDS_CONFIG_DIR/global"

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

    update_progress 75 "$(get_text step) 18/26: $(get_text configuring_ords)"
    if [ -n "$ORDS_BIN" ]; then
        "$ORDS_BIN" --config "$ORDS_CONFIG_DIR" config set standalone.http.port "$ORDS_PORT" >> "$INSTALL_LOG" 2>&1 || true
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
<entry key="db.hostname">${DB_HOST}</entry>
<entry key="db.port">${DB_PORT}</entry>
<entry key="db.servicename">${DB_SERVICE}</entry>
<entry key="feature.sdw">true</entry>
<entry key="feature.rest.enabled.sql">true</entry>
<entry key="gateway.mode">proxied</entry>
<entry key="gateway.user">ORDS_PUBLIC_USER</entry>
</properties>
SETTINGSEOF

    update_progress 78 "$(get_text step) 19/26: Final database configuration..."
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

    update_progress 82 "$(get_text step) 20/26: Starting ORDS..."
    pkill -9 -f "ords.*serve" 2>/dev/null || true
    pkill -9 -f "java.*ords" 2>/dev/null || true
    sleep 5
    run_sudo fuser -k "${ORDS_PORT}/tcp" 2>/dev/null || true
    sleep 2

    if [ -n "$ORDS_BIN" ]; then
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

    update_progress 88 "$(get_text step) 21/26: Waiting for ORDS (2 minutes)..."
    sleep 120

    update_progress 92 "$(get_text step) 22/26: $(get_text creating_scripts)"
    create_management_scripts

    update_progress 96 "$(get_text step) 23/26: $(get_text verifying)"
    local http_admin=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/ords/apex_admin" 2>/dev/null || echo "000")
    local http_img=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${ORDS_PORT}/i/apex_version.txt" 2>/dev/null || echo "000")
    log "Verification - Admin: $http_admin, Images: $http_img"

    update_progress 100 "$(get_text completed)"
    stop_progress

    local success_msg=$(get_text success_text)
    success_msg="${success_msg//%PASSWORD%/$APEX_ADMIN_PASSWORD}"
    gui_info "$(get_text success_title)" "$success_msg" 600 500

    if [ "$OS_TYPE" = "linux" ]; then
        if gui_question "$(get_text create_service_title)" "$(get_text create_service_text)"; then
            create_systemd_service
        fi
    fi

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

    log "Fresh installation completed successfully!"
    return 0
}

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
                    exit 0
                fi
                ;;
        esac
    done
}

main() {
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
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""

    safe_mkdir "$PROJECT_DIR"
    safe_mkdir "$LOG_DIR"
    safe_touch "$INSTALL_LOG"

    log "═══════════════════════════════════════════════════════════════"
    log "Oracle APEX GUI Installer v${VERSION} started"
    log "Date: $(date)"
    log "User: $USER"
    log "Home: $HOME"
    log "═══════════════════════════════════════════════════════════════"

    detect_os
    log "OS Type: $OS_TYPE"
    log "OS ID: $OS_ID"
    log "OS Version: $OS_VERSION"
    log "Architecture: $ARCH"

    echo "Checking GUI tools..."
    install_gui_tool
    log "GUI Tool: $GUI_TOOL"

    select_language

    gui_info "$(get_text welcome_title)" "$(get_text welcome_text)" 650 600

    get_sudo_password

    show_main_menu
}

cleanup_on_exit() {
    if [ -n "$FIFO_FILE" ] && [ -e "$FIFO_FILE" ]; then
        exec 3>&- 2>/dev/null || true
        rm -f "$FIFO_FILE" 2>/dev/null || true
    fi

    if [ -n "$PROGRESS_PID" ]; then
        kill "$PROGRESS_PID" 2>/dev/null || true
    fi

    log "Installer exited"
}

trap cleanup_on_exit EXIT
trap 'echo ""; echo "Installation cancelled by user."; exit 1' INT TERM

main "$@"
