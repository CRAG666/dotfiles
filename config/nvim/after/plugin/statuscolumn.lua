local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

if _G.StatusColumn then
  return
end

_G.StatusColumn = {}

local function get_vnum()
  return vim.wo.relativenumber and vim.v.relnum or vim.v.lnum
end

local function is_virtual_line()
  return vim.v.virtnum < 0
end

local function is_wrapped_line()
  return vim.v.virtnum > 0
end

local function not_in_fold_range()
  return vim.fn.foldlevel(vim.v.lnum) <= 0
end

local function not_fold_start(line)
  line = line or vim.v.lnum
  return vim.fn.foldlevel(line) <= vim.fn.foldlevel(line - 1)
end

local function fold_opened(line)
  return vim.fn.foldclosed(line or get_vnum()) == -1
end

local function git_sign()
  return vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), {
    group = "gitsigns_vimfn_signs_",
    lnum = vim.v.lnum,
  })[1].signs[1]
end

local function line_number()
  local num = tostring(get_vnum())
  if is_virtual_line() then
    return string.rep(" ", #num)
  elseif is_wrapped_line() then
    return " " .. string.rep(" ", #num)
  else
    return (#num == 1 and " " or "") .. num
  end
end

local function fold_icon()
  if is_wrapped_line() or is_virtual_line() then
    return ""
  end

  local icon
  if not_in_fold_range() or not_fold_start() then
    icon = "  "
  elseif fold_opened() then
    icon = Icons.misc.expanded
  else
    icon = Icons.misc.collapsed
  end

  return icon
end

local highlights_cache = {}

local function border_highlight()
  local sign = git_sign()
  if sign then
    if not highlights_cache[sign.name] then
      highlights_cache[sign.name] = vim.fn.sign_getdefined(sign.name)[1].texthl
    end
    return highlights_cache[sign.name]
  else
    return "StatusColumnBorder"
  end
end

local number = function(lnum)
  return { "%=", line_number(), " " }
end

local fold = function()
  return { "%#FoldColumn#", "%@v:lua.StatusColumn.fold_click_handler@", fold_icon() }
end

local border = function()
  return { "%#", border_highlight(), "#", Icons.misc.v_border, "%*" }
end

local padding = function()
  if get_vnum() == vim.fn.getcurpos()[2] then
    return { "%#StatusColumnBufferCursorLine#", " " }
  else
    return { "%#StatusColumnBuffer#", " " }
  end
end

StatusColumn.build = function()
  return table.concat(vim.tbl_flatten { number(), fold(), border(), padding() })
end

-- StatusColumn.rel = function()
--   return table.concat(vim.tbl_flatten { number(vim.v.relnum), fold(), border(), padding() })
-- end

StatusColumn.fold_click_handler = function()
  local line = vim.fn.getmousepos().line

  if not_fold_start(line) then
    return
  end

  vim.cmd.execute("'" .. line .. "fold" .. (fold_opened(line) and "close" or "open") .. "'")
end

StatusColumn.set_window = function(value, defer, win)
  vim.defer_fn(function()
    win = win or vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_option(win, "statuscolumn", value)
  end, defer or 1)
end

local numbertogglegroup = augroup("numbertoggle", { clear = true })
autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
  pattern = "*",
  callback = function()
    if vim.o.nu and vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt.relativenumber = true
    end
  end,
  group = numbertogglegroup,
})
autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, {
  pattern = "*",
  callback = function()
    if vim.o.nu then
      vim.opt.relativenumber = false
    end
  end,
  group = numbertogglegroup,
})

vim.opt.statuscolumn = "%{%v:lua.StatusColumn.build()%}"
