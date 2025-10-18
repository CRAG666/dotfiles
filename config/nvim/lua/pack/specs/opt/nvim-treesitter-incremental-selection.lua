---@type pack.spec
return {
  src = 'https://github.com/shushtain/nvim-treesitter-incremental-selection',
  data = {
    events = 'FileType',
    postload = function()
      local key = require('utils.key')
      local tsis = require('nvim-treesitter-incremental-selection')

      tsis.setup()

      ---Use lsp `textDocument/selectionRange` method by default for
      ---incremental/decremental selection if having capable clients attached
      ---with treesitter as fallback
      ---@param cb function treesitter range selection function
      local function lsp_range_sel_wrap(cb)
        ---@param fallback function
        return function(fallback)
          if
            not vim.tbl_isempty(vim.lsp.get_clients({
              bufnr = 0,
              method = 'textDocument/selectionRange',
            }))
          then
            fallback()
            return
          end
          cb()
        end
      end

      key.amend('x', 'in', lsp_range_sel_wrap(tsis.decrement_node))
      key.amend(
        'x',
        'an',
        lsp_range_sel_wrap(function()
          if not vim.b._ts_incr_sel_initialized then
            vim.b._ts_incr_sel_initialized = true
            tsis.init_selection()
          end
          tsis.increment_node()
        end)
      )

      vim.api.nvim_create_autocmd('ModeChanged', {
        desc = 'Clear treesitter selection range after exiting visual mode.',
        group = vim.api.nvim_create_augroup(
          'my.nvim-treesitter-incremental-selection.clear_selection',
          {}
        ),
        pattern = '[vV\x16]:*',
        callback = function(args)
          vim.b[args.buf]._ts_incr_sel_initialized = nil
        end,
      })
    end,
  },
}
