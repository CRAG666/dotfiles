vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('utils.load').on_events(
  'UIEnter',
  'keymaps',
  vim.schedule_wrap(function()
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

    local key = require('utils.key')

    -- Multi-window operations
    -- stylua: ignore start
    map({ 'x', 'n' }, '<C-w>>', 'v:count ? "<C-w>>" : "2<C-w>>"', { expr = true, desc = 'Resize window right' })
    map({ 'x', 'n' }, '<C-w><', 'v:count ? "<C-w><" : "2<C-w><"', { expr = true, desc = 'Resize window left' })
    map({ 'x', 'n' }, '<C-w>+', 'v:count ? "<C-w>+" : "2<C-w>+"', { expr = true, desc = 'Increase window height' })
    map({ 'x', 'n' }, '<C-w>-', 'v:count ? "<C-w>-" : "2<C-w>-"', { expr = true, desc = 'Decrease window height' })
    -- stylua: ignore end

    -- Search within visual selection, see:
    -- - https://stackoverflow.com/a/3264324/16371328
    -- - https://www.reddit.com/r/neovim/comments/1kv7som/comment/mu7lo52/
    -- stylua: ignore start
    map('x', '<M-/>',  '<C-\\><C-n>`</\\%V\\(\\)<Left><Left>', { desc = 'Search forward within visual selection' })
    map('x', '<M-?>',  '<C-\\><C-n>`>?\\%V\\(\\)<Left><Left>', { desc = 'Search backward within visual selection' })
    -- stylua: ignore end

    -- Select previously changed/yanked text, useful for selecting pasted text
    map('n', 'gz', '`[v`]', { desc = 'Select previously changed/yanked text' })
    map('o', 'gz', '<Cmd>normal! `[v`]<CR>', {
      desc = 'Select previously changed/yanked text',
    })

    -- Go to file under cursor, with line number
    map('n', 'gf', 'gF', { desc = 'Go to file under cursor' })
    map('n', ']f', 'gF', { desc = 'Go to file under cursor' })

    -- Delete selection in select mode
    map('s', '<BS>', '<C-o>"_s', { desc = 'Delete selection' })
    map('s', '<C-h>', '<C-o>"_s', { desc = 'Delete selection' })

    ---Check if given line should join with previews lines in current buffer
    ---@param line string
    ---@return boolean
    local function should_join_line(line)
      -- Buffer-local rules
      if vim.b.should_join_line then
        return vim.b.should_join_line(line)
      end
      return line ~= ''
    end

    ---Yank text with paragraphs joined as a single line, supposed to be used
    ---in a keymap
    local function yank_joined_paragraphs()
      local reg = vim.v.register

      local yank_joined_paragraphs_autocmd =
        vim.api.nvim_create_autocmd('TextYankPost', {
          once = true,
          callback = function()
            local joined_lines = {}

            for _, line in
              ipairs(vim.v.event.regcontents --[=[@as string[]]=])
            do
              -- Start a new paragraph if line is an empty line so that the
              -- original paragraphs are kept
              if line == '' then
                table.insert(joined_lines, '')
              end

              if not should_join_line(line) then
                table.insert(joined_lines, line)
                goto continue
              end

              local last_line = table.remove(joined_lines, #joined_lines)
              table.insert(
                joined_lines,
                (last_line == '' or last_line == nil) and vim.trim(line)
                  or string.format('%s %s', last_line, vim.trim(line))
              )
              ::continue::
            end

            vim.fn.setreg(reg, joined_lines, vim.v.event.regtype)
          end,
        })

      if vim.startswith(vim.fn.mode(), 'n') then
        -- If joined paragraph yank runs successfully in normal mode, the following
        -- events will trigger in order:
        -- 1. `ModeChanged` with pattern 'n:no'
        -- 2. `TextYankPost`
        -- 3. `ModeChanged` with pattern 'no:n' (or 'V:n', if using custom text
        --    object, e.g. `af`, `az`)
        --
        -- If joined paragraph yank is canceled, e.g. with `gy<Esc>` in normal mode,
        -- the following events will  trigger in order:
        -- 1. `ModeChanged` with pattern 'n:no'
        -- 2. `ModeChanged` with pattern 'no:n'
        --
        -- So remove the `TextYankPost` autocmd that joins each paragraph as a
        -- single line after changing from operator pending mode 'no' to normal mode
        -- 'n' to prevent it from affecting normal yanking e.g. with `y`
        vim.api.nvim_create_autocmd('ModeChanged', {
          once = true,
          pattern = '*:n',
          callback = vim.schedule_wrap(function()
            pcall(vim.api.nvim_del_autocmd, yank_joined_paragraphs_autocmd)
          end),
        })
      end

      vim.api.nvim_feedkeys('y', 'n', false)
    end

    -- Yank paragraphs as single lines, useful for yanking hard-wrapped
    -- paragraphs in nvim and paste it in browsers or other editors
    map({ 'n', 'x' }, 'gy', yank_joined_paragraphs, {
      desc = 'Yank text with joined paragraphs',
    })

    -- More consistent behavior when &wrap is set
    -- stylua: ignore start
    map({ 'n', 'x' }, 'j', 'v:count ? "j" : "gj"', { expr = true, desc = 'Move down' })
    map({ 'n', 'x' }, 'k', 'v:count ? "k" : "gk"', { expr = true, desc = 'Move up' })
    map({ 'n', 'x' }, '<Down>', 'v:count ? "<Down>" : "g<Down>"', { expr = true, replace_keycodes = false, desc = 'Move down' })
    map({ 'n', 'x' }, '<Up>',   'v:count ? "<Up>"   : "g<Up>"',   { expr = true, replace_keycodes = false, desc = 'Move up' })
    map({ 'i' }, '<Down>', '<Cmd>norm! g<Down><CR>', { desc = 'Move down' })
    map({ 'i' }, '<Up>',   '<Cmd>norm! g<Up><CR>',   { desc = 'Move up' })
    -- stylua: ignore end

    -- Correct misspelled word / mark as correct
    -- stylua: ignore start
    map('i', '<C-g>+', '<Esc>[szg`]a', { desc = 'Correct misspelled word before cursor' })
    map('i', '<C-g>=', '<C-g>u<Esc>[s1z=`]a<C-G>u', { desc = 'Add misspelled word before cursor' })
    -- stylua: ignore end

    -- Only clear highlights and message area and don't redraw if search
    -- highlighting is on to avoid flickering
    -- Use `:sil! dif` to suppress error
    -- 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits'
    -- in command window
    --
    -- Don't use `map()` here because `<C-l>` is already defined as nvim's
    -- default keymap before loading this config and we want to override it
    vim.keymap.set(
      { 'n', 'x' },
      '<C-l>',
      [['<Cmd>ec|noh|sil! dif<CR>' . (v:hlsearch ? '' : '<C-l>')]],
      {
        expr = true,
        replace_keycodes = false,
        desc = 'Clear and redraw screen',
      }
    )

    -- Folding
    map(
      { 'n', 'x' },
      'zV',
      key.with_lazyredraw(function()
        vim.cmd.normal({ 'zMzv', bang = true })
      end),
      { desc = 'Close all folds except current' }
    )

    -- Don't include extra spaces around quotes
    -- stylua: ignore start
    map({ 'o', 'x' }, 'a"', '2i"', { noremap = false, desc = 'Selet around double quotes' })
    map({ 'o', 'x' }, "a'", "2i'", { noremap = false, desc = 'Selet around single quotes' })
    map({ 'o', 'x' }, 'a`', '2i`', { noremap = false, desc = 'Selet around backticks' })
    -- stylua: ignore end

    ---Close floating windows with a given key, supposed to be used in a keymap
    --- 1. If current window is a floating window, close it and return
    --- 2. Else, close all floating windows that can be focused
    --- 3. Fallback to `key` if no floating window can be focused
    ---@param k string key (lhs) of the mapping
    local function close_floats(k)
      local current_win = vim.api.nvim_get_current_win()

      -- Only close current win if it's a floating window
      if vim.fn.win_gettype(current_win) == 'popup' then
        vim.api.nvim_win_close(current_win, true)
        return
      end

      -- Else close all focusable floating windows in current tab page
      local floats = vim
        .iter(vim.api.nvim_tabpage_list_wins(0))
        :filter(function(win)
          return vim.fn.win_gettype(win) == 'popup'
            and vim.api.nvim_win_get_config(win).focusable
            -- Ignore extui cmdline/message floating window, see `:h vim._extui`
            and not vim.tbl_contains(
              { 'cmd', 'dialog', 'msg', 'pager' },
              vim.bo[vim.fn.winbufnr(win)].ft
            )
        end)

      -- If no floating window will be closed, fallback
      if not floats:peek() then
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes(k, true, true, true),
          'n',
          false
        )
        return
      end

      floats:each(function(win)
        vim.api.nvim_win_close(win, false)
      end)
    end

    -- Close all floating windows
    -- stylua: ignore start
    map({ 'n', 'x' }, 'q', function() close_floats('q') end, { desc = 'Close all floating windows or start recording macro' })
    map({ 'n' }, '<Esc>', function() close_floats('<Esc>') end, { desc = 'Close all floating windows' })
    -- stylua: ignore end

    -- Enter insert mode, add a space after the cursor
    -- stylua: ignore start
    map({ 'n', 'x' }, '<M-i>', 'i<Space><Left>', { desc = 'Insert with a space after the cursor' })
    map({ 'n', 'x' }, '<M-I>', 'I<Space><Left>', { desc = 'Insert at start of line or selection with a space after the cursor' })
    map({ 'n', 'x' }, '<M-a>', 'a<Space><Left>', { desc = 'Append with a space after the cursor' })
    map({ 'n', 'x' }, '<M-A>', 'A<Space><Left>', { desc = 'Append at end of line or selection with a space after the cursor' })
    -- stylua: ignore end

    -- Text object: current buffer
    -- stylua: ignore start
    map('x', 'af', ':<C-u>silent! keepjumps normal! ggVG<CR>', { silent = true, noremap = false, desc = 'Select current buffer' })
    map('x', 'if', ':<C-u>silent! keepjumps normal! ggVG<CR>', { silent = true, noremap = false, desc = 'Select current buffer' })
    map('o', 'af', '<Cmd>silent! normal m`Vaf<CR><Cmd>silent! normal! ``<CR>', { silent = true, noremap = false, desc = 'Select current buffer' })
    map('o', 'if', '<Cmd>silent! normal m`Vif<CR><Cmd>silent! normal! ``<CR>', { silent = true, noremap = false, desc = 'Select current buffer' })
    -- stylua: ignore end

    -- Text object: folds
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

    -- stylua: ignore start
    map('x', 'iz', [[':<C-u>silent! keepjumps normal! ' . v:lua._textobj_fold('i') . '<CR>']], { silent = true, expr = true, noremap = false, desc = 'Select inside current fold' })
    map('x', 'az', [[':<C-u>silent! keepjumps normal! ' . v:lua._textobj_fold('a') . '<CR>']], { silent = true, expr = true, noremap = false, desc = 'Select around current fold' })
    map('o', 'iz', '<Cmd>silent! normal Viz<CR>', { silent = true, noremap = false, desc = 'Select inside current fold' })
    map('o', 'az', '<Cmd>silent! normal Vaz<CR>', { silent = true, noremap = false, desc = 'Select around current fold' })
    -- stylua: ignore end

    ---Go to the first line of current paragraph
    local function goto_paragraph_firstline()
      local chunk_size = 10
      local linenr = vim.fn.line('.')
      local count = vim.v.count1

      -- If current line is the first line of paragraph, move one line
      -- upwards first to goto the first line of previous paragraph
      if linenr >= 2 then
        local lines = vim.api.nvim_buf_get_lines(0, linenr - 2, linenr, false)
        if lines[1]:match('^$') and lines[2]:match('%S') then
          linenr = linenr - 1
        end
      end

      while linenr >= 1 do
        local chunk = vim.api.nvim_buf_get_lines(
          0,
          math.max(0, linenr - chunk_size - 1),
          linenr - 1,
          false
        )
        for i, line in ipairs(vim.iter(chunk):rev():totable()) do
          local current_linenr = linenr - i
          if line:match('^$') then
            count = count - 1
            if count <= 0 then
              vim.cmd.normal({ "m'", bang = true })
              vim.cmd(tostring(current_linenr + 1))
              return
            end
          elseif current_linenr <= 1 then
            vim.cmd.normal({ "m'", bang = true })
            vim.cmd('1')
            return
          end
        end
        linenr = linenr - chunk_size
      end
    end

    ---Go to the last line of current paragraph
    local function goto_paragraph_lastline()
      local chunk_size = 10
      local linenr = vim.fn.line('.')
      local buf_line_count = vim.api.nvim_buf_line_count(0)
      local count = vim.v.count1

      -- If current line is the last line of paragraph, move one line
      -- downwards first to goto the last line of next paragraph
      if buf_line_count - linenr >= 1 then
        local lines =
          vim.api.nvim_buf_get_lines(0, linenr - 1, linenr + 1, false)
        if lines[1]:match('%S') and lines[2]:match('^$') then
          linenr = linenr + 1
        end
      end

      while linenr <= buf_line_count do
        local chunk =
          vim.api.nvim_buf_get_lines(0, linenr, linenr + chunk_size, false)
        for i, line in ipairs(chunk) do
          local current_linenr = linenr + i
          if line:match('^$') then
            count = count - 1
            if count <= 0 then
              vim.cmd.normal({ "m'", bang = true })
              vim.cmd(tostring(current_linenr - 1))
              return
            end
          elseif current_linenr >= buf_line_count then
            vim.cmd.normal({ "m'", bang = true })
            vim.cmd(tostring(buf_line_count))
            return
          end
        end
        linenr = linenr + chunk_size
      end
    end

    -- Use 'g{' and 'g}' to go to the first/last line of a paragraph
    -- stylua: ignore start
    map({ 'o' }, 'g{', '<Cmd>silent! exe "normal V" . v:count1 . "g{"<CR>', { noremap = false, desc = 'Go to the first line of paragraph' })
    map({ 'o' }, 'g}', '<Cmd>silent! exe "normal V" . v:count1 . "g}"<CR>', { noremap = false, desc = 'Go to the last line of paragraph' })
    map({ 'n', 'x' }, 'g{', goto_paragraph_firstline, { noremap = false, desc = 'Go to the first line of paragraph' })
    map({ 'n', 'x' }, 'g}', goto_paragraph_lastline, { noremap = false, desc = 'Go to the last line of paragraph' })
    -- stylua: ignore end

    map('n', '<Leader>Pu', vim.pack.update, { desc = 'Update plugins' })
    map('n', '<Leader>Pr', function()
      vim.pack.update(nil, { target = 'lockfile' })
    end, { desc = 'Restore plugins according to lockfile' })
    map('n', '<Leader>Pd', function()
      ---@type string[]
      local plug_src_list = vim
        .iter(vim.pack.get())
        :map(function(data)
          return vim.fs.basename(data.path)
        end)
        :totable()

      vim.ui.select(
        plug_src_list,
        { prompt = 'Plugin to delete: ' },
        function(choice)
          if choice then
            vim.pack.del({ choice })
          end
        end
      )
    end, { desc = 'Delete plugin' })

    map('n', 'i', function()
      if #vim.fn.getline('.') == 0 then
        return [["_cc]]
      else
        return 'i'
      end
    end, { expr = true })
    -- map('n', "'", [[printf('`%czz',getchar())]], { expr = true, silent = false })
    map('n', '<C-d>', '<C-d>zz')
    map('n', '<C-u>', '<C-u>zz')
    map('n', 'n', 'nzzzv')
    map('n', 'N', 'Nzzzv')
    map('n', '<Tab>', vim.cmd.bnext)
    map('n', '<S-Tab>', vim.cmd.bprev)
    map('n', 'yc', 'yygccp', { remap = true, desc = 'Yank [c]omment' })

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
    map('t', '<Esc>', [[<C-\><C-n>']])
    map('t', '<M-[>', '<Esc>')
    map('t', '<C-v><Esc>', '<Esc>')

    map(
      'n',
      '<bs>',
      ":<c-u>exe v:count ? v:count . 'b' : 'b' . (bufloaded(0) ? '#' : 'n')<cr>"
    )
  end)
)

require('utils.load').on_events(
  'CmdlineEnter',
  'keymaps.cmdline_abbrevs',
  function()
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
  end
)
