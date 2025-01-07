---Change directory to the most frequently visited directory using `z`
---@param input string[]
local function z(input)
  local dest = vim.trim(vim.fn.system("z -e " .. table.concat(
    vim.tbl_map(function(path)
      return vim.fn.shellescape(vim.fn.expand(path))
    end, input),
    " "
  )))
  if dest and (vim.uv.fs_stat(dest) or {}).type == "directory" then
    vim.cmd.lcd(vim.fn.fnameescape(dest))
  end
end

---Complete `:Z` command
---@param input string?
---@return string[]
local function cmp(input)
  local candidates = vim.fn.systemlist("z -l " .. vim.fn.shellescape(input or ""))
  local completions = {}
  for _, candidate in ipairs(candidates) do
    local path = candidate:match "^[0-9.]+%s+(.*)" -- trim score
    if path then
      table.insert(completions, path)
    end
  end
  return completions
end

---Setup `:Z` command
local function setup()
  vim.fn.system "z"
  if vim.v.shell_error ~= 0 then
    return
  end

  if vim.g.loaded_z then
    return
  end
  vim.g.loaded_z = true

  vim.api.nvim_create_user_command("Z", function(args)
    z(args.fargs)
  end, {
    nargs = "*",
    desc = "Change local working directory using z.",
    complete = cmp,
  })
end

return {
  z = z,
  cmp = cmp,
  setup = setup,
}
