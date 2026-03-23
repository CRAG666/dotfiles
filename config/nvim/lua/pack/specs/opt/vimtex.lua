---@type pack.spec
return {
  src = 'https://github.com/lervag/vimtex',
  data = {
    cmds = 'VimtexInverseSearch',
    events = {
      event = 'FileType',
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
      vim.g.vimtex_mappings_prefix = '<leader>l'
      vim.g.vimtex_compiler_method = 'generic'
      vim.g.vimtex_compiler_generic = {
        command = 'true',
      }
      vim.g.vimtex_callback_progpath = vim.v.progpath
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'tex',
        group = vim.api.nvim_create_augroup('vimtex.settings', {}),
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
      if vim.fn.executable('xdg-mime') == 1 then
        vim.system(
          { 'xdg-mime', 'query', 'default', 'application/pdf' },
          {},
          function(o)
            if o.stdout:find('zathura') then
              vim.g.vimtex_view_method = 'general'
              vim.g.vimtex_view_general_viewer = 'zathura-vimtex'
              vim.g.vimtex_view_general_options =
                '--synctex-forward @line:1:@tex @pdf'
            elseif o.stdout:find('okular') then
              vim.g.vimtex_view_general_viewer = 'okular'
              vim.g.vimtex_view_general_options =
                '--unique file:@pdf#src:@line@tex'
            end
          end
        )
      end
    end,
  },
}
