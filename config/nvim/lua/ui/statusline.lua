local utils = require('utils')
icons = require('utils.static.icons')
local groupid = vim.api.nvim_create_augroup('StatusLine', {})

_G._statusline = {}

local diag_signs_default_text = { 'E', 'W', 'I', 'H' }
local diag_severity_map = {
  [1] = 'ERROR',
  [2] = 'WARN',
  [3] = 'INFO',
  [4] = 'HINT',
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  HINT = 4,
}

---@param severity integer|string
---@return string
local function get_diag_sign_text(severity)
  local diag_config = vim.diagnostic.config()
  local signs_text = diag_config
    and diag_config.signs
    and type(diag_config.signs) == 'table'
    and diag_config.signs.text
  return signs_text
      and (signs_text[severity] or signs_text[diag_severity_map[severity]])
    or (
      diag_signs_default_text[severity]
      or diag_signs_default_text[diag_severity_map[severity]]
    )
end

-- stylua: ignore start
local modes = {
  ['n']      = 'NO',
  ['no']     = 'OP',
  ['nov']    = 'OC',
  ['noV']    = 'OL',
  ['no\x16'] = 'OB',
  ['\x16']   = 'VB',
  ['niI']    = 'IN',
  ['niR']    = 'RE',
  ['niV']    = 'RV',
  ['nt']     = 'NT',
  ['ntT']    = 'TM',
  ['v']      = 'VI',
  ['vs']     = 'VI',
  ['V']      = 'VL',
  ['Vs']     = 'VL',
  ['\x16s']  = 'VB',
  ['s']      = 'SE',
  ['S']      = 'SL',
  ['\x13']   = 'SB',
  ['i']      = 'IN',
  ['ic']     = 'IC',
  ['ix']     = 'IX',
  ['R']      = 'RE',
  ['Rc']     = 'RC',
  ['Rx']     = 'RX',
  ['Rv']     = 'RV',
  ['Rvc']    = 'RC',
  ['Rvx']    = 'RX',
  ['c']      = 'CO',
  ['cv']     = 'CV',
  ['r']      = 'PR',
  ['rm']     = 'PM',
  ['r?']     = 'P?',
  ['!']      = 'SH',
  ['t']      = 'TE',
}
-- stylua: ignore end

---Get string representation of the current mode
---@return string
function _G._statusline.mode()
  local hl = vim.bo.mod and 'StatusLineHeaderModified' or 'StatusLineHeader'
  local mode = vim.fn.mode()
  local mode_str = (mode == 'n' and (vim.bo.ro or not vim.bo.ma)) and 'RO'
    or modes[mode]
  return utils.stl.hl(string.format(' %s ', mode_str), hl) .. ' '
end

---Get diff stats for current buffer
---@return string
function _G._statusline.gitdiff()
  local diff = vim.b.gitsigns_status_dict or utils.git.diffstat()
  local added = diff.added or 0
  local changed = diff.changed or 0
  local removed = diff.removed or 0

  if added + changed + removed == 0 then
    return ''
  end

  local parts = {}

  if added > 0 then
    table.insert(
      parts,
      string.format(
        '%s %d',
        utils.stl.hl(tostring(icons.git.Added), 'StatusLineGitAdded'),
        added
      )
    )
  end

  if changed > 0 then
    table.insert(
      parts,
      string.format(
        '%s %d',
        utils.stl.hl(tostring(icons.git.Modified), 'StatusLineGitChanged'),
        changed
      )
    )
  end

  if removed > 0 then
    table.insert(
      parts,
      string.format(
        '%s %d',
        utils.stl.hl(tostring(icons.git.Removed), 'StatusLineGitRemoved'),
        removed
      )
    )
  end

  return table.concat(parts, ' ')
end

---Get string representation of current git branch
---@return string
function _G._statusline.branch()
  ---@diagnostic disable-next-line: undefined-field
  local branch = vim.b.gitsigns_status_dict and vim.b.gitsigns_status_dict.head
    or utils.git.branch()
  return branch == '' and ''
    or utils.stl.hl(tostring(' '), 'TelescopeResultsDiffDelete')
      .. utils.stl.hl(branch, 'StatuslineItalic')
