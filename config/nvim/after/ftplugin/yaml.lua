if vim.bo.ft == 'yaml.gh' then
  return
end

-- Set filetype to 'yaml.gh' for GitHub workflow and action YAML files to
-- enable special operations (e.g., attaching `actionlint` linter, see
-- `after/lsp/actionlint`) since they are different from regular YAML files
local bufname = vim.api.nvim_buf_get_name(0)
for _, dir in ipairs({ 'workflows', 'actions' }) do
  if bufname:find(('/.github/%s/'):format(dir), 1, true) then
    vim.bo.ft = 'yaml.gh'
    break
  end
end
