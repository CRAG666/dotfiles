#!/usr/bin/env bash
set -euo pipefail

# ---------- Config ----------
theme="style_2"
dir="$HOME/.config/rofi/text"
DB_PATH="$HOME/.config/rofi/text/notes.db"
ROFI_MAIN_THEME="$dir/$theme"
ROFI_CONFIRM_THEME="$dir/confirm.rasi"
NVIM_BIN="$HOME/.local/share/bob/nvim-bin/nvim"
TERMINAL="kitty"
CLIP_CMD="wl-copy"

# ---------- Utilidades ----------
rofi_main_window() {
    rofi -dmenu -i -l 10 -p "$1" -theme "$ROFI_MAIN_THEME" \
        -kb-custom-1 'Control+o' \
        -kb-custom-2 'Alt+c' \
        -kb-custom-3 'Alt+d' \
        -kb-custom-4 'Alt+a' \
        -kb-custom-5 'Alt+e' \
        -kb-custom-6 'Alt+g'
}

rofi_sub_window() {
    rofi -dmenu -i -no-fixed-num-lines -p "$1" -theme "$ROFI_CONFIRM_THEME"
}

sql() {
    sqlite3 -batch -noheader -cmd "PRAGMA foreign_keys = ON;" "$DB_PATH" "$@"
}

