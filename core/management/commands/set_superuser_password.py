from django.core.management.base import BaseCommand, CommandError
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    help = "Set the password for a superuser identified by email."

    def add_arguments(self, parser):
        parser.add_argument("--email", required=True)
        parser.add_argument("--password", required=True)

    def handle(self, *args, **options):
        email = options["email"].strip()
        password = options["password"]
        User = get_user_model()
        try:
            u = User.objects.get(email=email, is_superuser=True)
        except User.DoesNotExist:
            raise CommandError(f"No superuser found with email: {email}")
        u.set_password(password)
        u.save(update_fields=["password"])
        self.stdout.write(self.style.SUCCESS(f"Password updated for {email}"))
