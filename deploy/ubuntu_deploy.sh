#!/usr/bin/env bash
set -euo pipefail

# Simple, idempotent deployment helper for Ubuntu 22.04
# Usage (tested for local dry-run):
#   sudo ./deploy/ubuntu_deploy.sh --local --domain example.com
# Or to clone from git:
#   sudo ./deploy/ubuntu_deploy.sh --repo https://github.com/youruser/renol.git --branch main --domain example.com

APP_NAME=renol
APP_USER=${APP_NAME}
APP_DIR=/opt/${APP_NAME}
VENV_DIR=${APP_DIR}/venv
REPO_URL="https://github.com/Adooz/renol.git"
BRANCH=main
# If no domain provided we set ALLOWED_HOSTS to '*' so the app can still start.
SITE_DOMAIN="*"
DATABASE_URL=""
USE_SQLITE=true

print_usage(){
  cat <<EOF
Usage: sudo $0 [--repo <git-url>] [--branch <branch>] [--local] [--domain <domain>] [--db <DATABASE_URL>]

Options:
  --repo       Git URL to clone (optional). If omitted, script assumes you're running from the project root and will copy files.
  --branch     Branch to clone (default: main)
  --local      Use current directory as project source (for local testing)
  --domain     Public domain or IP to set in nginx and ALLOWED_HOSTS (default: localhost)
  --db         DATABASE_URL (optional). If omitted the script will create a local Postgres DB named "renol".
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
  --sqlite) USE_SQLITE=true; shift 1;;
  --db) DATABASE_URL="$2"; USE_SQLITE=false; shift 2;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown option: $1"; print_usage; exit 1;;
  esac
done

echo "Deploying ${APP_NAME} to ${APP_DIR} (domain: ${SITE_DOMAIN})"

# Update apt and install required packages
apt update
# Minimal runtimes: Python, venv, git, nginx and rsync. Postgres not required because this deployment will use SQLite by default.
apt install -y python3 python3-venv python3-dev python3-pip build-essential git nginx rsync

# Create app user
if ! id -u ${APP_USER} >/dev/null 2>&1; then
  useradd --system --create-home --shell /bin/bash ${APP_USER}
fi

# Prepare application directory
mkdir -p ${APP_DIR}
chown ${APP_USER}:${APP_USER} ${APP_DIR}

if [[ -n "${REPO_URL}" ]]; then
  echo "Cloning ${REPO_URL} (branch ${BRANCH})"
  rm -rf ${APP_DIR}/app
  sudo -u ${APP_USER} git clone --depth 1 --branch ${BRANCH} ${REPO_URL} ${APP_DIR}/app
else
  if [[ "${COPY_LOCAL:-}" == "true" ]]; then
    echo "Copying project files from current directory to ${APP_DIR}/app"
    rm -rf ${APP_DIR}/app
    rsync -a --exclude '.git' --exclude 'venv' ./ ${APP_DIR}/app/
    chown -R ${APP_USER}:${APP_USER} ${APP_DIR}/app
  else
    echo "No repo and no --local flag provided. Exiting."; exit 1
  fi
fi

# Create virtualenv and install requirements
python3 -m venv ${VENV_DIR}
${VENV_DIR}/bin/pip install --upgrade pip wheel
${VENV_DIR}/bin/pip install -r ${APP_DIR}/app/requirements.txt || true

# Database: use provided DATABASE_URL or default to SQLite (no DB provisioning)
if [[ -n "${DATABASE_URL}" ]]; then
  echo "Using provided DATABASE_URL"
  DB_URL=${DATABASE_URL}
  USE_SQLITE=false
else
  echo "No external DATABASE_URL provided; will use SQLite (default for this repo)."
  DB_URL=""
  USE_SQLITE=true
fi

# Generate a secure SECRET_KEY
SECKEY=$(python3 - <<PY
import secrets
print(secrets.token_urlsafe(50))
PY
)

# Write .env file for application (settings.py loads .env)
ENV_FILE=${APP_DIR}/app/.env
cat > ${ENV_FILE} <<EOF
SECRET_KEY=${SECKEY}
DEBUG=True
ALLOWED_HOSTS=${SITE_DOMAIN}
PRODUCTION=False
EOF
if [[ -n "${DB_URL}" ]]; then
  echo "DATABASE_URL=${DB_URL}" >> ${ENV_FILE}
fi
chown ${APP_USER}:${APP_USER} ${ENV_FILE}
chmod 600 ${ENV_FILE}

# Run migrations, collectstatic
cd ${APP_DIR}/app
# Run migrations and collectstatic. Use || true so script continues if there are harmless issues.
sudo -u ${APP_USER} ${VENV_DIR}/bin/python manage.py migrate --noinput || true
sudo -u ${APP_USER} ${VENV_DIR}/bin/python manage.py collectstatic --noinput || true

# Create systemd service for gunicorn
SERVICE_PATH=/etc/systemd/system/${APP_NAME}.service
cat > ${SERVICE_PATH} <<'SYSTEMD'
[Unit]
Description=gunicorn daemon for renol Django app
After=network.target

[Service]
User=renol
Group=www-data
WorkingDirectory=/opt/renol/app
EnvironmentFile=/opt/renol/app/.env
ExecStart=/opt/renol/venv/bin/gunicorn --access-logfile - --workers 3 --bind unix:/run/renol.sock paylio.wsgi:application

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable ${APP_NAME}.service
systemctl restart ${APP_NAME}.service || systemctl status ${APP_NAME}.service --no-pager

# Configure nginx
NGINX_CONF=/etc/nginx/sites-available/${APP_NAME}
cat > ${NGINX_CONF} <<NGINX
server {
  listen 80;
  server_name _;

  location = /favicon.ico { access_log off; log_not_found off; }
  location /static/ {
    alias /opt/renol/app/staticfiles/;
  }

  location / {
    include proxy_params;
    proxy_pass http://unix:/run/renol.sock;
  }
}
NGINX

ln -sf ${NGINX_CONF} /etc/nginx/sites-enabled/${APP_NAME}
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx

echo "Deployment finished. Visit http://${SITE_DOMAIN} (or check logs with: journalctl -u ${APP_NAME} -f)"
