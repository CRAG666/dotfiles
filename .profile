set -a
. "$HOME/Git/dotfiles/config/shell/vars.env"
. "$HOME/Git/dotfiles/config/shell/colors.env"
set +a
# export PATH="$HOME/.local/bin:$HOME/.poetry/bin:$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
# export MESA_LOADER_DRIVER_OVERRIDE=iris
# export ANDROID_HOME=/opt/android-sdk
# export QT_QPA_PLATFORMTHEME=qt6ct
# export RIDER_JDK=/usr/share/rider/jbr

# lsp-mode: usar plists en vez de hash-tables → deserialización JSON más rápida.
# Tras cambiar este flag hay que reinstalar lsp-mode: cd ~/.config/emacs && bin/doom sync.

# WebKitGTK + Wayland workaround — bug #280210 (Error 71 dispatching)
# Afecta a luakit, nyxt, vimb, chawan, surf, epiphany, etc.
# Quitar cuando WebKitGTK arregle el bug del DMA-BUF renderer.

# LS_COLORS, BAT_THEME, FZF y Gum (vars temáticas) → fuente única:
# config/shell/colors.env, sourced arriba. (eza/exa usa su propio eyes.yml.)
