#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

MODEL_SRC="/model/yolov9-c-640.onnx"
MODEL_DEST="/share/yolov9/yolov9-c-640.onnx"
LABELMAP_DEST="/share/yolov9/labelmap.txt"

bashio::log.info "================================================"
bashio::log.info " YOLOv9 Builder – kopiowanie modelu do /share/"
bashio::log.info "================================================"

mkdir -p /share/yolov9

# ─── Model ONNX ──────────────────────────────────────────
if [ -f "${MODEL_DEST}" ]; then
    bashio::log.info "✓ Model już istnieje: ${MODEL_DEST}"
    bashio::log.info "  Usuń plik żeby wymusić ponowne skopiowanie."
else
    bashio::log.info "Kopiuję model: ${MODEL_SRC} → ${MODEL_DEST}"
    cp "${MODEL_SRC}" "${MODEL_DEST}"
    bashio::log.info "✓ Model zapisany ($(du -sh ${MODEL_DEST} | cut -f1))"
fi

# ─── Labelmap COCO ───────────────────────────────────────
if [ ! -f "${LABELMAP_DEST}" ]; then
    bashio::log.info "Kopiuję labelmap COCO do /share/yolov9/"
    cp /tmp/labelmap.txt "${LABELMAP_DEST}"
    bashio::log.info "✓ Labelmap zapisany."
fi

bashio::log.info ""
bashio::log.info "================================================"
bashio::log.info " Gotowe! Teraz:"
bashio::log.info "  1. Zatrzymaj ten add-on"
bashio::log.info "  2. Uruchom Frigate NVR (elFrigate)"
bashio::log.info " Model: ${MODEL_DEST}"
bashio::log.info "================================================"
