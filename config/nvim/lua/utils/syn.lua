local M = {}

---@param buf? integer default to current buffer
---@return boolean
function M.is_active(buf)
  buf = buf or 0
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].syntax ~= ''
end

---@class syn_find_group_opts_t
---@field bufnr? integer
---@field depth? integer

---@param names string|string[]|fun(types: string|string[]): boolean type of node, or function to check node type
---@param opts? syn_find_group_opts_t
---@return integer?
function M.find_group(names, opts)
  opts = opts or {}
  opts.bufnr = opts.bufnr or 0
  opts.depth = opts.depth or math.huge

  if not M.is_active(opts.bufnr) then
    return
  end

  ---Check if given syntax group name matches any of the names given in `names`
  ---@type fun(name: string): boolean?
  local check_name_match = vim.is_callable(names)
      and function(name)
        return names(name)
      end
    or function(name)
      if type(names) == 'string' then
        names = { names }
      end
      return vim.iter(names):any(function(n)
        return name:match(n)
      end)
    end

  return vim.api.nvim_buf_call(opts.bufnr, function()
    return vim
      .iter(
        vim.fn.synstack(
          vim.fn.line('.'),
          vim.fn.col('.') - (vim.startswith(vim.fn.mode(), 'i') and 1 or 0)
        )
      )
      :rev()
      :take(opts.depth)
      :find(function(id)
        return check_name_match(vim.fn.synIDattr(id, 'name')) and id
      end)
  end)
end

return M
