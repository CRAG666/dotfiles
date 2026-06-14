---
name: redaccion-cientifica-es
description: 'Usar siempre que el usuario escriba, redacte, revise o traduzca texto científico/académico en ESPAÑOL: artículos, papers, tesis, abstracts, introducciones, metodologías, resultados, discusión, conclusiones, agradecimientos, revisiones de literatura, defensas, propuestas de investigación o cualquier sección IMRyD. Aporta más de 5000 frases "precocinadas" idiomáticas y formales para cada sección estándar de un documento científico, evitando la prosa robótica/IA. Disparadores: "escribe la introducción", "redacta el abstract", "ayúdame con la discusión", "mejora este párrafo científico", "tradúceme este paper", "redacta la metodología", "necesito frases para...", "esto suena a IA, mejóralo".'
---

# Redacción Científica en Español

## Cuándo usar este skill

Activar siempre que el usuario pida producir, corregir, mejorar o traducir texto científico-académico en español. La función central es **sustituir la prosa genérica/robótica que produce un LLM por defecto** por construcciones idiomáticas establecidas en la tradición académica hispana.

**NO activar para**: comentarios de código, docstrings, mensajes de commit, correos informales, copy de marketing, ficción, o redacción no académica en general. Si el usuario está escribiendo un post de blog o divulgación, pregunta antes de aplicar el registro académico - esos textos suelen requerir prosa más ligera y accesible.

## Principios fundamentales

No son reglas arbitrarias; cada una previene un patrón concreto que delata el texto como generado por IA o como redacción no nativa.

1. **Evitar las muletillas de IA.** Construcciones como "profundizar en", "navegar por las complejidades de", "tapiz de", "en el mundo actual", "es importante destacar que" se han convertido en huella estadística de los LLM. Marcan el texto como generado por IA ante cualquier lector (o detector) entrenado.
2. **Voz pasiva e impersonal.** En español científico se prefiere "se ha demostrado", "se realizó", "se obtuvo" sobre "demostramos" / "hicimos" - salvo en humanidades, donde la voz autorial sí es aceptable. Esta convención refleja siglos de tradición académica hispana.
3. **Cautela epistémica.** En ciencia se afirma con matiz. Usar "sugiere", "podría", "los datos parecen indicar" cuando proceda. Sobreafirmar es señal de redacción inexperta (o de IA). Ver `precaucion-y-hipotesis.md`.
4. **Conectores variados.** Repetir "además", "por lo tanto", "sin embargo" hace mecánica la prosa. Rotar con las alternativas de `conectores-y-tiempo.md`.
5. **Disciplina temporal.** Cada tiempo verbal señala un estatus epistémico distinto:
   - **Pasado simple / pretérito perfecto** para métodos y resultados específicos ("se midió", "Smith halló").
   - **Presente** para conocimiento establecido y lo que hace el paper actual ("los datos muestran", "este trabajo aborda").
   - **Pretérito perfecto compuesto** para el cuerpo acumulado de la literatura ("la investigación ha mostrado", "se ha estudiado").
