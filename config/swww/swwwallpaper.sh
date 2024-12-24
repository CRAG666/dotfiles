#!/usr/bin/env sh

## define functions

Wall_Prev() {
    for ((i = 0; i < ${#Wallist[@]}; i++)); do
        if [ "${Wallist[i]}" = "${getWall2}" ]; then
            prevIndex=$(( (i - 1 + ${#Wallist[@]}) % ${#Wallist[@]} ))
            ws="${Wallist[prevIndex]/$HOME/~}"
            sed -i "s+${getWall1}+${ws}+" "$BaseDir/wall.ctl"
            ln -fs "${Wallist[prevIndex]}" "$BaseDir/wall.set"
            break
        fi
    done
}

Wall_Next() {
    for ((i = 0; i < ${#Wallist[@]}; i++)); do
        if [ "${Wallist[i]}" = "${getWall2}" ]; then
            nextIndex=$(( (i + 1) % ${#Wallist[@]} ))
            ws="${Wallist[nextIndex]/$HOME/~}"
            sed -i "s+${getWall1}+${ws}+" "$BaseDir/wall.ctl"
            ln -fs "${Wallist[nextIndex]}" "$BaseDir/wall.set"
            break
        fi
    done
}

Wall_Set() {
    local wallPath="$1"

    if [ -z "$wallPath" ]; then
        wallPath="$BaseDir/wall.set"
    fi

    if [ ! -f "$wallPath" ]; then
        echo "ERROR: Wallpaper file not found: $wallPath"
        exit 1
    fi

    : "${xtrans:=grow}"  # Valor predeterminado si xtrans está vacío
    : "${xpos:=center}"  # Valor predeterminado si xpos está vacío

    swww img "$wallPath" \
        --transition-bezier .43,1.19,1,.4 \
        --transition-type "$xtrans" \
        --transition-duration 1 \
        --transition-fps 60 \
        --transition-pos "$xpos"
}

## set variables

BaseDir="$(dirname "$(realpath "$0")")"

if [ "$(grep '^1|' "$BaseDir/wall.ctl" | wc -l)" -ne 1 ]; then
    echo "ERROR: Unable to fetch theme from $BaseDir/wall.ctl"
    exit 1
fi

getWall1="$(grep '^1|' "$BaseDir/wall.ctl" | cut -d '|' -f 3)"
getWall2="$(eval echo "$getWall1")"

if [ ! -f "$getWall2" ]; then
    echo "ERROR: Wallpaper not found at $getWall2"
    exit 1
fi

if [ ! -f "$BaseDir/wall.set" ]; then
    echo "ERROR: Wallpaper link is broken"
    exit 1
fi

Wallist=($(find "$(dirname "$getWall2")" -type f -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.svg"))


## evaluate options

while getopts "nps:" option; do
    case $option in
    n) # set the next wallpaper
        xtrans="grow"
        Wall_Next
        ;;
    p) # set the previous wallpaper
        xtrans="outer"
        Wall_Prev
        ;;
    s) # set a specific wallpaper
        specificWall="$OPTARG"
        ln -fs "$specificWall" "$BaseDir/wall.set"
        sed -i "s+${getWall1}+${specificWall/$HOME/~}+" "$BaseDir/wall.ctl"
        Wall_Set "$specificWall"
        ;;
    *) # invalid option
        echo "Usage: $0 [-n (next)] [-p (previous)] [-s <wallpaper_path>]"
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))
case $1 in
    1) xpos="top-left" ;;
    2) xpos="top-right" ;;
    3) xpos="bottom-right" ;;
    4) xpos="bottom-left" ;;
esac

## check swww daemon

if ! swww query > /dev/null 2>&1; then
    swww init
fi

## set wallpaper

Wall_Set
if command -v magick > /dev/null 2>&1; then
    magick "$BaseDir/wall.set" -strip -scale 10% -blur 0x3 -resize 100% "$BaseDir/wall.blur"
    magick "$BaseDir/wall.set" -resize 12% "${HOME}/.cache/wallpapers/thumbnails/wall.sqre"
else
    echo "WARNING: ImageMagick not found. Skipping blur creation."
fi
