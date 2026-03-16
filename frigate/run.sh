#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

bashio::log.info "Uruchamianie Frigate NVR (elFrigate)..."

# ─── Odczyt opcji z konfiguracji add-ona ──────────────────────────────────────
MQTT_HOST=$(bashio::config 'mqtt_host')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_USER=$(bashio::config 'mqtt_user')
MQTT_PASSWORD=$(bashio::config 'mqtt_password')

# ─── Przygotowanie katalogów ──────────────────────────────────────────────────
mkdir -p /config/frigate
mkdir -p /config/model_cache
mkdir -p /media/frigate/clips
mkdir -p /media/frigate/recordings

# ─── Konfiguracja Frigate ─────────────────────────────────────────────────────
FRIGATE_CONFIG="/config/frigate/config.yml"

if [ ! -f "${FRIGATE_CONFIG}" ]; then
    bashio::log.info "Tworzę domyślną konfigurację Frigate w ${FRIGATE_CONFIG}"
    cp /tmp/frigate_config_template.yml "${FRIGATE_CONFIG}"
    # Podmień zmienne MQTT w szablonie
    sed -i "s|{mqtt_host}|${MQTT_HOST}|g" "${FRIGATE_CONFIG}"
    sed -i "s|{mqtt_port}|${MQTT_PORT}|g" "${FRIGATE_CONFIG}"
    if bashio::config.has_value 'mqtt_user'; then
        sed -i "s|# mqtt_user_placeholder|user: ${MQTT_USER}|g" "${FRIGATE_CONFIG}"
        sed -i "s|# mqtt_pass_placeholder|password: ${MQTT_PASSWORD}|g" "${FRIGATE_CONFIG}"
    fi
else
    bashio::log.info "Używam istniejącej konfiguracji: ${FRIGATE_CONFIG}"
fi

# ─── Skopiuj labelmap jeśli brak w model_cache ────────────────────────────────
if [ ! -f "/config/model_cache/labelmap.txt" ]; then
    bashio::log.info "Kopiuję labelmap COCO do /config/model_cache/"
    cp /tmp/labelmap.txt /config/model_cache/labelmap.txt
fi

# ─── Sprawdź czy model ONNX istnieje ──────────────────────────────────────────
MODEL_PATH="/config/model_cache/yolov9-c-640.onnx"
if [ ! -f "${MODEL_PATH}" ]; then
    bashio::log.warning "Model ONNX nie znaleziony w ${MODEL_PATH}"
    bashio::log.warning "Uruchom add-on 'YOLOv9 Builder' aby wygenerować model."
    bashio::log.warning "Frigate uruchomi się bez detektora YOLOv9."
fi

# ─── Uruchom Frigate ──────────────────────────────────────────────────────────
bashio::log.info "Startowanie Frigate..."
export FRIGATE_DEFAULT_CAMERA_FPS=5
exec python3 -m frigate --config "${FRIGATE_CONFIG}"
