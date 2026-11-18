let __lsi_theme = (open $env.LSI_THEME_PATH)

let __lsi_icons = {
    dirs: ($__lsi_theme.icon.dirs | each {|it| {($it.name): $it} } | into record),
    files: ($__lsi_theme.icon.files | each {|it| {($it.name | str lowercase): $it} } | into record),
    exts: ($__lsi_theme.icon.exts | each {|it| {($it.name): $it} } | into record)
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
            return $"(ansi $hex)($match.text)(ansi reset) ($path)"
        }
        return $"(ansi cyan)󰉋(ansi reset) ($path)"
    }

    let lname = ($name | str lowercase)
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
        | str lowercase
    )

    let ext_match = ($__lsi_icons.exts | get -o $ext)
    if $ext_match != null {
        let hex = ($ext_match.fg? | default "#f8f8f2")
        return $"(ansi $hex)($ext_match.text)(ansi reset) ($path)"
    }

    $path
}

def ls [
    --all (-a) # Show hidden files.
    --long (-l) # Get all available columns for each entry.
    --short-names (-s) # Only print the file names, and not the path.
    --full-paths (-f) # Display paths as absolute paths.
    --du (-d) # Display the apparent directory size in place of the directory metadata size.
    --directory (-D) # List the specified directory itself instead of its contents.
    --mime-type (-m) # Show mime-type in type column instead of 'file'.
    --threads (-t) # Use multiple threads to list contents.
    ...pattern: glob # The glob pattern to use.
] {
    let pattern = if ($pattern | is-empty) { ['.'] } else { $pattern }
    (
        core-ls
        --all=$all
        --long=$long
        --short-names=$short_names
        --full-paths=$full_paths
        --du=$du
        --directory=$directory
        --mime-type=$mime_type
        --threads=$threads
        ...$pattern
    )
    | sort-by type name
    | update name {|row| decorate-file $row }
}

def gst [] {
  git status --short --porcelain
  | lines
  | each { |line|
      let status = ($line | str substring 0..1)  # Only 2 characters
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
