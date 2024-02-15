local M = {}

local cmd = vim.cmd

function M.feedkeys(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

function M.has_width_gt(cols)
  -- Check if the windows width is greater than a given number of columns
  return vim.fn.winwidth(0) / 2 > cols
end

function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

function M.pmaps(mode, prefix, maps)
  mode = mode or "n"
  for _, map in pairs(maps) do
    local opts = { desc = map[3] }
    if map[4] then
      opts = vim.tbl_extend("force", opts, map[4])
    end
    M.map(mode, prefix .. map[1], map[2], opts)
  end
end

function M.maps(maps)
  for _, map in pairs(maps) do
    local mode = map.mode or "n"
    M.pmaps(mode, map.prefix, map.maps)
  end
end

function M.is_empty(s)
  return s == nil or s == ""
end

function M.get_buf_option(opt)
  local status_ok, buf_option = pcall(vim.api.nvim_get_option_value, 0, opt)
  if not status_ok then
    return nil
  else
    return buf_option
  end
end

-- Highlights functions

function M.get_highlight(hlname)
  local hl = vim.api.nvim_get_hl(hlname, true)
  setmetatable(hl, {
    __index = function(t, k)
      if k == "fg" then
        return t.foreground
      elseif k == "bg" then
        return t.background
      elseif k == "sp" then
        return t.special
      else
        return rawget(t, k)
      end
    end,
  })
  return hl
end

-- Define bg color
-- @param group Group
-- @param color Color

M.bg = function(group, col)
  cmd("hi " .. group .. " guibg=" .. col)
end

-- Define fg color
-- @param group Group
-- @param color Color
M.fg = function(group, col)
  cmd("hi " .. group .. " guifg=" .. col)
end

-- Define bg and fg color
-- @param group Group
-- @param fgcol Fg Color
-- @param bgcol Bg Color
M.fg_bg = function(group, fgcol, bgcol)
  cmd("hi " .. group .. " guifg=" .. fgcol .. " guibg=" .. bgcol)
end

function M.warn(msg, name)
  vim.notify(msg, vim.log.levels.WARN, { title = name })
end

function M.error(msg, name)
  vim.notify(msg, vim.log.levels.ERROR, { title = name })
end

function M.info(msg, name)
  vim.notify(msg, vim.log.levels.INFO, { title = name })
end

function M.simple_fold(...)
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local start_line = vim.fn.getline(fs):gsub("\t", ("\t"):rep(vim.opt.ts:get()))
  local end_line = vim.trim(vim.fn.getline(fe))
  local spaces = (" "):rep(vim.o.columns - start_line:len() - end_line:len() - 7)
  return start_line .. "  " .. end_line .. spaces
end

function M.setup(modname, opts)
  return function()
    require(modname).setup(opts)
  end
end

function M.bind(func)
  return function()
    func()
  end
end

--- get root dir from files name
---@param names string | table
---@return string
function M.get_root_dir(names)
  return vim.fs.dirname(vim.fs.find(names, {
    upward = true,
    stop = vim.uv.os_homedir(),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
  })[1])
end

function M.get_active_client_by_name(bufnr, servername)
  for _, client in pairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if client.name == servername then
      return client
    end
  end
end

function M.foldtext()
  local ok = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
  local ret = ok and vim.treesitter.foldtext and vim.treesitter.foldtext()
  if not ret or type(ret) == "string" then
    ret = { { vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1], {} } }
  end
  table.insert(ret, { " 󰇘" })

  if not vim.treesitter.foldtext then
    return table.concat(
      vim.tbl_map(function(line)
        return line[1]
      end, ret),
      " "
    )
  end
  return ret
end

M.skip_foldexpr = {} ---@type table<number,boolean>
local skip_check = assert(vim.loop.new_check())
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  -- still in the same tick and no parser
  if M.skip_foldexpr[buf] then
    return "0"
  end

  -- don't use treesitter folds for non-file buffers
  if vim.bo[buf].buftype ~= "" then
    return "0"
  end

  -- as long as we don't have a filetype, don't bother
  -- checking if treesitter is available (it won't)
  if vim.bo[buf].filetype == "" then
    return "0"
  end

  local ok = pcall(vim.treesitter.get_parser, buf)

  if ok then
    return vim.treesitter.foldexpr()
  end

  -- no parser available, so mark it as skip
  -- in the next tick, all skip marks will be reset
  M.skip_foldexpr[buf] = true
  skip_check:start(function()
    M.skip_foldexpr = {}
    skip_check:stop()
  end)
  return "0"
end

function M.inject_args(fn, wrapper)
  return function(...)
    if wrapper(...) == false then
      return
    end
    return fn(...)
  end
end

return M
