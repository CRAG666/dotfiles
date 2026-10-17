---@param opts table<string, boolean|number|string>
---@param undo? string
return function(opts, undo)
  local reset = {}
  for name, value in pairs(opts) do
    if
      vim.b.bigfile
      and (name == 'spell' or name == 'wrap' or name == 'breakindent')
    then
      value = false
    end
    vim.opt_local[name] = value
    reset[#reset + 1] = name .. '<'
  end

  local commands = 'setlocal ' .. table.concat(reset, ' ')
  if undo then
    commands = commands .. ' | ' .. undo
  end
  if vim.b.undo_ftplugin and vim.b.undo_ftplugin ~= '' then
    commands = vim.b.undo_ftplugin .. ' | ' .. commands
  end
  vim.b.undo_ftplugin = commands
end
