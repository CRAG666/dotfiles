-- Port of nvim's `plugin/run_code.lua` (code_runner.nvim)
-- vis has no terminal buffers: commands run fullscreen and wait for <Enter>;
-- PDFs open in zathura, which reloads them on rebuild

local util = require('core.util')
local sh = util.shellescape

local M = {}

---Run `cmd` in the terminal from `dir`
---@param cmd string
---@param dir string
function M.term(cmd, dir)
  vis:pipe(
    string.format(
      '{ cd %s && %s; } </dev/tty >/dev/tty 2>&1; s=$?;'
        .. ' printf \'\\n[exit %%d] Press Enter\' "$s" >/dev/tty; read _ </dev/tty',
      sh(dir),
      cmd
    ),
    true
  )
  vis:redraw()
end

---Shell snippet opening `pdf` in zathura, detached from vis
---@param pdf string shell word, may contain variables
---@return string
local function preview(pdf)
  return string.format('setsid -f zathura %s >/dev/null 2>&1', pdf)
end

---@param path string
---@return string
local function stem(path)
  return (path:match('([^/]+)$'):gsub('%.[^.]*$', ''))
end

---@param options string[][] `{ label, command }` pairs
---@param dir string
local function choose(options, dir)
  local labels = {}
  for _, option in ipairs(options) do
    table.insert(labels, option[1])
  end
  local choice = require('core.pick').select(labels, 'Run')
  for _, option in ipairs(options) do
    if option[1] == choice then
      M.term(option[2], dir)
    end
  end
end

---@param compiler string
---@param path string
---@return string
local function compile_c(compiler, path)
  local bin = '/tmp/' .. stem(path)
  return string.format(
    "printf 'Add more args: '; read -r args; %s %s -o %s $args && %s; rm -f %s",
    compiler,
    sh(path),
    sh(bin),
    sh(bin),
    sh(bin)
  )
end

---Runners by vis syntax
---@type table<string, fun(path: string, dir: string)>
M.runners = {
  typst = function(path, dir)
    M.term('typst compile ' .. sh(path), dir)
  end,
  python = function(path, dir)
    M.term('python -u ' .. sh(path), dir)
  end,
  bash = function(path, dir)
    M.term('bash ' .. sh(path), dir)
  end,
  ansi_c = function(path, dir)
    M.term(compile_c('gcc', path), dir)
  end,
  c = function(path, dir)
    M.term(compile_c('gcc', path), dir)
  end,
  cpp = function(path, dir)
    M.term(compile_c('g++', path), dir)
  end,
  typescript = function(path, dir)
    if path:find('%.tsx$') then
      M.term('yarn dev', dir)
    end
  end,
  latex = function(path, dir)
    local root = sh(util.root(dir, { 'Tectonic.toml' }) or dir)
    local function project(flags)
      return 'cd '
        .. root
        .. ' && tectonic -X build '
        .. flags
        .. ' && '
        .. preview('"$(ls build/*/*.pdf | head -n 1)"')
    end
    local pdflatex = sh(os.getenv('HOME') .. '/.local/bin/pdflatex')
    choose({
      { 'Project', project('') },
      { 'Project + logs', project('--synctex --keep-logs') },
      {
        'Single (tectonic)',
        string.format(
          'tectonic -X compile %s --synctex --keep-logs -Zsearch-path=/latex'
            .. ' && %s',
          sh(path),
          preview(sh(stem(path) .. '.pdf'))
        ),
      },
      {
        'Single (pdflatex)',
        pdflatex .. ' -interaction=nonstopmode main.tex && ' .. preview(
          'main.pdf'
        ),
      },
    }, dir)
  end,
  markdown = function(path, dir)
    local pdf = sh('/tmp/' .. stem(path) .. '.pdf')
    local function pandoc(format)
      return 'pandoc ' .. sh(path) .. ' -o ' .. pdf .. ' -t ' .. format
    end
    choose({
      { 'Latex', pandoc('pdf') .. ' && ' .. preview(pdf) },
      { 'Beamer', pandoc('beamer') .. ' && ' .. preview(pdf) },
      {
        'Eisvogel',
        'bash ./build.sh && ' .. preview(sh(stem(path) .. '.pdf')),
      },
    }, dir)
  end,
}

function M.run()
  local win = vis.win
  local path = win.file.path
  local runner = M.runners[win.syntax or '']
  if not path or not runner then
    vis:info('No runner for ' .. (win.syntax or 'this file'))
    return
  end
  runner(path, util.file_dir(win))
end

vis:map(vis.modes.NORMAL, ' mc', M.run, 'Compile and run code')

return M
