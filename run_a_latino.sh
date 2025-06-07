#!/bin/bash
set -e

cd convertir_a_latino

if [ ! -d "venv" ]; then
    echo "🔒 Entorno virtual no encontrado. Por favor, ejecuta install_a_latino.sh primero."
    exit 1
fi
echo "🐍 Activando entorno virtual..."
source venv/bin/activate

python3 convertir_audio_latino.py entrada.wav
if [ $? -ne 0 ]; then
    echo "❌ Error al ejecutar convertir_audio_latino.py. Asegúrate de que el archivo de entrada existe y es válido."
    exit 1
fi
