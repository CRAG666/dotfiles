local M = {}
local u = require('utils')
local uf = require('utils.snippets.funcs')
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local conds = require('utils.snippets.conds')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node

---Check if current file is bash
---@return boolean
local function is_bash()
  if vim.bo.ft == 'bash' then
    return true
  end

  local bufname = vim.api.nvim_buf_get_name(0)
  if
    vim.fn.fnamemodify(bufname, ':e') == 'bash'
    or vim.tbl_contains(
      { '.bashrc', '.bash_profile' },
      vim.fn.fnamemodify(bufname, ':t')
    )
  then
    return true
  end

  return vim.api.nvim_buf_line_count(0) > 0
    and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]:match('^#!.*bash')
      ~= nil
end

M.snippets = {
  us.mssn({
    { trig = 'sb' },
    { trig = '#!', snippetType = 'autosnippet' },
    desc = 'Shebang',
  }, {
    t('#!'),
    d(1, function()
      return sn(
        nil,
        c(1, is_bash() and {
          i(nil, '/usr/bin/env bash'),
          i(nil, '/usr/bin/env sh'),
          i(nil, '/bin/bash'),
          i(nil, '/bin/sh'),
        } or {
          i(nil, '/usr/bin/env sh'),
          i(nil, '/usr/bin/env bash'),
          i(nil, '/bin/sh'),
          i(nil, '/bin/bash'),
        })
      )
    end),
  }),
  us.sn(
    {
      trig = 'if',
      desc = 'if statement',
    },
    un.fmtad(
      [[
        if <cond>; then
        <body>
        fi
      ]],
      {
        cond = i(1, 'true'),
        body = un.body(2, 1, ':'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'ife' },
      { trig = 'ifel' },
      { trig = 'ifelse' },
      common = { desc = 'if...else statement' },
    },
    un.fmtad(
      [[
        if <cond>; then
        <body>
        else
        <idnt><else_body>
        fi
      ]],
      {
        cond = i(1, 'true'),
        body = un.body(2, 1, ':'),
        else_body = i(3, ':'),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'elif' },
      { trig = 'eif' },
      common = { desc = 'elif statement' },
    },
    un.fmtad(
      [[
        elif <cond>; then
        <body>
      ]],
      {
        cond = i(1, 'true'),
        body = un.body(2, 1, ':'),
      }
    )
  ),
  us.sn(
    {
      trig = 'for',
      desc = 'for loop',
    },
    un.fmtad(
      [[
        for <var> in <items>; do
        <body>
        done
      ]],
      {
        var = i(1, 'item'),
        items = d(2, function()
          return is_bash() and sn(nil, i(1, '${items[@]}'))
            or sn(nil, i(1, '$items'))
        end),
        body = un.body(3, 1, ':'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'wh' },
      { trig = 'while' },
      common = { desc = 'while loop' },
    },
    un.fmtad(
      [[
        while <cond>; do
        <body>
        done
      ]],
      {
        cond = i(1, 'false'),
        body = un.body(2, 1, ':'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      common = { desc = 'Function definition' },
    },
    un.fmtad(
      [[
        <name>() {
        <body>
        }
      ]],
      {
        name = i(1, 'func'),
        body = un.body(2, 1, ':'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'ca' },
      { trig = 'cas' },
      { trig = 'case' },
      { trig = 'sw' },
      { trig = 'swi' },
      { trig = 'switch' },
      common = { desc = 'case statement' },
    },
    un.fmtad(
      [[
        case <expr> in
        <idnt><pattern>)
        <body>
        <idnt><idnt>;;<i>
        esac
      ]],
      {
        idnt = un.idnt(1),
        expr = i(1, '$1'),
        pattern = i(2, '*'),
        body = un.body(3, 2, ':'),
        i = i(4),
      }
    )
  ),
  us.snr(
    {
      trig = '^(%s*)pat',
      desc = 'case pattern',
    },
    un.fmtad(
      [[
        <ddnt><pattern>)
        <body>
        <ddnt><idnt>;;
      ]],
      {
        idnt = un.idnt(1),
        ddnt = un.ddnt(1),
        pattern = i(1, '*'),
        body = un.body(2, function(_, parent)
          return math.max(0, uf.get_indent_depth(parent.snippet.captures[1]))
        end, ':'),
      }
    )
  ),
  us.sn(
    {
      trig = 'sel',
      desc = 'select statement',
    },
    un.fmtad(
      [[
        select <var> in <items>; do
        <body>
        done
      ]],
      {
        var = i(1, 'item'),
        items = d(2, function()
          return is_bash() and sn(nil, i(1, '${items[@]}'))
            or sn(nil, i(1, '$items'))
        end),
        body = un.body(3, 1, ':'),
      }
    )
  ),
  us.sn(
    {
      trig = 'unt',
      desc = 'until loop',
    },
    un.fmtad(
      [[
        until <cond>; do
        <body>
        done
      ]],
      {
        cond = i(1, 'true'),
        body = un.body(2, 1, ':'),
      }
    )
  ),
  us.sn({ trig = 'eo' }, t('echo ')),
  us.sn({ trig = 'pr' }, t('printf ')),
  us.msn(
    {
      { trig = 'pl' },
      { trig = 'el' },
      common = { desc = 'Print a line' },
    },
    un.fmtad("echo '<line>'", {
      line = c(1, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
    })
  ),
  us.msn(
    {
      { trig = 'pck' },
      { trig = 'eck' },
      common = { desc = 'Debug check expression value' },
    },
    un.fmtad([[echo '<v_esc>:' "<v>"]], {
      v = i(1, '$var'),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\'):gsub([[']], [['"'"']])
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.sn(
    {
      trig = 'ck',
      priority = 999,
      desc = 'Debug check expression value (cont.)',
    },
    un.fmtad([['<v_esc>:' "<v>"]], {
      v = i(1, '$var'),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\'):gsub([[']], [['"'"']])
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.sn({
    trig = 'read',
    desc = 'read input',
  }, {
    t('read '),
    c(1, {
      i(nil, '-r var'),
      i(nil, "-p 'Prompt: ' var"),
      i(nil, '-n 1 var'),
    }),
  }),
  us.sn({
    trig = 'var',
    desc = 'variable declaration',
  }, {
    c(1, {
      un.fmtad('<name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
      un.fmtad('local <name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
      un.fmtad('local -r <name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
      un.fmtad('readonly <name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
    }),
  }),
  us.msn({
    { trig = 'con' },
    { trig = 'const' },
    common = { desc = 'variable declaration' },
  }, {
    c(1, {
      un.fmtad('local -r <name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
      un.fmtad('readonly <name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
    }),
  }),
  us.msn(
    {
      { trig = 'go' },
      { trig = 'geto' },
      common = { desc = 'getopts option parsing' },
    },
    un.fmtad(
      [[
        while getopts "<opts>" opt; do
        <idnt>case $opt in
        <body>
        <idnt>esac
        done
      ]],
      {
        opts = i(1, 'abc:'),
        body = un.body(2, 2, ':'),
        idnt = un.idnt(1),
      }
    )
  ),
  us.sn(
    {
      trig = 'trap',
      desc = 'trap command',
    },
    un.fmtad('trap <cmd> <sig>', {
      cmd = i(1, 'cleanup'),
      sig = c(2, {
        i(nil, 'EXIT INT TERM HUP'), -- common signals that terminates a program by default, useful for most scripts
        i(nil, 'EXIT INT TERM'), -- handle `HUP` in another trap, used in a daemon script
        i(nil, 'EXIT'),
        i(nil, 'INT'),
        i(nil, 'TERM'),
        i(nil, 'HUP'), -- disconnected from terminal, useful for interactive scripts that needs a terminal
        i(nil, 'ERR'), -- not POSIX but available in bash
      }),
    })
  ),
  us.sn(
    {
      trig = 'cd',
      desc = 'cd with exit or return',
    },
    d(1, function()
      if u.ts.find_node({ 'function_definition' }) then
        return sn(
          nil,
          un.fmtad('cd <dir> || return', {
            dir = i(1, 'dir'),
          })
        )
      end
      return sn(
        nil,
        un.fmtad('cd <dir> || exit', {
          dir = i(1, 'dir'),
        })
      )
    end)
  ),
  us.msn(
    {
      { trig = 'si' },
      { trig = 'sil' },
      common = { desc = 'Run command silently' },
    },
    c(1, {
      t('>/dev/null 2>&1'), -- suppress stdout and error
      t('2>/dev/null'), -- suppress error only
      t('>/dev/null'), -- suppress stdout only
    })
  ),
  us.msn({
    { trig = 'ne' },
    { trig = 'noe' },
    { trig = 'noerr' },
    common = { desc = 'Suppress error' },
  }, t('2>/dev/null')),
  us.sn(
    {
      trig = 'err',
      desc = 'Print to stderr',
    },
    d(1, function()
      if not conds.at_line_start() then
        return sn(nil, t('>&2'))
      end
      return sn(
        nil,
        un.fmtad('echo "<msg>" >>&2', {
          msg = i(1, 'msg'),
        })
      )
    end)
  ),
}

return M
