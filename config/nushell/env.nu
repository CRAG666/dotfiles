# Nushell Environment Config File
#
# version = "0.98.0"


# The prompt indicators are environmental variables that represent
# the state of the prompt
# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = ""
# FIXME: This default is not implemented in rust code as of 2023-09-08.

$env.PROMPT_COMMAND_RIGHT = ""

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = ""

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
use std "path add"
# $env.PATH = ($env.PATH | split row (char esep))
# path add /some/path
# path add ($env.CARGO_HOME | path join "bin")
# path add ($env.HOME | path join ".local" "bin")
# $env.PATH = ($env.PATH | uniq)

path add ($env.HOME | path join ".dotnet" "tools")
path add ($env.HOME | path join ".local" "bin")
path add ($env.HOME | path join ".local" "share" "nvim" "mason" "bin")
path add ($env.HOME | path join ".local" "share" "bob" "nvim-bin")

# To load from a custom file you can use:
# source ($nu.default-config-dir | path join 'custom.nu')


#$env.MYSQL_PS1 = "\n \d  ﯐ "
$env.VISUAL = "nvim"
$env.EDITOR = $env.VISUAL
$env.PYTHONSTARTUP = "~/.pyrc"
$env.BAT_THEME = "Catppuccin-mocha"
$env.USB = "/run/media/$USER"
$env.FZF_DEFAULT_COMMAND = "fd . --type f --hidden --follow --exclude .git --no-ignore"
$env.FZF_DEFAULT_OPTS = " --prompt='ﰉ ' --pointer='ﰊ' --height 40% --reverse --bind='?:toggle-preview' --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
$env.MARPT = "~/Documentos/Proyectos/Writings/utils/marp/themes"
$env.EISVOGEL = "~/Documentos/Proyectos/Writings/utils/latex/eisvogel.tex"
$env.IEEESTL = "~/Documentos/Proyectos/Writings/utils/latex/ieee.csl"
$env.LCOLORCATPPUCCIN = "~/Documentos/Proyectos/Writings/utils/latex/catppuccin"
$env.STARSHIP_SHELL = "nu"

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
zoxide init nushell | save -f ~/.zoxide.nu

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
