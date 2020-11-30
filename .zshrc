# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/
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
  ruby
  python
  history
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
  zsh-256color
  colors
  virtualenv
  systemd
)

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

# -< Source files or scripts >-
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# -> Config <-
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# -< Aliases >-
alias starshipconfig="vim ~/.config/starship.toml"
alias alacriconfig="vim ~/.config/alacritty/alacritty.yml"
alias dnsconfig="sudoedit /etc/resolv.conf"
alias js="node ~/.noderc"
alias sys="watch -ct -n0 sys.sh"
alias cerrar_todo="sh ~/.scripts/cerrar_todo.sh"
alias cerrar="sh ~/.scripts/cerrar_ventana"
alias zshconfig="vim ~/.zshrc"
alias firefoxconfig="vim ~/.mozilla/firefox/profiles.ini"
alias usb="cd /run/media/crag"
alias ll="lsd -l"
alias ls="lsd"
alias tree="lsd --tree"
alias vi="nvim"
alias vim="nvim"
alias vimconfig='vim ~/.config/nvim/init.vim'
alias applications="nautilus /usr/share/applications"
alias Escritorio="cd /$HOME/Escritorio"
alias Descargas="cd /$HOME/Descargas"
alias Documentos="cd /$HOME/Documentos"
alias Imágenes="cd /$HOME/Imágenes"
alias Música="cd /$HOME/Música"
alias Vídeos="cd /$HOME/Vídeos"
alias Git="cd /$HOME/Git"
alias dgcs="cp -r ~/Plantillas/.vscode $PWD"
alias ping="prettyping"

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
source ~/.passmaria.zsh
export EDITOR='nvim'
export BAT_THEME="gruvbox"

# -< Evals >-
eval $(thefuck --alias)
eval "$(starship init zsh)"
