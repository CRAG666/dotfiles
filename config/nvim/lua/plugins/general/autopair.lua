return {
  'altermo/ultimate-autopair.nvim',
  event = { 'InsertEnter', 'CmdlineEnter' },
  branch = 'v0.6', --recommended as each new version will have breaking changes
  config = function()
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
    require('ultimate-autopair.utils').ft_get_option = function(ft, opt)
      local opts = ft_opts[ft]
      local opt_val = opts[opt]
      if opt_val ~= nil then
        return opt_val
      end

      opt_val = vim.F.npcall(vim.filetype.get_option, ft, opt) or vim.bo[opt]
      opts[opt] = opt_val
      return opt_val
    end

    ---Get next two characters after cursor
    ---@return string: next two characters
    local function get_next_two_chars()
      local col, line
      if vim.startswith(vim.fn.mode(), 'c') then
        col = vim.fn.getcmdpos()
        line = vim.fn.getcmdline()
      else
        col = vim.fn.col('.')
        line = vim.api.nvim_get_current_line()
      end
      return line:sub(col, col + 1)
    end

    -- Matches strings that start with:
    -- keywords: \k
    -- opening pairs: (, [, {, \(, \[, \{
    local IGNORE_REGEX = vim.regex([=[^\%(\k\|\\\?[([{]\)]=])

    require('ultimate-autopair').setup({
      extensions = {
        suround = false,
        -- Improve performance when typing fast, see
        -- https://github.com/altermo/ultimate-autopair.nvim/issues/74
        utf8 = false,
        cond = {
          cond = function(f)
            return not f.in_macro()
              -- Disable autopairs if followed by a keyword or an opening pair
              and not IGNORE_REGEX:match_str(get_next_two_chars())
          end,
        },
      },
      { '\\(', '\\)', newline = true },
      { '\\[', '\\]', newline = true },
      { '\\{', '\\}', newline = true },
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
}
