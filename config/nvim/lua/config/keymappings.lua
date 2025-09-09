-- | | _____ _   _ _ __ ___   __ _ _ __
-- | |/ / _ \ | | | '_ ` _ \ / _` | '_ \
-- |   <  __/ |_| | | | | | | (_| | |_) |
-- |_|\_\___|\__, |_| |_| |_|\__,_| .__/
--           |___/                |_|

local key = require('utils.keymap')
local opts = { noremap = true, silent = false }

vim.keymap.set('n', 'i', function()
  if #vim.fn.getline('.') == 0 then
    return [["_cc]]
  else
    return 'i'
  end
end, { expr = true })
key.map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
key.map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- key.map('n', "'", [[printf('`%czz',getchar())]], { expr = true, silent = false })
key.map('n', '<C-d>', '<C-d>zz')
key.map('n', '<C-u>', '<C-u>zz')
key.map('n', 'n', 'nzzzv')
key.map('n', 'N', 'Nzzzv')
key.map('n', '<CR>', ':w<CR>')
key.map('n', '<Tab>', vim.cmd.bnext)
key.map('n', '<S-Tab>', vim.cmd.bprev)
key.map('n', 'yc', 'yygccp', { remap = true, desc = 'Yank [c]omment' })
key.map(
  'x',
  'z/',
  '<C-\\><C-n>`</\\%V',
  { desc = 'Search forward within visual selection' }
)
key.map(
  'x',
  'z?',
  '<C-\\><C-n>`>?\\%V',
  { desc = 'Search backward within visual selection' }
)

-- No yank
key.map('n', 'x', '"_x')
key.map({ 'n', 'x' }, 'c', '"_c')
key.map('n', 'C', '"_C')
key.map('v', 'p', '"_dP', opts)

-- Better indent
key.map('v', '<', '<gv', opts)
key.map('v', '>', '>gv', opts)

key.map('n', '<localleader>s', function()
  if vim.wo.spell then
    vim.wo.spell = false
    return
  end
  vim.ui.select({ 'es_mx', 'en_us' }, {
    prompt = 'Toggle spell checker',
  }, function(lang)
    if lang then
      vim.wo.spell = true
      vim.bo.spelllang = lang
    else
      print('language not selected')
    end
  end)
end, { desc = 'Toggle spell checker' })

key.map('n', '<localleader>e', function()
  require('modules.es_shortcuts')
end, { desc = 'Spanish Shortcuts' })

-- sudo
-- vim.cmd [[cmap w!! w !sudo tee > /dev/null %]]

-- Tab mappings

for i = 9, 1, -1 do
  local kmap = string.format('<leader>%d', i)
  local command = string.format('%dgt', i)
  key.map('n', kmap, command, { desc = string.format('Jump Tab [%d]', i) })
  key.map(
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
      { 'n', vim.cmd.tabnew, 'Tab [n]ew' },
      { 'o', vim.cmd.tabonly, 'Tab [o]nly' },
      { 'c', vim.cmd.tabclose, 'Tab [c]lose' },
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
      { 'cc', ':let @/=""<cr>', 'Clear [c]hoose' },
    },
  },
  {
    prefix = '<leader>r',
    maps = {
      {
        'r',
        ':%s/',
        'Search and [r]eplace',
        opts,
      },
      {
        'l',
        ':s/',
        'Search and [r]eplace [l]ine',
        opts,
      },
      {
        'w',
        [[:%s/\<<C-r><C-w>\>/]],
        'Search and [r]eplace [w]ord',
        opts,
      },
      {
        'e',
        [[:%s/\(.*\)/\1]],
        'Search and [r]eplace [e]xtend',
        opts,
      },
      {
        'n',
        [[/\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn]],
        'Search and Replace word and nexts word with .',
      },
      {
        'N',
        [[?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN]],
        'Search and Replace word and prevs word with .',
      },
    },
  },
  {
    prefix = '<leader>r',
    mode = 'v',
    maps = {
      { 'r', ':s/', 'Search and [r]eplace visual', opts },
      { 'e', [[:s/\(.*\)/\1]], 'Search and [r]eplace [e]xtend visual', opts },
    },
  },
}
key.maps(maps)

