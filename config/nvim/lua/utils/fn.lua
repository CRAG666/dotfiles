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

--- Carga un módulo de forma perezosa en uno o más eventos de autocomando.
--
-- Inspirado en la forma en que lazy.nvim maneja los eventos, esta función
-- crea un grupo de autocomandos temporales que, al activarse, cargan tu
-- función y luego se auto-eliminan (por defecto).
--
-- @param events (string|table) El evento o lista de eventos que activarán la carga.
-- @param mod_name (string) Un nombre para el módulo, usado en notificaciones y para el grupo.
-- @param load_fn (function) La función a ejecutar cuando el evento ocurra.
-- @param opts (table|nil) Opciones adicionales:
--   - pattern (string|table): Patrón para el autocomando (por defecto '*').
--   - once (boolean): Si es `true` (por defecto), el grupo de autocomandos se elimina después de la primera ejecución.
--   - desc (string): Descripción para el autocomando.
--
function M.lazy_load(events, mod_name, load_fn, opts)
  -- Validación de entradas más estricta
  if not (events and mod_name and load_fn) then
    error(
      "lazy_load: los parámetros 'events', 'mod_name', y 'load_fn' son requeridos.",
      2
    )
  end

  opts = opts or {}

  local event_list = type(events) == 'string' and { events } or events
  local group_name = 'LazyLoad_' .. mod_name
  local group_id = vim.api.nvim_create_augroup(group_name, { clear = true })
  local loaded = false

  -- La función callback que se ejecutará
  local callback = function()
    -- 💡 Previene ejecuciones múltiples si varios eventos se disparan rápidamente
    if loaded then
      return
    end
    loaded = true
    load_fn()
    -- 💡 Por defecto, limpia el grupo de autocomandos para evitar ejecuciones futuras.
    -- Esto ahora funciona correctamente para múltiples eventos.
    if opts.once ~= false then
      vim.schedule(function()
        pcall(vim.api.nvim_del_augroup_by_id, group_id)
      end)
    end
  end

  -- Crea un autocomando para cada evento especificado
  for _, event in ipairs(event_list) do
    vim.api.nvim_create_autocmd(event, {
      group = group_id,
      pattern = opts.pattern,
      callback = callback,
      desc = opts.desc or ('Lazy load: ' .. mod_name),
    })
  end
end

return M
