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
        -kb-custom-4 'Alt+a'
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

    sel=$(get_display_prompts | rofi_main_window "Eliminar prompt") || return
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
        category=$(get_categories | rofi_main_window "Categorías") || exit 0
        title=$(get_prompts | grep "^$category|" | cut -d'|' -f2 | rofi_main_window "Prompts") || exit 0
        copy_prompt_by_name "${category}|${title}"
        ;;
    12)
        delete_prompt
        ;;
    13)
        write_prompt
        ;;
esac
