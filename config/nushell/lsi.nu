let __lsi_theme = (open $env.LSI_THEME_PATH)

let __lsi_icons = {
    dirs: (
        $__lsi_theme.icon.dirs
        | reduce -f {} {|it, acc| $acc | upsert $it.name $it }
    ),
    files: (
        $__lsi_theme.icon.files
        | reduce -f {} {|it, acc|
            $acc | upsert ($it.name | str downcase) $it
        }
    ),
    exts: (
        $__lsi_theme.icon.exts
        | reduce -f {} {|it, acc| $acc | upsert $it.name $it }
    )
}

def decorate-file [input] {
    let is_record = ($input | describe | str starts-with "record")
    let path = if $is_record { $input.name } else { $input }
    let name = ($path | path basename)

    let is_dir = if $is_record {
        $input.type? == "dir"
    } else {
        false
    }

    if $is_dir {
        let match = ($__lsi_icons.dirs | get -o $name)
        if $match != null {
            let hex = ($match.fg? | default "#50fa7b")
            return $"(ansi $hex)($match.text) ($path)(ansi reset)"
        }
        return $"(ansi red)󰉋 ($path)(ansi reset)"
    }

    let lname = ($name | str downcase)
    let file_match = ($__lsi_icons.files | get -o $lname)

    if $file_match != null {
        let hex = ($file_match.fg? | default "#f8f8f2")
        return $"(ansi $hex)($file_match.text)(ansi reset) ($path)"
    }

    let ext = (
        $name
        | path parse
        | get extension?
        | default ""
        | str downcase
    )

    let ext_match = ($__lsi_icons.exts | get -o $ext)
    if $ext_match != null {
        let hex = ($ext_match.fg? | default "#f8f8f2")
        return $"(ansi $hex)($ext_match.text)(ansi reset) ($path)"
    }

    $path
}

def --wrapped ls [...args] {
    let result = (
        nu -c $"ls ($args | str join ' ') | to nuon"
        | complete
    )

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
