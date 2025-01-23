local M = {}

function M.setup(modname, opts)
  return function()
    require(modname).setup(opts)
  end
end

function M.telescope(builtin, opts)
  opts = opts or {}
  return function()
    require('telescope.builtin')[builtin](opts)
  end
end

function M.telescope_ext(builtin, opts)
  opts = opts or {}
  return function()
    require('telescope').extensions[builtin][builtin](opts)
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

return M
