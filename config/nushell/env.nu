# $env.MYSQL_PS1 = "\\n \d  ﯐ "
$env.VISUAL = $"($env.HOME)/.local/share/bob/nvim-bin/nvim"
$env.EDITOR = $env.VISUAL
$env.PYTHONSTARTUP = $"($env.HOME)/.pyrc"
$env.BAT_THEME = "eyes-dark"

# LS_COLORS — eyes (light) palette
# Truecolor escapes so directories/symlinks/exec stand out on sage-green bg.
# Format: key=SGR_codes (semicolon-separated)
$env.LS_COLORS = ([
  "di=1;38;2;106;148;168"          # directory      — blue0 #6a94a8 bold
  "ln=38;2;90;184;168"             # symlink        — teal #5ab8a8
  "or=38;2;200;120;104;1"          # orphan symlink — red bold
  "ex=1;38;2;122;171;114"           # executable     — green0 #7aab72 bold
  "fi=38;2;208;220;200"             # regular file   — fg0
  "pi=38;2;184;154;106"             # pipe (FIFO)    — orange0
  "so=38;2;184;144;176"              # socket         — pink #b890b0
  "bd=38;2;200;168;112"             # block device   — orange1
  "cd=38;2;212;184;90"               # char device    — yellow
  "do=38;2;144;144;184"              # door           — violet
  "su=1;38;2;138;40;32"           # setuid         — bright red bold
  "sg=1;38;2;138;40;32"           # setgid         — bright red bold
  "tw=38;2;208;220;200;48;2;108;144;96"   # sticky+ow dir on bg5
  "ow=38;2;106;148;168;48;2;32;40;32" # other-writable dir on bg1
  "st=38;2;26;33;26;48;2;106;148;168" # sticky dir
  # Archives / packages → magenta family
  "*.tar=38;2;184;144;176" "*.tgz=38;2;184;144;176" "*.gz=38;2;184;144;176"
  "*.zip=38;2;184;144;176" "*.7z=38;2;184;144;176"  "*.xz=38;2;184;144;176"
  "*.zst=38;2;184;144;176" "*.bz2=38;2;184;144;176" "*.rar=38;2;184;144;176"
  # Images → orange
  "*.jpg=38;2;184;154;106" "*.jpeg=38;2;184;154;106" "*.png=38;2;184;154;106"
  "*.gif=38;2;184;154;106" "*.bmp=38;2;184;154;106"  "*.webp=38;2;184;154;106"
  "*.svg=38;2;184;154;106"
  # Video → red
  "*.mp4=38;2;200;120;104" "*.mkv=38;2;200;120;104" "*.webm=38;2;200;120;104"
  "*.mov=38;2;200;120;104" "*.avi=38;2;200;120;104"
  # Audio → green
  "*.mp3=38;2;122;171;114"  "*.flac=38;2;122;171;114" "*.wav=38;2;122;171;114"
  "*.ogg=38;2;122;171;114"  "*.opus=38;2;122;171;114"
  # Documents → aqua/teal
  "*.pdf=38;2;90;184;168"  "*.epub=38;2;90;184;168" "*.djvu=38;2;90;184;168"
  "*.md=38;2;106;184;176"   "*.txt=38;2;208;220;200"
] | str join ":")
$env.USB = $"/run/media/($env.USER)"
$env.PASSWORD_STORE_ENABLE_EXTENSIONS = true
$env.NVIM_NF = true

$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""

# Variables de entorno para FZF
$env.FZF_DEFAULT_COMMAND = 'fd . --type f --hidden --follow --exclude .git --no-ignore'
$env.FZF_DEFAULT_OPTS = " --prompt='ﰉ ' --pointer='ﰊ' --height 40% --reverse --bind='?:toggle-preview' --color=bg+:#3a463a,bg:#1a211a,spinner:#b890b0,hl:#c87868 --color=fg:#6a94a8,header:#c87868,info:#9090b8,pointer:#b890b0 --color=marker:#b890b0,fg+:#d0dcc8,prompt:#9090b8,hl+:#c87868"

# Gum (Charm) — eyes palette via env vars; eyes-theme hex-swap toggles them.
$env.GUM_CHOOSE_CURSOR_FOREGROUND = "#b890b0"
$env.GUM_CHOOSE_SELECTED_FOREGROUND = "#c87868"
$env.GUM_CHOOSE_HEADER_FOREGROUND = "#c87868"
$env.GUM_INPUT_CURSOR_FOREGROUND = "#b890b0"
$env.GUM_INPUT_PROMPT_FOREGROUND = "#9090b8"
$env.GUM_INPUT_PLACEHOLDER_FOREGROUND = "#7a8a78"
$env.GUM_INPUT_HEADER_FOREGROUND = "#c87868"
$env.GUM_WRITE_CURSOR_FOREGROUND = "#b890b0"
$env.GUM_WRITE_PROMPT_FOREGROUND = "#9090b8"
$env.GUM_WRITE_PLACEHOLDER_FOREGROUND = "#7a8a78"
$env.GUM_WRITE_HEADER_FOREGROUND = "#c87868"
$env.GUM_CONFIRM_PROMPT_FOREGROUND = "#9090b8"
$env.GUM_CONFIRM_SELECTED_BACKGROUND = "#c87868"
$env.GUM_CONFIRM_SELECTED_FOREGROUND = "#1a211a"
$env.GUM_CONFIRM_UNSELECTED_BACKGROUND = "#3a463a"
$env.GUM_CONFIRM_UNSELECTED_FOREGROUND = "#d0dcc8"
$env.GUM_FILTER_INDICATOR_FOREGROUND = "#b890b0"
$env.GUM_FILTER_SELECTED_PREFIX_FOREGROUND = "#c87868"
$env.GUM_FILTER_MATCH_FOREGROUND = "#d4b85a"
$env.GUM_FILTER_PROMPT_FOREGROUND = "#9090b8"
$env.GUM_FILTER_PLACEHOLDER_FOREGROUND = "#7a8a78"
$env.GUM_FILTER_HEADER_FOREGROUND = "#c87868"
$env.GUM_SPIN_SPINNER_FOREGROUND = "#c87868"

# Configuración del PATH
# Nushell maneja el PATH como una lista. Agregamos tus directorios personalizados.
let zsh_paths = [
    $"($env.HOME)/.config/emacs/bin",
    $"($env.HOME)/.local/bin",
    $"($env.HOME)/.dotnet/tools",
    $"($env.HOME)/.local/share/bob/nvim-bin",
    $"($env.HOME)/.local/share/nvim/mason/bin",
    # $"($env.HOME)/.config/emacs/bin",
]
$env.PATH = ($zsh_paths | append $env.PATH)
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
let mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force
source ($nu.default-config-dir | path join mise.nu)
