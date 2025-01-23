local M = {}

---Check if `z` command is available
---@return boolean
local function has_z()
  if vim.g._z_installed then
    return true
  end

  vim.fn.system('z')
  if vim.v.shell_error == 0 then
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
local function get_arg_str(args)
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

---Change directory to the most frequently visited directory using `z`
---@param input string[]
function M.z(input)
  if not has_z() then
    return
  end

  local output = vim.trim(vim.fn.system('z -e ' .. get_arg_str(input)))
  if vim.v.shell_error ~= 0 then
    vim.notify('[z] ' .. output)
    return
  end

  vim.cmd.lcd(vim.fn.fnameescape(output))
end

---List matching z directories given input
---@param input string[]?
---@return string[]
function M.list(input)
  if not has_z() then
    return {}
  end

  local output = vim.fn.systemlist('z -l ' .. get_arg_str(input))
  if vim.v.shell_error ~= 0 then
    vim.notify('[z] ' .. output)
    return {}
  end

  local paths = {}
  for _, candidate in ipairs(output) do
    local path = candidate:match('^[0-9.]+%s+(.*)') -- trim score
    if path then
      table.insert(paths, path)
    end
  end
  return paths
end

---Return a complete function for given z command
---@param cmd string
---@return function
function M.cmp(cmd)
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
    -- TODO: only split on spaces that is not escaped
    return M.list(vim.split(cmdline:sub(1, cursorpos):gsub(cmd_reg, ''), ' '))
  end
end

---Select and jump to z directories using `vim.ui.select()`
---@param input string[]?
function M.select(input)
  if not has_z() then
    return
  end

  local paths = M.list(input)
  vim.ui.select(paths, {
    prompt = 'Change cwd to: ',
  }, function(choice)
    if choice then
      vim.cmd.lcd(vim.fn.fnameescape(choice))
    end
  end)
end

---Setup `:Z` command
function M.setup()
  if vim.g.loaded_z then
    return
  end
  vim.g.loaded_z = true

  vim.api.nvim_create_user_command('Z', function(args)
    M.z(args.fargs)
  end, {
    nargs = '*',
    desc = 'Change local working directory using z.',
    complete = M.cmp('Z'),
  })
  vim.api.nvim_create_user_command('ZSelect', function(args)
    M.select(args.fargs)
  end, {
    nargs = '*',
    desc = 'Pick from z directories with `vim.ui.select()`.',
    complete = M.cmp('ZSelect'),
  })
end

return M
