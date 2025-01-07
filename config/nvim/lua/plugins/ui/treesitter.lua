return {
  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = "FileType",
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treeitter** module to be loaded in time.
      -- Luckily, the only thins that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require "nvim-treesitter.query_predicates"
    end,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require "nvim-treesitter.textobjects.move" ---@type table<string,fun(...)>
          local configs = require "nvim-treesitter.configs"
          for name, fn in pairs(move) do
            if name:find "goto" == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find "[%]%[][cC]" then
                      vim.cmd("normal! " .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
      },
      "RRethy/nvim-treesitter-endwise",
      { "nushell/tree-sitter-nu", build = ":TSUpdate nu" },
      -- { "the-mikedavis/tree-sitter-git-config", build = ":TSUpdate git_config" },
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    },
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "arduino",
        "asm",
        "bash",
        "comment",
        "css",
        "csv",
        "cuda",
        "diff",
        "dot",
        "elixir",
        "fennel",
        "fortran",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "gpg",
        "graphql",
        "hjson",
        "html",
        "http",
        "hyprlang",
        "ini",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "luau",
        "markdown",
        "markdown_inline",
        "meson",
        "ninja",
        "nix",
        "pem",
        "perl",
        "printf",
        "query",
        "rasi",
        "regex",
        "scss",
        "sql",
        "ssh_config",
        "toml",
        "tsx",
        "typescript",
        "udev",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "yuck",
        "zathurarc",
        -- "jsonet",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["ii"] = "@conditional.inner",
            ["ai"] = "@conditional.outer",
            ["il"] = "@loop.inner",
            ["al"] = "@loop.outer",
            ["at"] = "@comment.outer",
            -- You can also use captures from other query groups like `locals.scm`
            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
          },
        },
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
        },
      },
      endwise = {
        enable = true,
      },
    },
    ---@param opts TSConfig
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      ---@param buf integer
      ---@return nil
      local function enable_ts_folding(buf)
        -- Treesitter folding is extremely slow in large files,
        -- making typing and undo lag as hell
        if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].bigfile then
          return
        end
        vim.api.nvim_buf_call(buf, function()
          local o = vim.opt_local
          local fdm = o.fdm:get() ---@diagnostic disable-line: undefined-field
          local fde = o.fde:get() ---@diagnostic disable-line: undefined-field
          o.fdm = fdm == "manual" and "expr" or fdm
          o.fde = fde == "0" and "nvim_treesitter#foldexpr()" or fde
        end)
      end

      enable_ts_folding(0)

      -- Set treesitter folds
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TSFolds", {}),
        callback = function(info)
          enable_ts_folding(info.buf)
        end,
      })
      vim.schedule(function()
        require("nvim-treesitter.configs").setup(opts)
      end)
    end,
  },

  -- Automatically add closing tags for HTML and JSX
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = true,
  },
}
