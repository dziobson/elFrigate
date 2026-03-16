#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

MODEL_SIZE=$(bashio::config 'model_size')
IMAGE_SIZE=$(bashio::config 'image_size')
ONNX_FILE="yolov9-${MODEL_SIZE}-${IMAGE_SIZE}.onnx"
DEST="/share/yolov9/${ONNX_FILE}"

bashio::log.info "==================================================="
bashio::log.info "YOLOv9 Builder – eksport modelu ONNX"
bashio::log.info "Model: YOLOv9-${MODEL_SIZE}  |  Rozmiar: ${IMAGE_SIZE}×${IMAGE_SIZE}"
bashio::log.info "Output: ${DEST}"
bashio::log.info "==================================================="

mkdir -p /share/yolov9

# ─── Sprawdź czy model już istnieje ──────────────────────────────────────────
if [ -f "${DEST}" ]; then
    bashio::log.info "✓ Model już istnieje: ${DEST}"
    bashio::log.info "Usuń plik jeśli chcesz wygenerować ponownie."
else
    # ─── Pobierz wagi modelu ─────────────────────────────────────────────────
    WEIGHTS_URL="https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-${MODEL_SIZE}-converted.pt"
    WEIGHTS_FILE="/yolov9/yolov9-${MODEL_SIZE}.pt"

    if [ ! -f "${WEIGHTS_FILE}" ]; then
        bashio::log.info "Pobieranie wag: ${WEIGHTS_URL}"
        wget -q --show-progress "${WEIGHTS_URL}" -O "${WEIGHTS_FILE}"
        bashio::log.info "✓ Wagi pobrane."
    else
        bashio::log.info "✓ Wagi już istnieją: ${WEIGHTS_FILE}"
    fi

    # ─── Eksport do ONNX ─────────────────────────────────────────────────────
    bashio::log.info "Eksportuję do ONNX (${IMAGE_SIZE}×${IMAGE_SIZE})..."
    cd /yolov9
    python3 export.py \
        --weights "${WEIGHTS_FILE}" \
        --imgsz "${IMAGE_SIZE}" \
        --simplify \
        --include onnx

    # Zmień nazwę na standardową (yolov9-c-640.onnx)
    EXPORTED="/yolov9/yolov9-${MODEL_SIZE}.onnx"
    mv "${EXPORTED}" "${DEST}"

    bashio::log.info "✓ Model zapisany: ${DEST}"
    bashio::log.info "Rozmiar: $(du -sh ${DEST} | cut -f1)"
fi

# ─── Skopiuj labelmap jeśli brak ─────────────────────────────────────────────
if [ ! -f "/share/yolov9/labelmap.txt" ]; then
    bashio::log.info "Kopiuję labelmap COCO do /share/yolov9/"
    cp /tmp/labelmap.txt /share/yolov9/labelmap.txt
fi

bashio::log.info ""
bashio::log.info "==================================================="
bashio::log.info "Gotowe! Model: ${DEST}"
bashio::log.info "Możesz teraz:"
bashio::log.info "  1. Zatrzymać ten add-on"
bashio::log.info "  2. Uruchomić 'Frigate NVR (elFrigate)'"
bashio::log.info "==================================================="