sql_escape() {
    local s=${1//\'/\'\'}
    printf "%s" "$s"
}

# ---------- Queries ----------
get_prompts() {
    sql "
        SELECT c.nombre || '|' || n.titulo
        FROM notas n
        JOIN categorias c ON c.id = n.categoria
        ORDER BY lower(c.nombre), lower(n.titulo);
    "
}

get_display_prompts() {
    sql "
        SELECT c.nombre || ': ' || n.titulo
        FROM notas n
        JOIN categorias c ON c.id = n.categoria
        ORDER BY lower(c.nombre), lower(n.titulo);
    "
}

get_categories() {
    sql "SELECT nombre FROM categorias ORDER BY lower(nombre);"
}

# ---------- Parsing UI ----------
parse_display_prompt() {
    local input="$1"
    local category title
    category="${input%%:*}"
    title="${input#*: }"
    printf "%s|%s" "$category" "$title"
}

# ---------- DB helpers ----------
ensure_category_and_get_id() {
    local category="$1"
    local cat_esc
    cat_esc=$(sql_escape "$category")
    sql "INSERT OR IGNORE INTO categorias(nombre) VALUES ('$cat_esc');"
    sql "SELECT id FROM categorias WHERE nombre='$cat_esc';"
}

note_exists_in_category() {
    local category="$1" title="$2"
    local cat_esc tit_esc
    cat_esc=$(sql_escape "$category")
    tit_esc=$(sql_escape "$title")
    sql "
        SELECT EXISTS(
            SELECT 1
            FROM notas n
            JOIN categorias c ON c.id=n.categoria
            WHERE c.nombre='$cat_esc' AND n.titulo='$tit_esc'
        );
    "
}

insert_note() {
    local category="$1" title="$2" content="$3"
    local cat_id tit_esc cont_esc
    cat_id=$(ensure_category_and_get_id "$category")
    tit_esc=$(sql_escape "$title")
    cont_esc=$(sql_escape "$content")
    sql "
        INSERT INTO notas(categoria,titulo,contenido)
        VALUES ($cat_id,'$tit_esc','$cont_esc');
    "
}

delete_note() {
    local category="$1" title="$2"
    local cat_esc tit_esc
    cat_esc=$(sql_escape "$category")
    tit_esc=$(sql_escape "$title")
    sql "
        DELETE FROM notas
        WHERE categoria=(SELECT id FROM categorias WHERE nombre='$cat_esc')
          AND titulo='$tit_esc';
    "
}

get_note_content() {
    local category="$1" title="$2"
    local cat_esc tit_esc
    cat_esc=$(sql_escape "$category")
    tit_esc=$(sql_escape "$title")
    sql "
        SELECT contenido
        FROM notas n
        JOIN categorias c ON c.id=n.categoria
        WHERE c.nombre='$cat_esc' AND n.titulo='$tit_esc';
    "
}

# ---------- UI helpers ----------
select_or_create_category() {
    local category exit_code
    set +e
    category=$(get_categories | rofi -dmenu -i \
        -p "Categoría (Alt+a para nueva):" \
        -theme "$ROFI_MAIN_THEME" \
        -kb-custom-1 'Alt+a')
    exit_code=$?
    set -e
    if [[ $exit_code -eq 10 ]]; then
        category=$(rofi_sub_window "Nombre de la nueva categoría:")
        [[ -z "$category" ]] && return 1
    elif [[ -z "$category" ]]; then
        return 1
    fi
    printf "%s" "$category"
}

# ---------- UI acciones ----------
write_prompt() {
    local category title
    category=$(select_or_create_category) || return
    title=$(rofi_sub_window "Nombre del prompt:")
    [[ -z "$title" ]] && return
    if [[ "$(note_exists_in_category "$category" "$title" | tr -d '\n')" == "1" ]]; then
        rofi_sub_window "Error: el prompt ya existe"
        return
    fi
    local tmp
    tmp=$(mktemp /tmp/rofi_prompt_write_XXXXXX.md)
    "$TERMINAL" -e "$NVIM_BIN" "$tmp"
    local content
    content=$(<"$tmp")
    rm -f "$tmp"
    [[ -n "$content" ]] || {
        rofi_sub_window "Error: contenido vacío"
        return
    }
    insert_note "$category" "$title" "$content"
    rofi_sub_window "Prompt añadido"
}

delete_prompt() {
    local sel full_id category title
    set +e
    sel=$(get_display_prompts | rofi_main_window "Eliminar prompt")
    set -e
    [[ -z "$sel" ]] && return
    full_id=$(parse_display_prompt "$sel")
    category="${full_id%%|*}"
    title="${full_id#*|}"
    local confirm
    confirm=$(printf "n\ny\n" | rofi_sub_window "Eliminar '$title'?") || return
    [[ "$confirm" == "y" ]] || return
    delete_note "$category" "$title"
    rofi_sub_window "Prompt eliminado"
}

copy_prompt_by_name() {
    local full="$1"
    local category="${full%%|*}"
    local title="${full#*|}"
    get_note_content "$category" "$title" | "$CLIP_CMD"
}

view_prompt_in_nvim() {
    local full="$1"
    local category="${full%%|*}"
    local title="${full#*|}"
    local tmp
    tmp=$(mktemp /tmp/rofi_prompt_view_XXXXXX.md)
    get_note_content "$category" "$title" >"$tmp"
    "$TERMINAL" -e "$NVIM_BIN" "$tmp"
    rm -f "$tmp"
}

# ------------------------------------------------------------------
# Edita el título y/o la categoría de una nota existente (Alt+e)
# ------------------------------------------------------------------
edit_prompt() {
    local sel full_id current_category current_title
    set +e
    sel=$(get_display_prompts | rofi_main_window "Editar prompt")
    set -e
    [[ -z "$sel" ]] && return

    full_id=$(parse_display_prompt "$sel")
    current_category="${full_id%%|*}"
    current_title="${full_id#*|}"

    # Elegir qué editar
    local field
    set +e
    field=$(printf "Título\nCategoría\nAmbos\nContenido\nTodo" | rofi -dmenu -i \
        -p "¿Qué editar?" -theme "$ROFI_MAIN_THEME")
    set -e
    [[ -z "$field" ]] && return

    local new_title="$current_title"
    local new_category="$current_category"
    local edit_content=0
    [[ "$field" == "Contenido" || "$field" == "Todo" ]] && edit_content=1

    # --- Editar título ---
    if [[ "$field" == "Título" || "$field" == "Ambos" || "$field" == "Todo" ]]; then
        local input_title
        input_title=$(rofi_sub_window "Nuevo título:")
        [[ -z "$input_title" ]] && return
        if [[ "$(note_exists_in_category "$current_category" "$input_title" | tr -d '\n')" == "1" ]]; then
            rofi_sub_window "Error: ya existe un prompt con ese título en esta categoría"
            return
        fi
        new_title="$input_title"
    fi

    # --- Editar categoría ---
    if [[ "$field" == "Categoría" || "$field" == "Ambos" || "$field" == "Todo" ]]; then
        local new_cat
        new_cat=$(select_or_create_category) || return
        new_category="$new_cat"
    fi

    # --- Editar contenido en neovim ---
    local new_content=""
    if [[ $edit_content -eq 1 ]]; then
        local tmp
        tmp=$(mktemp /tmp/rofi_prompt_edit_XXXXXX.md)
        get_note_content "$current_category" "$current_title" >"$tmp"
        "$TERMINAL" -e "$NVIM_BIN" "$tmp"
        new_content=$(<"$tmp")
        rm -f "$tmp"
        if [[ -z "$new_content" ]]; then
            rofi_sub_window "Error: el contenido no puede quedar vacío"
            return
        fi
    fi

    # Sin cambios reales
    if [[ "$new_title" == "$current_title" && "$new_category" == "$current_category" && $edit_content -eq 0 ]]; then
        rofi_sub_window "Sin cambios"
        return
    fi

    # Verificar conflicto en destino si cambió categoría o título
    if [[ "$new_category" != "$current_category" || "$new_title" != "$current_title" ]]; then
        if [[ "$(note_exists_in_category "$new_category" "$new_title" | tr -d '\n')" == "1" ]]; then
            rofi_sub_window "Error: ya existe un prompt con ese título en la categoría destino"
            return
        fi
    fi

    local new_cat_id tit_esc cur_cat_esc cur_tit_esc
    new_cat_id=$(ensure_category_and_get_id "$new_category")
    tit_esc=$(sql_escape "$new_title")
    cur_cat_esc=$(sql_escape "$current_category")
    cur_tit_esc=$(sql_escape "$current_title")

    if [[ $edit_content -eq 1 ]]; then
        local cont_esc
        cont_esc=$(sql_escape "$new_content")
        sql "
            UPDATE notas
            SET titulo='$tit_esc', categoria=$new_cat_id, contenido='$cont_esc'
            WHERE titulo='$cur_tit_esc'
              AND categoria=(SELECT id FROM categorias WHERE nombre='$cur_cat_esc');
        "
    else
        sql "
            UPDATE notas
            SET titulo='$tit_esc', categoria=$new_cat_id
            WHERE titulo='$cur_tit_esc'
              AND categoria=(SELECT id FROM categorias WHERE nombre='$cur_cat_esc');
        "
    fi
    rofi_sub_window "Prompt actualizado"
}

# ------------------------------------------------------------------
# Gestión de categorías: agregar, renombrar, eliminar vacías (Alt+g)
# ------------------------------------------------------------------
manage_categories() {
    local cat_query="SELECT printf('[%3d] %s', COALESCE(e.cnt,0), c.nombre) \
FROM categorias c \
LEFT JOIN (SELECT categoria, COUNT(*) AS cnt FROM notas GROUP BY categoria) e \
ON c.id = e.categoria ORDER BY lower(c.nombre);"

    local selected exit_code
    set +e
    selected=$(sql "$cat_query" |
        rofi -dmenu -i -l 10 \
            -p "Categorías (Alt+a nueva, Alt+r renombrar, Alt+d eliminar vacía):" \
            -theme "$ROFI_MAIN_THEME" \
            -kb-custom-1 'Alt+a' \
            -kb-custom-2 'Alt+r' \
            -kb-custom-3 'Alt+d')
    exit_code=$?
    set -e

    # Alt+a: agregar categoría nueva sin selección previa
    if [[ $exit_code -eq 10 ]]; then
        local new_cat
        new_cat=$(rofi_sub_window "Nombre de la nueva categoría:")
        [[ -z "$new_cat" ]] && return
        local esc
        esc=$(sql_escape "$new_cat")
        local existing
        existing=$(sql "SELECT id FROM categorias WHERE nombre='$esc';")
        if [[ -n "$existing" ]]; then
            rofi_sub_window "Ya existe esa categoría"
            return
        fi
        sql "INSERT INTO categorias(nombre) VALUES ('$esc');"
        rofi_sub_window "Categoría '${new_cat}' creada"
        return
    fi

    [[ -z "$selected" ]] && return

    # Extraer nombre limpio (quitar el prefijo "[NNN] ")
    local cat_name
    cat_name=$(printf "%s" "$selected" | sed 's/^\[[ 0-9]*\] //')

    local cat_esc cat_id
    cat_esc=$(sql_escape "$cat_name")
    cat_id=$(sql "SELECT id FROM categorias WHERE nombre='$cat_esc';")

    if [[ -z "$cat_id" ]]; then
        rofi_sub_window "Error: categoría no encontrada"
        return
    fi

    case "$exit_code" in
        11)
            # Alt+r: renombrar
            local new_name
            new_name=$(rofi_sub_window "Nuevo nombre para '${cat_name}':")
            [[ -z "$new_name" ]] && return
            local new_esc
            new_esc=$(sql_escape "$new_name")
            local clash
            clash=$(sql "SELECT id FROM categorias WHERE nombre='$new_esc';")
            if [[ -n "$clash" ]]; then
                rofi_sub_window "Ya existe una categoría con ese nombre"
                return
        fi
            sql "UPDATE categorias SET nombre='$new_esc' WHERE id=$cat_id;"
            rofi_sub_window "Categoría renombrada a '${new_name}'"
            ;;
        12)
            # Alt+d: eliminar si está vacía
            local count
            count=$(sql "SELECT COUNT(*) FROM notas WHERE categoria=$cat_id;")
            if [[ "$count" -gt 0 ]]; then
                rofi_sub_window "No se puede eliminar: tiene $count nota(s)"
                return
        fi
            local confirm
            confirm=$(printf "n\ny\n" | rofi_sub_window "Eliminar categoría vacía '${cat_name}'?") || return
            [[ "$confirm" == "y" ]] || return
            sql "DELETE FROM categorias WHERE id=$cat_id;"
            rofi_sub_window "Categoría eliminada"
            ;;
        0)
            # Enter: info
            local cnt
            cnt=$(sql "SELECT COUNT(*) FROM notas WHERE categoria=$cat_id;")
            rofi_sub_window "'${cat_name}' tiene $cnt nota(s). Alt+r renombrar · Alt+d eliminar"
            ;;
    esac
}

# ---------- Main ----------
options=$(get_display_prompts)
set +e
selection_display=$(printf "%s\n" "$options" | rofi_main_window "Prompt Gallery")
exit_code=$?
set -e

case "$exit_code" in
    0)
        [[ -n "$selection_display" ]] || exit 0
        copy_prompt_by_name "$(parse_display_prompt "$selection_display")"
        ;;
    10)
        view_prompt_in_nvim "$(parse_display_prompt "$selection_display")"
        ;;
    11)
        set +e
        category=$(get_categories | rofi_main_window "Categorías")
        set -e
        [[ -z "$category" ]] && exit 0
        set +e
        title=$(get_prompts | grep "^${category}|" | cut -d'|' -f2 | rofi_main_window "Prompts")
        set -e
        [[ -z "$title" ]] && exit 0
        copy_prompt_by_name "${category}|${title}"
        ;;
    12)
        delete_prompt
        ;;
    13)
        write_prompt
        ;;
    14)
        # Alt+e: editar nota
        edit_prompt
        ;;
    15)
        # Alt+g: gestionar categorías
        manage_categories
        ;;
esac
