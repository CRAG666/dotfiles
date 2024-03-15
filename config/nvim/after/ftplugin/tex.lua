local utils = require "utils"

local root_files = {
  "Tectonic.toml",
  ".git",
}
root_path = utils.fs.proj_dir(vim.api.nvim_buf_get_name(0), root_files)
build_path = root_path .. "/build/default"
local texlab = {
  name = "texlab",
  cmd = { "texlab" },
  filetypes = { "tex", "plaintex", "bib" },
  root_patterns = {
    "Tectonic.toml",
    ".git",
  },
  single_file_support = true,
  settings = {
    texlab = {
      rootDirectory = root_path,
      build = {
        auxDirectory = build_path, -- Editar
        logDirectory = build_path, -- Editar
        pdfDirectory = build_path, -- Editar
        executable = "tectonic",
        args = { "-X", "build", "--synctex", "-k", "--keep-logs" },
        onSave = true,
      },
      forwardSearch = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
        onSave = true,
      },
      chktex = {
        onOpenAndSave = true,
        onEdit = false,
      },
      diagnosticsDelay = 300,
      latexFormatter = "latexindent",
      bibtexFormatter = "texlab",
      formatterLineLength = 80,
    },
  },
}

local texlab_build_status = vim.tbl_add_reverse_lookup {
  Success = 0,
  Error = 1,
  Failure = 2,
  Cancelled = 3,
}

local texlab_forward_status = vim.tbl_add_reverse_lookup {
  Success = 0,
  Error = 1,
  Failure = 2,
  Unconfigured = 3,
}

local function buf_build(bufnr)
  local texlab_client = utils.get_active_client_by_name(bufnr, "texlab")
  local pos = vim.api.nvim_win_get_cursor(0)
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = { line = pos[1] - 1, character = pos[2] },
  }
  if texlab_client then
    texlab_client.request("textDocument/build", params, function(err, result)
      if err then
        error(tostring(err))
      end
      print("Build " .. texlab_build_status[result.status])
    end, bufnr)
  else
    print "method textDocument/build is not supported by any servers active on the current buffer"
  end
end

local function buf_search(bufnr)
  local texlab_client = utils.get_active_client_by_name(bufnr, "texlab")
  local pos = vim.api.nvim_win_get_cursor(0)
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = { line = pos[1] - 1, character = pos[2] },
  }
  if texlab_client then
    texlab_client.request("textDocument/forwardSearch", params, function(err, result)
      if err then
        error(tostring(err))
      end
      print("Search " .. texlab_forward_status[result.status])
    end, bufnr)
  else
    print "method textDocument/forwardSearch is not supported by any servers active on the current buffer"
  end
end

local function on_attach(client_id, bufnr)
  vim.api.nvim_create_user_command("TexlabView", function()
    buf_search(bufnr)
  end, { desc = "TexlabView" })
  vim.api.nvim_create_user_command("TexlabBuild", function()
    buf_build(bufnr)
  end, { desc = "TexlabBuild" })
  -- local keymap = vim.api.nvim_buf_set_keymap
  -- keymap(bufnr, "n", "<leader>Lv", ":TexlabView<CR>", { noremap = true, silent = true, desc = { "TexlabView" } })
end

require("config.lsp.grammar").setup()
require("config.lsp").setup(texlab, on_attach)
