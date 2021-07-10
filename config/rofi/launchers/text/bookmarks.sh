theme="style_2"
dir="$HOME/.config/rofi/launchers/text"

BOOKMARKS="$HOME/.config/rofi/launchers/text/bookmarks"
BROWSER="luakit"


function get_bookmarks(){
    cat $BOOKMARKS | cut -d '|' -f $1 | rofi -dmenu -l 10 -p Bookmarks \
        -theme $dir/"$theme"
}

function rofi_sub_window(){
    rofi -dmenu\
    -i\
    -no-fixed-num-lines\
    -p "$1" \
    -theme $dir/confirm.rasi $2 $3
}

function write_bookmark(){
    uri=`wl-paste`
    url_regex="(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]"
    tag=$(rofi_sub_window "url(${uri:0:40}...) tag: ")
    if [[ $tag != "" && $uri =~ $url_regex ]]; then
        if grep -Fq "$uri" $BOOKMARKS || grep -Fq "$tag" $BOOKMARKS; then
            rofi_sub_window "url or tag already exists" -width 20
        else
            echo "$tag|$uri" >> $BOOKMARKS
        fi
    fi
}

function delete_bookmark(){
    num_line=`grep -n "$1" bookmarks | cut -d : -f 1`
    del_line="${num_line}d"
    sed -i $del_line $BOOKMARKS
}


name=$(get_bookmarks 1)
if [[ "$name" == "+" ]]; then
    write_bookmark
elif [[ $name == '-' ]]; then
    url=$(get_bookmarks 2)
    delete_bookmark url
else
    if [[ -n $name ]]; then
        url=$(grep "$name" $BOOKMARKS | cut -d '|' -f 2)
        $BROWSER $url
    fi
fi
