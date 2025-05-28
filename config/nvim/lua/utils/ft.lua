local M = {}

---Load for given filetype once
---@param from string module to load from
---@param ft string filetype to load, default to current buffer's filetype
---@param action fun(ft: string, ...): boolean return `true` to indicate a successful load
---@return boolean
function M.load_once(from, ft, action)
  local file = string.format('%s.%s', from, ft)
  if package.loaded[file] then
    return false
  end
  local ok, val = pcall(require, file)
  if not ok or not action(ft, val) then
    return false
  end
  -- Only trigger FileType event when ft matches curent buffer's ft, else
  -- it will mess up current buffer's hl and conceal
  if ft == vim.bo.ft then
    vim.api.nvim_exec_autocmds('FileType', { pattern = ft })
  end
  return true
end

---Automatically load filetype-specific file from given module once
---@param from string module to load from
---@param action fun(ft: string, ...): boolean? return `true` to indicate a successful load
function M.auto_load_once(from, action)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    M.load_once(from, vim.bo[buf].ft, action)
  end

  vim.api.nvim_create_autocmd('FileType', {
    desc = string.format('Load for filetypes from %s lazily.', from),
    group = vim.api.nvim_create_augroup('Load_' .. from, {}),
    callback = function(info)
      M.load_once(from, info.match, action)
    end,
  })
end

return M
