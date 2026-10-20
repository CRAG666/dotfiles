#!/bin/sh
# Lock the session and return only once the compositor confirms it, so
# swayidle's before-sleep never suspends with the desktop still on screen.
# lock.qml stays resident: the first lock starts it and locks it over IPC, the
# next ones write to its fifo (a no-op while locked). It touches $flag when
# secure and removes it on unlock.
config="$HOME/.config/quickshell/lock.qml"
fifo="$XDG_RUNTIME_DIR/qs-lock.fifo"
flag="$XDG_RUNTIME_DIR/qs-lock.secure"

# only shell builtins: the pid must still be the lock's quickshell, which keeps
# the fifo open, so the write cannot block
if read -r pid 2> /dev/null < "$fifo.pid" && read -r name 2> /dev/null < "/proc/$pid/comm" && [ "$name" = quickshell ] && [ -p "$fifo" ]; then
    printf 'lock\n' > "$fifo"
else
    rm -f "$flag"
    # quickshell, not qs, which ananicy renices to 10 (see spotlight/spotlight.sh)
    quickshell -n -d -p "$config"
    for _ in $(seq 250); do
        quickshell ipc -p "$config" call lock lock > /dev/null 2>&1 && break
        sleep 0.02
    done
fi

for _ in $(seq 250); do
    [ -e "$flag" ] && exit 0
    sleep 0.02
done
echo "lock.sh: compositor did not confirm the lock within 5s" >&2
exit 1
