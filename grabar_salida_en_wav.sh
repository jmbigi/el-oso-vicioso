#!/bin/bash

systemctl --user restart pipewire pipewire-pulse
#hacer pausa para que se reinicie
sleep 2

set -euo pipefail

# Función para mostrar error y salir
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Verificar que ffmpeg esté instalado
if ! command -v ffmpeg >/dev/null 2>&1; then
  error_exit "ffmpeg no está instalado. Instálalo con 'sudo apt install ffmpeg'"
fi

# Verificar que pactl esté instalado
if ! command -v pactl >/dev/null 2>&1; then
  error_exit "pactl no está instalado. Instálalo con 'sudo apt install pulseaudio-utils'"
fi

# Validar duración (si se pasa)
DURACION=${1:-}
if [ -n "$DURACION" ]; then
  if ! [[ "$DURACION" =~ ^[0-9]+$ ]]; then
    error_exit "Duración debe ser un número entero positivo."
  fi
fi

echo "Buscando dispositivo monitor de PulseAudio para grabar..."

# Buscar dispositivo monitor (audio que sale del sistema)
DEVICE=$(pactl list short sources | grep -i monitor | head -n1 | awk '{print $2}' || true)

if [ -z "$DEVICE" ]; then
  echo "No se encontró dispositivo monitor para grabar. Listado de dispositivos disponibles:"
  pactl list short sources
  error_exit "No se pudo detectar dispositivo monitor para grabar audio."
fi

echo "Dispositivo monitor detectado: $DEVICE"

OUTPUT="grabacion_salida.wav"
rm -f "$OUTPUT"  # Eliminar archivo previo si existe

echo "Esperando 5 segundos antes de iniciar la grabación..."
sleep 5
echo "Iniciando grabación en 1 segundo..."
sleep 1

# Capturar CTRL+C para limpiar
trap 'echo -e "\nGrabación interrumpida por usuario."; exit 130' INT TERM

echo "Iniciando grabación en $OUTPUT desde dispositivo $DEVICE ..."

# Intentar ejecutar ffmpeg con un timeout (solo si DURACION está seteado)
# Para mejorar info, capturamos errores y mostramos mensaje amigable
if [ -z "$DURACION" ]; then
  ffmpeg -hide_banner -loglevel info -f pulse -i "$DEVICE" "$OUTPUT"
else
  ffmpeg -hide_banner -loglevel info -f pulse -i "$DEVICE" -t "$DURACION" "$OUTPUT"
fi

# Verificar que el archivo se creó y tiene contenido
if [ -f "$OUTPUT" ]; then
  FILESIZE=$(stat --format=%s "$OUTPUT")
  if [ "$FILESIZE" -gt 0 ]; then
    echo "Grabación finalizada correctamente: $OUTPUT (tamaño: $FILESIZE bytes)"
  else
    echo "Advertencia: El archivo $OUTPUT fue creado pero está vacío."
  fi
else
  echo "Error: No se creó el archivo de grabación."
fi

exit 0
