from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from .views import index_view, ask_view, upload_json

urlpatterns = [
    path('', index_view, name='index'),
    path('ask/', ask_view, name='ask'),
    path('upload_json/', upload_json, name='upload_json'),
    ]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)