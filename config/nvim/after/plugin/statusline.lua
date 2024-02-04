launched_by_user = function()
  local parent_process =
    vim.fn.system(string.format("ps -o ppid= -p %s | xargs ps -o comm= -p | tr -d '\n'", vim.fn.getpid()))
  return parent_process == "-fish"
end

---Get the name of the current branch
---@return string | nil
local function get_branch_name()
  local branch = vim.fn.system "git branch --show-current 2> /dev/null"
  if branch ~= "" and launched_by_user() then
    return branch:gsub("\n", "")
  else
    return nil
  end
end

---Get name of the current file
---@return string
local function get_file_name()
  local root_path = vim.loop.cwd()
  local root_dir = root_path:match "[^/]+$"
  local home_path = vim.fn.expand "%:~"
  local overlap, _ = home_path:find(root_dir)
  if home_path == "" then
    return root_path:gsub(vim.env.HOME, "~")
  elseif overlap then
    return home_path:sub(overlap)
  else
    return home_path
  end
end

---Set buffer variables for branch and file names as frequently as they may change
vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "FocusGained" }, {
  group = vim.api.nvim_create_augroup("statusline", { clear = true }),
  callback = function()
    vim.b.branch_name = get_branch_name()
    vim.b.file_name = get_file_name()
  end,
})

---Get instance and count of search matches
---@return string | nil
local function get_search_count()
  if vim.v.hlsearch == 1 and vim.api.nvim_get_mode().mode:match "n" then
    local search_count = vim.fn.searchcount { maxcount = 0 }
    return ("%d/%d"):format(search_count.current, search_count.total)
  else
    return nil
  end
end

---Get formatted and highlighted string of diagnostic counts
---@return string | nil
local function get_diagnostics()
  local diagnostics = vim.diagnostic.get(0)
  if #diagnostics == 0 or vim.api.nvim_get_mode().mode:match "^i" then
    return nil
  end

  local severities = {
    ERROR = { match = "Error", count = 0 },
    WARN = { match = "Warn", count = 0 },
    HINT = { match = "Hint", count = 0 },
    INFO = { match = "Info", count = 0 },
  }

  for _, v in ipairs(diagnostics) do
    for k, _ in pairs(severities) do
      if v.severity == vim.diagnostic.severity[k] then
        severities[k].count = severities[k].count + 1
      end
    end
  end

  local output = {}
  for _, v in pairs(severities) do
    if v.count > 0 then
      table.insert(
        output,
        table.concat {
          "%#DiagnosticVirtualText",
          v.match,
          "#",
          v.count,
          "%*",
        }
      )
    end
  end

  table.sort(output, function(a, b)
    local sort_order = { Error = 1, Warn = 2, Hint = 3, Info = 4 }
    local a_sev = a:match "(%u%l+)#"
    local b_sev = b:match "(%u%l+)#"

    return sort_order[a_sev] < sort_order[b_sev]
  end)

  return table.concat(output, " ")
end

---Get location in current buffer as a percentage
---@return string
local function get_progress()
  local p = vim.api.nvim_eval_statusline("%p", {}).str
  if p == "0" then
    return "top"
  elseif p == "100" then
    return "bot"
  else
    return ("%02d%s"):format(p, "%%")
  end
end

---Format string for left side of statusline
---@param branch string | nil
---@param file string | nil
---@return string
local function generate_left(branch, file)
  branch = branch or vim.b.branch_name
  file = file or vim.b.file_name

  local left = {}
  if branch then
    table.insert(left, branch)
  end
  table.insert(left, file)
  left = { table.concat(left, " | ") }

  local modified_flag = vim.api.nvim_eval_statusline("%m", {}).str
  if modified_flag ~= "" then
    table.insert(left, modified_flag)
  end

  return table.concat(left, " ")
end

---Truncate branch and file names for narrow window
---@param overflow number
---@return string | nil
---@return string
local function truncate(overflow)
  local min_width = 15
  local new_branch = vim.b.branch_name
  local new_file = vim.b.file_name

  if vim.b.branch_name and vim.b.branch_name:len() > min_width then
    if vim.b.branch_name:len() - overflow >= min_width then
      new_branch = vim.b.branch_name:sub(1, (overflow + 1) * -1)
      overflow = 0
    else
      new_branch = vim.b.branch_name:sub(1, min_width)
      overflow = overflow - vim.b.branch_name:sub(min_width + 1):len()
    end
    new_branch = new_branch:gsub(".$", ">")
  end

  if overflow > 0 and vim.b.file_name:len() > min_width then
    if vim.b.file_name:len() - overflow >= min_width then
      new_file = vim.b.file_name:sub(overflow + 1)
    else
      new_file = vim.b.file_name:sub(vim.b.file_name:len() - min_width + 1)
    end
    new_file = new_file:gsub("^.", "<")
  end

  return new_branch, new_file
end

---Generate statusline
---@return string
function Status_Line()
  local left_string = generate_left()
  local left_string_length = vim.api.nvim_eval_statusline(left_string, { maxwidth = 0 }).width

  local right_table = {}
  local search_count = get_search_count()
  if search_count then
    table.insert(right_table, search_count)
  end
  local diagnostics = get_diagnostics()
  if diagnostics then
    table.insert(right_table, diagnostics)
  end
  if vim.b.gitsigns_status and vim.b.gitsigns_status ~= "" then
    table.insert(right_table, vim.b.gitsigns_status)
  end
  table.insert(right_table, vim.api.nvim_eval_statusline("%Y", {}).str:lower())
  table.insert(right_table, get_progress())
  local right_string = table.concat(right_table, " | ")
  local right_string_length = vim.api.nvim_eval_statusline(right_string, {}).width

  local divider = " | "
  local length = left_string_length + divider:len() + right_string_length
  local overflow = length - vim.api.nvim_win_get_width(0)
  if overflow < 0 then
    divider = "%="
  end
  if overflow > 0 then
    local trunc_branch, trunc_file = truncate(overflow)
    left_string = generate_left(trunc_branch, trunc_file)
  end

  return table.concat { "%<", left_string, divider, right_string }
end

vim.o.statusline = "%{%v:lua.Status_Line()%}"
