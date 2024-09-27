local preview_cmd = "/bin/zathura --fork"
local folder = ""
return {
  "CRAG666/code_runner.nvim",
  -- name = "code_runner",
  dev = true,
  keys = {
    {
      "<leader>e",
      function()
        require("code_runner").run_code()
      end,
      desc = "[e]xcute code",
    },
  },
  opts = {
    mode = "better_term",
    better_term = {
      number = 1,
    },
    filetype = {
      v = "v run",
      tex = function(...)
        if vim.g.tectonic == nil then
          vim.fn.jobstart "tectonic -X watch -x 'build --keep-intermediates --keep-logs'"
          folder = vim.lsp.buf.list_workspace_folders()[1] .. "/build/default/default.pdf"
          vim.print(folder)
          vim.g.tectonic = 1
        end
        vim.system { "/bin/zathura", "--fork", folder }
      end,
      markdown = function(...)
        local hook = require "code_runner.hooks.preview_pdf"
        require("code_runner.hooks.ui").select {
          Marp = function()
            require("code_runner.commands").run_from_fn "marp --theme-set $MARPT -w -p . &$end"
          end,
          Latex = function()
            hook.run {
              command = "pandoc",
              args = { "$fileName", "-o", "$tmpFile", "-t pdf" },
              preview_cmd = preview_cmd,
            }
          end,
          Beamer = function()
            hook.run {
              command = "pandoc",
              args = { "$fileName", "-o", "$tmpFile", "-t beamer" },
              preview_cmd = preview_cmd,
            }
          end,
          Eisvogel = function()
            hook.run {
              command = "bash",
              args = { "./build.sh" },
              preview_cmd = preview_cmd,
              overwrite_output = ".",
            }
          end,
        }
      end,
      javascript = "node",
      java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
      kotlin = "cd $dir && kotlinc-native $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt.kexe",
      c = function(...)
        c_base = {
          "cd $dir &&",
          "gcc $fileName -o",
          "/tmp/$fileNameWithoutExt",
        }
        local c_exec = {
          "&& /tmp/$fileNameWithoutExt &&",
          "rm /tmp/$fileNameWithoutExt",
        }
        vim.ui.input({ prompt = "Add more args:" }, function(input)
          c_base[4] = input
          vim.print(vim.tbl_extend("force", c_base, c_exec))
          require("code_runner.commands").run_from_fn(vim.list_extend(c_base, c_exec))
        end)
      end,
      -- c = {
      --   "cd $dir &&",
      --   "gcc $fileName -o",
      --   "/tmp/$fileNameWithoutExt &&",
      --   "/tmp/$fileNameWithoutExt &&",
      --   "rm /tmp/$fileNameWithoutExt",
      -- },
      cpp = {
        "cd $dir &&",
        "g++ $fileName",
        "-o /tmp/$fileNameWithoutExt &&",
        "/tmp/$fileNameWithoutExt",
      },
      python = "python -u '$dir/$fileName'",
      sh = "bash",
      typescript = "deno run",
      typescriptreact = "yarn dev$end",
      rust = "cd $dir && rustc $fileName && $dir$fileNameWithoutExt",
      dart = "dart",
      cs = function(...)
        local root_dir = require("null-ls.utils").root_pattern "*.csproj"(vim.loop.cwd())
        return "cd " .. root_dir .. " && dotnet run$end"
      end,
    },
    project_path = vim.fn.expand "~/.config/nvim/project_manager.json",
  },
}
