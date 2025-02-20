local M = {}

---@param names string|string[]|fun(types: string|string[]): boolean type of node, or function to check node type
---@return boolean
function M.in_group(names)
  if not vim.b.current_syntax then
    return false
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

  return vim
    .iter(
      vim.fn.synstack(
        vim.fn.line('.'),
        vim.fn.col('.') - (vim.startswith(vim.fn.mode(), 'i') and 1 or 0)
      )
    )
    :map(function(id)
      return vim.fn.synIDattr(id, 'name')
    end)
    :any(check_name_match)
end

return M
