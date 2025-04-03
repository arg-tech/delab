FROM ghcr.io/ggml-org/llama.cpp:server-cuda


RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y git build-essential wget 
    
    
RUN mkdir -p models/Qwen2.5-7B-Instruct-GGUF
RUN wget -O models/Qwen2.5-7B-Instruct-GGUF/qwen2.5-7b-instruct-q3_k_m.gguf \
        https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q3_k_m.gguf

        
# CMD llama-server -m models/Qwen2.5-7B-Instruct-GGUF/qwen2.5-7b-instruct-q3_k_m.gguf --host 0.0.0.0