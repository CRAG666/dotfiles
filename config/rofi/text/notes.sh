#!/usr/bin/env bash
set -euo pipefail

dir="$HOME/.config/rofi/text"
DB="$dir/notes.db"
ENTITY_NAME="prompt"
CONTENT_COLUMN="content"
EDIT_FIELDS="Título\nCategoría\nAmbos\nContenido\nTodo"
ENABLE_VIEW=1
ROFI_MODE="notes"
ROFI_MAIN_THEME="$dir/style_2"
ROFI_CONFIRM_THEME="$dir/confirm.rasi"
NVIM_BIN="$HOME/.local/share/bob/nvim-bin/nvim"
TERMINAL="kitty"
CLIP_CMD="wl-copy"

source "$dir/rofi_common.sh"

note_content() {
    local category="$1" title="$2"
    sql "SELECT content FROM entries n JOIN categories c ON c.id=n.category_id WHERE c.name='$(sql_escape "$category")' AND n.title='$(sql_escape "$title")';"
}

edit_in_nvim() {
    local tmp
    tmp=$(mktemp "/tmp/rofi_prompt_$1_XXXXXX.md")
    [[ -n "${2:-}" ]] && sql "SELECT content FROM $ENTITY_TABLE WHERE id=$2;" >"$tmp"
    "$TERMINAL" -e "$NVIM_BIN" "$tmp"
    local content
    content=$(<"$tmp")
    rm -f "$tmp"
    printf "%s" "$content"
}

edit_content() {
    local content
    content=$(edit_in_nvim edit "$1")
    [[ -n "$content" ]] || rofi_sub_window "Error: el contenido no puede quedar vacío"
    printf "%s" "$content"
}

open_entry() {
    local sel="$1"
    note_content "${sel%%|*}" "${sel#*|}" | "$CLIP_CMD"
}

view_entry() {
    local sel="$1"
    local tmp
    tmp=$(mktemp /tmp/rofi_prompt_view_XXXXXX.md)
    note_content "${sel%%|*}" "${sel#*|}" >"$tmp"
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
    local content
    content=$(edit_in_nvim write)
    [[ -n "$content" ]] || { rofi_sub_window "Error: contenido vacío"; return; }
    sql "INSERT INTO entries(category_id,title,content) VALUES ($(ensure_category_and_get_id "$category"),'$(sql_escape "$title")','$(sql_escape "$content")');"
    rofi_sub_window "Prompt añadido"
}

browse_category() {
    local category
    set +e
    category=$(get_categories | rofi_main_window "Categorías")
    set -e
    [[ -z "$category" ]] && exit 0
    local title
    set +e
    title=$(list_entries | grep "^${category}:" | sed 's/^[^:]*: //' | rofi_main_window "Prompts")
    set -e
    [[ -z "$title" ]] && exit 0
    note_content "$category" "$title" | "$CLIP_CMD"
}

main_menu