6. **Gramática de cita.** Usar las construcciones de `referencias-y-citas.md` en lugar de "según [Autor]" repetido. Preferir verbos de reporte que marquen postura: argumenta, sostiene, plantea, demuestra, sugiere.
7. **Nada de emojis. Nada de negritas decorativas. Nada de bullets innecesarios** dentro del cuerpo del párrafo científico. Las viñetas solo son aceptables en enumeraciones genuinas (pasos de método, listas de condiciones).
8. **Voz activa cuando importa el agente; pasiva cuando importa la acción.** Ambas son defendibles; lo que cuenta es la consistencia dentro del documento.
9. **Puntuación ASCII - sin caracteres Unicode decorativos.** NO uses signos tipográficos Unicode en el texto que entregues. (Los caracteres de abajo se nombran por su código Unicode a propósito, para que esta misma regla siga siendo ASCII puro.) Sustitúyelos por su equivalente ASCII:
   - Raya (U+2014) y semirraya o guion largo (U+2013): usa un guion con espacios, una coma, dos puntos o paréntesis, según pida la frase. Nunca el glifo de raya: es la huella más delatora del texto generado por IA.
   - Comillas tipográficas o "inteligentes" (U+201C, U+201D, U+2018, U+2019) y comillas angulares (U+00AB, U+00BB): usa comillas rectas (" y ').
   - Puntos suspensivos (U+2026): usa tres puntos normales (...), o elimínalos.
   - Espacio de no separación (U+00A0), espacio fino (U+2009), espacio de ancho cero (U+200B): usa un espacio ASCII normal.
   - Viñetas (U+2022), flechas (U+2192, U+21D2), signo de multiplicación (U+00D7), signo menos (U+2212), punto medio (U+00B7): usa ASCII (-, ->, x, -) o escríbelo con palabras.

   La raya es una de las huellas más delatoras del texto generado por IA o copiado, y además rompe muchos sistemas de envío de revistas, flujos de LaTeX y codificaciones de texto plano.

   **IMPORTANTE - excepción del español:** esta regla NO afecta a los caracteres propios del idioma, que SÍ debes conservar siempre: letras acentuadas (`á é í ó ú`), diéresis (`ü`), la `ñ`, y los signos de apertura `¿` y `¡`. Estos no son adornos tipográficos: son ortografía obligatoria del español. La prohibición se limita a la puntuación y los símbolos decorativos Unicode, no a las letras.

## Cómo trabajar

1. **Identifica la sección** que el usuario necesita (Abstract, Introducción, Método, Resultados, Discusión, Conclusiones, o función transversal - comparar, definir, ser crítico, etc.).
2. **Lee SOLO el archivo de referencia relevante** de `references/` antes de redactar. No los cargues todos - cada uno tiene cientos de líneas.
3. **Elige frases del banco** y adáptalas al contexto del usuario sustituyendo las X, Y, Z y "Autor" por los términos reales.
4. **Combina y varía** - no encadenes tres frases del mismo subapartado seguidas; el texto debe fluir como prosa, no parecer un collage de frasebook.
5. **Entrega prosa terminada, no un menú de frases.** Por defecto, devuelve un párrafo pulido que el usuario pueda pegar en su documento. Solo devuelve listas de opciones si el usuario pide explícitamente "dame opciones" o "muéstrame alternativas".
6. Si la sección pedida no encaja con ningún archivo, lee `redaccion-critica.md` y `conectores-y-tiempo.md` - son transversales.

## Índice de referencias

Estructura IMRyD y secciones frontales:

- `agradecimientos-autores.md` - Agradecimientos, financiación, conflictos, sobre los autores, colaboradores.
- `introduccion.md` - Contexto, importancia, síntesis de literatura, problema, controversia, vacío de conocimiento, objetivos, hipótesis, estructura, limitaciones.
- `material-metodo.md` - Tipo de estudio, fuentes, diseño, justificación de metodología, muestra, procedimiento, instrumentos, limitaciones metodológicas.
- `resultados.md` - Referencia al método, presentación de datos, tablas/figuras, resultados positivos/negativos, inesperados, cuestionarios, datos cualitativos, síntesis.
- `discusion.md` - Antecedentes, vinculación con resultados, acuerdo, contradicción, apoyo en literatura previa, explicación, precaución, hipótesis tentativas, consecuencias, investigación futura.
- `conclusiones-abstract.md` - Resumen del contenido, sumario, reformulación del propósito, síntesis de hallazgos, limitaciones, implicaciones, impacto en la literatura, recomendaciones prácticas y políticas.

Funciones transversales (útiles en toda sección):

- `redaccion-critica.md` - Limitaciones argumentales, debilidades de un estudio, críticas generalizadas o a un autor concreto, sugerencias constructivas, adjetivos evaluativos.
- `clasificar-comparar.md` - Clasificaciones y listas; diferencias, similitudes, contrastes y correspondencias.
- `definir-causa-efecto.md` - Definiciones, dificultades de definición, definiciones de autores, excepciones, causalidad, correlación.
- `precaucion-y-hipotesis.md` - Distanciamiento del autor, hipotetización, cautela al hablar del presente/futuro, interpretación cautelosa, hipótesis, posibilidad/probabilidad, asunción, implicación, cuestiones retóricas.
- `puntos-de-vista.md` - Acuerdo/apoyo, desacuerdo/contra, exposición del propio punto de vista.
- `referencias-y-citas.md` - Evidencia general existente, referencias a investigación pasada y presente, evidencia con varios autores, referencias a un autor concreto, síntesis de fuentes, citas literales.
- `ejemplificar.md` - Ejemplos como información principal, casos como apoyo, lo que muestran los ejemplos.
- `conectores-y-tiempo.md` - Tiempo pasado/presente/futuro, duración, frecuencia, introducción y transición entre secciones, resumen de sección.
- `apoyo-contraste.md` - Contrastar el propio trabajo, apoyar un punto de vista, enunciar características, dar explicaciones.
- `orden-cantidad-cambio-interpretacion.md` - Cantidad, orden, cambio (aumento/decrecimiento), interpretación de hallazgos.

## Patrones idiomáticos clave (referencia rápida)

Para sustituir construcciones "de IA" frecuentes:

- En lugar de **"Este artículo explora..."** -> "Este estudio aborda...", "Este trabajo da cuenta de...", "El propósito de este estudio es...", "Este artículo se centra en...".
- En lugar de **"Es importante notar que..."** -> "Cabe señalar que...", "Conviene apuntar que...", "Merece la pena señalar que...", "Es importante tener en cuenta que...".
- En lugar de **"Los resultados muestran que..."** repetido -> alternar con "Los hallazgos sugieren...", "Los datos indican...", "Se desprende de los resultados que...", "Los resultados ponen de manifiesto...", "Se evidencia que...".
- En lugar de **"En conclusión,"** -> "Tomados en conjunto...", "Sintetizando...", "A la luz de estos resultados...", "Estos hallazgos sugieren, en general,...", "En síntesis...".
- En lugar de **"Como todos sabemos..."** -> eliminar; en ciencia no se apela al lector así. Sustituir por "Es ampliamente aceptado que..." o "La literatura coincide en que..." con cita.
- En lugar de **"Profundizar en..."** -> "Examinar con mayor detalle...", "Abordar en profundidad...", "Adentrarse en el estudio de...".

## Atribución

Banco basado en *5000 frases precocinadas para textos científicos* de Pedro Margolles García (NeoScientia.com), licencia CC BY-NC; a su vez inspirado en *Academic Phrasebank* (Morley, 2014) y *PhraseBook for Writing Papers and Research in English* (Howe & Henriksson, 2007).
