cd ~/oracle-apex-installer
cat > Dockerfile << 'EOF'
# Oracle APEX Web Installer - Docker Image
# Created by: Peyman Rasouli - KaizenixCore
# Version: 4.0

FROM python:3.12-slim

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV TERM=xterm-256color
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    bash \
    ca-certificates \
    docker.io \
    docker-compose \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir aiohttp aiohttp-cors

# Copy installer files
COPY web-installer.py .
COPY web-installer.html .

# Expose ports
EXPOSE 8888
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8888/ || exit 1

# Run the web installer
CMD ["python3", "web-installer.py"]
EOF
