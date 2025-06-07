# ---------------------------------------------------
# 🐻 PASO 1: PREPARACIÓN DEL SISTEMA (Ubuntu 24.04)
# ---------------------------------------------------

# Actualizar sistema (con -y para confirmar automáticamente)
sudo apt update && sudo apt upgrade -y

# Instalar dependencias esenciales (con -y)
sudo apt install -y git python3 python3-pip ffmpeg wget curl build-essential python3-venv nvidia-cuda-toolkit

# Verificar que nvidia-smi exista y detecte GPU Nvidia
if ! command -v nvidia-smi &> /dev/null || ! nvidia-smi | grep -q -E "Tesla|GeForce|Quadro"; then
  echo "NVIDIA drivers o GPU no detectados. Instala drivers antes de continuar."
  exit 1
fi

# ---------------------------------------------------
# 🧠 PASO 2: INSTALAR OLLAMA (para guiones IA)
# ---------------------------------------------------

# Instalar Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Descargar modelo ligero (Phi-3 para 4GB VRAM)
ollama pull phi3

# Probar generación de texto
ollama run phi3 "Escribe un chiste sobre un oso que apuesta"

# ---------------------------------------------------
# 🎨 PASO 3: INSTALAR FOOOCUS (imágenes SD)
# ---------------------------------------------------

# Ejecutar script de instalación Fooocus (asegúrate que tenga permisos de ejecución)
bash ./install_fooocus.sh

# ---------------------------------------------------
# 🎙️ PASO 4: INSTALAR TTS (voces XTTS-v2)
# ---------------------------------------------------

bash ./install_tts.sh

# ---------------------------------------------------
# 📦 PASO 5: CONFIGURAR PROYECTO
# ---------------------------------------------------

cd ~ || exit 1

# Clonar el repositorio (verifica que exista)
git clone https://github.com/tu-usuario/el-oso-vicioso.git || { echo "Error al clonar repo"; exit 1; }
cd el-oso-vicioso || exit 1

# Crear entorno virtual para el proyecto
python3 -m venv .venv

# Activar entorno virtual
source .venv/bin/activate

# Actualizar pip y luego instalar dependencias
pip install --upgrade pip
pip install -r requirements.txt

# ---------------------------------------------------
# ⚙️ PASO 6: CONFIGURACIÓN PERSONALIZADA
# ---------------------------------------------------

# Crear config.json con configuración mínima
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

# Generar solo el capítulo piloto (temporada 1, capítulo 1)
python3 generar_serie.py --temp 1 --cap 1

# Generar toda la serie en segundo plano y guardar log
nohup python3 generar_serie.py > registro.log 2>&1 &

# Mostrar progreso en tiempo real (puedes detener con Ctrl+C)
tail -f registro.log

# ---------------------------------------------------
# 🔍 PASO 8: VER RESULTADOS
# ---------------------------------------------------

# Mostrar estructura generada del capítulo piloto
ls -R temporada_1/capitulo_1/

# Reproducir vídeo short del capítulo piloto
ffplay temporada_1/capitulo_1/video_short.mp4
