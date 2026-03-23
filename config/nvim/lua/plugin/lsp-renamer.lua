local lsp = vim.lsp
local api = vim.api

local function get_text_at_range(range, position_encoding)
  return api.nvim_buf_get_text(
    0,
    range.start.line,
    lsp.util._get_line_byte_from_position(0, range.start, position_encoding),
    range['end'].line,
    lsp.util._get_line_byte_from_position(0, range['end'], position_encoding),
    {}
  )[1]
end

local function get_symbol_to_rename(cb)
  local cword = vim.fn.expand('<cword>')
  local clients =
    lsp.get_clients({ bufnr = 0, method = 'textDocument/rename' })
  if #clients == 0 then
    cb(cword)
    return
  end
  table.sort(clients, function(a, b)
    return a:supports_method('textDocument/prepareRename')
      and not b:supports_method('textDocument/prepareRename')
  end)
  local client = clients[1]
  if client:supports_method('textDocument/prepareRename') then
    local params = lsp.util.make_position_params(0, client.offset_encoding)
    client:request('textDocument/prepareRename', params, function(err, result)
      if err or not result then
        cb(cword)
        return -- fix: missing early return in original
      end
      local symbol_text = cword
      if result.placeholder then
        symbol_text = result.placeholder
      elseif result.start then
        symbol_text = get_text_at_range(result, client.offset_encoding)
      elseif result.range then
        symbol_text = get_text_at_range(result.range, client.offset_encoding)
      end
      cb(symbol_text)
    end, 0)
  else
    cb(cword)
  end
end

return function()
  -- Must capture position params BEFORE opening the float — once the float
  -- takes focus, make_position_params(0, ...) would point to the float buffer.
  local rename_params = {}
  local clients =
    lsp.get_clients({ bufnr = 0, method = 'textDocument/rename' })
  for _, client in ipairs(clients) do
    rename_params[client.id] = {
      client = client,
      params = lsp.util.make_position_params(0, client.offset_encoding),
    }
  end

  get_symbol_to_rename(function(to_rename)
    local buf = api.nvim_create_buf(false, true)
    local winopts = {
      height = 1,
      style = 'minimal',
      border = 'single',
      row = 1,
      col = 1,
      relative = 'cursor',
      width = math.max(20, #to_rename + 15),
      title = { { ' Renamer ', 'LspRenamerTitle' } },
      title_pos = 'center',
    }

    local win = api.nvim_open_win(buf, true, winopts)
    vim.wo[win].winhl = 'Normal:Normal,FloatBorder:LspRenamerBorder'
    -- buftype nofile: unlike "prompt", text is visible in minimal float windows
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    api.nvim_buf_set_lines(buf, 0, -1, true, { to_rename })
    -- startinsert! places cursor at end of line (equivalent to original "A")
    vim.cmd('startinsert!')

    local closed = false
    local function close()
      if closed then
        return
      end
      closed = true
      if api.nvim_win_is_valid(win) then
        api.nvim_win_close(win, true)
      end
      -- stopinsert prevents insert mode leaking back into the original buffer
      vim.cmd('stopinsert')
    end

    local function confirm()
      local newName =
        vim.trim(api.nvim_buf_get_lines(buf, 0, 1, false)[1] or '')
      close()
      if #newName == 0 or newName == to_rename then
        return
      end
      -- Use the pre-captured params so the position points to the original
      -- buffer, not the float. Call each client directly — lsp.buf_request()
      -- is deprecated since Neovim 0.11.
      for _, entry in pairs(rename_params) do
        entry.params.newName = newName
        entry.client:request(
          'textDocument/rename',
          entry.params,
          function(err, result)
            if err then
              return
            end
            lsp.util.apply_workspace_edit(result, entry.client.offset_encoding)
          end,
          0
        )
      end
    end

    vim.keymap.set(
      { 'i', 'n' },
      '<Esc>',
      close,
      { buffer = buf, nowait = true }
    )
    vim.keymap.set(
      { 'i', 'n' },
      '<C-c>',
      close,
      { buffer = buf, nowait = true }
    )
    vim.keymap.set(
      { 'i', 'n' },
      '<CR>',
      confirm,
      { buffer = buf, nowait = true }
    )

    api.nvim_create_autocmd('BufLeave', {
      buffer = buf,
      once = true,
      callback = function()
        vim.schedule(close)
      end,
    })
  end)
end
