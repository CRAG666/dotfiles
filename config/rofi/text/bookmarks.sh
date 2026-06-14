#!/bin/bash

theme="style_2"
dir="$HOME/.config/rofi/text"
DB="$HOME/.config/rofi/text/bookmarks.db"

: "${BROWSER:?Error: \$BROWSER no está definido}"

function rofi_main_window() {
    rofi -dmenu -i -l 10 -p "$1" -theme "$dir/$theme" \
        -kb-custom-2 'Alt+c' \
        -kb-custom-3 'Alt+d' \
        -kb-custom-4 'Alt+a' \
        -kb-custom-5 'Alt+r' \
        -kb-custom-6 'Alt+e' \
        -kb-custom-7 'Alt+g'
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

    local cat_id
    cat_id=$(sqlite3 "$DB" "SELECT id FROM categorias WHERE nombre = '$category_escaped';")

    if [[ -z "$cat_id" ]]; then
        sqlite3 "$DB" "INSERT INTO categorias (nombre) VALUES ('$category_escaped');"
        cat_id=$(sqlite3 "$DB" "SELECT id FROM categorias WHERE nombre = '$category_escaped';")
    fi

    echo "$cat_id"
}

# ------------------------------------------------------------------
# Agrega una nueva categoría manualmente (llamada desde write_bookmark)
# ------------------------------------------------------------------
function add_category() {
    local new_cat
    new_cat=$(rofi_sub_window "New category name: ")

    if [[ -z "$new_cat" ]]; then
        return 1
    fi

    local escaped="${new_cat//\'/\'\'}"
    local existing
    existing=$(sqlite3 "$DB" "SELECT id FROM categorias WHERE nombre = '$escaped';")

    if [[ -n "$existing" ]]; then
        rofi_sub_window "Category already exists" -theme-str 'window { width: 450px; }'
        return 1
    fi

    sqlite3 "$DB" "INSERT INTO categorias (nombre) VALUES ('$escaped');"
    rofi_sub_window "Category '${new_cat}' added" -theme-str 'window { width: 450px; }'

    # Devuelve el nombre para que write_bookmark pueda usarlo directamente
    echo "$new_cat"
}

function write_bookmark() {
    local uri
    uri=$(wl-paste)
    local url_regex='^(https?|ftp|file)://[\p{L}\p{N}\-._~:/?#\[\]@!$&'"'"'()*+,;=%]+$'

    if [[ -z "$uri" ]]; then
        rofi_sub_window "Error: Clipboard is empty" -theme-str 'window { width: 700px; }'
        return
    fi

    if ! echo "$uri" | grep -Pq "$url_regex"; then
        rofi_sub_window "Error: URL not valid in the clipboard" -theme-str 'window { width: 800px; }'
        return
    fi

    # Mostrar categorías con opción Alt+a para agregar nueva
    local category exit_code
    category=$(sqlite3 "$DB" "SELECT nombre FROM categorias ORDER BY nombre;" |
        rofi -dmenu -i -p "Category (Alt+a to add new): " -theme "$dir/$theme" \
            -kb-custom-1 'Alt+a')
    exit_code=$?

    if [[ $exit_code -eq 10 ]]; then
        # Alt+a: crear nueva categoría y usarla directamente
        category=$(add_category)
        if [[ -z "$category" ]]; then
            return
        fi
    elif [[ -z "$category" ]]; then
        return
    fi

    local title
    title=$(rofi_sub_window "Title: ")
    if [[ -z "$title" ]]; then
        return
    fi

    local category_id
    category_id=$(get_category_id "$category")

    local title_escaped="${title//\'/\'\'}"
    local uri_escaped="${uri//\'/\'\'}"

    local result
    result=$(sqlite3 "$DB" "INSERT OR IGNORE INTO elements (categoria, titulo, url) VALUES ($category_id, '$title_escaped', '$uri_escaped'); SELECT changes();" 2>&1)

    if [[ "$result" == "1" ]]; then
        rofi_sub_window "Bookmark added" -theme-str 'window { width: 400px; }'
    else
        rofi_sub_window "This URL already exists" -theme-str 'window { width: 450px; }'
    fi
}

function delete_bookmark() {
    local selected
    selected=$(sqlite3 "$DB" "SELECT categoria || ': ' || titulo || ' α ' || url FROM bookmarks_view ORDER BY categoria, titulo;" | rofi_main_window "Select a bookmark to delete")

    if [[ -z "$selected" ]]; then
        return
    fi

    local url
    url=$(echo "$selected" | awk -F ' α ' '{print $2}')

    if [[ -z "$url" ]]; then
        rofi_sub_window "Error: Bookmark not found" -theme-str 'window { width: 600px; }'
        return
    fi

    local option
    option=$(rofi_sub_window "Delete this URL ${url:0:50}? (y/n): " -theme-str 'window { width: 450px; }')

    if [[ "$option" == "y" ]]; then
        local url_escaped="${url//\'/\'\'}"
        sqlite3 "$DB" "DELETE FROM elements WHERE url = '$url_escaped';"
        rofi_sub_window "Bookmark deleted" -theme-str 'window { width: 400px; }'
    fi
}

