local utils = require "utils"
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "netrw",
--   callback = function()
--     vim.opt.bufhidden = "hide"
--   end,
-- })

-- Toggle Netrw
-- local netrw_info = {
--   bufid = -1,
--   winid = -1,
--   before_wind_id = -1,
--   hidden = false,
-- }

-- local function show_netrw(wind_id)
--   netrw_info.before_wind_id = wind_id
--   vim.cmd("topleft" .. vim.g.netrw_winsize + 15 .. " vs new | buffer " .. netrw_info.bufid)
--   netrw_info.winid = vim.api.nvim_get_current_win()
--   netrw_info.bufid = vim.api.nvim_buf_get_number(0)
--   netrw_info.hidden = false
-- end
--
-- local function toggle_netrw()
--   local buf_exist = vim.api.nvim_buf_is_valid(netrw_info.bufid)
--   local current_wind_id = vim.api.nvim_get_current_win()
--   if buf_exist then
--     utils.info('entre', 'netrw')
--     if netrw_info.hidden then
--       show_netrw(current_wind_id)
--     else
--       vim.fn.win_gotoid(netrw_info.winid)
--       vim.cmd ":hide"
--       netrw_info.hidden = true
--       if current_wind_id ~= netrw_info.before_wind_id and current_wind_id ~= netrw_info.winid then
--         vim.fn.win_gotoid(current_wind_id)
--         show_netrw(current_wind_id)
--       end
--     end
--   else
--     netrw_info.before_wind_id = current_wind_id
--     vim.cmd [[silent Lexplore]]
--     netrw_info.winid = vim.api.nvim_get_current_win()
--     netrw_info.bufid = vim.api.nvim_buf_get_number(0)
--     netrw_info.hidden = false
--   end
-- end

local cwd = "%:p:h"
local first = true
local function toggle_netrw()
  local winds = vim.api.nvim_tabpage_list_wins(0)
  local hide = true

  for _, winid in pairs(winds) do
    local ft = vim.bo[vim.fn.winbufnr(winid)].ft
    if ft == "netrw" then
      hide = false
      vim.cmd [[Lexplore]]
      break
    end
  end

  if hide then
    if first then
      cwd = vim.fn.expand(cwd)
      first = fasle
    end
    utils.info(cwd, "netrw")
    vim.cmd([[silent Lexplore ]] .. cwd)
  end
end

function setup()
  vim.g.netrw_hide = 1
  -- vim.g.netrw_keepdir = 0
  vim.g.netrw_liststyle = 3
  vim.g.netrw_list_hide = [[.*\.swp$,.DS_Store,*/tmp/*,*.so,*.swp,*.zip,*.git,^\.\.\=/\=$]]
  vim.g.netrw_banner = 0
  vim.g.netrw_browse_split = 3
  vim.g.netrw_winsize = 20
  vim.g.netrw_localcopydircmd = "cp -r"
  require("netrw").setup {
    use_devicons = true,
  }

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function(ev)
      local bind = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { remap = true, buffer = true, desc = desc })
      end
      vim.cmd.highlight { "link", "netrwMarkFile", "Search" }
      bind("H", "u", "Goto back")
      bind("h", "-^", "Navigate to up folder")
      bind("l", "<CR>", "open file")
      bind(".", "gh", "Hide or show hidden files")
      bind("P", "<C-w>z", "Close preview")
      bind("<TAB>", "mf", "Mark file")
      bind("<S-TAB>", "mF", "Quit all marked files over currente window")
      bind("<Leader><TAB>", "mu", "Quit all marks")
      bind("ff", "%:w<CR>:buffer #<CR>", "Create file")
      bind("fr", "R", "Rename file")
      bind("fc", "mc", "Copy marked files")
      bind("fC", "mtmc", "Copy marked files over current folder")
      bind("fx", "mm", "Cut marked files")
      bind("fX", "mtmm", "Cut marked files over current folder")
      bind("f;", "mx", "Execute commando over current file")
      bind("fl", [[:echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR>]], "Por asignar")
      bind("fq", [[:echo 'Target:' . netrw#Expose("netrwmftgt")<CR>]], "Por asignar")
      bind("fd", "mtfq", "Por asignar")
    end,
  })
  -- vim.cmd [[
  --   augroup AutoDeleteNetrwHiddenBuffers
  --     au!
  --     au FileType netrw setlocal bufhidden=hide
  --   augroup end
  -- ]]
end

return {
  {
    "prichrd/netrw.nvim",
    keys = { { "<leader><leader>", toggle_netrw, desc = "Show netrw file explorer" } },
    config = setup,
  },
}
