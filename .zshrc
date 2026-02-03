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
# fzf-tab preview
#

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
	'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
	'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
	'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	'case "$group" in
	"commit tag") git show --color=always $word ;;
	*) git show --color=always $word | delta ;;
	esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
	'case "$group" in
	"modified file") git diff $word | delta ;;
	"recent commit object name") git show --color=always $word | delta ;;
	*) git log --color=always $word ;;
	esac'
zstyle ':fzf-tab:complete:*:options' fzf-preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview
zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
   '(out=$(cht.sh "$word") 2>/dev/null && echo $out) || (out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out) || (out=$(which "$word") && echo $out) || echo "${(P)word}"'
zstyle ':fzf-tab:complete:*:*' fzf-preview '~/.scripts/preview $realpath'

# export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
# zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
# source <(carapace _carapace)

enable-fzf-tab

# -< Evals >-
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(starship init zsh)"

# -< Aliases >-
# HACK: Command alternatives
# alias vpn="~/.scripts/vpn"
alias ip='ip -color=auto'
alias ping="prettyping"
alias js="/usr/bin/node ~/.noderc"
alias ls="exa --icons"
alias la="exa --icons -la"
# alias grep='grep --color=auto'
alias cp='fcp'
cd() { pushd $1 && ls; }
alias tree="exa --icons --tree --level=4 --long --git"
alias zt="/bin/zathura --fork"
alias zb="zen-browser"
alias lo="/bin/libreoffice"
alias music="termusic"
alias rm='rm -i'
alias dus='du -h --max-depth=1 2>/dev/null | sort -hr'
alias du1='du -h -d 1 2>/dev/null | sort -hr'
alias rec="wl-screenrec --dri-device $MOZ_DRM_DEVICE -f $(date +'%s_grab.mp4')"
alias neofetch="fastfetch -l ~/.config/fastfetch/thinkpad.txt --logo-color-1 white --logo-color-2 red --logo-color-3 '38;2;23;147;209'"
alias freq="watch -n1 'grep Hz /proc/cpuinfo'"
alias fm="yazi"
alias help="cht.sh"
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias aicli='eval $(gum choose "gemini" "qwen" "crush")'
# HACK: docker Nftables
# alias don='sudo nft -f /etc/nftables-docker.conf && sudo systemctl start docker'
# alias doff='sudo systemctl stop docker.service docker.socket && sudo nft -f /etc/nftables.conf && sudo ip l d docker0'
# alias dor='doff && don'
# HACK: Config Nvim Aliases
alias vi="NVIM_APPNAME=nvim-minimal nvim"
alias vic='vi ~/.config/nvim-minimal/init.lua'
alias vim="NVIM_NF=true nvim"
alias vimc='vim ~/.config/nvim/init.lua'
alias vimk='vim ~/.config/nvim/lua/core/keymaps.lua'
alias vimd='vim ~/.config/nvim/lua/core/opts.lua'
alias vima='vim ~/.config/nvim/lua/core/autocmds.lua'
alias viml='vim ~/.config/nvim/lua/core/lsp.lua'
alias vl='vim -c "Neorg workspace life"'
alias va='vim -c "Neorg workspace academic"'
# HACK: Config alias
alias grubc="sudo -e /etc/default/grub"
alias newmc="vim ~/.config/newm/config.py"
alias hyprc="vim ~/.config/hypr/hyprland.conf"
alias owlc="vim ~/.config/owl/owl.conf"
alias keydc="vim ~/Git/dotfiles/etc/keyd/default.conf"
alias zshc="vim ~/.zshrc"
alias zshf="vim ~/.zshfunc"
alias zimc="vim ~/.zimrc"
alias dnsc="vim /etc/resolv.conf"
alias nftc="vim /etc/nftables.conf"
alias starshipc="vim ~/.config/starship.toml"
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
alias fontl="fc-list | cut -d ':' -f2 | sort | uniq"

# -< Environ variable >-
export MYSQL_PS1="\n \d  ﯐ "
export VISUAL=$HOME/.local/share/bob/nvim-bin/nvim
export EDITOR=$VISUAL
export PYTHONSTARTUP=~/.pyrc
export BAT_THEME="Catppuccin-mocha"
export USB="/run/media/$USER"
export PATH="$HOME/.local/bin:$HOME/.dotnet/tools:$HOME/.local/share/bob/nvim-bin:$HOME/.local/share/nvim/mason/bin:$HOME/.config/emacs/bin:$HOME/.npm-global/bin:$PATH"
export FZF_DEFAULT_COMMAND='fd . --type f --hidden --follow --exclude .git --no-ignore'
export FZF_DEFAULT_OPTS=" --prompt='ﰉ ' --pointer='ﰊ' --height 40% --reverse --bind='?:toggle-preview' \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Working with documents
alias pandock='podman run --rm -v "$(pwd):/data" pandoc/extra'
export MARPT=~/Documentos/Proyectos/Writings/utils/marp/themes
export IEEESTL=~/Documentos/Proyectos/Writings/utils/latex/ieee.csl
export LCOLORCATPPUCCIN=~/Documentos/Proyectos/Writings/utils/latex/catppuccin
export PASSWORD_STORE_ENABLE_EXTENSIONS=true
export NVIM_NF=true

# BEGIN_KITTY_SHELL_INTEGRATION
custom_autocomplete() {
    zle fzf-tab-complete
    printf "\x1b_Ga=d,d=A\x1b\\"
}

zle -N custom_autocomplete
bindkey '^I' custom_autocomplete
alias kittyc="nvim ~/.config/kitty/kitty.conf"
alias icat="kitten icat"
alias s="kitten ssh"
# END_KITTY_SHELL_INTEGRATION

source ~/.zshfunc
# FPATH="/usr/share/zsh/site-functions:${FPATH}"
source ~/.env
