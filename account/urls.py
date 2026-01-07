from django.urls import path
from account import views
app_name = "account"

urlpatterns = [
    path("", views.dashboard, name="dashboard"),
    path("account/", views.account, name="account"),
    path("kyc-reg/", views.kyc_registration, name="kyc-reg"),
    path("admin/view-user/<int:user_id>/", views.admin_view_user_dashboard, name="admin-view-user"),
]
