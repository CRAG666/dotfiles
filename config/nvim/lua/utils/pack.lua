local M = {}

---@class pack.structured_spec.data
---Mark plugin as optional
---
---Plugins marked as optional will not be installed, managed or enabled unless
---there's another spec for the same plugin with `optional=nil` or
---`optional=false`
---
---Useful for optional dependencies and plugins that are only used under
---specific conditions
---@field optional? boolean
---@field deps? pack.spec|pack.spec[] Dependencies of the plugin, always loaded **before** the main plugin
---@field exts? pack.spec|pack.spec[] Extensions of the plugin, always loaded **after** the main plugin
---Build command for the plugin, useful for plugins that need
---compilation/building steps, can be a string, a list of string, or a function
---
---If it is a string with ':' prefix, `build` is treated as a vim command,
---otherwise it is treated as a sh command and executed with `sh -c`
---
---If it is a list of string, it is treated as a command following by its
---arguments
---
---If a function is provided, the function is called with the plugin spec and
---path to build the plugin
---@field build? string|string[]|fun(spec: pack.spec, path: string)
---@field init? fun(spec: pack.spec, path: string) Function to call at startup to setup the plugin
---Custom loader for the plugin
---
---When specified, `preload` and `postload` will not execute unless explicitly
---called in `loader`. The loader is fully responsible for loading the plugin
---and handling pre/post-load callbacks
---@field load? fun(spec: pack.spec, path: string)
---@field preload? fun(spec: pack.spec, path: string) Function to execute before loading the plugin
---@field postload? fun(spec: pack.spec, path: string) Function to execute after loading the plugin
---Mark the plugin as lazy-loaded
---
---Unlike non-lazy plugins that are loaded on startup, lazy-loaded plugins can
---be loaded on specific keys, events, commands, or manually using
---`utils.pack.load()`
---@field lazy? boolean
---Whether the plugin is registered as a dependency/extension of another plugin
---Plugins that are both explicitly registered as stand-alone and as deps/exts
---have `asdeps=false`
---@field asdeps? boolean
---@field keys? load.key.spec|load.key.spec[] Keys that lazy-load the plugin
---@field events? load.event.spec|load.event.spec[] Events that lazy-load the plugin
---@field cmds? load.cmd.spec|load.cmd.spec[] Commands that lazy-load the plugin

---Extended pack spec with lazy-loading
---@class pack.structured_spec : vim.pack.Spec
---@field data? pack.structured_spec.data

---@alias pack.spec string|pack.structured_spec|vim.pack.Spec

---Merged plugin specs indexed by plugin src
---@type table<string, pack.structured_spec>
local specs_registry = {}

---Loaded plugins
---@type table<string, boolean>
local loaded = {}

---Plugins whose `init()` is already called
---@type table<string, boolean>
local initialized = {}

---Get plugin installation root dir
---@return string
function M.root()
  return vim.fs.joinpath(vim.fn.stdpath('data'), 'site/pack/core/opt')
end

---Get install path of a plugin given spec
---@param spec pack.spec
function M.path(spec)
  return vim.fs.joinpath(M.root(), vim.fs.basename(spec.name or spec.src))
end

---Load a plugin with init, pre/post hooks, dependencies etc.
---@param spec pack.spec
---@param path string
function M.load(spec, path)
  if type(spec) == 'string' then
    spec = { src = spec }
  end

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
    for _, dep in
      ipairs(spec.data.deps --[=[@as pack.spec[]]=])
    do
      local dep_spec = specs_registry[type(dep) == 'string' and dep or dep.src]
      M.load(dep_spec, M.path(dep_spec))
    end
  end

  -- Custom per-spec load function takes full control of loading that plugin,
  -- including running pre/post-loading hooks as only the custom loader
  -- knows when the plugin can be considered as 'loaded'
  if spec.data.load then
    spec.data.load(spec, path)
  else
    if spec.data.preload then
      spec.data.preload(spec, path)
    end

    pcall(vim.cmd.packadd, vim.fs.basename(path))

    if spec.data.postload then
      spec.data.postload(spec, path)
    end
  end

  -- Extensions should be loaded after current plugin
  if spec.data.exts then
    if not vim.islist(spec.data.exts) then
      spec.data.exts = { spec.data.exts }
    end
    for _, ext in
      ipairs(spec.data.exts --[=[@as pack.spec[]]=])
    do
      local ext_spec = specs_registry[type(ext) == 'string' and ext or ext.src]
      M.load(ext_spec, M.path(ext_spec))
    end
  end
