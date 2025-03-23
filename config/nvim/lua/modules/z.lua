local M = {}

---Check if `z` command is available
---@return boolean
local function has_z()
  if vim.g._z_installed then
    return true
  end

  if vim.system({ vim.env.SHELL, '-c', 'type z' }):wait().code == 0 then
    vim.g._z_installed = true
    return true
  end

  vim.notify_once('[z] `z` command not available\n', vim.log.levels.WARN)
  return false
end

---Given a list of args for `z`, return its corresponding escaped string to be
---used as a shell command argument
---@param args string[]?
---@return string
local function argesc(args)
  if not args then
    return ''
  end

  -- HACK: if the last element is a full path, only use it instead of all arguments
  -- as arguments for `z` command
  -- This is because nvim completion only works for single word and when multiple
  -- args are given to `:Z`, e.g. `:Z foo bar`, hitting tab will complete it as
  -- `:Z foo /foo/bar/baz`, assuming `/foo/bar/baz` is in z's database
  -- Without this trick 'foo /foo/bar/baz' will be passed to `z -e` shell command
  -- to get the best matching path, which is of course empty
  local last_arg = args[#args]
  if last_arg and require('utils.fs').is_full_path(last_arg) then
    return vim.fn.shellescape(last_arg)
  end

  return table.concat(
    vim.tbl_map(function(path)
      return vim.fn.shellescape(vim.fn.expand(path))
    end, args),
    ' '
  )
end

local cmp_args_cache ---@type string?
local cmp_list_cache ---@type string[]?

---Return a complete function for given z command
---@param cmd string
---@return function
local function cmp(cmd)
  local cmd_reg = string.format('.*%s%%s+', cmd)
  ---@param cmdline string the entire command line
  ---@param cursorpos integer cursor position in the command line
  ---@return string[] completion completion results
  return function(_, cmdline, cursorpos)
    -- HACK: use sting manipulation to get all args after the command instead
    -- of using `arglead` (only the last argument before cursor) to make the
    -- completion for multiple arguments just link `z` in shell
    -- e.g. if paths `/foo/bar` and `/baz/bar` are in z's database, then
    -- `z foo bar` should only complete `/foo/bar` instead of both (using
    -- both 'foo' and 'bar' to match)
    -- TODO: only split on spaces that are not escaped
    local argslead = cmdline:sub(1, cursorpos):gsub(cmd_reg, '')
    local trigs = vim.split(argslead, ' ', { trimempty = true })

    -- Avoid calling `z` on each keystroke when auto completion is enabled
    if
      cmp_args_cache
      and cmp_list_cache
      and vim.startswith(argslead, cmp_args_cache)
    then
      return vim
        .iter(cmp_list_cache)
        :filter(function(path)
          return vim.iter(trigs):all(function(trig)
            return path:find(trig, 1, true)
          end)
        end)
        :totable()
    end

    cmp_args_cache = argslead
    cmp_list_cache = M.list(trigs)
    return cmp_list_cache
  end
end

---Return a command function
---@param cb fun(fargs: string[])
---@return function
local function cmd(cb)
  return function(args)
    cb(args.fargs)
  end
end

---Change directory to the most frequently visited directory using `z`
---@param input string[]
function M.z(input)
  if not has_z() then
    return
  end

  vim.system(
    { vim.env.SHELL, '-c', 'z -e ' .. argesc(input) },
    { text = true },
    function(obj)
      if obj.code ~= 0 then
        vim.schedule(function()
          vim.notify('[z] ' .. (obj.stderr or obj.stdout))
        end)
        return
      end

      local output = vim.trim(obj.stdout)
      local path_escaped = vim.fn.fnameescape(output)

      -- Schedule to allow oil.nvim to conceal line headers correctly
      vim.schedule(function()
        vim.cmd.edit(path_escaped)
        vim.cmd.lcd({ path_escaped, mods = { silent = true } })
      end)
    end
  )
end

---List matching z directories given input
---@param input string[]?
---@return string[]
function M.list(input)
  if not has_z() then
    return {}
  end

  local o =
    vim.system({ vim.env.SHELL, '-c', 'z -l ' .. argesc(input) }):wait()
  if o.code ~= 0 then
    vim.notify('[z] ' .. o.stderr or o.stdout)
    return {}
  end

  return vim
    .iter(vim.gsplit(o.stdout, '\n', { trimempty = true }))
    :map(function(line)
      return line:match('^[0-9.]+%s+(.*)')
    end)
    :totable()
end

---Select and jump to z directories using `vim.ui.select()`
---@param input string[]?
function M.select(input)
  if not has_z() then
    return
  end

  vim.ui.select(
    M.list(input),
    { prompt = 'Open directory: ' },
    function(dir) ---@param dir string?
      if not dir then
        return
      end
      M.z({ dir })
    end
  )
end

---Setup `:Z` command
function M.setup()
  if vim.g.loaded_z then
    return
  end
  vim.g.loaded_z = true

  vim.api.nvim_create_user_command('Z', cmd(M.z), {
    desc = 'Open a directory from z.',
    complete = cmp('Z'),
    nargs = '*',
  })
  vim.api.nvim_create_user_command('ZSelect', cmd(M.select), {
    desc = 'Open a directory from z interactively.',
    complete = cmp('ZSelect'),
    nargs = '*',
  })

  vim.api.nvim_create_autocmd('DirChanged', {
    desc = 'Record nvim path in z.',
    group = vim.api.nvim_create_augroup('ZRecordDir', {}),
    callback = function(info)
      local dir = info.file
      vim.system({ vim.env.SHELL, '-c', 'cd ' .. vim.fn.shellescape(dir) })
      if cmp_list_cache and not vim.tbl_contains(cmp_list_cache, dir) then
        cmp_list_cache = nil
      end
    end,
  })
end

return M
