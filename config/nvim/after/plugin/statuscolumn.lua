---@return {name:string, text:string, texthl:string}[]
local function get_signs(win)
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.tbl_map(function(sign)
    return vim.fn.sign_getdefined(sign.name)[1]
  end, vim.fn.sign_getplaced(buf, { group = "*", lnum = vim.v.lnum })[1].signs)
end

function _G.StatusColumn()
  local win = vim.g.statusline_winid
  if vim.wo[win].signcolumn == "no" then
    return ""
  end
  local sign, git_sign
  for _, s in ipairs(get_signs(win)) do
    if s.name:find "GitSign" then
      git_sign = s
    else
      sign = s
    end
  end

  local folded = vim.fn.foldclosed(vim.v.lnum) >= 0
  local has_fold = vim.fn.foldlevel(vim.v.lnum) > vim.fn.foldlevel(vim.v.lnum - 1)

  local nu = ""
  if vim.wo[win].number and vim.wo[win].relativenumber and vim.v.virtnum == 0 then
    nu = vim.v.relnum == 0 and vim.v.lnum or ([[%=]] .. vim.v.relnum)
  end

  local components = {
    (sign and ("%#" .. (sign.texthl or "DiagnosticInfo") .. "#" .. sign.text .. "%*"))
      or (folded and vim.opt.fillchars:get().foldclose .. "")
      or (has_fold and vim.opt.fillchars:get().foldopen .. "")
      or (git_sign and ("%#" .. git_sign.texthl .. "#" .. git_sign.text .. "%*"))
      or " ",
    nu .. " ",
  }
  return table.concat(components, "")
end

vim.opt.statuscolumn = [[%!v:lua.StatusColumn()]]
