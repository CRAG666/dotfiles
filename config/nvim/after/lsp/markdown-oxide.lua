return {
  filetypes = { 'markdown' },
  cmd = { 'markdown-oxide' },
  buf_support = false,
  -- Only in vaults, marksman covers other markdown files
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, '.moxide.toml')
    if root then
      on_dir(root)
    end
  end,
}
