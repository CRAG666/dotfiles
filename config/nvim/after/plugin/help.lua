local utils = require "utils"
local M = {}

local lang = ""
local file_type = ""

local set_quit_maps = function()
  vim.keymap.set("n", "q", ":bd!<CR>", { buffer = true, silent = true })
  -- vim.keymap.set("n", "<ESC>", ":bd!<CR>", { buffer = true, silent = true })
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, "cheatsheet-" .. buf)
  vim.api.nvim_set_option_value(buf, "filetype", "cheat")
  vim.api.nvim_set_option_value(buf, "syntax", vim.bo.ft)
end

function cheat_input(text, command)
  vim.ui.input({ prompt = text, default = vim.bo.ft .. " ", width = 30 }, function(query)
    input = vim.split(query, " ")
    ft = input[1]
    table.remove(input, 1)
    vim.print(input)
    query = table.concat(input, "+")
    print(query)
    local cmd = (command):format(ft, query)
    vim.cmd("vsplit | term " .. cmd)
    vim.cmd [[stopinsert!]]
    set_quit_maps()
  end)
end

function cheat_sh()
  cheat_input("cht.sh input: ", 'curl "https://cht.sh/%s/%s"')
end

function so_input()
  cheat_input("so input: ", "so %s %s")
end

utils.map("n", "<leader>so", so_input)
utils.map({ "n", "t" }, "<leader>ch", cheat_sh)
