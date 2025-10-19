# Archivo de entorno de Nushell
#
# Este archivo establece las variables de entorno al iniciar Nushell.
# Fue migrado desde tu configuración de zsh.

# Variables de entorno generales
# $env.MYSQL_PS1 = "\\n \d  ﯐ "
$env.VISUAL = $"($env.HOME)/.local/share/bob/nvim-bin/nvim"
$env.EDITOR = $env.VISUAL
$env.PYTHONSTARTUP = $"($env.HOME)/.pyrc"
$env.BAT_THEME = "Catppuccin-mocha"
$env.USB = $"/run/media/($env.USER)"
$env.PASSWORD_STORE_ENABLE_EXTENSIONS = true
$env.NVIM_NF = true

# Variables de entorno para FZF
$env.FZF_DEFAULT_COMMAND = 'fd . --type f --hidden --follow --exclude .git --no-ignore'
$env.FZF_DEFAULT_OPTS = " --prompt='ﰉ ' --pointer='ﰊ' --height 40% --reverse --bind='?:toggle-preview' --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Variables de entorno para proyectos de escritura
$env.MARPT = $"($env.HOME)/Documentos/Proyectos/Writings/utils/marp/themes"
$env.IEEESTL = $"($env.HOME)/Documentos/Proyectos/Writings/utils/latex/ieee.csl"
$env.LCOLORCATPPUCCIN = $"($env.HOME)/Documentos/Proyectos/Writings/utils/latex/catppuccin"

# Configuración del PATH
# Nushell maneja el PATH como una lista. Agregamos tus directorios personalizados.
let zsh_paths = [
    $"($env.HOME)/.local/bin",
    $"($env.HOME)/.dotnet/tools",
    $"($env.HOME)/.local/share/bob/nvim-bin",
    $"($env.HOME)/.local/share/nvim/mason/bin",
    $"($env.HOME)/.config/emacs/bin",
    $"($env.HOME)/.npm-global/bin",
]
$env.PATH = ($zsh_paths | append $env.PATH)

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
