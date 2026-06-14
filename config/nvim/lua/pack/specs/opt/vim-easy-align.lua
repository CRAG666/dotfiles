---@type pack.spec
return {
  src = 'https://github.com/junegunn/vim-easy-align',
  data = {
    keys = {
      {
        lhs = 'gl',
        mode = { 'n', 'x' },
        opts = { desc = 'Align text' },
      },
      {
        lhs = 'gL',
        mode = { 'n', 'x' },
        opts = { desc = 'Align text interactively' },
      },
    },
    postload = function()
      vim.g.easy_align_delimiters = {
        ['\\'] = {
          pattern = [[\\\+]],
        },
        ['/'] = {
          pattern = [[//\+\|/\*\|\*/]],
          delimiter_align = 'c',
          ignore_groups = '!Comment',
        },
      }

      vim.keymap.set(
        { 'n', 'x' },
        'gl',
        '<Plug>(EasyAlign)',
        { noremap = false, desc = 'Align text' }
      )
      vim.keymap.set(
        { 'n', 'x' },
        'gL',
        '<Plug>(LiveEasyAlign)',
        { noremap = false, desc = 'Align text interactively' }
      )
    end,
  },
}
