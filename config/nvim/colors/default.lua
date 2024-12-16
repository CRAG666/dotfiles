-- Name:         default
-- Description:  Improves default colorscheme
-- Author:       Bekaboo <kankefengjing@gmail.com>
-- Maintainer:   Bekaboo <kankefengjing@gmail.com>
-- License:      GPL-3.0
-- Last Updated: Wed Sep 18 11:02:07 PM EDT 2024

vim.cmd.hi('clear')
vim.g.colors_name = 'default'

if vim.go.background == 'dark' then
  vim.api.nvim_set_hl(0, 'Comment', { fg = 'NvimDarkGrey4', ctermfg = 8 })
  vim.api.nvim_set_hl(0, 'LineNr', { fg = 'NvimDarkGrey4', ctermfg = 8 })
  vim.api.nvim_set_hl(0, 'NonText', { fg = 'NvimDarkGrey4', ctermfg = 8 })
  vim.api.nvim_set_hl(0, 'SpellBad', { underdashed = true, cterm = {} })
  vim.api.nvim_set_hl(0, 'NormalFloat', {
    bg = 'NvimDarkGrey1',
    ctermbg = 7,
    ctermfg = 0,
  })
end

vim.api.nvim_set_hl(0, 'MatchParen', { reverse = true })

-- stylua: ignore start
vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = 'NvimLightGreen', ctermfg = 10 })
vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = 'NvimLightBlue', ctermfg = 12 })
vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = 'NvimDarkRed', ctermfg = 9 })
vim.api.nvim_set_hl(0, 'GitSignsDeletePreview', { bg = 'NvimDarkRed', ctermbg = 9 })
-- stylua: ignore end

-- vim:ts=2:sw=2:sts=2:fdm=marker:fdl=0
