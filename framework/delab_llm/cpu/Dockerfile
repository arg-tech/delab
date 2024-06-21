FROM python:3-slim-bullseye

# We need to set the host to 0.0.0.0 to allow outside access
ENV HOST 0.0.0.0

RUN apt update && apt install -y libopenblas-dev ninja-build build-essential pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip pytest cmake scikit-build setuptools fastapi uvicorn sse-starlette pydantic-settings starlette-context
    
COPY . .

# Install llama-cpp-python (build with cuda)
RUN pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu

# Run the server
CMD python3 -m llama_cpp.server
