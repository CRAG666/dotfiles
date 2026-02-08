def hex-to-ansi [hex: string] {
    let clean = ($hex | str replace "#" "")
    if ($clean | str length) != 6 { return (ansi white) }

    let r = ($clean | str substring 0..2 | into int --radix 16)
    let g = ($clean | str substring 2..4 | into int --radix 16)
    let b = ($clean | str substring 4..6 | into int --radix 16)
    $"\e[38;2;($r);($g);($b)m"
}

def decorate-file [input] {
    let is_record = ($input | describe | str starts-with "record")
    let path = if $is_record { $input.name } else { $input }
    let name = ($path | path basename)
    let is_dir = if $is_record {
        ($input.type? == "dir")
    } else {
        try { ($path | path type) == 'dir' } catch { false }
    }
    let theme = (open ~/.config/yazi/theme.toml)
    let icons = ($theme | get -o icon | default { dirs: [], files: [], exts: [] })
    if $is_dir {
        let match = ($icons.dirs | where name == $name | first | default null)
        if $match != null {
            let hex = ($match | get -o fg | default "#50fa7b")
            return $"((hex-to-ansi $hex))($match.text)(ansi reset) ($path)"
        }
        return $"(ansi blue)(ansi reset) ($path)"
    } else {
       let exact_file = ($icons.files | where name == $name | first | default null)
        let match_file = if $exact_file != null {
            $exact_file
        } else {
            $icons.files | where {|it| ($it.name | str downcase) == ($name | str downcase)} | first | default null
        }
        if $match_file != null {
            let hex = ($match_file | get -o fg | default "#f8f8f2")
            return $"((hex-to-ansi $hex))($match_file.text)(ansi reset) ($path)"
        }
        let ext = ($name | path parse | get extension | default "" | str downcase)
        let match_ext = ($icons.exts | where name == $ext | first | default null)
        if $match_ext != null {
            let hex = ($match_ext | get -o fg | default "#f8f8f2")
            return $"((hex-to-ansi $hex))($match_ext.text)(ansi reset) ($path)"
        }
    }
    return $path
}

def --wrapped ls [...args] {
    if ($args | any {|it| $it == "-h" or $it == "--help"}) {
        # Unimos argumentos y ejecutamos en subshell para ver la ayuda nativa
        nu -c $"ls ($args | str join ' ')"
        return
    }
    let safe_args = ($args | each {|it|
        if ($it | str starts-with "-") { $it } else { $it | to nuon }
    } | str join " ")

    let output = (do { nu -c $"ls ($safe_args) | to nuon" } | complete)

    if $output.exit_code != 0 {
        print ($output.stderr)
        return
    }

    let data = ($output.stdout | from nuon)

    if ($data | describe | str starts-with "table") {
        $data | update name { |row| decorate-file $row }
    } else {
        $data
    }
}
