local utils = require 'utils'

require'compe'.setup {
  enabled = true,
  autocomplete = true,
  debug = false,
  min_length = 1,
  preselect = 'enable',
  throttle_time = 80,
  source_timeout = 200,
  incomplete_delay = 400,
  max_abbr_width = 100,
  max_kind_width = 100,
  max_menu_width = 100,
  documentation = true,

  source = {
    path = true,
    treesitter = true,
    nvim_lsp = true,
    nvim_lua = true,
    buffer = true,
    tags = true,
    spell = false,
    calc = false,
    vsnip = true,
    tabnine = true
  }
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

vim.cmd [[
" Expand
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
]]
--[[ function EnableCompletion()
  -- Don't Enable Completion on these clap
  if vim.bo.filetype ~= 'clap_input' then
    vim.g.completion_enable_auto_popup = 1
    require'completion'.on_attach()
  end
end ]]

-- vim.api.nvim_command([[autocmd FileType clap_input let g:completion_enable_auto_popup = 0]])
-- vim.api.nvim_command([[autocmd BufEnter * lua EnableCompletion()]])
-- vim.api.nvim_command([[autocmd BufEnter * lua require'completion'.on_attach()]])

-- Use <Tab> and <S-Tab> to navigate through popup menu
--[[ utils.map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
utils.map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true}) ]]

local opts = { noremap = true, silent = true }
utils.map('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
utils.map('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
utils.map('n', 'ħ', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
utils.map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
-- utils.map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
utils.map('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
utils.map('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
utils.map('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
utils.map('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
utils.map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
utils.map('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
-- utils.map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
-- utils.map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
-- utils.map('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
-- utils.map('n', '<A-Left>', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
-- utils.map('n', '<A-Right>', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

