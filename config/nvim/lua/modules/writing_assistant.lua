local M = {}

local function insert_text(text)
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1] - 1
  local col = pos[2]

  local current_line = vim.api.nvim_get_current_line()

  local word_end = col
  if col < #current_line then
    local rest_of_line = string.sub(current_line, col + 1)
    local next_space = string.find(rest_of_line, "%s") or #rest_of_line + 1
    if string.match(string.sub(rest_of_line, 1, 1), "%S") then
      word_end = col + next_space - 1
    end
  end

  local line_start = string.sub(current_line, 1, word_end)
  local line_end = string.sub(current_line, word_end + 1)

  local modified_text = text
  if word_end > 0 and not string.match(line_start, "%s$") then
    modified_text = " " .. text
  end

  if string.match(modified_text, "%s$") and string.match(line_end, "^%s") then
    line_end = string.sub(line_end, 2)
  end

  local new_line = line_start .. modified_text .. line_end

  vim.api.nvim_set_current_line(new_line)

  vim.api.nvim_win_set_cursor(0, { line + 1, word_end + #modified_text })
end

M.snippets = {
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "Cada vez es más difícil ignorar…",
    content = "Cada vez es más difícil ignorar…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X es el/la principal…",
    content = "X es el/la principal…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X es un Y común caracterizado por…",
    content = "X es un Y común caracterizado por…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X desempeña un papel importante en…",
    content = "X desempeña un papel importante en…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X, importante componente para Y, juega un papel clave en Z…",
    content = "X, importante componente para Y, juega un papel clave en Z…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "En el Ambito, X se ha convertido en un aspecto central para…",
    content = "En el Ambito, X se ha convertido en un aspecto central para…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "En Ambito, X ha sido considerado como un factor clave en…",
    content = "En Ambito, X ha sido considerado como un factor clave en…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X es uno de los Y más utilizados/estudiados/investigados/analizados…",
    content = "X es uno de los Y más utilizados/estudiados/investigados/analizados…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X es el Y más potente conocido…",
    content = "X es el Y más potente conocido…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X es un gran problema para Y y la principal causa de Z…",
    content = "X es un gran problema para Y y la principal causa de Z…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X se posiciona cada vez más como…",
    content = "X se posiciona cada vez más como…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X está cada vez más instituido como…",
    content = "X está cada vez más instituido como…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X se establece como…",
    content = "X se establece como…",
  },
  {
    tag = "3 Introduccion  1 Contexto e importancia del tema (Para la sociedad)",
    title = "X se está convirtiendo rápidamente en Y para Z…",
    content = "X se está convirtiendo rápidamente en Y para Z…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "X es un área que cobra cada vez más importancia en…",
    content = "X es un área que cobra cada vez más importancia en…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "La investigación sobre X es una preocupación constante dentro de…",
    content = "La investigación sobre X es una preocupación constante dentro de…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "Central a toda la disciplina de X encontramos…",
    content = "Central a toda la disciplina de X encontramos…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "X se encuentra en el corazón de nuestra comprensión de…",
    content = "X se encuentra en el corazón de nuestra comprensión de…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "X e Y han sido objeto de investigación desde…",
    content = "X e Y han sido objeto de investigación desde…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "Actualmente, uno de los debates más significativos en el campo de X es…",
    content = "Actualmente, uno de los debates más significativos en el campo de X es…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "Un aspecto clave de X es…",
    content = "Un aspecto clave de X es…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "X es un área de gran interés dentro del campo de…",
    content = "X es un área de gran interés dentro del campo de…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "X ha recibido considerable atención crítica desde…",
    content = "X ha recibido considerable atención crítica desde…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "X es un problema clásico en…",
    content = "X es un problema clásico en…",
  },
  {
    tag = "3 Introduccion  2 Contexto e importancia del tema (Para la disciplina)",
    title = "X ha sido estudiado por muchos investigadores que usan…",
    content = "X ha sido estudiado por muchos investigadores que usan…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "Los recientes desarrollos en el campo de X han estimulado la necesidad de…",
    content = "Los recientes desarrollos en el campo de X han estimulado la necesidad de…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "En los últimos años, ha habido un interés creciente en…",
    content = "En los últimos años, ha habido un interés creciente en…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "Acontecimientos recientes en el campo de X han reavivado el interés en…",
    content = "Acontecimientos recientes en el campo de X han reavivado el interés en…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "En la actualidad, se desarrolla un creciente interés por…",
    content = "En la actualidad, se desarrolla un creciente interés por…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "Desde la pasada década se ha establecido un rápido desarrollo de X en muchos…",
    content = "Desde la pasada década se ha establecido un rápido desarrollo de X en muchos…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "Los últimos X años han visto avances cada vez más rápidos en el campo de…",
    content = "Los últimos X años han visto avances cada vez más rápidos en el campo de…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "Durante el último siglo se ha producido un aumento espectacular en…",
    content = "Durante el último siglo se ha producido un aumento espectacular en…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "Uno de los eventos más importantes para la década de X fue…",
    content = "Uno de los eventos más importantes para la década de X fue…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "Tradicionalmente, se ha suscrito la creencia de que…",
    content = "Tradicionalmente, se ha suscrito la creencia de que…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "En el Año, X demostró ser un X en el ámbito de Y…",
    content = "En el Año, X demostró ser un X en el ámbito de Y…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "Los cambios experimentados por X durante la década Y permanecen sin precedentes entre…",
    content = "Los cambios experimentados por X durante la década Y permanecen sin precedentes entre…",
  },
  {
    tag = "3 Introduccion  3 Contexto e importancia del tema (En el tiempo)",
    title = "X es uno de los Y más ampliamente utilizados en Z para…",
    content = "X es uno de los Y más ampliamente utilizados en Z para…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "Recientemente, investigadores han examinado los efectos de X en Y…",
    content = "Recientemente, investigadores han examinado los efectos de X en Y…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "Los factores relacionados con X han sido investigados desde diversas perspectivas…",
    content = "Los factores relacionados con X han sido investigados desde diversas perspectivas…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "En las últimas décadas, muchos investigadores han tratado de determinar…",
    content = "En las últimas décadas, muchos investigadores han tratado de determinar…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "Estudios previos han hallado…",
    content = "Estudios previos han hallado…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "Una considerable cantidad de literatura científica ha sido publicada en X…",
    content = "Una considerable cantidad de literatura científica ha sido publicada en X…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "En estos estudios…Y muestra cómo, en el pasado, la investigación sobre X se refería principalmente a…",
    content = "En estos estudios…Y muestra cómo, en el pasado, la investigación sobre X se refería principalmente a…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "Las primeras discusiones y análisis serios sobre X surgieron durante la década de…",
    content = "Las primeras discusiones y análisis serios sobre X surgieron durante la década de…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "La evidencia reciente sobre la materia sugiere que…",
    content = "La evidencia reciente sobre la materia sugiere que…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "Un considerable número de investigadores ha referido que…",
    content = "Un considerable número de investigadores ha referido que…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "Lo que sabemos acerca de X se basa en gran medida en los estudios Y que investigan cómo…",
    content = "Lo que sabemos acerca de X se basa en gran medida en los estudios Y que investigan cómo…",
  },
  {
    tag = "3 Introduccion  4 Sintesis de la literatura relevante existente",
    title = "Los estudios sobre X muestran la importancia de…",
    content = "Los estudios sobre X muestran la importancia de…",
  },
  {
    tag = "3 Introduccion  5 Resaltando el problema",
    title = "Sin embargo, estos rápidos cambios están teniendo un grave efecto sobre…",
    content = "Sin embargo, estos rápidos cambios están teniendo un grave efecto sobre…",
  },
  {
    tag = "3 Introduccion  5 Resaltando el problema",
    title = "Sin embargo, un problema de este tipo…",
    content = "Sin embargo, un problema de este tipo…",
  },
  {
    tag = "3 Introduccion  5 Resaltando el problema",
    title = "La falta de X ha permanecido como un problema en…",
    content = "La falta de X ha permanecido como un problema en…",
  },
  {
    tag = "3 Introduccion  5 Resaltando el problema",
    title = "X presenta una serie de inconvenientes importantes:…",
    content = "X presenta una serie de inconvenientes importantes:…",
  },
  {
    tag = "3 Introduccion  5 Resaltando el problema",
    title = "Las investigaciones han demostrado que…",
    content = "Las investigaciones han demostrado que…",
  },
  {
    tag = "3 Introduccion  5 Resaltando el problema",
    title = "Existe una creciente preocupación sobre…",
    content = "Existe una creciente preocupación sobre…",
  },
  {
    tag = "3 Introduccion  5 Resaltando el problema",
    title = "X tiene una serie de importantes problemas en cuanto a…",
    content = "X tiene una serie de importantes problemas en cuanto a…",
  },
  {
    tag = "3 Introduccion  5 Resaltando el problema",
    title = "Se han planteado cuestiones acerca de…",
    content = "Se han planteado cuestiones acerca de…",
  },
  {
    tag = "3 Introduccion  5 Resaltando el problema",
    title = "Prolifera la preocupación sobre…",
    content = "Prolifera la preocupación sobre…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "Hasta la fecha, ha habido escaso acuerdo en cuanto a…",
    content = "Hasta la fecha, ha habido escaso acuerdo en cuanto a…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "Recientemente, la literatura científica ofrece resultados contradictorios sobre…",
    content = "Recientemente, la literatura científica ofrece resultados contradictorios sobre…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "La controversia acerca de la evidencia científica sobre X se ha prolongado durante más de…",
    content = "La controversia acerca de la evidencia científica sobre X se ha prolongado durante más de…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "A día de hoy, continua el debate sobre…",
    content = "A día de hoy, continua el debate sobre…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "Este concepto ha sido recientemente cuestionado por estudios que demuestran que…",
    content = "Este concepto ha sido recientemente cuestionado por estudios que demuestran que…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "Uno de los debates actuales más significativos en X es el referido a…",
    content = "Uno de los debates actuales más significativos en X es el referido a…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "Un investigador (Autor) ya había llamado la atención sobre…",
    content = "Un investigador (Autor) ya había llamado la atención sobre…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "Se han planteado dudas sobre…",
    content = "Se han planteado dudas sobre…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "X ha sido un área polémica dentro del campo de…",
    content = "X ha sido un área polémica dentro del campo de…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "X ha ocupado durante años la mente de los investigadores…",
    content = "X ha ocupado durante años la mente de los investigadores…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "X ha cobrado importancia a la luz de la reciente…",
    content = "X ha cobrado importancia a la luz de la reciente…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "X ha dominado durante años el campo de…",
    content = "X ha dominado durante años el campo de…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "En la literatura sobre X, la importancia relativa de Y ha sido objeto de…",
    content = "En la literatura sobre X, la importancia relativa de Y ha sido objeto de…",
  },
  {
    tag = "3 Introduccion  6 Resaltando la controversia en el campo de estudio",
    title = "El debate en X se ha reavivado a raíz de…",
    content = "El debate en X se ha reavivado a raíz de…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Destacando las debilidades de…",
    content = "Destacando las debilidades de…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "La mayoría de los estudios en el campo de X sólo se han centrado en…",
    content = "La mayoría de los estudios en el campo de X sólo se han centrado en…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "La mayoría de los estudios en X sólo han llevado a cabo investigaciones…",
    content = "La mayoría de los estudios en X sólo han llevado a cabo investigaciones…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "La generalización de la investigación publicada sobre X es problemática…",
    content = "La generalización de la investigación publicada sobre X es problemática…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Los resultados obtenidos en pasadas investigaciones son controvertidos y no existe un acuerdo general sobre…",
    content = "Los resultados obtenidos en pasadas investigaciones son controvertidos y no existe un acuerdo general sobre…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Tales exposiciones no son satisfactorias dado que…",
    content = "Tales exposiciones no son satisfactorias dado que…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Pocos estudios han sido capaces de recurrir…",
    content = "Pocos estudios han sido capaces de recurrir…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Hasta la fecha, la investigación se ha centrado en el papel de X en Y en lugar de Z…",
    content = "Hasta la fecha, la investigación se ha centrado en el papel de X en Y en lugar de Z…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "La literatura presente hasta la fecha se ha limitado, en su mayoría, a…",
    content = "La literatura presente hasta la fecha se ha limitado, en su mayoría, a…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Los estudios existentes no logran resolver el conflicto entre X e Y…",
    content = "Los estudios existentes no logran resolver el conflicto entre X e Y…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Los investigadores del campo X han descuidado…",
    content = "Los investigadores del campo X han descuidado…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Investigaciones pasadas sobre X no se han ocupado de…",
    content = "Investigaciones pasadas sobre X no se han ocupado de…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "La literatura científica publicada hasta el momento no ha especificado…",
    content = "La literatura científica publicada hasta el momento no ha especificado…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "El carácter de las publicaciones realizadas hasta la fecha ha sido…",
    content = "El carácter de las publicaciones realizadas hasta la fecha ha sido…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "A pesar de la amplia investigación en el campo de X no existe un solo estudio que aborde adecuadamente…",
    content = "A pesar de la amplia investigación en el campo de X no existe un solo estudio que aborde adecuadamente…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "En el campo de X no está claro…",
    content = "En el campo de X no está claro…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Los estudios publicados hasta el presente no han tenido en cuenta…",
    content = "Los estudios publicados hasta el presente no han tenido en cuenta…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "En la actualidad, se conoce muy poco acerca de…",
    content = "En la actualidad, se conoce muy poco acerca de…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "La literatura científica presente hasta el momento no da clara evidencia todavía de…",
    content = "La literatura científica presente hasta el momento no da clara evidencia todavía de…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Los investigadores en X ha prestado poca atención a…",
    content = "Los investigadores en X ha prestado poca atención a…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "No ha habido todavía un examen sistemático de…",
    content = "No ha habido todavía un examen sistemático de…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "La investigación en este área se ha limitado a…",
    content = "La investigación en este área se ha limitado a…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "La investigación científica en X se ha concentrado en…",
    content = "La investigación científica en X se ha concentrado en…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "X es pasado por alto con frecuencia en los debates…",
    content = "X es pasado por alto con frecuencia en los debates…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Rara vez se ha realizado antes…",
    content = "Rara vez se ha realizado antes…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Nuestro entendimiento hasta la fecha se ha limitado a…",
    content = "Nuestro entendimiento hasta la fecha se ha limitado a…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "No hay un acuerdo general respecto a…",
    content = "No hay un acuerdo general respecto a…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "No existe todavía una explicación satisfactoria para…",
    content = "No existe todavía una explicación satisfactoria para…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "La diversidad de aproximaciones / métodos refleja…",
    content = "La diversidad de aproximaciones / métodos refleja…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Los intentos de X realizados hasta ahora no han tenido éxito en…",
    content = "Los intentos de X realizados hasta ahora no han tenido éxito en…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Las pasadas investigaciones no han demostrado de manera concluyente…",
    content = "Las pasadas investigaciones no han demostrado de manera concluyente…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "A día de hoy, la pregunta sigue siendo…",
    content = "A día de hoy, la pregunta sigue siendo…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Un problema persistente en el campo de X es…",
    content = "Un problema persistente en el campo de X es…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Los resultados que Autor y Autor obtuvieron planteaban una serie de cuestiones que hasta ahora la literatura científica no ha sido capaz de resolver…",
    content = "Los resultados que Autor y Autor obtuvieron planteaban una serie de cuestiones que hasta ahora la literatura científica no ha sido capaz de resolver…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Aunque una importante labor se ha llevado a cabo… permanecen todavía numerosas preguntas sin resolver en…",
    content = "Aunque una importante labor se ha llevado a cabo… permanecen todavía numerosas preguntas sin resolver en…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Aunque se han hecho progresos considerables en…, muchas cuestiones importantes permanecen todavía sin resolver…",
    content = "Aunque se han hecho progresos considerables en…, muchas cuestiones importantes permanecen todavía sin resolver…",
  },
  {
    tag = "3 Introduccion  7 Resaltando las debilidades de la literatura previa",
    title = "Aunque se ha aprendido mucho acerca de X en los últimos años…, una serie de cuestiones siguen siendo fundamentales para…",
    content = "Aunque se ha aprendido mucho acerca de X en los últimos años…, una serie de cuestiones siguen siendo fundamentales para…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Hasta el momento, no se ha abordado…",
    content = "Hasta el momento, no se ha abordado…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Reexaminando la literatura presente hasta el momento…",
    content = "Reexaminando la literatura presente hasta el momento…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Los sucesivos intentos han fallado en resolver…",
    content = "Los sucesivos intentos han fallado en resolver…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "El actual entendimiento de X es limitado en cuanto a…",
    content = "El actual entendimiento de X es limitado en cuanto a…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Hasta el presente, no hay un consenso establecido para…",
    content = "Hasta el presente, no hay un consenso establecido para…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "La controvertida cuestión en el área de X que aborda…",
    content = "La controvertida cuestión en el área de X que aborda…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Muchos de nuestros conocimientos proceden de X; sin embargo,…",
    content = "Muchos de nuestros conocimientos proceden de X; sin embargo,…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "El impacto de X en Y no es facil de determinar…",
    content = "El impacto de X en Y no es facil de determinar…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "El efecto de X en Y no ha sido estudiado en detalle / no ha sido investigado en el pasado puesto que…",
    content = "El efecto de X en Y no ha sido estudiado en detalle / no ha sido investigado en el pasado puesto que…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "El campo de investigación en X está relativamente poco desarrollado…",
    content = "El campo de investigación en X está relativamente poco desarrollado…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "El mecanismo de X es, a día de hoy, poco conocido…",
    content = "El mecanismo de X es, a día de hoy, poco conocido…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "La visión prevalente en el campo de X es…",
    content = "La visión prevalente en el campo de X es…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Únicamente se han encontrado referencias de…",
    content = "Únicamente se han encontrado referencias de…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "A día de hoy, poco se sabe acerca de X. No está claro…",
    content = "A día de hoy, poco se sabe acerca de X. No está claro…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Se ha prestado escasa atención a…",
    content = "Se ha prestado escasa atención a…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "La evidencia disponible acerca de X no es concluyente…",
    content = "La evidencia disponible acerca de X no es concluyente…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Persiste la incertidumbre acerca de…",
    content = "Persiste la incertidumbre acerca de…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "A día de hoy, no está claro todavía…",
    content = "A día de hoy, no está claro todavía…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Las bases de X son prácticamente desconocidas…",
    content = "Las bases de X son prácticamente desconocidas…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "La literatura científica desarrollada hasta el momento no muestra una evidencia confiable acerca de…",
    content = "La literatura científica desarrollada hasta el momento no muestra una evidencia confiable acerca de…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Ninguna investigación ha encontrado/estudiado…",
    content = "Ninguna investigación ha encontrado/estudiado…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "No se han encontrado estudios que analicen X en el contexto de…",
    content = "No se han encontrado estudios que analicen X en el contexto de…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Surge, por tanto, la necesidad de comprender…",
    content = "Surge, por tanto, la necesidad de comprender…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Estudios tentativos acerca de X son los desarrollados por…",
    content = "Estudios tentativos acerca de X son los desarrollados por…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Aunque los resultados de recientes investigaciones han demostrado…",
    content = "Aunque los resultados de recientes investigaciones han demostrado…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "No se ha establecido una X sobre Y…",
    content = "No se ha establecido una X sobre Y…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Existe una falta general de investigación en…",
    content = "Existe una falta general de investigación en…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Muy pocos estudios han investigado el impacto de X en…",
    content = "Muy pocos estudios han investigado el impacto de X en…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Únicamente X estudios han hallado que…",
    content = "Únicamente X estudios han hallado que…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Únicamente X estudios se han centrado en…",
    content = "Únicamente X estudios se han centrado en…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "X no ha sido todavía abordado completamente…",
    content = "X no ha sido todavía abordado completamente…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "X no está presente en la teoría actual…",
    content = "X no está presente en la teoría actual…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "A día de hoy, todavía no se comprende claramente / completamente…",
    content = "A día de hoy, todavía no se comprende claramente / completamente…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "En el presente, hay una pobre compresión de…",
    content = "En el presente, hay una pobre compresión de…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Intentos sucesivos han fallado al resolver…",
    content = "Intentos sucesivos han fallado al resolver…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "X presenta difíciles problemas para la determinación de…",
    content = "X presenta difíciles problemas para la determinación de…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "X plantea una serie de problemas que…",
    content = "X plantea una serie de problemas que…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "La comprensión presente de X es limitada…",
    content = "La comprensión presente de X es limitada…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "El campo de… está recientemente en desarrollo…",
    content = "El campo de… está recientemente en desarrollo…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "No existe un consenso en lo que refiere a…",
    content = "No existe un consenso en lo que refiere a…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Todavía ninguna explicación ha conseguido la aceptación…",
    content = "Todavía ninguna explicación ha conseguido la aceptación…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "En el presente, hay un escaso acuerdo en…",
    content = "En el presente, hay un escaso acuerdo en…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "En el presente, no hay un acuerdo general en…",
    content = "En el presente, no hay un acuerdo general en…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Hay todavía un considerable desacuerdo en…",
    content = "Hay todavía un considerable desacuerdo en…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "El mecanismo por el cual… es desconocida o mal comprendida…",
    content = "El mecanismo por el cual… es desconocida o mal comprendida…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "La cuestión controvertida de…",
    content = "La cuestión controvertida de…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Muchos de nuestros conocimientos de… proceden de…",
    content = "Muchos de nuestros conocimientos de… proceden de…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "La tarea de… es complicada en cuanto a…",
    content = "La tarea de… es complicada en cuanto a…",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "El impacto de… en… no es fácil de determinar",
    content = "El impacto de… en… no es fácil de determinar",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "El efecto de… en… no ha sido examinada en detalle",
    content = "El efecto de… en… no ha sido examinada en detalle",
  },
  {
    tag = "3 Introduccion  8 Resaltando el vacío de conocimiento en el campo de estudio",
    title = "Los efectos en… no han sido estudiados en detalle",
    content = "Los efectos en… no han sido estudiados en detalle",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "El estudio de X es importante por una serie de razones:",
    content = "El estudio de X es importante por una serie de razones:",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "El estudio de X cobra cada día más relevancia dado que…",
    content = "El estudio de X cobra cada día más relevancia dado que…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Es importante…",
    content = "Es importante…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "La importancia de X se hace presente…",
    content = "La importancia de X se hace presente…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "En el campo de X se necesita/es necesario…",
    content = "En el campo de X se necesita/es necesario…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "A raíz de nuevos descubrimientos, se ha estimulado la investigación en X puesto que…",
    content = "A raíz de nuevos descubrimientos, se ha estimulado la investigación en X puesto que…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "X merece investigación adicional dado que…",
    content = "X merece investigación adicional dado que…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Merece la pena investigar X porque…",
    content = "Merece la pena investigar X porque…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Para dar luz a las numerosas cuestiones en el campo de X,…",
    content = "Para dar luz a las numerosas cuestiones en el campo de X,…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Una solución a X daría como resultado…",
    content = "Una solución a X daría como resultado…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "La perspectiva de un gran avance en la…",
    content = "La perspectiva de un gran avance en la…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Otros autores han solicitado ya una revisión de…",
    content = "Otros autores han solicitado ya una revisión de…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Este estudio podría estimular el debate / revelar / revestir / proporcionar evidencia / contribuir al incremento del conocimiento en… / ofrecer una visión alternativa / dar cuenta de / reavivar el interés por…",
    content = "Este estudio podría estimular el debate / revelar / revestir / proporcionar evidencia / contribuir al incremento del conocimiento en… / ofrecer una visión alternativa / dar cuenta de / reavivar el interés por…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Se debiera reexaminar / revisar…",
    content = "Se debiera reexaminar / revisar…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Es importante retomar y construir en base a investigaciones previas…",
    content = "Es importante retomar y construir en base a investigaciones previas…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "La cuestión, el problema, la causa de…",
    content = "La cuestión, el problema, la causa de…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "…merece un estudio adicional…",
    content = "…merece un estudio adicional…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "…merece consideración adicional…",
    content = "…merece consideración adicional…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "…es importante examinar con mayor detalle…",
    content = "…es importante examinar con mayor detalle…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "…es importante explorar adicionalmente…",
    content = "…es importante explorar adicionalmente…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Este estudio es de relevancia porque…",
    content = "Este estudio es de relevancia porque…",
  },
  {
    tag = "3 Introduccion  9 Resaltando la importancia de estudio del problema",
    title = "Un aspecto importante de…",
    content = "Un aspecto importante de…",
  },
  {
    tag = "3 Introduccion  10 Trabajos relacionados",
    title = "El trabajo aquí presentado se basa en parte en un estudio previo sobre…",
    content = "El trabajo aquí presentado se basa en parte en un estudio previo sobre…",
  },
  {
    tag = "3 Introduccion  10 Trabajos relacionados",
    title = "Una versión previa de este artículo fue presentada/publicada en…",
    content = "Una versión previa de este artículo fue presentada/publicada en…",
  },
  {
    tag = "3 Introduccion  10 Trabajos relacionados",
    title = "Este documento es una versión revisada / ha sido sustancialmente revisado / incluye nuevos capítulos en el ámbito de…",
    content = "Este documento es una versión revisada / ha sido sustancialmente revisado / incluye nuevos capítulos en el ámbito de…",
  },
  {
    tag = "3 Introduccion  10 Trabajos relacionados",
    title = "Este estudio aporta una nueva visión de lo ya expuesto en…",
    content = "Este estudio aporta una nueva visión de lo ya expuesto en…",
  },
  {
    tag = "3 Introduccion  10 Trabajos relacionados",
    title = "Este artículo forma parte de un amplio estudio en el campo de…",
    content = "Este artículo forma parte de un amplio estudio en el campo de…",
  },
  {
    tag = "3 Introduccion  10 Trabajos relacionados",
    title = "Este trabajo ha sido ya reportado para su publicación en…",
    content = "Este trabajo ha sido ya reportado para su publicación en…",
  },
  {
    tag = "3 Introduccion  10 Trabajos relacionados",
    title = "Secciones / Fragmentos / Una aproximación inicial a este estudio fue ya presentada en la conferencia/ simposio de… en… Año…",
    content = "Secciones / Fragmentos / Una aproximación inicial a este estudio fue ya presentada en la conferencia/ simposio de… en… Año…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "Este trabajo tiene como objetivo solucionar los problemas…",
    content = "Este trabajo tiene como objetivo solucionar los problemas…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "Este documento tiene como objetivo proporcionar una mejor base para la comprensión de…",
    content = "Este documento tiene como objetivo proporcionar una mejor base para la comprensión de…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "Esta publicación examina/aborda/se centra…",
    content = "Esta publicación examina/aborda/se centra…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "En este trabajo se aborda una revisión de la investigación realizada acerca de…",
    content = "En este trabajo se aborda una revisión de la investigación realizada acerca de…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "Este documento da cuenta de…",
    content = "Este documento da cuenta de…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "El propósito/objetivo de este trabajo es proporcionar un marco teórico conceptual basado en…",
    content = "El propósito/objetivo de este trabajo es proporcionar un marco teórico conceptual basado en…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "La meta de esta investigación es revisar la literatura presente hasta el momento en el ámbito de…",
    content = "La meta de esta investigación es revisar la literatura presente hasta el momento en el ámbito de…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "La tesis central de este trabajo es…",
    content = "La tesis central de este trabajo es…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "En este artículo se sostiene/se intentará demostrar…",
    content = "En este artículo se sostiene/se intentará demostrar…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "En las páginas que siguen, se argumentará acerca de…",
    content = "En las páginas que siguen, se argumentará acerca de…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "En este ensayo se pretende defender la opinión de…",
    content = "En este ensayo se pretende defender la opinión de…",
  },
  {
    tag = "3 Introduccion  11 Resaltando el objetivo, interés, argumento del estudio",
    title = "Este documento tiene por objeto…",
    content = "Este documento tiene por objeto…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El objetivo de este proyecto de investigación ha sido tratar de…",
    content = "El objetivo de este proyecto de investigación ha sido tratar de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Este estudio abarca…",
    content = "Este estudio abarca…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "En lo que a este estudio concierne…",
    content = "En lo que a este estudio concierne…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "La cuestión central que se tratará de resolver en este artículo es…",
    content = "La cuestión central que se tratará de resolver en este artículo es…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "La cuestión central discutida en detalle en este documento…",
    content = "La cuestión central discutida en detalle en este documento…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El principal objetivo de este estudio es investigar / evaluar…",
    content = "El principal objetivo de este estudio es investigar / evaluar…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El objetivo de esta investigación es hacer brillar una nueva luz sobre… a través de…",
    content = "El objetivo de esta investigación es hacer brillar una nueva luz sobre… a través de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El principal objetivo de este estudio fue…",
    content = "El principal objetivo de este estudio fue…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Los principales objetivos de esta investigación son: …",
    content = "Los principales objetivos de esta investigación son: …",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El principal objetivo de esta tesis es desarrollar un mejor entendimiento acerca de…",
    content = "El principal objetivo de esta tesis es desarrollar un mejor entendimiento acerca de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Esta investigación pretende determinar el grado en que…",
    content = "Esta investigación pretende determinar el grado en que…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Esta investigación busca integrar/combinar…",
    content = "Esta investigación busca integrar/combinar…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Este estudio aborda…",
    content = "Este estudio aborda…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Esta investigación da cuenta de…",
    content = "Esta investigación da cuenta de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El propósito de este estudio es…",
    content = "El propósito de este estudio es…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Este trabajo se centra en…",
    content = "Este trabajo se centra en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Este proyecto resalta la importancia de explorar / examinar / explicar / probar / desarrollar / determinar / definir / dar cuenta de / identificar / replicar / investigar / abordar / trazar / mejorar / ampliar / proporcionar / establecer / encontrar / introducir / crear / moverse más allá / evaluar / elaborar / estimular…",
    content = "Este proyecto resalta la importancia de explorar / examinar / explicar / probar / desarrollar / determinar / definir / dar cuenta de / identificar / replicar / investigar / abordar / trazar / mejorar / ampliar / proporcionar / establecer / encontrar / introducir / crear / moverse más allá / evaluar / elaborar / estimular…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Este estudio examina / investiga / aborda / pone por delante / tratará de mostrar / busca explicar / intenta clarificar / evalúa / busca combinar / busca integrar / se enfoca en / resalta la importancia de…",
    content = "Este estudio examina / investiga / aborda / pone por delante / tratará de mostrar / busca explicar / intenta clarificar / evalúa / busca combinar / busca integrar / se enfoca en / resalta la importancia de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "La cuestión a la que se refiere este trabajo…",
    content = "La cuestión a la que se refiere este trabajo…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El propósito de este estudio es…",
    content = "El propósito de este estudio es…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…con el objetivo de establecer un marco…",
    content = "…con el objetivo de establecer un marco…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…en el marco de la teoría general de…",
    content = "…en el marco de la teoría general de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…avanzar en la explicación de…",
    content = "…avanzar en la explicación de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…avanzar en el conocimiento teórico de…",
    content = "…avanzar en el conocimiento teórico de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…examinar los tipos de…",
    content = "…examinar los tipos de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…verificar el rol de…",
    content = "…verificar el rol de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…realizar una aproximación simplificada a…",
    content = "…realizar una aproximación simplificada a…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…realizar una aproximación empírica a…",
    content = "…realizar una aproximación empírica a…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…realizar una aproximación puramente teórica a…",
    content = "…realizar una aproximación puramente teórica a…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…dar una respuesta tentativa de…",
    content = "…dar una respuesta tentativa de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…averiguar el origen de…",
    content = "…averiguar el origen de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…poner a prueba la hipótesis de…",
    content = "…poner a prueba la hipótesis de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…desarrollar el concepto X en…",
    content = "…desarrollar el concepto X en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…investigar el papel que juega X en…",
    content = "…investigar el papel que juega X en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…evaluar los efectos de…en…",
    content = "…evaluar los efectos de…en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…trazar el desarrollo de…",
    content = "…trazar el desarrollo de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…mejorar nuestro conocimiento sobre…",
    content = "…mejorar nuestro conocimiento sobre…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…expandir nuestra comprensión sobre…",
    content = "…expandir nuestra comprensión sobre…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…crear nuevas cuestiones entorno a…",
    content = "…crear nuevas cuestiones entorno a…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…proporcionar una nueva comprensión de…",
    content = "…proporcionar una nueva comprensión de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…resaltar una serie de…",
    content = "…resaltar una serie de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…dirigir la atención más allá de…",
    content = "…dirigir la atención más allá de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…establecer un marco teórico…",
    content = "…establecer un marco teórico…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…encontrar una base única para…",
    content = "…encontrar una base única para…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…sentar los fundamentos de…",
    content = "…sentar los fundamentos de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…introducir nueva terminología en…",
    content = "…introducir nueva terminología en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…proporcionar una base para…",
    content = "…proporcionar una base para…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…hacer un balance entre X e Y en cuanto a…",
    content = "…hacer un balance entre X e Y en cuanto a…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…dar recomendaciones para…",
    content = "…dar recomendaciones para…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…abordar las cuestiones de…",
    content = "…abordar las cuestiones de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…enfocar la evidencia científica hacia…",
    content = "…enfocar la evidencia científica hacia…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…dar luz a la investigación de X en el contexto de…",
    content = "…dar luz a la investigación de X en el contexto de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…identificar y evaluar…",
    content = "…identificar y evaluar…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…evaluar y examinar críticamente…",
    content = "…evaluar y examinar críticamente…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…evaluar empíricamente…",
    content = "…evaluar empíricamente…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…examinar el valor de…",
    content = "…examinar el valor de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…examinar la validez de…",
    content = "…examinar la validez de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…examinar la naturaleza de…",
    content = "…examinar la naturaleza de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…determinar la relación entre…",
    content = "…determinar la relación entre…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…examinar el desarrollo de…",
    content = "…examinar el desarrollo de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…examinar los efectos de… en…",
    content = "…examinar los efectos de… en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…examinar cómo… es afectado por…",
    content = "…examinar cómo… es afectado por…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…examina en que medida… es afectado por…",
    content = "…examina en que medida… es afectado por…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…elaborar la idea que/de…",
    content = "…elaborar la idea que/de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…estimular el debate en…",
    content = "…estimular el debate en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…estudiar el origen de…",
    content = "…estudiar el origen de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…investigar el efecto de… en…",
    content = "…investigar el efecto de… en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…comprobar los posibles efectos de… en…",
    content = "…comprobar los posibles efectos de… en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…averiguar la relación entre X e Y…",
    content = "…averiguar la relación entre X e Y…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…encontrar una explicación tentativa para…",
    content = "…encontrar una explicación tentativa para…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…buscar la integración de X e Y en…",
    content = "…buscar la integración de X e Y en…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "…dar una explicación tentativa de…",
    content = "…dar una explicación tentativa de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Este proyecto fue diseñado para poner a prueba…",
    content = "Este proyecto fue diseñado para poner a prueba…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El presente estudio estudiará la forma en que…",
    content = "El presente estudio estudiará la forma en que…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Esta investigación examina el papel de X en el contexto de…",
    content = "Esta investigación examina el papel de X en el contexto de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Este documento intentará explicar el desarrollo de…",
    content = "Este documento intentará explicar el desarrollo de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El caso de estudio tiene por objeto…",
    content = "El caso de estudio tiene por objeto…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Esta investigación revisa sistemáticamente…",
    content = "Esta investigación revisa sistemáticamente…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Como objetivos principales de esta investigación encontramos:",
    content = "Como objetivos principales de esta investigación encontramos:",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Basándose en X este estudio intenta…",
    content = "Basándose en X este estudio intenta…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Uno de los propósitos de este estudio fue…",
    content = "Uno de los propósitos de este estudio fue…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Este estudio pretende hacer frente a las lagunas en la investigación de X a través de…",
    content = "Este estudio pretende hacer frente a las lagunas en la investigación de X a través de…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El presente volumen desarrolla…",
    content = "El presente volumen desarrolla…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Este compendio de artículos aborda…",
    content = "Este compendio de artículos aborda…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "El tema central de este documento…",
    content = "El tema central de este documento…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "En este capítulo se desarrolla…",
    content = "En este capítulo se desarrolla…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "A grandes rasgos, esta investigación pretende…",
    content = "A grandes rasgos, esta investigación pretende…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "Lo que en este estudio se intenta alcanzar es…",
    content = "Lo que en este estudio se intenta alcanzar es…",
  },
  {
    tag = "3 Introduccion  12 Propósito de la investigación",
    title = "La intención de este trabajo no es otra que…",
    content = "La intención de este trabajo no es otra que…",
  },
  {
    tag = "3 Introduccion  13 Preguntas de investigación e hipótesis",
    title = "La cuestión central en esta tesis es…",
    content = "La cuestión central en esta tesis es…",
  },
  {
    tag = "3 Introduccion  13 Preguntas de investigación e hipótesis",
    title = "Esta investigación busca responder a las siguientes cuestiones: ",
    content = "Esta investigación busca responder a las siguientes cuestiones: ",
  },
  {
    tag = "3 Introduccion  13 Preguntas de investigación e hipótesis",
    title = "Este estudio examina X preguntas principales de investigación: En primer lugar,…",
    content = "Este estudio examina X preguntas principales de investigación: En primer lugar,…",
  },
  {
    tag = "3 Introduccion  13 Preguntas de investigación e hipótesis",
    title = "En este estudio se pondrá a prueba la hipótesis de…",
    content = "En este estudio se pondrá a prueba la hipótesis de…",
  },
  {
    tag = "3 Introduccion  13 Preguntas de investigación e hipótesis",
    title = "La pregunta clave de investigación en este estudio es…",
    content = "La pregunta clave de investigación en este estudio es…",
  },
  {
    tag = "3 Introduccion  13 Preguntas de investigación e hipótesis",
    title = "Las cuestiones fundamentales que conciernen a X son: ",
    content = "Las cuestiones fundamentales que conciernen a X son: ",
  },
  {
    tag = "3 Introduccion  13 Preguntas de investigación e hipótesis",
    title = "Este estudio tuvo como objeto responder a las siguientes preguntas de investigación: ",
    content = "Este estudio tuvo como objeto responder a las siguientes preguntas de investigación: ",
  },
  {
    tag = "3 Introduccion  13 Preguntas de investigación e hipótesis",
    title = "Otra cuestión es si…",
    content = "Otra cuestión es si…",
  },
  {
    tag = "3 Introduccion  13 Preguntas de investigación e hipótesis",
    title = "La cuestión clave planteada en esta investigación es…",
    content = "La cuestión clave planteada en esta investigación es…",
  },
  {
    tag = "3 Introduccion  14 Indicando la significación",
    title = "Este proyecto constituye una gran oportunidad para el avance en…",
    content = "Este proyecto constituye una gran oportunidad para el avance en…",
  },
  {
    tag = "3 Introduccion  14 Indicando la significación",
    title = "Este estudio proporciona una gran oportunidad para contribuir al conocimiento de…",
    content = "Este estudio proporciona una gran oportunidad para contribuir al conocimiento de…",
  },
  {
    tag = "3 Introduccion  14 Indicando la significación",
    title = "Este es el primer estudio en el que se realiza…",
    content = "Este es el primer estudio en el que se realiza…",
  },
  {
    tag = "3 Introduccion  14 Indicando la significación",
    title = "Los resultados obtenidos en este estudio supondrían una importante contribución al campo de… dado que…",
    content = "Los resultados obtenidos en este estudio supondrían una importante contribución al campo de… dado que…",
  },
  {
    tag = "3 Introduccion  14 Indicando la significación",
    title = "En esta investigación se hace una importante contribución al estudio de X en el contexto de…",
    content = "En esta investigación se hace una importante contribución al estudio de X en el contexto de…",
  },
  {
    tag = "3 Introduccion  14 Indicando la significación",
    title = "Este estudio ofrece algunas pistas importantes sobre…",
    content = "Este estudio ofrece algunas pistas importantes sobre…",
  },
  {
    tag = "3 Introduccion  14 Indicando la significación",
    title = "Este estudio tiene como objetivo contribuir al creciente área de X mediante…",
    content = "Este estudio tiene como objetivo contribuir al creciente área de X mediante…",
  },
  {
    tag = "3 Introduccion  14 Indicando la significación",
    title = "Entre las importantes áreas en las que este estudio hace una contribución única y original encontramos: ",
    content = "Entre las importantes áreas en las que este estudio hace una contribución única y original encontramos: ",
  },
  {
    tag = "3 Introduccion  15 Describiendo las palabras clave",
    title = "Aunque se han sugerido una gran variedad de definiciones para X, en este trabajo se utilizará la propuesta por Autor que…",
    content = "Aunque se han sugerido una gran variedad de definiciones para X, en este trabajo se utilizará la propuesta por Autor que…",
  },
  {
    tag = "3 Introduccion  15 Describiendo las palabras clave",
    title = "A lo largo de este documento, el término X hará referencia a…",
    content = "A lo largo de este documento, el término X hará referencia a…",
  },
  {
    tag = "3 Introduccion  15 Describiendo las palabras clave",
    title = "A lo largo de este trabajo, utilizaremos el término X para referirnos a…",
    content = "A lo largo de este trabajo, utilizaremos el término X para referirnos a…",
  },
  {
    tag = "3 Introduccion  15 Describiendo las palabras clave",
    title = "En este artículo, se utilizarán las siglas/abreviaturas X para referirnos a…",
    content = "En este artículo, se utilizarán las siglas/abreviaturas X para referirnos a…",
  },
  {
    tag = "3 Introduccion  15 Describiendo las palabras clave",
    title = "De acuerdo con Autor, X puede ser definido como…",
    content = "De acuerdo con Autor, X puede ser definido como…",
  },
  {
    tag = "3 Introduccion  15 Describiendo las palabras clave",
    title = "El término X es comúnmente conocido como…",
    content = "El término X es comúnmente conocido como…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Las cuestiones / temas principales abordados en este trabajo son: ",
    content = "Las cuestiones / temas principales abordados en este trabajo son: ",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Este trabajo se ha dividido en…",
    content = "Este trabajo se ha dividido en…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Este documento ha sido organizado…",
    content = "Este documento ha sido organizado…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "El primer capitulo…; el segundo capitulo…; el último capitulo…",
    content = "El primer capitulo…; el segundo capitulo…; el último capitulo…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "En primer lugar…, en segundo lugar…, en tercer y último lugar…",
    content = "En primer lugar…, en segundo lugar…, en tercer y último lugar…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "En primer lugar…, seguido de…, en tercer lugar…",
    content = "En primer lugar…, seguido de…, en tercer lugar…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "En este trabajo se revisa la evidencia de…",
    content = "En este trabajo se revisa la evidencia de…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Este documento comienza… A continuación, pasaremos a…",
    content = "Este documento comienza… A continuación, pasaremos a…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "La primera sección de este documento examinará…",
    content = "La primera sección de este documento examinará…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "La estructura general de este estudio es…",
    content = "La estructura general de este estudio es…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "X capitulo toca las dimensiones teóricas de…y analiza como…",
    content = "X capitulo toca las dimensiones teóricas de…y analiza como…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "X capitulo se refiere a…",
    content = "X capitulo se refiere a…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Para examinar en detalle los factores que influyen en X se abordará…",
    content = "Para examinar en detalle los factores que influyen en X se abordará…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Este estudio comenzará examinando…",
    content = "Este estudio comenzará examinando…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Parece apropiado… dar una visión general del problema/proporcionar una breve reseña/aludir a la investigación…",
    content = "Parece apropiado… dar una visión general del problema/proporcionar una breve reseña/aludir a la investigación…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Resaltar el papel de…",
    content = "Resaltar el papel de…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "La siguiente sección propone…",
    content = "La siguiente sección propone…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "El análisis en el capitulo X de Y permitirá…",
    content = "El análisis en el capitulo X de Y permitirá…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "En el capitulo X se discutirá…",
    content = "En el capitulo X se discutirá…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "El capitulo X aborda la cuestión de…",
    content = "El capitulo X aborda la cuestión de…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "En la X sección se presentará Y centrándonos en…",
    content = "En la X sección se presentará Y centrándonos en…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "En X capitulo se analiza en detalle…",
    content = "En X capitulo se analiza en detalle…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "La X sección de este documento concentra su atención en…",
    content = "La X sección de este documento concentra su atención en…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "El X capitulo se basa en…",
    content = "El X capitulo se basa en…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "X capitulo incluye…",
    content = "X capitulo incluye…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Finalmente y como conclusión, se proporciona un breve resumen y discusión de los resultados…",
    content = "Finalmente y como conclusión, se proporciona un breve resumen y discusión de los resultados…",
  },
  {
    tag = "3 Introduccion  16 Definiendo la estructura",
    title = "Por último, se identifican las áreas para futuras investigaciones…",
    content = "Por último, se identifican las áreas para futuras investigaciones…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Debido a limitaciones prácticas, este documento no puede proporcionar una revisión exhaustiva de…",
    content = "Debido a limitaciones prácticas, este documento no puede proporcionar una revisión exhaustiva de…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "El objetivo de este estudio no es…",
    content = "El objetivo de este estudio no es…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "X no se discute en detalle en este tratado dado que…",
    content = "X no se discute en detalle en este tratado dado que…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "X cae fuera de las competencias de esta investigación…",
    content = "X cae fuera de las competencias de esta investigación…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "X sólo se puede discutir brevemente en este documento puesto que…",
    content = "X sólo se puede discutir brevemente en este documento puesto que…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Este estudio excluye…",
    content = "Este estudio excluye…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "A pesar de que sería interesante examinar en más detalle…",
    content = "A pesar de que sería interesante examinar en más detalle…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Los autores de este documento han decidido…",
    content = "Los autores de este documento han decidido…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "El acceso a X es difícil…",
    content = "El acceso a X es difícil…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Un problema inherente a X es…",
    content = "Un problema inherente a X es…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Para los propósitos de este estudio limitaremos nuestra discusión acerca de…",
    content = "Para los propósitos de este estudio limitaremos nuestra discusión acerca de…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Nuestra prioridad en este estudio es…",
    content = "Nuestra prioridad en este estudio es…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "La atención a X será limitada…",
    content = "La atención a X será limitada…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "No es nuestra intención…",
    content = "No es nuestra intención…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "No es tarea de este estudio…",
    content = "No es tarea de este estudio…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "En esta investigación, no se aborda de forma explícita…",
    content = "En esta investigación, no se aborda de forma explícita…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Los autores de este estudio no quieren dar a entender que en este estudio…",
    content = "Los autores de este estudio no quieren dar a entender que en este estudio…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Está más allá del alcance de este estudio examinar…",
    content = "Está más allá del alcance de este estudio examinar…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "El lector deberá tener en cuenta que este estudio se basa en… y no pretende…",
    content = "El lector deberá tener en cuenta que este estudio se basa en… y no pretende…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Una posible limitación de esta investigación es que su alcance no logra dar cuenta de…",
    content = "Una posible limitación de esta investigación es que su alcance no logra dar cuenta de…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Un exhaustivo abordaje de X está más allá del alcance de este estudio…",
    content = "Un exhaustivo abordaje de X está más allá del alcance de este estudio…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Esta investigación no se involucra en…",
    content = "Esta investigación no se involucra en…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "La intención o propósito de este estudio no es…",
    content = "La intención o propósito de este estudio no es…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "X no es un aspecto central en este estudio…",
    content = "X no es un aspecto central en este estudio…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Examinar X está más allá de los límites de este estudio…",
    content = "Examinar X está más allá de los límites de este estudio…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "El estudio de X recae fuera de los propósitos de este estudio puesto que…",
    content = "El estudio de X recae fuera de los propósitos de este estudio puesto que…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "X únicamente podrá ser discutido brevemente dado que…",
    content = "X únicamente podrá ser discutido brevemente dado que…",
  },
  {
    tag = "3 Introduccion  17 Limitaciones del estudio",
    title = "Hemos propuesto excluir de esta investigación…",
    content = "Hemos propuesto excluir de esta investigación…",
  },
  {
    tag = "3 Introduccion  18 Razones para un interés personal",
    title = "Mi principal interés personal para elegir este tema es…",
    content = "Mi principal interés personal para elegir este tema es…",
  },
  {
    tag = "3 Introduccion  18 Razones para un interés personal",
    title = "Me interesé en X tras…",
    content = "Me interesé en X tras…",
  },
  {
    tag = "3 Introduccion  18 Razones para un interés personal",
    title = "Este proyecto fue concebido como…",
    content = "Este proyecto fue concebido como…",
  },
  {
    tag = "3 Introduccion  18 Razones para un interés personal",
    title = "He trabajado en estrecha colaboración con X desde Y y…",
    content = "He trabajado en estrecha colaboración con X desde Y y…",
  },
  {
    tag = "3 Introduccion  18 Razones para un interés personal",
    title = "Mi experiencia en el campo de X me ha impulsado a realizar esta investigación como…",
    content = "Mi experiencia en el campo de X me ha impulsado a realizar esta investigación como…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Un debate más profundo/Un completo abordaje sobre/de X aparecerá en una publicación posterior…",
    content = "Un debate más profundo/Un completo abordaje sobre/de X aparecerá en una publicación posterior…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "…se recogerá en una publicación posterior…",
    content = "…se recogerá en una publicación posterior…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "…ver X (próxima publicación)…",
    content = "…ver X (próxima publicación)…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "…ver X (pendiente de publicación)…",
    content = "…ver X (pendiente de publicación)…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "…ver X (publicado en Y)…",
    content = "…ver X (publicado en Y)…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Al final de este artículo se proporcionan referencias para ampliar el conocimiento de la materia…",
    content = "Al final de este artículo se proporcionan referencias para ampliar el conocimiento de la materia…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "X se discute en detalle en otro artículo publicado en…",
    content = "X se discute en detalle en otro artículo publicado en…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Véase X para profundizar en…",
    content = "Véase X para profundizar en…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Para una revisión profunda de X véase…",
    content = "Para una revisión profunda de X véase…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Para información adicional sobre X, ver Y publicado en Z del año…",
    content = "Para información adicional sobre X, ver Y publicado en Z del año…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Para un examen más detallado acerca de X véase Y…",
    content = "Para un examen más detallado acerca de X véase Y…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Un examen bibliográfico exhaustivo acerca de la cuestión aquí tratada se recoge en…",
    content = "Un examen bibliográfico exhaustivo acerca de la cuestión aquí tratada se recoge en…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Al final de este artículo se proporcionarán referencias adicionales…",
    content = "Al final de este artículo se proporcionarán referencias adicionales…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Para discusión adicional véase, por ejemplo,…",
    content = "Para discusión adicional véase, por ejemplo,…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "X es discutido en detalle en Y o en Z…",
    content = "X es discutido en detalle en Y o en Z…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Ver X para un resumen y referencias",
    content = "Ver X para un resumen y referencias",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Para obtener información adicional sobre X ver Y",
    content = "Para obtener información adicional sobre X ver Y",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Para un examen más detallado de X ver Y",
    content = "Para un examen más detallado de X ver Y",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Para obtener bibliografía de estudios sobre X ver Y",
    content = "Para obtener bibliografía de estudios sobre X ver Y",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Véase en X…",
    content = "Véase en X…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Para discusión adicional véase por ejemplo…",
    content = "Para discusión adicional véase por ejemplo…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Ver X para un sumario de…",
    content = "Ver X para un sumario de…",
  },
  {
    tag = "3 Introduccion  19 Referencias adicionales",
    title = "Para una argumentación sobre X véase Y…",
    content = "Para una argumentación sobre X véase Y…",
  },
}

-- Función para mostrar los snippets filtrados por tag
function M.by_tag(tag)
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  -- Filtrar snippets por tag si se especifica uno
  local filtered_snippets = M.snippets
  if tag then
    filtered_snippets = vim.tbl_filter(function(item)
      return item.tag == tag
    end, M.snippets)
  end

  pickers
    .new({}, {
      prompt_title = tag and (tag:upper()) or "Frases precocinadas por tag",
      finder = finders.new_table {
        results = filtered_snippets,
        entry_maker = function(entry)
          return {
            value = entry,
            display = string.format("%s", entry.title),
            ordinal = string.format("%s", entry.title),
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          -- Usar la función auxiliar para insertar el texto
          insert_text(selection.value.content)
        end)
        return true
      end,
    })
    :find()
end

-- Función para mostrar y seleccionar tags disponibles
function M.tags()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  -- Obtener tags únicos
  local tags = {}
  local seen = {}
  for _, snippet in ipairs(M.snippets) do
    if not seen[snippet.tag] then
      seen[snippet.tag] = true
      table.insert(tags, snippet.tag)
    end
  end

  pickers
    .new({}, {
      prompt_title = "Seleccionar Categoría",
      finder = finders.new_table {
        results = tags,
        entry_maker = function(tag)
          return {
            value = tag,
            display = tag:upper(),
            ordinal = tag,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          M.by_tag(selection.value)
        end)
        return true
      end,
    })
    :find()
end

function M.all()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  pickers
    .new({}, {
      prompt_title = "Todas las frases precocinadas",
      finder = finders.new_table {
        results = M.snippets,
        entry_maker = function(entry)
          return {
            value = entry,
            -- Mostrar tag y título para facilitar el filtrado
            display = string.format("[%s] %s", entry.tag:upper(), entry.title),
            -- Permitir búsqueda por tag y título
            ordinal = string.format("%s %s", entry.tag, entry.title),
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          insert_text(selection.value.content)
        end)
        return true
      end,
    })
    :find()
end
return M
