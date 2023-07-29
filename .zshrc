# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

#
# fzf-tab preview
#

zstyle ':fzf-tab:complete:*:*' fzf-preview '~/.scripts/preview $realpath'

# PROMPT='%(?.%F{#fb5c8e}ﰉ %F{#f47d49}ﰉ %F{#a29dff}ﰉ.%F{#a29dff}ﰉ %F{#f47d49}ﰉ %F{#fb5c8e}ﰉ)%f '
# PS1='
# %(!.%B%F{red}%n%f%b in .${SSH_TTY:+"%B%F{yellow}%n%f%b in "})${SSH_TTY:+"%B%F{green}%m%f%b in "}%B%F{cyan}%~%f%b${(e)git_info[prompt]}${VIRTUAL_ENV:+" via %B%F{yellow}${VIRTUAL_ENV:t}%b%f"}${duration_info}
# %B%(1j.%F{blue}*%f .)%(?.%F{#f38ba8}ﰉ %F{#f9e2af}ﰉ %F{#a6e3a1}ﰉ.%F{#a6e3a1}ﰉ %F{#f9e2af}ﰉ %F{#f38ba8}ﰉ)%f%b '

# -< Evals >-
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# -< Aliases >-
# HACK: Command alternatives
# alias cd="z"
# alias vpn="~/.scripts/vpn"
alias ping="prettyping"
alias icat="kitty +kitten icat"
alias js="/usr/bin/node ~/.noderc"
alias ls="logo-ls"
alias la="logo-ls -la"
# alias grep='grep --color=auto'
# alias cp="rsync -Pvz"
alias curl="xh --curl"
alias cp='rsync --progress -avz'
alias tree="ls -R"
alias vi="nvim"
alias vim="nvim"
alias zt="/bin/zathura"
alias lo="/bin/libreoffice"
alias music="termusic"
alias rm='rm -i'
alias du1='du -h -d 1'
alias rec="wl-screenrec --dri-device $MOZ_DRM_DEVICE -f $(date +'%s_grab.mp4')"
alias neofetch='neofetch --ascii --source ~/.config/neofetch/thinkpad.txt --ascii_colors '7' '1''
alias freq="watch -n1 'grep Hz /proc/cpuinfo'"
alias bt="rfkill unblock bluetooth && sc-start bluetooth.service"
# alias aid="swaymsg -t get_tree | grep "app_id""
alias help="cht.sh"
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"
# HACK: docker Nftables
# alias don='sudo nft -f /etc/nftables-docker.conf && sudo systemctl start docker'
# alias doff='sudo systemctl stop docker.service docker.socket && sudo nft -f /etc/nftables.conf && sudo ip l d docker0'
# alias dor='doff && don'
# HACK: Config alias
alias grubc="sudoedit /etc/default/grub"
alias alacric="nvim ~/.config/alacritty/alacritty.yml"
alias swayc="nvim ~/.config/sway/config"
# alias newmc="nvim ~/.config/newm/config.py"
alias hyprc="nvim ~/.config/hypr/hyprland.conf"
alias keydc="nvim ~/Git/dotfiles/etc/keyd/default.conf"
alias zshc="nvim ~/.zshrc"
alias zshf="nvim ~/.zshfunc"
alias zimc="nvim ~/.zimrc"
alias tmuxc="nvim ~/.tmux.conf"
alias firefoxc="nvim ~/.mozilla/firefox/profiles.ini"
alias kittyc="nvim ~/.config/kitty/kitty.conf"
alias dnsc="nvim /etc/resolv.conf"
alias nftc="nvim /etc/nftables.conf"
alias starshipc="nvim ~/.config/starship.toml"
# HACK: Config Nvim Aliases
alias vimc='nvim ~/.config/nvim/init.lua'
alias vimp='nvim ~/.config/nvim/lua/plugins/init.lua'
alias vimk='nvim ~/.config/nvim/after/plugin/keymappings.lua'
alias vimd='nvim ~/.config/nvim/after/plugin/defaults.lua'
alias vima='nvim ~/.config/nvim/after/plugin/autocmds.lua'
alias viml='nvim ~/.config/nvim/lua/config/lsp/init.lua'
alias vo='nvim -c "Neorg workspace notes"'
# HACK: Jump alias
alias Applications="cd /usr/share/applications"
alias Desktop="cd /$HOME/Escritorio"
alias Download="cd /$HOME/Descargas"
alias Document="cd /$HOME/Documentos"
alias Images="cd /$HOME/Imágenes"
alias Music="cd /$HOME/Música"
alias Videos="cd /$HOME/Vídeos"
alias Git="cd /$HOME/Git"
alias Usb="cd /run/media/$USER"
# HACK: fzf alias
alias paci="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S"
alias pacr="pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns"
alias ys="yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S"
alias ci="{ find . -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n; } 2>/dev/null"
alias gbc="git switch -c"

# -< Environ variable >-
export MYSQL_PS1="\n \d  ﯐ "
export TERM="xterm-kitty"
export VISUAL=nvim
export EDITOR=$VISUAL
export PYTHONSTARTUP=~/.pyrc
export BAT_THEME="Catppuccin-mocha"
export USB="/run/media/$USER"
export PATH="$PATH:$HOME/.local/bin:$HOME/.dotnet/tools:$HOME/.local/share/bob/nvim-bin"
export FZF_DEFAULT_COMMAND='fd . --type f --hidden --follow --exclude .git --no-ignore'
export FZF_DEFAULT_OPTS=" --prompt='ﰉ ' --pointer='ﰊ' --height 40% --reverse --bind='?:toggle-preview' \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# source ~/.passmaria.zsh

# BEGIN_KITTY_SHELL_INTEGRATION
if test -e "/usr/lib/kitty/shell-integration/zsh/kitty.zsh"; then
  source "/usr/lib/kitty/shell-integration/zsh/kitty.zsh";
fi
source ~/.zshfunc
# END_KITTY_SHELL_INTEGRATION
