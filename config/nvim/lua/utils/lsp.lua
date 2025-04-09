local M = {}

---@type lsp_client_config_t
---@diagnostic disable-next-line: missing-fields
M.default_config = {
  root_markers = require('utils.fs').root_markers,
}

---@class vim.lsp.ClientConfig: lsp_client_config_t
---@class lsp_client_config_t
---@field cmd? (string[]|fun(dispatchers: table):table)
---@field cmd_cwd? string
---@field cmd_env? (table)
---@field detached? boolean
---@field workspace_folders? (table)
---@field capabilities? lsp.ClientCapabilities
---@field handlers? table<string,function>
---@field settings? table
---@field commands? table
---@field init_options? table
---@field name? string
---@field get_language_id? fun(bufnr: integer, filetype: string): string
---@field offset_encoding? string
---@field on_error? fun(code: integer)
---@field before_init? function
---@field on_init? function
---@field on_exit? fun(code: integer, signal: integer, client_id: integer)
---@field on_attach? fun(client: vim.lsp.Client, bufnr: integer)
---@field trace? 'off'|'messages'|'verbose'|nil
---@field flags? table
---@field root_dir? string
---@field root_markers? string[]
---@field requires? string[] additional executables required to start the language server
---@field buf_support? boolean whether the language server works on buffers without corresponding files

---Wrapper of `vim.lsp.start()`, starts and attaches LSP client for
---the current buffer
---@param config lsp_client_config_t
---@param opts table?
---@return integer? client_id id of attached client or nil if failed
function M.start(config, opts)
  if vim.b.bigfile or vim.bo.bt == 'nofile' or vim.g.vscode then
    return
  end

  local cmd_type = type(config.cmd)
  local cmd_exec = cmd_type == 'table' and config.cmd[1]
  if
    cmd_type == 'table' and vim.fn.executable(cmd_exec or '') == 0
    or vim.iter(config.requires or {}):any(function(e)
      return vim.fn.executable(e) == 0
    end)
  then
    return
  end

  local name = cmd_exec
  local bufname = vim.api.nvim_buf_get_name(0)

  if config.buf_support == false and not vim.uv.fs_stat(bufname) then
    return
  end

  ---Check if a directory is valid, return it if so, else return nil
  ---@param dir string?
  ---@return string?
  local function validate(dir)
    -- For some special buffers like `fugitive:///xxx`, `vim.fs.root()`
    -- returns '.' as result, which is NOT a valid directory
    return dir ~= nil
        and dir ~= '.'
        and vim.fn.isdirectory(dir) == 1
        -- Some language servers e.g. lua-language-server, refuse
        -- to use home dir as its root dir and prints an error message
        and not require('utils.fs').is_home_dir(dir)
        and not require('utils.fs').is_root_dir(dir)
        and dir
      or nil
  end

  return vim.lsp.start(
    vim.tbl_deep_extend('keep', config or {}, {
      name = name,
      root_dir = validate(
        vim.fs.root(
          bufname,
          vim.list_extend(
            config.root_markers or {},
            M.default_config.root_markers or {}
          )
        )
      ),
    }, M.default_config),
    opts
  )
end

---@class lsp_soft_stop_opts_t
---@field retry integer?
---@field interval integer?
---@field on_close fun(client: vim.lsp.Client)

---Soft stop LSP client with retries
---@param client_or_id integer|vim.lsp.Client
---@param opts lsp_soft_stop_opts_t?
function M.soft_stop(client_or_id, opts)
  local client = type(client_or_id) == 'number'
      and vim.lsp.get_client_by_id(client_or_id)
    or client_or_id --[[@as vim.lsp.Client]]
  if not client then
    return
  end
  opts = opts or {}
  opts.retry = opts.retry or 4
  opts.interval = opts.interval or 500
  opts.on_close = opts.on_close or function() end

  if client:is_stopped() then
    opts.on_close(client)
    return
  end

  if opts.retry < 0 then
    return
  end

  client:stop(opts.retry == 0)
  vim.defer_fn(function()
    opts.retry = opts.retry - 1
    M.soft_stop(client, opts)
  end, opts.interval)
end

---Restart and reattach LSP client
---@param client_or_id integer|vim.lsp.Client
---@param opts { on_restart: fun(client_id: integer)? }?
function M.restart(client_or_id, opts)
  local client = type(client_or_id) == 'number'
      and vim.lsp.get_client_by_id(client_or_id)
    or client_or_id --[[@as vim.lsp.Client]]
  if not client then
    return
  end

  -- `client.attached_buffers` will be empty after client is stopped,
  -- save it before stopping
  local attached_buffers = vim.deepcopy(client.attached_buffers, true)
  local config = client.config
  M.soft_stop(client, {
    on_close = function()
      for buf, _ in pairs(attached_buffers) do
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        vim.api.nvim_buf_call(buf, function()
          local id = M.start(config)
          if id and opts and opts.on_restart then
            opts.on_restart(id)
          end
        end)
      end
    end,
  })
end

---Check if `range1` contains `range2`
---@param range1 lsp_range_t 0-based range
---@param range2 lsp_range_t 0-based range
---@param strict boolean? only return true if `range1` fully contains `range2` (no overlapping boundaries), default false
---@return boolean
function M.range_contains(range1, range2, strict)
  local start_line1 = range1.start.line
  local start_char1 = range1.start.character
  local end_line1 = range1['end'].line
  local end_char1 = range1['end'].character
  local start_line2 = range2.start.line
  local start_char2 = range2.start.character
  local end_line2 = range2['end'].line
  local end_char2 = range2['end'].character
  -- stylua: ignore start
  return (
    start_line2 > start_line1
    or (start_line2 == start_line1
        and (
          start_char2 > start_char1
          or not strict and start_char2 == start_char1
        )
      )
    )
    and (
      start_line2 < end_line1
      or (
        start_line2 == end_line1
          and (
            start_char2 < end_char1
            or not strict and start_char2 == end_char1
          )
        )
      )
    and (
      end_line2 > start_line1
      or (
        end_line2 == start_line1
          and (
            end_char2 > start_char1
            or not strict and end_char2 == start_char1
          )
        )
      )
    and (
      end_line2 < end_line1
      or (
        end_line2 == end_line1
          and (
            end_char2 < end_char1
            or not strict and end_char2 == end_char1
          )
        )
      )
  -- stylua: ignore off
end

---Check if cursor is in range
---@param range lsp_range_t 0-based range
---@param cursor integer[]? cursor position (line, character); (1, 0)-based
---@param strict boolean? only return true if `cursor` is fully contained in `range` (not on the boundary), default false
---@return boolean
function M.range_contains_cursor(range, cursor, strict)
  cursor = cursor or vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local char = cursor[2]
  local start_line = range.start.line
  local start_char = range.start.character
  local end_line = range['end'].line
  local end_char = range['end'].character
  return (
    line > start_line
    or (
      line == start_line
      and (char > start_char or not strict and char == start_char)
    )
  )
    and (
      line < end_line
      or (
        line == end_line
        and (char < end_char or not strict and char == end_char)
      )
    )
end

return M
