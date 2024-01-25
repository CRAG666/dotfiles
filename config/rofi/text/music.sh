#!/bin/bash

# Carpeta donde se encuentran los archivos de música
music_folder=~/Música

# Crear lista de reproducción en formato m3u
find "$music_folder" -type f -exec file {} \; | grep -E 'Audio file' | cut -d: -f1 >"$music_folder/playlist.m3u"

# Obtener la selección del usuario usando Rofi
selected_file=$(rofi -dmenu -i -p "Selecciona una canción" <"$music_folder/playlist.m3u")

# Verificar si el usuario ha seleccionado un archivo
if [ -n "$selected_file" ]; then
    # Obtener información de la canción usando FFprobe
    artist=$(ffprobe -v error -select_streams a:0 -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$selected_file")
    title=$(ffprobe -v error -select_streams a:0 -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$selected_file")
    cover_image=$(ffprobe -v error -select_streams a:0 -show_entries format_tags=cover -of default=noprint_wrappers=1:nokey=1 "$selected_file")

    # Mostrar la información en Rofi
    rofi -show info -modi info -info "$title\n$artist" -theme-str 'window { width: 20%; }'

    # Reproducir la canción usando MPV
    mpv "$selected_file"
fi
