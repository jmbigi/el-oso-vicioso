#!/bin/bash
set -e
set -x

# Variables configurables
PYTHON_VERSION="3.10"
WAV_FILE="./mi_voz.wav"
VENV_DIR="venv"
TORCH_VERSION="2.1.2"
AUDIO_VERSION="2.1.2"
TTS_VERSION="0.21.2"
TRANSFORMERS_VERSION="4.37.2"

# Verificar e instalar Python 3.10
if ! command -v python3.10 &> /dev/null; then
    echo "Instalando Python ${PYTHON_VERSION}..."
    sudo apt update
    sudo apt install -y python3.10 python3.10-venv python3.10-distutils
fi

# Clonar el repositorio TTS si no existe
if [ ! -d "TTS" ]; then
    git clone https://github.com/coqui-ai/TTS.git
fi

cd TTS

# Crear entorno virtual si no existe
if [ ! -d "$VENV_DIR" ]; then
    echo "Creando entorno virtual con Python ${PYTHON_VERSION}..."
    python3.10 -m venv "$VENV_DIR"
fi

# Activar entorno virtual
source "$VENV_DIR/bin/activate"

# Actualizar pip y herramientas base
python -m pip install --upgrade pip setuptools wheel

# Instalar torch y torchaudio si es necesario
INSTALLED_TORCH=$(pip show torch | grep Version | awk '{print $2}' || echo "")
INSTALLED_AUDIO=$(pip show torchaudio | grep Version | awk '{print $2}' || echo "")

if [[ "$INSTALLED_TORCH" != "$TORCH_VERSION" ]] || [[ "$INSTALLED_AUDIO" != "$AUDIO_VERSION" ]]; then
    echo "Instalando torch y torchaudio..."
    pip install torch==$TORCH_VERSION torchaudio==$AUDIO_VERSION --index-url https://download.pytorch.org/whl/cu118
else
    echo "✅ torch y torchaudio ya están en la versión correcta."
fi

# Instalar TTS y transformers si es necesario
INSTALLED_TTS=$(pip show TTS | grep Version | awk '{print $2}' || echo "")
INSTALLED_TRANSFORMERS=$(pip show transformers | grep Version | awk '{print $2}' || echo "")

if [[ "$INSTALLED_TTS" != "$TTS_VERSION" ]] || [[ "$INSTALLED_TRANSFORMERS" != "$TRANSFORMERS_VERSION" ]]; then
    echo "Instalando TTS y transformers..."
    pip install TTS==$TTS_VERSION transformers==$TRANSFORMERS_VERSION
else
    echo "✅ TTS y transformers ya están en la versión correcta."
fi

# Mostrar modelos disponibles
tts --list_models

# Verificar existencia del archivo de voz
if [ ! -f "$WAV_FILE" ]; then
    echo "❌ No se encontró el archivo de referencia '$WAV_FILE'."
    echo "✅ Por favor graba un archivo de voz de ~3 segundos y guárdalo como '$WAV_FILE' en el directorio."
    echo "   Ejemplo: arecord -d 3 -f cd -r 22050 $WAV_FILE"
fi

# Función para ejecutar síntesis
function synthesize() {
    local model_name="$1"
    local text="$2"
    local out_path="$3"
    local speaker_wav="$4"
    shift 4
    local extra_args=("$@")

    echo "▶ Sintetizando con modelo: $model_name"

    if [ -n "$speaker_wav" ] && [ -f "$speaker_wav" ]; then
        tts --model_name "$model_name" \
            --text "$text" \
            --speaker_wav "$speaker_wav" \
            --out_path "$out_path" \
            "${extra_args[@]}"
    else
        tts --model_name "$model_name" \
            --text "$text" \
            --out_path "$out_path" \
            "${extra_args[@]}"
    fi
}

# Síntesis con XTTS_V2 (voz propia, español latino, vocoder WaveGrad universal)
if [ -f "$WAV_FILE" ]; then
    synthesize "tts_models/multilingual/multi-dataset/xtts_v2" \
        "Hola mundo, esta es una prueba en español latinoamericano con vos propia y vosoder WaveGrad." \
        "prueba_xtts_wavegrad_latam.wav" "$WAV_FILE" --language_idx "es" --vocoder_name "vocoder_models/universal/libri-tts/wavegrad"
else
    echo "⚠️ No se encontró '$WAV_FILE', saltando síntesis con voz propia."
fi

# Voces masculinas españolas preentrenadas
synthesize "tts_models/es/css10/vits" \
    "Hola, esta es la voz masculina española CSS10." \
    "prueba_css10_masc.wav" ""

synthesize "tts_models/es/mai/tacotron2-DDC" \
    "Hola, esta es la voz femenina española MAI tacotron2." \
    "prueba_mai_tacotron2_fem.wav" ""

# Voz masculina italiana MAI
synthesize "tts_models/it/mai_male/vits" \
    "Hola, esta es una voz masculina italiana proveniente del modelo MAI Male." \
    "prueba_mai_masc.wav" ""

echo "✅ Todas las síntesis han finalizado."
