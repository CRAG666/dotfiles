# $env.MYSQL_PS1 = "\\n \d  ﯐ "
$env.VISUAL = $"($env.HOME)/.local/share/bob/nvim-bin/nvim"
$env.EDITOR = $env.VISUAL
$env.PYTHONSTARTUP = $"($env.HOME)/.pyrc"

# Vars temáticas (BAT_THEME, LS_COLORS) → fuente única: config/shell/colors.env (loader al final).

$env.USB = $"/run/media/($env.USER)"
$env.PASSWORD_STORE_ENABLE_EXTENSIONS = true
$env.NVIM_NF = true

$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""

# FZF/Gum → fuente única: vars.env (FZF_DEFAULT_COMMAND), colors.env (FZF_DEFAULT_OPTS, GUM_*); loader al final.

$env.DOT_DIR = $"($env.HOME)/Git/dotfiles"

# PATH como lista (nushell): añade directorios personalizados.
let zsh_paths = [
    $"($env.HOME)/.config/emacs/bin",
    $"($env.HOME)/.local/bin",
    $"($env.HOME)/.dotnet/tools",
    $"($env.HOME)/.local/share/bob/nvim-bin",
    $"($env.HOME)/.local/share/nvim/mason/bin",
]
$env.PATH = ($zsh_paths | append $env.PATH)
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"

# >>> load-shared-env >>>
# Vars compartidas: vars.env (estáticas), colors.env (colores eyes-theme).
# Al final para tener prioridad; cada carga en try{} para no romper el arranque.
def --env load-shared-env [file: path] {
    open --raw $file
    | lines
    | where {|l| not ($l | str trim | str starts-with '#') and ($l | str contains '=') }
    | parse --regex '^\s*(?<key>[^=]+?)\s*=\s*(?<value>.*)$'
    | reduce --fold {} {|row, acc|
        let v = ($row.value
            | str trim --char '"'
            | str replace --all '${HOME}' $env.HOME
            | str replace --all '${USER}' $env.USER)
        $acc | upsert ($row.key | str trim) $v
    }
    | load-env
}
try { load-shared-env $"($env.HOME)/Git/dotfiles/config/shell/vars.env" }
try { load-shared-env $"($env.HOME)/Git/dotfiles/config/shell/colors.env" }
# <<< load-shared-env <<<

let mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force
