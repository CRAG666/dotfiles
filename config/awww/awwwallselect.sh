#!/usr/bin/env bash

# set -euo pipefail

#// Función para verificar dependencias
check_dependencies() {
    local missing_deps=0
    # ponytail: only the non-coreutils — mkdir/awk/readlink/etc are always present
    local deps=("jq" "fd" "magick" "rofi" "notify-send")

    # Verificar compositor disponible y agregar su herramienta
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl &>/dev/null; then
        deps+=("hyprctl")
        readonly DETECTED_COMPOSITOR="hyprland"
    elif command -v scrollmsg &>/dev/null; then
        deps+=("scrollmsg")
        readonly DETECTED_COMPOSITOR="sway"
    else
        echo "Error: No se detectó Hyprland ni Sway. Este script requiere uno de los dos." >&2
        exit 1
    fi

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "Error: Dependencia requerida '$dep' no encontrada." >&2
            missing_deps=1
        fi
    done
    if [[ "$missing_deps" -eq 1 ]]; then
        exit 1
    fi
}


#// Definir variables y constantes
readonly SCR_DIR="$(dirname "$(realpath "$0")")"
readonly CONF_DIR="${HOME}/.config/rofi"
readonly ROFI_CONF_USER="${CONF_DIR}/selector.rasi" # Asumiendo que este es un archivo de tema base
readonly THUMB_DIR="${HOME}/.cache/wallpapers/thumbnails"
readonly HYPR_BORDER_DEFAULT=2 # Valor predeterminado para el borde de Hyprland

# Directorios de búsqueda de fondos de pantalla (puede ser una lista separada por espacios o una ruta única)
# Ejemplo: WALLPAPER_PATHS=("${HOME}/Pictures/Fondos" "${HOME}/OtrosFondos")
WALLPAPER_PATHS=("~/Pictures/wallpaperCicle") # Original

#// Crear directorio de miniaturas si no existe
mkdir -p "${THUMB_DIR}"

#// Funciones auxiliares

# Manifiesto de hashes: el MD5 de una RUTA nunca cambia, así que se cachea en
# un archivo "hash<TAB>ruta" y solo se calcula (un md5sum) para rutas nuevas.
readonly HASH_MANIFEST="${THUMB_DIR}/.pathhash.map"
declare -A PATH_HASH_CACHE=()

load_hash_manifest() {
    [[ -f "$HASH_MANIFEST" ]] || return 0
    local h p
    while IFS=$'\t' read -r h p; do
        [[ -n "$h" && -n "$p" ]] && PATH_HASH_CACHE["$p"]="$h"
    done <"$HASH_MANIFEST"
}

# Calcula el hash MD5 de una cadena (ruta de archivo).
# Argumento 1: Cadena a hashear (ruta del archivo).
set_file_hash() {
    local sum _rest
    read -r sum _rest < <(printf '%s' "$1" | md5sum)
    printf '%s' "$sum"
}

