#!/usr/bin/env bash
set -euo pipefail

# docker_deploy_local.sh
# Build and run the renol Docker image from a local repository copy (useful for WSL/local Ubuntu testing)
# Defaults to ~/renol but accepts --path to override.

APP_NAME=renol
DEFAULT_PATH="${HOME}/renol"
REPO_PATH=""
PORT=8000

print_usage(){
  cat <<EOF
Usage: sudo $0 [--path /full/path/to/renol] [--port 8000]

Defaults:
  path: ${DEFAULT_PATH}
  port: ${PORT}

This script builds an image named ${APP_NAME}_local:latest and runs it as ${APP_NAME}_local_app.
It will use a local .env file in the repo if present. Otherwise it generates one with DEBUG=True.
EOF
}

if [[ $(id -u) -ne 0 ]]; then
  echo "Run this script with sudo. Exiting."; exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) REPO_PATH="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown option: $1"; print_usage; exit 1;;
  esac
done

if [[ -z "${REPO_PATH}" ]]; then
  REPO_PATH="${DEFAULT_PATH}"
fi

if [[ ! -d "${REPO_PATH}" ]]; then
  echo "Repository path not found: ${REPO_PATH}"; exit 1
fi

echo "Using repository at: ${REPO_PATH}"

# Ensure docker exists (no install here; fail fast with friendly message)
if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found. Install Docker Engine in WSL/Ubuntu before running this script."; exit 1
fi

# Ensure docker can run (daemon)
if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon not available. Make sure Docker is running (e.g., Docker Desktop WSL integration or docker.service)."; exit 1
fi

# Use local .env if present, else generate one
ENV_FILE="${REPO_PATH}/.env"
if [[ -f "${ENV_FILE}" ]]; then
  echo "Using existing .env at ${ENV_FILE}"
else
  echo "Generating a temporary .env at ${ENV_FILE}"
  SECKEY=$(python3 - <<PY
import secrets
print(secrets.token_urlsafe(50))
PY
  )
  cat > "${ENV_FILE}" <<EOF
SECRET_KEY=${SECKEY}
DEBUG=True
ALLOWED_HOSTS=*
PORT=${PORT}
PRODUCTION=False
EOF
  chmod 600 "${ENV_FILE}"
fi

# Build image
cd "${REPO_PATH}"
IMAGE_TAG="${APP_NAME}_local:latest"
echo "Building Docker image ${IMAGE_TAG} from ${REPO_PATH}"
docker build -t ${IMAGE_TAG} .

# Remove an existing container if present
CONTAINER_NAME="${APP_NAME}_local_app"
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Removing existing container ${CONTAINER_NAME}"
  docker rm -f ${CONTAINER_NAME} || true
fi

# Ensure media directory exists and is writable
mkdir -p "${REPO_PATH}/media"

# Run container, expose host port -> container PORT
echo "Starting container ${CONTAINER_NAME} mapping host:${PORT} -> container:${PORT}"
docker run -d \
  --name ${CONTAINER_NAME} \
  --env-file "${ENV_FILE}" \
  -p 127.0.0.1:${PORT}:${PORT} \
  -v "${REPO_PATH}/media:/app/media" \
  --restart unless-stopped \
  ${IMAGE_TAG}

echo "Container started. Visit http://localhost:${PORT} in your browser (from WSL/host)."
echo "View logs: docker logs -f ${CONTAINER_NAME}"

exit 0
