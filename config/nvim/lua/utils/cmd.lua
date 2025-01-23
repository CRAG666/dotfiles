local M = {}

---Recursively build a nested table from a list of keys and a value
---@param key_parts string[] list of keys
---@param val any
---@return table
function M.build_nested(key_parts, val)
  return key_parts[1]
      and { [key_parts[1]] = M.build_nested({ unpack(key_parts, 2) }, val) }
    or val
end

---@class parsed_arg_t table

---Parse arguments from the command line into a table
---@param fargs string[] list of arguments
---@return table
function M.parse_cmdline_args(fargs)
  local parsed = {}
  -- First pass: parse arguments into a plain table
  for _, arg in ipairs(fargs) do
    local key, val = arg:match('^%-%-(%S+)=(.*)$')
    if not key then
      key = arg:match('^%-%-(%S+)$')
    end
    local val_expanded = vim.fn.expand(val)
    if type(val) == 'string' and vim.uv.fs_stat(val_expanded) then
      val = val_expanded
    end
    if key and val then -- '--key=value'
      local eval_valid, eval_result = pcall(vim.fn.eval, val)
      parsed[key] = not eval_valid and val or eval_result
    elseif key and not val then -- '--key'
      parsed[key] = true
    else -- 'value'
      table.insert(parsed, arg)
    end
  end
  -- Second pass: build nested tables from dot-separated keys
  for key, val in pairs(parsed) do
    if type(key) == 'string' then
      local key_parts = vim.split(key, '%.')
      parsed =
        vim.tbl_deep_extend('force', parsed, M.build_nested(key_parts, val))
      if #key_parts > 1 then
        parsed[key] = nil -- Remove the original dot-separated key
      end
    end
  end
  return parsed
end

---options command accepts, in the format of <optkey>=<candicate_optvals>
---or <optkey>
---@alias opts_t table
---@alias params_t string[]

---Get option keys / option names from opts table
---@param opts opts_t
---@return string[]
function M.optkeys(opts)
  local optkeys = {}
  for key, val in pairs(opts) do
    if type(key) == 'number' then
      table.insert(optkeys, val)
    elseif type(key) == 'string' then
      table.insert(optkeys, key)
    end
  end
  return optkeys
end

---Returns a function that can be used to complete the options of a command
---An option must be in the format of --<opt> or --<opt>=<val>
---@param opts opts_t?
---@return fun(arglead: string, cmdline: string, cursorpos: integer): string[]
function M.complete_opts(opts)
  ---@param arglead string leading portion of the argument being completed
  ---@param cmdline string the entire command line
  ---@param cursorpos integer cursor position in the command line
  ---@return string[] completion completion results
  return function(arglead, cmdline, cursorpos)
    if not opts or vim.tbl_isempty(opts) then
      return {}
    end
    local optkey, eq, optval = arglead:match('^%-%-([^%s=]+)(=?)([^%s=]*)$')
    -- Complete option values
    if optkey and eq == '=' then
      local candidate_vals = vim.tbl_map(
        tostring,
        type(opts[optkey]) == 'function'
            and opts[optkey](arglead, cmdline, cursorpos)
          or opts[optkey]
      )
      return candidate_vals
          and vim.tbl_map(
            function(val)
              return '--' .. optkey .. '=' .. val
            end,
            vim.tbl_filter(function(val)
              return val:find(optval, 1, true) == 1
            end, candidate_vals)
          )
        or {}
    end
    -- Complete option keys
    return vim.tbl_filter(
      function(compl)
        return compl:find(arglead, 1, true) == 1
      end,
      vim.tbl_map(function(k)
        return '--' .. k
      end, M.optkeys(opts))
    )
  end
end

---Returns a function that can be used to complete the arguments of a command
---@param params params_t?
---@return fun(arglead: string, cmdline: string, cursorpos: integer): string[]
function M.complete_params(params)
  return function(arglead, _, _)
    return vim.tbl_filter(function(arg)
      return arg:find(arglead, 1, true) == 1
    end, params or {})
  end
end

---Returns a function that can be used to complete the arguments and options
---of a command
---@param params params_t?
---@param opts opts_t?
---@return fun(arglead: string, cmdline: string, cursorpos: integer): string[]
function M.complete(params, opts)
  local fn_compl_params = M.complete_params(params)
  local fn_compl_opts = M.complete_opts(opts)
  return function(arglead, cmdline, cursorpos)
    local param_completions = fn_compl_params(arglead, cmdline, cursorpos)
    local opt_completions = fn_compl_opts(arglead, cmdline, cursorpos)
    return vim.list_extend(param_completions, opt_completions)
  end
end

return M
