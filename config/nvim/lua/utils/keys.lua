local M = {}

-- Text object: folds
---Returns the key sequence to select around/inside a fold,
---supposed to be called in visual mode
---@param motion 'i'|'a'
---@return string
function M.textobj_fold(motion)
  local lnum = vim.fn.line('.') --[[@as integer]]
  local sel_start = vim.fn.line('v')
  local lev = vim.fn.foldlevel(lnum)
  local levp = vim.fn.foldlevel(lnum - 1)
  -- Multi-line selection with cursor on top of selection
  if sel_start > lnum then
    return (lev == 0 and 'zk' or lev > levp and levp > 0 and 'k' or '')
      .. vim.v.count1
      .. (motion == 'i' and ']zkV[zj' or ']zV[z')
  end
  return (lev == 0 and 'zj' or lev > levp and 'j' or '')
    .. vim.v.count1
    .. (motion == 'i' and '[zjV]zk' or '[zV]z')
end

---Go to the first line of current paragraph
function M.goto_paragraph_firstline()
  local chunk_size = 10
  local linenr = vim.fn.line('.')
  local count = vim.v.count1

  -- If current line is the first line of paragraph, move one line
  -- upwards first to goto the first line of previous paragraph
  if linenr >= 2 then
    local lines = vim.api.nvim_buf_get_lines(0, linenr - 2, linenr, false)
    if lines[1]:match('^$') and lines[2]:match('%S') then
      linenr = linenr - 1
    end
  end

  while linenr >= 1 do
    local chunk = vim.api.nvim_buf_get_lines(
      0,
      math.max(0, linenr - chunk_size - 1),
      linenr - 1,
      false
    )
    for i, line in ipairs(vim.iter(chunk):rev():totable()) do
      local current_linenr = linenr - i
      if line:match('^$') then
        count = count - 1
        if count <= 0 then
          vim.cmd.normal({ "m'", bang = true })
          vim.cmd(tostring(current_linenr + 1))
          return
        end
      elseif current_linenr <= 1 then
        vim.cmd.normal({ "m'", bang = true })
        vim.cmd('1')
        return
      end
    end
    linenr = linenr - chunk_size
  end
end

---Go to the last line of current paragraph
function M.goto_paragraph_lastline()
  local chunk_size = 10
  local linenr = vim.fn.line('.')
  local buf_line_count = vim.api.nvim_buf_line_count(0)
  local count = vim.v.count1

  -- If current line is the last line of paragraph, move one line
  -- downwards first to goto the last line of next paragraph
  if buf_line_count - linenr >= 1 then
    local lines = vim.api.nvim_buf_get_lines(0, linenr - 1, linenr + 1, false)
    if lines[1]:match('%S') and lines[2]:match('^$') then
      linenr = linenr + 1
    end
  end

  while linenr <= buf_line_count do
    local chunk =
      vim.api.nvim_buf_get_lines(0, linenr, linenr + chunk_size, false)
    for i, line in ipairs(chunk) do
      local current_linenr = linenr + i
      if line:match('^$') then
        count = count - 1
        if count <= 0 then
          vim.cmd.normal({ "m'", bang = true })
          vim.cmd(tostring(current_linenr - 1))
          return
        end
      elseif current_linenr >= buf_line_count then
        vim.cmd.normal({ "m'", bang = true })
        vim.cmd(tostring(buf_line_count))
        return
      end
    end
    linenr = linenr + chunk_size
  end
end

---Close floating windows with a given key, supposed to be used in a keymap
--- 1. If current window is a floating window, close it and return
--- 2. Else, close all floating windows that can be focused
--- 3. Fallback to `key` if no floating window can be focused
---@param key string
function M.close_floats(key)
  local current_win = vim.api.nvim_get_current_win()

  -- Only close current win if it's a floating window
  if vim.fn.win_gettype(current_win) == 'popup' then
    vim.api.nvim_win_close(current_win, true)
    return
  end

  -- Else close all focusable floating windows in current tab page
  local win_closed = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if
      vim.fn.win_gettype(win) == 'popup'
      and vim.api.nvim_win_get_config(win).focusable
    then
      vim.api.nvim_win_close(win, false) -- do not force
      win_closed = true
    end
  end

  -- If no floating window is closed, fallback
  if not win_closed then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(key, true, true, true),
      'n',
      false
    )
  end
end

---Yank text with paragraphs joined as a single line, supposed to be used in a
---keymap
function M.yank_joined_paragraphs()
  local reg = vim.v.register

  local join_paragraphs_autocmd = vim.api.nvim_create_autocmd('TextYankPost', {
    once = true,
    callback = function()
      local joined_lines = {}
      local joined_line ---@type string?

      for _, line in
        ipairs(vim.v.event.regcontents --[=[@as string[]]=])
      do
        if line ~= '' then
          joined_line = (joined_line and joined_line .. ' ' or '')
            .. vim.trim(line)
          goto continue
        end
        table.insert(joined_lines, joined_line)
        table.insert(joined_lines, line)
        joined_line = nil
        ::continue::
      end
      table.insert(joined_lines, joined_line)

      vim.fn.setreg(reg, joined_lines, vim.v.event.regtype)
    end,
  })

  if vim.startswith(vim.fn.mode(), 'n') then
    -- If joined paragraph yank runs successfully in normal mode, the following
    -- events will trigger in order:
    -- 1. `ModeChanged` with pattern 'n:no'
    -- 2. `TextYankPost`
    -- 3. `ModeChanged` with pattern 'no:n'
    --
    -- If joined paragraph yank is canceled, e.g. with `gy<Esc>` in normal mode,
    -- the following events will  trigger in order:
    -- 1. `ModeChanged` with pattern 'n:no'
    -- 2. `ModeChanged` with pattern 'no:n'
    --
    -- So remove the `TextYankPost` autocmd that joins each paragraph as a
    -- single line after changing from operator pending mode 'no' to normal mode
    -- 'n' to prevent it from affecting normal yanking e.g. with `y`
    vim.api.nvim_create_autocmd('ModeChanged', {
      once = true,
      pattern = 'no:n',
      callback = function()
        pcall(vim.api.nvim_del_autocmd, join_paragraphs_autocmd)
      end,
    })
  end

  vim.api.nvim_feedkeys('y', 'n', false)
end

return M
