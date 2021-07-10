# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh

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

plugins=(
  git
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
  virtualenv
  systemd
  fzf
)

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

encrypt(){
  openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in $1 -out $2
}

decrypt(){
  openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in $1 -out $2
}

# Util funtions
acp() {
  git add .
  git commit -m "$1"
  git push
}

mss(){
  sudo systemctl $1 mysqld
}

ds(){
  sudo systemctl $1 docker
}

smb(){
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

gitignore() {
    if [ $# = 1 ]; then
      curl -L -s https://www.gitignore.io/api/$@ > .gitignore
    else
      echo 'usage: gitignore django'
    fi
}

# -< Source files or scripts >-
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zshplugins/fzf-tab/fzf-tab.plugin.zsh
#source ~/.zshplugins/poetry/_poetry

# -> Config <-
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
#zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview '([[ -f $realpath ]] && (bat --style=numbers --color=always $realpath || cat $realpath)) || ([[ -d $realpath ]] && (tree -C $realpath | less)) || echo $realpath 2> /dev/null | head -200'

# -< Aliases >-
# TODO: Config alias
alias starshipc="vim ~/.config/starship.toml"
alias alacric="vim ~/.config/alacritty/alacritty.yml"
alias swayc="vim ~/.config/sway/config"
alias i3c="vim ~/.config/i3/config"
alias i3barc="~/.config/i3status/config"
alias dnsc="sudoedit /etc/resolv.conf"
alias zshc="vim ~/.zshrc"
alias tmuxc="vim ~/.tmux.conf"
alias firefoxc="vim ~/.mozilla/firefox/profiles.ini"
alias kittyc="vim ~/.config/kitty/kitty.conf"
alias nftc="sudoedit /etc/nftables.conf"
alias grubc="sudoedit /etc/default/grub"
# HACK: Config Nvim Aliases
alias vimc='vim ~/.config/nvim/init.lua'
alias vimp='vim ~/.config/nvim/lua/plugs.lua'
alias vimm='vim ~/.config/nvim/lua/keymappings.lua'
alias vimt='vim ~/.config/nvim/lua/colorscheme.lua'
alias vimcp='vim ~/.config/nvim/lua/config'
# HACK: Jump alias
alias applications="cd /usr/share/applications"
alias Escritorio="cd /$HOME/Escritorio"
alias Descargas="cd /$HOME/Descargas"
alias Documentos="cd /$HOME/Documentos"
alias Imágenes="cd /$HOME/Imágenes"
alias Música="cd /$HOME/Música"
alias Vídeos="cd /$HOME/Vídeos"
alias Git="cd /$HOME/Git"
alias usb="cd /run/media/crag"
# HACK: Command alternatives
alias sys="watch -ct -n0 sys.sh"
alias ping="prettyping"
alias cerrar="sh ~/.scripts/cerrar_ventana"
alias cerrar_todo="sh ~/.scripts/cerrar_todo.sh"
alias node="/usr/bin/node ~/.noderc"
alias ll="ls-icons -l"
alias ls="ls-icons"
alias cp="rsync -P"
alias tree="ls-icons -R"
alias vi="nvim"
alias vim="nvim"
# HACK: HACK: fzf alias
alias fpm="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S"
alias fpmr="pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns"
alias fyay="yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S"

# -< Environ variable >-
export ANDROID_HOME=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
export MYSQL_PS1="\n \d  ﯐ "
export LC_ALL=es_MX.UTF-8
export LANG=es_MX.UTF-8
export LANGUAGE=es_MX.UTF-8
export PYTHONSTARTUP=~/.pyrc
export TERM="xterm-256color"
export PATH="$HOME/.poetry/bin:$PATH"
export VISUAL=nvim
export EDITOR=$VISUAL
export BAT_THEME="gruvbox-dark"
export FZF_DEFAULT_OPTS="--height 40% --reverse --bind='?:toggle-preview' --pointer='⮞'"
source ~/.passmaria.zsh

#-< Evals >-
eval "$(zoxide init zsh)"
eval $(thefuck --alias)
eval "$(starship init zsh)"
