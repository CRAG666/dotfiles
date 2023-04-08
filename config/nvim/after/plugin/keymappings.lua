-- | | _____ _   _ _ __ ___   __ _ _ __
-- | |/ / _ \ | | | '_ ` _ \ / _` | '_ \
-- |   <  __/ |_| | | | | | | (_| | |_) |
-- |_|\_\___|\__, |_| |_| |_|\__,_| .__/
--           |___/                |_|

local utils = require "utils"
local opts = { noremap = true, silent = false }

utils.map("n", "#", "#N")
utils.map("n", "*", "*N")
utils.map("n", "Y", "yg$")
utils.map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
utils.map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
utils.map("n", "<C-d>", "<C-d>zz")
utils.map("n", "<C-u>", "<C-u>zz")
utils.map("n", "n", "nzzzv")
utils.map("n", "N", "Nzzzv")

-- Search in the current buffer
utils.map("n", "<leader>s", "?", opts)
-- Search and  replace in the current buffer
utils.map({ "n", "v" }, "<leader>r", ":s/", opts)
-- Set ; to end line
utils.map("n", "<leader>;", "<esc>mzA;<esc>`z")

-- No yank
utils.map("n", "x", '"_x')
utils.map({ "n", "x" }, "c", '"_c')
utils.map("n", "C", '"_C')
utils.map("v", "p", '"_dP', opts)

-- Better indent
-- utils.map("v", "<", "<gv", opts)
-- utils.map("v", ">", ">gv", opts)

-- Toggle spell checker
utils.map("n", "<F2>", ":setlocal spell! spelllang=es<CR>")
utils.map("n", "<F3>", ":setlocal spell! spelllang=en_us<CR>")

-- Search and replace word
utils.map("n", "cn", [[/\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn]]) -- replace world and nexts word with .
utils.map("n", "cN", [[?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN]]) -- replace world and prev word with .

-- sudo
-- vim.cmd [[cmap w!! w !sudo tee > /dev/null %]]

-- Tab mappings

for i = 9, 1, -1 do
  local kmap = string.format("<leader>%d", i)
  local command = string.format("%dgt", i)
  utils.map("n", kmap, command, { desc = string.format("Jump Tab %d", i) })
  utils.map(
    "n",
    string.format("<leader>t%d", i),
    string.format(":tabmove %d<CR>", i == 1 and 0 or i),
    { desc = string.format("Tab Move to %d", i) }
  )
end
local maps = {
  {
    prefix = "<leader>t",
    maps = {
      -- { "s", [[:execute 'set showtabline=' . (&showtabline ==# 0 ? 2 : 0)<CR>]], "Show Tabs" },
      { "n", vim.cmd.tabnew, "New Tab" },
      { "o", vim.cmd.tabonly, "Tab Only" },
      { "d", vim.cmd.tabclose, "Tab Close" },
      { "l", ":tabmove +1<CR>", "Tab Move Right" },
      { "h", ":tabmove -1<CR>", "Tab Move Left" },
    },
  },
  {
    prefix = "<leader>",
    maps = {
      { "w", vim.cmd.bnext, "Buffer Next" },
      { "b", vim.cmd.bprev, "Buffer Prev" },
      -- Move between splits
      -- { "k", ":wincmd k<CR>", "Move Up" },
      -- { "l", ":wincmd l<CR>", "Move Right" },
      -- { "j", ":wincmd j<CR>", "Move Down" },
      -- { "h", ":wincmd h<CR>", "Move Left" },
      --Delete search result
      { "c", ':let @/=""<cr>' },
    },
  },
  {
    prefix = ";",
    maps = {
      -- { "s", "/", "Search", opts },
      { "r", ":%s/", "Search and Replace", opts },
      { "cw", [[:%s/\<<C-r><C-w>\>/]], "Replace Word", opts },
      -- { "d", ":bd<CR>", "Buffer Delete" },
    },
  },
}
utils.maps(maps)

-- Resize pane
utils.map("n", "<A-Left>", ":vertical resize +5<CR>")
utils.map("n", "<A-Right>", ":vertical resize -5<CR>")
utils.map("n", "<A-Down>", ":resize +5<CR>")
utils.map("n", "<A-Up>", ":resize -5<CR>")

--Move line to up or down
-- utils.map("n", "J", ":m .+1<CR>==", opts)
-- utils.map("n", "K", ":m .-2<CR>==", opts)
-- utils.map("x", "J", ":move '>+1gv-gv", opts)
-- utils.map("x", "K", ":move '<-2gv-gv", opts)
-- utils.map("i", "J", "<Esc>:m .+1<CR>==gi", opts)
-- utils.map("i", "K", "<Esc>:m .-2<CR>==gi", opts)
-- utils.map("v", "J", ":m '>+1<CR>gv=gv", opts)
-- utils.map("v", "K", ":m '<-2<CR>gv=gv", opts)

--Esc in terminal mode
utils.map("t", "<Esc>", "<C-\\><C-n>")
utils.map("t", "<M-[>", "<Esc>")
utils.map("t", "<C-v><Esc>", "<Esc>")
-- utils.map('n', '<bs>', '<c-^>`”zz')
utils.map("n", "<bs>", ":<c-u>exe v:count ? v:count . 'b' : 'b' . (bufloaded(0) ? '#' : 'n')<cr>")
utils.map("n", "<leader>fo", vim.cmd.TodoTelescope, { desc = "Todo List" })
-- utils.map("n", "<leader>e", require("code_runner.commands").run_code, opts)
