local utils = require('plugin.winbar.utils')
local icons = utils.static.icons
local M = {}

---@class winbar_configs_t
M.opts = {
  icons = {
    kinds = {
      symbols = icons.kinds,
    },
    ui = {
      bar = {
        separator = vim.g.has_nf and icons.ui.AngleRight or ' > ',
        extends = vim.opt.listchars:get().extends
          or vim.trim(icons.ui.Ellipsis),
      },
      menu = {
        separator = ' ',
        indicator = icons.ui.AngleRight,
      },
    },
  },
  symbol = {
    ---@type fun(symbol: winbar_symbol_t, min_width: integer?, n_clicks: integer?, button: string?, modifiers: string?)|false?
    on_click = function(symbol)
      -- Update current context highlights if the symbol
      -- is shown inside a menu
      if symbol.entry and symbol.entry.menu then
        symbol.entry.menu:update_current_context_hl(symbol.entry.idx)
      elseif symbol.bar then
        symbol.bar:update_current_context_hl(symbol.bar_idx)
      end

      -- Determine menu configs
      local prev_win = nil ---@type integer?
      local entries_source = nil ---@type winbar_symbol_t[]?
      local init_cursor = nil ---@type integer[]?
      local win_configs = {}
      if symbol.bar then -- If symbol inside a winbar
        prev_win = symbol.bar.win
        entries_source = symbol.opts.siblings
        init_cursor = symbol.opts.sibling_idx
          and { symbol.opts.sibling_idx, 0 }
        if symbol.bar.in_pick_mode then
          ---@param tbl number[]
          local function tbl_sum(tbl)
            local sum = 0
            for _, v in ipairs(tbl) do
              sum = sum + v
            end
            return sum
          end
          win_configs.relative = 'win'
          win_configs.win = vim.api.nvim_get_current_win()
          win_configs.row = 0
          win_configs.col = symbol.bar.padding.left
            + tbl_sum(vim.tbl_map(
              function(component)
                return component:displaywidth()
                  + symbol.bar.separator:displaywidth()
              end,
              vim.tbl_filter(function(component)
                return component.bar_idx < symbol.bar_idx
              end, symbol.bar.components)
            ))
        end
      elseif symbol.entry and symbol.entry.menu then -- If inside a menu
        prev_win = symbol.entry.menu.win
        entries_source = symbol.opts.children
      end

      -- Toggle existing menu
      if symbol.menu then
        symbol.menu:toggle({
          prev_win = prev_win,
          win_configs = win_configs,
        })
        return
      end

      -- Create a new menu for the symbol
      if not entries_source or vim.tbl_isempty(entries_source) then
        return
      end

      local menu = require('plugin.winbar.menu')
      local configs = require('plugin.winbar.configs')
      symbol.menu = menu.winbar_menu_t:new({
        prev_win = prev_win,
        cursor = init_cursor,
        win_configs = win_configs,
        ---@param sym winbar_symbol_t
        entries = vim.tbl_map(function(sym)
          local menu_indicator_icon = configs.opts.icons.ui.menu.indicator
          local menu_indicator_on_click = nil
          if not sym.children or vim.tbl_isempty(sym.children) then
            menu_indicator_icon =
              string.rep(' ', vim.fn.strdisplaywidth(menu_indicator_icon))
            menu_indicator_on_click = false
          end
          return menu.winbar_menu_entry_t:new({
            components = {
              sym:merge({
                name = '',
                icon = menu_indicator_icon,
                icon_hl = 'winbarIconUIIndicator',
                on_click = menu_indicator_on_click,
              }),
              sym:merge({
                on_click = function()
                  local root_menu = symbol.menu and symbol.menu:root()
                  if root_menu then
                    root_menu:close(false)
                  end
                  sym:jump()
                end,
              }),
            },
          })
        end, entries_source),
      })
      symbol.menu:toggle()
    end,
    preview = {
      ---Reorient the preview window on previewing a new symbol
      ---@param win integer source window id
      ---@param range { start: { line: integer }, end: { line: integer } } 0-indexed
      ---@diagnostic disable-next-line: unused-local
      reorient = function(win, range) end, -- luacheck: ignore 212
    },
    jump = {
      ---@param win integer source window id
      ---@param range { start: { line: integer }, end: { line: integer } } 0-indexed
      ---@diagnostic disable-next-line: unused-local
      reorient = function(win, range) end, -- luacheck: ignore 212
    },
  },
  bar = {
    ---@type boolean|fun(buf: integer, win: integer): boolean
    enable = function(buf, win)
      if not vim.api.nvim_win_is_valid(win) then
        return false
      end

      buf = vim._resolve_bufnr(buf)
      if not vim.api.nvim_buf_is_valid(buf) then
        return false
      end

      local bt = vim.bo[buf].bt
      local ft = vim.bo[buf].ft

      return vim.wo[win].winbar == ''
        and not vim.w[win].winbar_no_attach
        and not vim.b[buf].winbar_no_attach
        and vim.fn.win_gettype(win) == ''
        and bt ~= 'terminal'
        and bt ~= 'quickfix'
        and bt ~= 'prompt'
        and ft ~= 'query'
        and ft ~= 'help'
        and ft ~= 'diff'
        and ft ~= 'gitcommit'
        and ft ~= 'gitrebase'
        and (
          ft == 'markdown'
          or utils.ts.is_active(buf)
          or not vim.tbl_isempty(vim.lsp.get_clients({
            bufnr = buf,
            method = vim.lsp.protocol.Methods.textDocument_documentSymbol,
          }))
        )
    end,
    attach_events = {
      'BufEnter',
      'BufWinEnter',
      'BufWritePost',
      'FileType',
      'LspAttach',
    },
    -- Wait for a short time before updating the winbar, if another update
    -- request is received within this time, the previous request will be
    -- cancelled, this improves the performance when the user is holding
    -- down a key (e.g. 'j') to scroll the window
    update_debounce = 16,
    update_events = {
      win = {
        'CursorMoved',
        'WinResized',
      },
      buf = {
        'BufModifiedSet',
        'FileChangedShellPost',
        'TextChanged',
        'InsertLeave',
      },
      global = {
        'DirChanged',
        'VimResized',
      },
    },
    hover = true,
    ---@type winbar_source_t[]|fun(buf: integer, win: integer): winbar_source_t[]
    sources = function(buf)
      local sources = require('plugin.winbar.sources')
      return vim.bo[buf].ft == 'markdown' and { sources.markdown }
        or {
          utils.source.fallback({
            sources.lsp,
            sources.treesitter,
          }),
        }
    end,
    padding = {
      left = 1,
      right = 1,
    },
    pick = {
      pivots = 'abcdefghijklmnopqrstuvwxyz',
    },
    gc = {
      interval = 60000,
    },
  },
  menu = {
    -- When on, preview the symbol in the source window
    preview = true,
    hover = true,
    -- When on, set the cursor to the closest clickable component
    -- on CursorMoved
    quick_navigation = true,
    -- Menu scrollbar options
    scrollbar = {
      enable = true,
    },
    entry = {
      padding = {
        left = 1,
        right = 1,
      },
    },
    ---@type table<string, string|function|table<string, string|function>>
    keymaps = {
      ['q'] = function()
        local menu = utils.menu.get_current()
        if menu then
          menu:close()
        end
      end,
      ['<LeftMouse>'] = function()
        local menu = utils.menu.get_current()
        if not menu then
          return
        end
        local mouse = vim.fn.getmousepos()
        local clicked_menu = utils.menu.get({ win = mouse.winid })
        -- If clicked on a menu, invoke the corresponding click action,
        -- else close all menus and set the cursor to the clicked window
        if clicked_menu then
          clicked_menu:click_at({ mouse.line, mouse.column - 1 }, nil, 1, 'l')
          return
        end
        utils.menu.exec('close')
        utils.bar.exec('update_current_context_hl')
        if vim.api.nvim_win_is_valid(mouse.winid) then
          vim.api.nvim_set_current_win(mouse.winid)
        end
      end,
      ['<CR>'] = function()
        local menu = utils.menu.get_current()
        if not menu then
          return
        end
        local cursor = vim.api.nvim_win_get_cursor(menu.win)
        local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
        if component then
          menu:click_on(component, nil, 1, 'l')
        end
      end,
      ['<MouseMove>'] = function()
        local menu = utils.menu.get_current()
        if not menu then
          return
        end
        local mouse = vim.fn.getmousepos()
        if M.opts.menu.hover then
          utils.menu.update_hover_hl(mouse)
        end
        if M.opts.menu.preview then
          utils.menu.update_preview(mouse)
        end
      end,
    },
    ---@alias winbar_menu_win_config_opts_t any|fun(menu: winbar_menu_t):any
    ---@type table<string, winbar_menu_win_config_opts_t>
    ---@see vim.api.nvim_open_win
    win_configs = {
      style = 'minimal',
      relative = 'win',
      win = function(menu)
        return menu.prev_menu and menu.prev_menu.win
          or vim.fn.getmousepos().winid
      end,
      row = function(menu)
        return menu.prev_menu
            and menu.prev_menu.clicked_at
            and menu.prev_menu.clicked_at[1] - vim.fn.line('w0')
          or 0
      end,
      ---@param menu winbar_menu_t
      col = function(menu)
        if menu.prev_menu then
          return menu.prev_menu._win_configs.width
            + (menu.prev_menu.scrollbar and 1 or 0)
        end
        local mouse = vim.fn.getmousepos()
        local bar = utils.bar.get({ win = menu.prev_win })
        if not bar then
          return mouse.wincol
        end
        local _, range = bar:get_component_at(math.max(0, mouse.wincol - 1))
        return range and range.start or mouse.wincol
      end,
      height = function(menu)
        return math.max(
          1,
          math.min(
            #menu.entries,
            vim.go.pumheight ~= 0 and vim.go.pumheight
              or math.ceil(vim.go.lines / 4)
          )
        )
      end,
      width = function(menu)
        local min_width = vim.go.pumwidth ~= 0 and vim.go.pumwidth or 8
        if vim.tbl_isempty(menu.entries) then
          return min_width
        end
        return math.max(
          min_width,
          math.max(unpack(vim.tbl_map(function(entry)
            return entry:displaywidth()
          end, menu.entries)))
        )
      end,
      zindex = function(menu)
        if not menu.prev_menu then
          return
        end
        return menu.prev_menu.scrollbar
            and menu.prev_menu.scrollbar.thumb
            and vim.api.nvim_win_get_config(menu.prev_menu.scrollbar.thumb).zindex
          or vim.api.nvim_win_get_config(menu.prev_win).zindex
      end,
    },
  },
  sources = {
    treesitter = {
      max_depth = 12,
      -- Vim regex used to extract a short name from the node text
      -- word with optional prefix and suffix: [#~!@\*&.]*[[:keyword:]]\+!\?
      -- word separators: \(->\)\+\|-\+\|\.\+\|:\+\|\s\+
      name_regex = [=[[#~!@\*&.]*[[:keyword:]]\+!\?]=]
        .. [=[\(\(\(->\)\+\|-\+\|\.\+\|:\+\|\s\+\)\?[#~!@\*&.]*[[:keyword:]]\+!\?\)*]=],
      -- The order matters! The first match is used as the type
      -- of the treesitter symbol and used to show the icon
      -- Types listed below must have corresponding icons
      -- in the `icons.kinds.symbols` table for the icon to be shown
      valid_types = {
        'block_mapping_pair',
        'break_statement',
        'call',
        'case_statement',
        'class',
        'constant',
        'constructor',
        'continue_statement',
        'delete',
        'do_statement',
        'element',
        'enum',
        'enum_member',
        'event',
        'for_statement',
        'function',
        'goto_statement',
        'if_statement',
        'interface',
        'keyword',
        'macro',
        'message',
        'method',
        'namespace',
        'null',
        'operator',
        'package',
        'pair',
        'property',
        'reference',
        'repeat',
        'return_statement',
        'rpc',
        'rule_set',
        'scope',
        'section',
        'service',
        'specifier',
        'struct',
        'switch_statement',
        'table',
        'type',
        'type_parameter',
        'unit',
        'value',
        'variable',
        'while_statement',
        'declaration',
        'field',
        'identifier',
        'object',
        'statement',
        -- 'boolean',
        -- 'module',
        -- 'number',
        -- 'text',
        -- 'string',
        -- 'array',
        -- 'list',
      },
      ---@type integer[]
      min_widths = {},
    },
    lsp = {
      max_depth = 12,
      valid_symbols = {
        'File',
        'Module',
        'Namespace',
        'Package',
        'Class',
        'Method',
        'Property',
        'Field',
        'Constructor',
        'Enum',
        'Interface',
        'Function',
        'Variable',
        'Constant',
        'String',
        'Number',
        'Boolean',
        'Array',
        'Object',
        'Keyword',
        'Null',
        'EnumMember',
        'Struct',
        'Event',
        'Operator',
        'TypeParameter',
      },
      request = {
        -- Times to retry a request before giving up
        ttl_init = 60,
        interval = 1000, -- in ms
      },
      ---@type integer[]
      min_widths = {},
    },
    markdown = {
      max_depth = 6,
      parse = {
        -- Number of lines to update when cursor moves out of the parsed range
        look_ahead = 200,
      },
      ---@type integer[]
      min_widths = {},
    },
  },
}

---Set winbar options
---@param new_opts winbar_configs_t?
function M.set(new_opts)
  M.opts = vim.tbl_deep_extend('force', M.opts, new_opts or {})
end

---Evaluate a dynamic option value (with type T|fun(...): T)
---@generic T
---@param opt T|fun(...): T
---@return T
function M.eval(opt, ...)
  if opt and vim.is_callable(opt) then
    return opt(...)
  end
  return opt
end

return M
