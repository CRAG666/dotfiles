---
name: redaccion-cientifica-es
description: Usar siempre que el usuario escriba, redacte, revise o traduzca texto científico/académico en ESPAÑOL — artículos, papers, tesis, abstracts, introducciones, metodologías, resultados, discusión, conclusiones, agradecimientos, revisiones de literatura, defensas, propuestas de investigación o cualquier sección IMRyD. Aporta más de 5000 frases "precocinadas" idiomáticas y formales para cada sección estándar de un documento científico, evitando la prosa robótica/IA. Disparadores: "escribe la introducción", "redacta el abstract", "ayúdame con la discusión", "mejora este párrafo científico", "tradúceme este paper", "redacta la metodología", "necesito frases para...", "esto suena a IA, mejóralo".
---

# Redacción Científica en Español

## Cuándo usar este skill

Activar SIEMPRE que el usuario pida producir, corregir o mejorar texto científico-académico en español. La función central es **sustituir la prosa genérica/robótica que produce un LLM por defecto** por construcciones idiomáticas establecidas en la tradición académica hispana.

## Principios irrenunciables

1. **Nunca empezar frases con "delve", "navigate", "tapestry", "in conclusion", "in summary"** ni sus equivalentes españoles ("profundizar", "navegar", "tapiz", "en conclusión" usado como muletilla).
2. **Voz pasiva e impersonal**: en español científico se prefiere "se ha demostrado", "se realizó", "se obtuvo" sobre "demostramos" / "hicimos" (salvo en humanidades).
3. **Conectores variados**: no abusar de "además", "por lo tanto", "sin embargo". Rotar con las frases del archivo `conectores-y-tiempo.md`.
4. **Cautela epistémica**: en ciencia se afirma con matiz. Usar "sugiere", "podría", "los datos parecen indicar" cuando proceda — ver `precaucion-y-hipotesis.md`.
5. **Cita y atribución**: usar las construcciones de `referencias-y-citas.md` en lugar de "según [Autor]" repetido.
6. **Nada de emojis. Nada de negritas decorativas. Nada de bullets innecesarios** dentro del cuerpo del texto científico.
7. **Coherencia temporal**: pasado para métodos y resultados; presente para conclusiones generales y descripciones de la literatura establecida; ver `conectores-y-tiempo.md`.

## Cómo trabajar

1. **Identifica la sección** que el usuario necesita (Abstract, Introducción, Método, Resultados, Discusión, Conclusiones, o función transversal — comparar, definir, ser crítico, etc.).
2. **Lee SOLO el archivo de referencia relevante** de `references/` antes de redactar. No los cargues todos.
3. **Elige frases del banco** y adáptalas al contexto del usuario sustituyendo las X, Y, Z y "Autor" por los términos reales.
4. **Combina y varía** — no encadenes tres frases del mismo subapartado seguidas; el texto debe fluir, no parecer un collage.
5. Si la sección que pide el usuario no encaja con ningún archivo, lee `redaccion-critica.md` y `conectores-y-tiempo.md` que son transversales.

## Índice de referencias

Estructura IMRyD y secciones frontales:

- `agradecimientos-autores.md` — Agradecimientos, financiación, conflictos, sobre los autores, colaboradores.
- `introduccion.md` — Contexto, importancia, síntesis de literatura, problema, controversia, vacío de conocimiento, objetivos, hipótesis, estructura, limitaciones.
- `material-metodo.md` — Tipo de estudio, fuentes, diseño, justificación de metodología, muestra, procedimiento, instrumentos, limitaciones metodológicas.
- `resultados.md` — Referencia al método, presentación de datos, tablas/figuras, resultados positivos/negativos, inesperados, cuestionarios, datos cualitativos, síntesis.
- `discusion.md` — Antecedentes, vinculación con resultados, acuerdo, contradicción, apoyo en literatura previa, explicación, precaución, hipótesis tentativas, consecuencias, investigación futura.
- `conclusiones-abstract.md` — Resumen del contenido, sumario, reformulación del propósito, síntesis de hallazgos, limitaciones, implicaciones, impacto en la literatura, recomendaciones prácticas y políticas.

Funciones transversales (útiles en toda sección):

- `redaccion-critica.md` — Limitaciones argumentales, debilidades de un estudio, críticas generalizadas o a un autor concreto, sugerencias constructivas, adjetivos evaluativos.
- `clasificar-comparar.md` — Clasificaciones y listas; diferencias, similitudes, contrastes y correspondencias.
- `definir-causa-efecto.md` — Definiciones, dificultades de definición, definiciones de autores, excepciones, causalidad, correlación.
- `precaucion-y-hipotesis.md` — Distanciamiento del autor, hipotetización, cautela al hablar del presente/futuro, interpretación cautelosa, hipótesis, posibilidad/probabilidad, asunción, implicación, cuestiones retóricas.
- `puntos-de-vista.md` — Acuerdo/apoyo, desacuerdo/contra, exposición del propio punto de vista.
- `referencias-y-citas.md` — Evidencia general existente, referencias a investigación pasada y presente, evidencia con varios autores, referencias a un autor concreto, síntesis de fuentes, citas literales.
- `ejemplificar.md` — Ejemplos como información principal, casos como apoyo, lo que muestran los ejemplos.
- `conectores-y-tiempo.md` — Tiempo pasado/presente/futuro, duración, frecuencia, introducción y transición entre secciones, resumen de sección.
- `apoyo-contraste.md` — Contrastar el propio trabajo, apoyar un punto de vista, enunciar características, dar explicaciones.
- `orden-cantidad-cambio-interpretacion.md` — Cantidad, orden, cambio (aumento/decrecimiento), interpretación de hallazgos.

## Patrones idiomáticos clave (referencia rápida)

Para sustituir construcciones "de IA" frecuentes:

- En lugar de **"Este artículo explora..."** → "Este estudio aborda…", "Este trabajo da cuenta de…", "El propósito de este estudio es…", "Este artículo se centra en…".
- En lugar de **"Es importante notar que..."** → "Cabe señalar que…", "Conviene apuntar que…", "Merece la pena señalar que…", "Es importante tener en cuenta que…".
- En lugar de **"Los resultados muestran que..."** repetido → alternar con "Los hallazgos sugieren…", "Los datos indican…", "Se desprende de los resultados que…", "Los resultados ponen de manifiesto…", "Se evidencia que…".
- En lugar de **"En conclusión,"** → "Tomados en conjunto…", "Sintetizando…", "A la luz de estos resultados…", "Estos hallazgos sugieren, en general,…", "En síntesis…".
- En lugar de **"Como todos sabemos..."** → eliminar; en ciencia no se apela al lector así. Sustituir por "Es ampliamente aceptado que…" o "La literatura coincide en que…" con cita.
- En lugar de **"Profundizar en..."** → "Examinar con mayor detalle…", "Abordar en profundidad…", "Adentrarse en el estudio de…".

## Atribución

Banco basado en *5000 frases precocinadas para textos científicos* de Pedro Margolles García (NeoScientia.com), licencia CC BY-NC; a su vez inspirado en *Academic Phrasebank* (Morley, 2014) y *PhraseBook for Writing Papers and Research in English* (Howe & Henriksson, 2007).
