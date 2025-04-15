from django.http import HttpResponse


def index(request):
    return HttpResponse("Hello, world. You're home.")


import requests
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from urllib.parse import urlencode


BACKEND_URL = "http://delab_analytics:8840"  # Adjust if your backend uses a different port or path

def forward_request(request, path):
    base_url = f"{BACKEND_URL}/{path}".rstrip('/')  # Avoid double slashes
    query_string = request.META.get('QUERY_STRING', '')  # Raw query string

    url = f"{base_url}"
    if query_string:
        url += f"?{query_string}"

    method = request.method.lower()
    headers = {k: v for k, v in request.headers.items() if k.lower() != "host"}

    try:
        resp = requests.request(
            method=method,
            url=url,
            headers=headers,
            data=request.body,
            cookies=request.COOKIES,
            timeout=30
        )
        return HttpResponse(
            resp.content,
            status=resp.status_code,
            content_type=resp.headers.get("Content-Type")
        )
    except requests.exceptions.RequestException as e:
        return JsonResponse({"error": str(e)}, status=502)

@csrf_exempt
def analytics_proxy(request):
    return forward_request(request, "analytics")

@csrf_exempt
def inference_proxy(request):
    return forward_request(request, "inference")

@csrf_exempt
def llm_proxy(request):
    return forward_request(request, "llm")