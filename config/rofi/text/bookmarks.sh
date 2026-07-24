#!/bin/bash
set -euo pipefail

dir="$HOME/.config/rofi/text"
DB="$dir/bookmarks.db"
ENTITY_TABLE="elements"
ROFI_MAIN_THEME="$dir/style_2"
ROFI_CONFIRM_THEME="$dir/confirm.rasi"
ROFI_MODE="bookmarks"

: "${BROWSER:?Error: \$BROWSER no está definido}"

source "$dir/rofi_common.sh"

rofi_main_window() {
    rofi -dmenu -i -l 10 -p "$1" -theme "$ROFI_MAIN_THEME" \
        -kb-custom-2 'Alt+c' -kb-custom-3 'Alt+d' \
        -kb-custom-4 'Alt+a' -kb-custom-5 'Alt+e' \
        -kb-custom-6 'Alt+g'
}

list_entries() {
    sql "SELECT categoria || ': ' || titulo FROM bookmarks_view ORDER BY categoria, titulo;"
}

open_entry() {
    local sel="$1"
    local category="${sel%%|*}" title="${sel#*|}"
    local url
    if [[ -z "$category" ]]; then
        url=$(sql "SELECT url FROM bookmarks_view WHERE titulo='$(sql_escape "$title")' LIMIT 1;")
    else
        url=$(sql "SELECT url FROM bookmarks_view WHERE categoria='$(sql_escape "$category")' AND titulo='$(sql_escape "$title")' LIMIT 1;")
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

    local category_id
    category_id=$(ensure_category_and_get_id "$category")
    local result
    result=$(sql "INSERT OR IGNORE INTO elements(categoria,titulo,url) VALUES ($category_id,'$(sql_escape "$title")','$(sql_escape "$uri")'); SELECT changes();")
    if [[ "$result" == "1" ]]; then
        rofi_sub_window "Bookmark added" -theme-str 'window { width: 400px; }'
    else
        rofi_sub_window "This URL already exists" -theme-str 'window { width: 450px; }'
    fi
}

delete_entry() {
    local sel
    set +e
    sel=$(sql "SELECT categoria || ': ' || titulo || ' α ' || url FROM bookmarks_view ORDER BY categoria, titulo;" | rofi_main_window "Select to delete")
    set -e
    [[ -z "$sel" ]] && return
    local url
    url=$(echo "$sel" | awk -F ' α ' '{print $2}')
    [[ -n "$url" ]] || { rofi_sub_window "Error: Bookmark not found" -theme-str 'window { width: 600px; }'; return; }
    local opt
    opt=$(rofi_sub_window "Delete ${url:0:50}? (y/n): ") || true
    if [[ "$opt" == "y" ]]; then
        sql "DELETE FROM elements WHERE url='$(sql_escape "$url")';"
        rofi_sub_window "Bookmark deleted" -theme-str 'window { width: 400px; }'
    fi
}

edit_entry() {
    local sel
    set +e
    sel=$(sql "SELECT categoria || ': ' || titulo || ' α ' || url FROM bookmarks_view ORDER BY categoria, titulo;" | rofi_main_window "Select to edit")
    set -e
    [[ -z "$sel" ]] && return
    local url
    url=$(echo "$sel" | awk -F ' α ' '{print $2}')
    [[ -n "$url" ]] || { rofi_sub_window "Error: Not found" -theme-str 'window { width: 600px; }'; return; }

    local url_esc
    url_esc=$(sql_escape "$url")
    local cur_title cur_cat
    cur_title=$(sql "SELECT titulo FROM bookmarks_view WHERE url='$url_esc' LIMIT 1;")
    cur_cat=$(sql "SELECT categoria FROM bookmarks_view WHERE url='$url_esc' LIMIT 1;")

    local field
    field=$(printf "Title\nCategory\nBoth" | rofi -dmenu -i -p "What to edit?" -theme "$ROFI_MAIN_THEME") || true
    [[ -z "$field" ]] && return

    local new_title="$cur_title" new_category="$cur_cat"

    if [[ "$field" == "Title" || "$field" == "Both" ]]; then
        local t
        t=$(rofi_sub_window "New title: ") || true
        [[ -z "$t" ]] && return
        new_title="$t"
    fi
    if [[ "$field" == "Category" || "$field" == "Both" ]]; then
        new_category=$(select_or_create_category "New category (Alt+a to add new):") || return
    fi

    [[ "$new_title" == "$cur_title" && "$new_category" == "$cur_cat" ]] && { rofi_sub_window "No changes made" -theme-str 'window { width: 400px; }'; return; }

    local new_cat_id
    new_cat_id=$(ensure_category_and_get_id "$new_category")
    sql "UPDATE elements SET titulo='$(sql_escape "$new_title")', categoria=$new_cat_id WHERE url='$url_esc';"
    rofi_sub_window "Bookmark updated" -theme-str 'window { width: 400px; }'
}

browse_category() {
    local category
    set +e
    category=$(get_categories | rofi_main_window "Bookmarks")
    set -e
    [[ -n "$category" ]] || exit
    sql "SELECT url FROM bookmarks_view WHERE categoria='$(sql_escape "$category")';" | while read -r url; do
        $BROWSER "$url" &
    done
}

view_entry() { :; }

main_menu
