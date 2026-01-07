from django.contrib import admin
from core.models import Transaction, CreditCard, Notification

class TransactionAdmin(admin.ModelAdmin):
    list_editable = ['amount', 'status', 'transaction_type']
    list_display = ['transaction_id', 'user', 'amount', 'status', 'transaction_type', 'reciever', 'sender', 'date']
    list_filter = ['status', 'transaction_type', 'date']
    search_fields = ['transaction_id', 'user__username', 'reciever__username', 'sender__username', 'description']
    readonly_fields = ['transaction_id', 'date']
    date_hierarchy = 'date'


class CreditCardAdmin(admin.ModelAdmin):
    list_editable = ['amount', 'card_type', 'card_status']
    list_display = ['user', 'card_id', 'name', 'card_type', 'amount', 'card_status', 'date']
    list_filter = ['card_type', 'card_status', 'date']
    search_fields = ['user__username', 'card_id', 'name']
    readonly_fields = ['card_id', 'date']
    date_hierarchy = 'date'
    

class NotificationAdmin(admin.ModelAdmin):
    list_display = ['user', 'notification_type', 'amount', 'date']
    list_filter = ['notification_type', 'date']
    search_fields = ['user__username']
    readonly_fields = ['date']
    date_hierarchy = 'date'

admin.site.register(Transaction, TransactionAdmin)
admin.site.register(CreditCard, CreditCardAdmin)
admin.site.register(Notification, NotificationAdmin)