from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.utils import timezone
from datetime import timedelta
from decimal import Decimal
import os
import random

from account.models import Account
from core.models import Transaction, Notification


class Command(BaseCommand):
    help = "Seed a superuser and one demo profile with many successful transactions and a huge balance."

    def add_arguments(self, parser):
        parser.add_argument("--superuser-email", dest="super_email", default=os.getenv("SUPERUSER_EMAIL", "admin@example.com"))
        parser.add_argument("--superuser-password", dest="super_password", default=os.getenv("SUPERUSER_PASSWORD", "Admin12345"))
        parser.add_argument("--demo-email", dest="demo_email", default=os.getenv("DEMO_EMAIL", "demo@example.com"))
        parser.add_argument("--demo-password", dest="demo_password", default=os.getenv("DEMO_PASSWORD", "Demo12345"))
        parser.add_argument("--transactions", type=int, default=int(os.getenv("DEMO_TX_COUNT", "50")))
        parser.add_argument("--balance", dest="balance", default=os.getenv("DEMO_BALANCE", "987654321.00"))

    def handle(self, *args, **options):
        User = get_user_model()

        # Create or get superuser
        super_email = options["super_email"].strip()
        super_password = options["super_password"]
        super_username = super_email.split("@")[0]

        su, created_su = User.objects.get_or_create(email=super_email, defaults={
            "username": super_username,
            "is_staff": True,
            "is_superuser": True,
            "first_name": "Super",
            "last_name": "Admin",
        })
        if created_su:
            su.set_password(super_password)
            su.save()
            self.stdout.write(self.style.SUCCESS(f"Created superuser {super_email}"))
        else:
            # Ensure privileges and password
            updated = False
            if not su.is_superuser or not su.is_staff:
                su.is_superuser = True
                su.is_staff = True
                updated = True
            if super_password:
                su.set_password(super_password)
                updated = True
            if updated:
                su.save()
            self.stdout.write(self.style.WARNING(f"Superuser {super_email} already exists (ensured privileges)."))

        # Create or get demo user
        demo_email = options["demo_email"].strip()
        demo_password = options["demo_password"]
        demo_username = demo_email.split("@")[0]

        demo_user, created_demo = User.objects.get_or_create(email=demo_email, defaults={
            "username": demo_username,
            "first_name": "Demo",
            "last_name": "User",
        })
        if created_demo:
            demo_user.set_password(demo_password)
            demo_user.save()
            self.stdout.write(self.style.SUCCESS(f"Created demo user {demo_email}"))
        else:
            self.stdout.write(self.style.WARNING(f"Demo user {demo_email} already exists."))

        # Ensure account exists (signals should create it, but be safe)
        account, _ = Account.objects.get_or_create(user=demo_user)

        # Set large balance and active/kyc status
        try:
            target_balance = Decimal(str(options["balance"]))
        except Exception:
            target_balance = Decimal("987654321.00")

        account.account_balance = target_balance
        account.account_status = "active"
        account.kyc_submitted = True
        account.kyc_confirmed = True
        account.save()

        self.stdout.write(self.style.SUCCESS(f"Demo account {account.account_number} set to balance {account.account_balance}"))

        # Create many successful transactions
        tx_count = max(1, int(options["transactions"]))

        # Clean up only demo user's old generated transactions (optional)
        # Comment out next line if you want to accumulate on each run
        # Transaction.objects.filter(user=demo_user).delete()

        now = timezone.now()
        created = 0
        for i in range(tx_count):
            amt = Decimal(random.randint(1000, 100000)) / Decimal(100)  # 10.00 - 1000.00
            # Alternate between received (credit) and transfer (debit)
            if i % 2 == 0:
                tx_type = "recieved"
                tx = Transaction.objects.create(
                    user=demo_user,
                    amount=amt,
                    description="Payment received",
                    reciever=demo_user,
                    reciever_account=account,
                    status="completed",
                    transaction_type=tx_type,
                )
                Notification.objects.create(
                    user=demo_user,
                    notification_type="Credit Alert",
                    amount=int(amt),
                )
                # Optionally adjust balance upwards (already set huge balance)
            else:
                tx_type = "transfer"
                tx = Transaction.objects.create(
                    user=demo_user,
                    amount=amt,
                    description="Payment sent",
                    sender=demo_user,
                    sender_account=account,
                    status="completed",
                    transaction_type=tx_type,
                )
                Notification.objects.create(
                    user=demo_user,
                    notification_type="Debit Alert",
                    amount=int(amt),
                )

            # Spread dates over past 90 days
            tx.date = now - timedelta(days=random.randint(0, 90))
            tx.save(update_fields=["date"])
            created += 1

        self.stdout.write(self.style.SUCCESS(f"Created {created} completed transactions for demo user."))
        self.stdout.write(self.style.SUCCESS("Seeding complete."))
