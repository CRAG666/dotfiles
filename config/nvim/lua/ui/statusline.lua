utils = require "utils"
icons = require "utils.static.icons"
-- Don't show the command that produced the quickfix list.
vim.g.qf_disable_statusline = 1

-- Show the mode in my custom component instead.
vim.o.showmode = false

--- Keeps track of the highlight groups I've already created.
---@type table<string, boolean>
local statusline_hls = {}

---@param hl string
---@return string
function get_or_create_hl(hl)
  local hl_name = "Statusline" .. hl

  if not statusline_hls[hl] then
    -- If not in the cache, create the highlight group using the icon's foreground color
    -- and the statusline's background color.
    local bg_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
    local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
    vim.api.nvim_set_hl(0, hl_name, { bg = ("#%06x"):format(bg_hl.bg), fg = ("#%06x"):format(fg_hl.fg) })
    statusline_hls[hl] = true
  end

  return hl_name
end

--- Current mode.
---@return string
function mode_component()
  -- Note that: \19 = ^S and \22 = ^V.
  local mode_to_str = {
    ["n"] = "NORMAL",
    ["no"] = "OP-PENDING",
    ["nov"] = "OP-PENDING",
    ["noV"] = "OP-PENDING",
    ["no\22"] = "OP-PENDING",
    ["niI"] = "NORMAL",
    ["niR"] = "NORMAL",
    ["niV"] = "NORMAL",
    ["nt"] = "NORMAL",
    ["ntT"] = "NORMAL",
    ["v"] = "VISUAL",
    ["vs"] = "VISUAL",
    ["V"] = "VISUAL",
    ["Vs"] = "VISUAL",
    ["\22"] = "VISUAL",
    ["\22s"] = "VISUAL",
    ["s"] = "SELECT",
    ["S"] = "SELECT",
    ["\19"] = "SELECT",
    ["i"] = "INSERT",
    ["ic"] = "INSERT",
    ["ix"] = "INSERT",
    ["R"] = "REPLACE",
    ["Rc"] = "REPLACE",
    ["Rx"] = "REPLACE",
    ["Rv"] = "VIRT REPLACE",
    ["Rvc"] = "VIRT REPLACE",
    ["Rvx"] = "VIRT REPLACE",
    ["c"] = "COMMAND",
    ["cv"] = "VIM EX",
    ["ce"] = "EX",
    ["r"] = "PROMPT",
    ["rm"] = "MORE",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    ["t"] = "TERMINAL",
  }

  -- Get the respective string to display.
  local mode = mode_to_str[vim.api.nvim_get_mode().mode] or "UNKNOWN"

  -- Set the highlight group.
  local hl = "Other"
  if mode:find "NORMAL" then
    hl = "Normal"
  elseif mode:find "PENDING" then
    hl = "Pending"
  elseif mode:find "VISUAL" then
    hl = "Visual"
  elseif mode:find "INSERT" or mode:find "SELECT" then
    hl = "Insert"
  elseif mode:find "COMMAND" or mode:find "TERMINAL" or mode:find "EX" then
    hl = "Command"
  end

  -- Construct the bubble-like component.
  return table.concat {
    string.format("%%#StatuslineModeSeparator%s#", hl),
    string.format("%%#StatuslineMode%s#%s", hl, mode),
    string.format("%%#StatuslineModeSeparator%s#", hl),
  }
end

---@return string
function git_diff()
  -- Integración con gitsigns.nvim
  ---@diagnostic disable-next-line: undefined-field
  local diff = vim.b.gitsigns_status_dict or utils.git.diffstat()
  local added = diff.added or 0
  local changed = diff.changed or 0
  local removed = diff.removed or 0

  local result = ""

  if added > 0 then
    result = result .. string.format("%%#StatuslineGitAdded#%s %d ", icons.git.Added, added)
  end
  if changed > 0 then
    result = result .. string.format("%%#StatuslineGitChanged#%s %d ", icons.git.Modified, changed)
  end
  if removed > 0 then
    result = result .. string.format("%%#StatuslineGitRemoved#%s %d ", icons.git.Removed, removed)
  end

  return result
end

--- Git status (if any).
---@return string
function git_component()
  local head = vim.b.gitsigns_head
  if not head then
    return ""
  end

  return string.format("%%#TelescopeResultsDiffDelete# %%#StatuslineItalic#%s %s", head, git_diff())
end

--- The current debugging status (if any).
---@return string?
function dap_component()
  if not package.loaded["dap"] or require("dap").status() == "" then
    return nil
  end

  return string.format("%%#%s#%s  %s", get_or_create_hl "DapUIRestart", icons.misc.Bug, require("dap").status())
end

---@type table<string, string?>
local progress_status = {
  client = nil,
  kind = nil,
  title = nil,
}

vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("mariasolos/statusline", { clear = true }),
  desc = "Update LSP progress in statusline",
  pattern = { "begin", "end" },
  callback = function(args)
    -- This should in theory never happen, but I've seen weird errors.
    if not args.data then
      return
    end

    progress_status = {
      client = vim.lsp.get_client_by_id(args.data.client_id).name,
      kind = args.data.params.value.kind,
      title = args.data.params.value.title,
    }

    if progress_status.kind == "end" then
      progress_status.title = nil
      -- Wait a bit before clearing the status.
      vim.defer_fn(function()
        vim.cmd.redrawstatus()
      end, 3000)
    else
      vim.cmd.redrawstatus()
    end
  end,
})
--- The latest LSP progress message.
---@return string
function lsp_progress_component()
  if not progress_status.client or not progress_status.title then
    return ""
  end

  -- Avoid noisy messages while typing.
  if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
    return ""
  end

  return table.concat {
    "%#StatuslineSpinner#󱥸 ",
    string.format("%%#StatuslineTitle#%s  ", progress_status.client),
    string.format("%%#StatuslineItalic#%s...", progress_status.title),
  }
end

local last_diagnostic_component = ""
--- Diagnostic counts in the current buffer.
---@return string
function diagnostics_component()
  -- Use the last computed value if in insert mode.
  if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
    return last_diagnostic_component
  end

  local counts = vim.iter(vim.diagnostic.get(0)):fold({
    ERROR = 0,
    WARN = 0,
    HINT = 0,
    INFO = 0,
  }, function(acc, diagnostic)
    local severity = vim.diagnostic.severity[diagnostic.severity]
    acc[severity] = acc[severity] + 1
    return acc
  end)

  local parts = {}
  for severity, count in pairs(counts) do
    if count ~= 0 then
      local hl = "Diagnostic" .. severity:sub(1, 1) .. severity:sub(2):lower()
      local part =
        string.format("%%#%s#%s %%#StatuslineItalic#%d", get_or_create_hl(hl), icons.diagnostics[severity], count)
      table.insert(parts, part)
    end
  end

  return table.concat(parts, " ")
end

--- The buffer's filetype.
---@return string
function filetype_component()
  local devicons = require "nvim-web-devicons"

  -- Special icons for some filetypes.
  local special_icons = {
    DiffviewFileHistory = { icons.kinds.GitBranch, "Number" },
    DiffviewFiles = { icons.kinds.GitBranch, "Number" },
    DressingInput = { "󰍩", "Comment" },
    DressingSelect = { "", "Comment" },
    OverseerForm = { "󰦬", "Special" },
    OverseerList = { "󰦬", "Special" },
    dapui_breakpoints = { icons.misc.Bug, "DapUIRestart" },
    dapui_scopes = { icons.misc.Bug, "DapUIRestart" },
    dapui_stacks = { icons.misc.Bug, "DapUIRestart" },
    gitcommit = { icons.kinds.GitBranch, "Number" },
    gitrebase = { icons.kinds.GitBranch, "Number" },
    fzf = { "", "Special" },
    lazy = { icons.kinds.Method, "Special" },
    lazyterm = { "", "Special" },
    minifiles = { icons.kinds.Folder, "Directory" },
    qf = { icons.misc.Search, "Conditional" },
    spectre_panel = { icons.misc.Search, "Constant" },
  }
  local filetype = vim.bo.filetype
  if filetype == "" then
    filetype = "[No Name]"
  end

  local icon, icon_hl
  if special_icons[filetype] then
    icon, icon_hl = unpack(special_icons[filetype])
  else
    local buf_name = vim.api.nvim_buf_get_name(0)
    local name, ext = vim.fn.fnamemodify(buf_name, ":t"), vim.fn.fnamemodify(buf_name, ":e")

    icon, icon_hl = devicons.get_icon(name, ext)
    if not icon then
      icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
    end
  end
  icon_hl = get_or_create_hl(icon_hl)

  return string.format("%%#%s#%s %%#StatuslineTitle#%%#StatuslineItalic#%s", icon_hl, icon, filetype)
end

--- File-content encoding for the current buffer.
---@return string
function encoding_component()
  local encoding = vim.opt.fileencoding:get()
  return encoding ~= ""
      and string.format("%%#StatuslineModeSeparatorOther#%%#NvimTreeRootFolder# %%#StatuslineItalic#%s", encoding)
    or ""
end

--- The current line, total line count, and column position.
---@return string
function position_component()
  local line = vim.fn.line "."
  local line_count = vim.api.nvim_buf_line_count(0)
  local col = vim.fn.virtcol "."

  return table.concat {
    "%#StatuslineItalic#l: ",
    string.format("%%#StatuslineTitle#%d", line),
    string.format("%%#StatuslineItalic#/%d c: %d", line_count, col),
  }
end

--- Renders the statusline.
---@return string
function render()
  ---@param components string[]
  ---@return string
  local function concat_components(components)
    return vim.iter(components):skip(1):fold(components[1], function(acc, component)
      return #component > 0 and string.format("%s    %s", acc, component) or acc
    end)
  end

  return table.concat {
    [[%{%&bt==#''?'%t':(&bt==#'terminal'?'[Terminal] '.bufname()->substitute('^term://.\{-}//\d\+:\s*','',''):'%F')%} ]],
    concat_components {
      -- mode_component(),
      git_component(),
      dap_component() or lsp_progress_component(),
    },
    "%#StatusLine#%=",
    concat_components {
      diagnostics_component(),
      filetype_component(),
      encoding_component(),
      position_component(),
    },
    " ",
  }
end

return {
  render = render,
}
