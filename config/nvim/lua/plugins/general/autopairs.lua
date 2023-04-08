-- local npairs = require "nvim-autopairs"
return {
  "windwp/nvim-autopairs",
  opts = {
    check_ts = true,
  },
}

-- if vim.g.cmp_enable then
--   function M.setup()
--     npairs.setup {
--       check_ts = true,
--     }
--   end
-- else
--   local remap = vim.api.nvim_set_keymap
--   M.setup = function()
--     npairs.setup { map_bs = false, map_cr = false }
--
--     -- these mappings are coq recommended mappings unrelated to nvim-autopairs
--     local opts = { expr = true, noremap = true, silent = true }
--     remap("i", "<esc>", [[pumvisible() ? "<c-e><esc>" : "<esc>"]], opts)
--     remap("i", "<c-c>", [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], opts)
--     remap("i", "<tab>", [[pumvisible() ? "<c-n>" : "<tab>"]], opts)
--     remap("i", "<s-tab>", [[pumvisible() ? "<c-p>" : "<bs>"]], opts)
--
--     -- skip it, if you use another global object
--     _G.MUtils = {}
--
--     MUtils.CR = function()
--       if vim.fn.pumvisible() ~= 0 then
--         if vim.fn.complete_info({ "selected" }).selected ~= -1 then
--           return npairs.esc "<c-y>"
--         else
--           return npairs.esc "<c-e>" .. npairs.autopairs_cr()
--         end
--       else
--         return npairs.autopairs_cr()
--       end
--     end
--     remap("i", "<cr>", "v:lua.MUtils.CR()", opts)
--
--     MUtils.BS = function()
--       if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ "mode" }).mode == "eval" then
--         return npairs.esc "<c-e>" .. npairs.autopairs_bs()
--       else
--         return npairs.autopairs_bs()
--       end
--     end
--     remap("i", "<bs>", "v:lua.MUtils.BS()", opts)
--   end
-- end
-- return M
