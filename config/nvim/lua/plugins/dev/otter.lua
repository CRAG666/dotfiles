local fn = require('utils.fn')
local utils = require('utils')

fn.lazy_load('FileType', 'otter', function()
  vim.pack.add({ 'https://github.com/jmbuhr/otter.nvim' })
  local ot = require('otter')

  -- Wrap `ot.activate()` in `pcall()` to suppress error when opening git diff
  -- for markdown files: 'Vim(append):Error executing lua callback: Vim:E95:
  -- Buffer with this name already exists'
  local ot_activate = ot.activate

  function ot.activate(...)
    pcall(ot_activate, ...)
  end

  ot.setup({
    verbose = { no_code_found = false },
    buffers = { set_filetype = true },
    lsp = {
      root_dir = function()
        return utils.fs.root() or vim.fn.getcwd(0)
      end,
    },
  })
end, { pattern = { 'markdown', 'norg', 'org' } })

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Activate otter for filetypes with injections.',
  group = vim.api.nvim_create_augroup('OtterActivate', {}),
  pattern = { 'markdown', 'norg', 'org' },
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].ma and utils.ts.is_active(buf) then
      -- Enable completion only, disable diagnostics
      require('otter').activate(nil, nil, false)
    end
  end,
})
