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
# Cachea la salida de `init` en .zwc; se regenera solo si cambia el binario (evita 3 spawns).
_init_cache() {
  local out="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init/$1.zsh" bin="${commands[$1]}"
  if [[ -n $bin && ( ! -s $out || $bin -nt $out ) ]]; then
    mkdir -p "${out:h}" && "${@:2}" >| "$out" 2>/dev/null && zcompile "$out" 2>/dev/null
  fi
  [[ -s $out ]] && source "$out"
}
_init_cache zoxide zoxide init zsh
_init_cache atuin atuin init zsh
_init_cache starship starship init zsh

# -< Aliases >-
# Alias compartidos — fuente única: ~/.config/nushell/aliases.nu (convierte 'alias x = y' -> 'alias x=y').
if [[ -r ~/.config/nushell/aliases.nu ]]; then
  while IFS= read -r _l; do
    [[ "$_l" == alias\ * ]] || continue
    _r=${_l#alias }; _n=${_r%% = *}; _c=${_r#* = }
    alias "${_n}=${_c}"
  done < ~/.config/nushell/aliases.nu
  unset _l _r _n _c
fi
# HACK: Command alternatives
# alias vpn="~/.scripts/vpn"
alias js="/usr/bin/node ~/.noderc"
alias ls="exa --icons"
alias la="exa --icons -la"
# alias grep='grep --color=auto'
cd() { pushd $1 && ls; }
alias rm='rm -i'
alias du1='du -h -d 1 2>/dev/null | sort -hr'
alias rec="wl-screenrec --dri-device $MOZ_DRM_DEVICE -f $(date +'%s_grab.mp4')"
alias freq="watch -n1 'grep Hz /proc/cpuinfo'"
alias help="cht.sh"
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
alias newmc="vim ~/.config/newm/config.py"
alias hyprc="vim ~/.config/hypr/hyprland.conf"
alias scrollc="vim ~/.config/scroll/config"
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
ys() {
  paru -Slq | fzf --multi --preview 'paru -Si {1}' | xargs -ro paru -S
}
yclean() {
  paru -Rns $(paru -Qtdq)
  paru -Scc
}
alias ci="{ find . -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n; } 2>/dev/null"
alias fontl="fc-list | cut -d ':' -f2 | sort | uniq"

# -< Environ variable >-
# Vars compartidas — fuente única: config/shell/vars.env (estáticas), colors.env (colores eyes-theme).
set -a
source "$HOME/Git/dotfiles/config/shell/vars.env"
source "$HOME/Git/dotfiles/config/shell/colors.env"
set +a
export PATH="$HOME/.config/emacs/bin:$HOME/.local/bin:$HOME/.dotnet/tools:$HOME/.local/share/bob/nvim-bin:$HOME/.local/share/nvim/mason/bin:$HOME/.config/emacs/bin:$HOME/.npm-global/bin:$PATH"
# FZF y Gum (colores eyes) — fuente única: config/shell/colors.env (sourced arriba).

# Hot-reload: si cambia ~/.config/eyes/mode, re-source colors.env en el próximo prompt.
zmodload -F zsh/stat b:zstat 2>/dev/null
typeset -g _eyes_mode_mtime="$(zstat +mtime "${XDG_CONFIG_HOME:-$HOME/.config}/eyes/mode" 2>/dev/null)"
_eyes_hotreload() {
  local m
  m="$(zstat +mtime "${XDG_CONFIG_HOME:-$HOME/.config}/eyes/mode" 2>/dev/null)" || return 0
  [[ "$m" == "$_eyes_mode_mtime" ]] && return 0
  _eyes_mode_mtime="$m"
  set -a
  source "$HOME/Git/dotfiles/config/shell/colors.env"
  set +a
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _eyes_hotreload

# Working with documents
alias pandock='podman run --rm -v "$(pwd):/data" pandoc/extra'

# BEGIN_KITTY_SHELL_INTEGRATION
custom_autocomplete() {
    zle fzf-tab-complete
    printf "\x1b_Ga=d,d=A\x1b\\"
}

zle -N custom_autocomplete
bindkey '^I' custom_autocomplete
# END_KITTY_SHELL_INTEGRATION

source ~/.zshfunc
# FPATH="/usr/share/zsh/site-functions:${FPATH}"
# source ~/.env
eval "$(zsh-patina activate)"

# Compila rc/func a bytecode (.zwc) si cambiaron; zsh los usa automáticamente
# al hacer source y se salta el parseo de texto.
for _f in ~/.zshrc ~/.zshfunc ${ZIM_HOME}/init.zsh; do
  [[ -s $_f && ( ! -s $_f.zwc || $_f -nt $_f.zwc ) ]] && zcompile "$_f" 2>/dev/null
done
unset _f
