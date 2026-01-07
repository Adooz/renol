from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    help = "Ensure a superuser exists. Creates if missing, updates password if exists. Never fails."

    def add_arguments(self, parser):
        parser.add_argument("--email", required=True)
        parser.add_argument("--password", required=True)
        parser.add_argument("--username", default=None, help="Optional username (defaults to email prefix)")

    def handle(self, *args, **options):
        email = options["email"].strip()
        password = options["password"]
        username = options["username"] or email.split("@")[0]
        
        User = get_user_model()
        
        try:
            # Try to get existing superuser
            user = User.objects.get(email=email)
            # Update to ensure superuser privileges
            user.is_superuser = True
            user.is_staff = True
            user.set_password(password)
            user.save()
            self.stdout.write(self.style.SUCCESS(f"✅ Updated superuser: {email}"))
        except User.DoesNotExist:
            # Create new superuser
            user = User.objects.create_superuser(
                email=email,
                username=username,
                password=password
            )
            user.is_superuser = True
            user.is_staff = True
            user.save()
            self.stdout.write(self.style.SUCCESS(f"✅ Created superuser: {email}"))
        
        self.stdout.write(self.style.SUCCESS(f"Login credentials → Email: {email} | Password: {password}"))
