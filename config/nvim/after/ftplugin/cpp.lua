require('utils.ftplugin')({
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = -1,
  expandtab = true,
  cinoptions = ':0g0(0s',
  commentstring = '// %s',
  textwidth = 0,
  wrap = false,
  spell = false,
}, 'setlocal errorformat<')

vim.g.ts = { 'c', 'cpp' }

-- Set ; to end line
-- vim.keymap.set(
--   'n',
--   '<leader>;',
--   '<esc>mzA;<esc>`z',
--   { noremap = true, silent = true }
-- )

-- vim.pack.add({
--   'https://github.com/p00f/clangd_extensions.nvim',
-- })
--
-- require('clangd_extensions').setup({
--   inlay_hints = {
--     inline = true,
--   },
--   ast = {
--     role_icons = {
--       ['type'] = icons.Type,
--       ['declaration'] = icons.Function,
--       ['expression'] = icons.Snippet,
--       ['specifier'] = icons.Specifier,
--       ['statement'] = icons.Statement,
--       ['template argument'] = icons.TypeParameter,
--     },
--     kind_icons = {
--       ['Compound'] = icons.Namespace,
--       ['Recovery'] = icons.DiagnosticSignError,
--       ['TranslationUnit'] = icons.Unit,
--       ['PackExpansion'] = icons.Ellipsis,
--       ['TemplateTypeParm'] = icons.TypeParameter,
--       ['TemplateTemplateParm'] = icons.TypeParameter,
--       ['TemplateParamObject'] = icons.TypeParameter,
--     },
--   },
--   memory_usage = { border = 'solid' },
--   symbol_info = { border = 'solid' },
-- })

-- Parse gcc/clang diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f:%l:%c: %t%*[^:]: %m,%f:%l: %m]]
