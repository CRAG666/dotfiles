local M = {}

---Set attributes for a single snippet
---@param snip table
---@param attr table
function M.snip_set_attr(snip, attr)
  for attr_key, attr_val in pairs(attr) do
    if type(snip[attr_key]) == 'table' and type(attr_val) == 'table' then
      snip[attr_key] = vim.tbl_deep_extend('keep', snip[attr_key], attr_val)
    else
      snip[attr_key] = attr_val
    end
  end
end

---Add attributes to a snippet group
---@param attr table
---@param snip_group table
---@return table
function M.add_attr(attr, snip_group)
  for _, snip in ipairs(snip_group) do
    -- ls.multi_snippet
    if snip.v_snips then
      for _, s in ipairs(snip.v_snips) do
        M.snip_set_attr(s, attr)
      end
    else -- ls.snippet
      M.snip_set_attr(snip, attr)
    end
  end
  return snip_group
end

---Returns the depth of the current indent given the indent of the current line
---@param indent? number|string
---@return number
function M.get_indent_depth(indent)
  if not indent then
    return 0
  end
  if type(indent) == 'string' then
    indent = #indent:match('^%s*'):gsub('\t', string.rep(' ', vim.bo.ts))
  end
  if indent <= 0 then
    return 0
  end
  local sts
  if vim.bo.sts > 0 then
    sts = vim.bo.sts
  elseif vim.bo.sw > 0 then
    sts = vim.bo.sw
  else
    sts = vim.bo.ts
  end
  return math.floor(indent / sts)
end

---Returns a string for indentation at the given depth
---@param depth number|fun(...): number
---@vararg any same as arguments passed to function/dynamic node, e.g. argnode_texts, parent/snip, [old_state, user_args]
---@return string
function M.get_indent_str(depth, ...)
  if type(depth) == 'function' then
    depth = depth(...)
  end

  if depth <= 0 then
    return ''
  end

  local sw = vim.fn.shiftwidth()
  return vim.bo.expandtab and string.rep(' ', sw * depth)
    or string.rep('\t', math.floor(sw * depth / vim.bo.ts))
      .. string.rep(' ', sw * depth % vim.bo.ts)
end

---Returns the character after the cursor
---@return string
function M.get_char_after()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return line:sub(col, col)
end

---Get which quotation mark (single or double) is preferred in current buffer
---@param buf? integer
---@param default? '"'|"'"
---@return '"'|"'"
function M.get_quotation_type(buf, default)
  buf = vim._resolve_bufnr(buf)
  default = default or "'"

  if not vim.api.nvim_buf_is_valid(buf) then
    return default
  end

  local b = vim.b[buf]
  if b._ls_quote_type then
    return b._ls_quote_type
  end

  local num_double_quotes = 0
  local num_single_quotes = 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    num_double_quotes = num_double_quotes + line:gsub('[^"]', ''):len()
    num_single_quotes = num_single_quotes + line:gsub("[^']", ''):len()
  end

  local quote = num_double_quotes > num_single_quotes and '"'
    or num_double_quotes < num_single_quotes and "'"
    or default
  if num_double_quotes + num_single_quotes > 0 then
    b._ls_quote_type = quote
  end

  return quote
end

return M
