local function setup()
  if vim.g.loaded_expandtab ~= nil then
    return
  end
  vim.g.loaded_expandtab = true

  vim.on_key(function(key)
    if
      key ~= '\t'
      or vim.bo.et
      or vim.fn.match(vim.fn.mode(), [[^i\|^R]]) == -1
    then
      return
    end

    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local after_non_blank = vim.fn.match(line:sub(1, col), [[\S]]) >= 0
    -- An adjacent tab is a tab that can be joined with the tab
    -- inserted before the cursor assuming 'noet' is set
    local has_adjacent_tabs = vim.fn.match(
      line:sub(1, col),
      string.format([[\t\ \{,%d}$]], math.max(0, vim.bo.ts - 1))
    ) >= 0 or line:sub(col + 1, col + 1) == '\t'

    if not after_non_blank or has_adjacent_tabs then
      return
    end

    if vim.b.et == nil then
      vim.b.et = vim.bo.et
    end
    vim.bo.et = true
  end)

  vim.api.nvim_create_autocmd('TextChangedI', {
    group = vim.api.nvim_create_augroup('my.expandtab', {}),
    callback = function(args)
      -- Restore 'expandtab' setting
      if vim.b[args.buf].et == nil then
        return
      end

      vim.bo[args.buf].et = vim.b[args.buf].et
      vim.b[args.buf].et = nil
    end,
  })
end

return {
  setup = setup,
}