end

---Get current filetype
---@return string
function _G._statusline.ft()
  local ft = vim.bo.ft == '' and '' or vim.bo.ft:gsub('^%l', string.upper)
  return utils.stl.hl(ft, 'StatuslineItalic')
end

---@return string
function _G._statusline.wordcount()
  local stats = nil
  local nwords, nchars = 0, 0 -- luacheck: ignore 311
  if
    vim.b.wc_words
    and vim.b.wc_chars
    and vim.b.wc_changedtick == vim.b.changedtick
  then
    nwords = vim.b.wc_words
    nchars = vim.b.wc_chars
  else
    stats = vim.fn.wordcount()
    nwords = stats.words
    nchars = stats.chars
    vim.b.wc_words = nwords
    vim.b.wc_chars = nchars
    vim.b.wc_changedtick = vim.b.changedtick
  end

  local vwords, vchars = 0, 0
  if vim.fn.mode():find('^[vsVS\x16\x13]') then
    stats = stats or vim.fn.wordcount()
    vwords = stats.visual_words
    vchars = stats.visual_chars
  end

  if nwords == 0 and nchars == 0 then
    return ''
  end

  return string.format(
    '%s%d word%s, %s%d char%s',
    vwords > 0 and vwords .. '/' or '',
    nwords,
    nwords > 1 and 's' or '',
    vchars > 0 and vchars .. '/' or '',
    nchars,
    nchars > 1 and 's' or ''
  )
end

---Record file name of normal buffers, key:val = fname:buffers_with_fname
---@type table<string, number[]>
local fnames = {}

---Update path diffs for buffers with the same file name
---@param bufs integer[]
---@return nil
local function update_pdiffs(bufs)
  bufs = vim.tbl_filter(vim.api.nvim_buf_is_valid, bufs)

  local path_diffs =
    utils.fs.diff(vim.tbl_map(vim.api.nvim_buf_get_name, bufs))

  for i, buf in ipairs(bufs) do
    if path_diffs[i] ~= '' then
      vim.b[buf]._stl_pdiff = path_diffs[i]
    end
  end
end

