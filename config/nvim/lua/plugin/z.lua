local M = {}

---HACK: if the last element is a full path, only use it instead of all arguments
---as arguments for `z` command
---This is because nvim completion only works for single word and when multiple
---args are given to `:Z`, e.g. `:Z foo bar`, hitting tab will complete it as
---`:Z foo /foo/bar/baz`, assuming `/foo/bar/baz` is in z's database
---Without this trick 'foo /foo/bar/baz' will be passed to `z -e` shell command
---to get the best matching path, which is of course empty
---@param args? string[]
---@return string[]
local function z_args_norm(args)
  if not args then
    return {}
  end

  local last_arg = args[#args]
  return last_arg
      and require('utils.fs').is_full_path(last_arg)
      and { last_arg }
    or args
end

---Given a list of args for `z`, return its corresponding escaped string to be
---used as a shell command argument
---@param args? string|string[]
---@return string
local function z_args_esc(args)
  if type(args) ~= 'table' then
    args = { args }
  end
  if vim.tbl_isempty(args) then
    return ''
  end

  return table.concat(
    vim.tbl_map(function(path)
      return vim.fn.shellescape(vim.fn.expand(path))
    end, z_args_norm(args)),
    ' '
  )
end

---@class z.cmd
---@field jump fun(trig?: string[]): string[]
---@field list fun(trig?: string[]): string[]
---@field add fun(dir: string): string[]

---@alias z.backend { cmd: z.cmd, exists: fun(): boolean }
---@type table<string, z.backend>
local z_backends = {
  z = {
    exists = function()
      return vim.env.SHELL
        and vim.fn.executable(vim.env.SHELL) == 1
        and vim.system({ vim.env.SHELL, '-c', 'type z' }):wait().code == 0
    end,
    cmd = {
      jump = function(trig)
        return { vim.env.SHELL, '-c', 'z -e ' .. z_args_esc(trig) }
      end,
      list = function(trig)
        return { vim.env.SHELL, '-c', 'z -l ' .. z_args_esc(trig) }
      end,
      add = function(dir)
        return { vim.env.SHELL, '-c', 'cd ' .. z_args_esc(dir) }
      end,
    },
  },
  zoxide = {
    exists = function()
      return vim.fn.executable('zoxide') == 1
    end,
    cmd = {
      jump = function(trig)
        return { 'zoxide', 'query', unpack(z_args_norm(trig)) }
      end,
      list = function(trig)
        return { 'zoxide', 'query', '-l', unpack(z_args_norm(trig)) }
      end,
      add = function(dir)
        return { 'zoxide', 'add', dir }
      end,
    },
  },
}

---@type z.backend
local z = (function()
  for _, backend in pairs(z_backends) do
    if backend.exists() then
      return backend
    end
  end

  return {
    exists = function()
      return false
    end,
    cmds = setmetatable({}, {
      __index = function()
        return function()
          vim.notify_once(
            '[z] `z` command not available\n',
            vim.log.levels.WARN
          )
          return { vim.env.SHELL, '-c', 'exit' }
        end
      end,
    }),
  }
end)()

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
    -- HACK: use string manipulation to get all args after the command instead
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
function M.jump(input)
  ---@diagnostic disable-next-line: need-check-nil
  vim.system(z.cmd.jump(input), { text = true }, function(obj)
    if obj.code ~= 0 then
      vim.schedule(function()
        vim.notify('[z] ' .. (obj.stderr or obj.stdout))
      end)
      return
    end

    local path = vim.trim(vim.gsplit(obj.stdout, '\n')() or '')
    vim.uv.fs_stat(path, function(_, stat)
      if not stat then
        return
      end
      -- Schedule to allow oil.nvim to conceal line headers correctly
      local path_escaped = vim.fn.fnameescape(path)
      vim.schedule(function()
        vim.cmd.edit(path_escaped)
        vim.cmd.lcd({ path_escaped, mods = { silent = true } })
      end)
    end)
  end)
end

---List matching z directories given input
---@param input string[]?
---@return string[]
function M.list(input)
  ---@diagnostic disable-next-line: need-check-nil
  local o = vim.system(z.cmd.list(input)):wait()
  if o.code ~= 0 then
    vim.notify('[z] ' .. o.stderr or o.stdout)
    return {}
  end

  return vim
    .iter(vim.gsplit(o.stdout, '\n', { trimempty = true }))
    :map(function(line)
      return line:match('^[0-9.]*%s*(.*)')
    end)
    :totable()
end

---Select and jump to z directories using `vim.ui.select()`
---@param input string[]?
function M.select(input)
  vim.ui.select(
    M.list(input),
    { prompt = 'Open directory: ' },
    function(dir) ---@param dir string?
      if not dir then
        return
      end
      M.jump({ dir })
    end
  )
end

---Setup `:Z` command
function M.setup()
  if vim.g.loaded_z then
    return
  end
  vim.g.loaded_z = true

  vim.api.nvim_create_user_command('Z', cmd(M.jump), {
    desc = 'Open a directory from z.',
    complete = cmp('Z'),
    nargs = '*',
  })
  vim.api.nvim_create_user_command('ZSelect', cmd(M.select), {
    desc = 'Open a directory from z interactively.',
    complete = cmp('ZSelect'),
    nargs = '*',
  })

  if z.exists() then
    vim.api.nvim_create_autocmd('DirChanged', {
      desc = 'Record nvim path in z.',
      group = vim.api.nvim_create_augroup('my.z.record_dir', {}),
      callback = function(args)
        local dir = args.file
        vim.system(z.cmd.add(dir))
        if cmp_list_cache and not vim.tbl_contains(cmp_list_cache, dir) then
          cmp_list_cache = nil
        end
      end,
    })
  end
end

return M
