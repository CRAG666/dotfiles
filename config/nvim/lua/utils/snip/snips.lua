local ls = require('luasnip')
local conds = require('utils.snip.conds')

-- Map snippet attribute string to snippet attribute options
local snip_attr_map = {
  w = { wordTrig = true },
  W = { wordTrig = false },
  -- cmp_luasnip cannot handle snippets with regex triggers, see
  -- https://github.com/L3MON4D3/LuaSnip/issues/931
  r = {
    regTrig = true,
    hidden = true,
    trigEngineOpts = {
      max_len = 80,
    },
  },
  R = { regTrig = false },
  h = { hidden = true },
  H = { hidden = false },
  a = { snippetType = 'autosnippet' },
  A = { snippetType = 'snippet' },
  m = {
    condition = conds.in_mathzone,
    show_condition = conds.in_mathzone,
  },
  M = {
    condition = -conds.in_mathzone,
    show_condition = -conds.in_mathzone,
  },
  n = {
    condition = conds.in_normalzone,
    show_condition = conds.in_normalzone,
  },
  N = {
    condition = -conds.in_normalzone,
    show_condition = -conds.in_normalzone,
  },
  s = {
    condition = conds.at_line_start,
    show_condition = conds.at_line_start,
  },
  i = {
    condition = conds.at_line_start_with_indent,
    show_condition = conds.at_line_start_with_indent,
  },
  S = {
    condition = -conds.at_line_start,
    show_condition = -conds.at_line_start,
  },
  e = {
    condition = conds.at_line_end,
    show_condition = conds.at_line_end,
  },
  E = {
    condition = -conds.at_line_end,
    show_condition = -conds.at_line_end,
  },
  -- After text block
  b = {
    condition = conds.after_pattern('[%w%d%)%]%}%>]%s*'),
    show_condition = conds.after_pattern('[%w%d%)%]%}%>]%s*'),
  },
  B = {
    condition = -conds.after_pattern('[%w%d%)%]%}%>]%s*'),
    show_condition = -conds.after_pattern('[%w%d%)%]%}%>]%s*'),
  },
}

---Add new snippet attribute option to snippet attributes table
---@param snip_attr table
---@param opt_key string
---@param opt_val any
local function snip_attr_add_new_opt(snip_attr, opt_key, opt_val)
  if opt_val == nil then
    return
  end
  local opt_orig_val = snip_attr[opt_key]
  if opt_orig_val == nil then
    snip_attr[opt_key] = opt_val
    return
  end
  if opt_key:match('condition$') then
    snip_attr[opt_key] = opt_orig_val * opt_val
    return
  end
  if type(opt_orig_val) == 'table' and type(opt_val) == 'table' then
    snip_attr[opt_key] = vim.tbl_deep_extend('force', opt_orig_val, opt_val)
    return
  end
  snip_attr[opt_key] = opt_val
end

return setmetatable({}, {
  __index = function(self, snip_name)
    local snip_attr_str = snip_name:gsub('^m?s', '')
    local snip_attr = {}
    for i = 1, #snip_attr_str do
      local snip_attr_opts = snip_attr_map[snip_attr_str:sub(i, i)]
      if snip_attr_opts then
        for attr_opt_key, attr_opt_val in pairs(snip_attr_opts) do
          snip_attr_add_new_opt(snip_attr, attr_opt_key, attr_opt_val)
        end
      end
    end
    if snip_name:match('^m') then
      self[snip_name] = ls.extend_decorator.apply(ls.multi_snippet, {
        common = snip_attr,
      })
    else
      self[snip_name] = ls.extend_decorator.apply(ls.snippet, snip_attr)
    end
    return self[snip_name]
  end,
})
