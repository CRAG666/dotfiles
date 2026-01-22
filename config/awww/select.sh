#!/usr/bin/env bash
# Script optimizado para selección de fondos de pantalla
# Variables
scrDir="$(dirname "$(realpath "$0")")"
confDir="${HOME}/.config"
rofiConf="${confDir}/rofi/selector.rasi"
thmbDir="${HOME}/.cache/wallpapers/thumbnails"
rofiScale="${ROFI_SCALE:-10}"
hypr_border=2

# Crear directorio de miniaturas si no existe
mkdir -p "${thmbDir}"

# Configuración de escala Rofi
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
elem_border=$((hypr_border * 3))

# Obtener resolución de monitor (con caché)
mon_x_res_cache="/tmp/mon_x_res_cache"
if [[ -f "$mon_x_res_cache" && $(($(date +%s) - $(stat -c %Y "$mon_x_res_cache"))) -lt 3600 ]]; then
    mon_x_res=$(cat "$mon_x_res_cache")
else
    mon_x_res=$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | (.width / .scale)')
    mon_x_res=${mon_x_res:-1920}
    echo "$mon_x_res" >"$mon_x_res_cache"
fi

# Generar configuración
elm_width=$(((28 + 8 + 5) * rofiScale))
max_avail=$((mon_x_res - (4 * rofiScale)))
col_count=$((max_avail / elm_width))
r_override="window{width:100%;} listview{columns:${col_count};spacing:5em;} element{border-radius:${elem_border}px;\
orientation:vertical;} element-icon{size:28em;border-radius:0em;} element-text{padding:1em;}"

# Función para generar hash (optimizada)
set_hash() {
    echo -n "$1" | md5sum | cut -d' ' -f1
}

# Función para generar miniaturas (en paralelo)
generate_thumbnail() {
    local image="$1"
    local thumbnail="$2"

    if [ ! -f "${thumbnail}" ]; then
        if [[ "$image" =~ \.gif$ ]]; then
            convert "$image[0]" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$thumbnail" &
        else
            convert "$image" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$thumbnail" &
        fi
    fi
}

# Ruta actual del fondo de pantalla
currentWall="$(basename "$(readlink -f "${HOME}/.config/awww/wall.set")")"

# Directorio de fondos de pantalla
wallDir="${HOME}/Imágenes/wallpaperCicle"

# Usar find una sola vez y procesar en paralelo
{
    # Cache de archivos
    cache_file="/tmp/wallpaper_cache"
    cache_hash="/tmp/wallpaper_hash"

    # Verificar si el caché existe y es reciente (menos de 5 minutos)
    if [[ -f "$cache_file" && -f "$cache_hash" && $(($(date +%s) - $(stat -c %Y "$cache_file"))) -lt 300 ]]; then
        wallList=($(cat "$cache_file"))
        wallHash=($(cat "$cache_hash"))
        wallListBase=($(basename -a "${wallList[@]}"))
    else
        # Crear listas temporales
        temp_list=$(mktemp)
        temp_hash=$(mktemp)
        temp_base=$(mktemp)

        # Buscar todas las imágenes de una vez
        find "${wallDir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.svg" \) | sort >"$temp_list"

        # Procesar cada imagen
        thumbnail_jobs=0
        max_jobs=4 # Número máximo de trabajos en paralelo

        while IFS= read -r file; do
            # Generar hash
            hash=$(set_hash "$file")
            echo "$hash" >>"$temp_hash"

            # Generar miniatura si es necesario
            thumbnail="${thmbDir}/${hash}.sqre"
            if [ ! -f "${thumbnail}" ]; then
                generate_thumbnail "$file" "$thumbnail"
                thumbnail_jobs=$((thumbnail_jobs + 1))

                # Limitar el número de trabajos en paralelo
                if [ $thumbnail_jobs -ge $max_jobs ]; then
                    wait
                    thumbnail_jobs=0
                fi
            fi

            # Guardar nombre base
            basename "$file" >>"$temp_base"
        done <"$temp_list"

        # Esperar a que terminen todas las miniaturas pendientes
        wait

        # Cargar los resultados
        mapfile -t wallList <"$temp_list"
        mapfile -t wallHash <"$temp_hash"
        mapfile -t wallListBase <"$temp_base"

        # Actualizar caché
        cp "$temp_list" "$cache_file"
        cp "$temp_hash" "$cache_hash"

        # Limpiar archivos temporales
        rm "$temp_list" "$temp_hash" "$temp_base"
    fi

    # Preparar datos para rofi (una sola vez)
    temp_rofi=$(mktemp)
    for i in "${!wallListBase[@]}"; do
        echo "${wallListBase[$i]}\x00icon\x1f${thmbDir}/${wallHash[$i]}.sqre" >>"$temp_rofi"
    done

    # Lanzar rofi
    rofiSel=$(rofi -dmenu -theme-str "${r_scale}" -theme-str "${r_override}" \
        -config "${rofiConf}" -select "${currentWall}" <"$temp_rofi" | xargs)

    rm "$temp_rofi"

    # Aplicar fondo de pantalla
    if [ -n "${rofiSel}" ]; then
        # Buscar el archivo completo basado en la selección
        for i in "${!wallListBase[@]}"; do
            if [ "${wallListBase[$i]}" = "${rofiSel}" ]; then
                setWall="${wallList[$i]}"
                wallHash="${wallHash[$i]}"
                break
            fi
        done

        if [ -n "${setWall}" ]; then
            "${scrDir}/awwwallpaper.sh" -s "${setWall}"
            notify-send -a "HyDE Alert" -i "${thmbDir}/${wallHash}.sqre" " ${rofiSel}"
        else
            notify-send -a "HyDE Alert" "Wallpaper not found"
        fi
    fi
} &>/dev/null # Suprimir salida innecesaria para mejorar rendimiento
