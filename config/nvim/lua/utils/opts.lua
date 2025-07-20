local M = {}

---@param args table
---@return string[]
function M.qftf(args)
  local qflist = args.quickfix == 1
      and vim.fn.getqflist({ id = args.id, items = 0 }).items
    or vim.fn.getloclist(args.winid, { id = args.id, items = 0 }).items

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

return M
