---@type pack.spec
return {
  src = 'https://github.com/tpope/vim-projectionist',
  data = {
    events = 'BufReadPre',
    postload = function()
      -- Keymaps
      vim.keymap.set(
        'n',
        '<C-_>',
        '<Cmd>A<CR>',
        { desc = 'Edit alternate file' }
      )

      -- Extra transformers
      vim.cmd([=[
        if !exists('g:projectionist_transformations')
          let g:projectionist_transformations = {}
        endif

        " Remove first slash separated component
        function! g:projectionist_transformations.tail(input, o) abort
          return substitute(a:input, '\(\/\)*[^/]\+\/*', '\1', '')
        endfunction

        " Remove all but first slash separated component
        function! g:projectionist_transformations.head(input, o) abort
          return matchstr(a:input, '\(\/\)*[^/]\+')
        endfunction

        " Remove last extension
        function! g:projectionist_transformations.root(input, o) abort
          return fnamemodify(a:input, ':r')
        endfunction

        " Get last extension
        function! g:projectionist_transformations.extension(input, o) abort
          return fnamemodify(a:input, ':e')
        endfunction
      ]=])

      -- Lazy load projections for each filetype
      require('utils.load').ft_auto_load_once(
        'pack.res.vim-projectionist.projections',
        function(_, projections)
          if not projections then
            return
          end
          vim.g.projectionist_heuristics = vim.tbl_deep_extend(
            'force',
            vim.g.projectionist_heuristics or {},
            projections
          )
        end
      )
    end,
  },
}
