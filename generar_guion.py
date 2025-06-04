import json
import os
import argparse

def cargar_guion(temporada, capitulo):
    """
    Carga el guion de un capítulo específico.
    """
    ruta = f"temporada_{temporada}/capitulo_{capitulo}/meta.json"
    if not os.path.exists(ruta):
        raise FileNotFoundError(f"No se encontró el archivo: {ruta}")
    with open(ruta, "r", encoding="utf-8") as f:
        guion = json.load(f)
    return guion

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Carga y muestra el guion de un capítulo.")
    parser.add_argument("--temp", type=int, required=True, help="Número de temporada")
    parser.add_argument("--cap", type=int, required=True, help="Número de capítulo")
    args = parser.parse_args()

    try:
        guion = cargar_guion(args.temp, args.cap)
        print(f"Título del capítulo: {guion.get('titulo', 'Sin título')}")
        print(f"Resumen: {guion.get('resumen', 'Sin resumen')}")
    except FileNotFoundError as e:
        print(e)
    except json.JSONDecodeError:
        print("Error: El archivo meta.json no es un JSON válido.")
    except Exception as e:
        print(f"Error inesperado: {e}")
