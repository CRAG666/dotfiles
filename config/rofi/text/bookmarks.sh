#!/bin/sh

theme="style_2"
dir="$HOME/.config/rofi/text"

BOOKMARKS="$HOME/.config/rofi/text/bookmarks"
BROWSER="xdg-open"

function rofi_main_window() {
    rofi -dmenu -i -l 10 -p "$1" -theme "$dir/$theme"
}

function rofi_sub_window() {
    rofi -dmenu -i -no-fixed-num-lines -p "$1" -theme "$dir"/confirm.rasi "$2" "$3"
}

function get_bookmarks() {
    [[ -f "$BOOKMARKS" ]] || { echo "Nothing to show." >&2; return; }
    cut -d '|' -f "$1" "$BOOKMARKS"
}

function get_categories() {
    [[ -f "$BOOKMARKS" ]] || { echo "Noting to show." >&2; return; }
    cut -d ':' -f 1 "$BOOKMARKS" | grep -wo '[[:alnum:]]\+' | uniq -c | sort -r
}

function write_bookmark() {
    uri=$(wl-paste)
    url_regex="^(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]$"

    if [[ -z "$uri" ]]; then
        rofi_sub_window "Error: Clipboard is empty" -width 20
        return
    fi

    if [[ ! $uri =~ $url_regex ]]; then
        rofi_sub_window "Error: URL not valid in the clipboard" -width 20
        return
    fi

    tag=$(rofi_sub_window "url(${uri:0:40}...) tag: ")
    if [[ -z "$tag" ]]; then
        return
    fi

    if grep -Fq "$uri" "$BOOKMARKS" || grep -Fq "$tag" "$BOOKMARKS"; then
        rofi_sub_window "This URL exits" -width 20
    else
        printf '%s|%s\n' "$tag" "$uri" >>"$BOOKMARKS"
        sort -u "$BOOKMARKS" -o "$BOOKMARKS"
        rofi_sub_window "Bookmark added" -width 20
    fi
}

function delete_bookmark() {
    selected=$(awk -F '|' '{print $1 "  " $2}' "$BOOKMARKS" | rofi_main_window "Selecciona un bookmark para eliminar")

    if [[ -z "$selected" ]]; then
        return
    fi

    url=$(echo "$selected" | awk -F '  ' '{print $2}')

    if [[ -z "$url" ]]; then
        rofi_sub_window "Error: Bookmark not found" -width 20
        return
    fi

    num_line=$(grep -nF "$url" "$BOOKMARKS" | cut -d : -f 1)
    del_line="${num_line}d"

    option=$(rofi_sub_window "Delete this URL ${url:0:50}? (y/n): " -width 27)
    if [[ $option == "y" ]]; then
        sed -i "$del_line" "$BOOKMARKS"
    fi
}

function open_random_sites() {
    local count=${1:-8}
    for ((i = 1; i <= count; i++)); do
        $BROWSER "https://wiby.me/surprise/" &
        $BROWSER "https://searchmysite.net/search/random" &
    done
}

# Menú principal
name=$(get_bookmarks 1 | rofi_main_window "Bookmarks")

if [[ "$name" == "+" ]]; then
    write_bookmark
elif [[ $name == "-" ]]; then
    delete_bookmark
elif [[ $name == "*" ]]; then
    category=$(get_categories | rofi_main_window "Bookmarks" | awk '{print $2}')
    [[ -n $category ]] || exit
    grep "$category" "$BOOKMARKS" | cut -d '|' -f 2 | xargs -I {} $BROWSER "{}"
elif [[ $name == ";"* ]]; then
    number=$(echo "$name" | cut -d';' -f2 | xargs)
    if [[ $number =~ ^[0-9]+$ ]]; then
        open_random_sites "$number"
    else
        open_random_sites
    fi
else
    [[ -n $name ]] || exit
    url=$(grep -F "$name" "$BOOKMARKS" | cut -d '|' -f 2)
    $BROWSER "$url"
fi
