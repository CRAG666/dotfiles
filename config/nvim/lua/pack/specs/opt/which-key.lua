---@type pack.spec
return {
  src = 'https://github.com/folke/which-key.nvim',
  data = {
    load = function(spec, path)
      local load = require('utils.load')

      local function load_wk()
        if spec.data and spec.data.preload then
          spec.data.preload(spec, path)
        end
        load.load('which-key.nvim')
        if spec.data and spec.data.postload then
          spec.data.postload(spec, path)
        end
      end

      if vim.v.vim_did_enter then
        vim.schedule(load_wk)
      else
        load.on_events(
          'UIEnter',
          'which-key',
          vim.schedule_wrap(load_wk)
        )
      end
    end,
    postload = function()
      local icons = require('utils.static.icons')
      local wk_win = require('which-key.win')
      local wk_trig = require('which-key.triggers')

      -- Hijack `which-key.win.show()` to fix gap to the right of which-key window
      -- when using helix preset
      wk_win.show = (function(show_fn)
        return function(self, opts, ...)
          if opts and opts.col then
            opts.col = opts.col + 1
          end
          return show_fn(self, opts, ...)
        end
      end)(wk_win.show)

      -- `<M->` will be added as a trigger if keymap `<M->>` (aka alt + left-angle)
      -- is set, conflicting with the default visual mode keymap `<`
      -- TODO: report to upstream
      ---@param add_fn function
      wk_trig.add = (function(add_fn)
        ---@param trig wk.Trigger
        return function(trig)
          if trig.keys == '<M->' then
            return
          end
          add_fn(trig)
        end
      end)(wk_trig.add)

      local wk = require('which-key')

      wk.setup({
        preset = 'helix',
        delay = function(ctx)
          return ctx.plugin and 0 or 640
        end,
        win = { border = 'solid' },
        sort = {
          'local',
          'order',
          'group',
          'desc',
          'alphanum',
          'mod',
        },
        filter = function(mapping)
          return not mapping.lhs:find('<Esc>', 0, true)
            and not mapping.lhs:find('<.*Mouse.*>')
            and not mapping.lhs:find('<.*ScrollWheel.*>')
        end,
        defer = function(ctx)
          return ctx.mode == 'V' or ctx.mode == '<C-V>' or ctx.mode == 'v'
        end,
        plugins = {
          marks = false,
          registers = false,
          spelling = {
            enabled = false,
          },
        },
        icons = {
          mappings = false,
          breadcrumb = '',
          separator = '',
          group = '+',
          ellipsis = icons.Ellipsis,
          keys = {
            Up = icons.keys.Up,
            Down = icons.keys.Down,
            Left = icons.keys.Left,
            Right = icons.keys.Right,
            C = icons.keys.Control,
            M = icons.keys.Meta,
            D = icons.keys.Command,
            S = icons.keys.Shift,
            CR = icons.keys.Enter,
            Esc = icons.keys.Escape,
            ScrollWheelDown = icons.keys.MouseDown,
            ScrollWheelUp = icons.keys.MouseUp,
            NL = icons.keys.Enter,
            BS = icons.keys.BackSpace,
            Space = icons.keys.Space,
            Tab = icons.keys.Tab,
            F1 = icons.keys.F1,
            F2 = icons.keys.F2,
            F3 = icons.keys.F3,
            F4 = icons.keys.F4,
            F5 = icons.keys.F5,
            F6 = icons.keys.F6,
            F7 = icons.keys.F7,
            F8 = icons.keys.F8,
            F9 = icons.keys.F9,
            F10 = icons.keys.F10,
            F11 = icons.keys.F11,
            F12 = icons.keys.F11,
          },
        },
      })

      wk.add({
        { '<Leader>g', group = 'Git' },
        { '<Leader>f', group = 'Find' },
        { '<Leader>fg', group = 'Git' },
        { '<Leader>gf', group = 'Find' },
        { '<Leader>fS', group = 'LSP' },
        { '<Leader>G', group = 'Debug' },
        { '<Leader>t', group = 'Test' },
        { '<Leader><Tab>', group = 'Table mode' },
        { '<Leader><Tab>d', group = 'Delete' },
        { '<Leader><Tab>i', group = 'Insert' },
        { '<Leader><Tab>f', group = 'Formula' },
        { '<LocalLeader>l', group = 'TeX' },
      })

      require('utils.hl').persist(function()
        if vim.go.termguicolors then
          return
        end

        -- Ensure visibility in TTY
        vim.api.nvim_set_hl(0, 'WhichKey', { link = 'Normal', default = true })
        vim.api.nvim_set_hl(
          0,
          'WhichKeyDesc',
          { link = 'Normal', default = true }
        )
        vim.api.nvim_set_hl(0, 'WhichKeySeparator', {
          link = 'WhichKeyGroup',
          default = true,
        })
      end)

      vim.api.nvim_create_autocmd('ModeChanged', {
        desc = 'Redraw statusline shortly after mode change to ensure correct mode display after enting visual mode when which-key.nvim is enabled.',
        group = vim.api.nvim_create_augroup(
          'my.which-key.redraw_statusline',
          {}
        ),
        callback = vim.schedule_wrap(function()
          vim.cmd.redrawstatus({
            mods = { emsg_silent = true },
          })
        end),
      })
    end,
  },
}
