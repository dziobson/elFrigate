# BUILD_FROM jest wstrzykiwany przez HA Supervisor
# Musi być przed pierwszym FROM (wymóg Docker multi-stage)
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:latest
FROM ${BUILD_FROM}

# Zależności systemowe (Debian/glibc – PyTorch wheels tutaj działają)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    cmake \
    libgl1 \
    libglib2.0-0 \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Instalacja uv (szybki pip, omija PEP 668)
COPY --from=ghcr.io/astral-sh/uv:0.10.4 /uv /usr/local/bin/uv

# Utwórz venv i zainstaluj PyTorch CPU + ONNX (wolne raz, potem z cache)
RUN python3 -m venv /opt/yolov9_venv
RUN /opt/yolov9_venv/bin/pip install --no-cache-dir \
    torch torchvision --index-url https://download.pytorch.org/whl/cpu
RUN /opt/yolov9_venv/bin/pip install --no-cache-dir \
    onnx \
    onnxruntime \
    onnxscript

# Klonuj YOLOv9 i zainstaluj jego zależności
RUN git clone --depth=1 https://github.com/WongKinYiu/yolov9.git /yolov9
RUN /opt/yolov9_venv/bin/pip install --no-cache-dir -r /yolov9/requirements.txt

# Fix weights_only dla nowych wersji PyTorch
RUN sed -i \
    "s/ckpt = torch.load(attempt_download(w), map_location='cpu')/ckpt = torch.load(attempt_download(w), map_location='cpu', weights_only=False)/g" \
    /yolov9/models/experimental.py

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
