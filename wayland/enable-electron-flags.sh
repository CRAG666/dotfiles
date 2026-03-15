#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAGS="$SCRIPT_DIR/electron-flags.conf"

for app in electron chromium chrome; do
    ln -vsf "$FLAGS" ~/.config/${app}-flags.conf
done
