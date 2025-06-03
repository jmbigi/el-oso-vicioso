import os

README_DIALOGOS = """# Carpeta de Diálogos

Aquí se almacenan los audios de los personajes en formato `.wav` para este capítulo.
"""

README_IMAGENES = """# Carpeta de Imágenes

Aquí se guardan las imágenes del storyboard y personajes en formatos `.png` o `.jpg` para este capítulo.
"""

README_VIDEOS = """# Carpeta de Videos

Aquí se almacenan los videos generados en formato `.mp4` para este capítulo.
"""

def crear_capitulo(temporada, capitulo):
    base = f"temporada_{temporada}/capitulo_{capitulo}"
    rutas = [
        f"{base}/dialogos",
        f"{base}/imagenes",
        f"{base}/videos"
    ]
    for ruta in rutas:
        os.makedirs(ruta, exist_ok=True)
    # Crear archivos README.md en cada subcarpeta
    with open(f"{base}/dialogos/README.md", "w", encoding="utf-8") as f:
        f.write(README_DIALOGOS)
    with open(f"{base}/imagenes/README.md", "w", encoding="utf-8") as f:
        f.write(README_IMAGENES)
    with open(f"{base}/videos/README.md", "w", encoding="utf-8") as f:
        f.write(README_VIDEOS)
    # Crear meta.json vacío si no existe
    meta_path = f"{base}/meta.json"
    if not os.path.exists(meta_path):
        with open(meta_path, "w", encoding="utf-8") as f:
            f.write('{\n  "temporada": %d,\n  "capitulo": %d\n}\n' % (temporada, capitulo))
    print(f"Estructura creada para temporada_{temporada}/capitulo_{capitulo}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Crea la estructura de carpetas para un capítulo de El Oso Vicioso.")
    parser.add_argument("--temp", type=int, required=True, help="Número de temporada")
    parser.add_argument("--cap", type=int, required=True, help="Número de capítulo")
    args = parser.parse_args()
    crear_capitulo(args.temp, args.cap)