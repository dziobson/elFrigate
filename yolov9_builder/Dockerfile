# ARG BUILD_FROM musi być przed pierwszym FROM – Docker multi-stage wymóg
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest

FROM python:3.11-slim AS build

# Instalacja zależności systemowych
RUN apt-get update && apt-get install --no-install-recommends -y \
    cmake \
    libgl1 \
    libglib2.0-0 \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalacja uv (szybki pip)
COPY --from=ghcr.io/astral-sh/uv:0.10.4 /uv /bin/uv

WORKDIR /yolov9

# Pobierz repozytorium YOLOv9
RUN git clone https://github.com/WongKinYiu/yolov9.git . \
    && git checkout main

# Instalacja zależności Python
RUN uv pip install --system -r requirements.txt
RUN uv pip install --system \
    onnx==1.18.0 \
    onnxruntime \
    onnx-simplifier==0.4.* \
    onnxscript

# Fix dla PyTorch weights_only warning (wymagane dla nowych wersji)
RUN sed -i \
    "s/ckpt = torch.load(attempt_download(w), map_location='cpu')/ckpt = torch.load(attempt_download(w), map_location='cpu', weights_only=False)/g" \
    models/experimental.py

# Argumenty build-time (domyślnie YOLOv9-c 640px)
ARG MODEL_SIZE=c
ARG IMG_SIZE=640

# Pobierz wagi modelu
RUN wget -q \
    "https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-${MODEL_SIZE}-converted.pt" \
    -O "yolov9-${MODEL_SIZE}.pt"

# Eksport do ONNX z simplification
RUN python3 export.py \
    --weights "./yolov9-${MODEL_SIZE}.pt" \
    --imgsz ${IMG_SIZE} \
    --simplify \
    --include onnx

# Zmień nazwę do standardowej (yolov9-c-640.onnx)
RUN mv "yolov9-${MODEL_SIZE}.onnx" "yolov9-${MODEL_SIZE}-${IMG_SIZE}.onnx"

# --- Etap końcowy: obraz bazowy HA (zawiera bashio i with-contenv) ---
FROM ${BUILD_FROM}

ARG MODEL_SIZE=c
ARG IMG_SIZE=640

COPY --from=build /yolov9/yolov9-${MODEL_SIZE}-${IMG_SIZE}.onnx /model/yolov9-${MODEL_SIZE}-${IMG_SIZE}.onnx
COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