# ------------------------------------------------------------------
# Edita el título y/o la categoría de un bookmark existente
# ------------------------------------------------------------------
function edit_bookmark() {
    # 1. Seleccionar el bookmark a editar
    local selected
    selected=$(sqlite3 "$DB" "SELECT categoria || ': ' || titulo || ' α ' || url FROM bookmarks_view ORDER BY categoria, titulo;" |
          rofi_main_window "Select a bookmark to edit")

    if [[ -z "$selected" ]]; then
        return
    fi

    local url
    url=$(echo "$selected" | awk -F ' α ' '{print $2}')

    if [[ -z "$url" ]]; then
        rofi_sub_window "Error: Bookmark not found" -theme-str 'window { width: 600px; }'
        return
    fi

    # Obtener datos actuales del bookmark
    local url_escaped="${url//\'/\'\'}"
    local current_title current_category
    current_title=$(sqlite3 "$DB" "SELECT titulo FROM bookmarks_view WHERE url = '$url_escaped' LIMIT 1;")
    current_category=$(sqlite3 "$DB" "SELECT categoria FROM bookmarks_view WHERE url = '$url_escaped' LIMIT 1;")

    # 2. Elegir qué editar
    local field
    field=$(printf "Title\nCategory\nBoth" | rofi -dmenu -i -p "What to edit?" -theme "$dir/$theme")

    if [[ -z "$field" ]]; then
        return
    fi

    local new_title="$current_title"
    local new_category="$current_category"
    local changed=0

    # --- Editar título ---
    if [[ "$field" == "Title" || "$field" == "Both" ]]; then
        local input_title
        input_title=$(echo "$current_title" | rofi_sub_window "New title: ")
        if [[ -z "$input_title" ]]; then
            return
        fi
        new_title="$input_title"
        ((changed++))
    fi

    # --- Editar categoría ---
    if [[ "$field" == "Category" || "$field" == "Both" ]]; then
        local exit_code_cat
        new_category=$(sqlite3 "$DB" "SELECT nombre FROM categorias ORDER BY nombre;" |
            rofi -dmenu -i -p "New category (Alt+a to add new): " -theme "$dir/$theme" \
                -kb-custom-1 'Alt+a')
        exit_code_cat=$?

        if [[ $exit_code_cat -eq 10 ]]; then
            new_category=$(add_category)
            if [[ -z "$new_category" ]]; then
                return
            fi
        elif [[ -z "$new_category" ]]; then
            return
        fi
        ((changed++))
    fi

    # Nada cambió (mismo valor)
    if [[ "$new_title" == "$current_title" && "$new_category" == "$current_category" ]]; then
        rofi_sub_window "No changes made" -theme-str 'window { width: 400px; }'
        return
    fi

    # Obtener (o crear) el ID de la nueva categoría
    local new_cat_id
    new_cat_id=$(get_category_id "$new_category")

    local new_title_escaped="${new_title//\'/\'\'}"

    sqlite3 "$DB" "UPDATE elements SET titulo = '$new_title_escaped', categoria = $new_cat_id WHERE url = '$url_escaped';"

    rofi_sub_window "Bookmark updated" -theme-str 'window { width: 400px; }'
}

