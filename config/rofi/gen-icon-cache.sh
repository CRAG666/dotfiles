#!/usr/bin/env bash
# Pre-render .desktop app icons into a flat PNG theme ("rofi-fast"): PNGs decode
# ~20x faster than gdk-pixbuf's sandboxed glycin SVG loader. Misses fall back to
# inherited themes. Cheap to call often: exits unless a .desktop dir changed.

set -u

THEME_DIR="${HOME}/.local/share/icons/rofi-fast"
STAMP="${THEME_DIR}/.stamp"
SIZE=96   # > element-icon 72px, so it only ever scales DOWN (crisp)

# staleness check: any .desktop dir newer than the stamp?
fresh=1
for d in /usr/share/applications "${HOME}/.local/share/applications"; do
    [ -d "$d" ] && [ "$d" -nt "$STAMP" ] && fresh=0
done

# ...or Macjaro theme changed. Content-hash (path+size+mtime), not -newer:
# cp -a/rsync -a preserve old timestamps so mtime checks miss updates.
MACJARO="${HOME}/.icons/Macjaro"
MACJARO_SUM="${THEME_DIR}/.macjaro.sum"
theme_changed=0
if [ -d "$MACJARO" ]; then
    sum=$(find "$MACJARO" -path '*/.git' -prune -o -name icon-theme.cache \
        -o -type f -printf '%p %s %T@\n' 2>/dev/null | md5sum)
    if [ "$sum" != "$(cat "$MACJARO_SUM" 2>/dev/null)" ]; then
        fresh=0
        theme_changed=1
    fi
fi

[ "${1:-}" = "-f" ] && { fresh=0; theme_changed=1; }
[ "$fresh" = 1 ] && exit 0

if [ "$theme_changed" = 1 ]; then
    # refresh Macjaro's mmap cache so GTK lookups don't fall back to readdir
    gtk-update-icon-cache -f "$MACJARO" >/dev/null 2>&1
    echo "$sum" > "$MACJARO_SUM"
fi

mkdir -p "${THEME_DIR}/${SIZE}x${SIZE}/apps"

# resolve icon names the same way rofi/GTK would (Adwaita + hicolor + pixmaps)
# and emit "name<TAB>resolved_path" lines
resolve_icons() {
    grep -h '^Icon=' /usr/share/applications/*.desktop \
        "${HOME}/.local/share/applications/"*.desktop 2>/dev/null |
        sort -u | sed 's/^Icon=//' |
        python3 -c '
import sys
import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk
theme = Gtk.IconTheme.new()
theme.set_theme_name("Macjaro")
for line in sys.stdin:
    name = line.strip()
    if not name:
        continue
    if name.startswith("/"):
        stem = name.rsplit("/", 1)[-1].rsplit(".", 1)[0]
        print(stem + "\t" + name)
        continue
    info = theme.lookup_icon(name, None, 96, 1, Gtk.TextDirection.NONE, 0)
    f = info.get_file() if info else None
    path = f.get_path() if f else None
    if path:
        print(name + "\t" + path)
'
}

count=0
while IFS=$'\t' read -r name path; do
    [ -n "$name" ] && [ -f "$path" ] || continue
    out="${THEME_DIR}/${SIZE}x${SIZE}/apps/${name}.png"
    # skip if up to date — unless theme changed (preserved timestamps fool -nt)
    [ "$theme_changed" = 0 ] && [ -f "$out" ] && [ "$out" -nt "$path" ] && continue
    case "$path" in
        *.svg) rsvg-convert -w "$SIZE" -h "$SIZE" --keep-aspect-ratio "$path" -o "$out" 2>/dev/null ;;
        *.png) cp -f "$path" "$out" ;;
        *)     magick "$path" -resize "${SIZE}x${SIZE}" "$out" 2>/dev/null ;;
    esac && count=$((count + 1))
done < <(resolve_icons)

cat > "${THEME_DIR}/index.theme" <<EOF
[Icon Theme]
Name=rofi-fast
Comment=Pre-rendered PNG app icons for fast rofi startup
Inherits=Macjaro,Adwaita,hicolor
Directories=${SIZE}x${SIZE}/apps

[${SIZE}x${SIZE}/apps]
Size=${SIZE}
Type=Scalable
MinSize=8
MaxSize=512
Context=Applications
EOF

touch "$STAMP"
echo "rofi-fast: ${count} icono(s) (re)generado(s)" >&2
