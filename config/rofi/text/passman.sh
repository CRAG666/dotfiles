#!/bin/bash

theme="style_2"
dir="$HOME/.config/rofi/text"

shopt -s nullglob globstar

# switch para autotipeo
typeit=0
if [[ $1 == "--type" ]]; then
	typeit=1
	shift
fi

# obtiene todos los archivos de contraseñas guardadas
prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=("$prefix"/**/*.gpg)
password_files=("${password_files[@]#"$prefix"/}")
password_files=("${password_files[@]%.gpg}")

# muestra una lista de todos los archivos de contraseñas y guarda el seleccionado en una variable
password=$(printf '%s\n' "${password_files[@]}" | rofi -dmenu "$@" -matching fuzzy -l 10 -p "Contraseña" -theme "$dir/$theme")
[[ -n $password ]] || exit

# pass -c copia la contraseña en el portapapeles. La salida adicional de pass se redirige a /dev/null
if [[ $typeit -eq 0 ]]; then
	# msg=$(PASSWORD_STORE_ENABLE_EXTENSIONS=true pass copyq "$password")
	msg=$(pass show "$password" | head -n1 2>/dev/null)
	wl-copy "$msg"
	notify-send -i "passwordsafe" "Password copied for 30 seconds"
	sleep 30s
	cliphist delete-query "$msg"
	notify-send -i "passwordsafe" "Password deleted from clipboard history"
else
	# Si se desea utilizar el autotipeo, guarda el nombre de usuario y la contraseña en variables
	# Los archivos de contraseñas son archivos de texto simples.
	# La contraseña debe estar en la primera línea,
	# porque si usas `pass -i`, la primera línea se reemplazará con una nueva contraseña

	passw=$(pass show "$password" | head -n1)
	# uname=$(pass show "$password" | tail -n1)
	# # xdotool escribe el nombre de usuario en el lugar activo (CLI o campo de entrada de un navegador)
	# xdotool type "$uname"
	# # escribe un TAB (para avanzar en los campos de entrada del navegador)
	# xdotool key Tab
	# escribe la contraseña en la entrada activa
	xdotool type "$passw"

	# Muestra una notificación con notify-send
	notify-send "Autotipeo completado" -t 2000 -u normal
fi
