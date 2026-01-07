# Hostinger hPanel Deployment Guide

## Prerequisites
- Hostinger hPanel account with Python support
- MySQL database access
- SSH access (if available)

## Step 1: Create MySQL Database in hPanel

1. Login to your Hostinger hPanel
2. Go to **MySQL Databases**
3. Click **Create Database**
4. Note down:
   - Database Name
   - Database User
   - Database Password
   - Database Host (usually `localhost`)

## Step 2: Upload Files to Hostinger

### Option A: Using File Manager
1. Compress your project folder (zip)
2. Go to hPanel → **File Manager**
3. Upload zip to `/domains/yourdomain.com/public_html/`
4. Extract the zip file

### Option B: Using FTP
1. Get FTP credentials from hPanel
2. Use FileZilla or similar FTP client
3. Upload all files to `/domains/yourdomain.com/public_html/`

## Step 3: Set Environment Variables

Create a `.env` file in your project root with:

```env
PRODUCTION=True
DEBUG=False
SECRET_KEY=your-secret-key-here-generate-a-new-one
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database Configuration
DB_NAME=your_database_name
DB_USER=your_database_user
DB_PASSWORD=your_database_password
DB_HOST=localhost
DB_PORT=3306
```

**Important**: Generate a new SECRET_KEY for production. Never use your development key.

## Step 4: Install Dependencies

If you have SSH access:

```bash
cd /domains/yourdomain.com/public_html/paylio-main
pip install -r requirements.txt
```

If no SSH access, use hPanel's Python setup interface.

## Step 5: Run Migrations

```bash
python manage.py migrate
python manage.py collectstatic --noinput
```

## Step 6: Create Superuser

```bash
python manage.py createsuperuser
```

## Step 7: Configure Python App in hPanel

1. Go to **Advanced** → **Python**
2. Click **Setup Python Application**
3. Configure:
   - **Python Version**: 3.12 or latest available
   - **Application Root**: `/domains/yourdomain.com/public_html/paylio-main`
   - **Application URL**: `/` (or subdirectory)
   - **Application Startup File**: `paylio/wsgi.py`
   - **Application Entry Point**: `application`

4. Set environment variables in hPanel Python interface

## Step 8: Update ALLOWED_HOSTS

In your `.env` or settings.py, ensure your domain is in ALLOWED_HOSTS:

```python
ALLOWED_HOSTS = ['yourdomain.com', 'www.yourdomain.com', '127.0.0.1', 'localhost']
```

## Step 9: Static Files Configuration

Create/update `passenger_wsgi.py` in your project root:

```python
import os
import sys

# Add project directory to path
sys.path.insert(0, os.path.dirname(__file__))

# Set Django settings module
os.environ['DJANGO_SETTINGS_MODULE'] = 'paylio.settings'

# Load environment variables
from dotenv import load_dotenv
load_dotenv()

# Import Django's WSGI handler
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
```

## Step 10: Media Files Setup

Ensure your media folder has write permissions:

```bash
chmod 755 media/
chmod 755 media/kyc/
```

## Troubleshooting

### Error: "Database connection failed"
- Check database credentials in `.env`
- Ensure MySQL database is created
- Verify database host (usually `localhost` on Hostinger)

### Error: "Static files not loading"
- Run `python manage.py collectstatic`
- Check `STATIC_ROOT` and `STATIC_URL` in settings.py
- Ensure WhiteNoise is installed

### Error: "500 Internal Server Error"
- Set `DEBUG=False` in production
- Check error logs in hPanel
- Ensure all dependencies are installed

### Python version not supported
- Check available Python versions in hPanel
- Update `runtime.txt` if needed
- Contact Hostinger support for Python 3.12+ availability

## Security Checklist

- [ ] Set `DEBUG=False`
- [ ] Generate new `SECRET_KEY` for production
- [ ] Update `ALLOWED_HOSTS` with your domain
- [ ] Set strong database password
- [ ] Enable HTTPS/SSL in Hostinger
- [ ] Secure your `.env` file (don't commit to Git)
- [ ] Set proper file permissions (755 for folders, 644 for files)

## Post-Deployment

1. Test login at: `https://yourdomain.com/admin/`
2. Test user dashboard: `https://yourdomain.com/account/`
3. Check all static files load correctly
4. Test file uploads (KYC documents)
5. Monitor error logs for any issues

## Useful Commands

```bash
# Check Python version
python --version

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Collect static files
python manage.py collectstatic --noinput

# Check for issues
python manage.py check --deploy
```

## Support

If you encounter issues:
1. Check Hostinger's Python app documentation
2. Review error logs in hPanel
3. Contact Hostinger support for server-specific issues
4. Check Django logs in your project directory

## Note on Database Migration

If you have existing data in SQLite:

1. Export data: `python manage.py dumpdata > data.json`
2. Switch to MySQL configuration
3. Run migrations: `python manage.py migrate`
4. Import data: `python manage.py loaddata data.json`
