local M = {}

---@type table<string, boolean> plugins/modules loaded
local loaded = {}

---Load lua module for given filetype once
---@param ft string filetype to load, default to current buffer's filetype
---@param from string module to load from
---@param after_load fun(ft: string, ...)
function M.ft_load_once(ft, from, after_load)
  local mod_name = string.format('%s.%s', from, ft)
  if loaded[mod_name] then
    return
  end
  loaded[mod_name] = true

  local ok, mod = pcall(require, mod_name)
  if not ok then
    return
  end

  after_load(ft, mod)

  -- Only trigger FileType event when ft matches current buffer's ft, else
  -- it will mess up current buffer's hl and conceal
  if ft == vim.bo.ft then
    vim.api.nvim_exec_autocmds('FileType', { pattern = ft })
  end
end

---Automatically load filetype-specific lua file from given module once
---@param from string module to load from
---@param after_load fun(ft: string, ...)
function M.ft_auto_load_once(from, after_load)
  if loaded[from] then
    return
  end
  loaded[from] = true

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    M.ft_load_once(vim.bo[buf].ft, from, after_load)
  end

  vim.api.nvim_create_autocmd('FileType', {
    desc = string.format('Load for filetypes from %s lazily.', from),
    group = vim.api.nvim_create_augroup('my.ft_load.' .. from, {}),
    callback = function(args)
      M.ft_load_once(args.match, from, after_load)
    end,
  })
end

---Load vim plugin or lua module given `name`
---@param name string
function M.load(name)
  pcall(vim.cmd.packadd, name)
  pcall(require, name)
end

---@class (partial) load.event.structured_spec : vim.api.keyset.create_autocmd
---@field event string

---@alias load.event.spec load.event.structured_spec|string
---@alias load.event.handler fun(args: vim.api.keyset.create_autocmd.callback_args): boolean?

---Plugin loaders grouped by event, pattern, and buffers
---@type table<string, { all: load.event.handler[], pats: table<string, load.event.handler[]>, bufs: table<string, load.event.handler[]> }>
local event_loaders = vim.defaulttable()

---Helper function that returns a function as event callback to trigger
---loaders given by `loaders`
---@param loaders load.event.handler[]
---@return load.event.handler
local function trig_loaders_fn(loaders)
  return function(args)
    for i, loader in ipairs(loaders) do
      loader(args)
      loaders[i] = nil
    end
    vim.api.nvim_buf_call(args.buf, function()
      vim.api.nvim_exec_autocmds(
        args.event,
        { pattern = args.match, data = args.data }
      )
    end)
    return true
  end
end

---Load plugin once on given events
---@param event_specs load.event.spec|load.event.spec[] event/list of events to load the plugin
---@param name string unique name of the plugin, also used as a namespace to prevent setting duplicated lazy-loading handlers for the same plugin/module
---@param load? fun(args: vim.api.keyset.create_autocmd.callback_args) function to load the plugin
function M.on_events(event_specs, name, load)
  if loaded[name] then
    return
  end

  ---@param l? boolean|(fun(args: vim.api.keyset.create_autocmd.callback_args): boolean?)
  ---@return fun(args: vim.api.keyset.create_autocmd.callback_args)
  load = (function(l)
    ---Wrapped callback that deletes the loading augroup to avoid double loading
    ---and re-triggers event to execute event handlers in lazy-loaded plugins
    ---@param args vim.api.keyset.create_autocmd.callback_args
    return function(args)
      if loaded[name] then
        return
      end
      loaded[name] = true

      if l then
        l(args)
      else
        M.load(name)
      end
    end
  end)(load)

  -- Normalize `event_specs` to be a list of structured specs, e.g.
  -- {
  --   { event = ... },
  --   { event = ... },
  --   ...
  -- }
  ---@diagnostic disable-next-line: param-type-mismatch
  if not vim.islist(event_specs) then
    event_specs = { event_specs } ---@cast event_specs load.event.spec[]
  end
  for i, spec in ipairs(event_specs) do
    if type(spec) == 'string' then
      event_specs[i] = { event = spec }
    end
  end

  -- Register loader so that the group of loaders for the same event, pattern,
  -- and buffers are triggered once together
  ---@cast event_specs load.event.structured_spec[]
  for _, spec in ipairs(event_specs) do
    if spec.buffer then
      local loaders = event_loaders[spec.event].bufs[spec.buffer]
      if vim.tbl_isempty(loaders) then
        vim.api.nvim_create_autocmd(spec.event, {
          once = true,
          buffer = spec.buffer,
          group = vim.api.nvim_create_augroup(
            string.format(
              'my.load.on_events.event.%s.buf.%d',
              spec.event,
              spec.buffer
            ),
            {}
          ),
          callback = trig_loaders_fn(loaders),
        })
      end
      table.insert(loaders, load)
      goto continue
    end

    if spec.pattern then
      for _, pat in
        ipairs(
          type(spec.pattern) == 'table' and spec.pattern or { spec.pattern } --[[@as table]]
        )
      do
        local loaders = event_loaders[spec.event].pats[pat]
        if vim.tbl_isempty(loaders) then
          vim.api.nvim_create_autocmd(spec.event, {
            once = true,
            pattern = pat,
            group = vim.api.nvim_create_augroup(
              string.format(
                'my.load.on_events.event.%s.pat.%s',
                spec.event,
                pat
              ),
              {}
            ),
            callback = trig_loaders_fn(loaders),
          })
        end
        table.insert(loaders, load)
      end
      goto continue
    end

    -- Event spec does not specify buffer or pattern, `spec.loader` should be
    -- called whenever a matching event fires, thus register the loader to the
    -- `all` field
    do
      local loaders = event_loaders[spec.event].all
      if vim.tbl_isempty(loaders) then
        vim.api.nvim_create_autocmd(spec.event, {
          once = true,
          group = vim.api.nvim_create_augroup(
            string.format('my.load.on_events.event.%s', spec.event),
            {}
          ),
          callback = trig_loaders_fn(loaders),
        })
      end
      table.insert(loaders, load)
    end
    ::continue::
  end
