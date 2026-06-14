local M = {}

---Get test command string from vim-test
---@return string?
function M.get_test_cmd()
  if vim.fn.exists(':TestNearest') ~= 2 then
    vim.notify(
      '[utils.test] vim-test is required to determine test command',
      vim.log.levels.WARN
    )
    return
  end

  -- Register custom strategy to get test cmd from vim-test
  local strategies = vim.g['test#custom_strategies'] or {}
  if not strategies.capture then
    strategies.capture = function(cmd)
      _G._test_cmd = nil
      _G._test_cmd = cmd
    end
    vim.g['test#custom_strategies'] = strategies
  end

  -- Save & restore some global states to avoid side effects
  local test_last_cmd = vim.g['test#last_command']
  local test_last_strategy = vim.g['test#last_strategy']

  -- Actually get the test cmd
  vim.cmd.TestNearest('-strategy=capture')

  vim.g['test#last_command'] = test_last_cmd
  vim.g['test#last_strategy'] = test_last_strategy

  return _G._test_cmd
end

return M
