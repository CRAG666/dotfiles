local M = {}

---See `:h 'quickfixtextfunc'`
---@param info table
---@return string[]
function M.qftf(info)
  local qflist = info.quickfix == 1
      and vim.fn.getqflist({ id = info.id, items = 0 }).items
    or vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items

  if vim.tbl_isempty(qflist) then
    return {}
  end

  local fname_str_cache = {}
  local lnum_str_cache = {}
  local col_str_cache = {}
  local type_str_cache = {}
  local nr_str_cache = {}

  local fname_width_cache = {}
  local lnum_width_cache = {}
  local col_width_cache = {}
  local type_width_cache = {}
  local nr_width_cache = {}

  ---Traverse the qflist and get the maximum display width of the
  ---transformed string; cache the transformed string and its width
  ---in table `str_cache` and `width_cache` respectively
  ---@param trans fun(item: table): string|number
  ---@param max_width_allowed integer?
  ---@param str_cache table
  ---@param width_cache table
  ---@return integer
  local function _traverse(trans, max_width_allowed, str_cache, width_cache)
    max_width_allowed = max_width_allowed or math.huge
    local max_width_seen = 0
    for i, item in ipairs(qflist) do
      local str = tostring(trans(item))
      local width = vim.fn.strdisplaywidth(str)
      str_cache[i] = str
      width_cache[i] = width
      if width > max_width_seen then
        max_width_seen = width
      end
    end
    return math.min(max_width_allowed, max_width_seen)
  end

  ---@param item table
  ---@return string
  local function _fname_trans(item)
    local bufnr = item.bufnr
    local module = item.module
    local filename = item.filename
    return module and module ~= '' and module
      or filename and filename ~= '' and filename
      or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':~:.')
  end

  ---@param item table
  ---@return string|integer
  local function _lnum_trans(item)
    if item.lnum == item.end_lnum or item.end_lnum == 0 then
      return item.lnum
    end
    return string.format('%s-%s', item.lnum, item.end_lnum)
  end

  ---@param item table
  ---@return string|integer
  local function _col_trans(item)
    if item.col == item.end_col or item.end_col == 0 then
      return item.col
    end
    return string.format('%s-%s', item.col, item.end_col)
  end

  local type_sign_map = {
    E = 'ERROR',
    W = 'WARN',
    I = 'INFO',
    N = 'HINT',
  }

  ---@param item table
  ---@return string
  local function _type_trans(item)
    -- Sometimes `item.type` will contain unprintable characters,
    -- e.g. items in the qflist of `:helpg vim`
    local type = (type_sign_map[item.type] or item.type):gsub('[^%g]', '')
    return type == '' and '' or ' ' .. type
  end

  ---@param item table
  ---@return string
  local function _nr_trans(item)
    return item.nr <= 0 and '' or ' ' .. item.nr
  end

  -- stylua: ignore start
  local max_width = math.ceil(vim.go.columns / 2)
  local fname_width = _traverse(_fname_trans, max_width, fname_str_cache, fname_width_cache)
  local lnum_width = _traverse(_lnum_trans, max_width, lnum_str_cache, lnum_width_cache)
  local col_width = _traverse(_col_trans, max_width, col_str_cache, col_width_cache)
  local type_width = _traverse(_type_trans, max_width, type_str_cache, type_width_cache)
  local nr_width = _traverse(_nr_trans, max_width, nr_str_cache, nr_width_cache)
  -- stylua: ignore end

  local lines = {} ---@type string[]
  local format_str = vim.go.termguicolors and '%s %s:%s%s%s %s'
    or '%s│%s:%s%s%s│ %s'

  local function _fill_item(idx, item)
    local fname = fname_str_cache[idx]
    local fname_cur_width = fname_width_cache[idx]

    if item.lnum == 0 and item.col == 0 and item.text == '' then
      table.insert(lines, fname)
      return
    end

    local lnum = lnum_str_cache[idx]
    local col = col_str_cache[idx]
    local type = type_str_cache[idx]
    local nr = nr_str_cache[idx]

    local lnum_cur_width = lnum_width_cache[idx]
    local col_cur_width = col_width_cache[idx]
    local type_cur_width = type_width_cache[idx]
    local nr_cur_width = nr_width_cache[idx]

    table.insert(
      lines,
      string.format(
        format_str,
        -- Do not use `string.format()` here because it only allows
        -- at most 99 characters for alignment and alignment is
        -- based on byte length instead of display length
        fname .. string.rep(' ', fname_width - fname_cur_width),
        string.rep(' ', lnum_width - lnum_cur_width) .. lnum,
        col .. string.rep(' ', col_width - col_cur_width),
        type .. string.rep(' ', type_width - type_cur_width),
        nr .. string.rep(' ', nr_width - nr_cur_width),
        item.text
      )
    )
  end

  for i, item in ipairs(qflist) do
    _fill_item(i, item)
  end

  return lines
end

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
---@return nil
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
---@return nil
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
---@return nil
function M.close_floats_keymap(key)
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

return M
