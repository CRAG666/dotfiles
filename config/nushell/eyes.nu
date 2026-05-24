let theme = {
  # FG colors are kept aligned with config/nvim/colors/eyes.lua (dark block).
  # NOTE: maroon and pink must be FG values, not c_winterRed/c_winterYellow
  # (those are BG tints — assigning them to shape_flag/shape_custom would make
  # flags and custom commands render almost invisible on dark bg).
  rosewater: "#88b878"   # c_green1
  flamingo: "#82aab8"    # c_blue1
  pink: "#b890b0"        # c_pink (FG pink)
  mauve: "#9090b8"       # c_violet
  red: "#c87868"         # c_red
  maroon: "#c8a870"      # c_orange1 (coral-ish FG)
  peach: "#b89a6a"       # c_orange0
  yellow: "#d4b85a"      # c_yellow
  green: "#7aab72"       # c_green0
  teal: "#5ab8a8"        # c_teal
  sky: "#6a94a8"         # c_blue0
  sapphire: "#6ab8b0"    # c_aqua
  blue: "#6a94a8"        # c_blue0
  lavender: "#b890b0"    # c_pink (alias of pink)
  text: "#d0dcc8"        # c_fg0
  overlay2: "#7a8a78"    # c_gray1
  surface2: "#6a7868"    # c_gray2
  base: "#1a211a"        # c_bg0
  mantle: "#2d382d"      # c_bg3
  crust: "#3a463a"       # c_bg4
}

let scheme = {
  recognized_command: $theme.blue
  unrecognized_command: $theme.text
  constant: $theme.peach
  punctuation: $theme.overlay2
  operator: $theme.sky
  string: $theme.green
  virtual_text: $theme.surface2
  variable: { fg: $theme.flamingo attr: i }
  filepath: $theme.yellow
}

$env.config.color_config = {
  separator: { fg: $theme.surface2 attr: b }
  leading_trailing_space_bg: { fg: $theme.lavender attr: u }
  header: { fg: $theme.text attr: b }
  row_index: $scheme.virtual_text
  record: $theme.text
  list: $theme.text
  hints: $scheme.virtual_text
  search_result: { fg: $theme.base bg: $theme.yellow }
  shape_closure: $theme.teal
  closure: $theme.teal
  shape_flag: { fg: $theme.maroon attr: i }
  shape_matching_brackets: { attr: u }
  shape_garbage: $theme.red
  shape_keyword: $theme.mauve
  shape_match_pattern: $theme.green
  shape_signature: $theme.teal
  shape_table: $scheme.punctuation
  cell-path: $scheme.punctuation
  shape_list: $scheme.punctuation
  shape_record: $scheme.punctuation
  shape_vardecl: $scheme.variable
  shape_variable: $scheme.variable
  empty: { attr: n }
  filesize: {||
    if $in < 1kb {
      $theme.teal
    } else if $in < 10kb {
      $theme.green
    } else if $in < 100kb {
      $theme.yellow
    } else if $in < 10mb {
      $theme.peach
    } else if $in < 100mb {
      $theme.maroon
    } else if $in < 1gb {
      $theme.red
    } else {
      $theme.mauve
    }
  }
  duration: {||
    if $in < 1day {
      $theme.teal
    } else if $in < 1wk {
      $theme.green
    } else if $in < 4wk {
      $theme.yellow
    } else if $in < 12wk {
      $theme.peach
    } else if $in < 24wk {
      $theme.maroon
    } else if $in < 52wk {
      $theme.red
    } else {
      $theme.mauve
    }
  }
  date: {|| (date now) - $in |
    if $in < 1day {
      $theme.teal
    } else if $in < 1wk {
      $theme.green
    } else if $in < 4wk {
      $theme.yellow
    } else if $in < 12wk {
      $theme.peach
    } else if $in < 24wk {
      $theme.maroon
    } else if $in < 52wk {
      $theme.red
    } else {
      $theme.mauve
    }
  }
  shape_external: $scheme.unrecognized_command
  shape_internalcall: $scheme.recognized_command
  shape_external_resolved: $scheme.recognized_command
  shape_block: $scheme.recognized_command
  block: $scheme.recognized_command
  shape_custom: $theme.pink
  custom: $theme.pink
  background: $theme.base
  foreground: $theme.text
  cursor: { bg: $theme.rosewater fg: $theme.base }
  shape_range: $scheme.operator
  range: $scheme.operator
  shape_pipe: $scheme.operator
  shape_operator: $scheme.operator
  shape_redirection: $scheme.operator
  glob: $scheme.filepath
  shape_directory: $scheme.filepath
  shape_filepath: $scheme.filepath
  shape_glob_interpolation: $scheme.filepath
  shape_globpattern: $scheme.filepath
  shape_int: $scheme.constant
  int: $scheme.constant
  bool: $scheme.constant
  float: $scheme.constant
  nothing: $scheme.constant
  binary: $scheme.constant
  shape_nothing: $scheme.constant
  shape_bool: $scheme.constant
  shape_float: $scheme.constant
  shape_binary: $scheme.constant
  shape_datetime: $scheme.constant
  shape_literal: $scheme.constant
  string: $scheme.string
  shape_string: $scheme.string
  shape_string_interpolation: $theme.flamingo
  shape_raw_string: $scheme.string
  shape_externalarg: $scheme.string
}
$env.config.highlight_resolved_externals = true
$env.config.explore = {
    status_bar_background: { fg: $theme.text, bg: $theme.mantle },
    command_bar_text: { fg: $theme.text },
    highlight: { fg: $theme.base, bg: $theme.yellow },
    status: {
        error: $theme.red,
        warn: $theme.yellow,
        info: $theme.blue,
    },
    selected_cell: { bg: $theme.blue fg: $theme.base },
}
