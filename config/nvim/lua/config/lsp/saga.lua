local utils = require 'utils'
local opts = { noremap = true, silent = true }
local saga = require 'lspsaga'
saga.init_lsp_saga {
error_sign = '',
warn_sign = '',
hint_sign = '',
infor_sign = '',
-- dianostic_header_icon = '   ',
code_action_icon = 'ﯦ'
-- code_action_prompt = {
--   enable = true,
--   sign = true,
--   sign_priority = 20,
--   virtual_text = true,
-- },
-- finder_definition_icon = '  ',
-- finder_reference_icon = '  ',
-- max_preview_lines = 10, -- preview lines of lsp_finder and definition preview
-- finder_action_keys = {
--   open = 'o', vsplit = 's',split = 'i',quit = 'q',scroll_down = '<C-f>', scroll_up = '<C-b>' -- quit can be a table
-- },
-- code_action_keys = {
--   quit = 'q',exec = '<CR>'
-- },
-- rename_action_keys = {
--   quit = '<C-c>',exec = '<CR>'  -- quit can be a table
-- },
-- definition_preview_icon = '  '
-- "single" "double" "round" "plus"
-- border_style = "single"
-- rename_prompt_prefix = '➤',
-- if you don't use nvim-lspconfig you must pass your server name and
-- the related filetypes into this table
-- like server_filetype_map = {metals = {'sbt', 'scala'}}
-- server_filetype_map = {}
}
-- lspsaga
utils.map('n', 'gh', "<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>", opts)
utils.map('n', '<leader>ca', "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts)
utils.map('v', '<leader>ca', "<cmd>'<,'>lua require('lspsaga.codeaction').range_code_action()<CR>", opts)
utils.map('n', 'K', "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", opts)
utils.map('n', '<C-f>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", opts)
utils.map('n', '<C-b>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", opts)
utils.map('n', 'gs', "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", opts)
utils.map('n', '<leader>rn', "<cmd>lua require('lspsaga.rename').rename()<CR>", opts)
utils.map('n', '<leader>cd', "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>", opts)
utils.map('n', 'A-Left', "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>", opts)
utils.map('n', 'A-Right', "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>", opts)
-- utils.map('n', '<A-d>', "<cmd>lua require('lspsaga.floaterm').open_float_terminal()<CR>", opts)
-- utils.map('t', '<A-d>', "<C-\\><C-n>:lua require('lspsaga.floaterm').close_float_terminal()<CR>", opts)
