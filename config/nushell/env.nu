# $env.MYSQL_PS1 = "\\n \d  ﯐ "
$env.VISUAL = $"($env.HOME)/.local/share/bob/nvim-bin/nvim"
$env.EDITOR = $env.VISUAL
$env.PYTHONSTARTUP = $"($env.HOME)/.pyrc"

# BAT_THEME y LS_COLORS (vars temáticas) → fuente única compartida con zsh:
# config/shell/colors.env, cargado via el loader al final de este archivo.

$env.USB = $"/run/media/($env.USER)"
$env.PASSWORD_STORE_ENABLE_EXTENSIONS = true
$env.NVIM_NF = true

$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""

# FZF (no-color) y Gum/FZF colores → fuente única compartida con zsh:
#   config/shell/vars.env    (FZF_DEFAULT_COMMAND, …)
#   config/shell/colors.env  (FZF_DEFAULT_OPTS, GUM_*)
# Se cargan via el loader al final de este archivo.

$env.DOT_DIR = $"($env.HOME)/Git/dotfiles"

# Configuración del PATH
# Nushell maneja el PATH como una lista. Agregamos tus directorios personalizados.
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
let mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force
source ($nu.default-config-dir | path join mise.nu)


# >>> load-shared-env >>>
# Carga las variables compartidas con zsh:
#   vars.env    → estáticas
#   colors.env  → colores FZF/Gum (eyes-theme las reescribe por tema)
# Va al final para tener prioridad sobre las defs anteriores, y cada carga en
# try{} para que un fallo del parser jamás rompa el arranque de nushell.
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
