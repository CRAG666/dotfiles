local M = {}

---@class dap.cache
---@field progs table<string, string> maps source file path to program path
---@field args table<string, string> maps source file path to arguments

---Create a new cache table for DAP program paths and arguments
---@return dap.cache
function M.new_cache()
  return {
    progs = {},
    args = {},
  }
end

---Install directory of a mise tool, for adapters that are scripts, not binaries
---@param tool string
---@return string
function M.mise_where(tool)
  local out = vim.system({ 'mise', 'where', tool }, { text = true }):wait()
  if out.code ~= 0 then
    error(
      string.format('[utils.dap] `mise where %s` failed: %s', tool, out.stderr)
    )
  end
  return vim.trim(out.stdout)
end

---Prompt with `vim.ui.input()` inside the nvim-dap run coroutine, so async
---inputs (e.g. snacks.input) are awaited
---@param opts table `vim.ui.input()` options
---@param on_input fun(input: string): any maps the input to the option value
---@return thread
local function input_co(opts, on_input)
  return coroutine.create(function(dap_run_co)
    vim.ui.input(opts, function(input)
      vim.cmd.stopinsert()
      coroutine.resume(
        dap_run_co,
        input == nil and require('dap').ABORT or on_input(input)
      )
    end)
  end)
end

---Returns a function that prompts for the arguments of the current buffer,
---defaulting to the previous ones
---@param cache dap.cache
---@return fun(): thread
function M.get_args(cache)
  return function()
    local bufname = vim.api.nvim_buf_get_name(0)
    return input_co({
      prompt = 'Enter arguments: ',
      completion = 'file',
      default = cache.args[bufname],
    }, function(input)
      cache.args[bufname] = input
      return require('dap.utils').splitstr(input)
    end)
  end
end

---Return a function that prompts for the executable of the current buffer,
---defaulting to the previous one or a file named like the buffer or cwd
---@param cache dap.cache
---@return fun(): thread
function M.get_prog(cache)
  return function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local cwd = vim.fn.getcwd(0)
    return input_co({
      prompt = 'Enter path to executable: ',
      completion = 'file',
      default = cache.progs[bufname] or vim.fs.find({
        vim.fn.fnamemodify(bufname, ':t:r'),
        vim.fs.basename(cwd),
      }, {
        path = vim.fs.dirname(bufname),
        upward = true,
      })[1] or cwd,
    }, function(input)
      if input == '' then
        return require('dap').ABORT
      end
      cache.progs[bufname] = input
      return input
    end)
  end
end

return M