--Esc in terminal mode
key.map('t', '<Esc>', '<C-\\><C-n>')
key.map('t', '<M-[>', '<Esc>')
key.map('t', '<C-v><Esc>', '<Esc>')

key.map(
  'n',
  '<bs>',
  ":<c-u>exe v:count ? v:count . 'b' : 'b' . (bufloaded(0) ? '#' : 'n')<cr>"
)

key.map({ 'n', 'x' }, 'zV', function()
  local lz = vim.go.lz
  vim.go.lz = true
  vim.cmd.normal({ 'zMzv', bang = true })
  vim.go.lz = lz
end, { desc = 'Close all folds except current' })

key.map({ 'n', 'x' }, 'q', function()
  require('utils.key').close_floats('q')
end, { desc = 'Close all floating windows or start recording macro' })

key.map(
  'x',
  'af',
  ':<C-u>silent! keepjumps normal! ggVG<CR>',
  { silent = true, noremap = false, desc = 'Select current buffer' }
)
key.map(
  'x',
  'if',
  ':<C-u>silent! keepjumps normal! ggVG<CR>',
  { silent = true, noremap = false, desc = 'Select current buffer' }
)
key.map(
  'o',
  'af',
  '<Cmd>silent! normal m`Vaf<CR><Cmd>silent! normal! ``<CR>',
  { silent = true, noremap = false, desc = 'Select current buffer' }
)
key.map(
  'o',
  'if',
  '<Cmd>silent! normal m`Vif<CR><Cmd>silent! normal! ``<CR>',
  { silent = true, noremap = false, desc = 'Select current buffer' }
)

key.map(
  'x',
  'iz',
  [[':<C-u>silent! keepjumps normal! ' . v:lua.require'utils.key'.textobj_fold('i') . '<CR>']],
  {
    silent = true,
    expr = true,
    noremap = false,
    desc = 'Select inside current fold',
  }
)
key.map(
  'x',
  'az',
  [[':<C-u>silent! keepjumps normal! ' . v:lua.require'utils.key'.textobj_fold('a') . '<CR>']],
  {
    silent = true,
    expr = true,
    noremap = false,
    desc = 'Select around current fold',
  }
)
key.map(
  'o',
  'iz',
  '<Cmd>silent! normal Viz<CR>',
  { silent = true, noremap = false, desc = 'Select inside current fold' }
)
key.map(
  'o',
  'az',
  '<Cmd>silent! normal Vaz<CR>',
  { silent = true, noremap = false, desc = 'Select around current fold' }
)

key.map('n', '<leader>pu', vim.pack.update, { desc = '[p]lugin [u]pdate' })
key.map('n', '<leader>pi', vim.pack.get, { desc = '[p]lugins [i]nfo' })

key.map('!a', 'ture', 'true')
key.map('!a', 'Ture', 'True')
key.map('!a', 'flase', 'false')
key.map('!a', 'fasle', 'false')
key.map('!a', 'Flase', 'False')
key.map('!a', 'Fasle', 'False')
key.map('!a', 'lcaol', 'local')
key.map('!a', 'lcoal', 'local')
key.map('!a', 'locla', 'local')
key.map('!a', 'sahre', 'share')
key.map('!a', 'saher', 'share')
key.map('!a', 'balme', 'blame')
key.map('!a', 'intall', 'install')

vim.api.nvim_create_autocmd('CmdlineEnter', {
  once = true,
  callback = function()
    key.command_map(':', 'lua ')
    key.command_map(';', ':= ')
    key.command_abbrev('man', 'Man')
    key.command_abbrev('rm', '!rm')
    key.command_abbrev('mv', '!mv')
    key.command_abbrev('git', '!git')
    key.command_abbrev('tree', '!tree')
    key.command_abbrev('mkdir', '!mkdir')
    key.command_abbrev('touch', '!touch')
    key.command_abbrev('chmod', '!chmod')
    return true
  end,
})
