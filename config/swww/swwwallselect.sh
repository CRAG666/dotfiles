#!/usr/bin/env bash

# Salir inmediatamente si un comando falla, si se usan variables no definidas,
# y propagar el código de salida en pipelines.
set -euo pipefail

#// Función para verificar dependencias
check_dependencies() {
    local missing_deps=0
    local deps=("realpath" "mkdir" "hyprctl" "jq" "fd" "parallel" "magick" "md5sum" "rofi" "notify-send" "basename" "readlink" "dirname" "cut" "awk" "paste" "printf" "xargs")
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
# Ejemplo: WALLPAPER_PATHS=("${HOME}/Imágenes/Fondos" "${HOME}/OtrosFondos")
WALLPAPER_PATHS=("${HOME}/Imágenes/wallpaperCicle") # Original

#// Crear directorio de miniaturas si no existe
mkdir -p "${THUMB_DIR}"

#// Funciones auxiliares

# Genera una miniatura cuadrada para una imagen dada.
# Argumento 1: Ruta de la imagen original.
# Argumento 2: Ruta de la miniatura a crear.
generate_thumbnail() {
    local image_path="$1"
    local thumb_path="$2"

    # No regenerar si ya existe
    if [[ -f "$thumb_path" ]]; then
        return 0
    fi

    echo "Generando miniatura para: $image_path -> $thumb_path" >&2
    if [[ "$image_path" == *.gif ]]; then
        # Extraer el primer fotograma del GIF y redimensionar
        if ! magick "$image_path[0]" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$thumb_path"; then
            echo "Error: magick falló al generar la miniatura para el GIF '$image_path'." >&2
            # Crear un placeholder o no hacer nada podría ser una opción aquí
            return 1
        fi
    else
        if ! magick "$image_path" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$thumb_path"; then
            echo "Error: magick falló al generar la miniatura para '$image_path'." >&2
            return 1
        fi
    fi
}

# Calcula el hash MD5 de una cadena (ruta de archivo).
# Argumento 1: Cadena a hashear (ruta del archivo).
set_file_hash() {
    echo -n "$1" | md5sum | cut -d' ' -f1
}

# Procesa un archivo individual: genera su miniatura y devuelve la ruta y el hash.
# Esta función es llamada por GNU Parallel.
# Argumento 1: Ruta del archivo de imagen.
# Argumento 2: Directorio de miniaturas.
_process_wallpaper_file() {
    local file_path="$1"
    local thumb_dir_local="$2" # Renombrado para evitar colisión con THUMB_DIR global
    local file_hash
    file_hash=$(set_file_hash "$file_path")
    local thumbnail_path="${thumb_dir_local}/${file_hash}.sqre" # Usar extensión .sqre como en el original

    generate_thumbnail "$file_path" "$thumbnail_path" # La generación de miniaturas ya verifica la existencia

    # Salida para GNU Parallel: ruta del archivo y su hash, separados por nueva línea
    printf "%s\n%s\n" "$file_path" "$file_hash"
}
export -f _process_wallpaper_file # Necesario para GNU Parallel
export -f generate_thumbnail      # Necesario para _process_wallpaper_file si es llamado por parallel
export -f set_file_hash           # Necesario para _process_wallpaper_file

# Recopila fondos de pantalla, genera hashes y miniaturas.
# Argumento 1 (nombre de array, por referencia): Array para almacenar rutas completas de fondos.
# Argumento 2 (nombre de array, por referencia): Array para almacenar hashes de fondos.
# Argumento 3 (nombre de array, por referencia): Array de rutas donde buscar fondos.
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
        mapfile -t found_files_in_path < <(fd --type f --extension jpg --extension jpeg --extension png --extension gif --extension bmp --extension tiff --extension svg . "$search_path_expanded")
        all_found_files+=("${found_files_in_path[@]}")
    done

    if ((${#all_found_files[@]} == 0)); then
        echo "No se encontraron fondos de pantalla en las rutas especificadas." >&2
        return
    fi

    # Usar GNU Parallel para procesar archivos en paralelo
    # printf "%s\n" alimenta a parallel con un nombre de archivo por línea
    # _process_wallpaper_file recibe el nombre del archivo y THUMB_DIR
    # La salida de parallel (dos líneas por archivo: ruta y hash) se procesa en el bucle while
    local parallel_results
    parallel_results=$(printf "%s\n" "${all_found_files[@]}" | parallel -j+0 _process_wallpaper_file "{}" "${THUMB_DIR}")

    local current_file current_hash
    while IFS= read -r current_file && IFS= read -r current_hash; do
        if [[ -n "$current_file" && -n "$current_hash" ]]; then # Asegurarse de que ambos valores se leyeron
            out_wall_list+=("$current_file")
            out_wall_hash+=("$current_hash")
        fi
    done <<<"$parallel_results"
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
readonly ROFI_THEME_SCALE_OVERRIDE="configuration {font: \"SFProDisplay Nerd Font ${ROFI_SCALE}\";}"

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
mon_x_res_raw=$(hyprctl -j monitors | jq '.[] | select(.focused == true) | (.width / .scale)' || echo "null")
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
current_wall_symlink="${HOME}/.config/swww/wall.set"
if [[ -L "$current_wall_symlink" ]]; then
    target_wall_path=$(readlink -f "$current_wall_symlink")
    if [[ -n "$target_wall_path" && -f "$target_wall_path" ]]; then
        current_wall_basename=$(basename "$target_wall_path")
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

#// Preparar la entrada para Rofi
# wall_basenames_list: solo nombres de archivo para mostrar en Rofi.
# rofi_input_string: cadena formateada para Rofi con nombres de archivo e iconos.
declare -a wall_basenames_list=()
rofi_input_string=""
for i in "${!wall_full_paths_list[@]}"; do
    full_path="${wall_full_paths_list[i]}"
    base_name=$(basename "$full_path")
    hash_val="${wall_hashes_list[i]}" # Asume que los índices están sincronizados

    wall_basenames_list+=("$base_name")
    # Formato Rofi: "NombreArchivo\x00icon\x1f/ruta/a/miniatura.sqre"
    rofi_input_string+="${base_name}\x00icon\x1f${THUMB_DIR}/${hash_val}.sqre\n"
done

#// Lanzar Rofi
# Se usa -select "$current_wall_basename" para preseleccionar. Si está vacío, no hay preselección.
# xargs se usa para limpiar cualquier espacio en blanco alrededor de la selección de Rofi.
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
        if [[ "$(basename "$path_candidate")" == "$selected_basename" ]]; then
            selected_full_path="$path_candidate"
            break
        fi
    done

    if [[ -n "$selected_full_path" && -f "$selected_full_path" ]]; then
        # Llamar al script para cambiar el fondo
        if "${SCR_DIR}/swwwallpaper.sh" -s "${selected_full_path}"; then
            # Enviar notificación
            selected_hash=$(set_file_hash "$selected_full_path") # Re-hashear o buscar en wall_hashes_list
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
