FROM python:3.13-slim

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt --break-system-packages

# Copy project
COPY ./front_end/ ./front_end/

# Run Django server
CMD ["python", "front_end/django_chatbot/manage.py", "runserver", "0.0.0.0:8840"]
