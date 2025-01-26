-- Name:         default
-- Description:  Improves default colorscheme
-- Author:       Bekaboo <kankefengjing@gmail.com>
-- Maintainer:   Bekaboo <kankefengjing@gmail.com>
-- License:      GPL-3.0
-- Last Updated: Fri Jan 24 10:06:39 PM EST 2025

vim.cmd.hi('clear')
vim.g.colors_name = 'default'

vim.api.nvim_set_hl(0, 'Comment', { fg = 'NvimDarkGrey4', ctermfg = 8 })
vim.api.nvim_set_hl(0, 'LineNr', { fg = 'NvimDarkGrey4', ctermfg = 8 })
vim.api.nvim_set_hl(0, 'NonText', { fg = 'NvimDarkGrey4', ctermfg = 8 })
vim.api.nvim_set_hl(0, 'SpellBad', { underdashed = true, cterm = {} })
vim.api.nvim_set_hl(0, 'FloatTitle', { link = 'FloatBorder' })
vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Pmenu' })

vim.api.nvim_set_hl(0, 'MatchParen', { reverse = true })

-- stylua: ignore start
vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = 'NvimLightGreen', ctermfg = 10 })
vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = 'NvimLightBlue', ctermfg = 12 })
vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = 'NvimDarkRed', ctermfg = 9 })
vim.api.nvim_set_hl(0, 'GitSignsDeletePreview', { bg = 'NvimDarkRed', ctermbg = 9 })
-- stylua: ignore end

-- vim:ts=2:sw=2:sts=2:fdm=marker
