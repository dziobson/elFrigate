#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

MODEL_SIZE=$(bashio::config 'model_size')
IMAGE_SIZE=$(bashio::config 'image_size')
ONNX_FILE="yolov9-${MODEL_SIZE}-${IMAGE_SIZE}.onnx"
DEST="/share/yolov9/${ONNX_FILE}"
PYTHON="/opt/yolov9_venv/bin/python3"

bashio::log.info "================================================"
bashio::log.info " YOLOv9 Builder – eksport modelu ONNX"
bashio::log.info " Model : YOLOv9-${MODEL_SIZE}"
bashio::log.info " Rozmiar: ${IMAGE_SIZE}×${IMAGE_SIZE}"
bashio::log.info " Output : ${DEST}"
bashio::log.info "================================================"

mkdir -p /share/yolov9

# ─── Sprawdź czy model już istnieje ──────────────────────
if [ -f "${DEST}" ]; then
    bashio::log.info "✓ Model już istnieje: ${DEST}"
    bashio::log.info "  Usuń plik z /share/yolov9/ żeby wyeksportować ponownie."
else
    # ─── Pobierz wagi ─────────────────────────────────────
    WEIGHTS="/yolov9/yolov9-${MODEL_SIZE}.pt"
    if [ ! -f "${WEIGHTS}" ]; then
        bashio::log.info "Pobieranie wag YOLOv9-${MODEL_SIZE}..."
        wget -q --show-progress \
            "https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-${MODEL_SIZE}-converted.pt" \
            -O "${WEIGHTS}"
        bashio::log.info "✓ Wagi pobrane."
    fi

    # ─── Eksport do ONNX ──────────────────────────────────
    bashio::log.info "Eksport do ONNX ${IMAGE_SIZE}×${IMAGE_SIZE}..."
    cd /yolov9
    ${PYTHON} export.py \
        --weights "${WEIGHTS}" \
        --imgsz "${IMAGE_SIZE}" \
        --simplify \
        --include onnx

    # Przenieś do /share/yolov9/
    mv "/yolov9/yolov9-${MODEL_SIZE}.onnx" "${DEST}"
    bashio::log.info "✓ Model zapisany: ${DEST} ($(du -sh ${DEST} | cut -f1))"
fi

# ─── Labelmap COCO ────────────────────────────────────────
if [ ! -f "/share/yolov9/labelmap.txt" ]; then
    cp /tmp/labelmap.txt /share/yolov9/labelmap.txt
    bashio::log.info "✓ Labelmap COCO skopiowany."
fi

bashio::log.info ""
bashio::log.info "================================================"
bashio::log.info " Gotowe!"
bashio::log.info " 1. Zatrzymaj ten add-on"
bashio::log.info " 2. Uruchom Frigate NVR (elFrigate)"
bashio::log.info "================================================"
