# ARG BUILD_FROM musi być przed pierwszym FROM – wymóg Docker multi-stage
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-python:latest
FROM ${BUILD_FROM}

# Zależności systemowe (Alpine)
RUN apk add --no-cache \
    git \
    wget \
    cmake \
    libstdc++ \
    libgcc \
    python3-dev \
    py3-pip \
    g++ \
    make \
    libffi-dev

# PyTorch CPU + ONNX (wolne, ale tylko raz przy build)
RUN pip3 install --no-cache-dir \
    torch torchvision --index-url https://download.pytorch.org/whl/cpu

RUN pip3 install --no-cache-dir \
    onnx==1.18.0 \
    onnxruntime \
    "onnx-simplifier==0.4.*" \
    onnxscript

# Klonuj YOLOv9 i zainstaluj jego zależności przy build
RUN git clone --depth=1 https://github.com/WongKinYiu/yolov9.git /yolov9

RUN pip3 install --no-cache-dir -r /yolov9/requirements.txt

# Fix PyTorch weights_only (nowe wersje)
RUN sed -i \
    "s/ckpt = torch.load(attempt_download(w), map_location='cpu')/ckpt = torch.load(attempt_download(w), map_location='cpu', weights_only=False)/g" \
    /yolov9/models/experimental.py

# Skrypt startowy
COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