---Check if buffer is visible
---A buffer is considered visible if it is listed or has a corresponding window
---@param buf integer buffer number
---@return boolean
local function buf_visible(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and (vim.bo[buf].bl or vim.fn.bufwinid(buf) ~= -1)
end

---Add a buffer to `fnames`, calc diff for buffer with non-unique file names
---@param buf integer buffer number
---@return nil
local function add_buf(buf)
  if not buf_visible(buf) then
    return
  end

  local fname = vim.fs.basename(vim.api.nvim_buf_get_name(buf))
  if fname == '' then
    return
  end

  if not fnames[fname] then
    fnames[fname] = {}
  end

  local bufs = fnames[fname] -- buffers with the same name as the removed buf
  if not vim.tbl_contains(bufs, buf) then
    table.insert(bufs, buf)
    update_pdiffs(bufs)
  end
end

---Remove a buffer from `fnames` and update path diffs
---@param buf integer buffer number
---@param bufname string buffer name, `buf` may not be valid so we need this
---@return nil
local function remove_buf(buf, bufname)
  if buf_visible(buf) then
    return
  end

  bufname = vim.fs.basename(bufname)
  local bufs = fnames[bufname] -- buffers with the same name as the removed buf
  if not bufs then
    return
  end

  for i, b in ipairs(bufs) do
    if b == buf then
      table.remove(bufs, i)
      break
    end
  end

  local num_bufs = #bufs
  if num_bufs == 0 then
    fnames[bufname] = nil
    return
  end

  if num_bufs == 1 then
    if vim.api.nvim_buf_is_valid(bufs[1]) then
      vim.b[bufs[1]]._stl_pdiff = nil
    end
    return
  end

  -- Still have multiple buffers with the same file name,
  -- update path diffs for the remaining buffers
  update_pdiffs(bufs)
end

for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  add_buf(buf)
end

vim.api.nvim_create_autocmd({ 'BufAdd', 'BufWinEnter', 'BufFilePost' }, {
  desc = 'Track new buffer file name.',
  group = groupid,
  -- Delay adding buffer to fnames to ensure attributes, e.g.
  -- `bt`, are set for special buffers, for example, terminal buffers
  callback = vim.schedule_wrap(function(info)
    add_buf(info.buf)
    vim.cmd.redrawstatus({
      bang = true,
      mods = { emsg_silent = true },
    })
  end),
})

vim.api.nvim_create_autocmd('OptionSet', {
  desc = 'Remove invisible buffer record.',
  group = groupid,
  pattern = 'buflisted',
  callback = function(info)
    remove_buf(info.buf, info.file)
    -- For some reason, invoking `:redrawstatus` directly makes oil.nvim open
    -- a floating window shortly before opening a file
    vim.schedule(function()
      vim.cmd.redrawstatus({
        bang = true,
        mods = { emsg_silent = true },
      })
    end)
  end,
})

vim.api.nvim_create_autocmd({
  'BufLeave',
  'BufHidden',
  'BufDelete',
  'BufFilePre',
}, {
  desc = 'Remove invisible buffer from record.',
  group = groupid,
  callback = vim.schedule_wrap(function(info)
    remove_buf(info.buf, info.file)
  end),
})

vim.api.nvim_create_autocmd('WinClosed', {
  group = groupid,
  callback = function(info)
    local win = tonumber(info.match)
    if not win or not vim.api.nvim_win_is_valid(win) then
      return
    end
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    vim.schedule(function()
      remove_buf(buf, bufname)
    end)
  end,
})

---@return string
function _G._statusline.fname()
  local bname = vim.api.nvim_buf_get_name(0)

  -- Normal buffer
  if vim.bo.bt == '' then
    -- Unnamed normal buffer
    if bname == '' then
      return '[Buffer %n]'
    end
    -- Named normal buffer, show file name, if the file name is not unique,
    -- show local cwd (often project root) after the file name
    local fname = vim.fs.basename(bname)
    if vim.b._stl_pdiff then
      return string.format(
        '%s [%s]',
        utils.stl.escape(fname),
        utils.stl.escape(vim.b._stl_pdiff)
      )
    end
    return utils.stl.escape(fname)
  end

  if vim.bo.bt == 'quickfix' then
    return vim.w.quickfix_title or ''
  end

  -- Terminal buffer, show terminal command and id
  if vim.bo.bt == 'terminal' then
    local path, pid, cmd, comment = utils.term.parse_name(bname)
    if not path or not pid or not cmd then
      return '[Terminal] %F'
    end
    return string.format(
      '[Terminal %s] %s [%s]',
      utils.stl.escape(comment ~= '' and comment or pid),
      utils.stl.escape(cmd),
      utils.stl.escape(vim.fn.fnamemodify(path, ':~'):gsub('/+$', ''))
    )
  end

  -- Other special buffer types
  local prefix, suffix = bname:match('^%s*(%S+)://(.*)')
  if prefix and suffix then
    return string.format(
      '[%s] %s',
      utils.stl.escape(utils.str.snake_to_camel(prefix)),
      utils.stl.escape(suffix)
    )
  end

  return '%F'
end

---Name of python virtual environment
---@return string
function _G._statusline.venv()
  local venv_name = vim.env.VIRTUAL_ENV
      and vim.fn.fnamemodify(vim.env.VIRTUAL_ENV, ':~:.')
    or vim.env.CONDA_DEFAULT_ENV
  return venv_name and string.format('venv: %s', venv_name) or ''
end

---Text filetypes
---@type table<string, true>
local is_text = {
  [''] = true,
  ['tex'] = true,
  ['markdown'] = true,
  ['text'] = true,
}

---Check if current buffer is a python/jupyter notebook buffer
---@return boolean
local function is_python()
  return vim.startswith(vim.bo.ft, 'python')
    or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':e') == 'ipynb'
