import os
import sys

# Add your project directory to the sys.path
sys.path.insert(0, os.path.dirname(__file__))

# Set the Django settings module
os.environ['DJANGO_SETTINGS_MODULE'] = 'paylio.settings'

# Load environment variables from .env
from dotenv import load_dotenv
load_dotenv()

# Get the WSGI application
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
