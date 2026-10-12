#!/usr/bin/env bash

# set -euo pipefail

#// Function to check dependencies
check_dependencies() {
    local missing_deps=0
    # ponytail: only the non-coreutils — mkdir/awk/readlink/etc are always present
    local deps=("jq" "fd" "magick" "rofi" "notify-send")

    # Detect the available compositor and add its tool
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


#// Define variables and constants
readonly SCR_DIR="$(dirname "$(realpath "$0")")"
readonly CONF_DIR="${HOME}/.config/rofi"
readonly ROFI_CONF_USER="${CONF_DIR}/selector.rasi" # Assuming this is a base theme file
readonly THUMB_DIR="${HOME}/.cache/wallpapers/thumbnails"
readonly HYPR_BORDER_DEFAULT=2 # Default value for the Hyprland border

# Wallpaper search directories (can be a space-separated list or a single path)
# Example: WALLPAPER_PATHS=("${HOME}/Pictures/Fondos" "${HOME}/OtrosFondos")
WALLPAPER_PATHS=("~/Pictures/wallpaperCicle") # Original

#// Create the thumbnail directory if it does not exist
mkdir -p "${THUMB_DIR}"

#// Helper functions

# Hash manifest: the MD5 of a PATH never changes, so it is cached in
# a "hash<TAB>path" file and only computed (one md5sum) for new paths.
readonly HASH_MANIFEST="${THUMB_DIR}/.pathhash.map"
declare -A PATH_HASH_CACHE=()

load_hash_manifest() {
    [[ -f "$HASH_MANIFEST" ]] || return 0
    local h p
    while IFS=$'\t' read -r h p; do
        [[ -n "$h" && -n "$p" ]] && PATH_HASH_CACHE["$p"]="$h"
    done <"$HASH_MANIFEST"
}

# Compute the MD5 hash of a string (file path).
# Argument 1: string to hash (file path).
set_file_hash() {
    local sum _rest
    read -r sum _rest < <(printf '%s' "$1" | md5sum)
    printf '%s' "$sum"
}

# Collect wallpapers, resolve (cached) hashes and generate only the missing thumbnails in parallel.
# Args (namerefs): 1=path list (out), 2=hash list (out), 3=search paths (in).
get_wallpapers_and_hashes() {
    local -n out_wall_list=$1 # Use a nameref to modify the original array
    local -n out_wall_hash=$2 # Use a nameref
    local -n search_paths=$3

    out_wall_list=() # Clear the output arrays
    out_wall_hash=()

    local -a all_found_files=()

    for search_path_raw in "${search_paths[@]}"; do
        local search_path_expanded="${search_path_raw/#\~/$HOME}"
        if [[ ! -d "$search_path_expanded" ]]; then
            echo "Advertencia: El directorio de búsqueda '$search_path_expanded' no existe." >&2
            continue
        fi
        # Use mapfile to safely read fd's results (handles spaces in file names)
        # fd finds files with the given extensions in the search directory
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

    # Generate the missing thumbnails in parallel (xargs -P). "[0]" takes the
    # first frame, which covers animated GIFs and is harmless for the rest.
    if ((${#missing_thumb_args[@]})); then
        echo "Generando $((${#missing_thumb_args[@]} / 2)) miniatura(s) nueva(s)..." >&2
        printf '%s\0' "${missing_thumb_args[@]}" |
            xargs -0 -n2 -P "$(nproc)" sh -c \
                'magick "$1[0]" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$2" || echo "Error: magick falló al generar la miniatura para '\''$1'\''." >&2' _
    fi
}

#// --- Main Script Start ---

check_dependencies

#// Rofi scale configuration
rofi_scale_input="${ROFI_SCALE:-10}"             # Read env variable or default to 10
if ! [[ "$rofi_scale_input" =~ ^[0-9]+$ ]]; then # Validate that it is a number
    echo "Advertencia: ROFI_SCALE ('$rofi_scale_input') no es un número válido. Usando 10." >&2
    rofi_scale_input=10
fi
readonly ROFI_SCALE="$rofi_scale_input"
readonly ROFI_THEME_SCALE_OVERRIDE="configuration {font: \"SFPro Nerd Font Propo Display ${ROFI_SCALE}\";}"

#// Rofi element border based on hypr_border
hypr_border_val="${hypr_border:-$HYPR_BORDER_DEFAULT}" # Use the env variable if set, else the script default
if ! [[ "$hypr_border_val" =~ ^[0-9]+$ ]]; then
    echo "Advertencia: hypr_border ('$hypr_border_val') no es un número válido. Usando $HYPR_BORDER_DEFAULT." >&2
    hypr_border_val=$HYPR_BORDER_DEFAULT
fi
readonly HYPR_BORDER="$hypr_border_val"
readonly ROFI_ELEMENT_BORDER=$((HYPR_BORDER * 3))

#// Fit Rofi to the monitor size
# Get the focused monitor's X resolution, or default to 1920
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
    # Convert to integer (jq may return a float)
    mon_x_res=$(printf "%.0f" "$mon_x_res_raw")
fi

#// Generate dynamic Rofi configuration for the layout
# These are approximations; adjust to the Rofi theme
readonly ELEMENT_ICON_SIZE_EM=28     # Matches element-icon{size:NNem;}
readonly ELEMENT_APPROX_PADDING_EM=8 # Sum of approximate horizontal paddings and margins
readonly ELEMENT_APPROX_EXTRA_EM=5   # Extra space or borders
readonly ROFI_ELEMENT_WIDTH_CALCULATED=$(((ELEMENT_ICON_SIZE_EM + ELEMENT_APPROX_PADDING_EM + ELEMENT_APPROX_EXTRA_EM) * ROFI_SCALE))
readonly ROFI_MAX_AVAILABLE_WIDTH=$((mon_x_res - (4 * ROFI_SCALE))) # 4*ROFI_SCALE as total margin
rofi_col_count=$((ROFI_MAX_AVAILABLE_WIDTH / ROFI_ELEMENT_WIDTH_CALCULATED))
if ((rofi_col_count < 1)); then # Ensure at least one column
    rofi_col_count=1
fi

readonly ROFI_LAYOUT_OVERRIDE=$(printf "window{width:100%%;} listview{columns:%s;spacing:5em;} element{border-radius:%spx;orientation:vertical;} element-icon{size:%sem;border-radius:0em;} element-text{padding:1em;}" \
    "$rofi_col_count" \
    "$ROFI_ELEMENT_BORDER" \
    "$ELEMENT_ICON_SIZE_EM")

#// Determine the current wallpaper for preselection in Rofi
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
    echo "Info: No se encontró el enlace del fondo de pantalla actual en '$current_wall_symlink'." >&2 # Not necessarily an error
fi

#// Get the wallpaper list and its hashes
declare -a wall_full_paths_list=()
declare -a wall_hashes_list=()
get_wallpapers_and_hashes wall_full_paths_list wall_hashes_list WALLPAPER_PATHS

if ((${#wall_full_paths_list[@]} == 0)); then
    notify-send -u critical -a "HyDE Alert" "No se encontraron fondos de pantalla."
    exit 1
fi

#// Prepare the Rofi input (basenames + name\x00icon\x1fthumbnail string)
declare -a wall_basenames_list=()
rofi_input_string=""
for i in "${!wall_full_paths_list[@]}"; do
    full_path="${wall_full_paths_list[i]}"
    base_name="${full_path##*/}" # basename without an external process
    hash_val="${wall_hashes_list[i]}" # Assumes the indices are in sync

    wall_basenames_list+=("$base_name")
    # Rofi format: "FileName\x00icon\x1f/path/to/thumbnail.sqre"
    rofi_input_string+="${base_name}\x00icon\x1f${THUMB_DIR}/${hash_val}.sqre\n"
done

#// Launch Rofi (-select preselects the current one; xargs trims the selection)
$CONF_DIR/colors/ramdom_color.sh
selected_basename=$(echo -ne "${rofi_input_string}" | rofi -dmenu \
    -theme-str "${ROFI_THEME_SCALE_OVERRIDE}" \
    -theme-str "${ROFI_LAYOUT_OVERRIDE}" \
    -config "${ROFI_CONF_USER}" \
    -select "${current_wall_basename}" \
    -p "Seleccionar Fondo:" | xargs)

#// Apply the selected wallpaper
if [[ -n "$selected_basename" ]]; then
    selected_full_path=""
    # Find the full path of the selected basename in our list
    for path_candidate in "${wall_full_paths_list[@]}"; do
        if [[ "${path_candidate##*/}" == "$selected_basename" ]]; then
            selected_full_path="$path_candidate"
            break
        fi
    done

    if [[ -n "$selected_full_path" && -f "$selected_full_path" ]]; then
        # Call the script that changes the wallpaper
        if "${SCR_DIR}/awwwallpaper.sh" -s "${selected_full_path}"; then
            # Send notification (hash already resolved in the manifest)
            selected_hash="${PATH_HASH_CACHE[$selected_full_path]}"
            notify-send -a "HyDE Alert" -i "${THUMB_DIR}/${selected_hash}.sqre" "Fondo cambiado a: ${selected_basename}"
        else
            notify-send -u critical -a "HyDE Alert" "Error al cambiar el fondo a: ${selected_basename}"
        fi
    else
        notify-send -u critical -a "HyDE Alert" "Error: El fondo seleccionado '${selected_basename}' no se encontró o no es un archivo."
    fi
else
    echo "No se seleccionó ningún fondo de pantalla." # Not an error, the user cancelled.
fi

exit 0
