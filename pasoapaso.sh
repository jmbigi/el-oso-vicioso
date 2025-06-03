# ---------------------------------------------------
# 🐻 PASO 1: PREPARACIÓN DEL SISTEMA (Ubuntu 24.04)
# ---------------------------------------------------

# Actualizar sistema
sudo apt update && sudo apt upgrade

# Instalar dependencias esenciales

sudo apt install git python3 python3-pip ffmpeg wget curl build-essential python3-venv nvidia-cuda-toolkit

# Verificar GPU (debe mostrar tus 4GB VRAM)
nvidia-smi

# ---------------------------------------------------
# 🧠 PASO 2: INSTALAR OLLAMA (para guiones IA)
# ---------------------------------------------------

# Instalar Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Descargar modelo ligero (Phi-3 para 4GB)
ollama pull phi3

# Probar generación de texto
ollama run phi3 "Escribe un chiste sobre un oso que apuesta"

# ---------------------------------------------------
# 🎨 PASO 3: INSTALAR FOOOCUS (imágenes SD)
# ---------------------------------------------------

# Clonar repositorio
git clone https://github.com/lllyasviel/Fooocus.git
cd Fooocus

# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependencias (usaremos torch con CUDA 12.1)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# Probar Fooocus en modo low-RAM (abrirá interfaz web)
python3 entry_with_update.py --port 7860 --lowvram

# ---------------------------------------------------
# 🎙️ PASO 4: INSTALAR TTS (voces XTTS-v2)
# ---------------------------------------------------

cd ~
git clone https://github.com/coqui-ai/TTS.git
cd TTS

# Instalar en modo desarrollo
pip install -e .

# Descargar modelo de voces en español
tts --model_name tts_models/multilingual/multi-dataset/xtts_v2 --list_models

# ---------------------------------------------------
# 📦 PASO 5: CONFIGURAR PROYECTO
# ---------------------------------------------------

cd ~
git clone https://github.com/tu-usuario/el-oso-vicioso.git
cd el-oso-vicioso

# Crear entorno virtual para el proyecto
python3 -m venv .venv
source .venv/bin/activate

# Instalar dependencias Python
pip install -r requirements.txt

# ---------------------------------------------------
# ⚙️ PASO 6: CONFIGURACIÓN PERSONALIZADA
# ---------------------------------------------------

# Editar config.json (ejemplo mínimo)
cat > config.json <<EOL
{
  "modelo_texto": "phi3",
  "modelo_voz": "xtts_v2",
  "resolucion": "512x512",
  "estilo_imagen": "anime",
  "personajes": {
    "oso": {
      "voz": "assets/voces/oso_ref.wav",
      "emociones": ["eufórico", "triste"]
    }
  }
}
EOL

# ---------------------------------------------------
# 🚀 PASO 7: EJECUCIÓN AUTOMÁTICA
# ---------------------------------------------------

# Generar solo el capítulo piloto (para prueba)
python3 generar_serie.py --temp 1 --cap 1

# Generar toda la serie en segundo plano
nohup python3 generar_serie.py > registro.log &

# Ver progreso
tail -f registro.log

# ---------------------------------------------------
# 🔍 PASO 8: VER RESULTADOS
# ---------------------------------------------------

# Estructura generada
ls -R Temporada_1/Capitulo_1/

# Reproducir vídeo short
ffplay Temporada_1/Capitulo_1/video_short.mp4
