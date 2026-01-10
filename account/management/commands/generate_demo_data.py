from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from account.models import Account
from core.models import Transaction
from django.utils import timezone
from decimal import Decimal
import random
import string

class Command(BaseCommand):
    help = 'Generate 10 demo accounts with 50 transactions'

    def handle(self, *args, **options):
        self.stdout.write("Creating 10 demo accounts...")
        
        accounts_created = 0
        transactions_created = 0
        
        for i in range(1, 11):
            try:
                # Create user
                username = f"demo_user_{i}"
                email = f"demo{i}@myroanokeheritage.com"
                
                user, created = User.objects.get_or_create(
                    username=username,
                    defaults={
                        'email': email,
                        'first_name': f'Demo',
                        'last_name': f'User {i}'
                    }
                )
                
                if created:
                    user.set_password('DemoPass123!')
                    user.save()
                
                # Create account
                account, acc_created = Account.objects.get_or_create(
                    user=user,
                    defaults={
                        'account_type': random.choice(['Checking', 'Savings', 'Business']),
                        'account_number': f"{''.join(random.choices(string.digits, k=10))}",
                        'pin_number': '1234',
                        'account_balance': Decimal(random.uniform(1000, 50000)).quantize(Decimal('0.01')),
                        'account_status': 'Active'
                    }
                )
                
                if acc_created:
                    accounts_created += 1
                    self.stdout.write(f"✓ Created account for {username}")
                
                # Create 5 transactions per account
                for j in range(5):
                    transaction_type = random.choice(['deposit', 'withdrawal', 'transfer'])
                    amount = Decimal(random.uniform(50, 5000)).quantize(Decimal('0.01'))
                    
                    transaction = Transaction.objects.create(
                        user=user,
                        account=account,
                        transaction_type=transaction_type,
                        amount=amount,
                        balance_after=account.account_balance,
                        transaction_status='Success',
                        description=f"{transaction_type.title()} - Demo Transaction {j+1}",
                        timestamp=timezone.now()
                    )
                    transactions_created += 1
                
            except Exception as e:
                self.stdout.write(f"✗ Error with account {i}: {str(e)}")
        
        self.stdout.write(
            self.style.SUCCESS(
                f"\n✓ Successfully created {accounts_created} accounts and {transactions_created} transactions"
            )
        )
