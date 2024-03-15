local M = {}

function M.setup(modname, opts)
  return function()
    require(modname).setup(opts)
  end
end

return M
