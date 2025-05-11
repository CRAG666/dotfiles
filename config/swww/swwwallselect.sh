#!/usr/bin/env bash

#// set variables

scrDir="$(dirname "$(realpath "$0")")"
confDir="${HOME}/.config"
rofiConf="${confDir}/rofi/selector.rasi"
thmbDir="${HOME}/.cache/wallpapers/thumbnails"
rofiScale="${ROFI_SCALE:-10}"
hypr_border=2 # Define un valor predeterminado para hypr_border

# Create thumbnail directory if it doesn't exist
mkdir -p "${thmbDir}"

#// set rofi scaling

[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
elem_border=$((hypr_border * 3))

#// scale for monitor

mon_x_res=$(hyprctl -j monitors | jq '.[] | select(.focused == true) | (.width / .scale)')
mon_x_res=${mon_x_res:-1920} # Valor predeterminado si no se puede obtener

#// generate config

elm_width=$(((28 + 8 + 5) * rofiScale))
max_avail=$((mon_x_res - (4 * rofiScale)))
col_count=$((max_avail / elm_width))
r_override="window{width:100%;} listview{columns:${col_count};spacing:5em;} element{border-radius:${elem_border}px;\
orientation:vertical;} element-icon{size:28em;border-radius:0em;} element-text{padding:1em;}"

#// Define funciones faltantes

generate_thumbnail() {
    local image="$1"
    local thumbnail="$2"
    if [ ! -f "${thumbnail}" ]; then
        if [[ "$image" =~ \.gif$ ]]; then
            # Extraer el primer fotograma del GIF y guardarlo como PNG
            magick "$image[0]" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$thumbnail"
        else
            magick "$image" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$thumbnail"
        fi
    fi
}

get_hashmap() {
    local -n paths=$1
    wallList=()
    wallHash=()
    for path in "${paths[@]}"; do
        files=($(find "${path/#\~/$HOME}" -type f -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.svg"))
        for file in "${files[@]}"; do
            hash=$(set_hash "$file")
            thumbnail="${thmbDir}/${hash}.sqre"
            if [ ! -f "${thumbnail}" ]; then
                generate_thumbnail "$file" "$thumbnail"
            fi
            wallList+=("$file")
            wallHash+=("$hash")
        done
    done
}

set_hash() {
    local file="$1"
    echo -n "$file" | md5sum | awk '{print $1}'
}

#// launch rofi menu

currentWall="$(basename "$(readlink -f "${HOME}/.config/swww/wall.set")")"
wallPathArray=("${HOME}/Imágenes/wallpaperCicle")
get_hashmap wallPathArray
wallListBase=()

for wall in "${wallList[@]}"; do
    wallListBase+=("${wall##*/}")
done

rofiSel=$(paste <(printf "%s\n" "${wallListBase[@]}") <(printf "|%s\n" "${wallHash[@]}") |
    awk -F '|' -v thmbDir="${thmbDir}" '{split($1, arr, "/"); print arr[length(arr)] "\x00icon\x1f" thmbDir "/" $2 ".sqre"}' |
    rofi -dmenu -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -select "${currentWall}" | xargs)

#// apply wallpaper

if [ -n "${rofiSel}" ]; then
    for i in "${!wallPathArray[@]}"; do
        setWall=$(find "${wallPathArray[i]}" -type f -name "${rofiSel}")
        [ -z "${setWall}" ] || break
    done
    if [ -n "${setWall}" ]; then
        "${scrDir}/swwwallpaper.sh" -s "${setWall}"
        notify-send -a "HyDE Alert" -i "${thmbDir}/$(set_hash "${setWall}").sqre" " ${rofiSel}"
    else
        notify-send -a "HyDE Alert" "Wallpaper not found"
    fi
fi
