local icons = require('utils.static.icons')
local key = require('utils.keymap')

-- Supermaven
vim.pack.add({ { src = 'https://github.com/supermaven-inc/supermaven-nvim' } })
require('supermaven-nvim').setup({
  keymaps = {
    accept_suggestion = '<C-CR>',
    clear_suggestion = '<C-BS>',
    accept_word = '<C-J>',
  },
  ignore_filetypes = { 'bigfile' },
})

-- Blink and its dependencies
vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp', version = '1.*' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/jc-doyle/cmp-pandoc-references' },
  {
    src = 'https://github.com/L3MON4D3/LuaSnip',
    build = 'make install_jsregexp',
  },
  { src = 'https://github.com/iurimateus/luasnip-latex-snippets.nvim' },
  { src = 'https://github.com/saghen/blink.compat' },
  { src = 'https://github.com/mikavilpas/blink-ripgrep.nvim' },
})

require('luasnip.loaders.from_vscode').lazy_load()

require('luasnip-latex-snippets').setup({ use_treesitter = true })

local ls = require('luasnip')
local ls_types = require('luasnip.util.types')
local ls_ft = require('luasnip.extras.filetype_functions')
local utils = require('utils')

---Load snippets for a given filetype
---@param ft string?
local function load_snippets(ft)
  ft = ft or vim.bo.ft

  utils.ft.load_once('snippets', ft, function(_, snips)
    if not snips or vim.tbl_isempty(snips) then
      return false
    end
    for _, group in pairs(snips) do
      ls.add_snippets(ft, group.snip or group, group.opts or {})
    end
    return true
  end)
end

ls.setup({
  ft_func = function()
    load_snippets('all')
    local langs = ls_ft.from_pos_or_filetype()
    for _, lang in ipairs(langs) do
      load_snippets(lang)
    end
    return langs
  end,
  keep_roots = true,
  link_roots = true,
  exit_roots = false,
  link_children = true,
  region_check_events = 'CursorMoved,CursorMovedI,InsertEnter',
  delete_check_events = 'TextChanged,TextChangedI,InsertLeave',
  enable_autosnippets = true,
  cut_selection_keys = '<Tab>',
  ext_opts = {
    [ls_types.choiceNode] = {
      active = {
        virt_text = {
          {
            utils.static.icons.ArrowUpDown,
            'Number',
          },
        },
      },
    },
  },
})

-- Unlink current snippet on leaving insert/select mode
-- https://github.com/L3MON4D3/LuaSnip/issues/258#issuecomment-1011938524
vim.api.nvim_create_autocmd('ModeChanged', {
  desc = 'Unlink current snippet on leaving insert/selection mode.',
  group = vim.api.nvim_create_augroup('LuaSnipModeChanged', {}),
  pattern = '[si]*:[^si]*',
  callback = vim.schedule_wrap(function(args)
    if vim.fn.mode():match('^[si]') then -- still in insert/select mode
      return
    end
    if ls.session.current_nodes[args.buf] and not ls.session.jump_active then
      ls.unlink_current()
    end
  end),
})

require('blink.compat').setup({})

require('blink.cmp').setup({
  enabled = function()
    return vim.fn.reg_recording() == '' and vim.fn.reg_executing() == ''
  end,
  keymap = { preset = 'enter' },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 0,
      window = {
        border = 'solid',
      },
    },
    ghost_text = { enabled = false },
    list = { selection = { preselect = false, auto_insert = true } },
    menu = {
      draw = {
        columns = {
          { 'kind_icon' },
          { 'label', 'label_description', gap = 1, 'kind' },
        },
        components = {
          kind_icon = {
            text = function(ctx)
              return ' ' .. ctx.kind_icon .. ctx.icon_gap .. ' '
            end,
          },
          kind = {
            text = function(ctx)
              return '(' .. ctx.kind .. ')'
            end,
            highlight = function(ctx)
              return 'BlinkCmpCustomType'
            end,
          },
        },
      },
    },
  },
  sources = {
    default = {
      'snippets',
      'lsp',
      'path',
      'buffer',
      'ripgrep',
    },
    per_filetype = {
      codecompanion = { 'codecompanion' },
      markdown = {
        'snippets',
        'lsp',
        'path',
        'buffer',
        'ripgrep',
        'pandoc_references',
      },
      norg = {
        'snippets',
        'lsp',
        'path',
        'buffer',
        'ripgrep',
      },
      quarto = {
        'snippets',
        'lsp',
        'path',
        'buffer',
        'ripgrep',
        'pandoc_references',
      },
      tex = {
        'snippets',
        'lsp',
        'path',
        'buffer',
        'ripgrep',
        'pandoc_references',
      },
    },
    providers = {
      ripgrep = {
        module = 'blink-ripgrep',
        name = 'Ripgrep',
        score_offset = -4,
        opts = {
          prefix_min_len = 3,
          context_size = 5,
          max_filesize = '1G',
        },
      },
      pandoc_references = {
        name = 'pandoc_references',
        module = 'blink.compat.source',
        score_offset = -1,
      },
      snippets = {
        score_offset = 100,
      },
      lsp = {
        score_offset = 99,
        timeout_ms = 500,
      },
      cmdline = {
        transform_items = function(_, items)
          is_cmd_expr_compl = vim.tbl_contains(
            { 'function', 'expression' },
            require('blink.cmp.sources.lib.utils').get_completion_type(
              require('blink.cmp.completion.trigger.context').get_mode()
            )
          )

          if not is_cmd_expr_compl then
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
  snippets = { preset = 'luasnip' },
  signature = { enabled = true },
})
