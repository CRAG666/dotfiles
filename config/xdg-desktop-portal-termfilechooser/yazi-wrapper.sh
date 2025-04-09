#!/bin/sh
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# For more information about input/output arguments read `xdg-desktop-portal-termfilechooser(5)`

set -ex
PATH="/usr/bin:/bin"

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

cmd="yazi"
termcmd="${TERMCMD:-kitty --title 'termfilechooser'}"

if [ "$save" = "1" ]; then
    # save a file
    set -- --chooser-file="$out" "$path"
elif [ "$directory" = "1" ]; then
    # upload files from a directory
    set -- --chooser-file="$out" --cwd-file="$out" "$path"
elif [ "$multiple" = "1" ]; then
    # upload multiple files
    set -- --chooser-file="$out" "$path"
else
    # upload only 1 file
    set -- --chooser-file="$out" "$path"
fi

command="$termcmd $cmd"
for arg in "$@"; do
    # escape double quotes
    escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
    # escape spaces
    command="$command \"$escaped\""
done

sh -c "$command"
