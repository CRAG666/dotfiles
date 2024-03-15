local M = {}

function M.has_width_gt(cols)
  -- Check if the windows width is greater than a given number of columns
  return vim.fn.winwidth(0) / 2 > cols
end

function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

function M.pmaps(mode, prefix, maps)
  mode = mode or "n"
  for _, map in pairs(maps) do
    local opts = { desc = map[3] }
    if map[4] then
      opts = vim.tbl_extend("force", opts, map[4])
    end
    M.map(mode, prefix .. map[1], map[2], opts)
  end
end

function M.maps(maps)
  for _, map in pairs(maps) do
    local mode = map.mode or "n"
    M.pmaps(mode, map.prefix, map.maps)
  end
end

return M
