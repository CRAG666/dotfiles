# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh
. /usr/share/z/z.sh
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
autoload -U compinit
compinit
# Uncomment the following line to use case-sensitive completion.
#CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#dotenv
plugins=(
  git
  python
  history
  ripgrep
  fd
  npm
  colored-man-pages
  extract
  sudo
  command-not-found
  node
  cargo
  dircycle
  docker
  themes
  colors
  virtualenv
  poetry
  systemd
  zsh-256color
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
  fzf-tab
)
#zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview '([[ -f $realpath ]] && (bat --style=numbers --color=always $realpath || cat $realpath)) || ([[ -d $realpath ]] && (tree -C $realpath | less)) || echo $realpath 2> /dev/null | head -200'

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"
ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi


# Util funtions
function acp() {
  git add .
  git commit -m "$1"
  git push
}

function mss(){
  sudo systemctl $1 mysqld
}

function ds(){
  sudo systemctl $1 docker
}

function smb(){
  sudo systemctl $1 smb
  sudo systemctl $1 nmb
}

fapp() {
	selected="$(ls /usr/share/applications | fzf -e)"
	nohup `grep '^Exec' "/usr/share/applications/$selected" | tail -1 | sed 's/^Exec=//' | sed 's/%.//'` >/dev/null 2>&1&
}

fkill() {
  local pid

  pid="$(
    pgrep . -l \
      | fzf -m \
      | awk '{print $1}'
  )" || return
  if [ $pid ];then
    kill -"${1:-9}" "$pid"
  fi
}

tmuxkillf () {
    local sessions
    sessions="$(tmux ls|fzf --exit-0 --multi)"  || return $?
    local i
    for i in "${(f@)sessions}"
    do
        [[ $i =~ '([^:]*):.*' ]] && {
            echo "Killing $match[1]"
            tmux kill-session -t "$match[1]"
        }
    done
}

# -< Source files or scripts >-
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# -> Config <-
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# -< Aliases >-
# Config alias
alias starshipconfig="vim ~/.config/starship.toml"
alias alacriconfig="vim ~/.config/alacritty/alacritty.yml"
alias i3config="vim ~/.config/i3/config"
alias i3barconfig="~/.config/i3status/config"
alias dnsconfig="sudoedit /etc/resolv.conf"
alias zshconfig="vim ~/.zshrc"
alias tmuxc="vim ~/.tmux.conf"
alias firefoxconfig="vim ~/.mozilla/firefox/profiles.ini"
alias vimc='vim ~/.config/nvim/init.vim'
alias vimp='vim ~/.config/nvim/init/plugs.vim'
alias vimm='vim ~/.config/nvim/init/maps.vim'
# Jump alias
alias applications="thunar /usr/share/applications"
alias Escritorio="cd /$HOME/Escritorio"
alias Descargas="cd /$HOME/Descargas"
alias Documentos="cd /$HOME/Documentos"
alias Imágenes="cd /$HOME/Imágenes"
alias Música="cd /$HOME/Música"
alias Vídeos="cd /$HOME/Vídeos"
alias Git="cd /$HOME/Git"
alias usb="cd /run/media/crag"
# command alternatives
alias sys="watch -ct -n0 sys.sh"
alias ping="prettyping"
alias cerrar="sh ~/.scripts/cerrar_ventana"
alias cerrar_todo="sh ~/.scripts/cerrar_todo.sh"
alias js="node ~/.noderc"
alias ll="logo-ls -l"
alias ls="logo-ls"
alias cp="rsync -P"
alias tree="logo-ls -R"
alias vi="nvim"
alias vim="nvim"
# fzf alias
alias fpm="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S"
alias fpmr="pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns"
alias fyay="yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S"

# -< Environ variable >-
export _JAVA_OPTIONS="${_JAVA_OPTIONS}"
#export JAYATANA_FORCE=1
#export ANDROID_SDK_ROOT=/opt/android-sdk
export ANDROID_HOME=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
export MYSQL_PS1="\n \d  ﯐ "
export LC_ALL=es_MX.UTF-8
export LANG=es_MX.UTF-8
export LANGUAGE=es_MX.UTF-8
export PYTHONSTARTUP=~/.pyrc
export TERM="xterm-256color"
export PATH="/opt/brew/bin:$PATH"
export PATH="$HOME/.poetry/bin:$PATH"
source ~/.passmaria.zsh
export VISUAL=nvim
export EDITOR="$VISUAL"
export BAT_THEME="gruvbox-dark"
export FZF_DEFAULT_OPTS="--height 40% --reverse --bind='?:toggle-preview'"
#-< Evals >-
eval $(thefuck --alias)
eval "$(starship init zsh)"

