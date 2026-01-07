FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

RUN python manage.py collectstatic --noinput

# Align container port with platform-provided $PORT (default to 8000 locally)
EXPOSE 8080

CMD ["sh", "-c", "python manage.py migrate --noinput && gunicorn paylio.wsgi:application --bind 0.0.0.0:${PORT:-8000}"]
