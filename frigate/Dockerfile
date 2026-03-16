ARG BUILD_FROM=ghcr.io/blakeblackshear/frigate:0.17.0
FROM ${BUILD_FROM}

# Oznaczenia Add-ona dla HA
LABEL \
    io.hass.name="Frigate NVR (elFrigate)" \
    io.hass.description="Frigate NVR z YOLOv9 640x640 ONNX detector" \
    io.hass.type="addon" \
    io.hass.version="0.17.0"

# Skopiuj skrypt startowy HA
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Skopiuj domyślny szablon konfiguracji Frigate
COPY frigate_config/config.yml /tmp/frigate_config_template.yml

# Labelmap COCO (80 klas) – Frigate go wymaga gdy używa się custom modelu
COPY frigate_config/labelmap.txt /tmp/labelmap.txt

CMD ["/run.sh"]
