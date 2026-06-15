# Shared aliases — single source of truth para zsh + nushell (.zshrc convierte 'alias x = y' -> 'x=y').
# Una línea `alias NOMBRE = VALOR`; SOLO alias idénticos en ambos shells.
alias ip = ip -color=auto
alias ping = prettyping
alias cp = cpx
alias tree = exa --icons --tree --level=4 --long --git
alias zt = /bin/zathura --fork
alias zb = zen-browser
alias lo = /bin/libreoffice
alias music = termusic
alias fm = yazi
alias update-grub = sudo grub-mkconfig -o /boot/grub/grub.cfg
alias neofetch = fastfetch -l ~/.config/fastfetch/thinkpad.txt --logo-color-1 white --logo-color-2 red --logo-color-3 '38;2;23;147;209'
alias gbc = git switch -c
alias grubc = sudo -e /etc/default/grub
alias kittyc = nvim ~/.config/kitty/kitty.conf
alias icat = kitten icat
alias s = kitten ssh
alias ssh = kitten ssh
