local M = {}

---Detect the case style of a string
---@param str string
---@return 'snake'|'lisp'|'camel'|'pascal'|'dot'|nil case_type 'snake', 'camel', 'pascal', 'lisp', 'dot', or `nil` if ambiguous
function M.detect_case(str)
  if str == '' then
    return nil
  end

  local has_underscore = str:find('_')
  local has_hyphen = str:find('-')
  local has_dot = str:find('%.')

  -- Check for single separator types
  if has_dot and not has_underscore and not has_hyphen then
    return 'dot'
  end

  if has_hyphen and not has_underscore and not has_dot then
    return 'lisp'
  end

  if has_underscore and not has_hyphen and not has_dot then
    return 'snake'
  end

  -- Mixed separators, ambiguous
  if has_underscore or has_hyphen or has_dot then
    return
  end

  local first_char = str:sub(1, 1)
  local has_upper = str:find('%u')
  local has_lower = str:find('%l')

  if first_char:match('%u') and has_lower then
    return 'pascal'
  end

  if first_char:match('%l') and has_upper then
    return 'camel'
  end
end

---Convert a snake_case string to camelCase
---@param str string
---@return string
function M.snake_to_camel(str)
  return (str:gsub('_%l', string.upper):gsub('_', ''))
end

---Convert a snake_case string to PascalCase
---@param str string
---@return string
function M.snake_to_pascal(str)
  return (
    str:gsub('^%l', string.upper):gsub('_%l', string.upper):gsub('_', '')
  )
end

---Convert a camelCase string to snake_case
---@param str string
---@return string
function M.camel_to_snake(str)
  return (str:gsub('%u', '_%1'):gsub('^_', ''):lower())
end

---Convert a camelCase string to PascalCase
---@param str string
---@return string
function M.camel_to_pascal(str)
  return (str:gsub('^%l', string.upper))
end

---Convert a camelCase string to lisp-case
---@param str string
---@return string
function M.camel_to_lisp(str)
  return (str:gsub('%u', '-%1'):gsub('^-', ''):lower())
end

---Convert a snake_case string to lisp-case
---@param str string
---@return string
function M.snake_to_lisp(str)
  return (str:gsub('_', '-'))
end

---Convert a lisp-case string to snake_case
---@param str string
---@return string
function M.lisp_to_snake(str)
  return (str:gsub('-', '_'))
end

---Convert a lisp-case string to camelCase
---@param str string
---@return string
function M.lisp_to_camel(str)
  return (str:gsub('-%l', string.upper):gsub('-', ''))
end

---Convert a lisp-case string to PascalCase
---@param str string
---@return string
function M.lisp_to_pascal(str)
  return (
    str:gsub('^%l', string.upper):gsub('-%l', string.upper):gsub('-', '')
  )
end

---Convert a PascalCase string to snake_case
---@param str string
---@return string
function M.pascal_to_snake(str)
  return (str:gsub('%u', '_%1'):gsub('^_', ''):lower())
end

---Convert a PascalCase string to camelCase
---@param str string
---@return string
function M.pascal_to_camel(str)
  return (str:gsub('^%u', string.lower))
end

---Convert a PascalCase string to lisp-case
---@param str string
---@return string
function M.pascal_to_lisp(str)
  return (str:gsub('%u', '-%1'):gsub('^-', ''):lower())
end

---Convert a snake_case string to dot.case
---@param str string
---@return string
function M.snake_to_dot(str)
  return (str:gsub('_', '.'))
end

---Convert a camelCase string to dot.case
---@param str string
---@return string
function M.camel_to_dot(str)
  return (str:gsub('%u', '.%1'):gsub('^%.', ''):lower())
end

---Convert a PascalCase string to dot.case
---@param str string
---@return string
function M.pascal_to_dot(str)
  return (str:gsub('%u', '.%1'):gsub('^%.', ''):lower())
end

---Convert a lisp-case string to dot.case
---@param str string
---@return string
function M.lisp_to_dot(str)
  return (str:gsub('-', '.'))
end

---Convert a dot.case string to snake_case
---@param str string
---@return string
function M.dot_to_snake(str)
  return (str:gsub('%.', '_'))
end

---Convert a dot.case string to camelCase
---@param str string
---@return string
function M.dot_to_camel(str)
  return (str:gsub('%.%l', string.upper):gsub('%.', ''))
end

---Convert a dot.case string to PascalCase
---@param str string
---@return string
function M.dot_to_pascal(str)
  return (
    str:gsub('^%l', string.upper):gsub('%.%l', string.upper):gsub('%.', '')
  )
end

---Convert a dot.case string to lisp-case
---@param str string
---@return string
function M.dot_to_lisp(str)
  return (str:gsub('%.', '-'))
end

-- Generate `to_{case_type}` functions
for _, target_case_type in ipairs({ 'snake', 'lisp', 'pascal', 'camel', 'dot' }) do
  M['to_' .. target_case_type] = function(str)
    local current_case_type = M.detect_case(str)
    if not current_case_type or current_case_type == target_case_type then
      return str
    end
    return M[('%s_to_%s'):format(current_case_type, target_case_type)](str)
  end
end

---Escape all magic characters in lua pattern-matching syntax
---@param str string string to escape
---@return string
function M.escape_magic(str)
  return (str:gsub('[$^()%%.%[%]*+-?]', '%%%1'))
end

return M
