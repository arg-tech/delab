from django.shortcuts import render
# Create your views here.
from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from .utils import generate_answer, get_context
import os
from django.conf import settings


def index_view(request):
    request.session['context'] = get_context()
    context = request.session['context']
    if context is None:
        return render(request, 'chatbot/upload_template.html')
    return render(request, 'chatbot/chat_temp.html', {'context_items': context.items()})


@csrf_exempt
@require_POST
def ask_view(request):
    user_input = request.POST.get('user_input')
    context = request.session.get('context', get_context())
    answer = generate_answer(user_input, context)
    return JsonResponse({'answer': answer})

@csrf_exempt
@require_POST
def upload_json(request):
    """Funktion zum Hochladen und Speichern einer JSON-Datei"""
    if 'jsonFile' not in request.FILES:
        return JsonResponse({'message': 'Keine Datei hochgeladen!'}, status=400)

    json_file = request.FILES['jsonFile']

    if not json_file.name.endswith('.json'):
        return JsonResponse({'message': 'Nur JSON-Dateien sind erlaubt!'}, status=400)

    # Sicherstellen, dass das Verzeichnis existiert
    upload_dir = settings.MEDIA_ROOT
    os.makedirs(upload_dir, exist_ok=True)

    file_path = upload_dir / 'conv_delab.json'

    # Datei speichern
    with open(file_path, 'wb+') as destination:
        for chunk in json_file.chunks():
            destination.write(chunk)

    return JsonResponse({'message': f'Datei {json_file.name} erfolgreich hochgeladen!'})
