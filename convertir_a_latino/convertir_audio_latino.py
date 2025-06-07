#!/usr/bin/env python3
import os, sys, wave, json, re
from vosk import Model, KaldiRecognizer
from pydub import AudioSegment

# Importa para evitar error con PyTorch y TTS
import torch.serialization
from TTS.utils.radam import RAdam

from TTS.api import TTS

# Añade RAdam a la lista segura para torch.load
torch.serialization.add_safe_globals([RAdam])

# Ruta al modelo Vosk
VOSK_MODEL_PATH = os.path.expanduser("~/modelos/vosk/vosk-model-small-es-0.42")

def transcribe(audio_file):
    if not os.path.exists(VOSK_MODEL_PATH):
        print(f"❌ Modelo Vosk no encontrado en {VOSK_MODEL_PATH}")
        sys.exit(1)

    sound = AudioSegment.from_file(audio_file)
    sound = sound.set_channels(1).set_frame_rate(16000)
    temp_wav = "temp.wav"
    sound.export(temp_wav, format="wav")

    wf = wave.open(temp_wav, "rb")
    model = Model(VOSK_MODEL_PATH)
    rec = KaldiRecognizer(model, wf.getframerate())
    result = ""
    while True:
        data = wf.readframes(4000)
        if not data:
            break
        if rec.AcceptWaveform(data):
            res = json.loads(rec.Result())
            result += res.get("text", "") + " "
    final = json.loads(rec.FinalResult())
    result += final.get("text", "")
    os.remove(temp_wav)
    return result.strip()

def reemplazar_pronunciacion(texto):
    texto = re.sub(r'z', 's', texto, flags=re.IGNORECASE)
    texto = re.sub(r'c(?=[ei])', 's', texto, flags=re.IGNORECASE)
    return texto

def sintetizar(texto, archivo_salida="salida_latino.wav"):
    tts = TTS(model_name="tts_models/es/mai/tacotron2-DDC", progress_bar=False)
    tts.tts_to_file(text=texto, file_path=archivo_salida)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python3 convertir_audio_latino.py archivo_entrada.mp3")
        sys.exit(1)

    entrada = sys.argv[1]
    if not os.path.exists(entrada):
        print(f"❌ Archivo no encontrado: {entrada}")
        sys.exit(1)

    print("🎙️ Transcribiendo...")
    texto = transcribe(entrada)
    print("📝 Texto detectado:", texto)

    print("🔁 Reemplazando pronunciación...")
    texto_mod = reemplazar_pronunciacion(texto)
    print("🗣️ Texto corregido:", texto_mod)

    print("🎧 Sintetizando nuevo audio...")
    sintetizar(texto_mod)
    print("✅ Audio generado: salida_latino.wav")
