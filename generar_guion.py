import json
import os

def cargar_guion(temporada, capitulo):
    ruta = f"Temporada_{temporada}/Capitulo_{capitulo}/meta.json"
    if not os.path.exists(ruta):
        raise FileNotFoundError(f"No se encontró el archivo: {ruta}")
    
    with open(ruta, "r", encoding="utf-8") as f:
        guion = json.load(f)
    return guion

# Ejemplo de uso:
guion_cap1 = cargar_guion(1, 1)
print(f"Título del capítulo: {guion_cap1['titulo']}")
print(f"Resumen: {guion_cap1['resumen']}")
