from django.db import migrations, models


def generate_unique_code(existing):
    import random
    digits = '0123456789'
    for _ in range(10000):
        code = ''.join(random.choices(digits, k=6))
        if code not in existing:
            return code
    raise RuntimeError('Unable to generate unique access code')


def forwards(apps, schema_editor):
    Account = apps.get_model('account', 'Account')
    existing = set(Account.objects.exclude(access_code__isnull=True).values_list('access_code', flat=True))
    for acc in Account.objects.all():
        if not acc.access_code:
            code = generate_unique_code(existing)
            acc.access_code = code
            acc.save(update_fields=['access_code'])
            existing.add(code)


def reverse(apps, schema_editor):
    Account = apps.get_model('account', 'Account')
    for acc in Account.objects.all():
        acc.access_code = None
        acc.save(update_fields=['access_code'])


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0002_account_account_type'),
    ]

    operations = [
        migrations.AddField(
            model_name='account',
            name='access_code',
            field=models.CharField(max_length=6, null=True, blank=True),
        ),
        migrations.RunPython(forwards, reverse_code=reverse),
    ]
