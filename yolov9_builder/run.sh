#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

MODEL_SIZE=$(bashio::config 'model_size')
IMAGE_SIZE=$(bashio::config 'image_size')
OUTPUT_FILE="yolov9-${MODEL_SIZE}-${IMAGE_SIZE}.onnx"
DEST="/config/model_cache/${OUTPUT_FILE}"

bashio::log.info "==================================================="
bashio::log.info "YOLOv9 Builder – eksport modelu ONNX"
bashio::log.info "Model: YOLOv9-${MODEL_SIZE}  |  Rozmiar: ${IMAGE_SIZE}×${IMAGE_SIZE}"
bashio::log.info "==================================================="

mkdir -p /config/model_cache

if [ -f "${DEST}" ]; then
    bashio::log.info "Model już istnieje: ${DEST}"
    bashio::log.info "Usuń plik jeśli chcesz wygenerować ponownie."
else
    bashio::log.info "Kopiuję model do /config/model_cache/..."
    cp "/model/${OUTPUT_FILE}" "${DEST}"
    bashio::log.info "✓ Model zapisany: ${DEST}"
    bashio::log.info "Rozmiar: $(du -sh ${DEST} | cut -f1)"
fi

bashio::log.info ""
bashio::log.info "==================================================="
bashio::log.info "Gotowe! Możesz teraz:"
bashio::log.info "1. Zatrzymać ten add-on (startup: once)"
bashio::log.info "2. Uruchomić add-on 'Frigate NVR (elFrigate)'"
bashio::log.info "==================================================="
