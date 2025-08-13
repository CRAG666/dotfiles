local key = require('utils.keymap')

vim.pack.add({ { src = 'https://github.com/nvim-neotest/neotest' } })
vim.pack.add({ { src = 'https://github.com/nvim-neotest/nvim-nio' } })
vim.pack.add({ { src = 'https://github.com/mfussenegger/nvim-dap' } })

local opts = {
  adapters = {},
  status = { virtual_text = true },
  output = { open_on_run = true },
  quickfix = {
    open = function()
      vim.cmd('copen')
    end,
  },
}

local neotest_ns = vim.api.nvim_create_namespace('neotest')
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      -- Replace newline and tab characters with space for more compact diagnostics
      local message = diagnostic.message:gsub('
', ' '):gsub('	', ' '):gsub('%s+', ' '):gsub('^%s+', '')
      return message
    end,
  },
}, neotest_ns)

if opts.adapters then
  local adapters = {}
  for name, config in pairs(opts.adapters or {}) do
    if type(name) == 'number' then
      if type(config) == 'string' then
        config = require(config)
      end
      adapters[#adapters + 1] = config
    elseif config ~= false then
      local adapter = require(name)
      if type(config) == 'table' and not vim.tbl_isempty(config) then
        local meta = getmetatable(adapter)
        if adapter.setup then
          adapter.setup(config)
        elseif adapter.adapter then
          adapter.adapter(config)
          adapter = adapter.adapter
        elseif meta and meta.__call then
          adapter = adapter(config)
        else
          error('Adapter ' .. name .. ' does not support setup')
        end
      end
      adapters[#adapters + 1] = adapter
    end
  end
  opts.adapters = adapters
end

require('neotest').setup(opts)

key.map('n', ';t', '', { desc = '+Neotest' })
key.map('n', ';tt', function()
  require('neotest').run.run(vim.fn.expand('%'))
end, { desc = 'Run File (Neotest)' })
key.map('n', ';tT', function()
  require('neotest').run.run(vim.uv.cwd())
end, { desc = 'Run All Test Files (Neotest)' })
key.map('n', ';tr', function()
  require('neotest').run.run()
end, { desc = 'Run Nearest (Neotest)' })
key.map('n', ';tl', function()
  require('neotest').run.run_last()
end, { desc = 'Run Last (Neotest)' })
key.map('n', ';ts', function()
  require('neotest').summary.toggle()
end, { desc = 'Toggle Summary (Neotest)' })
key.map('n', ';to', function()
  require('neotest').output.open({ enter = true, auto_close = true })
end, { desc = 'Show Output (Neotest)' })
key.map('n', ';tO', function()
  require('neotest').output_panel.toggle()
end, { desc = 'Toggle Output Panel (Neotest)' })
key.map('n', ';tS', function()
  require('neotest').run.stop()
end, { desc = 'Stop (Neotest)' })
key.map('n', ';tw', function()
  require('neotest').watch.toggle(vim.fn.expand('%'))
end, { desc = 'Toggle Watch (Neotest)' })
key.map('n', ';td', function()
  require('neotest').run.run({ strategy = 'dap' })
end, { desc = 'Debug Nearest' })