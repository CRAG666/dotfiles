local M = {}

function M.setup(modname, opts)
  return function()
    require(modname).setup(opts)
  end
end

function M.telescope(builtin, opts)
  opts = opts or {}
  return function()
    require("telescope.builtin")[builtin](opts)
  end
end

function M.telescope_ext(builtin, opts)
  opts = opts or {}
  return function()
    require("telescope").extensions[builtin][builtin](opts)
  end
end

return M
