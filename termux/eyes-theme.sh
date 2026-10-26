# shellcheck shell=sh
# Sourced by every Termux login shell: picks the eyes variant by the hour, as `eyes-theme auto` does
hour=$(date +%-H)
if [ "$hour" -ge 6 ] && [ "$hour" -lt 19 ]; then
    colors=colors.eyes.properties
else
    colors=colors.eyes-dark.properties
fi
if [ "$(readlink ~/.termux/colors.properties)" != "$colors" ]; then
    ln -sfn "$colors" ~/.termux/colors.properties
    termux-reload-settings
fi
unset hour colors
