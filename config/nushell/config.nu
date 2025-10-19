$env.config.hooks = ($env.config.hooks | upsert env_change {
    PWD: [
        {|before, after|
            print (ls | table)
        }
    ]
})

$env.config.buffer_editor = "nvim"
$env.config.use_kitty_protocol = true
$env.config.show_banner = false
$env.config.history.max_size = 0


alias ip = ip -color=auto
alias ping = prettyping
alias js = /usr/bin/node ~/.noderc
alias cp = fcp
alias tree = exa --icons --tree --level=4 --long --git
alias zt = /bin/zathura --fork
alias zb = zen-browser
alias lo = /bin/libreoffice
alias music = termusic
alias rm = rm -i
alias fm = yazi
alias help = cht.sh
alias update-grub = sudo grub-mkconfig -o /boot/grub/grub.cfg
alias neofetch = fastfetch -l ~/.config/fastfetch/thinkpad.txt --logo-color-1 white --logo-color-2 red --logo-color-3 '38;2;23;147;209'
alias la = ls -la
alias ll = ls -l

def vi [...args] {
    NVIM_APPNAME=nvim-minimal nvim ...$args
}
alias vic = vi ~/.config/nvim-minimal/init.lua
def vim [...args] {
    NVIM_NF=true nvim ...$args
}
alias vimc = nvim ~/.config/nvim/init.lua
alias vimk = nvim ~/.config/nvim/lua/core/keymaps.lua
alias vimd = nvim ~/.config/nvim/lua/core/opts.lua
alias vima = nvim ~/.config/nvim/lua/core/autocmds.lua
alias viml = nvim ~/.config/nvim/lua/core/lsp.lua
alias vo = nvim -c "Neorg workspace notes"
alias vs = nvim -c "Neorg workspace state_art"

alias grubc = sudo -e /etc/default/grub
alias newmc = nvim ~/.config/newm/config.py
alias hyprc = nvim ~/.config/hypr/hyprland.conf
alias owlc = nvim ~/.config/owl/owl.conf
alias keydc = nvim ~/Git/dotfiles/etc/keyd/default.conf
alias zshc = nvim ~/.zshrc
alias zshf = nvim ~/.zshfunc
alias zimc = nvim ~/.zimrc
alias dnsc = nvim /etc/resolv.conf
alias nftc = nvim /etc/nftables.conf
alias starshipc = nvim ~/.config/starship.toml

def Applications [] { cd /usr/share/applications }
def Desktop [] { cd $"($env.HOME)/Escritorio" }
def Download [] { cd $"($env.HOME)/Descargas" }
def Document [] { cd $"($env.HOME)/Documentos" }
def Images [] { cd $"($env.HOME)/Imágenes" }
def Music [] { cd $"($env.HOME)/Música" }
def Videos [] { cd $"($env.HOME)/Vídeos" }
def Git [] { cd $"($env.HOME)/Git" }
def Usb [] { cd $env.USB }

alias gbc = git switch -c

alias kittyc = nvim ~/.config/kitty/kitty.conf
alias icat = kitten icat
alias s = kitten ssh

def pclean [] {
    podman rm (podman ps -aq)
    podman rmi (podman images -q)
    podman volume prune
    podman network prune
}

def sar [find_text: string, replace_text: string] {
    let files_to_change = (rg $find_text -l)
    if ($files_to_change | is-empty) {
        print "No se encontraron archivos."
        return
    }
    for file in $files_to_change {
        let content = (open $file | str replace -a $find_text $replace_text)
        $content | save -f $file
    }
    print $"Cambiado en ($files_to_change | length) archivos."
}

def encrypt [infile: path, outfile: path] {
    openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in $infile -out $outfile
}

def decrypt [infile: path, outfile: path] {
    openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in $infile -out $outfile
}

