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

local set_quit_maps = function()
  vim.keymap.set("n", "q", ":bd!<CR>", { buffer = true, silent = true })
  vim.keymap.set("n", "<ESC>", ":bd!<CR>", { buffer = true, silent = true })
end

function cheat_sh()
  vim.ui.input({ width = 30 }, function(query)
    query = table.concat(vim.split(query, " "), "+")
    local cmd = ('curl "https://cht.sh/%s/%s"'):format(vim.bo.ft, query)
    vim.cmd("split | term " .. cmd)
    vim.cmd [[stopinsert!]]
    set_quit_maps()
  end)
end

utils.map({ "n", "t" }, "<leader>ch", cheat_sh)
-- zoom over split
-- local zoom = false
local equal_split_keym = [[<C-w>=]]
local zoom_split_keym = [[<C-w>_<C-w>|]]

local function toggle_zoom_split()
  local win_amount = #vim.api.nvim_tabpage_list_wins(0)
  if win_amount > 1 then
    if vim.t.zoom then
      vim.t.zoom = false
      return equal_split_keym
    end
    vim.t.zoom = true
    return zoom_split_keym
  end
  return ""
end

local function move_zoom_split(pos)
  local move_pos = [[<C-w>]] .. pos
  if vim.t.zoom then
    return move_pos .. zoom_split_keym
  end
  return move_pos
end

local opts = { expr = true, noremap = true }
local zoom_maps = {
  { "z", toggle_zoom_split, "Zoom Current Split", opts },
  {
    "j",
    function()
      return move_zoom_split "j"
    end,
    "Move down split",
    opts,
  },
  {
    "k",
    function()
      return move_zoom_split "k"
    end,
    "Move up split",
    opts,
  },
  {
    "h",
    function()
      return move_zoom_split "h"
    end,
    "Move left split",
    opts,
  },
  {
    "l",
    function()
      return move_zoom_split "l"
    end,
    "Move right split",
    opts,
  },
}
utils.pmaps("n", "<leader>", zoom_maps)
