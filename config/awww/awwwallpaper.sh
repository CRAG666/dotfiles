#!/usr/bin/env bash

## define functions

Wall_Cycle() { # $1 = 1 (next) | -1 (previous)
    local -a Wallist
    mapfile -d '' -t Wallist < <(find "$(dirname "$getWall2")" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.svg" \) -print0)
    local i n=${#Wallist[@]}
    for ((i = 0; i < n; i++)); do
        if [ "${Wallist[i]}" = "${getWall2}" ]; then
            local idx=$(( (i + $1 + n) % n ))
            ws="${Wallist[idx]/$HOME/~}"
            sed -i "s+${getWall1}+${ws}+" "$BaseDir/wall.ctl"
            ln -fs "${Wallist[idx]}" "$BaseDir/wall.set"
            break
        fi
    done
}

Wall_Set() {
    local wallPath="$BaseDir/wall.set"

    if [ ! -f "$wallPath" ]; then
        echo "ERROR: Wallpaper file not found: $wallPath"
        exit 1
    fi

    : "${xtrans:=grow}"  # Valor predeterminado si xtrans está vacío
    : "${xpos:=center}"  # Valor predeterminado si xpos está vacío

    awww img "$wallPath" \
        --transition-bezier .43,1.19,1,.4 \
        --transition-type "$xtrans" \
        --transition-duration 1 \
        --transition-fps 60 \
        --transition-pos "$xpos"
}

# Derived artifacts: blur + rofi thumbnail + Quickshell per-widget light/dark.
# Everything comes out of ONE magick invocation (one image decode, jpeg
# shrink-on-load, then a 25% working copy), instead of five full 4K decodes.
Post_Process() {
    if ! command -v magick > /dev/null 2>&1; then
        echo "WARNING: ImageMagick not found. Skipping blur creation."
        return
    fi

    local src="$BaseDir/wall.set"
    mkdir -p "${HOME}/.cache/wallpapers/thumbnails"

    # Quickshell: per-widget eyes light/dark. We sample the wallpaper region
    # BEHIND each widget (per shell.qml geometry, in u = height/1440) and use
    # its mean perceptual luminance (Rec.709). Light theme only when the
    # background is clearly bright; otherwise dark (light text + halo stays
    # legible over busy/dark/colourful backgrounds). Regions, in stdout order:
    #   date block:   top centre, y 4..29% of height        -> North 40%x29%
    #   player block: bottom centre, y 78..90% (bottomMargin
    #                 150u keeps it off the edge — top 55%
    #                 of the bottom-22% band)                -> South+North crop
    #   system gauges: left edge, vertically centred        -> West 9%x50%
    local lums dl pl sl
    lums=$(magick -define jpeg:size=2048x2048 "${src}[0]" -strip -resize 25% \
        \( +clone -quality 90 -write "${HOME}/.cache/wallpapers/thumbnails/wall.sqre" +delete \) \
        \( +clone -scale 40% -blur 0x3 -write "$BaseDir/wall.blur" +delete \) \
        \( +clone -gravity North -crop 40%x29%+0+0 +repage -resize 1x1 -format '%[fx:0.2126*r+0.7152*g+0.0722*b]\n' -write info: +delete \) \
        \( +clone -gravity South -crop 50%x22%+0+0 +repage -gravity North -crop 100%x55%+0+0 +repage -resize 1x1 -format '%[fx:0.2126*r+0.7152*g+0.0722*b]\n' -write info: +delete \) \
        -gravity West -crop 9%x50%+0+0 +repage -resize 1x1 -format '%[fx:0.2126*r+0.7152*g+0.0722*b]' info: 2>/dev/null)
    { read -r dl; read -r pl; read -r sl; } <<< "$lums"

    local qs_state="${HOME}/.config/quickshell/theme.state"
    mkdir -p "$(dirname "$qs_state")"
    awk -v d="$dl" -v p="$pl" -v s="$sl" 'BEGIN{
        printf "date=%s\n",   (d != "" && d+0 > 0.6) ? "light" : "dark"
        printf "player=%s\n", (p != "" && p+0 > 0.6) ? "light" : "dark"
        printf "system=%s\n", (s != "" && s+0 > 0.6) ? "light" : "dark"
    }' > "$qs_state"
}

## set variables

BaseDir="$(dirname "$(realpath "$0")")"

# Bootstrap on first run. wall.ctl / wall.set are per-machine state (gitignored),
# so on a fresh clone they don't exist. Seed them from the first wallpaper found
# so the rest of the script (and -n / -p / -s) has a valid current entry; an
# explicit `-s <path>` later just overwrites this seed with the chosen image.
WallDir="${HOME}/Pictures/wallpaperCicle"
if [ ! -s "$BaseDir/wall.ctl" ]; then
    # No control file: seed both from the first wallpaper available.
    seed="$(find "$WallDir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' \
        -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' \
        -o -iname '*.tiff' -o -iname '*.svg' \) | sort | head -n1)"
    if [ -z "$seed" ]; then
        echo "ERROR: No wallpapers in $WallDir to bootstrap wall.ctl/wall.set" >&2
        exit 1
    fi
    printf '1|Catppuccin-Mocha|%s\n' "${seed/#$HOME/~}" > "$BaseDir/wall.ctl"
    ln -fs "$seed" "$BaseDir/wall.set"
elif [ ! -L "$BaseDir/wall.set" ]; then
    # Control file is fine but the symlink is missing/broken: rebuild it from
    # wall.ctl so we keep the current selection instead of resetting it.
    cur="$(eval echo "$(awk -F'|' '$1 == "1" { print $3; exit }' "$BaseDir/wall.ctl")")"
    [ -f "$cur" ] && ln -fs "$cur" "$BaseDir/wall.set"
fi

getWall1="$(awk -F'|' '$1 == "1" { print $3; exit }' "$BaseDir/wall.ctl")"

if [ -z "$getWall1" ]; then
    echo "ERROR: Unable to fetch theme from $BaseDir/wall.ctl"
    exit 1
fi

getWall2="$(eval echo "$getWall1")"

if [ ! -f "$getWall2" ]; then
    echo "ERROR: Wallpaper not found at $getWall2"
    exit 1
fi

if [ ! -f "$BaseDir/wall.set" ]; then
    echo "ERROR: Wallpaper link is broken"
    exit 1
fi

## evaluate options

while getopts "nps:" option; do
    case $option in
    n) # set the next wallpaper
        xtrans="grow"
        Wall_Cycle 1
        ;;
    p) # set the previous wallpaper
        xtrans="outer"
        Wall_Cycle -1
        ;;
    s) # set a specific wallpaper (applied by the shared Wall_Set below)
        specificWall="$OPTARG"
        ln -fs "$specificWall" "$BaseDir/wall.set"
        sed -i "s+${getWall1}+${specificWall/$HOME/~}+" "$BaseDir/wall.ctl"
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

## check awww daemon

if ! awww query > /dev/null 2>&1; then
    awww-daemon
fi

## set wallpaper

Wall_Set

# run the derived artifacts in the background so the script returns as soon as
# the transition starts; if a previous run is still processing, replace it
# (newest wallpaper wins)
ppPid="${XDG_RUNTIME_DIR:-/tmp}/awww-postprocess.pid"
[ -f "$ppPid" ] && kill "$(cat "$ppPid" 2>/dev/null)" 2>/dev/null
Post_Process &
echo $! > "$ppPid"
