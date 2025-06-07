import asyncio
import edge_tts

async def main():
    voice = "es-MX-JorgeNeural"  # Voz latina mexicana
    text = ("Hola, esta es una muestra de voz latina para clonación. "
            "Este audio está preparado para usarse en modelos de síntesis de voz.")
    await edge_tts.Communicate(text, voice).save("voz_latina.wav")
    print("Archivo 'voz_latina.wav' generado correctamente.")

if __name__ == "__main__":
    asyncio.run(main())
