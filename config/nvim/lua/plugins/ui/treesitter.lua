return {
  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  {
    'nvim-treesitter/nvim-treesitter',
    version = false, -- last release is way too old and doesn't work on Windows
    build = ':TSUpdate',
    event = 'FileType',
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treeitter** module to be loaded in time.
      -- Luckily, the only thins that those plugins need are the custom queries, which we make available
      -- during startup.
      require('lazy.core.loader').add_to_rtp(plugin)
      require('nvim-treesitter.query_predicates')
    end,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require('nvim-treesitter.textobjects.move') ---@type table<string,fun(...)>
          local configs = require('nvim-treesitter.configs')
          for name, fn in pairs(move) do
            if name:find('goto') == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module('textobjects.move')[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find('[%]%[][cC]') then
                      vim.cmd('normal! ' .. key)
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
      'RRethy/nvim-treesitter-endwise',
      { 'nushell/tree-sitter-nu', build = ':TSUpdate nu' },
      -- { "the-mikedavis/tree-sitter-git-config", build = ":TSUpdate git_config" },
    },
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    keys = {
      { '<c-space>', desc = 'Increment selection' },
      { '<bs>',      desc = 'Decrement selection', mode = 'x' },
    },
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
      },
      indent = { enable = true },
      ensure_installed = {
        'arduino',
        'asm',
        'bash',
        'comment',
        'css',
        'csv',
        'cuda',
        'diff',
        'dot',
        'elixir',
        'fennel',
        'fortran',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gpg',
        'graphql',
        'hjson',
        'html',
        'http',
        'hyprlang',
        'ini',
        'javascript',
        'jsdoc',
        'json',
        'json5',
        'jsonc',
        'lua',
        'luadoc',
        'luap',
        'luau',
        'markdown',
        'markdown_inline',
        'meson',
        'ninja',
        'nix',
        'pem',
        'perl',
        'printf',
        'query',
        'rasi',
        'regex',
        'scss',
        'sql',
        'ssh_config',
        'toml',
        'tsx',
        'typescript',
        'udev',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
        'yuck',
        'zathurarc',
        -- "jsonet",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['am'] = '@function.outer',
            ['im'] = '@function.inner',
            ['ao'] = '@loop.outer',
            ['io'] = '@loop.inner',
            ['ak'] = '@class.outer',
            ['ik'] = '@class.inner',
            ['a,'] = '@parameter.outer',
            ['i,'] = '@parameter.inner',
            ['a/'] = '@comment.outer',
            ['a*'] = '@comment.outer',
            ['ag'] = '@block.outer',
            ['ig'] = '@block.inner',
            ['a?'] = '@conditional.outer',
            ['i?'] = '@conditional.inner',
            ['a='] = '@assignment.outer',
            ['i='] = '@assignment.inner',
            ['a#'] = '@header.outer',
            ['i#'] = '@header.inner',
            ['a3'] = '@header.outer',
            ['i3'] = '@header.inner',
          },
          selection_modes = {
            ['@block.outer'] = 'V',
            ['@block.inner'] = 'V',
            ['@header.outer'] = 'V',
            ['@header.inner'] = 'V',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']f'] = '@function.outer',
            [']o'] = '@loop.outer',
            [']]'] = '@function.outer',
            [']c'] = '@class.outer',
            ['],'] = '@parameter.outer',
            [']g'] = '@block.outer',
            [']?'] = '@conditional.outer',
            [']='] = '@assignment.inner',
            [']#'] = '@header.outer',
            [']3'] = '@header.outer',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']O'] = '@loop.outer',
            [']['] = '@function.outer',
            [']C'] = '@class.outer',
            [']<'] = '@parameter.outer',
            [']/'] = '@comment.outer',
            [']*'] = '@comment.outer',
            [']G'] = '@block.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[o'] = '@loop.outer',
            ['[['] = '@function.outer',
            ['[c'] = '@class.outer',
            ['[,'] = '@parameter.outer',
            ['[/'] = '@comment.outer',
            ['[*'] = '@comment.outer',
            ['[g'] = '@block.outer',
            ['[?'] = '@conditional.outer',
            ['[='] = '@assignment.inner',
            ['[#'] = '@header.outer',
            ['[3'] = '@header.outer',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[O'] = '@loop.outer',
            ['[]'] = '@function.outer',
            ['[C'] = '@class.outer',
            ['[<'] = '@parameter.outer',
            ['[G'] = '@block.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<M-C-L>'] = '@parameter.inner',
            ['<M-C-Right>'] = '@parameter.inner',
          },
          swap_previous = {
            ['<M-C-H>'] = '@parameter.inner',
            ['<M-C-Left>'] = '@parameter.inner',
          },
        },
        lsp_interop = {
          enable = true,
          border = 'solid',
          peek_definition_code = {
            ['<C-k>'] = '@function.outer',
          },
        },
      },
      endwise = {
        enable = true,
      },
    },
    ---@param opts TSConfig
    config = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
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
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- Automatically add closing tags for HTML and JSX
  {
    'windwp/nvim-ts-autotag',
    event = 'InsertEnter',
    config = true,
  },
}
