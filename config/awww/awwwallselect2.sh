#!/usr/bin/env bash

# Salir inmediatamente si un comando falla, si se usan variables no definidas,
# y propagar el código de salida en pipelines.
set -euo pipefail

#// Función para verificar dependencias
check_dependencies() {
    local missing_deps=0
    local deps=("realpath" "mkdir" "jq" "fd" "parallel" "magick" "md5sum" "rofi" "notify-send" "basename" "readlink" "dirname" "cut" "awk" "paste" "printf" "xargs")

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
readonly ROFI_CONF_USER="${CONF_DIR}/selector.rasi"
readonly THUMB_DIR="${HOME}/.cache/wallpapers/thumbnails"
readonly BORDER_DEFAULT=2

# Directorios de búsqueda de fondos de pantalla
WALLPAPER_PATHS=("/mnt/home/Pictures/wallpaperCicle")

#// Crear directorio de miniaturas si no existe
mkdir -p "${THUMB_DIR}"

#// Funciones auxiliares

generate_thumbnail() {
    local image_path="$1"
    local thumb_path="$2"

    [[ -f "$thumb_path" ]] && return 0

    echo "Generando miniatura para: $image_path -> $thumb_path" >&2
    if [[ "$image_path" == *.gif ]]; then
        magick "$image_path[0]" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$thumb_path" || return 1
    else
        magick "$image_path" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$thumb_path" || return 1
    fi
}

set_file_hash() {
    echo -n "$1" | md5sum | cut -d' ' -f1
}

_process_wallpaper_file() {
    local file_path="$1"
    local thumb_dir_local="$2"
    local file_hash
    file_hash=$(set_file_hash "$file_path")
    local thumbnail_path="${thumb_dir_local}/${file_hash}.sqre"

    generate_thumbnail "$file_path" "$thumbnail_path"
    printf "%s\n%s\n" "$file_path" "$file_hash"
}
export -f _process_wallpaper_file generate_thumbnail set_file_hash

get_wallpapers_and_hashes() {
    local -n out_wall_list=$1
    local -n out_wall_hash=$2
    local -n search_paths=$3

    out_wall_list=()
    out_wall_hash=()
    local -a all_found_files=()

    for search_path_raw in "${search_paths[@]}"; do
        local search_path_expanded="${search_path_raw/#\~/$HOME}"
        [[ ! -d "$search_path_expanded" ]] && { echo "Advertencia: '$search_path_expanded' no existe." >&2; continue; }
        mapfile -t found_files_in_path < <(fd --type f --extension jpg --extension jpeg --extension png --extension gif --extension bmp --extension tiff --extension svg . "$search_path_expanded")
        all_found_files+=("${found_files_in_path[@]}")
    done

    ((${#all_found_files[@]} == 0)) && { echo "No se encontraron fondos de pantalla." >&2; return; }

    local parallel_results
    parallel_results=$(printf "%s\n" "${all_found_files[@]}" | parallel -j+0 _process_wallpaper_file "{}" "${THUMB_DIR}")

    local current_file current_hash
    while IFS= read -r current_file && IFS= read -r current_hash; do
        [[ -n "$current_file" && -n "$current_hash" ]] && { out_wall_list+=("$current_file"); out_wall_hash+=("$current_hash"); }
    done <<<"$parallel_results"
}

#// Obtener ancho del monitor enfocado según compositor
get_focused_monitor_width() {
    case "${DETECTED_COMPOSITOR}" in
        hyprland)
            hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused == true) | ((.width / .scale) | floor)'
            ;;
        sway)
            # Tu output muestra: "Current mode: 2560x1440 @ 164.998 Hz"
            # JSON de scrollmsg tiene: .current_mode.width
            scrollmsg -t get_outputs -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .current_mode.width'
            ;;
        *)
            echo "1920"
            ;;
    esac
}

#// --- Inicio del Script Principal ---

check_dependencies

# Configurar variable de borde según compositor
if [[ "${DETECTED_COMPOSITOR}" == "hyprland" ]]; then
    border_val="${hypr_border:-$BORDER_DEFAULT}"
else
    border_val="${sway_border:-$BORDER_DEFAULT}"
fi
[[ ! "$border_val" =~ ^[0-9]+$ ]] && border_val=$BORDER_DEFAULT
readonly BORDER_VALUE="$border_val"
readonly ROFI_ELEMENT_BORDER=$((BORDER_VALUE * 3))

# Configuración de escala de Rofi
rofi_scale_input="${ROFI_SCALE:-10}"
[[ ! "$rofi_scale_input" =~ ^[0-9]+$ ]] && rofi_scale_input=10
readonly ROFI_SCALE="$rofi_scale_input"
readonly ROFI_THEME_SCALE_OVERRIDE="configuration {font: \"SFProDisplay Nerd Font ${ROFI_SCALE}\";}"

# Obtener resolución del monitor
mon_x_res_raw=$(get_focused_monitor_width)
if [[ -z "$mon_x_res_raw" || "$mon_x_res_raw" == "null" || ! "$mon_x_res_raw" =~ ^[0-9]+$ ]]; then
    echo "Advertencia: No se pudo obtener resolución del monitor. Usando 1920." >&2
    mon_x_res=1920
