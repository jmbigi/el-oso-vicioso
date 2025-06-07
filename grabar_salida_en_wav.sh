#!/bin/bash

OUTPUT="grabacion_salida.wav"
DURACION=$1

echo "=== 🎧 Iniciando grabación de salida de audio del sistema ==="

# Función para diagnóstico de problemas
diagnosticar_problemas() {
    echo -e "\n=== 🛠️ Diagnóstico de problemas ==="

    echo -e "\n🔍 Dispositivos de tipo monitor detectados:"
    local devices=$(pactl list sources short | grep -i monitor)
    if [ -z "$devices" ]; then
        echo "❌ No se encontraron dispositivos monitor."
        echo "   Posibles causas:"
        echo "   - No hay audio en reproducción"
        echo "   - PipeWire o PulseAudio no está funcionando"
    else
        echo "$devices"
    fi

    echo -e "\n🔍 Permisos de audio:"
    if groups | grep -q -E 'audio|pipewire'; then
        echo "✅ Usuario tiene permisos adecuados de audio"
    else
        echo "❌ Usuario SIN permisos de audio."
        echo "   ➤ Solución recomendada:"
        echo "     sudo usermod -aG audio,pipewire $USER"
        echo "     (Requiere cerrar y volver a iniciar sesión)"
    fi

    echo -e "\n🔍 Estado del servidor de audio (PipeWire/PulseAudio):"
    if pactl info | grep -q "PipeWire"; then
        echo "✅ PipeWire está activo"
    else
        echo "❌ PipeWire NO está corriendo."
        echo "   ➤ Solución recomendada:"
        echo "     systemctl --user restart pipewire pipewire-pulse"
    fi

    if [ -n "$DEVICE" ]; then
        echo -e "\n🔍 Estado del dispositivo seleccionado ($DEVICE):"
        if pactl list sources | grep -A10 "$DEVICE" | grep -q "Suspended: yes"; then
            echo "❌ Dispositivo suspendido."
            echo "   ➤ Solución:"
            echo "     pactl suspend-source $DEVICE 0"
        else
            echo "✅ Dispositivo activo"
        fi
    fi

    echo -e "\n=== 🔚 Fin del diagnóstico ===\n"
}

# Despierta el audio para prevenir "suspend"
despertar_dispositivo() {
    echo "🌐 Activando dispositivo de audio (evitando suspensión)..."
    timeout 0.3 pw-play /dev/zero 2>/dev/null || true
}

# Función principal
grabar_pipewire() {
    echo -e "\n🔍 Buscando dispositivos tipo monitor..."

    # Selecciona el primer dispositivo tipo monitor disponible
    DEVICE=$(pactl list sources short | grep -i monitor | head -n1 | awk '{print $2}')

    if [ -z "$DEVICE" ]; then
        echo "❌ No se encontró ningún dispositivo tipo monitor."
        diagnosticar_problemas
        exit 1
    fi

    echo "✔ Dispositivo seleccionado para grabación: $DEVICE"
    echo -e "\n📋 Lista completa de dispositivos monitor disponibles:"
    pactl list sources short | grep -i monitor

    despertar_dispositivo

    echo -e "\n📟 Estado del dispositivo:"
    pactl list sources | grep -A10 "$DEVICE" | grep -E "Name:|Description:|State:|Sample Specification:"

    # Parámetros
    FORMATO_PW=s32
    FORMATO_FF=s32le
    RATE=48000
    CHANNELS=2

    echo -e "\n⚙️ Configuración de grabación:"
    echo "  🎚️ Formato: $FORMATO_PW"
    echo "  🕒 Tasa de muestreo: $RATE Hz"
    echo "  🎛️ Canales: $CHANNELS"
    echo "  ⏳ Duración: ${DURACION:-'ilimitada (Ctrl+C para detener)'}"

    echo -e "\n🎤 Grabando..."

    if [ -z "$DURACION" ]; then
        pw-record --target="$DEVICE" --format=$FORMATO_PW --rate=$RATE --channels=$CHANNELS - | \
        ffmpeg -y -f $FORMATO_FF -ar $RATE -ac $CHANNELS -i - "$OUTPUT"
    else
        timeout "${DURACION}s" bash -c \
        "pw-record --target='$DEVICE' --format=$FORMATO_PW --rate=$RATE --channels=$CHANNELS - | \
         ffmpeg -y -f $FORMATO_FF -ar $RATE -ac $CHANNELS -i - '$OUTPUT'"
    fi

    # Revisión del archivo generado
    if [ -s "$OUTPUT" ]; then
        DURACION_REAL=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT" | awk '{printf "%.1f", $1}')
        echo -e "\n✅ Grabación completada:"
        echo "  📁 Archivo: $OUTPUT"
        echo "  📦 Tamaño: $(du -h "$OUTPUT" | cut -f1)"
        echo "  🕒 Duración real: $DURACION_REAL segundos"

        SILENCIO=$(ffmpeg -i "$OUTPUT" -af silencedetect=noise=-30dB:d=0.5 -f null - 2>&1 | grep "silence_")
        if [ -n "$SILENCIO" ]; then
            echo -e "\n⚠️  Se detectaron periodos de silencio:"
            echo "$SILENCIO" | while read -r line; do echo "  $line"; done
        fi
    else
        echo -e "\n❌ Error: La grabación resultó en un archivo vacío."
        diagnosticar_problemas
        exit 1
    fi
}

# Validación de conexión a PipeWire
if ! pactl info &>/dev/null; then
    echo "❌ No se puede conectar a PipeWire/PulseAudio."
    echo "   ➤ Intente ejecutar:"
    echo "     systemctl --user restart pipewire pipewire-pulse"
    exit 1
fi

grabar_pipewire
