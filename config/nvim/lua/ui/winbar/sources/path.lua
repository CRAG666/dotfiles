local configs = require('ui.winbar.configs')
local bar = require('ui.winbar.bar')

---Get icon and icon highlight group of a path
---@param path string
---@return string icon
---@return string? icon_hl
local function get_icon(path)
  local icon_kind_opts = configs.opts.icons.kinds
  local icon = icon_kind_opts.symbols.File
  local icon_hl = 'WinBarIconKindFile'
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return icon, icon_hl
  elseif stat.type == 'directory' then
    icon = icon_kind_opts.symbols.Folder
    icon_hl = 'WinBarIconKindFolder'
  end
  if icon_kind_opts.use_devicons then
    local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
    if devicons_ok and stat and stat.type ~= 'directory' then
      local devicon, devicon_hl = devicons.get_icon(
        vim.fs.basename(path),
        vim.fn.fnamemodify(path, ':e'),
        { default = true }
      )
      icon = devicon and devicon .. ' ' or icon
      icon_hl = devicon_hl
    end
  end
  return icon, icon_hl
end

---Convert a path into a winbar symbol
---@param path string full path
---@param buf integer buffer handler
---@param win integer window handler
---@return winbar_symbol_t
local function convert(path, buf, win)
  local path_opts = configs.opts.sources.path
  local icon, icon_hl = get_icon(path)
  return bar.winbar_symbol_t:new(setmetatable({
    buf = buf,
    win = win,
    name = vim.fs.basename(path),
    icon = icon,
    icon_hl = icon_hl,
    ---Override the default jump function
    jump = function(_)
      vim.cmd.edit(path)
    end,
  }, {
    ---@param self winbar_symbol_t
    __index = function(self, k)
      if k == 'children' then
        self.children = {}
        for name in vim.fs.dir(path) do
          if path_opts.filter(name) then
            table.insert(
              self.children,
              convert(vim.fs.joinpath(path, name), buf, win)
            )
          end
        end
        return self.children
      end
      if k == 'siblings' or k == 'sibling_idx' then
        local parent_dir = vim.fs.dirname(path)
        self.siblings = {}
        self.sibling_idx = 1
        for idx, name in vim.iter(vim.fs.dir(parent_dir)):enumerate() do
          if path_opts.filter(name) then
            table.insert(
              self.siblings,
              convert(vim.fs.joinpath(parent_dir, name), buf, win)
            )
            if name == self.name then
              self.sibling_idx = idx
            end
          end
        end
        return self[k]
      end
    end,
  }))
end

---Get list of winbar symbols of the parent directories of given buffer
---@param buf integer buffer handler
---@param win integer window handler
---@param _ integer[] cursor position, ignored
---@return winbar_symbol_t[] winbar symbols
local function get_symbols(buf, win, _)
  local path_opts = configs.opts.sources.path
  local symbols = {} ---@type winbar_symbol_t[]
  local current_path = vim.fs.normalize((vim.api.nvim_buf_get_name(buf)))
  local root = vim.fs.normalize(configs.eval(path_opts.relative_to, buf, win))
  while
    current_path
    and current_path ~= '.'
    and current_path ~= root
    and current_path ~= vim.fs.dirname(current_path)
  do
    table.insert(symbols, 1, convert(current_path, buf, win))
    current_path = vim.fs.dirname(current_path)
  end
  if vim.bo[buf].mod then
    symbols[#symbols] = path_opts.modified(symbols[#symbols])
  end
  return symbols
end

return {
  get_symbols = get_symbols,
}
