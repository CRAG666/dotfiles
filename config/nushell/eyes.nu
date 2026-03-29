$env.config.color_config = {
    # --- Estructura de la Tabla ---
    separator: white                # Tu color7 (#222222)
    leading_trailing_space_bg: { attr: n }
    header: green_bold              # Tu color2 (#3a6832)
    empty: blue                     # Tu color4 (#2a5872)
    row_index: green                # Tu color2

    # --- Tipos de Datos (Columna 'type' y valores) ---
    bool: magenta                   # Tu color5 (#4a3870)
    int: white                      # Tu color7
    filesize: {
        small: cyan                 # Tu color6 (#2a6868)
        medium: yellow              # Tu color3 (#7a4a18)
        large: red                  # Tu color1 (#8a2820)
    }
    duration: white
    date: {
        # Colores para las fechas según antigüedad
        hour: red                   # Reciente
        day: yellow                 # Medio
        week: cyan                  # Antiguo
    }
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white

    # --- Formas y Comandos (Syntax Highlighting) ---
    # Esto es lo que ves mientras escribes
    shape_and: magenta
    shape_binary: magenta
    shape_block: blue
    shape_bool: magenta
    shape_custom: green
    shape_datetime: cyan
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: magenta
    shape_id: blue_bold
    shape_int: magenta
    shape_internalcall: cyan_bold
    shape_list: cyan
    shape_nothing: red
    shape_operator: yellow
    shape_or: magenta
    shape_pipe: magenta
    shape_range: yellow
    shape_record: cyan
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue
    shape_variable: magenta

    hints: light_gray
    search_result: { fg: white bg: red }
}
