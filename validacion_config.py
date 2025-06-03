import json
import jsonschema
from jsonschema import validate

schema = {
    "type": "object",
    "properties": {
        "temporadas": {"type": "integer", "minimum": 1},
        "capitulos_por_temporada": {"type": "integer", "minimum": 1},
        "idioma": {"type": "string"},
        "modelo_guion": {"type": "string"},
        "modelo_voz": {"type": "string"},
        "modelo_imagen": {"type": "string"}
    },
    "required": ["temporadas", "capitulos_por_temporada", "idioma"]
}

def validar_config(path="config.json"):
    with open(path, "r", encoding="utf-8") as f:
        config = json.load(f)
    validate(instance=config, schema=schema)
    print("config.json válido.")

if __name__ == "__main__":
    validar_config()