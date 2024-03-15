local M = {}

---Wrapper of nvim_get_hl(), but does not create a highlight group
---if it doesn't exist (default to opts.create = false), and add
---new option opts.winhl_link to get highlight attributes without
---being affected by winhl
---@param ns_id integer
---@param opts table{ name: string?, id: integer?, link: boolean? }
---@return vim.api.keyset.hl_info: highlight attributes
function M.get(ns_id, opts)
  local no_winhl_link = opts.winhl_link == false
  opts.winhl_link = nil
  opts.create = opts.create or false
  local attr = vim.api.nvim_get_hl(ns_id, opts)
  -- We want to get true highlight attribute not affected by winhl
  if no_winhl_link then
    while attr.link do
      opts.name = attr.link
      attr = vim.api.nvim_get_hl(ns_id, opts)
    end
  end
  return attr
end

---Wrapper of nvim_buf_add_highlight(), but does not create a cleared
---highlight group if it doesn't exist
---@param buffer integer buffer handle, or 0 for current buffer
---@param ns_id integer namespace to use or -1 for ungrouped highlight
---@param hl_group string name of the highlight group to use
---@param line integer line to highlight (zero-indexed)
---@param col_start integer start of (byte-indexed) column range to highlight
---@param col_end integer end of (byte-indexed) column range to highlight, or -1 to highlight to end of line
---@return nil
function M.buf_add_hl(buffer, ns_id, hl_group, line, col_start, col_end)
  if vim.fn.hlexists(hl_group) == 0 then
    return
  end
  vim.api.nvim_buf_add_highlight(
    buffer,
    ns_id,
    hl_group,
    line,
    col_start,
    col_end
  )
end

---Highlight text in buffer, clear previous highlight if any exists
---@param buf integer
---@param hlgroup string
---@param range winbar_symbol_range_t?
function M.range_single(buf, hlgroup, range)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local ns = vim.api.nvim_create_namespace(hlgroup)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if range then
    for linenr = range.start.line, range['end'].line do
      local start_col = linenr == range.start.line and range.start.character
        or 0
      local end_col = linenr == range['end'].line and range['end'].character
        or -1
      M.buf_add_hl(buf, ns, hlgroup, linenr, start_col, end_col)
    end
  end
end

---Highlight a line in buffer, clear previous highlight if any exists
---@param buf integer
---@param hlgroup string
---@param linenr integer? 1-indexed line number
function M.line_single(buf, hlgroup, linenr)
  M.range_single(buf, hlgroup, linenr and {
    start = {
      line = linenr - 1,
      character = 0,
    },
    ['end'] = {
      line = linenr - 1,
      character = -1,
    },
  })
end

---Merge highlight attributes, use values from the right most hl group
---if there are conflicts
---@vararg string highlight group names
---@return vim.api.keyset.highlight: merged highlight attributes
function M.merge(...)
  -- Eliminate nil values in vararg
  local hl_names = {}
  for _, hl_name in pairs({ ... }) do
    if hl_name then
      table.insert(hl_names, hl_name)
    end
  end
  local hl_attr = vim.tbl_map(function(hl_name)
    return M.get(0, {
      name = hl_name,
      winhl_link = false,
    })
  end, hl_names)
  return vim.tbl_extend('force', unpack(hl_attr))
end

---@param attr_type 'fg'|'bg'|'ctermfg'|'ctermbg'
---@param fbg? string|integer
---@param default? integer
---@return integer|string|nil
function M.normalize_fg_or_bg(attr_type, fbg, default)
  if not fbg then
    return default
  end
  local data_type = type(fbg)
  if data_type == 'number' then
    if attr_type:match('^cterm') then
      return fbg >= 0 and fbg <= 255 and fbg or default
    end
    return fbg
  end
  if data_type == 'string' then
    if vim.fn.hlexists(fbg) == 1 then
      return M.get(0, {
        name = fbg,
        winhl_link = false,
      })[attr_type]
    end
    if fbg:match('^#%x%x%x%x%x%x$') then
      if attr_type:match('^cterm') then
        return default
      end
      return fbg
    end
  end
  return default
end

---Normalize highlight attributes
---1. Replace `attr.fg` and `attr.bg` with their corresponding color codes
---   if they are set to highlight group names
---2. If `attr.link` used in combination with other attributes, will first
---   retrieve the attributes of the linked highlight group, then merge
---   with other attributes
---Side effect: change `attr` table
---@param attr vim.api.keyset.highlight highlight attributes
---@return table: normalized highlight attributes
function M.normalize(attr)
  if attr.link then
    local num_keys = #vim.tbl_keys(attr)
    if num_keys <= 1 then
      return attr
    end
    attr.fg = M.normalize_fg_or_bg('fg', attr.fg)
    attr.bg = M.normalize_fg_or_bg('bg', attr.bg)
    attr = vim.tbl_extend('force', M.get(0, {
      name = attr.link,
      winhl_link = false,
    }) or {}, attr)
    attr.link = nil
    return attr
  end
  local fg = attr.fg
  local bg = attr.bg
  local ctermfg = attr.ctermfg
  local ctermbg = attr.ctermbg
  attr.fg = M.normalize_fg_or_bg('fg', fg)
  attr.bg = M.normalize_fg_or_bg('bg', bg)
  attr.ctermfg = M.normalize_fg_or_bg('ctermfg', ctermfg or fg)
  attr.ctermbg = M.normalize_fg_or_bg('ctermbg', ctermbg or bg)
  return attr
