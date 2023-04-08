return {
    "CRAG666/code_runner.nvim",
    -- name = "code_runner",
    dev = true,
    dependencies = "nvim-lua/plenary.nvim",
    opts = {
      startinsert = true,
      term = {
        -- tab = true,
        size = 15,
      },
      -- filetype_path = vim.fn.expand "~/.config/nvim/code_runner.json",
      filetype = {
        javascript = "node",
        java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
        kotlin = "cd $dir && kotlinc-native $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt.kexe",
        c = "cd $dir && gcc $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
        cpp = "cd $dir && g++ $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
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
