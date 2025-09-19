local utils = require('utils')

_G._tabline = {}

---Get tab display name given tabpage id and number
---@param tabnr integer
---@param tabid integer
---@return string
local function tabgetname(tabnr, tabid)
  if not vim.api.nvim_tabpage_is_valid(tabid) then
    return ''
  end
  return vim.t[tabid]._tabname
    or vim.fs.basename(
      vim.fn.getcwd(vim.api.nvim_tabpage_get_win(tabid), tabnr)
    )
end

setmetatable(_G._tabline, {
  ---@return string
  __call = function()
    local tabnames = {}
    local tabids = vim.api.nvim_list_tabpages()
    local tabnrcur = vim.fn.tabpagenr()

    -- If tab-local tab name variable is not set but a global tab name variable
    -- exists for that tab, restore the tab-local tab name using the global tab
    -- name variable, this should only happen during or after session load once
    if not vim.g._tabline_name_restored then
      for tabnr, tabid in ipairs(tabids) do
        local tabname_id = vim.t[tabid]._tabname
        local tabname_nr = vim.g['Tabname' .. tabnr]
        if not tabname_id and tabname_nr then
          vim.t[tabid]._tabname = tabname_nr
        end
      end
      vim.g._tabline_name_restored = true
    end

    -- Save the tab-local name variable to the corresponding global variable
    -- Tab names are saved in global variables by number instead of id
    -- because tab ids are not preserved across sessions
    for tabnr, tabid in ipairs(tabids) do
      if vim.g._tabline_name_restored then
        vim.g['Tabname' .. tabnr] = vim.t[tabid]._tabname
      end
    end

    local leftpad, rightpad = ' ', ' '

    for tabnr, tabid in ipairs(tabids) do
      table.insert(
        tabnames,
        string.format('%s%s%s', leftpad, tabgetname(tabnr, tabid), rightpad)
      )
    end

    -- Shrink tabnames if tabline cannot fit into screen
    if vim.fn.strdisplaywidth(table.concat(tabnames)) > vim.go.columns then
      local ellipsis = vim.trim(utils.static.icons.Ellipsis)
      local tabwidth = math.floor(vim.go.columns / vim.fn.tabpagenr('$'))
      local tabnameshrinkwidth = math.max(
        1,
        tabwidth - vim.fn.strdisplaywidth(ellipsis .. leftpad .. rightpad)
      )
      for i, tabname in ipairs(tabnames) do
        if vim.fn.strdisplaywidth(tabname) > tabwidth then
          tabnames[i] = string.format(
            '%s%s%s%s',
            leftpad,
            vim.fn.strcharpart(vim.trim(tabname), 0, tabnameshrinkwidth),
            ellipsis,
            rightpad
          )
        end
      end
    end

    -- Colorize and add click response
    for tabnr, tabname in ipairs(tabnames) do
      tabnames[tabnr] = utils.stl.hl(
        string.format('%%%dT%s%%X', tabnr, tabname),
        tabnr == tabnrcur and 'TabLineSel' or 'TabLine'
      )
    end

    return table.concat(tabnames)
  end,
})

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

-- `:[count]TabRename [name]`
-- 1. `[count]` works like `:[count]tabnew`
-- 2. When `[name]` is omitted, fallback to default name (cwd)
vim.api.nvim_create_user_command('TabRename', function(opts)
  _G._tabline.rename(
    opts.count == -1 and vim.api.nvim_get_current_tabpage()
      or vim.api.nvim_list_tabpages()[opts.count],
    opts.fargs[1]
  )
end, {
  nargs = '?',
  count = -1,
  addr = 'tabs',
  desc = 'Rename the current tab.',
  complete = function()
    local tabnrcur = vim.fn.tabpagenr()
    local tabidcur = vim.api.nvim_get_current_tabpage()
    local tabnamecur = tabgetname(tabnrcur, tabidcur)

    local tabnames = {} ---@type table<string, true> deduplicated tab names
    for tabnr, tabid in ipairs(vim.api.nvim_list_tabpages()) do
      tabnames[tabgetname(tabnr, tabid)] = true
    end

    -- Make current tab's name first in the completion menu
    local compl = { tabnamecur } ---@type string[]
    for tabname, _ in pairs(tabnames) do
      if tabname ~= tabnamecur then
        table.insert(compl, tabname)
      end
    end

    return compl
  end,
})

-- Preserve tab names across sessions
vim.opt.sessionoptions:append('globals')

local groupid = vim.api.nvim_create_augroup('my.tabline.name', {})

vim.api.nvim_create_autocmd({ 'UIEnter', 'SessionLoadPost' }, {
  desc = 'Set flag to enable tab name psersistence across sessions.',
  group = groupid,
  once = true,
  callback = function()
    vim.g._tabline_name_restored = true
  end,
})

vim.api.nvim_create_autocmd('TabClosed', {
  desc = 'Clear global tab name variable for closed tabs.',
  group = groupid,
  callback = function(args)
    vim.g['Tabname' .. args.file] = nil
  end,
})

return _G._tabline