# ------------------------------------------------------------------
# Gestión de categorías: renombrar o eliminar las vacías (Alt+g)
# ------------------------------------------------------------------
function manage_categories() {
    # Mostrar todas las categorías con su conteo de elementos
    local cat_query="SELECT printf('[%3d] %s', COALESCE(e.cnt, 0), c.nombre) \
FROM categorias c \
LEFT JOIN (SELECT categoria, COUNT(*) AS cnt FROM elements GROUP BY categoria) e \
ON c.id = e.categoria ORDER BY c.nombre;"

    local selected
    selected=$(sqlite3 "$DB" "$cat_query" |
        rofi -dmenu -i -l 10 -p "Manage categories (Alt+r rename, Alt+d delete empty):" \
            -theme "$dir/$theme" \
            -kb-custom-1 'Alt+r' \
            -kb-custom-2 'Alt+d')
    local exit_code=$?

    if [[ -z "$selected" ]]; then
        return
    fi

    # Extraer nombre limpio (quitar el prefijo "[NNN] ")
    local cat_name
    cat_name=$(echo "$selected" | sed 's/^\[[ 0-9]*\] //')

    local cat_escaped="${cat_name//\'/\'\'}"
    local cat_id
    cat_id=$(sqlite3 "$DB" "SELECT id FROM categorias WHERE nombre = '$cat_escaped';")

    if [[ -z "$cat_id" ]]; then
        rofi_sub_window "Error: Category not found" -theme-str 'window { width: 500px; }'
        return
    fi

    case "$exit_code" in
        10)
            # Alt+r: renombrar categoría
            local new_name
            new_name=$(rofi_sub_window "New name for '${cat_name}': ")
            if [[ -z "$new_name" ]]; then
                return
        fi

            local new_name_escaped="${new_name//\'/\'\'}"
            local existing
            existing=$(sqlite3 "$DB" "SELECT id FROM categorias WHERE nombre = '$new_name_escaped';")
            if [[ -n "$existing" ]]; then
                rofi_sub_window "A category with that name already exists" -theme-str 'window { width: 550px; }'
                return
        fi

            sqlite3 "$DB" "UPDATE categorias SET nombre = '$new_name_escaped' WHERE id = $cat_id;"
            rofi_sub_window "Category renamed to '${new_name}'" -theme-str 'window { width: 500px; }'
            ;;
        11)
            # Alt+d: eliminar solo si está vacía
            local count
            count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM elements WHERE categoria = $cat_id;")
            if [[ "$count" -gt 0 ]]; then
                rofi_sub_window "Cannot delete: category has $count bookmark(s)" -theme-str 'window { width: 600px; }'
                return
        fi

            local option
            option=$(rofi_sub_window "Delete empty category '${cat_name}'? (y/n): " -theme-str 'window { width: 550px; }')
            if [[ "$option" == "y" ]]; then
                sqlite3 "$DB" "DELETE FROM categorias WHERE id = $cat_id;"
                rofi_sub_window "Category deleted" -theme-str 'window { width: 400px; }'
        fi
            ;;
        0)
            # Enter sin tecla especial: mostrar info
            local cnt
            cnt=$(sqlite3 "$DB" "SELECT COUNT(*) FROM elements WHERE categoria = $cat_id;")
            rofi_sub_window "'${cat_name}' has $cnt bookmark(s). Alt+r to rename, Alt+d to delete." \
                -theme-str 'window { width: 700px; }'
            ;;
    esac
}

function open_random_sites() {
    local count=${1:-40}
    for ((i = 1; i <= count; i++)); do
        $BROWSER "https://searchmysite.net/search/random" &
    done
}

# Verificar que la base de datos existe
if [[ ! -f "$DB" ]]; then
    rofi_sub_window "Error: Database not found. Run migration script first." -theme-str 'window { width: 900px; }'
    exit 1
fi

# Menú principal
name=$(get_bookmarks | rofi_main_window "Bookmarks")
exit_code=$?

case "$exit_code" in
    0)
        if [[ -n "$name" ]]; then
            url=""
            if [[ "$name" =~ ^([^:]+):\ *(.+)$ ]]; then
                category="${BASH_REMATCH[1]}"
                title="${BASH_REMATCH[2]}"
                category_escaped="${category//\'/\'\'}"
                title_escaped="${title//\'/\'\'}"
                url=$(sqlite3 "$DB" "SELECT url FROM bookmarks_view WHERE categoria = '$category_escaped' AND titulo = '$title_escaped' LIMIT 1;")
        else
                name_escaped="${name//\'/\'\'}"
                url=$(sqlite3 "$DB" "SELECT url FROM bookmarks_view WHERE titulo = '$name_escaped' LIMIT 1;")
        fi
            if [[ -n "$url" ]]; then
                $BROWSER "$url"
        fi
    fi
        ;;
    11)
        # Alt+c: abrir todos los bookmarks de una categoría
        category=$(get_categories | rofi_main_window "Bookmarks" | awk '{print $2}')
        [[ -n "$category" ]] || exit
        category_escaped="${category//\'/\'\'}"
        sqlite3 "$DB" "SELECT url FROM bookmarks_view WHERE categoria = '$category_escaped';" | while read -r url; do
            $BROWSER "$url" &
    done
        ;;
    12)
        # Alt+d: eliminar bookmark
        delete_bookmark
        ;;
    13)
        # Alt+a: agregar bookmark
        write_bookmark
        ;;
    14)
        # Alt+r: abrir sitios aleatorios
        open_random_sites
        ;;
    15)
        # Alt+e: editar bookmark
        edit_bookmark
        ;;
    16)
        # Alt+g: gestionar categorías
        manage_categories
        ;;
    *)
        exit
        ;;
esac
