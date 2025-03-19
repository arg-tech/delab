FROM ghcr.io/abetlen/llama-cpp-python:latest


RUN apt-get update && apt-get install -y wget && \
    mkdir -p /models/Qwen2.5-7B-Instruct-GGUF && \
    wget -O /models/Qwen2.5-7B-Instruct-GGUF/qwen2.5-7b-instruct-q3_k_m.gguf \
        https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q3_k_m.gguf