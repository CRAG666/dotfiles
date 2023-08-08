#!/bin/bash

# Leer el valor actual de ac del archivo
theme="$HOME/.config/rofi/text/styles/catppuccin.rasi"
current_ac_value=$(grep 'ac:[[:space:]]*#' "$theme" | awk -F'#' '{print $2}' | tr -d ';')

# Extraer los colores y sus valores del archivo y guardarlos en un array asociativo
declare -A colors_array
while read -r line; do
	if echo "$line" | grep -qE '^(red|green|yellow|blue|purple|cyan):[[:space:]]*#[0-9a-fA-F]{8};$'; then
		key="${line%%:*}"
		value=$(echo "$line" | awk -F'#' '{print $2}' | tr -d ';')
		if [ "$value" != "$current_ac_value" ]; then
			colors_array["$key"]="$value"
		fi
	fi
done <"$theme"

# Función para obtener un índice aleatorio dentro del rango de colores, excluyendo el color actual
get_random_index() {
	local array_length=${#colors_array[@]}
	if [ "$array_length" -eq 0 ]; then
		echo "No se encontraron colores válidos en el archivo."
		exit 1
	fi
	echo $((RANDOM % array_length))
}

# Obtener un índice aleatorio excluyendo el índice del color actual
random_index=$(get_random_index)

# Extraer el color aleatorio y su valor
color_names=("${!colors_array[@]}")
if [ "${color_names[$random_index]}" = "" ]; then
	echo "Error: No se pudo obtener un color aleatorio."
	exit 1
fi
color_name="${color_names[$random_index]}"
color_value="${colors_array[$color_name]}"

# Reemplazar el valor actual de ac con el nuevo valor en el archivo
sed -i "s/ac:[[:space:]]*#${current_ac_value};/ac: #$color_value;/" "$theme"

echo "Se ha cambiado el valor de ac a $color_name (#$color_value)"
