#!/usr/bin/env bash
set -euo pipefail

# Production Docker deploy helper for Ubuntu 22.04 (Hostinger VPS)
# This script clones the repo, builds the Docker image, runs the container,
# creates a minimal nginx reverse proxy and can optionally obtain a TLS cert via certbot.
#
# Usage (example):
#   sudo bash deploy/docker_deploy.sh --repo https://github.com/Adooz/renol.git --branch main --domain example.com --https

APP_NAME=renol
APP_DIR=/opt/${APP_NAME}
REPO_URL="https://github.com/Adooz/renol.git"
BRANCH=main
SITE_DOMAIN=""
COPY_LOCAL=false
ENABLE_HTTPS=false
SKIP_DOCKER_INSTALL=false
SUPERUSER_EMAIL="admin@paylio.com"
SUPERUSER_PASSWORD=""

print_usage(){
  cat <<EOF
Usage: sudo $0 --domain yourdomain.com [--repo <git-url>] [--branch <branch>] [--https] [--skip-docker-install] [--superuser-email <email>] [--superuser-pass <pass>]

Options:
  --domain    Public domain to serve (required)
  --repo      Git URL to clone (default: https://github.com/Adooz/renol.git)
  --branch    Branch to clone (default: main)
  --https     Request TLS via Certbot after setup (requires DNS A record to point to this server)
  --skip-docker-install  Don't attempt to install Docker (useful if Docker is already present)
  --superuser-email     Email for ensured superuser (default: admin@paylio.com)
  --superuser-pass      If omitted, a secure random password will be generated and printed
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
    --https) ENABLE_HTTPS=true; shift 1;;
    --skip-docker-install) SKIP_DOCKER_INSTALL=true; shift 1;;
    --superuser-email) SUPERUSER_EMAIL="$2"; shift 2;;
    --superuser-pass) SUPERUSER_PASSWORD="$2"; shift 2;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown option: $1"; print_usage; exit 1;;
  esac
done

if [[ -z "${SITE_DOMAIN}" ]]; then
  echo "Error: --domain is required."
  print_usage
  exit 1
fi

echo "Deploying ${APP_NAME} from ${REPO_URL} (branch ${BRANCH}) to domain ${SITE_DOMAIN}"

# Install Docker if missing (skip if user requested)
if [[ "${SKIP_DOCKER_INSTALL}" != "true" ]]; then
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
fi

# Create app dir and clone the repo
mkdir -p ${APP_DIR}
chown root:root ${APP_DIR}
rm -rf ${APP_DIR}/app
echo "Cloning ${REPO_URL} (branch ${BRANCH})"
git clone --depth 1 --branch ${BRANCH} ${REPO_URL} ${APP_DIR}/app

# Generate secure SECRET_KEY and superuser password if not provided
SECKEY=$(python3 - <<PY
import secrets
print(secrets.token_urlsafe(50))
PY
)
if [[ -z "${SUPERUSER_PASSWORD}" ]]; then
  SUPERUSER_PASSWORD=$(python3 - <<PY
import secrets
print(secrets.token_urlsafe(16))
PY
)
fi

# Create .env for the container
ENV_FILE=${APP_DIR}/app/.env
cat > ${ENV_FILE} <<EOF
SECRET_KEY=${SECKEY}
DEBUG=False
ALLOWED_HOSTS=${SITE_DOMAIN}
PORT=8080
PRODUCTION=True
SUPERUSER_EMAIL=${SUPERUSER_EMAIL}
SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD}
EOF
chmod 600 ${ENV_FILE}

# Ensure media volume exists and ownership
mkdir -p ${APP_DIR}/app/media
chown -R root:root ${APP_DIR}/app

# Build Docker image
cd ${APP_DIR}/app
docker build -t ${APP_NAME}:latest .

# Stop any running container and run fresh
CONTAINER_NAME=${APP_NAME}_app
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker rm -f ${CONTAINER_NAME} || true
fi

echo "Starting container ${CONTAINER_NAME} (internal port 8080)"
docker run -d \
  --name ${CONTAINER_NAME} \
  --env-file ${ENV_FILE} \
  -p 127.0.0.1:8080:8080 \
  -v ${APP_DIR}/app/media:/app/media \
  --restart unless-stopped \
  ${APP_NAME}:latest

# Configure nginx to reverse proxy to container on 127.0.0.1:8080
apt install -y nginx
NGINX_CONF=/etc/nginx/sites-available/${APP_NAME}
cat > ${NGINX_CONF} <<'NGINX'
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;

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

# Replace placeholder with actual domain
sed -i "s|DOMAIN_PLACEHOLDER|${SITE_DOMAIN}|g" ${NGINX_CONF}

ln -sf ${NGINX_CONF} /etc/nginx/sites-enabled/${APP_NAME}
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx

echo "Application started and proxied by nginx at http://${SITE_DOMAIN}"
echo "Superuser: ${SUPERUSER_EMAIL}  Password: ${SUPERUSER_PASSWORD}"

# Wait for the container to become healthy (HTTP 2xx/3xx) before attempting HTTPS
echo "Waiting for application to respond on http://127.0.0.1:8080 ..."
MAX_WAIT=180
SLEEP=5
elapsed=0
until code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/ 2>/dev/null) && [[ "$code" =~ ^[23] ]]; do
  if [[ ${elapsed} -ge ${MAX_WAIT} ]]; then
    echo "Timed out waiting for application to become ready (waited ${MAX_WAIT}s). Check container logs: docker logs -f ${CONTAINER_NAME}";
    break
  fi
  sleep ${SLEEP}
  elapsed=$((elapsed+SLEEP))
done

if [[ ${elapsed} -lt ${MAX_WAIT} ]]; then
  echo "Application responded (HTTP ${code})."
else
  echo "Proceeding even though app did not respond successfully. Certbot will likely fail until app is healthy."
fi

# If HTTPS requested, attempt to obtain a certificate with Certbot (requires DNS A record)
if [[ "${ENABLE_HTTPS}" == "true" ]]; then
  echo "Attempting to obtain TLS certificate for ${SITE_DOMAIN} using certbot..."
  apt install -y certbot python3-certbot-nginx

  # Try certbot up to 3 times, in case the app/nginx is still starting
  cert_ok=false
  for attempt in 1 2 3; do
    echo "Certbot attempt ${attempt}/3..."
    if certbot --nginx -d ${SITE_DOMAIN} --non-interactive --agree-tos -m ${SUPERUSER_EMAIL}; then
      cert_ok=true
      break
    else
      echo "certbot attempt ${attempt} failed; retrying in 10s..."
      sleep 10
    fi
  done

  if [[ "${cert_ok}" == "true" ]]; then
    echo "certbot succeeded — site should be available via https://"
  else
    echo "certbot failed after multiple attempts. Please check nginx, DNS, and container health, then run certbot manually.";
  fi
fi

echo "Deployment finished. Check container logs: docker logs -f ${CONTAINER_NAME}"

