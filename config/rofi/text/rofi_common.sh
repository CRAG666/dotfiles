#!/usr/bin/env bash

: "${ENTITY_TABLE:=entries}" "${LIST_VIEW:=entries_view}"

rofi_sub_window() {
    rofi -dmenu -i -no-fixed-num-lines -p "$1" -theme "$ROFI_CONFIRM_THEME" "${@:2}"
}

rofi_main_window() {
    local view_kb=()
    [[ ${ENABLE_VIEW:-0} == 1 ]] && view_kb+=(-kb-custom-1 'Control+o')
    rofi -dmenu -i -l 10 -p "$1" -theme "$ROFI_MAIN_THEME" "${view_kb[@]}" \
        -kb-custom-2 'Alt+c' -kb-custom-3 'Alt+d' \
        -kb-custom-4 'Alt+a' -kb-custom-5 'Alt+e' \
        -kb-custom-6 'Alt+g'
}

sql() {
    sqlite3 -batch -noheader -cmd "PRAGMA foreign_keys = ON;" "$DB" "$@"
}

sql_escape() {
    local s=${1//\'/\'\'}
    printf "%s" "$s"
}

list_entries() {
    sql "SELECT category || ': ' || title FROM $LIST_VIEW ORDER BY lower(category), lower(title);"
}

entry_id() {
    local sel="$1"
    local category="${sel%%:*}" title="${sel#*: }"
    sql "SELECT id FROM $LIST_VIEW WHERE category='$(sql_escape "$category")' AND title='$(sql_escape "$title")' LIMIT 1;"
}

get_categories() {
    sql "SELECT name FROM categories ORDER BY lower(name);"
}

ensure_category_and_get_id() {
    local category="$1"
    local cat_esc
    cat_esc=$(sql_escape "$category")
    sql "INSERT OR IGNORE INTO categories(name) VALUES ('$cat_esc');"
    sql "SELECT id FROM categories WHERE name='$cat_esc';"
}

entry_exists_in_category() {
    local category="$1" title="$2"
    sql "SELECT EXISTS(SELECT 1 FROM $ENTITY_TABLE e JOIN categories c ON c.id=e.category_id WHERE c.name='$(sql_escape "$category")' AND e.title='$(sql_escape "$title")');" | tr -d '\n'
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

delete_entry() {
    local sel
    set +e
    sel=$(list_entries | rofi_main_window "Eliminar $ENTITY_NAME")
    set -e
    [[ -z "$sel" ]] && return
    local confirm
    confirm=$(printf "n\ny\n" | rofi_sub_window "¿Eliminar '${sel#*: }'?") || true
    [[ "$confirm" == "y" ]] || return
    sql "DELETE FROM $ENTITY_TABLE WHERE id=$(entry_id "$sel");"
    rofi_sub_window "${ENTITY_NAME^} eliminado"
}

edit_entry() {
    local sel
    set +e
    sel=$(list_entries | rofi_main_window "Editar $ENTITY_NAME")
    set -e
    [[ -z "$sel" ]] && return
    local id
    id=$(entry_id "$sel")
    [[ -n "$id" ]] || {
                        rofi_sub_window "Error: no encontrado"
                                                                return
    }

    local cur_category="${sel%%:*}" cur_title="${sel#*: }"

    local field
    set +e
    field=$(printf '%b' "$EDIT_FIELDS" | rofi -dmenu -i -p "¿Qué editar?" -theme "$ROFI_MAIN_THEME")
    set -e
    [[ -z "$field" ]] && return

    local new_title="$cur_title" new_category="$cur_category" new_content=""
    if [[ "$field" == "Título" || "$field" == "Ambos" || "$field" == "Todo" ]]; then
        local input_title
        input_title=$(rofi_sub_window "Nuevo título:") || true
        [[ -z "$input_title" ]] && return
        new_title="$input_title"
    fi

    if [[ "$field" == "Categoría" || "$field" == "Ambos" || "$field" == "Todo" ]]; then
        new_category=$(select_or_create_category) || return
    fi

    if [[ "$field" == "Contenido" || "$field" == "Todo" ]]; then
        new_content=$(edit_content "$id")
        [[ -n "$new_content" ]] || return
    fi

    [[ "$new_title" == "$cur_title" && "$new_category" == "$cur_category" && -z "$new_content" ]] &&
           {
             rofi_sub_window "Sin cambios"
                                            return
        }

    if [[ "$new_category" != "$cur_category" || "$new_title" != "$cur_title" ]] &&
           [[ "$(entry_exists_in_category "$new_category" "$new_title")" == "1" ]]; then
        rofi_sub_window "Error: ya existe un $ENTITY_NAME con ese título en esa categoría"
        return
    fi

    local new_cat_id tit_esc
    new_cat_id=$(ensure_category_and_get_id "$new_category")
    tit_esc=$(sql_escape "$new_title")
    local sets="title='$tit_esc', category_id=$new_cat_id"
    [[ -n "$new_content" ]] && sets+=", $CONTENT_COLUMN='$(sql_escape "$new_content")'"
    sql "UPDATE $ENTITY_TABLE SET $sets WHERE id=$id;"
    rofi_sub_window "${ENTITY_NAME^} actualizado"
}

manage_categories() {
    local cat_query="SELECT printf('[%3d] %s', COALESCE(e.cnt,0), c.name) \
FROM categories c \
LEFT JOIN (SELECT category_id, COUNT(*) AS cnt FROM $ENTITY_TABLE GROUP BY category_id) e \
ON c.id = e.category_id ORDER BY lower(c.name);"

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
        existing=$(sql "SELECT id FROM categories WHERE name='$esc';")
        if [[ -n "$existing" ]]; then
            rofi_sub_window "Ya existe esa categoría"
            return
        fi
        sql "INSERT INTO categories(name) VALUES ('$esc');"
        rofi_sub_window "Categoría '${new_cat}' creada"
        return
    fi

    [[ -z "$selected" ]] && return

    local cat_name
    cat_name=$(printf "%s" "$selected" | sed 's/^\[[ 0-9]*\] //')

    local cat_esc cat_id
    cat_esc=$(sql_escape "$cat_name")
    cat_id=$(sql "SELECT id FROM categories WHERE name='$cat_esc';")

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
            clash=$(sql "SELECT id FROM categories WHERE name='$new_esc';")
            if [[ -n "$clash" ]]; then
                rofi_sub_window "Ya existe una categoría con ese nombre"
                return
        fi
            sql "UPDATE categories SET name='$new_esc' WHERE id=$cat_id;"
            rofi_sub_window "Categoría renombrada a '${new_name}'"
            ;;
        12)
            local count
            count=$(sql "SELECT COUNT(*) FROM $ENTITY_TABLE WHERE category_id=$cat_id;")
            if [[ "$count" -gt 0 ]]; then
                rofi_sub_window "No se puede eliminar: tiene $count elemento(s)"
                return
        fi
            local confirm
            confirm=$(printf "n\ny\n" | rofi_sub_window "Eliminar categoría vacía '${cat_name}'?") || return
            [[ "$confirm" == "y" ]] || return
            sql "DELETE FROM categories WHERE id=$cat_id;"
            rofi_sub_window "Categoría eliminada"
            ;;
        0)
            local cnt
            cnt=$(sql "SELECT COUNT(*) FROM $ENTITY_TABLE WHERE category_id=$cat_id;")
            rofi_sub_window "'${cat_name}' tiene $cnt elemento(s). Alt+r renombrar · Alt+d eliminar"
            ;;
    esac
}

main_menu() {
    [[ -f "$DB" ]] || {
                        rofi_sub_window "Error: Database not found" -theme-str 'window { width: 900px; }'
                                                                                                           exit 1
    }

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
            [[ -n "$selection" && "$selection" =~ ^([^:]+):\ *(.+)$ ]] &&
                view_entry "${BASH_REMATCH[1]}|${BASH_REMATCH[2]}"
            ;;
        11) browse_category ;;
        12) delete_entry ;;
        13) add_entry ;;
        14) edit_entry ;;
        15) manage_categories ;;
    esac
}
