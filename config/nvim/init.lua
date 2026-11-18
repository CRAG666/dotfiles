-- Prevent loading lua files from the current directory.
-- E.g. when cwd is `lua/pack/specs/opt/`, `require('nvim-web-devicons')` will
-- load the local `nvim-web-devicons.lua` config file instead of the plugin
-- itself. This will confuse plugins that depends on `nvim-web-devicons`.
-- Subsequent calls to nvim-web-devicons' function may fail.
-- Remove the current directory from `package.path` to avoid errors.
package.path = package.path:gsub('%./%?%.lua;?', '')

-- Enable faster lua loader using byte-compilation
-- https://github.com/neovim/neovim/commit/2257ade3dc2daab5ee12d27807c0b3bcf103cd29
vim.loader.enable()

require('vim._core.ui2').enable()

-- ui2 highlights the cmdline with treesitter, compile the queries while idle
-- instead of on the first `:`
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    vim.defer_fn(function()
      vim.treesitter.get_string_parser(':', 'vim'):parse(true)
      vim.treesitter.query.get('vim', 'highlights')
    end, 100)
  end,
})

-- Runtime ftplugins (lua, help, markdown, query) start treesitter before the
-- first redraw, loading the parser and compiling the queries takes ~10ms
if vim.fn.argc(-1) > 0 then
  local ts_start = vim.treesitter.start
  ---@diagnostic disable-next-line: duplicate-set-field
  function vim.treesitter.start(buf, lang)
    if vim.v.vim_did_enter == 1 then
      ts_start(buf, lang)
      return
    end
    buf = vim._resolve_bufnr(buf)
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = vim.schedule_wrap(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.treesitter.start(buf, lang)
          require('utils.ts').redraw_parsed(buf)
        end
      end),
    })
  end
end

require('core.opts')
require('core.keymaps')
require('core.autocmds')
require('core.pack')

local load = require('utils.load')

load.on_events(load.ft_event, 'core.treesitter')
load.on_events('DiagnosticChanged', 'core.diagnostic')
-- Start language servers after the first redraw instead of blocking it,
-- `vim.lsp.enable()` only attaches to existing buffers after `VimEnter`
load.on_events(load.ft_event, 'core.lsp', function()
  local function setup()
    vim.schedule(function()
      require('core.lsp')
    end)
  end
  if vim.v.vim_did_enter == 1 then
    setup()
  else
    vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = setup })
  end
end)
require('core.format')
vim.cmd.colorscheme('eyes')

-- Learning Keybindings
--  ctrl+wv  Split buffer vertical
--  ctrl+ws  Split buffer horizontal
-- g;  Jump to the next change.
-- g,  Jump to the previous change
-- gUw  Uppercase until end of word (u for lower, ~ to toggle)
-- gUiw  Uppercase entire word (u for lower, ~ to toggle)
-- gUU  Uppercase entire line

-- Windows
-- ctrl+wo  Close every other window
-- ctrl+wT  Move window to a new tab
-- ctrl+wx  Swap with the next window (ctrl+wr rotates all)
-- ctrl+wH  Move window to the far left (J/K/L: bottom/top/right)
-- ctrl+w=  Equalize window sizes (ctrl+w| and ctrl+w_ maximize)
-- ctrl+wp  Jump to the previous window
-- ctrl+wgf  Open file under cursor in a new tab
-- ctrl+wd  Show diagnostics under cursor in a float (nvim)

-- Editing
-- gi  Insert where insert mode was last stopped
-- gv  Reselect the last visual selection
-- `.  Jump to the position of the last change (`` jumps back)
-- cgn  Change next search match, then . repeats on the following ones
-- &  Repeat last :s on this line with its flags (g& on all lines)
-- ctrl+a  Increment number at/after cursor (ctrl+x decrements)
-- {Visual}g ctrl+a  Turn a column of numbers into a sequence 1, 2, 3
-- gp  Paste and leave the cursor after the pasted text
-- ]p  Paste linewise matching the current indent
-- "0p  Paste the last yank, ignoring later deletes
-- gJ  Join lines without inserting spaces
-- gwip  Reflow paragraph to textwidth, cursor stays
-- !ip  Filter paragraph through a shell command (e.g. !ipsort)
-- ]<Space>  Add empty line below, stay in normal mode ([ above) (nvim)
-- gcc  Toggle comment on line (gc{motion}, dgc deletes a comment) (nvim)
-- @:  Repeat last Ex command (@@ afterwards)
-- qA  Append to macro a (uppercase register appends)
-- {Visual}@a  Run macro a on each selected line (nvim)
-- q:  Editable command history window (ctrl+f from the cmdline)

-- Motions and info
-- g_  Last non-blank character of the line
-- gM  Middle of the line's text (gm: middle of the screen line)
-- [(  Previous unmatched paren (also [{ ]) ]})
-- ge  Backward to end of previous word
-- g*  Like * but without whole-word boundaries
-- [I  List every line containing the word under cursor
-- ga  Show the character's code point (g8: UTF-8 bytes)
-- g ctrl+g  Word/char/byte counts (of the selection in visual mode)
-- gO  Outline: LSP symbols, table of contents in help/man (nvim)

-- Visual mode
-- o  Jump to the other end of the selection (O: other corner in a block)
-- $A  In a block, append at the end of every selected line
-- *  Search for the selected text (nvim)
-- an  Select parent treesitter node (in: child, ]n [n: siblings) (nvim)

-- Insert mode
-- ctrl+r{reg}  Insert a register (cmdline ctrl+r ctrl+w: word under cursor)
-- ctrl+o{cmd}  Run one normal-mode command, then back to insert
-- ctrl+a  Reinsert the last inserted text
-- ctrl+t  Indent the current line (ctrl+d dedents)
-- ctrl+k{c1}{c2}  Insert a digraph (n? gives ñ, e: gives ë)
-- ctrl+x ctrl+l  Complete a whole line (ctrl+x ctrl+f: file path)
-- ctrl+s  LSP signature help (nvim)

-- LSP and lists (nvim)
-- ]d  Next diagnostic ([d previous, ]D last, [D first)
-- ]q  Next quickfix item ([q previous, ]Q last, [Q first, ]ctrl+q next file)
-- ]b  Next buffer (same pattern: ]l loclist, ]a arglist, ]t tags)

-- Multicursor (nvim 0.13)
-- Q  Toggle an extra cursor at the cursor position
-- zq{motion}  Cursor at every target of the motion (zq*: every match)
-- {Visual}Q  Cursor on each selected line
-- q=  Toggle follow mode: motions replay at every cursor
-- g ctrl+a  Number the cursors 1, 2, 3
-- ]C  Jump to the next cursor ([C previous)
-- ctrl+l  Clear the cursors (gQ restores them)