def get_commit_info [] {
    let TYPE = (gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")
    let SCOPE_INPUT = (gum input --placeholder "scope")
    let SCOPE = if not ($SCOPE_INPUT | is-empty) { $"($SCOPE_INPUT)" } else { "" }
    let SUMMARY = (gum input --value $"($TYPE)($SCOPE): " --placeholder "Resumen de este cambio")
    let DESCRIPTION = (gum write --placeholder "Detalles de este cambio")
    { summary: $SUMMARY, description: $DESCRIPTION }
}

def gac [] {
    let commit_info = (get_commit_info)
    if (gum confirm "Hacer commit de los cambios?") {
        git add .
        git commit -m $commit_info.summary -m $commit_info.description
    }
}

def acp [] {
    let commit_info = (get_commit_info)
    if (gum confirm "Hacer commit de los cambios?") {
        git add .
        git commit -m $commit_info.summary -m $commit_info.description
        git push
    }
}

def dhg [commit_message: string] {
    git checkout --orphan latest_branch
    git add -A
    git commit -am $commit_message
    git branch -D main
    git branch -m main
    git push -f origin main
}

def gitignore [framework: string] {
    try {
        http get $"https://www.gitignore.io/api/($framework)" | save .gitignore
    } catch {
        print "Error: No se pudo obtener el gitignore. Uso: gitignore <framework>"
    }
}

def vims [pattern: string] {
    let files = (rg $pattern -l | lines)
    if not ($files | is-empty) {
        nvim -p $files
    } else {
        print "No se encontraron archivos para el patrón."
    }
}

def uuid [count: int = 1] {
    for i in 1..$count {
        python -c "import uuid; print(uuid.uuid4())"
    }
}

def gb [] {
    git for-each-ref --color=always --sort=-committerdate refs/heads/ --format=' %(color:green)%(committerdate:relative)%(color:reset)%09%(HEAD) %(color:yellow)%(refname:short)%(color:reset) %(color:magenta)%(authorname)%(color:reset) • %(contents:subject)'
}

def gbs [] {
    let branch = (gb | gum filter --no-limit --height=25 --placeholder 'switch branch <choose branch>' | split row ' ' | get 3)

    if ($branch | is-not-empty) {
        ^git switch $branch
    }
}

def fkill [signal: int = 9] {
  let pid = (pgrep . -l | gum filter --no-limit --height=25 | lines | split column " " pid name | get pid)
  if $pid != "" {
    kill --signal $signal $pid
  }
}

def fapp [] {
    let selected = (ls /usr/share/applications | get name | to text | gum filter --no-limit --height=25 --placeholder "Select an application")

    let filename = ($selected | str trim | path basename)

    let exec_line = (open $"/usr/share/applications/($filename)" | lines | find --regex '^Exec' | last)

    let command = ($exec_line | str replace '^Exec=' '' | str replace '%.' '')

    bash -c $"nohup ($command) >/dev/null 2>&1 &"
}

def dirsum [directory?: string] {
    if ($directory == null) {
        print 'usage: dirsum [directory]'
        return
    }

    let dir = ($directory | str trim --right --char '/')

    glob $"($dir)/**/*"
    | where ($it | path type) == "file"
    | each { |file| ^shasum $file | split row ' ' | get 0 }
    | sort
    | to text
    | ^shasum
    | split row ' '
    | get 0
}

def glog [commit?: int] {
    let count = if ($commit == null) { 10 } else { $commit }
    git log --pretty=%h»¦«%aN»¦«%s»¦«%aD | lines | split column "»¦«" sha1 committer desc merged_at | first $count
}

def ghgram [] {
    git log --pretty=%h»¦«%aN»¦«%s»¦«%aD | lines | split column "»¦«" sha1 committer desc merged_at | histogram committer merger | sort-by merger | reverse
}

def dus [] { ^bash -c 'du -h --max-depth=1 2>/dev/null | sort -hr' }
def du1 [] { ^bash -c 'du -h -d 1 2>/dev/null | sort -hr' }
def aicli [] { ^bash -c 'eval $(gum choose "gemini" "qwen" "crush")' }
def paci [] { ^bash -c "pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S" }
def pacr [] { ^bash -c "pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns" }
def ys [] { ^bash -c "yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S" }
def ci [] { ^bash -c "{ find . -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n; } 2>/dev/null" }
def fontl [] { ^bash -c "fc-list | cut -d ':' -f2 | sort | uniq" }
# def atm [flag: string] { ^bash -c $'atm "($flag)"' }

source $"($nu.cache-dir)/carapace.nu"
source ~/.zoxide.nu
source ~/.local/share/atuin/init.nu
source ~/.config/nushell/catppuccin_mocha.nu
