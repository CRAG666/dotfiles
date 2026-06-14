---@type pack.spec
return {
  src = 'https://github.com/RRethy/nvim-treesitter-endwise',
  data = {
    events = 'InsertEnter',
    postload = function()
      -- Manually trigger `FileType` event to make nvim-treesitter-endwise
      -- attach to current file when loaded
      vim.api.nvim_exec_autocmds('FileType', {})
    end,
  },
}
