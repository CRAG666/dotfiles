local utils = require "utils"
local M = {}
local keys = {
  { "<leader>hm", desc = "[h]arpoon [m]ark" },
  { "<leader>hh", desc = "[h]arpoon [h]istory" },
  { "<leader>hw", desc = "[h]arpoon next" },
  { "<leader>hb", desc = "[h]arpoon prev" },
  { "<leader>hr", desc = "[h]arpoon [r]un" },
  { "<leader>ht", desc = "[h]arpoon [t]erm" },
}

local function setup()
  require("harpoon").setup {
    global_settings = {
      save_on_toggle = true,
      enter_on_sendcmd = true,
    },
  }
  local ui = require "harpoon.ui"
  local term = require "harpoon.term"

  local maps = {
    require("harpoon.mark").add_file,
    ui.toggle_quick_menu,
    ui.nav_next,
    ui.nav_prev,
    function()
      term.sendCommand(10, vim.api.nvim_replace_termcodes("<C-c> <C-l>", true, true, true))
      vim.uv.sleep(150)
      term.sendCommand(10, require("code_runner.commands").get_filetype_command() .. "\n")
    end,
    function()
      term.gotoTerminal(10)
      vim.wo.relativenumber = false
      vim.o.number = false
      vim.wo.foldcolumn = "0"
      vim.wo.scl = "no"
    end,
  }
  for i, map in ipairs(keys) do
    utils.map("n", map[1], maps[i])
  end
end

return {
  {
    "ThePrimeagen/harpoon",
    keys = keys,
    config = setup,
  },
}