end

---Additional info for the current buffer enclosed in parentheses
---@return string
function _G._statusline.info()
  if vim.bo.bt ~= '' then
    return ''
  end

  local info = {}
  ---@param section string
  local function add_section(section)
    if section ~= '' then
      table.insert(info, section)
    end
  end

  add_section(_G._statusline.ft())

  if is_text[vim.bo.ft] and not vim.b.bigfile then
    add_section(_G._statusline.wordcount())
  end

  if is_python() then
    add_section(_G._statusline.venv())
  end

  add_section(_G._statusline.branch())
  add_section(_G._statusline.gitdiff())
  return vim.tbl_isempty(info) and ''
    or string.format('(%s) ', table.concat(info, ', '))
end

vim.api.nvim_create_autocmd('DiagnosticChanged', {
  group = groupid,
  desc = 'Update diagnostics cache for the status line.',
  callback = function(info)
    vim.b[info.buf].diag_cnt_cache = vim.diagnostic.count(info.buf)
    vim.b[info.buf].diag_str_cache = nil
    vim.cmd.redrawstatus({
      mods = { emsg_silent = true },
    })
  end,
})

---Get string representation of diagnostics for current buffer
---@return string
function _G._statusline.diag()
  if vim.b.diag_str_cache then
    return vim.b.diag_str_cache
  end
  local str = ''
  local buf_cnt = vim.b.diag_cnt_cache or {}
  for serverity_nr, severity in ipairs({ 'Error', 'Warn', 'Info', 'Hint' }) do
    local cnt = buf_cnt[serverity_nr] ~= vim.NIL and buf_cnt[serverity_nr] or 0
    if cnt > 0 then
      local icon_text = get_diag_sign_text(serverity_nr)
      local icon_hl = 'StatusLineDiagnostic' .. severity
      str = str
        .. (str == '' and '' or ' ')
        .. utils.stl.hl(icon_text, icon_hl)
        .. cnt
    end
  end
  if str:find('%S') then
    str = str .. ' '
  end
  vim.b.diag_str_cache = str
  return str
end

---Id and additional info about LSP clients
---@type table<integer, { name: string, bufs: integer[] }>
local client_info = {}

vim.api.nvim_create_autocmd('LspDetach', {
  desc = 'Clean up server info when client detaches.',
  group = groupid,
  callback = function(info)
    if info.data.client_id then
      client_info[info.data.client_id] = nil
    end
  end,
})

vim.api.nvim_create_autocmd('LspProgress', {
  desc = 'Update LSP progress info for the status line.',
  group = groupid,
  callback = function(info)
    -- Update LSP progress data
    local id = info.data.client_id
    local bufs = vim.lsp.get_buffers_by_client_id(id)
    client_info[id] = {
      name = vim.lsp.get_client_by_id(id).name,
      bufs = bufs,
    }

    vim
      .iter(bufs)
      :filter(function(buf)
        -- No need to create and attach spinners to invisible bufs
        return vim.fn.bufwinid(buf) ~= -1
      end)
      :each(function(buf)
        local b = vim.b[buf]
        if not utils.stl.spinner.id_is_valid(b.spinner_id) then
          utils.stl.spinner:new():attach(buf)
        end

        local spinner = utils.stl.spinner.get_by_id(b.spinner_id)
        if spinner.status == 'idle' then
          spinner:spin()
        end

        local type = info.data
          and info.data.params
          and info.data.params.value
          and info.data.params.value.kind
        if type == 'end' then
          spinner:finish()
        end
      end)
  end,
})

