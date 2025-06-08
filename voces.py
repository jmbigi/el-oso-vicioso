import asyncio
import edge_tts

async def main():
    opciones = [
        # México
        ("es-MX-JorgeNeural", "voz_mex_masc.wav",
         "Hola, soy Jorge, voz masculina mexicana. ¿Cómo estás? Este es un ejemplo para clonación de voz. "
         "Me gusta el café por las mañanas y escuchar música los fines de semana. ¡Vamos a comenzar con la grabación!"),
        ("es-MX-DaliaNeural", "voz_mex_fem.wav",
         "Hola, soy Dalia, voz femenina mexicana. ¿Listos para una nueva aventura? "
         "Hoy es un gran día para aprender algo nuevo. ¡Ánimo y mucha suerte!"),
        # Colombia
        ("es-CO-GonzaloNeural", "voz_col_masc.wav",
         "Hola, soy Gonzalo, voz masculina colombiana. Me encanta caminar por las montañas y disfrutar de un buen café. "
         "Esta grabación servirá para entrenar un modelo de clonación de voz. ¡Saludos desde Colombia!"),
        ("es-CO-SalomeNeural", "voz_col_fem.wav",
         "Hola, soy Salomé, voz femenina colombiana. ¿Qué tal todo? Espero que tengas un excelente día. "
         "Recuerda siempre sonreír y seguir aprendiendo. ¡Hasta pronto!"),
        # Argentina
        ("es-AR-TomasNeural", "voz_arg_masc.wav",
         "Hola, soy Tomás, voz masculina argentina. ¿Cómo andás? Este es un texto de ejemplo para clonación de voz. "
         "Me gusta el mate y salir a correr por la ciudad. ¡Nos vemos pronto!"),
        ("es-AR-ElenaNeural", "voz_arg_fem.wav",
         "Hola, soy Elena, voz femenina argentina. ¿Todo bien? Estoy grabando este mensaje para que puedas usarlo en tu proyecto de clonación de voz. "
         "¡Un abrazo grande desde Buenos Aires!"),
        # Chile
        ("es-CL-CatalinaNeural", "voz_chile_fem.wav",
         "Hola, soy Catalina, voz femenina chilena. ¿Cómo te va? Este audio es para entrenar un sistema de clonación de voz. "
         "Me encanta la playa y las empanadas. ¡Que tengas un lindo día!"),
        ("es-CL-LorenzoNeural", "voz_chile_masc.wav",
         "Hola, soy Lorenzo, voz masculina chilena. Aquí va un texto variado para que puedas clonar mi voz. "
         "Disfruta del proceso y recuerda siempre practicar. ¡Nos vemos!"),
        # Perú
        ("es-PE-AlexNeural", "voz_peru_masc.wav",
         "Hola, soy Alex, voz masculina peruana. Este mensaje es para ayudarte a crear una clonación de voz precisa. "
         "Me gusta la comida peruana y pasear por Lima. ¡Hasta luego!"),
        ("es-PE-CamilaNeural", "voz_peru_fem.wav",
         "Hola, soy Camila, voz femenina peruana. Estoy grabando este texto para que puedas usarlo en tu proyecto de clonación de voz. "
         "Espero que te sirva mucho. ¡Saludos desde Perú!"),
        # Estados Unidos (español)
        ("es-US-AlonsoNeural", "voz_us_alonso.wav",
         "Hola, soy Alonso, voz masculina hispana en Estados Unidos. Me gusta viajar y conocer nuevas culturas. "
         "Este mensaje es para que puedas entrenar un sistema de clonación de voz en español latino. ¡Mucho éxito en tu proyecto!"),
        ("es-US-PalomaNeural", "voz_us_paloma.wav",
         "Hola, soy Paloma, voz femenina hispana en Estados Unidos. ¿Cómo te encuentras hoy? "
         "Estoy grabando este texto para que puedas usarlo en tus experimentos de clonación de voz. ¡Saludos cordiales!"),
        # Estados Unidos (inglés)
        ("en-US-GuyNeural", "voz_enus_guy.wav",
         "Hello, I am Guy, an American male voice. This is a sample for voice cloning. "
         "I enjoy reading books in the evening and going for a walk in the park. Let's get started with the recording!"),
        ("en-US-JennyNeural", "voz_enus_jenny.wav",
         "Hello, I am Jenny, an American female voice. Are you ready for a new adventure? "
         "Today is a great day to learn something new. Good luck and have fun!"),
        # Inglaterra (inglés)
        ("en-GB-RyanNeural", "voz_engb_ryan.wav",
         "Hello, I am Ryan, a British male voice. I love drinking tea in the afternoon and listening to music on weekends. "
         "This recording will help you train a voice cloning model. Cheers from London!"),
        ("en-GB-SoniaNeural", "voz_engb_sonia.wav",
         "Hello, I am Sonia, a British female voice. How are you doing? I hope you have a wonderful day. "
         "Remember to always smile and keep learning. See you soon!"),
    ]
    for voice, filename, text in opciones:
        print(f"Generando voces_gen_base/{filename} con voz {voice}...")
        await edge_tts.Communicate(text, voice).save('voces_gen_base/' + filename)
    print("Todos los audios han sido generados correctamente.")

if __name__ == "__main__":
    asyncio.run(main())
