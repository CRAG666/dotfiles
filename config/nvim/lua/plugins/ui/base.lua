local fn = require('utils.fn')

-- Dressing.nvim: Tu configuración ya es perezosa. ¡Perfecto!
vim.ui.select = function(...)
  vim.pack.add({
    'https://github.com/stevearc/dressing.nvim',
  })
  require('lazy').load({ plugins = { 'dressing.nvim' } })
  return vim.ui.select(...)
end

-- Which-key, Reactive, Marks: Se configuran en `VimEnter` usando tu utilidad.
-- Esto difiere la carga hasta que Neovim esté completamente inicializado.
fn.lazy_load('VimEnter', 'which-key', function()
  vim.pack.add({ 'https://github.com/folke/which-key.nvim' })
  require('which-key').setup({ preset = 'modern' })
end)

fn.lazy_load('CursorMoved', 'reactive', function()
  vim.pack.add({ 'https://github.com/rasulomaroff/reactive.nvim' })
  require('reactive').setup({
    builtin = {
      cursorline = true,
      cursor = true,
      modemsg = true,
    },
    load = { 'catppuccin-mocha-cursor', 'catppuccin-mocha-cursorline' },
  })
end)

fn.lazy_load('VimEnter', 'marks', function()
  vim.pack.add({ 'https://github.com/chentoast/marks.nvim' })
  require('marks').setup({})
end)

-- nvim-highlight-colors: Se configura solo al abrir archivos relevantes usando la opción `pattern`.
fn.lazy_load('FileType', 'nvim-highlight-colors', function()
  vim.pack.add({ 'https://github.com/brenoprata10/nvim-highlight-colors' })
  require('nvim-highlight-colors').setup({
    render = 'background',
    enable_tailwind = false,
  })
end, {
  pattern = {
    'html',
    'css',
    'scss',
    'javascript',
    'typescript',
    'svelte',
    'vue',
  },
  desc = 'Carga nvim-highlight-colors para tipos de archivo con colores',
})
