#!/usr/bin/env bash
set -euo pipefail

dir="$HOME/.config/rofi/text"
DB="$dir/notes.db"
ENTITY_TABLE="notas"
ROFI_MAIN_THEME="$dir/style_2"
ROFI_CONFIRM_THEME="$dir/confirm.rasi"
ROFI_MODE="notes"
NVIM_BIN="$HOME/.local/share/bob/nvim-bin/nvim"
TERMINAL="kitty"
CLIP_CMD="wl-copy"

source "$dir/rofi_common.sh"

rofi_main_window() {
    rofi -dmenu -i -l 10 -p "$1" -theme "$ROFI_MAIN_THEME" \
        -kb-custom-1 'Control+o' -kb-custom-2 'Alt+c' \
        -kb-custom-3 'Alt+d' -kb-custom-4 'Alt+a' \
        -kb-custom-5 'Alt+e' -kb-custom-6 'Alt+g'
}

list_entries() {
    sql "SELECT c.nombre || ': ' || n.titulo FROM notas n JOIN categorias c ON c.id=n.categoria ORDER BY lower(c.nombre), lower(n.titulo);"
}

open_entry() {
    local sel="$1"
    local category="${sel%%|*}" title="${sel#*|}"
    sql "SELECT contenido FROM notas n JOIN categorias c ON c.id=n.categoria WHERE c.nombre='$(sql_escape "$category")' AND n.titulo='$(sql_escape "$title")';" | "$CLIP_CMD"
}

view_entry() {
    local sel="$1"
    local category="${sel%%|*}" title="${sel#*|}"
    local tmp
    tmp=$(mktemp /tmp/rofi_prompt_view_XXXXXX.md)
    sql "SELECT contenido FROM notas n JOIN categorias c ON c.id=n.categoria WHERE c.nombre='$(sql_escape "$category")' AND n.titulo='$(sql_escape "$title")';" >"$tmp"
    "$TERMINAL" -e "$NVIM_BIN" "$tmp"
    rm -f "$tmp"
}

add_entry() {
    local category
    category=$(select_or_create_category) || return
    local title
    title=$(rofi_sub_window "Nombre del prompt:") || true
    [[ -z "$title" ]] && return
    if [[ "$(entry_exists_in_category "$category" "$title")" == "1" ]]; then
        rofi_sub_window "Error: el prompt ya existe"
        return
    fi
    local tmp
    tmp=$(mktemp /tmp/rofi_prompt_write_XXXXXX.md)
    "$TERMINAL" -e "$NVIM_BIN" "$tmp"
    local content
    content=$(<"$tmp")
    rm -f "$tmp"
    [[ -n "$content" ]] || { rofi_sub_window "Error: contenido vacío"; return; }
    local cat_id
    cat_id=$(ensure_category_and_get_id "$category")
    sql "INSERT INTO notas(categoria,titulo,contenido) VALUES ($cat_id,'$(sql_escape "$title")','$(sql_escape "$content")');"
    rofi_sub_window "Prompt añadido"
}

delete_entry() {
    local sel
    set +e
    sel=$(list_entries | rofi_main_window "Eliminar prompt")
    set -e
    [[ -z "$sel" ]] && return
    local category="${sel%%:*}" title="${sel#*: }"
    local confirm
    confirm=$(printf "n\ny\n" | rofi_sub_window "Eliminar '$title'?") || true
    [[ "$confirm" == "y" ]] || return
    sql "DELETE FROM notas WHERE categoria=(SELECT id FROM categorias WHERE nombre='$(sql_escape "$category")') AND titulo='$(sql_escape "$title")';"
    rofi_sub_window "Prompt eliminado"
}

edit_entry() {
    local sel
    set +e
    sel=$(list_entries | rofi_main_window "Editar prompt")
    set -e
    [[ -z "$sel" ]] && return
    local cur_category="${sel%%:*}" cur_title="${sel#*: }"

    local field
    set +e
    field=$(printf "Título\nCategoría\nAmbos\nContenido\nTodo" | rofi -dmenu -i -p "¿Qué editar?" -theme "$ROFI_MAIN_THEME")
    set -e
    [[ -z "$field" ]] && return

    local new_title="$cur_title" new_category="$cur_category" edit_content=0
    [[ "$field" == "Contenido" || "$field" == "Todo" ]] && edit_content=1

    if [[ "$field" == "Título" || "$field" == "Ambos" || "$field" == "Todo" ]]; then
        local input_title
        input_title=$(rofi_sub_window "Nuevo título:") || true
        [[ -z "$input_title" ]] && return
        if [[ "$(entry_exists_in_category "$cur_category" "$input_title")" == "1" ]]; then
            rofi_sub_window "Error: ya existe un prompt con ese título en esta categoría"
            return
        fi
        new_title="$input_title"
    fi

    if [[ "$field" == "Categoría" || "$field" == "Ambos" || "$field" == "Todo" ]]; then
        new_category=$(select_or_create_category) || return
    fi

    local new_content=""
    if [[ $edit_content -eq 1 ]]; then
        local tmp
        tmp=$(mktemp /tmp/rofi_prompt_edit_XXXXXX.md)
        sql "SELECT contenido FROM notas n JOIN categorias c ON c.id=n.categoria WHERE c.nombre='$(sql_escape "$cur_category")' AND n.titulo='$(sql_escape "$cur_title")';" >"$tmp"
        "$TERMINAL" -e "$NVIM_BIN" "$tmp"
        new_content=$(<"$tmp")
        rm -f "$tmp"
        [[ -n "$new_content" ]] || { rofi_sub_window "Error: el contenido no puede quedar vacío"; return; }
    fi

    [[ "$new_title" == "$cur_title" && "$new_category" == "$cur_category" && $edit_content -eq 0 ]] && { rofi_sub_window "Sin cambios"; return; }

    if [[ "$new_category" != "$cur_category" || "$new_title" != "$cur_title" ]]; then
        if [[ "$(entry_exists_in_category "$new_category" "$new_title")" == "1" ]]; then
            rofi_sub_window "Error: ya existe un prompt con ese título en la categoría destino"
            return
        fi
    fi

    local new_cat_id
    new_cat_id=$(ensure_category_and_get_id "$new_category")
    local cur_cat_esc cur_tit_esc
    cur_cat_esc=$(sql_escape "$cur_category")
    cur_tit_esc=$(sql_escape "$cur_title")

    if [[ $edit_content -eq 1 ]]; then
        sql "UPDATE notas SET titulo='$(sql_escape "$new_title")', categoria=$new_cat_id, contenido='$(sql_escape "$new_content")' WHERE titulo='$cur_tit_esc' AND categoria=(SELECT id FROM categorias WHERE nombre='$cur_cat_esc');"
    else
        sql "UPDATE notas SET titulo='$(sql_escape "$new_title")', categoria=$new_cat_id WHERE titulo='$cur_tit_esc' AND categoria=(SELECT id FROM categorias WHERE nombre='$cur_cat_esc');"
    fi
    rofi_sub_window "Prompt actualizado"
}

browse_category() {
    set +e
    local category
    category=$(get_categories | rofi_main_window "Categorías")
    set -e
    [[ -z "$category" ]] && exit 0
    set +e
    local title
    title=$(list_entries | grep "^${category}:" | sed 's/^[^:]*: //' | rofi_main_window "Prompts")
    set -e
    [[ -z "$title" ]] && exit 0
    sql "SELECT contenido FROM notas n JOIN categorias c ON c.id=n.categoria WHERE c.nombre='$(sql_escape "$category")' AND n.titulo='$(sql_escape "$title")';" | "$CLIP_CMD"
}

main_menu