end

---Wrapper of nvim_set_hl(), normalize highlight attributes before setting
---@param ns_id integer namespace id
---@param name string
---@param attr vim.api.keyset.highlight highlight attributes
---@return nil
function M.set(ns_id, name, attr)
  return vim.api.nvim_set_hl(ns_id, name, M.normalize(attr))
end

---Set default highlight attributes, normalize highlight attributes before setting
---@param ns_id integer namespace id
---@param name string
---@param attr vim.api.keyset.highlight highlight attributes
---@return nil
function M.set_default(ns_id, name, attr)
  attr.default = true
  return vim.api.nvim_set_hl(ns_id, name, M.normalize(attr))
end

local todec = {
  ['0'] = 0,
  ['1'] = 1,
  ['2'] = 2,
  ['3'] = 3,
  ['4'] = 4,
  ['5'] = 5,
  ['6'] = 6,
  ['7'] = 7,
  ['8'] = 8,
  ['9'] = 9,
  ['a'] = 10,
  ['b'] = 11,
  ['c'] = 12,
  ['d'] = 13,
  ['e'] = 14,
  ['f'] = 15,
  ['A'] = 10,
  ['B'] = 11,
  ['C'] = 12,
  ['D'] = 13,
  ['E'] = 14,
  ['F'] = 15,
}

---Convert an integer from hexadecimal to decimal
---@param hex string
---@return integer dec
function M.hex2dec(hex)
  local digit = 1
  local dec = 0
  while digit <= #hex do
    dec = dec + todec[string.sub(hex, digit, digit)] * 16 ^ (#hex - digit)
    digit = digit + 1
  end
  return dec
end

---Convert an integer from decimal to hexadecimal
---@param int integer
---@param n_digits integer? number of digits used for the hex code
---@return string hex
function M.dec2hex(int, n_digits)
  return not n_digits and string.format('%x', int)
    or string.format('%0' .. n_digits .. 'x', int)
end

---Convert a hex color to rgb color
---@param hex string hex code of the color
---@return integer[] rgb
function M.hex2rgb(hex)
  return {
    M.hex2dec(string.sub(hex, 1, 2)),
    M.hex2dec(string.sub(hex, 3, 4)),
    M.hex2dec(string.sub(hex, 5, 6)),
  }
end
---Convert an rgb color to hex color
---@param rgb integer[]
---@return string
function M.rgb2hex(rgb)
  local hex = {
    M.dec2hex(math.floor(rgb[1])),
    M.dec2hex(math.floor(rgb[2])),
    M.dec2hex(math.floor(rgb[3])),
  }
  hex = {
    string.rep('0', 2 - #hex[1]) .. hex[1],
    string.rep('0', 2 - #hex[2]) .. hex[2],
    string.rep('0', 2 - #hex[3]) .. hex[3],
  }
  return table.concat(hex, '')
end

---Blend two colors
---@param c1 string|number|table the first color, in hex, dec, or rgb
---@param c2 string|number|table the second color, in hex, dec, or rgb
---@param alpha number? between 0~1, weight of the first color, default to 0.5
---@return { hex: string, dec: integer, r: integer, g: integer, b: integer }
function M.cblend(c1, c2, alpha)
  alpha = alpha or 0.5
  c1 = type(c1) == 'number' and M.dec2hex(c1, 6) or c1
  c2 = type(c2) == 'number' and M.dec2hex(c2, 6) or c2
  local rgb1 = type(c1) == 'string' and M.hex2rgb(c1:gsub('#', '', 1)) or c1
  local rgb2 = type(c2) == 'string' and M.hex2rgb(c2:gsub('#', '', 1)) or c2
  local rgb_blended = {
    alpha * rgb1[1] + (1 - alpha) * rgb2[1],
    alpha * rgb1[2] + (1 - alpha) * rgb2[2],
    alpha * rgb1[3] + (1 - alpha) * rgb2[3],
  }
  local hex = M.rgb2hex(rgb_blended)
  return {
    hex = '#' .. hex,
    dec = M.hex2dec(hex),
    r = math.floor(rgb_blended[1]),
    g = math.floor(rgb_blended[2]),
    b = math.floor(rgb_blended[3]),
  }
end

---Blend two hlgroups
---@param h1 string|table the first hlgroup name or highlight attribute table
---@param h2 string|table the second hlgroup name or highlight attribute table
---@param alpha number? between 0~1, weight of the first color, default to 0.5
---@return table: merged color or highlight attributes
function M.blend(h1, h2, alpha)
  -- stylua: ignore start
  h1 = type(h1) == 'table' and h1 or M.get(0, { name = h1, winhl_link = false })
  h2 = type(h2) == 'table' and h2 or M.get(0, { name = h2, winhl_link = false })
  local fg = h1.fg and h2.fg and M.cblend(h1.fg, h2.fg, alpha).dec or h1.fg or h2.fg
  local bg = h1.bg and h2.bg and M.cblend(h1.bg, h2.bg, alpha).dec or h1.bg or h2.bg
  return vim.tbl_deep_extend('force', h1, h2, { fg = fg, bg = bg })
  -- stylua: ignore end
end

return M
