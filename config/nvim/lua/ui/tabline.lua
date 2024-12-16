local utils = require "utils"

_G._tabline = {}

---@return string
function _G._tabline.get()
  if vim.g.loaded_tabline == nil then
    _G._tabline.setup()
  end

  local tabnames = {}
  local tabidcur = vim.api.nvim_get_current_tabpage()
  for tabnr, tabid in ipairs(vim.api.nvim_list_tabpages()) do
    table.insert(
      tabnames,
      utils.stl.hl(
        string.format(
          "%%%dT %s %%X",
          tabnr,
          vim.t[tabid]._tabname
            or vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.getcwd(vim.api.nvim_tabpage_get_win(tabid), tabnr), ":.:~"))
        ),
        tabid == tabidcur and "TabLineSel" or "TabLine"
      )
    )
  end
  return table.concat(tabnames)
end

---@param tabid integer?
---@param name string?
---@return nil
function _G._tabline.rename(tabid, name)
  if not tabid or not vim.api.nvim_tabpage_is_valid(tabid) then
    return
  end
  vim.t[tabid]._tabname = name
  vim.cmd.redrawtabline()
end

---@return nil
function _G._tabline.setup()
  if vim.g.loaded_tabline ~= nil then
    return
  end
  vim.g.loaded_tabline = true

  vim.go.tabline = [[%!v:lua._tabline.get()]]

  -- `:[count]TabRename [name]`
  -- 1. `[count]` works like `:[count]tabnew`
  -- 2. When `[name]` is omitted, fallback to default name (cwd)
  vim.api.nvim_create_user_command("TabRename", function(opts)
    _G._tabline.rename(
      opts.count == -1 and vim.api.nvim_get_current_tabpage() or vim.api.nvim_list_tabpages()[opts.count],
      opts.fargs[1]
    )
  end, {
    nargs = "?",
    count = -1,
    addr = "tabs",
    desc = "Rename the current tab.",
  })
end

return _G._tabline
