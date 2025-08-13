local M = {}

function M.setup(modname, opts)
  return function()
    require(modname).setup(opts)
  end
end

function M.get_file_hash(file_path)
  local handle = io.popen('sha256sum ' .. file_path .. ' 2>/dev/null')
  if handle then
    local result = handle:read('*a')
    handle:close()
    -- Extraer el hash de la salida (primera parte antes del espacio)
    return result:match('^%w+')
  else
    return nil
  end
end

function M.lazy_load(events, mod_name, load_fn, opts)
  if not events or not load_fn then
    error('lazy_load: events y load_fn son requeridos')
  end

  local event_list = type(events) == 'string' and { events } or events

  opts = opts or {}
  local group_name = opts.group or ('LazyLoad_' .. mod_name)
  local pattern = opts.pattern or '*'
  local once = opts.once ~= false

  local group_id = vim.api.nvim_create_augroup(group_name, { clear = true })

  local loaded = false

  for _, event in ipairs(event_list) do
    vim.api.nvim_create_autocmd(event, {
      group = group_id,
      pattern = pattern,
      once = once,
      callback = function()
        if once and loaded then
          return
        end
        loaded = true
        vim.notify('Loading module', vim.log.levels.INFO, { title = mod_name })
        load_fn()
        if once and (opts.cleanup ~= false) then
          vim.schedule(function()
            pcall(vim.api.nvim_del_augroup_by_id, group_id)
          end)
        end
      end,
      desc = opts.desc or 'Lazy load plugin',
    })
  end

  return group_id
end

return M
