#!/bin/sh

theme="style_2"
dir="$HOME/.config/rofi/text"

PROMPT_GALLERY="$HOME/.config/rofi/text/prompt_gallery"

# Asegurarse de que el archivo de prompts exista
touch "$PROMPT_GALLERY"

function rofi_main_window() {
    rofi -dmenu -i -l 10 -p "$1" -theme "$dir/$theme" \
        -kb-custom-1 'Control+o' \
        -kb-custom-2 'Alt+c' \
        -kb-custom-3 'Alt+d' \
        -kb-custom-4 'Alt+a'
}

function rofi_sub_window() {
    rofi -dmenu -i -no-fixed-num-lines -p "$1" -theme "$dir"/confirm.rasi
}

function get_prompts() {
    # Busca líneas que empiezan con ::: y contienen |, luego quita el prefijo :::
    grep '^:::.*|' "$PROMPT_GALLERY" | cut -c 4-
}

function get_display_prompts() {
    # Formatea 'categoria|nombre' a 'nombre (categoria)' para mostrar en rofi
    get_prompts | awk -F'|' '{if (NF==2) print $2 " (" $1 ")"}'
}

function get_categories() {
    get_prompts | cut -d'|' -f1 | sort -u
}

function write_prompt() {
    header=$(rofi_sub_window "Introduce 'categoría|nombre': ")
    if [[ -z "$header" || ! "$header" =~ .+\|.+ ]]; then
        rofi_sub_window "Error: Formato inválido. Usa 'categoría|nombre'"
        return
    fi

    if grep -q "^:::$header$" "$PROMPT_GALLERY"; then
        rofi_sub_window "Error: El nombre del prompt ya existe"
        return
    fi

    # Crear un archivo temporal para escribir el prompt
    TMP_FILE=$(mktemp /tmp/rofi_prompt_write_XXXXXX.md)

    # Abrir Neovim para escribir
    kitty nvim "$TMP_FILE"

    # Leer el contenido escrito en Neovim
    prompt_content=$(cat "$TMP_FILE")

    # Eliminar el archivo temporal
    rm "$TMP_FILE"

    # Verificar si se escribió contenido
    if [[ -z "$prompt_content" ]]; then
        rofi_sub_window "Error: No se escribió contenido en Neovim."
        return
    fi

    # El nuevo bloque completo, con su cabecera y terminador
    new_block=":::${header}\n${prompt_content}\n:::\n"

    # Simplemente añade el nuevo bloque al final del archivo
    printf "%b" "$new_block" >> "$PROMPT_GALLERY"
    rofi_sub_window "Prompt añadido"
}

function delete_prompt() {
    selected_display=$(get_display_prompts | rofi_main_window "Selecciona prompt a eliminar")
    [[ -z "$selected_display" ]] && return

    prompt_name=$(echo "$selected_display" | sed -e 's/ ([^)]*)//')
    category=$(echo "$selected_display" | sed -e 's/.*(//' -e 's/)//')
    selected="${category}|${prompt_name}"

    option=$(echo -e "n\ny" | rofi_sub_window "Eliminar '$selected'? (y/n)")
    [[ "$option" != "y" ]] && return

    TMP_FILE=$(mktemp)
    # Usar awk para eliminar el bloque completo
    awk -v target_header=":::${selected}" 'BEGIN { delete_mode = 0 }
        $0 == target_header {
            delete_mode = 1; # Empezar a eliminar
            next;
        }
        delete_mode == 1 && $0 == ":::" {
            delete_mode = 0; # Terminar de eliminar
            next;
        }
        delete_mode == 0 {
            print $0; # Imprimir la línea si no estamos en modo eliminación
        }
    ' "$PROMPT_GALLERY" > "$TMP_FILE"

    mv "$TMP_FILE" "$PROMPT_GALLERY"
    rofi_sub_window "Prompt eliminado"
}

function get_prompt_content_raw() {
    local prompt_name_full="$1"
    [[ -n "$prompt_name_full" ]] || return

    awk -v target="$prompt_name_full" '
        /^:::/ {
            if (substr($0, 4) == target) {
                p=1
            } else {
                p=0
            }
            next
        }
        p { print }
    ' "$PROMPT_GALLERY"
}

function copy_prompt_by_name() {
    local prompt_name_full="$1" # Esto es "categoria|nombre"
    [[ -n "$prompt_name_full" ]] || return

    # awk en modo "estado" para imprimir solo las líneas entre la cabecera correcta y el siguiente :::
    awk -v target="$prompt_name_full" '
        /^:::/ {
            if (substr($0, 4) == target) {
                p=1 # Activar impresión
            } else {
                p=0 # Desactivar impresión
            }
            next # No imprimir la línea de cabecera/terminador
        }
        p { print } # Si la impresión está activa, imprimir la línea
    ' "$PROMPT_GALLERY" | wl-copy
}

### Menú Principal ###
options="$(get_display_prompts)"
selection_display=$(echo -e "$options" | rofi_main_window "Prompt Gallery")
exit_code=$?

case "$exit_code" in
    0)
        # Selección normal (Enter)
        if [[ -n "$selection_display" ]]; then
            prompt_name=$(echo "$selection_display" | sed -e 's/ ([^)]*)//')
            category=$(echo "$selection_display" | sed -e 's/.*(//' -e 's/)//')
            full_id="${category}|${prompt_name}"
            copy_prompt_by_name "$full_id"
        fi
        ;;
    10)
        # Tecla 'Control+o' presionada (custom-key-1)
        if [[ -n "$selection_display" ]]; then
            prompt_name=$(echo "$selection_display" | sed -e 's/ ([^)]*)//')
            category=$(echo "$selection_display" | sed -e 's/.*(//' -e 's/)//')
            full_id="${category}|${prompt_name}"

            # Obtener el contenido actual del prompt
            current_content=$(get_prompt_content_raw "$full_id")

            # Crear un archivo temporal para ver
            TMP_FILE=$(mktemp /tmp/rofi_prompt_view_XXXXXX.md)
            printf "%s" "$current_content" > "$TMP_FILE"

            # Abrir Neovim para ver (no para editar y guardar)
            kitty nvim "$TMP_FILE"

            # Eliminar el archivo temporal
            rm "$TMP_FILE"
        fi
        ;;
    11)
        # Tecla 'Alt+c' presionada (custom-key-2)
        category=$(get_categories | rofi_main_window "Categorías")
        if [[ -n "$category" ]]; then
            prompt_name=$(get_prompts | grep "^$category|" | cut -d'|' -f2 | rofi_main_window "Prompts en $category")
            if [[ -n "$prompt_name" ]]; then
                full_id="${category}|${prompt_name}"
                copy_prompt_by_name "$full_id"
            fi
        fi
        ;;
    12)
        # Tecla 'Alt+d' presionada (custom-key-3)
        delete_prompt
        ;;
    13)
        # Tecla 'Alt+a' presionada (custom-key-4)
        write_prompt
        ;;
    *)
        exit
        ;;
esac
