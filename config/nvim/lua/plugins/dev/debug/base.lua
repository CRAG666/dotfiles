vim.pack.add({ 'https://github.com/mfussenegger/nvim-dap' })

local dap = require('dap')
local key = require('utils.key')
local icons = require('utils.static.icons')

local function set_cond_breakpoint()
  dap.set_breakpoint(nil, vim.fn.input('Breakpoint condition: '))
end

local function set_logpoint()
  dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end

local last_dap_fn = function() end

---Wrap a function to set it as the last function to be called
---@param fn function
---@return function
local function wrap(fn)
  return function()
    last_dap_fn = fn
    fn()
  end
end

local dap_set_cond_breakpoint = wrap(set_cond_breakpoint)
local dap_set_logpoint = wrap(set_logpoint)
local dap_up = wrap(dap.up)
local dap_down = wrap(dap.down)
local dap_continue = wrap(dap.continue)
local dap_pause = wrap(dap.pause)
local dap_repl_open = wrap(dap.repl.open)
local dap_toggle_breakpoint = wrap(dap.toggle_breakpoint)
local dap_step_over = wrap(dap.step_over)
local dap_step_into = wrap(dap.step_into)
local dap_step_out = wrap(dap.step_out)
local dap_terminate = wrap(dap.terminate)
local dap_restart = wrap(dap.restart)

-- stylua: ignore start
vim.keymap.set('n', '<F1>',  dap_up,                  { desc = 'Stack up' })
vim.keymap.set('n', '<F2>',  dap_down,                { desc = 'Stack down' })
vim.keymap.set('n', '<F5>',  dap_continue,            { desc = 'Continue program execution' })
vim.keymap.set('n', '<F6>',  dap_pause,               { desc = 'Pause program execution' })
vim.keymap.set('n', '<F8>',  dap_repl_open,           { desc = 'Open debug REPL' })
vim.keymap.set('n', '<F9>',  dap_toggle_breakpoint,   { desc = 'Toggle breakpoint' })
vim.keymap.set('n', '<F10>', dap_step_over,           { desc = 'Step over' })
vim.keymap.set('n', '<F11>', dap_step_into,           { desc = 'Step into' })
vim.keymap.set('n', '<F17>', dap_terminate,           { desc = 'Terminate debug session' })
vim.keymap.set('n', '<F23>', dap_step_out,            { desc = 'Step out' })
vim.keymap.set('n', '<F41>', dap_restart,             { desc = 'Restart debug session' })
vim.keymap.set('n', '<F21>', dap_set_cond_breakpoint, { desc = 'Set conditional breakpoint' })
vim.keymap.set('n', '<F45>', dap_set_logpoint,        { desc = 'Set logpoint' })

vim.keymap.set('n', '<Leader>Gk',      dap_up,                  { desc = 'Stack up' })
vim.keymap.set('n', '<Leader>Gj',      dap_down,                { desc = 'Stack down' })
vim.keymap.set('n', '<Leader>G<Up>',   dap_up,                  { desc = 'Stack up' })
vim.keymap.set('n', '<Leader>G<Down>', dap_down,                { desc = 'Stack down' })
vim.keymap.set('n', '<Leader>Gc',      dap_continue,            { desc = 'Continue program execution' })
vim.keymap.set('n', '<Leader>Gg',      dap_continue,            { desc = 'Continue program execution' })
vim.keymap.set('n', '<Leader>GG',      dap_continue,            { desc = 'Continue program execution' })
vim.keymap.set('n', '<Leader>Gh',      dap_pause,               { desc = 'Pause program execution' })
vim.keymap.set('n', '<Leader>Gp',      dap_pause,               { desc = 'Pause program execution' })
vim.keymap.set('n', '<C-c>',           dap_pause,               { desc = 'Pause program execution' })
vim.keymap.set('n', '<Leader>Ge',      dap_repl_open,           { desc = 'Open debug REPL' })
vim.keymap.set('n', '<Leader>Gb',      dap_toggle_breakpoint,   { desc = 'Toggle breakpoint' })
vim.keymap.set('n', '<Leader>Gn',      dap_step_over,           { desc = 'Step over' })
vim.keymap.set('n', '<Leader>Gi',      dap_step_into,           { desc = 'Step into' })
vim.keymap.set('n', '<Leader>Go',      dap_step_out,            { desc = 'Step out' })
vim.keymap.set('n', '<Leader>Gt',      dap_terminate,           { desc = 'Terminate debug session' })
vim.keymap.set('n', '<Leader>Gx',      dap_terminate,           { desc = 'Terminate debug session' })
vim.keymap.set('n', '<Leader>Gr',      dap_restart,             { desc = 'Restart debug session' })
vim.keymap.set('n', '<Leader>GB',      dap_set_cond_breakpoint, { desc = 'Set conditional breakpoint' })
vim.keymap.set('n', '<Leader>Gl',      dap_set_logpoint,        { desc = 'Set logpoint' })
vim.keymap.set('n', '<Leader>G<Esc>',  '<Nop>',                 { desc = 'Cancel debug action' })
-- stylua: ignore end

-- When there's active dap session, use `<CR>` to repeat the last dap function
key.amend('n', '<CR>', function(fallback)
  if dap.session() then
    last_dap_fn()
    return
  end
  fallback()
end)

vim.api.nvim_create_user_command('DapClear', dap.clear_breakpoints, {
  desc = 'Clear all breakpoints',
})

-- stylua: ignore start
vim.fn.sign_define('DapBreakpoint',          { text = vim.trim(icons.debug.Breakpoint), texthl = 'DiagnosticSignHint' })
vim.fn.sign_define('DapBreakpointCondition', { text = vim.trim(icons.debug.BreakpointCondition), texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DapBreakpointRejected',  { text = vim.trim(icons.debug.BreakpointRejected), texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DapLogPoint',            { text = vim.trim(icons.debug.BreakpointLog), texthl = 'DiagnosticSignOk' })
vim.fn.sign_define('DapStopped',             { text = vim.trim(icons.debug.StackFrame), texthl = 'DiagnosticSignError' })
-- stylua: ignore end

dap.adapters = {}
dap.configurations = {}

require('utils.ft').auto_load_once('dap-configs', function(ft, spec)
  if not spec then
    return false
  end
  dap.adapters[spec.config[1].type] = spec.adapter
  dap.configurations[ft] = spec.config
  return true
end)
