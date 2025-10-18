---@type pack.spec
return {
  src = 'https://github.com/lervag/vimtex',
  data = {
    cmds = 'VimtexInverseSearch',
    events = {
      event = 'Filetype',
      pattern = 'tex',
    },
    preload = function()
      -- Enable vim's legacy regex-based syntax highlighting alongside treesitter
      -- highlighting for some vimtex functions, e.g. changing modifiers, formatting,
      -- indentation, etc.
      vim.treesitter.start = (function(cb)
        ---@param bufnr integer? Buffer to be highlighted (default: current buffer)
        ---@param lang string? Language of the parser (default: from buffer filetype)
        return function(bufnr, lang, ...)
          bufnr = vim._resolve_bufnr(bufnr)
          cb(bufnr, lang, ...)
          if vim.bo[bufnr].ft ~= 'tex' and lang ~= 'latex' then
            return
          end
          -- Re-enable regex syntax highlighting after starting treesitter
          vim.bo[bufnr].syntax = 'on'
        end
      end)(vim.treesitter.start)
    end,
    postload = function()
      if vim.env.TERM == 'linux' then
        vim.g.vimtex_syntax_conceal_disable = true
      end

      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_format_enabled = 1
      vim.g.vimtex_imaps_enabled = 0
      vim.g.vimtex_mappings_prefix = '<LocalLeader>l'

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'tex',
        group = vim.api.nvim_create_augroup('my.vimtex.settings', {}),
        callback = function(args)
          -- Make surrounding delimiters large
          vim.keymap.set('n', 'css', vim.fn['vimtex#delim#add_modifiers'], {
            buffer = args.buf,
            desc = 'Surround with large delimiters',
          })
          -- Remove default `]]` mapping in insert mode as it causes lagging
          -- when typing `]`
          pcall(vim.keymap.del, 'i', ']]', {
            buffer = args.buf,
          })
        end,
      })

      -- Explicitly set view method for forward and inverse search
      local viewer = (function()
        if vim.fn.executable('xdg-mime') == 1 then
          local o = vim
            .system({ 'xdg-mime', 'query', 'default', 'application/pdf' })
            :wait()
          if o.stdout:find('zathura') then
            return 'zathura'
          end
          if o.stdout:find('okular') then
            return 'okular'
          end
        end
        if vim.fn.executable('zathura') == 1 then
          return 'zathura'
        end
        if vim.fn.executable('okular') == 1 then
          return 'okular'
        end
      end)()

      if viewer == 'zathura' then
        vim.g.vimtex_view_method = 'zathura'
        vim.g.vimtex_auto_sync_view_debounce = 0
      elseif viewer == 'okular' then
        vim.g.vimtex_view_general_viewer = 'okular'
        vim.g.vimtex_view_general_options = '--unique file:@pdf#src:@line@tex'
      end
    end,
  },
}
