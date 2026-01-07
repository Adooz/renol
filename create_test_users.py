import os
import django
import random
from decimal import Decimal
from datetime import datetime, timedelta

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'paylio.settings')
django.setup()

from userauths.models import User
from account.models import Account
from core.models import Transaction, Notification

# Test user data
test_users = [
    {"username": "john_doe", "email": "john@example.com", "first_name": "John", "last_name": "Doe"},
    {"username": "sarah_smith", "email": "sarah@example.com", "first_name": "Sarah", "last_name": "Smith"},
    {"username": "mike_johnson", "email": "mike@example.com", "first_name": "Mike", "last_name": "Johnson"},
    {"username": "emily_davis", "email": "emily@example.com", "first_name": "Emily", "last_name": "Davis"},
    {"username": "david_wilson", "email": "david@example.com", "first_name": "David", "last_name": "Wilson"},
]

print("Creating test users with accounts and transactions...\n")

for user_data in test_users:
    # Check if user exists
    if User.objects.filter(username=user_data['username']).exists():
        print(f"❌ User {user_data['username']} already exists, skipping...")
        continue
    
    # Create user
    user = User.objects.create_user(
        username=user_data['username'],
        email=user_data['email'],
        password='password123'
    )
    user.first_name = user_data['first_name']
    user.last_name = user_data['last_name']
    user.save()
    
    # Get or create account
    account = Account.objects.get(user=user)
    
    # Set random balance between 1000 and 50000
    balance = Decimal(random.randint(1000, 50000))
    account.account_balance = balance
    account.account_status = 'active'
    account.kyc_submitted = True
    account.kyc_confirmed = True
    account.save()
    
    print(f"✅ Created user: {user.username} | Account: {account.account_number} | Balance: ${balance}")
    
    # Create 3-5 random transactions for each user
    num_transactions = random.randint(3, 5)
    
    for i in range(num_transactions):
        # Random transaction from 1-7 days ago
        days_ago = random.randint(1, 7)
        trans_date = datetime.now() - timedelta(days=days_ago)
        
        # Random amount between 50 and 2000
        amount = Decimal(random.randint(50, 2000))
        
        # Random transaction type
        trans_type = random.choice(['transfer', 'recieved'])
        status = random.choice(['completed', 'completed', 'completed', 'pending'])  # More completed than pending
        
        if trans_type == 'recieved':
            transaction = Transaction.objects.create(
                user=user,
                amount=amount,
                description=f"Payment received",
                reciever=user,
                reciever_account=account,
                status=status,
                transaction_type=trans_type
            )
        else:
            transaction = Transaction.objects.create(
                user=user,
                amount=amount,
                description=f"Payment sent",
                sender=user,
                sender_account=account,
                status=status,
                transaction_type=trans_type
            )
        
        transaction.date = trans_date
        transaction.save()
        
        # Create notification
        if trans_type == 'recieved':
            notif_type = "Credit Alert"
        else:
            notif_type = "Debit Alert"
            
        notification = Notification.objects.create(
            user=user,
            notification_type=notif_type,
            amount=amount
        )
        notification.date = trans_date
        notification.save()
    
    print(f"   📊 Created {num_transactions} transactions\n")

print("\n🎉 All test users created successfully!")
print("\n📋 Login credentials for all users:")
print("   Password: password123\n")
for user_data in test_users:
    print(f"   Username: {user_data['username']} | Email: {user_data['email']}")
