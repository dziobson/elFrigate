# BUILD_FROM jest wstrzykiwany przez HA Supervisor jako --build-arg
# Musi być zadeklarowany przed pierwszym FROM (wymóg Docker multi-stage)
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest

# ══════════════════════════════════════════════════════════════
# Stage 1: Builder – python:3.11-slim (glibc, pip działa, PyTorch OK)
# ══════════════════════════════════════════════════════════════
FROM python:3.11-slim AS builder

RUN apt-get update && apt-get install --no-install-recommends -y \
    cmake libgl1 libglib2.0-0 wget git \
    && rm -rf /var/lib/apt/lists/*

# uv – szybki instalator pip
COPY --from=ghcr.io/astral-sh/uv:0.10.4 /uv /bin/uv

WORKDIR /yolov9

# Klonuj YOLOv9
RUN git clone --depth=1 https://github.com/WongKinYiu/yolov9.git .

# Instalacja zależności
RUN uv pip install --system -r requirements.txt
RUN uv pip install --system \
    onnx==1.18.0 \
    onnxruntime \
    "onnx-simplifier==0.4.*" \
    onnxscript

# Fix weights_only dla nowych wersji PyTorch
RUN sed -i \
    "s/ckpt = torch.load(attempt_download(w), map_location='cpu')/ckpt = torch.load(attempt_download(w), map_location='cpu', weights_only=False)/g" \
    models/experimental.py

# Pobierz wagi YOLOv9-c i eksportuj do ONNX 640×640
RUN wget -q \
    "https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-c-converted.pt" \
    -O yolov9-c.pt

RUN python3 export.py \
    --weights yolov9-c.pt \
    --imgsz 640 \
    --simplify \
    --include onnx

# ══════════════════════════════════════════════════════════════
# Stage 2: Runtime – HA Alpine base (zawiera bashio i with-contenv)
# ══════════════════════════════════════════════════════════════
FROM ${BUILD_FROM}

# Skopiuj zbudowany model z buildera
COPY --from=builder /yolov9/yolov9-c.onnx /model/yolov9-c-640.onnx

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
