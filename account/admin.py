from django.contrib import admin
from account.models import Account, KYC
from userauths.models import User
from import_export.admin import ImportExportModelAdmin
from django.urls import reverse
from django.utils.html import format_html

class AccountAdminModel(ImportExportModelAdmin):
    list_editable = ['account_type', 'account_status', 'account_balance', 'kyc_submitted', 'kyc_confirmed'] 
    list_display = ['user', 'account_number', 'account_type', 'account_status', 'account_balance', 'kyc_submitted', 'kyc_confirmed', 'date', 'view_dashboard_link'] 
    list_filter = ['account_type', 'account_status', 'kyc_submitted', 'kyc_confirmed', 'date']
    search_fields = ['user__username', 'user__email', 'account_number', 'account_id']
    readonly_fields = ['account_number', 'account_id', 'pin_number', 'red_code', 'date']
    date_hierarchy = 'date'
    
    def view_dashboard_link(self, obj):
        url = reverse('account:admin-view-user', args=[obj.user.id])
        return format_html('<a class="button" href="{}">View Dashboard</a>', url)
    view_dashboard_link.short_description = 'Actions'

class KYCAdmin(ImportExportModelAdmin):
    search_fields = ['full_name', 'user__username', 'user__email', 'mobile']
    list_display = ['user', 'full_name', 'gender', 'identity_type', 'country', 'date_of_birth', 'date'] 
    list_filter = ['gender', 'identity_type', 'marrital_status', 'country', 'date']
    readonly_fields = ['date']
    date_hierarchy = 'date'


admin.site.register(Account, AccountAdminModel)
admin.site.register(KYC, KYCAdmin)