else
    mon_x_res="$mon_x_res_raw"
fi
echo "Debug: Compositor=${DETECTED_COMPOSITOR}, Resolución X=${mon_x_res}" >&2

# Calcular layout de Rofi
readonly ELEMENT_ICON_SIZE_EM=28
readonly ELEMENT_APPROX_PADDING_EM=8
readonly ELEMENT_APPROX_EXTRA_EM=5
readonly ROFI_ELEMENT_WIDTH_CALCULATED=$(((ELEMENT_ICON_SIZE_EM + ELEMENT_APPROX_PADDING_EM + ELEMENT_APPROX_EXTRA_EM) * ROFI_SCALE))
readonly ROFI_MAX_AVAILABLE_WIDTH=$((mon_x_res - (4 * ROFI_SCALE)))
rofi_col_count=$((ROFI_MAX_AVAILABLE_WIDTH / ROFI_ELEMENT_WIDTH_CALCULATED))
((rofi_col_count < 1)) && rofi_col_count=1

readonly ROFI_LAYOUT_OVERRIDE=$(printf "window{width:100%%;} listview{columns:%s;spacing:5em;} element{border-radius:%spx;orientation:vertical;} element-icon{size:%sem;border-radius:0em;} element-text{padding:1em;}" \
    "$rofi_col_count" \
    "$ROFI_ELEMENT_BORDER" \
    "$ELEMENT_ICON_SIZE_EM")

# Determinar fondo actual para preselección
current_wall_basename=""
current_wall_symlink="${HOME}/.config/awww/wall.set"
if [[ -L "$current_wall_symlink" ]]; then
    target_wall_path=$(readlink -f "$current_wall_symlink")
    [[ -n "$target_wall_path" && -f "$target_wall_path" ]] && current_wall_basename=$(basename "$target_wall_path")
fi

# Obtener lista de wallpapers
declare -a wall_full_paths_list=()
declare -a wall_hashes_list=()
get_wallpapers_and_hashes wall_full_paths_list wall_hashes_list WALLPAPER_PATHS

if ((${#wall_full_paths_list[@]} == 0)); then
    notify-send -u critical -a "HyDE Alert" "No se encontraron fondos de pantalla."
    exit 1
fi

# Preparar entrada para Rofi
rofi_input_string=""
for i in "${!wall_full_paths_list[@]}"; do
    full_path="${wall_full_paths_list[i]}"
    base_name=$(basename "$full_path")
    hash_val="${wall_hashes_list[i]}"
    rofi_input_string+="${base_name}\x00icon\x1f${THUMB_DIR}/${hash_val}.sqre\n"
done

# Lanzar Rofi
[[ -x "$CONF_DIR/colors/ramdom_color.sh" ]] && "$CONF_DIR/colors/ramdom_color.sh"

selected_basename=$(echo -ne "${rofi_input_string}" | rofi -dmenu \
    -theme-str "${ROFI_THEME_SCALE_OVERRIDE}" \
    -theme-str "${ROFI_LAYOUT_OVERRIDE}" \
    -config "${ROFI_CONF_USER}" \
    -select "${current_wall_basename}" \
    -p "Seleccionar Fondo:" | xargs)

# Aplicar fondo seleccionado
if [[ -n "$selected_basename" ]]; then
    selected_full_path=""
    for path_candidate in "${wall_full_paths_list[@]}"; do
        [[ "$(basename "$path_candidate")" == "$selected_basename" ]] && { selected_full_path="$path_candidate"; break; }
    done

    if [[ -n "$selected_full_path" && -f "$selected_full_path" ]]; then
        applied=false

        # Intentar con awwwallpaper.sh primero
        if [[ -x "${SCR_DIR}/awwwallpaper.sh" ]]; then
            if "${SCR_DIR}/awwwallpaper.sh" -s "${selected_full_path}" 2>/dev/null; then
                applied=true
            fi
        fi

        # Fallback para Sway con swaybg
        if [[ "$applied" == false && "${DETECTED_COMPOSITOR}" == "sway" ]] && command -v swaybg &>/dev/null; then
            if swaybg -m fill -i "${selected_full_path}" 2>/dev/null &
            then
                # Actualizar symlink si es posible
                [[ -d "$(dirname "$current_wall_symlink")" ]] && ln -sf "${selected_full_path}" "$current_wall_symlink" 2>/dev/null || true
                applied=true
            fi
        fi

        if [[ "$applied" == true ]]; then
            selected_hash=$(set_file_hash "$selected_full_path")
            notify-send -a "HyDE Alert" -i "${THUMB_DIR}/${selected_hash}.sqre" "Fondo cambiado a: ${selected_basename}"
        else
            notify-send -u critical -a "HyDE Alert" "Error al aplicar el fondo: ${selected_basename}"
        fi
    else
        notify-send -u critical -a "HyDE Alert" "Error: '${selected_basename}' no encontrado."
    fi
else
    echo "No se seleccionó ningún fondo."
fi

exit 0