end

---Lazy-load plugin for given plugin spec
---@param spec pack.spec
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
      M.load(spec, path)
    end)
    ::continue::
  end

  if not lazy and not (spec.data and spec.data.asdeps) then
    M.load(spec, path)
  end
end

---@class (partial) pack.structured_spec.opts : pack.structured_spec

---Add specified plugin spec with lazy-loading
---@param specs pack.spec|pack.spec[]
---@param default pack.structured_spec.opts? Default options to merge with the plugin spec table if the plugin is not registered
function M.register(specs, default)
  if not vim.islist(specs) then
    specs = { specs } ---@cast specs pack.spec[]
  end

  ---@cast specs pack.structured_spec[]
  for i, spec in ipairs(specs) do
    if type(spec) == 'string' then
      specs[i] = { src = spec }
    end
  end

  -- Set default fields in the spec, prepare for merging and registration
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

  -- Actual registration
  for _, spec in ipairs(specs) do
    -- First register dependencies/Extensions
    if spec.data then
      if spec.data.deps then
        M.register(spec.data.deps, {
          data = { asdeps = true },
        })
      end
      if spec.data.exts then
        M.register(spec.data.exts, {
          data = { asdeps = true },
        })
      end
    end

    -- Then register self
    local existing_spec = specs_registry[spec.src]
    local asdeps = existing_spec
      and existing_spec.data
      and existing_spec.data.asdeps
      and spec.data
      and spec.data.asdeps

    specs_registry[spec.src] =
      vim.tbl_deep_extend('force', existing_spec or default or {}, spec)

    -- `asdeps` in the existing and new spec should be `AND`ed together
    if specs_registry[spec.src].data then
      specs_registry[spec.src].data.asdeps = asdeps
    end
  end
end

---Maps from plugin spec src to building status
---@type table<string, boolean>
local built = {}

---Build plugin, e.g. build c/rust lib, install node dependencies, etc.
---comment
---@param spec pack.spec
---@param path string
function M.build(spec, path)
  if not spec.data or not spec.data.build or built[spec.src] then
    return
  end
  built[spec.src] = true

  vim.notify(string.format('[utils.pack] Building %s', spec.src))

  -- Build can be a function, a vim command (starting with ':'), or a shell
  -- command
  local success ---@type boolean
  local err ---@type string

  if vim.is_callable(spec.data.build) then
    success, err = pcall(spec.data.build --[[@as function]], spec, path)
  elseif
    vim.startswith(spec.data.build --[[@as string]], ':')
  then
    success, err = pcall(
      vim.cmd --[[@as function]],
      spec
        .data
        .build --[[@as string]]
        :gsub('^:', '')
    )
  else
    local o = vim
      .system(
        type(spec.data.build) == 'table' and spec.data.build
          or { 'sh', '-c', spec.data.build },
        { cwd = path }
      )
      :wait()
    success = o.code == 0
    err = o.stderr
  end

  if success then
    vim.notify(
      string.format('[utils.pack] Successfully built plugin %s', spec.src)
    )
  else
    vim.notify(
      string.format('[utils.pack] Error building plugin %s: %s', spec.src, err),
      vim.log.levels.ERROR
    )
  end
end

local pack_add = vim.pack.add

---Wrapper of `vim.pack.add()` that handles lazy-loading, dependencies, etc.
---via the `data` field
---@param specs pack.spec|pack.spec[]
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
