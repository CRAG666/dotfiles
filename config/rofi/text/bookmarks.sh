#!/bin/bash
set -euo pipefail

dir="$HOME/.config/rofi/text"
DB="$dir/bookmarks.db"
ENTITY_NAME="bookmark"
EDIT_FIELDS="Título\nCategoría\nAmbos"
ROFI_MODE="bookmarks"
ROFI_MAIN_THEME="$dir/style_2"
ROFI_CONFIRM_THEME="$dir/confirm.rasi"

: "${BROWSER:?Error: \$BROWSER no está definido}"

source "$dir/rofi_common.sh"

open_entry() {
    local sel="$1"
    local category="${sel%%|*}" title="${sel#*|}"
    local url
    if [[ -z "$category" ]]; then
        url=$(sql "SELECT url FROM entries_view WHERE title='$(sql_escape "$title")' LIMIT 1;")
    else
        url=$(sql "SELECT url FROM entries_view WHERE category='$(sql_escape "$category")' AND title='$(sql_escape "$title")' LIMIT 1;")
    fi
    [[ -n "$url" ]] && $BROWSER "$url"
}

add_entry() {
    local uri
    uri=$(wl-paste)
    [[ -n "$uri" ]] || { rofi_sub_window "Error: Clipboard is empty" -theme-str 'window { width: 700px; }'; return; }
    echo "$uri" | grep -qE '^https?://' || { rofi_sub_window "Error: URL not valid in the clipboard" -theme-str 'window { width: 800px; }'; return; }

    local category
    category=$(select_or_create_category "Category (Alt+a to add new):") || return
    local title
    title=$(rofi_sub_window "Title: ") || true
    [[ -z "$title" ]] && return

    local result
    result=$(sql "INSERT OR IGNORE INTO entries(category_id,title,url) VALUES ($(ensure_category_and_get_id "$category"),'$(sql_escape "$title")','$(sql_escape "$uri")'); SELECT changes();")
    if [[ "$result" == "1" ]]; then
        rofi_sub_window "Bookmark added" -theme-str 'window { width: 400px; }'
    else
        rofi_sub_window "This URL already exists" -theme-str 'window { width: 450px; }'
    fi
}

browse_category() {
    local category
    set +e
    category=$(get_categories | rofi_main_window "Bookmarks")
    set -e
    [[ -n "$category" ]] || exit
    sql "SELECT url FROM entries_view WHERE category='$(sql_escape "$category")';" | while read -r url; do
        $BROWSER "$url" &
    done
}

main_menu
