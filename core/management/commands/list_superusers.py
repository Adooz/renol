from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    help = "List all superusers (email, username, is_active)."

    def handle(self, *args, **options):
        User = get_user_model()
        su_qs = User.objects.filter(is_superuser=True)
        if not su_qs.exists():
            self.stdout.write(self.style.WARNING("No superusers found."))
            return
        for u in su_qs:
            self.stdout.write(f"email={getattr(u, 'email', '')} username={getattr(u, 'username', '')} active={u.is_active}")
