#!/bin/bash

theme="style_2"
dir="$HOME/.config/rofi/text"

shopt -s nullglob globstar

typeit=0
if [[ $1 == "--type" ]]; then
	typeit=1
	shift
fi

prefix="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
password_files=("$prefix"/**/*.gpg)
password_files=("${password_files[@]#"$prefix"/}")
password_files=("${password_files[@]%.gpg}")

password=$(printf '%s\n' "${password_files[@]}" | rofi -dmenu "$@" -matching fuzzy -l 10 -p "Contraseña" -theme "$dir/$theme")
[[ -n $password ]] || exit

if [[ $typeit -eq 0 ]]; then
	msg=$(pass show "$password" | head -n1 2>/dev/null)
	wl-copy "$msg"
	notify-send -i "passwordsafe" "Password copied for 30 seconds"
	sleep 30s
	cliphist delete-query "$msg"
	notify-send -i "passwordsafe" "Password deleted from clipboard history"
else
	passw=$(pass show "$password" | head -n1)
	xdotool type "$passw"
	notify-send "Autotipeo completado" -t 2000 -u normal
fi
