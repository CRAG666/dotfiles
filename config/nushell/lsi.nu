def decorate-file [input] {
    let is_record = ($input | describe | str starts-with "record")
    let path = if $is_record { $input.name } else { $input }
    let name = ($path | path basename)
    let is_dir = if $is_record {
        ($input.type? == "dir")
    } else {
        try { ($path | path type) == 'dir' } catch { false }
    }

    let theme = (open $env.LSI_THEME_PATH)
    let icons = ($theme | get -o icon | default { dirs: [], files: [], exts: [] })

    if $is_dir {
        let match = ($icons.dirs | where name == $name | first | default null)
        if $match != null {
            let hex = ($match | get -o fg | default "#50fa7b")
            return $"(ansi $hex)($match.text) ($path)(ansi reset)"
        }
        return $"(ansi red)󰉋 ($path)(ansi reset)"
    } else {
        let exact_file = ($icons.files | where name == $name | first | default null)
        let match_file = if $exact_file != null {
            $exact_file
        } else {
            $icons.files | where {|it| ($it.name | str downcase) == ($name | str downcase)} | first | default null
        }

        if $match_file != null {
            let hex = ($match_file | get -o fg | default "#f8f8f2")
            return $"(ansi $hex)($match_file.text)(ansi reset) ($path)"
        }

        let ext = ($name | path parse | get extension | default "" | str downcase)
        let match_ext = ($icons.exts | where name == $ext | first | default null)
        if $match_ext != null {
            let hex = ($match_ext | get -o fg | default "#f8f8f2")
            return $"(ansi $hex)($match_ext.text)(ansi reset) ($path)"
        }
    }

    return $path
}

def --wrapped ls [...args] {
    if ($args | any {|it| $it in ["-h" "--help"]}) {
        nu -c $"ls ($args | str join ' ')"
        return
    }

    let result = (nu -c $"ls -t ($args | str join ' ') | to nuon" | complete)

    if $result.exit_code != 0 {
        print -e $result.stderr
        return
    }

    let data = ($result.stdout | from nuon)

    if ($data | describe | str starts-with "table") {
        $data | update name {|row| decorate-file $row }
    } else {
        $data
    }
}

def gst [] {
  git status --short --porcelain
  | lines
  | each { |line|
      let status = ($line | str substring 0..1)  # Solo 2 caracteres
      let file = ($line | str substring 3..)
      {status: $status, file: $file}
  }
  | update status { |row|
      match $row.status {
        " M" => $"(ansi yellow)(ansi reset)",
        "A " => $"(ansi green)(ansi reset)",
        " D" => $"(ansi red)(ansi reset)",
        "??" => $"(ansi cyan)(ansi reset)",,
        "MM" => $"(ansi yellow)(ansi reset)",
        "AM" => $"(ansi green)(ansi yellow)(ansi reset)",
        "M " => $"(ansi green)✎(ansi reset)",
        "D " => $"(ansi green)✖(ansi reset)",
        "R " => $"(ansi purple)﯇(ansi reset)",
        "UD" | "DU" => $"(ansi red)(ansi reset)",
        _ => $row.status
      }
  }
  | update file { |row| decorate-file $row.file }
}
