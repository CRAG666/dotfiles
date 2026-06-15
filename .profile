set -a
. "$HOME/Git/dotfiles/config/shell/vars.env"
. "$HOME/Git/dotfiles/config/shell/colors.env"
set +a
# export PATH="$HOME/.local/bin:$HOME/.poetry/bin:$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
# export MESA_LOADER_DRIVER_OVERRIDE=iris
# export ANDROID_HOME=/opt/android-sdk
# export QT_QPA_PLATFORMTHEME=qt6ct
# export RIDER_JDK=/usr/share/rider/jbr

# lsp-mode plists (JSON más rápido); tras cambiar, reinstalar: cd ~/.config/emacs && bin/doom sync.

# WebKitGTK+Wayland workaround — bug #280210 (Error 71); quitar cuando se arregle el DMA-BUF renderer.

# Vars temáticas (LS_COLORS, BAT_THEME, FZF, Gum) → fuente única: config/shell/colors.env (sourced arriba).
