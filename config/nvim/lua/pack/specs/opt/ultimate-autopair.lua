return {
  src = 'https://github.com/altermo/ultimate-autopair.nvim',
  data = {
    events = { 'InsertEnter', 'CmdlineEnter' },
    postload = function()
      local ap_utils = require('ultimate-autopair.utils')

      ---Filetype options memoization
      ---@type table<string, table<string, string|integer|boolean|table>>
      local ft_opts = vim.defaulttable(function()
        return {}
      end)

      ---Get option value for given filetype, with memoization for performance
      ---This fixes sluggish `<CR>` in markdown files
      ---TODO: upstream to ultimate-autopair
      ---@param ft string
      ---@param opt string
      ---@diagnostic disable-next-line: duplicate-set-field
      ap_utils.ft_get_option = function(ft, opt)
        local opts = ft_opts[ft]
        local opt_val = opts[opt]
        if opt_val ~= nil then
          return opt_val
        end

        opt_val = vim.F.npcall(vim.filetype.get_option, ft, opt) or vim.bo[opt]
        opts[opt] = opt_val
        return opt_val
      end

      ap_utils.getsmartft = (function(cb)
        return function(o, notree, ...)
          return cb(o, vim.b.bigfile or notree, ...)
        end
      end)(ap_utils.getsmartft)

      ---Record previous cmdline completion types,
      ---`cmdcompltype[1]` is the current completion type,
      ---`cmdcompltype[2]` is the previous completion type
      ---@type string[]
      local compltype = {}

      vim.api.nvim_create_autocmd('CmdlineChanged', {
        desc = 'Record cmd compltype to determine whether to autopair.',
        group = vim.api.nvim_create_augroup(
          'my.ultimate-autopair.record_cmdcompltype',
          {}
        ),
        callback = function()
          local type = vim.fn.getcmdcompltype()
          if compltype[1] == type then
            return
          end
          compltype[2] = compltype[1]
          compltype[1] = type
        end,
      })

      require('ultimate-autopair').setup({
        extensions = {
          suround = false,
          -- Improve performance when typing fast, see
          -- https://github.com/altermo/ultimate-autopair.nvim/issues/74
          utf8 = false,
          cond = {
            cond = function(f)
              return not f.in_macro()
                and (
                  not f.in_cmdline()
                  -- Disable autopairs when inserting a regex, e.g.
                  -- `:s/{pattern}/{string}/[flags]` or `:g/{pattern}/[cmd]`, etc.
                  or (compltype[2] ~= 'command' or compltype[1] ~= '')
                )
            end,
          },
        },
        { '[=[', ']=]', ft = { 'lua' } },
        { '<<<', '>>>', ft = { 'cuda' } },
        {
          '/*',
          '*/',
          ft = { 'c', 'cpp', 'cuda', 'go' },
          newline = true,
          space = true,
        },
        {
          '<',
          '>',
          disable_start = true,
          disable_end = true,
        },
        {
          '>',
          '<',
          ft = { 'html', 'xml', 'markdown' },
          disable_start = true,
          disable_end = true,
          newline = true,
          space = true,
        },
        -- Paring '$' and '*' are handled by snippets,
        -- only use autopair to delete matched pairs here
        {
          '$',
          '$',
          ft = { 'markdown', 'tex' },
          disable_start = true,
          disable_end = true,
        },
        {
          '*',
          '*',
          ft = { 'markdown' },
          disable_start = true,
          disable_end = true,
        },
        {
          '\\left(',
          '\\right)',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\left[',
          '\\right]',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\left{',
          '\\right}',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\left<',
          '\\right>',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\left\\lfloor',
          '\\right\\rfloor',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\left\\lceil',
          '\\right\\rceil',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\left\\vert',
          '\\right\\vert',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\left\\lVert',
          '\\right\\rVert',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\left\\lVert',
          '\\right\\rVert',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\begin{bmatrix}',
          '\\end{bmatrix}',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
        {
          '\\begin{pmatrix}',
          '\\end{pmatrix}',
          newline = true,
          space = true,
          ft = { 'markdown', 'tex' },
        },
      })
    end,
  },
}
