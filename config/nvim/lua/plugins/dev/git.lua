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
    keys = {
      {
        "<leader>gm",
        function()
          require("neogit").open()
        end,
        desc = "[g]it [m]ode",
      },
      {
        "<leader>gc",
        function()
          require("neogit").open { "commit" }
        end,
        desc = "[g]it [c]ommit",
      },
      {
        "<leader>gp",
        function()
          require("neogit").open { "pull" }
        end,
        desc = "[g]it [p]ull",
      },
      {
        "<leader>gP",
        function()
          require("neogit").open { "push" }
        end,
        desc = "[g]it [p]ush",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim", -- optional
    },
    config = true,
  },
}
