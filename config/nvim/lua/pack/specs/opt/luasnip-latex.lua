return {
  src = 'https://github.com/iurimateus/luasnip-latex-snippets.nvim',
  data = {
    deps = {
      {
        src = 'https://github.com/L3MON4D3/LuaSnip',
        data = { optional = true },
      },
    },
    events = {
      event = 'Filetype',
      pattern = { 'tex', 'markdown', 'quarto' },
    },
    defer = 'idle',
    postload = function()
      vim.schedule(function()
        require('luasnip-latex-snippets').setup({ use_treesitter = true })
        -- `setup()` adds the snippets on the next `FileType`, which already
        -- fired for the buffers that loaded the plugin; math in markdown is
        -- injected latex, which uses the tex snippets
        local fts = { 'tex' }
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local ft = vim.bo[buf].ft
          if ft == 'markdown' or ft == 'quarto' then
            fts[2] = 'markdown'
          end
        end
        for _, ft in ipairs(fts) do
          vim.api.nvim_exec_autocmds('FileType', {
            group = 'luasnip-latex-snippets',
            pattern = ft,
          })
          -- This module appends to a shared list on every call, the second
          -- filetype would get its snippets twice
          package.loaded['luasnip-latex-snippets.math_rA_no_backslash'] = nil
        end
      end)
    end,
  },
}
