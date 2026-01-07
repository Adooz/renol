from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    help = "List all staff and superuser accounts in the database."

    def handle(self, *args, **options):
        User = get_user_model()
        
        staff_users = User.objects.filter(is_staff=True)
        
        if not staff_users.exists():
            self.stdout.write(self.style.WARNING("❌ No staff accounts found in database."))
            return
        
        self.stdout.write(self.style.SUCCESS(f"\n📋 Found {staff_users.count()} staff account(s):\n"))
        
        for user in staff_users:
            self.stdout.write("─" * 60)
            self.stdout.write(f"Email: {user.email}")
            self.stdout.write(f"Username: {user.username}")
            self.stdout.write(f"Name: {user.first_name} {user.last_name}")
            self.stdout.write(f"Superuser: {'✅ Yes' if user.is_superuser else '❌ No'}")
            self.stdout.write(f"Staff: {'✅ Yes' if user.is_staff else '❌ No'}")
            self.stdout.write(f"Active: {'✅ Yes' if user.is_active else '❌ No'}")
            self.stdout.write(f"Date joined: {user.date_joined}")
        
        self.stdout.write("─" * 60)
        self.stdout.write(self.style.SUCCESS("\n💡 Note: Passwords are hashed. Use ensure_superuser to reset."))
