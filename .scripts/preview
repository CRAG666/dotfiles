#!/usr/bin/env sh

X="90"
Y="4"
WIDTH="$FZF_PREVIEW_COLUMNS"
HEIGHT="$FZF_PREVIEW_LINES"
TMP="/tmp/fzf-preview"
CACHEFILE="$TMP/$(echo "$1" | base64).png"

maketemp() {
	[ ! -d "$TMP" ] && mkdir -p "$TMP"
}

previewclear() {
	kitty +kitten icat --transfer-mode=file --silent --clear
}

text() {
	bat --pager=never --wrap never --style="changes" --color="always" "$1" -p
}

archive() {
	atool -l -q "$1" | tail -n +2 | awk -F'   ' '{print $NF}'
}

draw() {
	kitty +kitten icat --transfer-mode=file --silent --align=left --place="${WIDTH}x$HEIGHT@${X}x$Y" --z-index=-1 "$1"
}

image() {
	draw "$1"
}

# https://ffmpeg.org/ffmpeg-filters.html#showspectrum-1
audio() {
	[ ! -f "$CACHEFILE" ] && ffmpeg -loglevel 0 -y -i "$1" -lavfi "showspectrumpic=s=hd480:legend=0:gain=5:color=intensity" "$CACHEFILE"
	draw "$CACHEFILE"
}

video() {
	[ ! -f "$CACHEFILE" ] && ffmpegthumbnailer -i "$1" -o "$CACHEFILE" -s 1024 -q 10
	draw "$CACHEFILE"
}

pdf() {
	[ ! -f "$CACHEFILE.png" ] && pdftoppm -png -singlefile "$1" "$CACHEFILE" -scale-to 1024
	draw "$CACHEFILE.png"
}

epub() {
	[ ! -f "$CACHEFILE" ] && epub-thumbnailer "$1" "$CACHEFILE" 1024
	draw "$CACHEFILE"
}

main() {
	previewclear
	maketemp
	mimetype=$(file -b --mime-type "$1")

	case $mimetype in
	application/epub*)
		epub "$1"
		;;
	application/pdf)
		pdf "$1"
		;;
	application/zip | application/x-tar | *rar | application/gzip)
		archive "$1"
		;;
	audio/*)
		audio "$1"
		;;
	image/*)
		image "$1"
		;;
	text/*)
		text "$1"
		;;
	video/*)
		video "$1"
		;;
	inode/directory)
		[ "${1##*/..*}" = "" ] && echo || tree "$1"
		;;
	*)
		text "$1"
		;;
	esac
}

main "$1"
