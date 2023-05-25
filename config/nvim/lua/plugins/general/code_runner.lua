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
      desc = "Execute Code",
    },
  },
  opts = {
    mode = "better_term",
    better_term = {
      number = 1,
    },
    filetype = {
      tex = function(...)
        require("code_runner.hooks.preview_pdf").run {
          command = "pdflatex",
          args = { "-output-directory", "/tmp", "$fileName" },
          preview_cmd = "/bin/zathura --fork",
          overwrite_output = "/tmp",
        }
      end,
      markdown = function(...)
        markdownCompileOptions = {
          Normal = "pdf",
          Presentation = "beamer",
          Slides = "",
        }
        vim.ui.select(vim.tbl_keys(markdownCompileOptions), {
          prompt = "Select preview mode:",
        }, function(opt, _)
          if opt then
            if opt == "Slides" then
              local filename = vim.fn.expand "%:p"
              os.execute("kitty slides " .. filename .. " &> /dev/null &")
              return
            end
            require("code_runner.hooks.preview_pdf").run {
              command = "pandoc",
              args = { "$fileName", "-o", "$tmpFile", "-t", markdownCompileOptions[opt] },
              preview_cmd = "/bin/zathura --fork",
            }
          else
            print "Not Preview"
          end
        end)
      end,
      javascript = "node",
      java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
      kotlin = "cd $dir && kotlinc-native $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt.kexe",
      c = {
        "cd $dir &&",
        "gcc $fileName",
        "-o $fileNameWithoutExt &&",
        "$dir/$fileNameWithoutExt",
      },
      cpp = {
        "cd $dir &&",
        "g++ $fileName",
        "-o /tmp/$fileNameWithoutExt &&",
        "/tmp/$fileNameWithoutExt",
      },
      python = "python -u",
      sh = "bash",
      typescript = "deno run",
      typescriptreact = "yarn dev$end",
      rust = "cd $dir && rustc $fileName && $dir$fileNameWithoutExt",
      dart = "dart",
      cs = function(...)
        local root_dir = require("lspconfig").util.root_pattern "*.csproj"(vim.loop.cwd())
        return "cd " .. root_dir .. " && dotnet run$end"
      end,
    },
    project_path = vim.fn.expand "~/.config/nvim/project_manager.json",
  },
}
