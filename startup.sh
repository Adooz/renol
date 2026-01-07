#!/bin/bash
set -e

echo "Running migrations..."
python manage.py migrate --noinput

echo "Checking existing staff accounts..."
python manage.py list_staff || true

echo "Ensuring superuser exists..."
python manage.py ensure_superuser --email "${SUPERUSER_EMAIL:-admin@paylio.com}" --password "${SUPERUSER_PASSWORD:-Admin12345!}" || echo "Warning: Could not ensure superuser, continuing anyway..."

echo "Starting Gunicorn..."
exec gunicorn paylio.wsgi:application --bind 0.0.0.0:${PORT:-8000} --log-file -
