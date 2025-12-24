#!/bin/bash
################################################################################
#  DBeaver (CloudBeaver) Manager - KaizenixCore v3.0.0
#  Automatic Docker-based DBeaver installation for all platforms
################################################################################

PROJECT_DIR="$HOME/oracle-apex-complete"
DBEAVER_DIR="$PROJECT_DIR/dbeaver"
DBEAVER_PORT="8978"
DB_PASSWORD_FILE="$PROJECT_DIR/.db_password"

# رنگ‌ها
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC}  $*"; }
log_success() { echo -e "${GREEN}✓${NC}  $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $*"; }
log_error() { echo -e "${RED}✗${NC}  $*"; }

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALL DBEAVER (CLOUDBEAVER)
# ═══════════════════════════════════════════════════════════════════════════════
install_dbeaver() {
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  🐬 Installing DBeaver (CloudBeaver) via Docker"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    mkdir -p "$DBEAVER_DIR/workspace"

    # Create docker-compose for CloudBeaver
    log_info "Creating CloudBeaver configuration..."
    cat > "$DBEAVER_DIR/docker-compose.yml" << 'EOF'
version: '3.8'
services:
  cloudbeaver:
    image: dbeaver/cloudbeaver:latest
    container_name: oracle-apex-cloudbeaver
    restart: unless-stopped
    ports:
      - "8978:8978"
    volumes:
      - ./workspace:/opt/cloudbeaver/workspace
    environment:
      - CB_SERVER_NAME=KaizenixCore DBeaver
      - CB_SERVER_URL=http://localhost:8978
      - CB_ADMIN_NAME=admin
      - CB_ADMIN_PASSWORD=admin123
    networks:
      - apex-network

networks:
  apex-network:
    external: true
EOF

    # Create network if not exists
    log_info "Ensuring Docker network exists..."
    docker network create apex-network 2>/dev/null || log_info "Network already exists"

    # Connect Oracle DB to network
    docker network connect apex-network oracle-apex-db 2>/dev/null || log_info "DB already connected"

    # Pull and start CloudBeaver
    log_info "Pulling CloudBeaver image (may take 1-2 minutes)..."
    cd "$DBEAVER_DIR"
    docker compose pull 2>/dev/null || docker-compose pull

    log_info "Starting CloudBeaver..."
    docker compose up -d 2>/dev/null || docker-compose up -d

    sleep 10

    # Create connection config
    log_info "Configuring Oracle connection..."
    local DB_PASS=""
    if [ -f "$DB_PASSWORD_FILE" ]; then
        DB_PASS=$(cat "$DB_PASSWORD_FILE")
    fi

    # Auto-configure connection (via CloudBeaver API if available)
    # Note: CloudBeaver requires manual first-time setup via web UI

    echo ""
    log_success "✅ CloudBeaver installed successfully!"
    echo ""
    echo "  🌐 Access DBeaver at: http://localhost:$DBEAVER_PORT"
    echo "  👤 Default credentials:"
    echo "      Username: admin"
    echo "      Password: admin123"
    echo ""
    echo "  📝 To connect to Oracle:"
    echo "      Host: oracle-apex-db"
    echo "      Port: 1521"
    echo "      Database: XEPDB1"
    echo "      Username: SYS as SYSDBA"
    echo "      Password: (your database password)"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# START DBEAVER
# ═══════════════════════════════════════════════════════════════════════════════
start_dbeaver() {
    if [ ! -d "$DBEAVER_DIR" ]; then
        log_error "DBeaver not installed. Run: bash dbeaver.sh install"
        exit 1
    fi

    log_info "Starting CloudBeaver..."
    cd "$DBEAVER_DIR"
    docker compose up -d 2>/dev/null || docker-compose up -d
    sleep 5
    log_success "CloudBeaver is running at http://localhost:$DBEAVER_PORT"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STOP DBEAVER
# ═══════════════════════════════════════════════════════════════════════════════
stop_dbeaver() {
    log_info "Stopping CloudBeaver..."
    cd "$DBEAVER_DIR" 2>/dev/null || exit 0
    docker compose down 2>/dev/null || docker-compose down
    log_success "CloudBeaver stopped"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STATUS CHECK
# ═══════════════════════════════════════════════════════════════════════════════
status_dbeaver() {
    if docker ps | grep -q "oracle-apex-cloudbeaver"; then
        log_success "CloudBeaver is running"
        echo "  🌐 URL: http://localhost:$DBEAVER_PORT"
    else
        log_warning "CloudBeaver is not running"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN SWITCH
# ═══════════════════════════════════════════════════════════════════════════════
case "$1" in
    install) install_dbeaver ;;
    start)   start_dbeaver ;;
    stop)    stop_dbeaver ;;
    status)  status_dbeaver ;;
    *)
        echo "Usage: $0 {install|start|stop|status}"
        echo ""
        echo "Commands:"
        echo "  install  - Install CloudBeaver (first time)"
        echo "  start    - Start CloudBeaver"
        echo "  stop     - Stop CloudBeaver"
        echo "  status   - Check CloudBeaver status"
        exit 1
        ;;
esac