---@return string
function _G._statusline.spinner()
  local spinner = utils.stl.spinner.get_by_id(vim.b.spinner_id)
  if not spinner or spinner.icon == '' then
    return ''
  end

  local buf = vim.api.nvim_get_current_buf()
  local progs = vim
    .iter(vim.tbl_keys(client_info))
    :filter(function(id)
      return vim.tbl_contains(client_info[id].bufs, buf)
    end)
    :map(function(id)
      return client_info[id].name
    end)
    :totable()

  -- Extra progresses requiring spinner animation
  if vim.b.spinner_progs then
    vim.list_extend(progs, vim.b.spinner_progs)
  end

  if vim.tbl_isempty(progs) then
    return ''
  end

  return string.format(
    '%s %s ',
    utils.stl.hl(table.concat(progs, ', '), 'StatuslineItalic'),
    utils.stl.hl(spinner.icon, 'StatuslineSpinner')
  )
end

-- stylua: ignore start
---Statusline components
---@type table<string, string>
local components = {
  align    = [[%=]],
  flag     = [[%{%&bt==#''?'':(&bt==#'help'?'%h ':(&pvw?'%w ':(&bt==#'quickfix'?'%q ':'')))%}]],
  diag     = [[%{%v:lua._statusline.diag()%}]],
  fname    = [[%{%v:lua._statusline.fname()%} ]],
  info     = [[%{%v:lua._statusline.info()%}]],
  spinner  = [[%{%v:lua._statusline.spinner()%}]],
  mode     = [[%{%v:lua._statusline.mode()%}]],
  padding  = [[ ]],
  pos      = [[%{%&ru?"%l:%c ":""%}]],
  truncate = [[%<]],
}
-- stylua: ignore end

local stl = table.concat({
  components.mode,
  components.flag,
  components.fname,
  components.info,
  components.align,
  components.truncate,
  components.spinner,
  components.diag,
  components.pos,
})

local stl_nc = table.concat({
  components.padding,
  components.flag,
  components.fname,
  components.align,
  components.truncate,
  components.pos,
})

setmetatable(_G._statusline, {
  ---Get statusline string
  ---@return string
  __call = function()
    return vim.g.statusline_winid == vim.api.nvim_get_current_win() and stl
      or stl_nc
  end,
})

-- Prevent statusline from being overridden by qf ftplugin in quickfix windows
vim.g.qf_disable_statusline = true

---Set default highlight groups for statusline components
---@return  nil
local function set_default_hlgroups()
  local default_attr = utils.hl.get(0, {
    name = 'StatusLine',
    link = false,
    winhl_link = false,
  })

  ---@param hlgroup_name string
  ---@param attr table
  ---@return nil
  local function sethl(hlgroup_name, attr)
    local merged_attr = vim.tbl_deep_extend('keep', attr, default_attr)
    utils.hl.set_default(0, hlgroup_name, merged_attr)
  end
  -- stylua: ignore start
  sethl('StatusLineGitAdded', { fg = 'GitSignsAdd',  ctermfg = 'GitSignsAdd' })
  sethl('StatusLineGitChanged', {  fg = 'GitSignsChange', ctermfg = 'GitSignsChange' })
  sethl('StatusLineGitRemoved', {  fg = 'GitSignsDelete', ctermfg = 'GitSignsDelete' })
  sethl('StatusLineDiagnosticHint', {  fg = 'DiagnosticSignHint', ctermfg = 'DiagnosticSignHint' })
  sethl('StatusLineDiagnosticInfo', {  fg = 'DiagnosticSignInfo', ctermfg = 'DiagnosticSignInfo' })
  sethl('StatusLineDiagnosticWarn', {  fg = 'DiagnosticSignWarn', ctermfg = 'DiagnosticSignWarn' })
  sethl('StatusLineDiagnosticError', {  fg = 'DiagnosticSignError', ctermfg = 'DiagnosticSignError' })
  -- sethl('StatusLineHeader', { fg = 'TabLine', bg = 'fg', ctermfg = 'TabLine', ctermbg = 'fg', reverse = true })
  -- sethl('StatusLineHeaderModified', { fg = 'Special', bg = 'fg', ctermfg = 'Special', ctermbg = 'fg', reverse = true })
  -- stylua: ignore off
end

set_default_hlgroups()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = groupid,
  callback = set_default_hlgroups,
})

return _G._statusline
