#!/bin/bash

systemctl --user restart pipewire pipewire-pulse
#hacer pausa para que se reinicie
sleep 2

set -euo pipefail

error_exit() {
  echo "Error: $1" >&2
  exit 1
}

if ! command -v ffmpeg >/dev/null 2>&1; then
  error_exit "ffmpeg no está instalado. Instálalo con 'sudo apt install ffmpeg'"
fi

if ! command -v pactl >/dev/null 2>&1; then
  error_exit "pactl no está instalado. Instálalo con 'sudo apt install pulseaudio-utils'"
fi

DURACION=${1:-}
if [ -n "$DURACION" ]; then
  if ! [[ "$DURACION" =~ ^[0-9]+$ ]]; then
    error_exit "Duración debe ser un número entero positivo."
  fi
fi

echo "Buscando dispositivo monitor de PulseAudio para grabar..."

DEVICE=$(pactl list short sources | grep -i monitor | head -n1 | awk '{print $2}' || true)

if [ -z "$DEVICE" ]; then
  echo "No se encontró dispositivo monitor para grabar. Listado de dispositivos disponibles:"
  pactl list short sources
  error_exit "No se pudo detectar dispositivo monitor para grabar audio."
fi

echo "Dispositivo monitor detectado: $DEVICE"

OUTPUT="grabacion_salida.wav"
OUTPUT_LIMPIO="grabacion_salida_limpia.wav"
rm -f "$OUTPUT" "$OUTPUT_LIMPIO"

echo "Esperando 5 segundos antes de iniciar la grabación..."
sleep 5
echo "Iniciando grabación en 1 segundo..."
sleep 1

trap 'echo -e "\nGrabación interrumpida por usuario."; exit 130' INT TERM

echo "Iniciando grabación en $OUTPUT desde dispositivo $DEVICE ..."

if [ -z "$DURACION" ]; then
  ffmpeg -hide_banner -loglevel info -f pulse -i "$DEVICE" "$OUTPUT"
else
  ffmpeg -hide_banner -loglevel info -f pulse -i "$DEVICE" -t "$DURACION" "$OUTPUT"
fi

if [ -f "$OUTPUT" ]; then
  FILESIZE=$(stat --format=%s "$OUTPUT")
  if [ "$FILESIZE" -gt 0 ]; then
    echo "Grabación finalizada correctamente: $OUTPUT (tamaño: $FILESIZE bytes)"
    echo "Procesando para eliminar silencios..."

    # Aplicar filtro silenceremove para eliminar silencios al principio y final
    # Ajusta los parámetros según tu necesidad:
    # start_periods=1: eliminar desde el principio
    # stop_periods=1: eliminar al final
    # threshold=-50dB: nivel que define silencio
    # start_duration=0.5: duración mínima del silencio para eliminar al inicio (0.5 seg)
    # stop_duration=0.5: duración mínima al final

    ffmpeg -hide_banner -loglevel info -i "$OUTPUT" -af silenceremove=start_periods=1:start_duration=0.5:start_threshold=-50dB:stop_periods=1:stop_duration=0.5:stop_threshold=-50dB "$OUTPUT_LIMPIO"

    if [ -f "$OUTPUT_LIMPIO" ]; then
      LIMPIO_SIZE=$(stat --format=%s "$OUTPUT_LIMPIO")
      if [ "$LIMPIO_SIZE" -gt 0 ]; then
        DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT_LIMPIO")
        echo "Archivo limpio creado: $OUTPUT_LIMPIO (tamaño: $LIMPIO_SIZE bytes, duración: ${DURATION}s)"
      else
        echo "Advertencia: El archivo limpio está vacío después de eliminar silencios."
      fi
    else
      echo "Error: No se pudo crear el archivo limpio."
    fi

  else
    echo "Advertencia: El archivo $OUTPUT fue creado pero está vacío."
  fi
else
  echo "Error: No se creó el archivo de grabación."
fi

exit 0
