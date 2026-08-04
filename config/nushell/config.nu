$env.LSI_THEME_PATH = $"($env.HOME)/.config/yazi/flavors/eyes-(try { open $"($env.HOME)/.config/eyes/mode" | str trim } catch { 'light' }).yazi/flavor.toml"
source ~/.config/nushell/lsi.nu
$env.config.hooks = ($env.config.hooks | upsert env_change {
    PWD: [
        {|before, after|
            print (ls -t | table)
        }
    ]
})

$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
$env.config.cursor_shape = {
    vi_insert: line
    vi_normal: block
    emacs: line
}
$env.config.use_kitty_protocol = true
$env.config.show_banner = false
$env.config.history.file_format = "sqlite"
$env.config.history.sync_on_enter = true
$env.config.table = {
    mode: rounded
    index_mode: auto
    show_empty: true
    trim: {
        methodology: wrapping
        wrapping_try_keep_words: true
        truncating_suffix: "..."
    }
}

alias rm = rm -ti

def vi [...args] {
    $env.NVIM_APPNAME = "nvim-minimal"
    nvim ...$args
}

alias Applications = cd /usr/share/applications
alias Desktop = cd $"($env.HOME)/Escritorio"
alias Download = cd $"($env.HOME)/Descargas"
alias Document = cd $"($env.HOME)/Documentos"
alias Images = cd $"($env.HOME)/Imágenes"
alias Music = cd $"($env.HOME)/Música"
alias Videos = cd $"($env.HOME)/Vídeos"
alias Git = cd $"($env.HOME)/Git"
alias Usb = cd $env.USB
alias q = do {|x|
  pi --tools bash,read -p $"Read the man page \(or --help if none exists\) for the following Linux command and output ONLY a cheat.sh-style reference in plain shell-script format: a one-line comment summarizing the command at the top, then 4-8 realistic example invocations from basic to advanced, each preceded by a one-line comment starting with # explaining what it does. Every line must be either a comment starting with # or an actual runnable shell command exactly as it would appear in a .sh file - no markdown code fences, no headers, no bullet points, no bold text, no prose paragraphs. End with one comment starting with # gotcha: describing a common mistake. Keep it under 25 lines total. The command is: ($x)"
  | bat -l bash --style=plain --paging=never --color=always
}
def h [...args: string] {
    let hour = (date now | format date "%H" | into int)
    let style = if $hour >= 7 and $hour < 19 { "?style=emacs" } else { "" }
    let query = ($args | str join " ")
    curl -s $"cheat.sh/($query)($style)"
}

def sar [find_text: string, replace_text: string] {
    let files_to_change = (rg -l $find_text | lines)

    if ($files_to_change | is-empty) {
        print "No se encontraron archivos."
        return
    }

    for $file in $files_to_change {
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

def fkill [signal: int = 9] {
    let processes = (
        ps
        | where pid != 1
        | select pid name
    )

    let selection = (
        $processes
        | each { |p| $p.name }
        | uniq
        | str join "\n"
        | ^gum filter --no-limit --height 25
    )

    if ($selection | is-empty) {
        return
    }

    $processes
    | where name in ($selection | lines)
    | get pid
    | each { |pid|
        kill --signal $signal ($pid | into int)
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

def du1 [] { du -d 1 | sort-by apparent }
def paci [] { ^bash -c "pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S" }
def pacr [] { ^bash -c "pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns" }
def ys [] {
    ^pacman -Slq
    | fzf --multi --preview 'pacman -Si {1}'
    | xargs -ro sudo pacman -S
}
def yclean [] {
    let orphans = (pacman -Qtdq | lines)
    if ($orphans | is-empty) {
        print "No hay paquetes huérfanos para limpiar."
    } else {
        sudo pacman -Rns $orphans
    }
    sudo pacman -Scc
}

def ci [] { ^bash -c "{ find . -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n; } 2>/dev/null" }
def fontl [] { ^bash -c "fc-list | cut -d ':' -f2 | sort | uniq" }

def polars-open [file: path] {
    polars open $file | polars into-nu
}

def norg [
    workspace: string  # Nombre del workspace (ej: academic, personal, work)
] {
    nvim -c $"Neorg workspace ($workspace)"
}

def ddl [
    db_file: path,           # El archivo de la base de datos (.db)
    table_name?: string      # Nombre de la tabla (opcional)
] {
    if ($table_name == null) {
        open $db_file | query db "SELECT name, sql FROM sqlite_schema WHERE type = 'table'"
    } else {
        open $db_file | query db $"SELECT sql FROM sqlite_schema WHERE name = '($table_name)'"
    }
}

# Túnel SSH al ollama del cluster (gpuserver02:11652 vía login node).
def otun-up [] { ^setsid ssh -fN ollama-tunnel; print "túnel arriba → localhost:11652 (sobrevive al cerrar la terminal)" }
def otun-down [] { do -i { ^pkill -f 'ssh -fN ollama-tunnel' }; print "túnel cerrado" }

source $"($nu.cache-dir)/carapace.nu"
let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}
source ~/.zoxide.nu
source ~/.local/share/atuin/init.nu

$env.config = (
    $env.config | upsert keybindings (
        $env.config.keybindings
        | append {
            name: atuin_vi_normal_k
            modifier: none
            keycode: char_k
            mode: [vi_normal]
            event: { send: executehostcommand cmd: (_atuin_search_cmd) }
        }
        # Ctrl+T: fzf con ~/.scripts/preview e inserta la ruta (equivalente al preview de fzf-tab en zsh).
        | append {
            name: fzf_file_preview
            modifier: control
            keycode: char_t
            mode: [emacs, vi_insert]
            event: {
                send: executehostcommand
                cmd: "let _sel = (try { fd --hidden --exclude .git --color never | fzf --height 90% --preview '~/.scripts/preview {}' | str trim } catch { '' }); if ($_sel | is-not-empty) { commandline edit --insert ($_sel | str replace -a ' ' '\\ ') }"
            }
        }
    )
)

source ~/.config/nushell/theme.nu
source ~/.config/nushell/podman.nu
source ~/.config/nushell/git.nu
source ~/.config/nushell/aliases.nu

$env._EYES_MODE_MTIME = (try { ls $"($env.HOME)/.config/eyes/mode" | get 0.modified | into int } catch { -1 })
$env.config.hooks.pre_prompt = (
    $env.config.hooks.pre_prompt? | default [] | append {
        condition: {||
            (try { ls $"($env.HOME)/.config/eyes/mode" | get 0.modified | into int } catch { -1 }) != $env._EYES_MODE_MTIME
        }
        code: '
            $env._EYES_MODE_MTIME = (try { ls $"($env.HOME)/.config/eyes/mode" | get 0.modified | into int } catch { -1 })
            try { load-shared-env $"($env.HOME)/Git/dotfiles/config/shell/colors.env" }
            source ~/.config/nushell/theme.nu
        '
    }
)
