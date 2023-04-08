local colors = require("catppuccin.palettes").get_palette()
local theme = vim.tbl_extend("force", colors, { bg = colors.base, fg = colors.text })

local mode_theme = {
  ["NORMAL"] = theme.mauve,
  ["OP"] = theme.lavender,
  ["INSERT"] = theme.red,
  ["VISUAL"] = theme.peach,
  ["LINES"] = theme.maroon,
  ["BLOCK"] = theme.yellow,
  ["REPLACE"] = theme.sky,
  ["V-REPLACE"] = theme.teal,
  ["ENTER"] = theme.blue,
  ["MORE"] = theme.overlay1,
  ["SELECT"] = theme.flamingo,
  ["SHELL"] = theme.rosewater,
  ["TERM"] = theme.green,
  ["NONE"] = theme.overlay2,
  ["COMMAND"] = theme.sapphire,
}

local component = {}

component.vim_mode = {
  provider = function()
    return vim.api.nvim_get_mode().mode:upper()
  end,
  hl = function()
    return {
      fg = "base",
      bg = require("feline.providers.vi_mode").get_mode_color(),
      style = "bold",
      name = "NeovimModeHLColor",
    }
  end,
  left_sep = "block",
  right_sep = "block",
}

component.git_branch = {
  provider = "git_branch",
  hl = {
    fg = "red",
    bg = "base",
    style = "bold",
  },
  left_sep = " ",
  right_sep = "",
}

component.git_add = {
  provider = "git_diff_added",
  hl = {
    fg = "green",
    bg = "base",
  },
  left_sep = "",
  right_sep = "",
}

component.git_delete = {
  provider = "git_diff_removed",
  hl = {
    fg = "red",
    bg = "base",
  },
  left_sep = "",
  right_sep = "",
}

component.git_change = {
  provider = "git_diff_changed",
  hl = {
    fg = "yellow",
    bg = "base",
  },
  left_sep = "",
  right_sep = "",
}

component.separator = {
  provider = "",
  hl = {
    fg = "base",
    bg = "base",
  },
}

component.diagnostic_errors = {
  provider = "diagnostic_errors",
  hl = {
    fg = "red",
  },
}

component.diagnostic_warnings = {
  provider = "diagnostic_warnings",
  hl = {
    fg = "yellow",
  },
}

component.diagnostic_hints = {
  provider = "diagnostic_hints",
  hl = {
    fg = "aqua",
  },
}

component.diagnostic_info = {
  provider = "diagnostic_info",
}

component.lsp = {
  provider = function()
    if not rawget(vim, "lsp") then
      return ""
    end

    local progress = vim.lsp.util.get_progress_messages()[1]
    if vim.o.columns < 120 then
      return ""
    end

    local clients = vim.lsp.get_active_clients { bufnr = 0 }
    if #clients ~= 0 then
      if progress then
        local spinners = {
          "◜ ",
          "◠ ",
          "◝ ",
          "◞ ",
          "◡ ",
          "◟ ",
        }
        local ms = vim.loop.hrtime() / 1000000
        local frame = math.floor(ms / 120) % #spinners
        local content = string.format("%%<%s", spinners[frame + 1])
        return content or ""
      else
        return "לּ LSP"
      end
    end
    return ""
  end,
  hl = function()
    local progress = vim.lsp.util.get_progress_messages()[1]
    return {
      fg = progress and "peach" or "teal",
      bg = "base",
      style = "bold",
    }
  end,
  left_sep = "",
  right_sep = "",
}

component.file_type = {
  provider = {
    name = "file_type",
    opts = {
      filetype_icon = true,
    },
  },
  hl = {
    fg = "sky",
    bg = "base",
  },
  left_sep = "block",
  right_sep = "block",
}

component.file_info = {
  provider = {
    name = "file_info",
    opts = {
      filetype_icon = true,
    },
  },
  hl = {
    fg = "fg",
    bg = "base",
  },
  left_sep = " ",
  right_sep = " ",
}

component.scroll_bar = {
  provider = function()
    local chars = {
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
    }
    local line_ratio = vim.api.nvim_win_get_cursor(0)[1] / vim.api.nvim_buf_line_count(0)
    local position = math.floor(line_ratio * 100)

    if position <= 5 then
      position = " TOP"
    elseif position >= 95 then
      position = " BOT"
    else
      position = chars[math.floor(line_ratio * #chars)] .. position
    end
    return position
  end,
  hl = function()
    local position = math.floor(vim.api.nvim_win_get_cursor(0)[1] / vim.api.nvim_buf_line_count(0) * 100)
    local fg
    local style

    if position <= 5 then
      fg = "mauve"
      style = "bold"
    elseif position >= 95 then
      fg = "red"
      style = "bold"
    else
      fg = "peach"
      style = nil
    end
    return {
      fg = fg,
      style = "bold",
      bg = "base",
    }
  end,
  left_sep = " ",
  right_sep = "",
}

local left = { component.vim_mode, component.file_info }
local middle = {
  component.lsp,
  component.diagnostic_errors,
  component.diagnostic_warnings,
  component.diagnostic_info,
  component.diagnostic_hints,
}
local right = {
  component.git_branch,
  component.git_add,
  component.git_delete,
  component.git_change,
  component.separator,
  component.scroll_bar,
}

local components = {
  active = {
    left,
    middle,
    right,
  },
}

return {
  {
    "freddiehaddad/feline.nvim",
    event = "UIEnter",
    opts = {
      components = components,
      theme = theme,
      vi_mode_colors = mode_theme,
    },
  },
}
---vim:filetype=lua
