if vim.g.loaded_markdown_title ~= nil then
  return
end

local utils = require('utils')

if vim.g.md_fmt_title == nil then
  vim.g.md_fmt_title = true
end

-- Export the word list to global so that other parts of the config
-- (e.g. markdown snippets) can access it
_G._title_lowercase_words = {
  ['a'] = true,
  ['an'] = true,
  ['and'] = true,
  ['as'] = true,
  ['at'] = true,
  ['but'] = true,
  ['by'] = true,
  ['can'] = true,
  ['etc'] = true,
  ['for'] = true,
  ['if'] = true,
  ['in'] = true,
  ['is'] = true,
  ['nor'] = true,
  ['of'] = true,
  ['off'] = true,
  ['on'] = true,
  ['or'] = true,
  ['per'] = true,
  ['so'] = true,
  ['than'] = true,
  ['the'] = true,
  ['to'] = true,
  ['up'] = true,
  ['via'] = true,
  ['vs'] = true,
  ['was'] = true,
  ['were'] = true,
  ['with'] = true,
  ['yet'] = true,
}

---Capitalize the first letter of words on title line
---@return nil
local function format_title()
  if
    vim.bo.filetype ~= 'markdown'
    or vim.b.md_fmt_title == false
    or (vim.g.md_fmt_title == false and vim.b.md_fmt_title == nil)
  then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()

  -- Don't use treesitter/syntax to check title if current line does not start
  -- with '#', improves performance on non-title lines
  if not vim.startswith(line, '#') then
    return
  end

  -- Don't capitalize if not in a heading
  -- Also, don't capitalize if inside inline code (``) or latex equations ($$)
  if utils.ts.is_active() then
    if
      not utils.ts.find_node('heading')
      or utils.ts.find_node(
        { 'code_span', 'formula', 'equation', 'math' },
        { ignore_injections = false }
      )
    then
      return
    end
  elseif
    utils.syn.is_active()
    and (
      not utils.syn.find_group('H%d$')
      or utils.syn.find_group({
        'Code',
        'MathZone',
      })
    )
  then
    return
  end

  local word = line:sub(1, cursor[2]):match('[%w_]+$')
  if word == nil then
    return
  end

  local is_first = line:match('^#+%s+([%w_]+)$') == word
  local word_lower = word:lower()
  local should_upper = is_first or not _G._title_lowercase_words[word_lower]

  if should_upper then
    local word_upper = word:sub(1, 1):upper() .. word:sub(2)
    if word_upper ~= word then
      vim.api.nvim_buf_set_text(
        0,
        cursor[1] - 1,
        cursor[2] - #word,
        cursor[1] - 1,
        cursor[2],
        { word_upper }
      )
    end
  elseif word ~= word_lower then
    -- Replace the word before cursor when it should be all lower-cased but not
    -- This can happen after we finished typing a word in the lower-cased words
    -- list, e.g. 'is': after typing 'i', the word captured is 'i' which is not
    -- in the list and is capitalized (assuming it is not the first word in the
    -- title); then we type 's', the word captured is 'Is' which is in the list
    -- but not lower-cased, we need to fix this by replacing 'Is' with 'is'
    vim.api.nvim_buf_set_text(
      0,
      cursor[1] - 1,
      cursor[2] - #word,
      cursor[1] - 1,
      cursor[2],
      { word_lower }
    )
  end
end

local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_create_autocmd('TextChangedI', {
  group = vim.api.nvim_create_augroup(
    string.format('my.ft.markdown.format_title.buf.%d', buf),
    {}
  ),
  buffer = buf,
  callback = format_title,
})

vim.api.nvim_buf_create_user_command(
  buf,
  'MarkdownAutoFormatTitle',
  function(args)
    local parsed_args = utils.cmd.parse_cmdline_args(args.fargs)
    local scope = vim[parsed_args.global and 'g' or 'b']
    if scope.md_fmt_title == nil then
      scope.md_fmt_title = vim.g.md_fmt_title
    end
    if args.bang or vim.tbl_contains(parsed_args, 'toggle') then
      scope.md_fmt_title = not scope.md_fmt_title
      return
    end
    if args.fargs[1] == '&' or vim.tbl_contains(parsed_args, 'reset') then
      scope.md_fmt_title = true
      return
    end
    if args.fargs[1] == '?' or vim.tbl_contains(parsed_args, 'status') then
      vim.notify(tostring(scope.md_fmt_title))
      return
    end
    if vim.tbl_contains(parsed_args, 'enable') then
      scope.md_fmt_title = true
      return
    end
    if vim.tbl_contains(parsed_args, 'disable') then
      scope.md_fmt_title = false
      return
    end
  end,
  {
    nargs = '*',
    bang = true,
    complete = utils.cmd.complete({
      'enable',
      'disable',
      'toggle',
      'status',
    }, {
      ['global'] = { 'v:true', 'v:false' },
      ['local'] = { 'v:true', 'v:false' },
    }),
    desc = 'Set whether to automatically capitalize the first letter of words in markdown titles',
  }
)
