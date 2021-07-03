local utils = require('utils')
local opts = { noremap = true, silent = true }

utils.map('i', 'jk', '<Esc>')           -- jk to escape
utils.map('n', 'ø', ':Vexplore<CR>')           -- open explorer in vertical split

--Python Docstring
vim.cmd [[autocmd FileType python nnoremap <buffer> <leader>pd :Pydocstring<CR>]]

-- Tab mappings
utils.map('n',
          '<leader>t',
          [[:execute 'set showtabline=' . (&showtabline ==# 0 ? 2 : 0)<CR>]],
          opts)
utils.map('n', 'tn', ':tabnew<CR>', opts)
utils.map('n', 'to', ':tabonly<CR>', opts)
utils.map('n', 'td', ':tabclose<CR>', opts)
utils.map('n', 'tm', ':tabmove<CR>', opts)
for i = 9,1,-1
do
   kmap = string.format("<leader>%d", i)
   command = string.format("%dgt", i)
   utils.map('n', kmap, command)
end

-- Buffer mappings
utils.map('n', '<c-j>', ':bnext<cr>', opts)
utils.map('n', '<c-k>', ':bprev<cr>', opts)
utils.map('n', 'ĸ', ':bd<CR>', opts)

-- Terminal open
-- utils.map('n', '<leader>t', ':split<CR>:ter<CR>:resize 8<CR>'

-- Resize pane
utils.map('n', '<leader><Right>', ':vertical resize +5<CR>', opts)
utils.map('n', '<leader><Left>', ':vertical resize -5<CR>', opts)
utils.map('n', '<leader><Up>', ':resize +5<CR>', opts)
utils.map('n', '<leader><Down>', ':resize -5<CR>', opts)

--Esc in terminal mode
utils.map('t', '<Esc>', '<C-\\><C-n>', opts)
utils.map('t', '<M-[>', '<Esc>', opts)
utils.map('t', '<C-v><Esc>', '<Esc>', opts)

--Move line to up or down
utils.map('n', '<A-Down>', ':m .+1<CR>==', opts)
utils.map('n', '<A-Up>', ':m .-2<CR>==', opts)
utils.map('i', '<A-Down>', '<Esc>:m .+1<CR>==gi', opts)
utils.map('i', '<A-Up>', '<Esc>:m .-2<CR>==gi', opts)
utils.map('v', '<A-Down>', ":m '>+1<CR>gv=gv", opts)
utils.map('v', '<A-Up>', ":m '<-2<CR>gv=gv", opts)

utils.map('n', '<A-j>', ':m .+1<CR>==', opts)
utils.map('n', '<A-k>', ':m .-2<CR>==', opts)
utils.map('i', '<A-j>', '<Esc>:m .+1<CR>==gi', opts)
utils.map('i', '<A-k>', '<Esc>:m .-2<CR>==gi', opts)
utils.map('v', '<A-j>', ":m '>+1<CR>gv=gv", opts)
utils.map('v', '<A-k>', ":m '<-2<CR>gv=gv", opts)

--Delete search result
utils.map('n', '<leader>v', ':let @/=""<cr>', opts)

-- Leader for multi cursors
-- vim.g.VM_leader =
vim.g.VM_maps = {["Select All"] = 'æ'}
