vim.bo.textwidth = 100
vim.opt_local.wrap = true
vim.bo.commentstring = '% %s'

local utils = require('code_runner.hooks.utils')
local root_files = {
  'Tectonic.toml',
  '.git',
}

local last_hash = nil

local function process_log_to_quickfix(log_file)
  local data = require('utils.fs').read_file(log_file)
  local lines = vim.split(data, '\n', { trimempty = true })

  local error_lines = {}
  local file_pattern = '%) %(([^)]+)%.tex'
  local error_pattern = '! (.+)'
  local line_pattern = 'l%.(%d+)'

  local i = #lines
  while i > 0 do
    local line = lines[i]:match(line_pattern)
    if line then
      local message, file_name
      for j = i - 1, 1, -1 do
        message = lines[j]:match(error_pattern)
        if message then
          for k = j - 1, 1, -1 do
            file_name = lines[k]:match(file_pattern)
            if file_name then
              i = k - 1
              break
            end
          end
          break
        end
      end

      if file_name and message then
        table.insert(error_lines, {
          filename = file_name .. '.tex',
          lnum = tonumber(line),
          text = message,
          type = 'E',
        })
      end
    end
    i = i - 1
  end

  if #error_lines > 0 then
    vim.fn.setqflist(
      {},
      'r',
      { title = 'Tectonic Errors', items = error_lines }
    )
    vim.cmd('copen')
  else
    vim.cmd('cclose')
    vim.fn.setqflist({}, 'r', { title = 'Tectonic Errors', items = {} })
  end
end

local iter = 1
local fn = require('utils.fn')
local root_path = nil
local log_file = nil
local pdf = nil
local function check_and_process_log()
  root_path = root_path or vim.lsp.buf.list_workspace_folders()[1]
  log_file = log_file or root_path .. '/build/default/default.log'
  local current_hash = fn.get_file_hash(log_file)
  last_hash = last_hash or current_hash
  if current_hash ~= last_hash then
    last_hash = current_hash
    process_log_to_quickfix(log_file)
  else
    if iter <= 3 then
      iter = iter + 1
      vim.defer_fn(check_and_process_log, 1500)
    else
      iter = 1
      vim.cmd('cclose')
      vim.fn.setqflist({}, 'r', { title = 'Tectonic Errors', items = {} })
      pdf = pdf or root_path .. '/build/default/default.pdf'
      if vim.uv.fs_stat(pdf) then
        utils.preview_open(pdf, '/bin/zathura')
      end
    end
  end
end

local texlab = {
  cmd = { 'texlab' },
  root_patterns = root_files,
  settings = {
    texlab = {
      rootDirectory = nil,
      build = {
        auxDirectory = 'build/default',
        logDirectory = 'build/default',
        pdfDirectory = 'build/default',
        filename = 'default.pdf',
        executable = 'tectonic',
        args = {
          '-X',
          'build',
          '--keep-logs',
          '--keep-intermediates',
        },
        onSave = true,
        forwardSearchAfter = true,
      },
      forwardSearch = {
        executable = 'zathura',
        args = { '--synctex-forward', '%l:1:%f', '%p' },
      },
      chktex = {
        onOpenAndSave = true,
        onEdit = true,
      },
      diagnosticsDelay = 300,
      latexFormatter = 'latexindent',
      latexindent = {
        ['local'] = nil,
        modifyLineBreaks = false,
      },
      bibtexFormatter = 'texlab',
      formatterLineLength = 80,
    },
  },
}

require('config.lsp').setup(texlab, function(client, bufnr)
  vim.api.nvim_create_autocmd('VimLeave', {
    callback = function()
      utils.preview_close()
    end,
  })

  local group =
    vim.api.nvim_create_augroup('TectonicPreview', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = group,
    pattern = '*.tex',
    callback = function()
      check_and_process_log()
    end,
  })
end)
