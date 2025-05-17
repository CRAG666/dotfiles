-- | | _____ _   _ _ __ ___   __ _ _ __
-- | |/ / _ \ | | | '_ ` _ \ / _` | '_ \
-- |   <  __/ |_| | | | | | | (_| | |_) |
-- |_|\_\___|\__, |_| |_| |_|\__,_| .__/
--           |___/                |_|

local utils = require('utils.keymap')
local opts = { noremap = true, silent = false }

vim.keymap.set('n', 'i', function()
  if #vim.fn.getline('.') == 0 then
    return [["_cc]]
  else
    return 'i'
  end
end, { expr = true })
utils.map('n', '#', '#N')
utils.map('n', '*', '*N')
utils.map(
  'n',
  'k',
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true }
)
utils.map(
  'n',
  'j',
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true }
)
utils.map('n', '<C-d>', '<C-d>zz')
utils.map('n', '<C-u>', '<C-u>zz')
utils.map('n', 'n', 'nzzzv')
utils.map('n', 'N', 'Nzzzv')

-- Search and  replace in the current buffer
utils.map({ 'n', 'v' }, '<leader>r', ':s/', opts)

-- Set ; to end line
-- utils.map("n", "<leader>;", "<esc>mzA;<esc>`z")

-- No yank
utils.map('n', 'x', '"_x')
utils.map({ 'n', 'x' }, 'c', '"_c')
utils.map('n', 'C', '"_C')
utils.map('v', 'p', '"_dP', opts)

-- Better indent
utils.map("v", "<", "<gv", opts)
utils.map("v", ">", ">gv", opts)

utils.map('n', '<A-s>', function()
  vim.ui.select({ "es_mx", "en_us" }, {
    prompt = "Toggle spell checker",
  }, function(lang)
    if lang then
      vim.cmd(string.format([[setlocal spell! spelllang=%s]], lang))
    else
      print("language not selected")
    end
  end)
end)

-- sudo
-- vim.cmd [[cmap w!! w !sudo tee > /dev/null %]]

-- Tab mappings

for i = 9, 1, -1 do
  local kmap = string.format('<leader>%d', i)
  local command = string.format('%dgt', i)
  utils.map('n', kmap, command, { desc = string.format('Jump Tab [%d]', i) })
  utils.map(
    'n',
    string.format('<leader>t%d', i),
    string.format(':tabmove %d<CR>', i == 1 and 0 or i),
    { desc = string.format('Tab Move to [%d]', i) }
  )
end

local maps = {
  {
    prefix = '<leader>t',
    maps = {
      { 'n', vim.cmd.tabnew,    'Tab [n]ew' },
      { 'o', vim.cmd.tabonly,   'Tab [o]nly' },
      { 'c', vim.cmd.tabclose,  'Tab [c]lose' },
      { 'l', ':tabmove +1<CR>', 'Tab Move Right' },
      { 'h', ':tabmove -1<CR>', 'Tab Move Left' },
      {
        's',
        [[:execute 'set showtabline=' . (&showtabline ==# 0 ? 2 : 0)<CR>]],
        'Toggle Tabs',
      },
    },
  },
  {
    prefix = '<leader>',
    maps = {
      { 'cc', ':let @/=""<cr>',                                "Clear [c]hoose" },
      -- { 'l',  [[*``cgn]],                                      'Replace word and nexts word with .' },
      -- Search and replace word
      { 'cn', [[/\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn]], 'Replace word and nexts word with .' },
      { 'cN', [[/\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn]], 'Replace word and prevs word with .' },
    },
  },
  {
    prefix = ';',
    maps = {
      { 'r',  ':%s/',                  'Search and [r]eplace',        opts },
      { 'cw', [[:%s/\<<C-r><C-w>\>/]], '[c]hange [w]ord',             opts },
      { 'R',  [[:%s/\(.*\)/\1]],       'Search and [R]eplace extend', opts },
    },
  },
}
utils.maps(maps)

--Esc in terminal mode
utils.map('t', '<Esc>', '<C-\\><C-n>')
utils.map('t', '<M-[>', '<Esc>')
utils.map('t', '<C-v><Esc>', '<Esc>')

utils.map(
  'n',
  '<bs>',
  ":<c-u>exe v:count ? v:count . 'b' : 'b' . (bufloaded(0) ? '#' : 'n')<cr>"
)
vim.api.nvim_create_autocmd('CmdlineEnter', {
  once = true,
  callback = function()
    utils.command_map(';', 'lua ')
    utils.command_map(':', ':= ')
    utils.command_abbrev('man', 'Man')
    utils.command_abbrev('rm', '!rm')
    utils.command_abbrev('mv', '!mv')
    utils.command_abbrev('git', '!git')
    utils.command_abbrev('mkd', '!mkdir')
    utils.command_abbrev('mkdir', '!mkdir')
    utils.command_abbrev('touch', '!touch')
    return true
  end,
})
