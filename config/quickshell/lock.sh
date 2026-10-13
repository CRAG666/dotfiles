#!/bin/sh
# Lock the session and return only once the compositor confirms it, so
# swayidle's before-sleep never suspends with the desktop still on screen.
# lock.qml touches $flag when secure and removes it on unlock.
config="$HOME/.config/quickshell/lock.qml"
flag="$XDG_RUNTIME_DIR/qs-lock.secure"

if ! pgrep -f "$config" > /dev/null; then
    rm -f "$flag"
    qs -n -d -p "$config"
fi

for _ in $(seq 50); do
    [ -e "$flag" ] && exit 0
    sleep 0.1
done
echo "lock.sh: compositor did not confirm the lock within 5s" >&2
exit 1
