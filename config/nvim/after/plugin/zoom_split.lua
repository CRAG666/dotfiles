--  _____
-- () | ,_  o  _  |)   ,
--    |/  | | /   |/) / \_
--  (/    |/|/\__/| \/ \/
--
local utils = require "utils"
-- local autopairs = {
--   ['('] = ')',
--   ['['] = ']',
--   ['{'] = '}',
--   ['<'] = '>',
--   [ [=[']=] ] = [=[']=],
--   [ [=["]=] ] = [=["]=],
-- }
-- local set_pairs = vim.keymap.set
-- for k, v in pairs(autopairs) do
--   set_pairs('i', k, function()
--     return k .. v .. '<Left>'
--   end, { expr = true, noremap = true })
-- end
local function resize()
  vim.api.nvim_win_set_width(0, 135)
  vim.api.nvim_win_set_height(0, 40)
end

local function feedkeys(keys, mode)
  if mode == nil then
    mode = "in"
  end
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), mode, true)
end

local function focus_split()
  local win_amount = #vim.api.nvim_tabpage_list_wins(0)
  if win_amount > 1 then
    if vim.t.zoom then
      vim.t.zoom = false
      feedkeys "<C-w>="
      return
    end
    vim.t.zoom = true
    resize()
  end
end

local function move_zoom_split(mov)
  vim.cmd.wincmd(mov)
  if vim.t.zoom then
    resize()
  end
end

vim.api.nvim_create_autocmd("WinNew", {
  callback = function()
    if vim.t.zoom then
      resize()
    end
  end,
})

local zoom_maps = {
  {
    "f",
    function()
      focus_split()
    end,
    "[f]ocus split",
  },
  {
    "j",
    function()
      move_zoom_split "j"
    end,
    "Move down split",
  },
  {
    "k",
    function()
      move_zoom_split "k"
    end,
    "Move up split",
  },
  {
    "h",
    function()
      move_zoom_split "h"
    end,
    "Move left split",
  },
  {
    "l",
    function()
      move_zoom_split "l"
    end,
    "Move right split",
  },
}
utils.pmaps("n", "<C-w>", zoom_maps)
