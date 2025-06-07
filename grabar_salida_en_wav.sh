#!/bin/bash

OUTPUT="grabacion_salida_$(date +%Y%m%d_%H%M%S).wav"
DURACION=$1

echo "Detectando sistema de sonido..."

grabar_pulseaudio() {
    echo "PulseAudio o PipeWire emulando PulseAudio detectado. Buscando dispositivo monitor..."

    SINK_MONITOR=$(pacmd list-sinks | grep -A 15 '* index:' | grep 'monitor of' | head -n1 | sed -n 's/.*name: <\(.*\)>.*/\1/p')

    if [ -z "$SINK_MONITOR" ]; then
        SINK_MONITOR=$(pacmd list-sinks | grep 'monitor of' | head -n1 | sed -n 's/.*name: <\(.*\)>.*/\1/p')
    fi

    if [ -z "$SINK_MONITOR" ]; then
        echo "No se pudo encontrar el dispositivo monitor en PulseAudio."
        exit 1
    fi

    echo "Dispositivo monitor encontrado: $SINK_MONITOR"
    echo "Grabando salida de audio a $OUTPUT ..."

    if [ -z "$DURACION" ]; then
        parec -d "$SINK_MONITOR" --file-format=wav > "$OUTPUT"
    else
        timeout "$DURACION" parec -d "$SINK_MONITOR" --file-format=wav > "$OUTPUT"
    fi

    echo "Grabación finalizada."
}

if command -v pw-record >/dev/null 2>&1; then
    SERVER_NAME=$(pactl info | grep "Server Name" | awk -F': ' '{print $2}')
    echo "Servidor de audio detectado: $SERVER_NAME"

    if echo "$SERVER_NAME" | grep -q "PulseAudio (on PipeWire)"; then
        grabar_pulseaudio
    else
        echo "PipeWire nativo detectado. Buscando dispositivo monitor con pactl..."

        echo "Listado de dispositivos monitor:"
        pactl list sources short | grep monitor

        DEVICE=$(pactl list sources short | grep monitor | head -n1 | awk '{print $2}')

        if [ -z "$DEVICE" ]; then
            echo "No se pudo encontrar el dispositivo monitor en PipeWire usando pactl."
            exit 1
        fi

        echo "Dispositivo monitor encontrado: $DEVICE"
        echo "Grabando salida de audio a $OUTPUT ..."

        if [ -z "$DURACION" ]; then
            pw-record --target "$DEVICE" | ffmpeg -f s16le -ar 48000 -ac 2 -i - "$OUTPUT"
        else
            pw-record --target "$DEVICE" --duration "$DURACION" | ffmpeg -f s16le -ar 48000 -ac 2 -i - "$OUTPUT"
        fi

        echo "Grabación finalizada."
    fi

elif command -v parec >/dev/null 2>&1; then
    grabar_pulseaudio
else
    echo "No se encontró ni pw-record ni parec. Instala PipeWire o PulseAudio."
    exit 1
fi
