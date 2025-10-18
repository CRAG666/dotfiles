---@type pack.spec
return {
  src = 'https://github.com/tpope/vim-sleuth',
  data = {
    events = { 'BufReadPre', 'StdinReadPre' },
  },
}
