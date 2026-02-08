#!/usr/bin/env bash
set -euo pipefail

# Docker-based deploy helper for Ubuntu 22.04
# Usage:
#   sudo bash deploy/docker_deploy.sh --repo https://github.com/Adooz/renol.git --branch main --domain example.com
#   or locally:
#   sudo bash deploy/docker_deploy.sh --local --domain 127.0.0.1

APP_NAME=renol
APP_DIR=/opt/${APP_NAME}
REPO_URL="https://github.com/Adooz/renol.git"
BRANCH=main
SITE_DOMAIN="*"
COPY_LOCAL=false

print_usage(){
  cat <<EOF
Usage: sudo $0 [--repo <git-url>] [--branch <branch>] [--local] [--domain <domain>] [--help]

Options:
  --repo   Git URL to clone (default: https://github.com/Adooz/renol.git)
  --branch Branch to clone (default: main)
  --local  Copy current directory into the target (for local testing)
  --domain Public domain or IP (optional). If omitted ALLOWED_HOSTS will be '*'.
EOF
}

if [[ $(id -u) -ne 0 ]]; then
  echo "This script must be run with sudo. Exiting."
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_URL="$2"; shift 2;;
    --branch) BRANCH="$2"; shift 2;;
    --local) COPY_LOCAL=true; shift 1;;
    --domain) SITE_DOMAIN="$2"; shift 2;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown option: $1"; print_usage; exit 1;;
  esac
done

echo "Docker deploy: repo=${REPO_URL}, branch=${BRANCH}, domain=${SITE_DOMAIN}"

# Install Docker if missing
if ! command -v docker >/dev/null 2>&1; then
  echo "Installing Docker Engine and compose plugin..."
  apt update
  apt install -y ca-certificates curl gnupg lsb-release
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# Create app dir and pull code
mkdir -p ${APP_DIR}
chown root:root ${APP_DIR}

if [[ "${COPY_LOCAL}" == "true" ]]; then
  echo "Copying local project into ${APP_DIR}/app"
  rm -rf ${APP_DIR}/app
  rsync -a --exclude '.git' --exclude 'venv' ./ ${APP_DIR}/app/
else
  echo "Cloning ${REPO_URL} (branch ${BRANCH})"
  rm -rf ${APP_DIR}/app
  git clone --depth 1 --branch ${BRANCH} ${REPO_URL} ${APP_DIR}/app
fi

# Generate .env for the container
SECKEY=$(python3 - <<PY
import secrets
print(secrets.token_urlsafe(50))
PY
)

ENV_FILE=${APP_DIR}/app/.env
cat > ${ENV_FILE} <<EOF
SECRET_KEY=${SECKEY}
DEBUG=True
ALLOWED_HOSTS=${SITE_DOMAIN}
PORT=8080
PRODUCTION=False
EOF
chmod 600 ${ENV_FILE}

# Ensure media volume exists
mkdir -p ${APP_DIR}/app/media
chown -R root:root ${APP_DIR}/app

# Build Docker image
cd ${APP_DIR}/app
docker build -t ${APP_NAME}:latest .

# Stop any running container and run fresh
if docker ps -a --format '{{.Names}}' | grep -q '^${APP_NAME}_app$'; then
  docker rm -f ${APP_NAME}_app || true
fi

echo "Starting container ${APP_NAME}_app"
docker run -d \
  --name ${APP_NAME}_app \
  --env-file ${ENV_FILE} \
  -p 127.0.0.1:8080:8080 \
  -v ${APP_DIR}/app/media:/app/media \
  --restart unless-stopped \
  ${APP_NAME}:latest

# Configure nginx to reverse proxy to container on 127.0.0.1:8080
apt install -y nginx
NGINX_CONF=/etc/nginx/sites-available/${APP_NAME}
cat > ${NGINX_CONF} <<NGINX
server {
    listen 80;
    server_name _;

    location = /favicon.ico { access_log off; log_not_found off; }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://127.0.0.1:8080;
    }
}
NGINX

ln -sf ${NGINX_CONF} /etc/nginx/sites-enabled/${APP_NAME}
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx

echo "Docker deployment complete. App available at http://<server-ip> (or configure DNS for a domain and run certbot)."
