set -e
# ---------------------------------------------------
# 🎨 PASO 3: INSTALAR FOOOCUS (imágenes SD)
# ---------------------------------------------------
git clone https://github.com/lllyasviel/Fooocus.git
cd Fooocus
python3 -m venv venv
source venv/bin/activate
pip install Fooocus
#pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
#pip install -r requirements.txt
