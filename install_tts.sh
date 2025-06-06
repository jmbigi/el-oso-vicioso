set -e
# ---------------------------------------------------
# 🎙️ PASO 4: INSTALAR TTS (voces XTTS-v2)
# ---------------------------------------------------
git clone https://github.com/coqui-ai/TTS.git
cd TTS
#rm -rd venv
python3.11 -m venv venv
source venv/bin/activate
#pip install -e .
pip install TTS
tts --list_models
tts --model_name tts_models/multilingual/multi-dataset/xtts_v2 --text "Hola mundo" --out_path prueba.wav
