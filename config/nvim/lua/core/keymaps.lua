vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = vim.schedule_wrap(function()
    local keymaps = {} ---@type table<string, table<string, true>>
    local buf_keymaps = {} ---@type table<integer, table<string, table<string, true>>>

    ---Set keymaps, don't override existing keymaps unless `opts.unique` is false
    ---@param modes string|string[] mode short-name
    ---@param lhs string left-hand side of the mapping
    ---@param rhs string|function right-hand side of the mapping
    ---@param opts? vim.keymap.set.Opts
    ---@return nil
    local function map(modes, lhs, rhs, opts)
      if opts and opts.unique == false then
        vim.keymap.set(modes, lhs, rhs, opts)
        return
      end

      if type(modes) ~= 'table' then
        modes = { modes }
      end

      if not opts or not opts.buffer then -- global keymaps
        for _, mode in ipairs(modes) do
          if not keymaps[mode] then
            keymaps[mode] = {}
            for _, keymap in ipairs(vim.api.nvim_get_keymap(mode)) do
              keymaps[mode][vim.keycode(keymap.lhs)] = true
            end
          end
          if not keymaps[mode][vim.keycode(lhs)] then
            vim.keymap.set(mode, lhs, rhs, opts)
          end
        end
      else -- buffer-local keymaps
        local buf = type(opts.buffer) == 'number' and opts.buffer or 0 --[[@as integer]]
        if not buf_keymaps[buf] then
          buf_keymaps[buf] = {}
        end
        local maps = buf_keymaps[buf]
        for _, mode in ipairs(modes) do
          if not maps[mode] then
            maps[mode] = {}
            for _, keymap in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
              maps[mode][vim.keycode(keymap.lhs)] = true
            end
          end
          if not maps[mode][vim.keycode(lhs)] then
            vim.keymap.set(mode, lhs, rhs, opts)
          end
        end
      end
    end

    ---Close floating windows with a given key, supposed to be used in a keymap
    --- 1. If current window is a floating window, close it and return
    --- 2. Else, close all floating windows that can be focused
    --- 3. Fallback to `key` if no floating window can be focused
    ---@param key string
    local function close_floats(key)
      local current_win = vim.api.nvim_get_current_win()

      -- Only close current win if it's a floating window
      if vim.fn.win_gettype(current_win) == 'popup' then
        vim.api.nvim_win_close(current_win, true)
        return
      end

      -- Else close all focusable floating windows in current tab page
      local win_closed = false
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if
          vim.fn.win_gettype(win) == 'popup'
          and vim.api.nvim_win_get_config(win).focusable
        then
          vim.api.nvim_win_close(win, false) -- do not force
          win_closed = true
        end
      end

      -- If no floating window is closed, fallback
      if not win_closed then
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes(key, true, true, true),
          'n',
          false
        )
      end
    end

    ---Returns the key sequence to select around/inside a fold,
    ---supposed to be called in visual mode
    ---@param motion 'i'|'a'
    ---@return string
    function _G._textobj_fold(motion)
      local lnum = vim.fn.line('.') --[[@as integer]]
      local sel_start = vim.fn.line('v')
      local lev = vim.fn.foldlevel(lnum)
      local levp = vim.fn.foldlevel(lnum - 1)
      -- Multi-line selection with cursor on top of selection
      if sel_start > lnum then
        return (lev == 0 and 'zk' or lev > levp and levp > 0 and 'k' or '')
          .. vim.v.count1
          .. (motion == 'i' and ']zkV[zj' or ']zV[z')
      end
      return (lev == 0 and 'zj' or lev > levp and 'j' or '')
        .. vim.v.count1
        .. (motion == 'i' and '[zjV]zk' or '[zV]z')
    end

    -- Mappings from keymappings.lua
    local opts = { noremap = true, silent = false }

    map('n', 'i', function()
      if #vim.fn.getline('.') == 0 then
        return [["_cc]]
      else
        return 'i'
      end
    end, { expr = true })
    map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
    map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
    -- map('n', "'", [[printf('`%czz',getchar())]], { expr = true, silent = false })
    map('n', '<C-d>', '<C-d>zz')
    map('n', '<C-u>', '<C-u>zz')
    map('n', 'n', 'nzzzv')
    map('n', 'N', 'Nzzzv')
    map('n', '<Tab>', vim.cmd.bnext)
    map('n', '<S-Tab>', vim.cmd.bprev)
    map('n', 'yc', 'yygccp', { remap = true, desc = 'Yank [c]omment' })
    map(
      'x',
      'z/',
      [[<C-\><C-n>`</\%V]],
      { desc = 'Search forward within visual selection' }
    )
    map(
      'x',
      'z?',
      [[<C-\><C-n>`>?\%V]],
      { desc = 'Search backward within visual selection' }
    )

    -- No yank
    map('n', 'x', '"_x')
    map({ 'n', 'x' }, 'c', '"_c')
    map('n', 'C', '"_C')
    map('v', 'p', '"_dP', opts)

    -- Better indent
    map('v', '<', '<gv', opts)
    map('v', '>', '>gv', opts)

    map('n', '<localleader>s', function()
      if vim.wo.spell then
        vim.wo.spell = false
        return
      end
      vim.ui.select({ 'es_mx', 'en_us' }, {
        prompt = 'Toggle spell checker',
      }, function(lang)
        if lang then
          vim.wo.spell = true
          vim.bo.spelllang = lang
        else
          print('language not selected')
        end
      end)
    end, { desc = 'Toggle spell checker' })

    map('n', '<localleader>e', function()
      require('modules.es_shortcuts')
    end, { desc = 'Spanish Shortcuts' })

    -- sudo
    -- vim.cmd [[cmap w!! w !sudo tee > /dev/null %]]

    -- Tab mappings
    for i = 9, 1, -1 do
      local kmap = string.format('<leader>%d', i)
      local command = string.format('%dgt', i)
      map('n', kmap, command, { desc = string.format('Jump Tab [%d]', i) })
      map(
        'n',
        string.format('<leader>t%d', i),
        string.format(':tabmove %d<CR>', i == 1 and 0 or i),
        { desc = string.format('Tab Move to [%d]', i) }
      )
    end

    -- Unrolled maps
    -- prefix = '<leader>t', mode = 'n'
    map('n', '<leader>tn', vim.cmd.tabnew, { desc = 'Tab [n]ew' })
    map('n', '<leader>to', vim.cmd.tabonly, { desc = 'Tab [o]nly' })
    map('n', '<leader>tc', vim.cmd.tabclose, { desc = 'Tab [c]lose' })
    map('n', '<leader>tl', ':tabmove +1<CR>', { desc = 'Tab Move Right' })
    map('n', '<leader>th', ':tabmove -1<CR>', { desc = 'Tab Move Left' })
    map(
      'n',
      '<leader>ts',
      [[:execute 'set showtabline=' . (&showtabline ==# 0 ? 2 : 0)<CR>]],
      { desc = 'Toggle Tabs' }
    )

    -- prefix = '<leader>', mode = 'n'
    map('n', '<leader>cc', ':let @/=""<cr>', { desc = 'Clear [c]hoose' })

    -- prefix = '<leader>r', mode = 'n'
    map(
      'n',
      '<leader>rr',
      ':%s/',
      { desc = 'Search and [r]eplace', noremap = true, silent = false }
    )
    map(
      'n',
      '<leader>rl',
      ':s/',
      { desc = 'Search and [r]eplace [l]ine', noremap = true, silent = false }
    )
    map(
      'n',
      '<leader>rw',
      [[:%s/\<C-r><C-w>\>/]],
      { desc = 'Search and [r]eplace [w]ord', noremap = true, silent = false }
    )
    map('n', '<leader>re', [[:%s/\(.*\)/\1]], {
      desc = 'Search and [r]eplace [e]xtend',
      noremap = true,
      silent = false,
    })
    map(
      'n',
      '<leader>rn',
      [[/\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn]],
      { desc = 'Search and Replace word and nexts word with .' }
    )
    map(
      'n',
      '<leader>rN',
      [[?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN]],
      { desc = 'Search and Replace word and prevs word with .' }
    )

    -- prefix = '<leader>r', mode = 'v'
    map(
      'v',
      '<leader>rr',
      ':s/',
      { desc = 'Search and [r]eplace visual', noremap = true, silent = false }
    )
    map('v', '<leader>re', [[:s/\(.*\)/\1]], {
      desc = 'Search and [r]eplace [e]xtend visual',
      noremap = true,
      silent = false,
    })

    --Esc in terminal mode
    -- map('t', '<Esc>', '<C-\><C-n>')
    -- map('t', '<M-[>', '<Esc>')
    -- map('t', '<C-v><Esc>', '<Esc>')

    map(
      'n',
      '<bs>',
      ":<c-u>exe v:count ? v:count . 'b' : 'b' . (bufloaded(0) ? '#' : 'n')<cr>"
    )

    map({ 'n', 'x' }, 'zV', function()
      local lz = vim.go.lz
      vim.go.lz = true
      vim.cmd.normal({ 'zMzv', bang = true })
      vim.go.lz = lz
    end, { desc = 'Close all folds except current' })

    map({ 'n', 'x' }, 'q', function()
      close_floats('q')
    end, { desc = 'Close all floating windows or start recording macro' })

    map(
      'x',
      'af',
      ':<C-u>silent! keepjumps normal! ggVG<CR>',
      { silent = true, noremap = false, desc = 'Select current buffer' }
    )
    map(
      'x',
      'if',
      ':<C-u>silent! keepjumps normal! ggVG<CR>',
      { silent = true, noremap = false, desc = 'Select current buffer' }
    )
    map(
      'o',
      'af',
      '<Cmd>silent! normal m`Vaf<CR><Cmd>silent! normal! ``<CR>',
      { silent = true, noremap = false, desc = 'Select current buffer' }
    )
    map(
      'o',
      'if',
      '<Cmd>silent! normal m`Vif<CR><Cmd>silent! normal! ``<CR>',
      { silent = true, noremap = false, desc = 'Select current buffer' }
    )

    map(
      'x',
      'iz',
      [[':<C-u>silent! keepjumps normal! ' . v:lua._textobj_fold('i') . '<CR>']],
      {
        silent = true,
        expr = true,
        noremap = false,
        desc = 'Select inside current fold',
      }
    )
    map(
      'x',
      'az',
      [[':<C-u>silent! keepjumps normal! ' . v:lua._textobj_fold('a') . '<CR>']],
      {
        silent = true,
        expr = true,
        noremap = false,
        desc = 'Select around current fold',
      }
    )
    map(
      'o',
      'iz',
      '<Cmd>silent! normal Viz<CR>',
      { silent = true, noremap = false, desc = 'Select inside current fold' }
    )
    map(
      'o',
      'az',
      '<Cmd>silent! normal Vaz<CR>',
      { silent = true, noremap = false, desc = 'Select around current fold' }
    )

    map('n', '<leader>pu', vim.pack.update, { desc = '[p]lugin [u]pdate' })
    map('n', '<leader>pi', vim.pack.get, { desc = '[p]lugins [i]nfo' })

    map('!a', 'ture', 'true')
    map('!a', 'Ture', 'True')
    map('!a', 'flase', 'false')
    map('!a', 'fasle', 'false')
    map('!a', 'Flase', 'False')
    map('!a', 'Fasle', 'False')
    map('!a', 'lcaol', 'local')
    map('!a', 'lcoal', 'local')
    map('!a', 'locla', 'local')
    map('!a', 'sahre', 'share')
    map('!a', 'saher', 'share')
    map('!a', 'balme', 'blame')
    map('!a', 'intall', 'install')
  end),
})

vim.api.nvim_create_autocmd('CmdlineEnter', {
  once = true,
  callback = function()
    local key = require('utils.key')
    key.command_map(':', 'lua ')
    key.command_map(';', ':= ')
    key.command_abbrev('man', 'Man')
    key.command_abbrev('rm', '!rm')
    key.command_abbrev('mv', '!mv')
    key.command_abbrev('git', '!git')
    key.command_abbrev('tree', '!tree')
    key.command_abbrev('mkdir', '!mkdir')
    key.command_abbrev('touch', '!touch')
    key.command_abbrev('chmod', '!chmod')
    return true
  end,
})
