# $env.MYSQL_PS1 = "\\n \d  ﯐ "
$env.VISUAL = $"($env.HOME)/.local/share/bob/nvim-bin/nvim"
$env.EDITOR = $env.VISUAL
$env.PYTHONSTARTUP = $"($env.HOME)/.pyrc"
$env.BAT_THEME = "eyes"

# LS_COLORS — eyes (light) palette
# Truecolor escapes so directories/symlinks/exec stand out on sage-green bg.
# Format: key=SGR_codes (semicolon-separated)
$env.LS_COLORS = ([
  "di=1;38;2;30;72;104"          # directory      — blue0 #1e4868 bold
  "ln=38;2;20;88;80"             # symlink        — teal #145850
  "or=38;2;122;30;24;1"          # orphan symlink — red bold
  "ex=1;38;2;42;92;34"           # executable     — green0 #2a5c22 bold
  "fi=38;2;26;26;26"             # regular file   — fg0
  "pi=38;2;106;60;16"             # pipe (FIFO)    — orange0
  "so=38;2;90;40;88"              # socket         — pink #5a2858
  "bd=38;2;122;74;24"             # block device   — orange1
  "cd=38;2;90;72;8"               # char device    — yellow
  "do=38;2;58;40;96"              # door           — violet
  "su=1;38;2;138;40;32"           # setuid         — bright red bold
  "sg=1;38;2;138;40;32"           # setgid         — bright red bold
  "tw=38;2;26;26;26;48;2;108;144;96"   # sticky+ow dir on bg5
  "ow=38;2;30;72;104;48;2;164;204;152" # other-writable dir on bg1
  "st=38;2;173;212;160;48;2;30;72;104" # sticky dir
  # Archives / packages → magenta family
  "*.tar=38;2;90;40;88" "*.tgz=38;2;90;40;88" "*.gz=38;2;90;40;88"
  "*.zip=38;2;90;40;88" "*.7z=38;2;90;40;88"  "*.xz=38;2;90;40;88"
  "*.zst=38;2;90;40;88" "*.bz2=38;2;90;40;88" "*.rar=38;2;90;40;88"
  # Images → orange
  "*.jpg=38;2;106;60;16" "*.jpeg=38;2;106;60;16" "*.png=38;2;106;60;16"
  "*.gif=38;2;106;60;16" "*.bmp=38;2;106;60;16"  "*.webp=38;2;106;60;16"
  "*.svg=38;2;106;60;16"
  # Video → red
  "*.mp4=38;2;122;30;24" "*.mkv=38;2;122;30;24" "*.webm=38;2;122;30;24"
  "*.mov=38;2;122;30;24" "*.avi=38;2;122;30;24"
  # Audio → green
  "*.mp3=38;2;42;92;34"  "*.flac=38;2;42;92;34" "*.wav=38;2;42;92;34"
  "*.ogg=38;2;42;92;34"  "*.opus=38;2;42;92;34"
  # Documents → aqua/teal
  "*.pdf=38;2;20;88;80"  "*.epub=38;2;20;88;80" "*.djvu=38;2;20;88;80"
  "*.md=38;2;26;88;88"   "*.txt=38;2;26;26;26"
] | str join ":")
$env.USB = $"/run/media/($env.USER)"
$env.PASSWORD_STORE_ENABLE_EXTENSIONS = true
$env.NVIM_NF = true

$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""

# Variables de entorno para FZF
$env.FZF_DEFAULT_COMMAND = 'fd . --type f --hidden --follow --exclude .git --no-ignore'
$env.FZF_DEFAULT_OPTS = " --prompt='ﰉ ' --pointer='ﰊ' --height 40% --reverse --bind='?:toggle-preview' --color=bg+:#88b07e,bg:#add4a0,spinner:#5a2858,hl:#7a1e18 --color=fg:#1e4868,header:#7a1e18,info:#3a2860,pointer:#5a2858 --color=marker:#5a2858,fg+:#1a1a1a,prompt:#3a2860,hl+:#7a1e18"

# Gum (Charm) — eyes palette via env vars; eyes-theme hex-swap toggles them.
$env.GUM_CHOOSE_CURSOR_FOREGROUND = "#5a2858"
$env.GUM_CHOOSE_SELECTED_FOREGROUND = "#7a1e18"
$env.GUM_CHOOSE_HEADER_FOREGROUND = "#7a1e18"
$env.GUM_INPUT_CURSOR_FOREGROUND = "#5a2858"
$env.GUM_INPUT_PROMPT_FOREGROUND = "#3a2860"
$env.GUM_INPUT_PLACEHOLDER_FOREGROUND = "#385030"
$env.GUM_INPUT_HEADER_FOREGROUND = "#7a1e18"
$env.GUM_WRITE_CURSOR_FOREGROUND = "#5a2858"
$env.GUM_WRITE_PROMPT_FOREGROUND = "#3a2860"
$env.GUM_WRITE_PLACEHOLDER_FOREGROUND = "#385030"
$env.GUM_WRITE_HEADER_FOREGROUND = "#7a1e18"
$env.GUM_CONFIRM_PROMPT_FOREGROUND = "#3a2860"
$env.GUM_CONFIRM_SELECTED_BACKGROUND = "#7a1e18"
$env.GUM_CONFIRM_SELECTED_FOREGROUND = "#add4a0"
$env.GUM_CONFIRM_UNSELECTED_BACKGROUND = "#88b07e"
$env.GUM_CONFIRM_UNSELECTED_FOREGROUND = "#1a1a1a"
$env.GUM_FILTER_INDICATOR_FOREGROUND = "#5a2858"
$env.GUM_FILTER_SELECTED_PREFIX_FOREGROUND = "#7a1e18"
$env.GUM_FILTER_MATCH_FOREGROUND = "#5a4808"
$env.GUM_FILTER_PROMPT_FOREGROUND = "#3a2860"
$env.GUM_FILTER_PLACEHOLDER_FOREGROUND = "#385030"
$env.GUM_FILTER_HEADER_FOREGROUND = "#7a1e18"
$env.GUM_SPIN_SPINNER_FOREGROUND = "#7a1e18"

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
