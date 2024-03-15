local M = {}

---Run a function multiple times and print the average time
---@param epochs integer? default to 128
---@param fn function
---@vararg any arguments to pass to the function
---@return number average time in nanoseconds
---@return number total time in nanoseconds
function M.time(epochs, fn, ...)
  epochs = epochs or 128
  local start = vim.uv.hrtime()
  for _ = 1, epochs do
    fn(...)
  end
  local total = vim.uv.hrtime() - start
  return total / epochs, total
end

---Run a function multiple times and print the average time and total time
---@param epochs integer?
---@param name string
---@param fn function
---@vararg any arguments to pass to the function
function M.benchmark(epochs, name, fn, ...)
  local time_avg, time_total = M.time(epochs, fn, ...)
  print(string.format("%s: %d epochs, %f ns/epoch, %f ns total", name, epochs, time_avg, time_total))
end

return M
