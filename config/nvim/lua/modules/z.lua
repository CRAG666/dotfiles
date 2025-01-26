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
local function argesc(args)
  if not args then
    return ''
  end

  -- HACK: if the last element is a directory, only use it instead of all
  -- arguments as arguments for `z` command
  -- This is because nvim completion only works for single word and when multiple
  -- args are given to `:Z`, e.g. `:Z foo bar`, hitting tab will complete it as
  -- `:Z foo /foo/bar/baz`, assuming `/foo/bar/baz` is in z's database
  -- Without this trick 'foo /foo/bar/baz' will be passed to `z -e` shell command
  -- to get the best matching path, which is of course empty
  local last_arg = args[#args]
  if last_arg and vim.fn.isdirectory(last_arg) == 1 then
    -- `last_arg` can be a relative path and may contain chars like '~' which
    -- is not recognized by `z`, so first convert it to absolute path
    -- Also need to trim trailing slashes using `vim.fs.normalize()` to make
    -- `z -e` happy
    return vim.fn.shellescape(
      vim.fs.normalize(vim.fn.fnamemodify(last_arg, ':p'))
    )
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

  local output = vim.trim(vim.fn.system('z -e ' .. argesc(input)))
  if vim.v.shell_error ~= 0 then
    vim.notify('[z] ' .. output)
    return
  end

  local path_escaped = vim.fn.fnameescape(output)
  -- Schedule to allow oil.nvim to conceal line headers correctly
  vim.schedule(function()
    vim.cmd.edit(path_escaped)
    vim.cmd.lcd({ path_escaped, mods = { silent = true } })
  end)
end

---List matching z directories given input
---@param input string[]?
---@return string[]
function M.list(input)
  if not has_z() then
    return {}
  end

  local output = vim.fn.systemlist('z -l ' .. argesc(input))
  if vim.v.shell_error ~= 0 then
    vim.notify('[z] ' .. output)
    return {}
  end

  local paths = {}
  for _, candidate in ipairs(output) do
    local path = candidate:match('^[0-9.]+%s+(.*)') -- trim score
    if path then
      table.insert(paths, vim.fn.fnamemodify(path, ':~:.'))
    end
  end
  return paths
end

---Select and jump to z directories using `vim.ui.select()`
---@param input string[]?
function M.select(input)
  if not has_z() then
    return
  end

  ---@param dir string?
  local function open_dir(dir)
    if not dir then
      return
    end
    local dir_escaped = vim.fn.fnameescape(dir)
    vim.schedule(function()
      vim.cmd.edit(dir_escaped)
      vim.cmd.lcd({ dir_escaped, mods = { silent = true } })
    end)
  end

  local dirs = M.list(input)
  local prompt = 'Open directory: '
  local has_fzf, fzf = pcall(require, 'fzf-lua')

  -- Fallback to `vim.ui.select()` if fzf-lua is not installed
  if not has_fzf then
    vim.ui.select(dirs, { prompt = prompt }, open_dir)
    return
  end

  -- Register as an fzf picker
  fzf.z = fzf.z
    or function(opts)
      fzf.fzf_exec(
        dirs,
        vim.tbl_deep_extend('force', {
          cwd = vim.fn.getcwd(0),
          prompt = prompt,
          actions = {
            ['enter'] = {
              fn = function(selection)
                open_dir(unpack(selection))
              end,
            },
          },
        }, opts)
      )
    end
  fzf.z()
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
end

return M
