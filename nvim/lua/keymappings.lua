local utils = require('utils')

utils.map('n', '<leader>c', "lua require('ts_context_commentstring.internal').update_commentstring()<cr>", {silent=true})
utils.map('i', 'jk', '<Esc>')           -- jk to escape
--AltGr p
utils.map('n', 'þ' ,':Clap filer<CR>', {silent = true })
utils.map('n', 'ł', ':Clap blines<CR>', {silent = true })
--AltGr .
utils.map('n', '·', ':Clap command<CR>', {silent = true })
utils.map('n', '<leader>f', ':Clap files<CR>', {silent = true })
utils.map('n', '<leader>fg', ':Clap gfiles<CR>', {silent = true })
utils.map('n', '<leader>g', ':Clap grep2<CR>', {silent = true })
utils.map('n', '<leader>h', ':Clap history<CR>', {silent = true })
utils.map('n', '<leader>b', ':Clap buffers<CR>', {silent = true })
utils.map('n', '<leader>y', ':Clap yanks<CR>', {silent = true })
--Python Docstring
vim.api.nvim_command([[autocmd FileType python nnoremap <buffer> <leader>pd :Pydocstring<CR>)]])
utils.map('n', 'tn', ':tabnew<CR>', {silent = true })
utils.map('n', 'to', ':tabonly<CR>', {silent = true })
utils.map('n', 'td', ':tabclose<CR>', {silent = true })
utils.map('n', 'tm', ':tabmove<CR>', {silent = true })
--commans tabs
utils.map('n', '<Leader><PageDown>', ':tabnext<cr>', {silent = true })
utils.map('n', '<Leader><PageUp>', ':tabprevious<cr>', {silent = true })
utils.map('n', '<c-]>', ':BufNext<cr>', {silent = true })
utils.map('n', '<c-[>', ':BufPrev<cr>', {silent = true })
utils.map('n', '<A-c>', ':bd<CR>', {silent = true })
utils.map('n', '<leader>t', ':ToggleBuftabline<cr>', {silent = true })
utils.map('n', '<leader>R', ':belowright 8split term://crlvc %<CR>', {silent = true })
-- Terminal open
-- utils.map('n', '<leader>t', ':split<CR>:ter<CR>:resize 8<CR>'
-- Resize pane
utils.map('n', '<leader><Right>', ':vertical resize +5<CR>', {silent = true })
utils.map('n', '<leader><Left>', ':vertical resize -5<CR>', {silent = true })
utils.map('n', '<leader><Up>', ':resize +5<CR>', {silent = true })
utils.map('n', '<leader><Down>', ':resize -5<CR>', {silent = true })
--Esc in terminal mode
--[[ utils.map('t', '<Esc>', '<C-\><C-n>', {silent = true })
utils.map('t', '<M-[>', '<Esc>', {silent = true })
utils.map('t', '<C-v><Esc>', '<Esc>', {silent = true }) ]]
--Move line to up or down
utils.map('n', '<A-Down>', ':m .+1<CR>==', { silent = true })
utils.map('n', '<A-Up>', ':m .-2<CR>==', {silent = true })
utils.map('i', '<A-Down>', '<Esc>:m .+1<CR>==gi', { silent = true })
utils.map('i', '<A-Up>', '<Esc>:m .-2<CR>==gi', { silent = true })
utils.map('v', '<A-Down>', ":m '>+1<CR>gv=gv", {silent = true})
utils.map('v', '<A-Up>', ":m '<-2<CR>gv=gv", {silent = true})
--Delete search result
utils.map('n', '<leader>v', ':let @/=""<cr>', {silent = true })

-- Leader for multi cursors
-- vim.g.VM_leader =
vim.g.VM_maps = {["Select All"] = 'æ'}
vim.g.fzf_tags_command = 'ctags -R'
-- let $FZF_DEFAULT_COMMAND = 'rg --files --hidden'
-- let $FZF_DEFAULT_COMMAND = 'rg --files'
--Clap map
vim.g.clap_provider_grep_opts = '--hidden -g "!.git/--"!__pycache__/"'
--AltGr l

-- utils.map('n', '<Leader><PageDown>' ':tabnext<cr>
-- utils.map('n', '<Leader><PageUp>' ':tabprevious<cr>
-- utils.map('n', <leader>1 1gt
-- utils.map('n', <leader>2 2gt
-- utils.map('n', <leader>3 3gt
-- utils.map('n', <leader>4 4gt
-- utils.map('n', <leader>5 5gt
-- utils.map('n', '<Leader><PageDown>' ':BufferLineCycleNext<CR>
-- utils.map('n', '<Leader><PageUP>' ':BufferLineCyclePrev<CR>
-- utils.map('n', '<c-p>' ':BufferLinePick<CR>
-- utils.map('n', <leader>1' ':lua require"bufferline".go_to_buffer(1)<CR>
-- utils.map('n', <leader>2' ':lua require"bufferline".go_to_buffer(2)<CR>
-- utils.map('n', <leader>3' ':lua require"bufferline".go_to_buffer(3)<CR>
-- utils.map('n', <leader>4' ':lua require"bufferline".go_to_buffer(4)<CR>
-- utils.map('n', <leader>5' ':lua require"bufferline".go_to_buffer(5)<CR>
-- utils.map('n',  '<leader>R', ':Lspsaga open_floaterm crlvc %<CR>', {silent = true })




