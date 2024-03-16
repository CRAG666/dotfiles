function get_keys()
  local keys = {
    { "<leader><leader>do", ":DiffviewOpen<CR>", desc = "Diff [o]pen" },
    { "<leader><leader>dc", ":DiffviewClose<CR>", desc = "Diff [c]lose" },
    { "<leader><leader>dh", ":DiffviewFileHistory<CR>", desc = "Diff close" },
  }
  for i = 9, 1, -1 do
    keys[#keys + 1] = {
      string.format("<leader><leader>d%d", i),
      string.format(":DiffviewOpen HEAD~%d<CR>", i),
      desc = string.format("Diff Open HEAD~%d<CR>", i),
    }
  end
  return keys
end

return {
  {
    "sindrets/diffview.nvim",
    keys = get_keys(),
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    keys = { { "<leader>gm", "<cmd>Neogit<CR>", desc = "[g]it [m]ode" } },
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim", -- optional
    },
    config = true,
  },
}
