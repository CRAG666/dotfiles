local M = {}
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node

---Check if current file is bash
---@return boolean
local function is_bash()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename:match('%.bash$') then
    return true
  end

  -- Check first line for bash shebang
  local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ''
  return first_line:match('^#!.*bash') ~= nil
end

---Determine opening bracket type based on file detection
---@return string
local function get_lbrkt()
  return is_bash() and '[[' or '['
end

---Determine closing bracket type based on file detection
---@return string
local function get_rbrkt()
  return is_bash() and ']]' or ']'
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
          i(nil, '/bin/bash'),
          i(nil, '/usr/bin/env sh'),
          i(nil, '/bin/sh'),
        } or {
          i(nil, '/usr/bin/env sh'),
          i(nil, '/bin/sh'),
          i(nil, '/usr/bin/env bash'),
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
        if <lbrkt> <cond> <rbrkt>; then
        <body>
        fi
      ]],
      {
        lbrkt = f(get_lbrkt),
        rbrkt = f(get_rbrkt),
        cond = i(1),
        body = un.body(2, 1),
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
        if <lbrkt> <cond> <rbrkt>; then
        <body>
        else
        <idnt><else_body>
        fi
      ]],
      {
        lbrkt = f(get_lbrkt),
        rbrkt = f(get_rbrkt),
        cond = i(1),
        body = un.body(2, 1),
        else_body = i(3),
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
        elif <lbrkt> <cond> <rbrkt>; then
        <body>
      ]],
      {
        lbrkt = f(get_lbrkt),
        rbrkt = f(get_rbrkt),
        cond = i(1),
        body = un.body(2, 1),
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
        items = i(2, '${items[@]}'),
        body = un.body(3, 1),
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
        while <lbrkt> <cond> <rbrkt>; do
        <body>
        done
      ]],
      {
        lbrkt = f(get_lbrkt),
        rbrkt = f(get_rbrkt),
        cond = i(1),
        body = un.body(2, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'func' },
      { trig = 'function' },
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
      { trig = 'cs' },
      { trig = 'ca' },
      { trig = 'case' },
      common = { desc = 'case statement' },
    },
    un.fmtad(
      [[
        case <expr> in
        <idnt><pattern>)
        <body>
        <idnt>;;
        esac
      ]],
      {
        expr = i(1, '$1'),
        pattern = i(2, '*'),
        body = un.body(3, 2),
        idnt = un.idnt(1),
      }
    )
  ),
  us.sn(
    {
      trig = 'pat',
      desc = 'case pattern',
    },
    un.fmtad(
      [[
        <pattern>)
        <body>
        ;;
      ]],
      {
        pattern = i(1, '*'),
        body = un.body(2, 1),
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
        items = i(2, '${items[@]}'),
        body = un.body(3, 1),
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
        until <lbrkt> <cond> <rbrkt>; do
        <body>
        done
      ]],
      {
        lbrkt = f(get_lbrkt),
        rbrkt = f(get_rbrkt),
        cond = i(1),
        body = un.body(2, 1),
      }
    )
  ),
  us.msn({
    { trig = 'p' },
    { trig = 'e' },
    { trig = 'ech' },
    { trig = 'echo' },
  }, {
    t('echo '),
    c(1, {
      i(nil, '"$1"'),
      i(nil, "'$1'"),
      i(nil, '$1'),
    }),
  }),
  us.msn(
    {
      { trig = 'pl' },
      { trig = 'el' },
      common = { desc = 'Print a line' },
    },
    un.fmtad('echo "<line>"', {
      line = c(1, {
        -- stylua: ignore start
        i(nil, '----------------------------------------'),
        i(nil, '========================================'),
        i(nil, '........................................'),
        i(nil, '++++++++++++++++++++++++++++++++++++++++'),
        i(nil, '****************************************'),
        i(nil, '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'),
        i(nil, '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'),
        i(nil, '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'),
        i(nil, '########################################'),
        i(nil, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'),
        -- stylua: ignore end
      }),
    })
  ),
  us.msn(
    {
      { trig = 'pck' },
      { trig = 'eck' },
      { trig = 'pcheck' },
      { trig = 'echeck' },
      common = { desc = 'Debug check expression value' },
    },
    un.fmtad([[echo '<v_esc>:' <v>]], {
      v = i(1, '"$var"'),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\'):gsub([[']], [['"'"']])
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.msn(
    {
      { trig = 'ck' },
      { trig = 'check' },
      common = {
        priority = 999,
        desc = 'Debug check expression value (cont.)',
      },
    },
    un.fmtad([['<v_esc>:' <v>]], {
      v = i(1, '"$var"'),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\'):gsub([[']], [['"'"']])
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.msn({
    { trig = 'r' },
    { trig = 'read' },
    common = { desc = 'read input' },
  }, {
    t('read '),
    c(1, {
      i(nil, '-r var'),
      i(nil, '-p "Prompt: " var'),
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
      un.fmtad('readonly <name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
    }),
  }),
  us.msn(
    {
      { trig = 'go' },
      { trig = 'getopts' },
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
        body = un.body(2, 2),
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
        t('EXIT'),
        t('SIGINT SIGTERM'),
        t('ERR'),
      }),
    })
  ),
}

return M
