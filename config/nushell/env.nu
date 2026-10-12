# gpg: the agent needs the current terminal for pinentry (pass, git sign…).
try { $env.GPG_TTY = (^tty | str trim) }

$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""

# PATH as a list (nushell): prepend custom directories.
let zsh_paths = [
    $"($env.HOME)/.config/emacs/bin",
    $"($env.HOME)/.local/bin",
    $"($env.HOME)/.local/share/mise/shims",
    $"($env.HOME)/.dotnet/tools",
    $"($env.HOME)/.local/share/bob/nvim-bin",
    $"($env.HOME)/.local/share/nvim/mason/bin",
]
$env.PATH = ($zsh_paths | append $env.PATH)
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"

# >>> load-shared-env >>>
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
$env.DOT_DIR = ($nu.env-path | path expand | path dirname | path dirname | path dirname)
try { load-shared-env $"($env.DOT_DIR)/config/shell/vars.env" }
try { load-shared-env $"($env.DOT_DIR)/config/shell/colors.env" }
# <<< load-shared-env <<<