end

---@alias load.cmd.spec string

---Load plugin once on given commands
---@param cmds load.cmd.spec|load.cmd.spec[] command/list of commands to load the plugin
---@param name string unique name of the plugin, also used as a namespace to prevent setting duplicated lazy-loading handlers for the same plugin/module
---@param load? function function to load the plugin
function M.on_cmds(cmds, name, load)
  if loaded[name] then
    return
  end

  if type(cmds) ~= 'table' then
    cmds = { cmds }
  end

  for _, cmd in ipairs(cmds) do
    local function load_cmd()
      pcall(vim.api.nvim_del_user_command, cmd)
      loaded[name] = true

      if load then
        load()
      else
        M.load(name)
      end
    end

    vim.api.nvim_create_user_command(cmd, function(call_args)
      load_cmd()

      -- Adapted from
      -- https://github.com/folke/lazy.nvim/blob/main/lua/lazy/core/handler/cmd.lua
      local cmd_info = vim.api.nvim_get_commands({})[cmd]
        or vim.api.nvim_buf_get_commands(0, {})[cmd]
      if not cmd_info then
        return
      end

      local cmd_call_spec = {
        cmd = cmd,
        bang = call_args.bang or nil,
        mods = call_args.smods,
        args = call_args.fargs,
        nargs = cmd_info.nargs,
        count = call_args.count >= 0
            and call_args.range == 0
            and call_args.count
          or nil,
        range = call_args.range == 1 and { call_args.line1 }
          or call_args.range == 2 and { call_args.line1, call_args.line2 }
          or nil,
      }

      if
        call_args.args
        and call_args.args ~= ''
        and cmd_info.nargs
        and cmd_info.nargs:find('[1?]')
      then
        cmd_call_spec.args = { call_args.args }
      end

      vim.cmd(cmd_call_spec)
    end, {
      bang = true,
      range = true,
      nargs = '*',
      complete = function(_, line)
        load_cmd()
        return vim.fn.getcompletion(line, 'cmdline')
      end,
    })
  end
end

---@class load.key.structured_spec
---@field mode? string|string[]
---@field lhs string
---@field opts? vim.keymap.set.Opts

---@alias load.key.spec load.key.structured_spec|string

---Mapping from plugin/module name to triggering keys
---@type table<string, load.key.spec[]>
local keys = {}

---Load plugin once on given keys
---@param key_specs load.key.spec|load.key.spec[]
---@param name string unique name of the plugin, also used as a namespace to prevent setting duplicated lazy-loading handlers for the same plugin/module
---@param load? function function to load the plugin
function M.on_keys(key_specs, name, load)
  if loaded[name] then
    return
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  if not vim.islist(key_specs) then
    key_specs = { key_specs } ---@cast key_specs load.key.spec[]
  end
  ---@cast key_specs load.key.structured_spec[]
  for i, spec in ipairs(key_specs) do
    if type(spec) == 'string' then
      key_specs[i] = { mode = { 'n' }, lhs = spec }
    else
      spec.mode = spec.mode or { 'n' }
      if not vim.islist(spec.mode) then
        spec.mode = {
          spec.mode --[[@as string]],
        }
      end
    end
  end

  if not keys[name] then
    keys[name] = {}
  end
  vim.list_extend(keys[name], key_specs)

  for _, spec in ipairs(key_specs) do
    local function rhs()
      if loaded[name] then
        return
      end
      loaded[name] = true

      -- Delete all key triggers associated with the plugin
      -- Some plugins, e.g. vim-conjoin, detects existing keys, and prepend
      -- its keymap before existing ones. When there are multiple key triggers
      -- for such plugin, the one that is not used as the initial trigger can
      -- has wrong definition
      for _, s in ipairs(keys[name] or {}) do
        local buf = s.opts and (s.opts.buffer == true and 0 or s.opts.buffer)
        if buf then
          for _, mode in
            ipairs(s.mode --[=[@as string[]]=])
          do
            pcall(vim.api.nvim_buf_del_keymap, buf, mode, s.lhs)
          end
        else
          for _, mode in
            ipairs(s.mode --[=[@as string[]]=])
          do
            pcall(vim.api.nvim_del_keymap, mode, s.lhs)
          end
        end
      end
      keys[name] = nil

      if load then
        load()
      else
        M.load(name)
      end

      vim.api.nvim_feedkeys(vim.keycode('<Ignore>' .. spec.lhs), 'i', false)
    end

    vim.keymap.set(
      spec.mode,
      spec.lhs,
      rhs,
      vim.tbl_deep_extend('force', spec.opts, {
        expr = true, -- make operator-pending mode work
      })
    )
  end
end

return M
