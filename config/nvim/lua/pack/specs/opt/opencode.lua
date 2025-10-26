---@type pack.spec
return {
  src = 'https://github.com/sudo-tee/opencode.nvim',
  data = {
    deps = {
      'https://github.com/nvim-lua/plenary.nvim',
      {
        src = 'https://github.com/saghen/blink.cmp',
        data = { optional = true },
      },
      {
        src = 'https://github.com/folke/snacks.nvim',
        data = { optional = true },
      },
    },
    cmds = {
      'OpencodeSwapPosition',
      'Opencode',
      'OpencodeToggleFocus',
      'OpencodeOpenInput',
      'OpencodeOpenInputNewSession',
      'OpencodeOpenOutput',
      'OpencodeClose',
      'OpencodeStop',
      'OpencodeSelectSession',
      'OpencodeTogglePane',
      'OpencodeConfigureProvider',
      'OpencodeRun',
      'OpencodeRunNewSession',
      'OpencodeDiff',
      'OpencodeDiffNext',
      'OpencodeDiffPrev',
      'OpencodeDiffClose',
      'OpencodeRevertAllLastPrompt',
      'OpencodeRevertThisLastPrompt',
      'OpencodeRevertAllSession',
      'OpencodeRevertThisSession',
      'OpencodeRevertAllToSnapshot',
      'OpencodeRevertThisToSnapshot',
      'OpencodeRestoreSnapshotFile',
      'OpencodeRestoreSnapshotAll',
      'OpencodeSetReviewBreakpoint',
      'OpencodeInit',
      'OpencodeHelp',
      'OpencodeMCP',
      'OpencodeConfigFile',
      'OpencodeAgentPlan',
      'OpencodeAgentBuild',
      'OpencodeAgentSelect',
    },
    keys = {
      lhs = '<Leader>@',
      opts = { desc = 'Toggle opencode' },
    },
    postload = function()
      if vim.fn.executable('opencode') == 0 then
        vim.notify(
          '[Opencode.nvim] command `opencode` not found',
          vim.log.levels.ERROR
        )
        return
      end

      -- Default configuration with all available options
      require('opencode').setup({
        default_global_keymaps = false,
        ui = {
          icons = { preset = vim.g.has_nf and 'emoji' or 'text' },
          input = { text = { wrap = true } },
        },
        context = {
          cursor_data = {
            enabled = true,
          },
        },
        keymap = {
          input_window = {
            ['<cr>'] = {
              'submit_input_prompt',
              mode = 'n',
            },
            ['<m-cr>'] = {
              'submit_input_prompt',
              mode = { 'i', 'n' },
            },
            -- Must use lower-case '<tab>' to disable default keymaps
            -- https://github.com/sudo-tee/opencode.nvim/issues/61
            ['<tab>'] = false,
          },
        },
      })

      local opencode_api = require('opencode.api')

      -- stylua: ignore start
      vim.keymap.set('n', '<Leader>@', opencode_api.toggle_focus, { desc = 'Toggle opencode' })
      vim.keymap.set('n', '[@', opencode_api.diff_prev, { desc = 'Navigate to opencode previous file diff' })
      vim.keymap.set('n', ']@', opencode_api.diff_next, { desc = 'Navigate to opencode next file diff' })
      -- stylua: ignore end

      local group = vim.api.nvim_create_augroup('my.opencode.settings', {})

      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Filetype settings for opencode buffers.',
        pattern = 'opencode*',
        group = group,
        callback = function(args)
          vim.b[args.buf].winbar_no_attach = true
        end,
      })

      vim.api.nvim_create_autocmd('BufWinEnter', {
        desc = 'Opencode window settings.',
        group = group,
        callback = function(args)
          if not vim.startswith(vim.bo[args.buf].ft, 'opencode') then
            return
          end
          for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
            vim.wo[win][0].cc = ''
          end
        end,
      })

      local hl = require('utils.hl')

      hl.persist(function()
        -- See `lua/core/autocmds.lua` for `hl-NormalSpecial` definition
        -- stylua: ignore start
        hl.set(0, 'OpenCodeNormal',             { link = 'NormalSpecial', default = true })
        hl.set(0, 'OpenCodeBackground',         { link = 'NormalSpecial', default = true })
        hl.set(0, 'OpenCodeDiffAdd',            { link = 'DiffAdd',       default = true })
        hl.set(0, 'OpencodeDiffDelete',         { link = 'DiffDelete',    default = true })
        hl.set(0, 'OpencodeAgentBuild',         { link = 'Todo',          default = true })
        hl.set(0, 'OpencodeInputLegend',        { link = 'SpecialKey',    default = true })
        hl.set(0, 'OpenCodeSessionDescription', { bg = 'OpenCodeNormal',  fg = 'Comment', default = true })
        hl.set(0, 'OpenCodeHint',               { bg = 'OpenCodeNormal',  fg = 'Comment', default = true })
        -- stylua: ignore end
      end)
    end,
  },
}
