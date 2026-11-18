---@type pack.spec
return {
  src = 'https://github.com/RRethy/nvim-treesitter-endwise',
  data = {
    events = 'InsertEnter',
    idle = true,
    postload = function()
      -- Attach to the current buffer, its `FileType` fired before this
      -- lazy-load
      local lang = vim.treesitter.language.get_lang(vim.bo.ft)
      if require('nvim-treesitter-endwise').is_supported(lang) then
        require('nvim-treesitter.endwise').attach(
          vim.api.nvim_get_current_buf()
        )
      end
    end,
  },
}
