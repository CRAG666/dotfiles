#!/usr/bin/env bash

rofi_sub_window() {
    rofi -dmenu -i -no-fixed-num-lines -p "$1" -theme "$ROFI_CONFIRM_THEME" "${@:2}"
}

sql() {
    sqlite3 -batch -noheader -cmd "PRAGMA foreign_keys = ON;" "$DB" "$@"
}

sql_escape() {
    local s=${1//\'/\'\'}
    printf "%s" "$s"
}

get_categories() {
    sql "SELECT nombre FROM categorias ORDER BY lower(nombre);"
}

ensure_category_and_get_id() {
    local category="$1"
    local cat_esc
    cat_esc=$(sql_escape "$category")
    sql "INSERT OR IGNORE INTO categorias(nombre) VALUES ('$cat_esc');"
    sql "SELECT id FROM categorias WHERE nombre='$cat_esc';"
}

entry_exists_in_category() {
    local category="$1" title="$2"
    sql "SELECT EXISTS(SELECT 1 FROM $ENTITY_TABLE e JOIN categorias c ON c.id=e.categoria WHERE c.nombre='$(sql_escape "$category")' AND e.titulo='$(sql_escape "$title")');" | tr -d '\n'
}

select_or_create_category() {
    local prompt="${1:-Categoría (Alt+a para nueva):}"
    local category exit_code
    set +e
    category=$(get_categories | rofi -dmenu -i \
        -p "$prompt" \
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

manage_categories() {
    local cat_query="SELECT printf('[%3d] %s', COALESCE(e.cnt,0), c.nombre) \
FROM categorias c \
LEFT JOIN (SELECT categoria, COUNT(*) AS cnt FROM $ENTITY_TABLE GROUP BY categoria) e \
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
            local count
            count=$(sql "SELECT COUNT(*) FROM $ENTITY_TABLE WHERE categoria=$cat_id;")
            if [[ "$count" -gt 0 ]]; then
                rofi_sub_window "No se puede eliminar: tiene $count elemento(s)"
                return
            fi
            local confirm
            confirm=$(printf "n\ny\n" | rofi_sub_window "Eliminar categoría vacía '${cat_name}'?") || return
            [[ "$confirm" == "y" ]] || return
            sql "DELETE FROM categorias WHERE id=$cat_id;"
            rofi_sub_window "Categoría eliminada"
            ;;
        0)
            local cnt
            cnt=$(sql "SELECT COUNT(*) FROM $ENTITY_TABLE WHERE categoria=$cat_id;")
            rofi_sub_window "'${cat_name}' tiene $cnt elemento(s). Alt+r renombrar · Alt+d eliminar"
            ;;
    esac
}

main_menu() {
    [[ -f "$DB" ]] || { rofi_sub_window "Error: Database not found" -theme-str 'window { width: 900px; }'; exit 1; }

    local selection exit_code
    set +e
    selection=$(list_entries | rofi_main_window "${ROFI_MODE}")
    exit_code=$?
    set -e

    case "$exit_code" in
        0)
            [[ -z "$selection" ]] && exit
            if [[ "$selection" =~ ^([^:]+):\ *(.+)$ ]]; then
                open_entry "${BASH_REMATCH[1]}|${BASH_REMATCH[2]}"
            else
                open_entry "|${selection}"
            fi
            ;;
        10)
            [[ -n "$selection" && "$selection" =~ ^([^:]+):\ *(.+)$ ]] && \
                view_entry "${BASH_REMATCH[1]}|${BASH_REMATCH[2]}"
            ;;
        11) browse_category ;;
        12) delete_entry ;;
        13) add_entry ;;
        14) edit_entry ;;
        15) manage_categories ;;
    esac
}
