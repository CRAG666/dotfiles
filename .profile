set -a
DOT_DIR=$(dirname "$(readlink -f "$HOME/.profile")")
. "$DOT_DIR/config/shell/vars.env"
. "$DOT_DIR/config/shell/colors.env"
set +a
# export PATH="$HOME/.local/bin:$HOME/.poetry/bin:$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
# export MESA_LOADER_DRIVER_OVERRIDE=iris
# export ANDROID_HOME=/opt/android-sdk
# export QT_QPA_PLATFORMTHEME=qt6ct
# export RIDER_JDK=/usr/share/rider/jbr

# lsp-mode plists (faster JSON); after changing, reinstall: cd ~/.config/emacs && bin/doom sync.

# WebKitGTK+Wayland workaround — bug #280210 (Error 71); remove once the DMA-BUF renderer is fixed.

# Themed vars (LS_COLORS, BAT_THEME, FZF, Gum) → single source: config/shell/colors.env (sourced above).
