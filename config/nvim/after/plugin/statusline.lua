-- M.get_git_status = function(self, addh, changeh, removeh, headh)
--   -- use fallback because it doesn't set this variable on the initial `BufEnter`
--   local signs = vim.b.gitsigns_status_dict or { head = "", added = 0, changed = 0, removed = 0 }
--   local is_head_empty = signs.head ~= ""
--
--   if self:is_truncated(90) then
--     return is_head_empty and string.format("  %s ", signs.head or "") or ""
--   end
--
--   local format = "%%#%s#%s %s "
--   local git_status = {
--     "",
--     "",
--     "",
--     string.format("%%#Border#| %%#%s# %s ", headh, signs.head),
--   }
--   if signs.added > 0 then
--     git_status[1] = string.format(format, addh, Icons.git.status_added, signs.added)
--   end
--   if signs.changed > 0 then
--     git_status[2] = string.format(format, changeh, Icons.git.status_modified, signs.changed)
--   end
--   if signs.removed > 0 then
--     git_status[3] = string.format(format, removeh, Icons.git.status_removed, signs.removed)
--   end
--   return is_head_empty and table.concat(git_status) or ""
-- end
--
local bg = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg
local bg_win = vim.api.nvim_get_hl(0, { name = "WinBar" }).bg

function StatusFileIcon()
  local file_comp = "%#StatusLine#%t %h%m%r"
  local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  local icon, color = require("nvim-web-devicons").get_icon_color_by_filetype(ft, {})
  if icon ~= nil then
    vim.api.nvim_set_hl(0, "StatusLineIcon", { fg = color, bg = bg })
    return "%#StatusLineIcon#" .. icon .. " " .. file_comp
  end
  return file_comp
end

function WinbarFileIcon()
  local file_comp = "%#WinBar#%f %h%m%r"
  local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  local icon, color = require("nvim-web-devicons").get_icon_color_by_filetype(ft, {})
  if icon ~= nil then
    vim.api.nvim_set_hl(0, "WinBarIcon", { fg = color, bg = bg_win })
    return "%#WinBarIcon#" .. icon .. " " .. file_comp
  end
  return file_comp
end

local severities = {
  "Error",
  "Warn",
  "Info",
  "Hint",
}

for _, severity in ipairs(severities) do
  local fg = vim.api.nvim_get_hl(0, { name = "DiagnosticSign" .. severity }).fg
  vim.api.nvim_set_hl(0, "DiagnosticStatus" .. severity, { fg = fg, bg = bg })
end

function StatusDiagnostics()
  local str = ""

  for _, severity in ipairs(severities) do
    local count = #vim.diagnostic.get(0, { severity = severity })
    if count > 0 then
      local sign = vim.fn.sign_getdefined("DiagnosticSign" .. severity)[1]
      if sign ~= nil then
        str = str .. " %#DiagnosticStatus" .. severity .. "#" .. sign.text .. count .. "%#StatusLine#"
      end
    end
  end
  return str
end

local C_fallback = {}
setmetatable(C_fallback, {
  __index = function()
    return "#b4befe"
  end,
})
local C = require("catppuccin.palettes").get_palette() or C_fallback

local assets = {
  mode_icon = "",
  dir = "",
  file = "",
  lsp = {
    server = "",
  },
  git = {
    branch = "",
  },
}

local mode_colors = {
  ["n"] = { "NORMAL", C.lavender },
  ["no"] = { "N-PENDING", C.lavender },
  ["nt"] = { "NORMAL", C.lavender },
  ["niI"] = { "I-NORMAL", C.lavender },
  ["i"] = { "INSERT", C.green },
  ["ic"] = { "INSERT", C.green },
  ["t"] = { "TERMINAL", C.green },
  ["v"] = { "VISUAL", C.flamingo },
  ["V"] = { "V-LINE", C.flamingo },
  [""] = { "V-BLOCK", C.flamingo },
  ["R"] = { "REPLACE", C.maroon },
  ["Rv"] = { "V-REPLACE", C.maroon },
  ["s"] = { "SELECT", C.maroon },
  ["S"] = { "S-LINE", C.maroon },
  [""] = { "S-BLOCK", C.maroon },
  ["c"] = { "COMMAND", C.peach },
  ["cv"] = { "COMMAND", C.peach },
  ["ce"] = { "COMMAND", C.peach },
  ["r"] = { "PROMPT", C.teal },
  ["rm"] = { "MORE", C.teal },
  ["r?"] = { "CONFIRM", C.mauve },
  ["!"] = { "SHELL", C.green },
}

function StatusMode()
  local mode = vim.api.nvim_get_mode()

  if mode_colors[mode.mode] == nil then
    print('Unhandled mode "' .. mode .. '" encountered in statusline')
  end

  local name = (mode_colors[mode.mode] or { "NORMAL", C.lavender })[1]
  local color = (mode_colors[mode.mode] or { "NORMAL", C.lavender })[2]
  vim.api.nvim_set_hl(0, "StatusMode", { fg = C.surface0, bg = color, bold = true })

  return "%#StatusMode# " .. assets.mode_icon .. " " .. name .. " %#StatusLine#"
end

function StatusLsp()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  local names = vim.tbl_map(function(item)
    return item.name
  end, clients)
  return "%#StatusLineNC#" .. assets.lsp.server .. " " .. table.concat(names, ", ") .. "%#StatusLine#"
end

function StatusGit()
  if vim.b.gitsigns_head then
    return assets.git.branch .. " " .. vim.b.gitsigns_head
  end
  return ""
end

local function wrap(funcName)
  return [[%{%luaeval("]] .. funcName .. [[()")%}]]
end

local statusline = {
  table.concat({
    wrap "StatusMode",
    wrap "StatusFileIcon",
    [[ %P ]],
    [[%l:%c%V]],
  }, " "),
  wrap "StatusDiagnostics",
  table.concat({
    wrap "StatusLsp",
    [[ ]],
    wrap "StatusGit",
  }, " "),
}

vim.opt.statusline = table.concat(statusline, "%=")

-- vim.opt.winbar = [[%<%{%luaeval("WinbarFileIcon()")%}]]
