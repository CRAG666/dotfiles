local M = {}

---@type lsp.config
---@diagnostic disable-next-line: missing-fields
M.default_config = {
  root_markers = require('utils.fs').root_markers,
}

---@class (partial) lsp.config : vim.lsp.Config
---@field requires? string[] additional executables required to start the language server
---@field buf_support? boolean whether the language server works on buffers without corresponding files

-- Avoid recursion after overriding
local lsp_start = vim.lsp.start

---Wrapper of `vim.lsp.start()`, starts and attaches LSP client for
---the current buffer
---@param config lsp.config
---@param opts table?
---@return integer? client_id id of attached client or nil if failed
function M.start(config, opts)
  if not config or vim.bo.bt == 'nofile' then
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
        and dir ~= ''
        and dir ~= '.'
        and vim.fn.isdirectory(dir) == 1
        -- Some language servers e.g. lua-language-server, refuse
        -- to use home dir as its root dir and prints an error message
        and not require('utils.fs').is_home_dir(dir)
        and not require('utils.fs').is_root_dir(dir)
        and dir
      or nil
  end

  local root_dir = validate(
    require('utils.fs').root(
      bufname,
      vim.list_extend(
        config.root_markers or {},
        M.default_config.root_markers or {}
      )
    )
  ) or validate(vim.fs.dirname(bufname)) or vim.fn.getcwd(0)

  return lsp_start(
    vim.tbl_deep_extend('keep', config or {}, {
      name = name,
      root_dir = root_dir,
    }, M.default_config),
    opts
  )
end

---@class lsp.soft_stop.opts
---@field retry integer?
---@field interval integer?
---@field on_close fun(client: vim.lsp.Client)

---Soft stop LSP client with retries
---@param client_or_id integer|vim.lsp.Client
---@param opts lsp.soft_stop.opts?
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
          ---@cast config lsp.config
          local id = M.start(config)
          if id and opts and opts.on_restart then
            opts.on_restart(id)
          end
        end)
      end
    end,
  })
end

---@class lsp.range
---@field start {line: integer, character: integer}
---@field end {line: integer, character: integer}

---Check if `range1` contains `range2`
---@param r1 lsp.range 0-based range
---@param r2 lsp.range 0-based range
---@param strict boolean? only return true if `range1` fully contains `range2` (no overlapping boundaries), default false
---@return boolean
function M.range_contains(r1, r2, strict)
  return (
    r2.start.line > r1.start.line
    or (
      r2.start.line == r1.start.line
      and (
        r2.start.character > r1.start.character
        or not strict and r2.start.character == r1.start.character
      )
    )
  )
    and (r2.start.line < r1['end'].line or (r2.start.line == r1['end'].line and (r2.start.character < r1['end'].character or not strict and r2.start.character == r1['end'].character)))
    and (r2['end'].line > r1.start.line or (r2['end'].line == r1.start.line and (r2['end'].character > r1.start.character or not strict and r2['end'].character == r1.start.character)))
    and (
      r2['end'].line < r1['end'].line
      or (
        r2['end'].line == r1['end'].line
        and (
          r2['end'].character < r1['end'].character
          or not strict and r2['end'].character == r1['end'].character
        )
      )
    )
end

---Check if cursor is in range
---@param range lsp.range 0-based range
---@param cursor integer[]? cursor position (line, character); (1, 0)-based
---@param strict boolean? only return true if `cursor` is fully contained in `range` (not on the boundary), default false
---@return boolean
function M.range_contains_cursor(range, cursor, strict)
  cursor = cursor or vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local char = cursor[2]
  return (
    line > range.start.line
    or (
      line == range.start.line
      and (
        char > range.start.character
        or not strict and char == range.start.character
      )
    )
  )
    and (
      line < range['end'].line
      or (
        line == range['end'].line
        and (
          char < range['end'].character
          or not strict and char == range['end'].character
        )
      )
    )
end

return M
