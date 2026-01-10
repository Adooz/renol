 

from django.contrib import admin
from django.urls import path, include
from core import views
from django.conf.urls.static import static
from django.conf import settings
import os
from core.views import AdminLogoutView  # Adjust if placed elsewhere
from django.views.generic import TemplateView


urlpatterns = [
    path('admin/logout/', AdminLogoutView.as_view(), name='admin-logout'),   
    path("admin/", admin.site.urls),
    path("", include("core.urls")),  
    path("", views.index, name="index"), 
    path("about/", views.about, name="about"),
    path("contact/", views.contact, name="contact"),
    path("user/", include("userauths.urls")),
    path('account/', include('account.urls', namespace='account')),
    path('sitemap.xml', TemplateView.as_view(template_name='sitemap.xml', content_type='application/xml')),
    path('google3797164cdd298408.html', TemplateView.as_view(template_name='google3797164cdd298408.html', content_type='text/html')),

]
 

# if settings.DEBUG:
#     urlpatterns += static(settings.STATIC_URL, document_root=os.path.join(settings.BASE_DIR, 'paylio', 'static'))

# Serve media files in both DEBUG and production
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
