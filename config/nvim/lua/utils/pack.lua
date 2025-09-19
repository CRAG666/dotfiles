local M = {}

---Merged plugin specs indexed by plugin src
---@type table<string, vim.pack.Spec>
local specs_registry = {}

---Loaded plugins
---@type table<string, boolean>
local loaded = {}

---Plugins whose `init()` is already called
---@type table<string, boolean>
local initialized = {}

---Load a plugin with init, pre/post hooks, dependencies etc.
---@param spec vim.pack.Spec
---@param path? string
function M.load(spec, path)
  if spec.data and spec.data.optional then
    return
  end

  if loaded[spec.src] then
    return
  end
  loaded[spec.src] = true

  spec.data = spec.data or {}

  -- Dependencies must be loaded before current plugin
  if spec.data.deps then
    if not vim.islist(spec.data.deps) then
      spec.data.deps = { spec.data.deps }
    end
    for _, dep in ipairs(spec.data.deps) do
      M.load(specs_registry[type(dep) == 'string' and dep or dep.src])
    end
  end

  -- Custom per-spec load function takes full control of loading that plugin,
  -- including running pre/post-loading hooks as only the custom loader
  -- knows when the plugin can be considered as 'loaded'
  if spec.data.load then
    spec.data.load(spec, path)
    return
  end

  if spec.data.preload then
    spec.data.preload()
  end

  pcall(vim.cmd.packadd, vim.fs.basename(spec.src))

  if spec.data.postload then
    spec.data.postload()
  else
    local ok, plugin = pcall(
      require,
      vim.fs
        .basename(spec.name or spec.src)
        :lower()
        :gsub('%.nvim$', '')
        :gsub('%.', '-')
    )
    if ok and type(plugin) == 'table' and plugin.setup then
      pcall(plugin.setup)
    end
  end
end

---Lazy-load plugin for given plugin spec
---@param spec vim.pack.Spec
---@param path string
function M.lazy_load(spec, path)
  spec.data = spec.data or {}

  if spec.data.init and not initialized[spec.src] then
    spec.data.init(spec, path)
    initialized[spec.src] = true
  end

  ---Whether the plugin is lazy-loaded
  ---Some plugin may set `spec.data.lazy` to `true` without setting
  ---cmd/key/event triggers to serve as a 'library'
  local lazy = spec.data.lazy

  for _, trig in ipairs({ 'cmds', 'keys', 'events' }) do
    if not spec.data[trig] then
      goto continue
    end
    lazy = true
    require('utils.load')['on_' .. trig](spec.data[trig], spec.src, function()
      M.load(spec)
    end)
    ::continue::
  end

  if not lazy then
    M.load(spec)
  end
end

---Add specified plugin spec with lazy-loading
---@param specs string|vim.pack.Spec|(string|vim.pack.Spec)[]
function M.register(specs)
  if not vim.islist(specs) then
    specs = { specs } ---@cast specs (string|vim.pack.Spec)[]
  end

  ---@cast specs vim.pack.Spec[]
  for i, spec in ipairs(specs) do
    if type(spec) == 'string' then
      specs[i] = { src = spec }
    end
  end

  for _, spec in ipairs(specs) do
    local existing_spec = specs_registry[spec.src]

    -- A plugin can flagged as an optional dependency of other plugins
    -- Optional plugins will not be installed and configured unless there's
    -- another spec for the same plugin without `data.optional` or with
    -- `data.optional` being `false`
    local optional = spec.data
      and spec.data.optional
      and (
        not existing_spec
        or existing_spec.data and existing_spec.data.optional
      )

    if not optional then
      spec.data = spec.data or {}
      spec.data.optional = false
    end
  end

  for _, spec in ipairs(specs) do
    if spec.data and spec.data.deps then
      M.register(spec.data.deps)
    end
    specs_registry[spec.src] =
      vim.tbl_deep_extend('force', specs_registry[spec.src] or {}, spec)
  end
end

---Maps from plugin spec src to building status
---@type table<string, boolean>
local building = {}

---Build plugin, e.g. build c/rust lib, install node dependencies, etc.
---comment
---@param spec vim.pack.Spec
---@param path string
---@param notify? boolean default to `true`
function M.build(spec, path, notify)
  if not spec.data or not spec.data.build or building[spec.src] then
    return
  end
  building[spec.src] = true

  notify = notify ~= false
  if notify then
    vim.notify(string.format('[utils.pack] Building %s', spec.src))
  end

  -- Build can be a function, a vim command (starting with ':'), or a shell
  -- command
  if vim.is_callable(spec.data.build) then
    spec.data.build(spec, path)
    return
  end

  if
    type(spec.data.build) == 'string'
    and vim.startswith(spec.data.build, ':')
  then
    vim.cmd(spec.data.build:gsub('^:', ''))
    return
  end

  local o = vim
    .system(
      type(spec.data.build) == 'table' and spec.data.build
        or { 'sh', '-c', spec.data.build },
      { cwd = path }
    )
    :wait()
  if o.code ~= 0 then
    vim.notify(
      string.format(
        '[utils.pack] Error building plugin %s (exited with code %d): %s',
        spec.src,
        o.code,
        o.stderr
      ),
      vim.log.levels.ERROR
    )
  end
end

local pack_add = vim.pack.add

---Wrapper of `vim.pack.add()` that handles lazy-loading, dependencies, etc.
---via the `data` field
---@param specs string|vim.pack.Spec|(string|vim.pack.Spec)[]
function M.add(specs)
  M.register(specs)

  -- Set autocmd to build plugin on pack changed (installed/updated)
  vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('my.pack.build', { clear = false }),
    callback = function(args)
      if args.data.kind == 'delete' then
        return
      end
      M.build(args.data.spec, args.data.path)
    end,
  })

  specs = {}
  for _, spec in pairs(specs_registry) do
    if not spec.data or not spec.data.optional then
      table.insert(specs, spec)
    end
  end

  -- `vim.pack.add()` throws error if previous confirm is denied
  -- This happens if installation of plugins under `start` is denied
  -- first, then plugin specs under `opt` is collected and managed
  pcall(pack_add, specs, {
    load = function(args)
      M.lazy_load(args.spec, args.path)
    end,
  })
end

return M
