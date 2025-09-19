return {
  src = 'https://github.com/saghen/blink.cmp',
  data = {
    deps = {
      {
        src = 'https://github.com/L3MON4D3/LuaSnip',
        data = { optional = true },
      },
      {
        src = 'https://github.com/kyazdani42/nvim-web-devicons',
        data = { optional = true },
      },
    },
    -- https://github.com/Saghen/blink.cmp/issues/145#issuecomment-2483686337
    -- https://github.com/Saghen/blink.cmp/issues/145#issuecomment-2492759016
    build = string.format(
      '%s cargo build --release',
      vim.env.TERMUX_VERSION
          and 'RUSTC_BOOTSTRAP=1 RUSTFLAGS="-C link-args=-lluajit"'
        or ''
    ),
    events = { 'InsertEnter', 'CmdlineEnter' },
    postload = function()
      local icons = require('utils.static.icons')
      local has_ls, ls = pcall(require, 'luasnip')
      local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
      local blink_source_utils = require('blink.cmp.sources.lib.utils')
      local blink_ctx = require('blink.cmp.completion.trigger.context')

      ---@param ctx blink.cmp.DrawItemContext
      ---@return boolean
      local function is_file_compl(ctx)
        return ctx.source_id == 'path'
          -- Opencode has slash commands (starting with `/`) and file references,
          -- both provided by the 'opencode_mentions' source. Show file icons only
          -- for file require.
          or ctx.source_id == 'opencode_mentions' and not vim.startswith(
            ctx.label,
            '/'
          )
          or vim.tbl_contains(
            { 'dir', 'file', 'file_in_path', 'runtime' },
            blink_source_utils.get_completion_type(blink_ctx.get_mode())
          )
      end

      ---@param items blink.cmp.CompletionItem[]
      ---@return boolean
      local function is_expr_compl(items)
        return items[1] and items[1].source_id == 'cmdline'
          or vim.tbl_contains(
            { 'function', 'expression' },
            blink_source_utils.get_completion_type(blink_ctx.get_mode())
          )
      end

      ---@param path string
      ---@return boolean
      local function is_directory(path)
        return vim.endswith(path, '/') or vim.fn.isdirectory(path) == 1
      end

      require('blink.cmp').setup({
        enabled = function()
          return vim.fn.reg_recording() == '' and vim.fn.reg_executing() == ''
        end,
        fuzzy = {
          -- Don't error when rust fuzzy lib is unavailable
          implementation = 'prefer_rust',
        },
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,
            window = {
              border = 'solid',
            },
          },
          menu = {
            min_width = vim.go.pumwidth,
            max_height = vim.go.pumheight,
            draw = {
              columns = not vim.g.has_nf and {
                { 'label' },
                { 'kind_icon' },
                { 'label_description' },
              } or nil,
              components = {
                kind_icon = {
                  ellipsis = false,
                  -- Show different icons for files/directories, use
                  -- nvim-web-devicons to show filetype icons if possible
                  text = function(ctx)
                    if not is_file_compl(ctx) then
                      return icons[ctx.kind] --[[@as string]]
                    end

                    if is_directory(ctx.item.label) then
                      return icons.Folder
                    end

                    return has_devicons
                        and (devicons.get_icon(
                          ctx.item.label,
                          vim.fn.fnamemodify(ctx.item.label, ':e'),
                          { default = true }
                        ))
                      or icons.File
                  end,
                  highlight = function(ctx)
                    if not is_file_compl(ctx) then
                      return ctx.kind_hl
                    end

                    if is_directory(ctx.item.label) then
                      return 'BlinkCmpKindFolder'
                    end

                    return has_devicons
                        and ({
                          devicons.get_icon(
                            ctx.item.label,
                            vim.fn.fnamemodify(ctx.item.label, ':e'),
                            { default = true }
                          ),
                        })[2]
                      or 'BlinkCmpKindFile'
                  end,
                },
              },
            },
          },
        },
        ---@type table<string, (blink.cmp.KeymapCommand|fun(cmp: blink.cmp.API): boolean?)[]|false>
        keymap = {
          ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
          ['<C-p>'] = {
            'select_prev',
            function(cmp)
              if not has_ls or not ls.choice_active() then
                return cmp.show()
              end
            end,
            'fallback', -- change luasnip choice node, see `lua/configs/luasnip.lua`
          },
          ['<C-n>'] = {
            'select_next',
            function(cmp)
              if not has_ls or not ls.choice_active() then
                return cmp.show()
              end
            end,
            'fallback',
          },
          -- Managed by snippet config and tabout plugin, see
          -- - `lua/configs/luasnip.lua`
          -- - `lua/plugin/tabout.lua`
          ['<Tab>'] = false,
          ['<S-Tab>'] = false,
          -- Conflict with readline's keymap, see `lua/plugin/readline.lua`
          ['<C-k>'] = false,
          ['<C-s>'] = { 'show_signature', 'fallback' },
          -- Hide both signature help and completion menu with `<C-e>`
          ['<C-e>'] = {
            function(cmp)
              local hide_success = cmp.hide()
              local hide_signature_success = cmp.hide_signature()
              return hide_success or hide_signature_success
            end,
            'fallback',
          },
        },
        cmdline = {
          completion = {
            list = {
              selection = {
                preselect = false,
                auto_insert = true,
              },
            },
          },
        },
        signature = {
          enabled = true,
        },
        snippets = {
          preset = has_ls and 'luasnip' or 'default',
        },
        sources = {
          default = {
            'snippets',
            'lsp',
            'path',
            'buffer',
          },
          providers = {
            lsp = {
              -- Don't wait for LSP completions for a long time before fallback to
              -- buffer completions
              -- - https://github.com/Saghen/blink.cmp/issues/2042
              -- - https://cmp.saghen.dev/configuration/sources.html#show-buffer-completions-with-lsp
              timeout_ms = 500,
            },
            cmdline = {
              -- Don't complete left parenthesis when calling functions or
              -- expressions in cmdline, e.g. `:call func(...`
              transform_items = function(_, items)
                if not is_expr_compl(items) then
                  return items
                end

                for _, item in ipairs(items) do
                  item.textEdit.newText = item.textEdit.newText:gsub('%($', '')
                  item.label = item.textEdit.newText
                end
                return items
              end,
            },
            buffer = {
              -- Keep first letter capitalization on buffer source
              -- https://cmp.saghen.dev/recipes.html#keep-first-letter-capitalization-on-buffer-source
              transform_items = function(ctx, items)
                local keyword = ctx.get_keyword()
                if not (keyword:match('^%l') or keyword:match('^%u')) then
                  return items
                end

                local pattern ---@type string
                local case_func ---@type function
                if keyword:match('^%l') then
                  pattern = '^%u%l+$'
                  case_func = string.lower
                else
                  pattern = '^%l+$'
                  case_func = string.upper
                end

                local seen = {}
                local out = {}
                for _, item in ipairs(items) do
                  if not item.insertText then
                    goto continue
                  end

                  if item.insertText:match(pattern) then
                    local text = case_func(item.insertText:sub(1, 1))
                      .. item.insertText:sub(2)
                    item.insertText = text
                    item.label = text
                  end

                  if seen[item.insertText] then
                    goto continue
                  end
                  seen[item.insertText] = true

                  table.insert(out, item)
                  ::continue::
                end
                return out
              end,
            },
          },
        },
      })

      require('utils.hl').persist(function()
        -- stylua: ignore start
        vim.api.nvim_set_hl(0, 'BlinkCmpKindClass',       { link = '@type',               default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindConstant',    { link = '@constant',           default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindConstructor', { link = '@constructor',        default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindEnum',        { link = '@constant',           default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindEnumMember',  { link = '@constant',           default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindFile',        { link = 'Special',             default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindFolder',      { link = 'Directory',           default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindFunction',    { link = '@function',           default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindInterface',   { link = '@type',               default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindKey',         { link = '@keyword',            default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindKeyword',     { link = '@keyword',            default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindMethod',      { link = '@function',           default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindModule',      { link = '@module',             default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindOperator',    { link = '@operator',           default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindProperty',    { link = '@attribute',          default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindSnippet',     { link = '@diff.plus',          default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindString',      { link = '@string',             default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindStruct',      { link = '@type',               default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindText',        { link = '@string',             default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindValue',       { link = '@number',             default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpKindVariable',    { link = 'Special',             default = true })
        vim.api.nvim_set_hl(0, 'BlinkCmpLabelDeprecated', { link = '@lsp.mod.deprecated', default = true })
        -- stylua: ignore end
      end)
    end,
  },
}
