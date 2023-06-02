function get_keys()
  local keys = {
    { ",do", ":DiffviewOpen<CR>", desc = "Diff Open" },
    { ",dc", ":DiffviewClose<CR>", desc = "Diff Close" },
    { ",dh", ":DiffviewFileHistory<CR>", desc = "Diff Close" },
  }
  for i = 9, 1, -1 do
    keys[#keys + 1] = {
      string.format(",d%d", i),
      string.format(":DiffviewOpen HEAD~%d<CR>", i),
      desc = string.format("Diff Open HEAD~%d<CR>", i),
    }
  end
  return keys
end

return {
  "sindrets/diffview.nvim",
  keys = get_keys(),
  dependencies = "nvim-lua/plenary.nvim",
  config = true,
}
