local M = {}

---@class dapcache_t
---@field progs table<string, string> maps source file path to program path
---@field args table<string, string> maps source file path to arguments

---Create a new cache table for DAP program paths and arguments
---@return dapcache_t
function M.new_cache()
  return {
    progs = {},
    args = {},
  }
end

---Returns a function that gets arguments for the current buffer, using cached
---arguments if arguments are provided before
---@param cache dapcache_t
---@return fun(): string[]?
function M.get_args(cache)
  return function()
    local bufname = vim.api.nvim_buf_get_name(0)

    vim.ui.input({
      prompt = 'Enter arguments: ',
      completion = 'file',
      default = cache.args[bufname],
    }, function(input)
      if input and input ~= '' then
        cache.args[bufname] = input
      end
      vim.cmd.stopinsert()
    end)

    return cache.args[bufname]
      and require('utils.cmd').split(cache.args[bufname])
  end
end

---Return a function that gets the path to the executable for the current
---buffer, using cached executable path when possible
---@param cache dapcache_t
---@return fun(): string?
function M.get_prog(cache)
  return function()
    local bufname = vim.api.nvim_buf_get_name(0)

    vim.ui.input({
      prompt = 'Enter path to executable: ',
      completion = 'file',
      default = (function()
        local prog = cache.progs[bufname]
        if prog then
          return prog
        end

        local cwd = vim.fn.getcwd(0)
        local progs = vim.fs.find({
          vim.fn.fnamemodify(bufname, ':t:r'),
          vim.fn.fnamemodify(cwd, ':t'),
        }, {
          path = vim.fn.fnamemodify(bufname, ':p:h'),
          upward = true,
        })
        return progs[1] or cwd
      end)(),
    }, function(input)
      cache.progs[bufname] = input
      vim.cmd.stopinsert()
    end)

    return cache.progs[bufname]
  end
end

return M
