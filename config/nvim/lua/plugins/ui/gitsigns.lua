return {
  "lewis6991/gitsigns.nvim",
  event = "BufReadPre",
  opts = {
    signs = {
      add = { text = Icons.git.status_added },
      change = { text = Icons.git.status_modified },
      delete = { text = Icons.git.status_removed },
      topdelete = { text = Icons.git.topdelete },
      changedelete = { text = Icons.git.topdelete },
      untracked = { text = Icons.git.untracked },
    },
    numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
  },
}