# Recopila fondos, resuelve hashes (cacheados) y genera en paralelo solo las miniaturas faltantes.
# Args (namerefs): 1=lista rutas (out), 2=lista hashes (out), 3=rutas de búsqueda (in).
get_wallpapers_and_hashes() {
    local -n out_wall_list=$1 # Usar nameref para modificar el array original
    local -n out_wall_hash=$2 # Usar nameref
    local -n search_paths=$3

    out_wall_list=() # Limpiar arrays de salida
    out_wall_hash=()

    local -a all_found_files=()

    for search_path_raw in "${search_paths[@]}"; do
        local search_path_expanded="${search_path_raw/#\~/$HOME}"
        if [[ ! -d "$search_path_expanded" ]]; then
            echo "Advertencia: El directorio de búsqueda '$search_path_expanded' no existe." >&2
            continue
        fi
        # Usar mapfile para leer de forma segura los resultados de fd (maneja espacios en nombres de archivo)
        # fd busca archivos con las extensiones especificadas en el directorio de búsqueda
        mapfile -t found_files_in_path < <(fd --type f --extension jpg --extension jpeg --extension png --extension gif --extension bmp --extension tiff --extension svg --extension webp . "$search_path_expanded")
        all_found_files+=("${found_files_in_path[@]}")
    done

    if ((${#all_found_files[@]} == 0)); then
        echo "No se encontraron fondos de pantalla en las rutas especificadas." >&2
        return
    fi

    load_hash_manifest

    local file_path file_hash thumb_path
    local -a missing_thumb_args=()
    for file_path in "${all_found_files[@]}"; do
        file_hash="${PATH_HASH_CACHE[$file_path]:-}"
        if [[ -z "$file_hash" ]]; then
            file_hash=$(set_file_hash "$file_path")
            PATH_HASH_CACHE["$file_path"]="$file_hash"
            printf '%s\t%s\n' "$file_hash" "$file_path" >>"$HASH_MANIFEST"
        fi
        out_wall_list+=("$file_path")
        out_wall_hash+=("$file_hash")

        thumb_path="${THUMB_DIR}/${file_hash}.sqre"
        [[ -f "$thumb_path" ]] || missing_thumb_args+=("$file_path" "$thumb_path")
    done

    # Generar las miniaturas faltantes en paralelo (xargs -P). "[0]" toma el
    # primer fotograma, lo que cubre GIFs animados y es inocuo para el resto.
    if ((${#missing_thumb_args[@]})); then
        echo "Generando $((${#missing_thumb_args[@]} / 2)) miniatura(s) nueva(s)..." >&2
        printf '%s\0' "${missing_thumb_args[@]}" |
            xargs -0 -n2 -P "$(nproc)" sh -c \
                'magick "$1[0]" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$2" || echo "Error: magick falló al generar la miniatura para '\''$1'\''." >&2' _
    fi
}

#// --- Inicio del Script Principal ---

check_dependencies

#// Configuración de escala de Rofi
rofi_scale_input="${ROFI_SCALE:-10}"             # Leer variable de entorno o usar 10 por defecto
if ! [[ "$rofi_scale_input" =~ ^[0-9]+$ ]]; then # Validar que sea un número
    echo "Advertencia: ROFI_SCALE ('$rofi_scale_input') no es un número válido. Usando 10." >&2
    rofi_scale_input=10
fi
readonly ROFI_SCALE="$rofi_scale_input"
readonly ROFI_THEME_SCALE_OVERRIDE="configuration {font: \"SFPro Nerd Font Propo Display ${ROFI_SCALE}\";}"

#// Borde de elementos de Rofi basado en hypr_border
hypr_border_val="${hypr_border:-$HYPR_BORDER_DEFAULT}" # Usar variable de entorno si existe, sino el default del script
if ! [[ "$hypr_border_val" =~ ^[0-9]+$ ]]; then
    echo "Advertencia: hypr_border ('$hypr_border_val') no es un número válido. Usando $HYPR_BORDER_DEFAULT." >&2
    hypr_border_val=$HYPR_BORDER_DEFAULT
fi
readonly HYPR_BORDER="$hypr_border_val"
readonly ROFI_ELEMENT_BORDER=$((HYPR_BORDER * 3))

#// Adaptar Rofi al tamaño del monitor
# Obtener resolución X del monitor enfocado, o usar 1920 por defecto
get_focused_monitor_width() {
    case "${DETECTED_COMPOSITOR}" in
        hyprland)
            hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused == true) | ((.width / .scale) | floor)'
            ;;
        sway)
	    scrollmsg -t get_outputs | jq '.[] | select(.focused) | .current_mode.width'
            ;;
        *)
            echo "1920"
            ;;
    esac
}
mon_x_res_raw=$(get_focused_monitor_width)
if [[ "$mon_x_res_raw" == "null" ]] || [[ -z "$mon_x_res_raw" ]] || ! [[ "$mon_x_res_raw" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Advertencia: No se pudo obtener la resolución del monitor X o no es válida. Usando 1920." >&2
    mon_x_res=1920
else
    # Convertir a entero (jq puede devolver flotante)
    mon_x_res=$(printf "%.0f" "$mon_x_res_raw")
fi

#// Generar configuración dinámica de Rofi para el layout
# Estas son aproximaciones, ajustar según el tema de Rofi
readonly ELEMENT_ICON_SIZE_EM=28     # Coincide con element-icon{size:NNem;}
readonly ELEMENT_APPROX_PADDING_EM=8 # Suma de paddings y márgenes horizontales aproximados
readonly ELEMENT_APPROX_EXTRA_EM=5   # Espacio adicional o bordes
readonly ROFI_ELEMENT_WIDTH_CALCULATED=$(((ELEMENT_ICON_SIZE_EM + ELEMENT_APPROX_PADDING_EM + ELEMENT_APPROX_EXTRA_EM) * ROFI_SCALE))
readonly ROFI_MAX_AVAILABLE_WIDTH=$((mon_x_res - (4 * ROFI_SCALE))) # 4*ROFI_SCALE como margen total
rofi_col_count=$((ROFI_MAX_AVAILABLE_WIDTH / ROFI_ELEMENT_WIDTH_CALCULATED))
if ((rofi_col_count < 1)); then # Asegurar al menos una columna
    rofi_col_count=1
fi

readonly ROFI_LAYOUT_OVERRIDE=$(printf "window{width:100%%;} listview{columns:%s;spacing:5em;} element{border-radius:%spx;orientation:vertical;} element-icon{size:%sem;border-radius:0em;} element-text{padding:1em;}" \
    "$rofi_col_count" \
    "$ROFI_ELEMENT_BORDER" \
    "$ELEMENT_ICON_SIZE_EM")

#// Determinar el fondo de pantalla actual para preselección en Rofi
current_wall_basename=""
current_wall_symlink="${HOME}/.config/awww/wall.set"
if [[ -L "$current_wall_symlink" ]]; then
    target_wall_path=$(readlink -f "$current_wall_symlink")
    if [[ -n "$target_wall_path" && -f "$target_wall_path" ]]; then
        current_wall_basename="${target_wall_path##*/}"
    else
        echo "Advertencia: El enlace simbólico del fondo actual '$current_wall_symlink' está roto o no apunta a un archivo." >&2
    fi
elif [[ -e "$current_wall_symlink" ]]; then
    echo "Advertencia: '$current_wall_symlink' existe pero no es un enlace simbólico. No se puede determinar el fondo actual." >&2
else
    echo "Info: No se encontró el enlace del fondo de pantalla actual en '$current_wall_symlink'." >&2 # No es un error necesariamente
fi

#// Obtener la lista de fondos de pantalla y sus hashes
declare -a wall_full_paths_list=()
declare -a wall_hashes_list=()
get_wallpapers_and_hashes wall_full_paths_list wall_hashes_list WALLPAPER_PATHS

if ((${#wall_full_paths_list[@]} == 0)); then
    notify-send -u critical -a "HyDE Alert" "No se encontraron fondos de pantalla."
    exit 1
fi

#// Preparar la entrada para Rofi (basenames + cadena nombre\x00icon\x1fminiatura)
declare -a wall_basenames_list=()
rofi_input_string=""
for i in "${!wall_full_paths_list[@]}"; do
    full_path="${wall_full_paths_list[i]}"
    base_name="${full_path##*/}" # basename sin proceso externo
    hash_val="${wall_hashes_list[i]}" # Asume que los índices están sincronizados

    wall_basenames_list+=("$base_name")
    # Formato Rofi: "NombreArchivo\x00icon\x1f/ruta/a/miniatura.sqre"
    rofi_input_string+="${base_name}\x00icon\x1f${THUMB_DIR}/${hash_val}.sqre\n"
done

#// Lanzar Rofi (-select preselecciona el actual; xargs recorta la selección)
$CONF_DIR/colors/ramdom_color.sh
selected_basename=$(echo -ne "${rofi_input_string}" | rofi -dmenu \
    -theme-str "${ROFI_THEME_SCALE_OVERRIDE}" \
    -theme-str "${ROFI_LAYOUT_OVERRIDE}" \
    -config "${ROFI_CONF_USER}" \
    -select "${current_wall_basename}" \
    -p "Seleccionar Fondo:" | xargs)

#// Aplicar el fondo de pantalla seleccionado
if [[ -n "$selected_basename" ]]; then
    selected_full_path=""
    # Encontrar la ruta completa del basename seleccionado a partir de nuestra lista
    for path_candidate in "${wall_full_paths_list[@]}"; do
        if [[ "${path_candidate##*/}" == "$selected_basename" ]]; then
            selected_full_path="$path_candidate"
            break
        fi
    done

    if [[ -n "$selected_full_path" && -f "$selected_full_path" ]]; then
        # Llamar al script para cambiar el fondo
        if "${SCR_DIR}/awwwallpaper.sh" -s "${selected_full_path}"; then
            # Enviar notificación (hash ya resuelto en el manifiesto)
            selected_hash="${PATH_HASH_CACHE[$selected_full_path]}"
            notify-send -a "HyDE Alert" -i "${THUMB_DIR}/${selected_hash}.sqre" "Fondo cambiado a: ${selected_basename}"
        else
            notify-send -u critical -a "HyDE Alert" "Error al cambiar el fondo a: ${selected_basename}"
        fi
    else
        notify-send -u critical -a "HyDE Alert" "Error: El fondo seleccionado '${selected_basename}' no se encontró o no es un archivo."
    fi
else
    echo "No se seleccionó ningún fondo de pantalla." # No es un error, el usuario canceló.
fi

exit 0
