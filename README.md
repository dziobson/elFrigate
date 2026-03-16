# elFrigate

Własne repozytorium Home Assistant Add-onów z Frigate NVR i YOLOv9 640×640.

## Add-ony

| Add-on | Opis |
|--------|------|
| **Frigate NVR** | Network Video Recorder z AI detekcją obiektów (ONNX YOLOv9) |
| **YOLOv9 Builder** | Jednorazowe narzędzie do eksportu modelu YOLOv9-c 640×640 → ONNX |

## Instalacja

1. W Home Assistant przejdź do **Settings → Add-ons → Add-on Store**
2. Kliknij **⋮ (trzy kropki)** → **Repositories**
3. Dodaj URL tego repozytorium:
   ```
   https://github.com/m-rodak/elFrigate
   ```
4. Odśwież stronę – add-ony pojawią się w sklepie

## Szybki start

### 1. Zbuduj model ONNX (tylko raz)
Zainstaluj i uruchom add-on **YOLOv9 Builder**. Model zostanie zapisany do `/config/model_cache/yolov9-c-640.onnx`.

### 2. Skonfiguruj Frigate
Zainstaluj add-on **Frigate NVR** i edytuj `/config/frigate/config.yml`:
- Dodaj swoje kamery w sekcji `cameras`
- Ustaw `mqtt.host` na adres swojego brokera MQTT

### 3. Integracja z HA
Frigate automatycznie pojawi się jako integracja MQTT w Home Assistant.

## Wymagania

- Home Assistant OS (HAOS) lub Supervised
- Broker MQTT (np. add-on Mosquitto Broker)
- Min. 4 GB RAM (zalecane 8 GB dla YOLOv9-c 640×640)

## Architektura

```
Home Assistant
├── Frigate NVR add-on
│   ├── Frigate 0.17+
│   └── ONNX Runtime (CPU/GPU)
│       └── yolov9-c-640.onnx  ← /config/model_cache/
└── MQTT Broker (Mosquitto)
```
