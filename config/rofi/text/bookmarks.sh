#!/bin/bash

theme="style_2"
dir="$HOME/.config/rofi/text"
DB="$HOME/.config/rofi/text/bookmarks.db"

function rofi_main_window() {
    rofi -dmenu -i -l 10 -p "$1" -theme "$dir/$theme" \
        -kb-custom-2 'Alt+c' \
        -kb-custom-3 'Alt+d' \
        -kb-custom-4 'Alt+a' \
        -kb-custom-5 'Alt+r'
}

function rofi_sub_window() {
    rofi -dmenu -i -no-fixed-num-lines -p "$1" -theme "$dir"/confirm.rasi "$2" "$3"
}

function get_bookmarks() {
    sqlite3 "$DB" "SELECT categoria || ': ' || titulo FROM bookmarks_view ORDER BY categoria, titulo;"
}

function get_categories() {
    sqlite3 "$DB" <<EOF
SELECT printf('%4d %s', count, categoria)
FROM category_stats;
EOF
}

function get_category_id() {
    local category_name="$1"
    local category_escaped="${category_name//\'/\'\'}"

    # Intentar obtener el ID
    local cat_id=$(sqlite3 "$DB" "SELECT id FROM categorias WHERE nombre = '$category_escaped';")

    # Si no existe, crear la categoría
    if [[ -z "$cat_id" ]]; then
        sqlite3 "$DB" "INSERT INTO categorias (nombre) VALUES ('$category_escaped');"
        cat_id=$(sqlite3 "$DB" "SELECT id FROM categorias WHERE nombre = '$category_escaped';")
    fi

    echo "$cat_id"
}

function write_bookmark() {
    uri=$(wl-paste)
    url_regex='^(https?|ftp|file)://[\p{L}\p{N}\-._~:/?#\[\]@!$&'"'"'()*+,;=%]+$'

    if [[ -z "$uri" ]]; then
        rofi_sub_window "Error: Clipboard is empty" -width 20
        return
    fi

    if ! echo "$uri" | grep -Pq "$url_regex"; then
        rofi_sub_window "Error: URL not valid in the clipboard" -width 20
        return
    fi

    # Mostrar categorías existentes con opción de crear nueva
    category=$(sqlite3 "$DB" "SELECT nombre FROM categorias ORDER BY nombre;" | \
        rofi -dmenu -i -p "Category (Alt+a to add new): " -theme "$dir/$theme" \
        -kb-custom-1 'Alt+a')

    exit_code=$?

    # Si presionó Alt+a, crear nueva categoría
    if [[ $exit_code -eq 10 ]]; then
        category=$(rofi_sub_window "New category name: ")
        if [[ -z "$category" ]]; then
            return
        fi
    elif [[ -z "$category" ]]; then
        # Si canceló o no seleccionó nada
        return
    fi

    # Pedir título
    title=$(rofi_sub_window "Title: ")
    if [[ -z "$title" ]]; then
        return
    fi

    # Obtener o crear ID de categoría
    category_id=$(get_category_id "$category")

    # Escapar comillas simples para SQL
    title_escaped="${title//\'/\'\'}"
    uri_escaped="${uri//\'/\'\'}"

    # Insertar en la base de datos
    result=$(sqlite3 "$DB" "INSERT OR IGNORE INTO elements (categoria, titulo, url) VALUES ($category_id, '$title_escaped', '$uri_escaped'); SELECT changes();" 2>&1)

    if [[ "$result" == "1" ]]; then
        rofi_sub_window "Bookmark added" -width 20
    else
        rofi_sub_window "This URL already exists" -width 20
    fi
}

function delete_bookmark() {
    selected=$(sqlite3 "$DB" "SELECT categoria || ': ' || titulo || ' α ' || url FROM bookmarks_view ORDER BY categoria, titulo;" | rofi_main_window "Selecciona un bookmark para eliminar")

    if [[ -z "$selected" ]]; then
        return
    fi

    url=$(echo "$selected" | awk -F ' α ' '{print $2}')

    if [[ -z "$url" ]]; then
        rofi_sub_window "Error: Bookmark not found" -width 20
        return
    fi

    option=$(rofi_sub_window "Delete this URL ${url:0:50}? (y/n): " -width 27)

    if [[ $option == "y" ]]; then
        url_escaped="${url//\'/\'\'}"
        sqlite3 "$DB" "DELETE FROM elements WHERE url = '$url_escaped';"
        rofi_sub_window "Bookmark deleted" -width 20
    fi
}

function open_random_sites() {
    local count=${1:-40}
    for ((i = 1; i <= count; i++)); do
        $BROWSER "https://searchmysite.net/search/random" &
    done
}

# Verificar que la base de datos existe
if [[ ! -f "$DB" ]]; then
    rofi_sub_window "Error: Database not found. Run migration script first." -width 35
    exit 1
fi

# Menú principal
name=$(get_bookmarks | rofi_main_window "Bookmarks")
exit_code=$?

case "$exit_code" in
    0)
        # Selección normal (Enter)
        if [[ -n "$name" ]]; then
            # Parsear "Category: Title" para buscar en la DB
            if [[ "$name" =~ ^([^:]+):\ *(.+)$ ]]; then
                category="${BASH_REMATCH[1]}"
                title="${BASH_REMATCH[2]}"
                category_escaped="${category//\'/\'\'}"
                title_escaped="${title//\'/\'\'}"
                url=$(sqlite3 "$DB" "SELECT url FROM bookmarks_view WHERE categoria = '$category_escaped' AND titulo = '$title_escaped' LIMIT 1;")
            else
                # Fallback: buscar solo por título
                name_escaped="${name//\'/\'\'}"
                url=$(sqlite3 "$DB" "SELECT url FROM bookmarks_view WHERE titulo = '$name_escaped' LIMIT 1;")
            fi

            if [[ -n "$url" ]]; then
                $BROWSER "$url"
            fi
        fi
        ;;
    11)
        # Tecla 'Alt+c' presionada (custom-key-2)
        category=$(get_categories | rofi_main_window "Bookmarks" | awk '{print $2}')
        [[ -n "$category" ]] || exit

        category_escaped="${category//\'/\'\'}"
        sqlite3 "$DB" "SELECT url FROM bookmarks_view WHERE categoria = '$category_escaped';" | while read -r url; do
            $BROWSER "$url" &
        done
        ;;
    12)
        # Tecla 'Alt+d' presionada (custom-key-3)
        delete_bookmark
        ;;
    13)
        # Tecla 'Alt+a' presionada (custom-key-4)
        write_bookmark
        ;;
    14)
        # Tecla 'Alt+r' presionada (custom-key-5)
        open_random_sites
        ;;
    *)
        exit
        ;;
esac
