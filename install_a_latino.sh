#!/bin/bash
set -e

echo "🔧 Instalando dependencias del sistema..."
sudo apt update
sudo apt install -y ffmpeg python3 python3-venv git unzip wget

echo "📁 Creando carpeta ./convertir_a_latino y entorno virtual..."
mkdir -p convertir_a_latino
cd convertir_a_latino

if [ ! -d "venv" ]; then
    echo "🔒 Entorno virtual no encontrado. Creando..."
    python3 -m venv venv
else
    echo "✅ Entorno virtual ya existe. Usando el existente."
fi

echo "🐍 Activando entorno virtual y actualizando pip..."
source venv/bin/activate
pip install --upgrade pip

echo "📦 Instalando paquetes Python en el entorno virtual..."
pip install vosk pydub TTS soundfile

echo "⬇️ Descargando modelo Vosk (si no existe)..."
mkdir -p ~/modelos/vosk
cd ~/modelos/vosk
if [ ! -d "vosk-model-small-es-0.42" ]; then
    wget https://alphacephei.com/vosk/models/vosk-model-small-es-0.42.zip
    unzip vosk-model-small-es-0.42.zip
fi
cd -

echo "✅ Instalación completada."
echo ""
echo "Para usar el script:"
echo "1. Activa el entorno:"
echo "   source convertir_a_latino/venv/bin/activate"
echo ""
echo "2. Ejecuta el script con:"
echo "   python3 convertir_audio_latino.py archivo.mp3"
