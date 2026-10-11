vis.events.subscribe(vis.events.INIT, function()
  vis.options.autoindent = true
  vis.options.ignorecase = true
  -- `timeout = false` in nvim; vis only needs to tell <Esc> from escape
  -- sequences
  vis.options.escdelay = 10
  -- External commands run through the shell; avoid zsh startup on each pipe
  vis.options.shell = '/bin/sh'
  vis:command('set theme eyes')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  win.options.numbers = true
  -- `cursorlineopt = 'number'`: the theme only highlights the line number
  win.options.cursorline = false
  win.options.colorcolumn = 80
  -- `fillchars.eob = ' '`
  win.options.showeof = false
  -- `linebreak`: vis always soft-wraps, break at word boundaries
  win.options.breakat = ' \t;:,.!?'
end)
