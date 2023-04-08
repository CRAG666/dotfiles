#!/bin/sh
theme="style_2"
dir="$HOME/.config/rofi/text"

BOOKMARKS="$HOME/.config/rofi/text/bookmarks"
BROWSER="firefox"

function rofi_main_window() {
	rofi -dmenu -i -l 10 -p $1 -theme $dir/"$theme"
}

function rofi_sub_window() {
	rofi -dmenu -i -no-fixed-num-lines -p "$1" \
		-theme $dir/styles/confirm.rasi $2 $3
}

function get_bookmarks() {
	cat $BOOKMARKS | cut -d '|' -f $1
}

function get_categories() {
	cat $BOOKMARKS | cut -d ':' -f 1 | grep -wo '[[:alnum:]]\+' | sort | uniq -cd
}

function write_bookmark() {
	uri=$(wl-paste)
	url_regex="(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]"
	tag=$(rofi_sub_window "url(${uri:0:40}...) tag: ")
	if [[ $tag != "" && $uri =~ $url_regex ]]; then
		if grep -Fq "$uri" $BOOKMARKS || grep -Fq "$tag" $BOOKMARKS; then
			rofi_sub_window "url or tag already exists" -width 20
		else
			echo "$tag|$uri" >>$BOOKMARKS
		fi
	fi
}

function delete_bookmark() {
	num_line=$(grep -n "$1" $BOOKMARKS | cut -d : -f 1)
	del_line="${num_line}d"
	option=$(rofi_sub_window "Delete ${1:0:30}: " -width 27)
	if [[ option == "y" ]]; then
		sed -i $del_line $BOOKMARKS
	fi
}

# Main menu
name=$(get_bookmarks 1 | rofi_main_window "Bookmarks")
if [[ "$name" == "+" ]]; then
	write_bookmark
elif [[ $name == "-" ]]; then
	url=$(get_bookmarks 2 | rofi_main_window "Bookmarks")
	[[ -n $url ]] || exit
	delete_bookmark $url
elif [[ $name == "*" ]]; then
	category=$(get_categories | rofi_main_window "Bookmarks" | awk '{print $2}')
	[[ -n $category ]] || exit
	grep "$category" $BOOKMARKS | cut -d '|' -f 2 | xargs $BROWSER
else
	[[ -n $name ]] || exit
	url=$(grep "$name" $BOOKMARKS | cut -d '|' -f 2)
	$BROWSER $url
fi
