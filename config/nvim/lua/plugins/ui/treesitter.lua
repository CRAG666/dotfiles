vim.pack.add({
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    version = 'main',
  },
  'https://github.com/RRethy/nvim-treesitter-endwise',
  'https://github.com/tronikelis/ts-autotag.nvim',
})

require('nvim-treesitter').install({
  'bash',
  'bibtex',
  'c',
  'c_sharp',
  'comment',
  'cpp',
  'css',
  'csv',
  'desktop',
  'diff',
  'dockerfile',
  'dot',
  'git_config',
  'git_rebase',
  'gitattributes',
  'gitcommit',
  'gitignore',
  'gpg',
  'html',
  'hyprlang',
  'javascript',
  'json',
  'jsonc',
  'latex',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'norg',
  'norg_meta',
  'nu',
  'python',
  'query',
  'rasi',
  'regex',
  'requirements',
  'sql',
  'toml',
  'typescript',
  'udev',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
  'zathurarc',
})

require('nvim-treesitter-textobjects').setup({
  select = {
    lookahead = true,
    selection_modes = {
      ['@block.outer'] = 'V',
      ['@block.inner'] = 'V',
      ['@header.outer'] = 'V',
      ['@header.inner'] = 'V',
    },
  },
})

local sel = require('nvim-treesitter-textobjects.select').select_textobject

local goto_next_end = require('nvim-treesitter-textobjects.move').goto_next_end
local goto_next_start =
  require('nvim-treesitter-textobjects.move').goto_next_start
local goto_previous_end =
  require('nvim-treesitter-textobjects.move').goto_previous_end
local goto_previous_start =
  require('nvim-treesitter-textobjects.move').goto_previous_start

local swap_next = require('nvim-treesitter-textobjects.swap').swap_next
local swap_previous = require('nvim-treesitter-textobjects.swap').swap_previous

-- stylua: ignore start
vim.keymap.set({ 'x', 'o' }, 'am', function() sel('@function.outer') end)
vim.keymap.set({ 'x', 'o' }, 'im', function() sel('@function.inner') end)
vim.keymap.set({ 'x', 'o' }, 'ao', function() sel('@loop.outer') end)
vim.keymap.set({ 'x', 'o' }, 'io', function() sel('@loop.inner') end)
vim.keymap.set({ 'x', 'o' }, 'ak', function() sel('@class.outer') end)
vim.keymap.set({ 'x', 'o' }, 'ik', function() sel('@class.inner') end)
vim.keymap.set({ 'x', 'o' }, 'a,', function() sel('@parameter.outer') end)
vim.keymap.set({ 'x', 'o' }, 'i,', function() sel('@parameter.inner') end)
vim.keymap.set({ 'x', 'o' }, 'a/', function() sel('@comment.outer') end)
vim.keymap.set({ 'x', 'o' }, 'a*', function() sel('@comment.outer') end)
vim.keymap.set({ 'x', 'o' }, 'a.', function() sel('@block.outer') end)
vim.keymap.set({ 'x', 'o' }, 'i.', function() sel('@block.inner') end)
vim.keymap.set({ 'x', 'o' }, 'a?', function() sel('@conditional.outer') end)
vim.keymap.set({ 'x', 'o' }, 'i?', function() sel('@conditional.inner') end)
vim.keymap.set({ 'x', 'o' }, 'a=', function() sel('@assignment.outer') end)
vim.keymap.set({ 'x', 'o' }, 'i=', function() sel('@assignment.inner') end)
vim.keymap.set({ 'x', 'o' }, 'a#', function() sel('@header.outer') end)
vim.keymap.set({ 'x', 'o' }, 'i#', function() sel('@header.inner') end)
vim.keymap.set({ 'x', 'o' }, 'a3', function() sel('@header.outer') end)
vim.keymap.set({ 'x', 'o' }, 'i3', function() sel('@header.inner') end)
vim.keymap.set({ 'x', 'o' }, 'ar', function() sel('@return.inner') end)
vim.keymap.set({ 'x', 'o' }, 'ir', function() sel('@return.outer') end)
-- stylua: ignore end

-- stylua: ignore start
vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() goto_next_start('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']o', function() goto_next_start('@loop.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() goto_next_start('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']k', function() goto_next_start('@class.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '],', function() goto_next_start('@parameter.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '].', function() goto_next_start('@block.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']?', function() goto_next_start('@conditional.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']=', function() goto_next_start('@assignment.inner') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']#', function() goto_next_start('@header.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']3', function() goto_next_start('@header.outer') end)

vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() goto_next_end('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']O', function() goto_next_end('@loop.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '][', function() goto_next_end('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']K', function() goto_next_end('@class.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']<', function() goto_next_end('@parameter.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']/', function() goto_next_end('@comment.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']>', function() goto_next_end('@block.outer') end)

vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() goto_previous_start('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[o', function() goto_previous_start('@loop.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() goto_previous_start('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[k', function() goto_previous_start('@class.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[,', function() goto_previous_start('@parameter.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[.', function() goto_previous_start('@block.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[?', function() goto_previous_start('@conditional.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[=', function() goto_previous_start('@assignment.inner') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[#', function() goto_previous_start('@header.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[3', function() goto_previous_start('@header.outer') end)

vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() goto_previous_end('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[O', function() goto_previous_end('@loop.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() goto_previous_end('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[K', function() goto_previous_end('@class.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[<', function() goto_previous_end('@parameter.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[/', function() goto_previous_end('@comment.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[>', function() goto_previous_end('@block.outer') end)

vim.keymap.set('n', '<M-C-h>',     function() swap_previous('@parameter.inner') end)
vim.keymap.set('n', '<M-C-Left>',  function() swap_previous('@parameter.inner') end)
vim.keymap.set('n', '<M-C-l>',     function() swap_next('@parameter.inner') end)
vim.keymap.set('n', '<M-C-Right>', function() swap_next('@parameter.inner') end)
-- stylua: ignore end

local fn = require('utils.fn')
fn.lazy_load('InsertEnter', 'treesitter_plugins', function()
  require('ts-autotag').setup()
  vim.api.nvim_exec_autocmds('FileType', {})
end)
