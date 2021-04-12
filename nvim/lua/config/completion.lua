local utils = require('utils')
local lspc = require 'lspconfig'
local saga = require 'lspsaga'
lspc.pyright.setup{}
lspc.elixirls.setup{}
require'lspkind'.init({})
saga.init_lsp_saga()

vim.g.completion_chain_complete_list = {
  default = {
  {complete_items = {'lsp', 'ts', 'snippet', 'tabnine', 'buffers'}},
  {mode = '<c-p>'},
  {mode = '<c-n>'}
}
}

function EnableCompletion()
  -- Don't Enable Completion on these clap
  if vim.bo.filetype ~= 'clap_input' then
    vim.g.completion_enable_auto_popup = 1
    require'completion'.on_attach()
  end
end

vim.api.nvim_command([[autocmd FileType clap_input let g:completion_enable_auto_popup = 0]])
vim.api.nvim_command([[autocmd BufEnter * lua EnableCompletion()]])

-- Use <Tab> and <S-Tab> to navigate through popup menu
utils.map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
utils.map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})

utils.map('n', 'gh', "<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>", {silent = true})
utils.map('n', '<leader>ca', "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", {silent = true})
utils.map('v', '<leader>ca', "<cmd>'<,'>lua require('lspsaga.codeaction').range_code_action()<CR>", {silent = true})
utils.map('n', 'K', "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", {silent = true})
utils.map('n', '<C-f>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", {silent = true})
utils.map('n', '<C-b>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", {silent = true})
utils.map('n', 'gs', "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", {silent = true})
utils.map('n', 'gr', "<cmd>lua require('lspsaga.rename').rename()<CR>", {silent = true})
utils.map('n', 'gD', "<cmd>lua require'lspsaga.provider'.preview_definition()<CR>", {silent = true})
utils.map('n', '<leader>cd', "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>", {silent = true})
utils.map('n', '[e', "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>", {silent = true})
utils.map('n', ']e', "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>", {silent = true})
utils.map('n', '<A-d>', "<cmd>lua require('lspsaga.floaterm').open_float_terminal()<CR>", {silent = true})
utils.map('t', '<A-d>', "<C-\\><C-n>:lua require('lspsaga.floaterm').close_float_terminal()<CR>", {silent = true})
