#!/bin/bash
set -e
# ---------------------------------------------------
# 🎨 PASO 3: INSTALAR FOOOCUS (imágenes SD)
# ---------------------------------------------------

# 1. Clonar Fooocus si no existe
if [ ! -d "Fooocus" ]; then
    echo "📦 Clonando Fooocus desde GitHub..."
    git clone https://github.com/lllyasviel/Fooocus.git
fi

# 2. Verificar carpeta Fooocus
if [ ! -d "Fooocus" ]; then
  echo "❌ Error: No se pudo encontrar la carpeta 'Fooocus'."
  exit 1
fi

# 3. Entrar al directorio
cd Fooocus

# 4. Crear entorno virtual si no existe
if [ ! -d "venv" ]; then
  echo "🐍 Creando entorno virtual..."
  python3 -m venv venv
fi

# 5. Activar entorno
echo "⚙️ Activando entorno virtual..."
source venv/bin/activate

# 6. Instalar dependencias
echo "📥 Instalando dependencias..."
pip install --upgrade pip
pip install -r requirements_versions.txt

# 7. Ejecutar Fooocus
echo "🚀 Ejecutando Fooocus en modo lowvram en el puerto 7860..."
export PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:32
python3 entry_with_update.py --port 7860 --always-low-vram > fooocus.log 2>&1
