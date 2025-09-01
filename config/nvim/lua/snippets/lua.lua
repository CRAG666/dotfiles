local M = {}
local u = require('utils')
local un = require('utils.snippets.nodes')
local uf = require('utils.snippets.funcs')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

---Determine if the current lua file is a nvim configuration file
---@return boolean
local function is_nvim_lua()
  if vim.b._ls_is_nvim_lua then
    return true
  end

  -- Check if the file or its cwd is in nvim runtime path
  local bufname = vim.api.nvim_buf_get_name(0)
  if
    vim.iter(vim.api.nvim_list_runtime_paths()):any(function(rtp)
      return u.fs.contains(rtp, bufname)
    end)
  then
    vim.b._ls_is_nvim_lua = true
    return true
  end

  -- Check if the file contains 'vim.xxx'
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:match('vim%.') then
      vim.b._ls_is_nvim_lua = true
      return true
    end
  end

  return false
end

M.snippets = {
  us.msns({
    { trig = 'sb' },
    { trig = '#!', snippetType = 'autosnippet' },
    desc = 'Shebang',
  }, {
    t('#!'),
    c(1, {
      i(nil, '/usr/bin/env luajit'),
      i(nil, '/usr/bin/env lua5.4'),
      i(nil, '/usr/bin/env lua5.3'),
      i(nil, '/usr/bin/env lua5.2'),
      i(nil, '/usr/bin/env lua5.1'),
      i(nil, '/usr/bin/luajit'),
      i(nil, '/usr/bin/lua5.4'),
      i(nil, '/usr/bin/lua5.3'),
      i(nil, '/usr/bin/lua5.2'),
      i(nil, '/usr/bin/lua5.1'),
    }),
  }),
  us.msn({
    { trig = 'lv' },
    { trig = 'lc' },
    { trig = 'l=' },
  }, {
    t('local '),
    i(1, 'var'),
    t(' = '),
    un.body(2, 0, 'value'),
  }),
  us.msn({
    { trig = 'lf' },
    { trig = 'lfn' },
    { trig = 'lfun' },
    { trig = 'lfunc' },
  }, {
    t('local function '),
    i(1, 'func'),
    t('('),
    i(2),
    t({ ')', '' }),
    un.body(3, 1),
    t({ '', 'end' }),
  }),
  us.msn({
    { trig = 'fn' },
    { trig = 'fun' },
    { trig = 'func' },
  }, {
    d(1, function()
      if
        u.ts.find_node({
          'field', --- { function() ... end, ... }
          'arguments', -- foo(function() ... end, ...)
          'assignment', -- val = function() ... end
          'return_statement', -- return function() ... end
          'table_constructor', -- unnamed function in list
          'binary_expression', -- <expression> and function() ... end
          'parenthesized_expression', -- (function() ... end)()
        }, { ignore_injections = false })
      then
        -- Unnamed function
        return sn(nil, {
          t('function('),
          r(1, 'params'),
          t({ ')', '' }),
        })
      end
      -- Named function
      return sn(nil, {
        t('function '),
        i(1, 'func'),
        t('('),
        r(2, 'params'),
        t({ ')', '' }),
      })
    end),
    un.body(2, 1),
    t({ '', 'end' }),
  }),
  us.msn(
    {
      { trig = 'ifn' },
      { trig = 'ifun' },
      { trig = 'ifunc' },
      common = { desc = 'Immediate function evaluation' },
    },
    un.fmtad(
      [[
        (function(<params>)
        <body>
        end)(<val>)
      ]],
      {
        val = i(1),
        params = i(2),
        body = un.body(3, 1),
      }
    )
  ),
  us.msn({
    { trig = 'me' },
    { trig = 'meth' },
  }, {
    t('function '),
    i(1, 'class'),
    t(':'),
    i(2, 'method'),
    t('('),
    i(3),
    t({ ')', '' }),
    un.body(4, 1),
    t({ '', 'end' }),
  }),
  us.sn({ trig = 'if' }, {
    t('if '),
    i(1, 'condition'),
    t({ ' then', '' }),
    un.body(2, 1),
    t({ '', 'end' }),
  }),
  us.msn({
    { trig = 'ife' },
    { trig = 'ifel' },
    { trig = 'ifelse' },
  }, {
    t('if '),
    i(1, 'condition'),
    t({ ' then', '' }),
    un.body(2, 1),
    t({ '', 'else', '' }),
    un.idnt(1),
    i(0),
    t({ '', 'end' }),
  }),
  us.msn({
    { trig = 'ifei' },
    { trig = 'ifeif' },
    { trig = 'ifeli' },
    { trig = 'ifelif' },
    { trig = 'ifelsei' },
    { trig = 'ifelseif' },
  }, {
    t('if '),
    i(1, 'condition_1'),
    t({ ' then', '' }),
    un.body(2, 1),
    t({ '', 'elseif ' }),
    i(3, 'condition_2'),
    t({ '', '' }),
    un.idnt(1),
    i(0),
    t({ '', 'end' }),
  }),
  us.snr({ trig = '^(%s*)elif' }, {
    un.idnt(function(_, parent)
      return uf.get_indent_depth(parent.captures[1]) - 1
    end),
    t({ 'elseif ' }),
    i(1, 'condition'),
    t({ ' then', '' }),
    un.body(2, function(_, parent)
      return uf.get_indent_depth(parent.snippet.captures[1])
    end, false),
  }),
  us.msn({
    { trig = 'eli' },
    { trig = 'elif' },
    { trig = 'elsei' },
    { trig = 'elseif' },
  }, {
    t('elseif '),
    i(1, 'condition'),
    t({ ' then', '' }),
    un.body(2, 1, false),
  }),
  us.sn(
    { trig = 'for', desc = 'For loop' },
    c(1, {
      un.fmtad(
        [[
          for <idx>, <val> in ipairs(<iter>) do
          <body>
          end
        ]],
        {
          idx = r(1, 'idx'),
          val = r(2, 'val'),
          iter = r(3, 'iter'),
          body = un.body(4, 1),
        }
      ),
      un.fmtad(
        [[
          for <key>, <val> in pairs(<iter>) do
          <body>
          end
        ]],
        {
          key = i(1, 'key'),
          val = r(2, 'val'),
          iter = r(3, 'iter'),
          body = un.body(4, 1),
        }
      ),
      un.fmtad(
        [[
          for <val> in <iter> do
          <body>
          end
        ]],
        {
          val = r(1, 'val'),
          iter = r(2, 'iter'),
          body = un.body(3, 1),
        }
      ),
      un.fmtad(
        [[
          for <idx> = <start>, <stop> do
          <body>
          end
        ]],
        {
          idx = r(1, 'idx'),
          start = r(2, 'start'),
          stop = r(3, 'stop'),
          body = un.body(4, 1),
        }
      ),
      un.fmtad(
        [[
          for <idx> = <start>, <stop>, <step> do
          <body>
          end
        ]],
        {
          idx = r(1, 'idx'),
          start = r(2, 'start'),
          stop = r(3, 'stop'),
          step = i(4, 'step'),
          body = un.body(5, 1),
        }
      ),
    }),
    {
      stored = {
        idx = i(nil, '_'),
        val = i(nil, 'val'),
        iter = i(nil, 'iter'),
        start = i(nil, 'start'),
        stop = i(nil, 'stop'),
      },
    }
  ),
  us.msn(
    {
      { trig = 'fip' },
      { trig = 'forip' },
      common = { desc = 'for ... in ipairs(...) loop' },
    },
    un.fmtad(
      [[
        for <idx>, <val> in ipairs(<iter>) do
        <body>
        end
      ]],
      {
        idx = i(1, 'i'),
        val = i(2, 'val'),
        iter = i(3, 'iter'),
        body = un.body(4, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fp' },
      { trig = 'forp' },
      common = { desc = 'for ... in pairs(...) loop' },
    },
    un.fmtad(
      [[
        for <key>, <val> in pairs(<iter>) do
        <body>
        end
      ]],
      {
        key = i(1, 'key'),
        val = i(2, 'val'),
        iter = i(3, 'iter'),
        body = un.body(4, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'forr' },
      { trig = 'forange' },
      { trig = 'forrange' },
      common = { desc = 'for ... in ... loop' },
    },
    un.fmtad(
      [[
        for <val> in <iter> do
        <body>
        end
      ]],
      {
        val = i(1, 'val'),
        iter = i(2, 'iter'),
        body = un.body(3, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fi' },
      { trig = 'fori' },
      common = { desc = 'for i = ... loop' },
    },
    c(1, {
      un.fmtad(
        [[
          for <idx> = <start>, <stop> do
          <body>
          end
        ]],
        {
          idx = r(1, 'idx'),
          start = r(2, 'start'),
          stop = r(3, 'stop'),
          body = un.body(4, 1),
        }
      ),
      un.fmtad(
        [[
          for <idx> = <start>, <stop>, <step> do
          <body>
          end
        ]],
        {
          idx = r(1, 'idx'),
          start = r(2, 'start'),
          stop = r(3, 'stop'),
          step = i(4, 'step'),
          body = un.body(5, 1),
        }
      ),
    }),
    {
      common_opts = {
        stored = {
          idx = i(nil, 'i'),
          start = i(nil, 'start'),
          stop = i(nil, 'stop'),
        },
      },
    }
  ),
  us.msn({
    { trig = 'wh' },
    { trig = 'while' },
  }, {
    t('while '),
    i(1, 'condition'),
    t({ ' do', '' }),
    un.body(2, 1),
    t({ '', 'end' }),
  }),
  us.sn({ trig = 'do' }, {
    t({ 'do', '' }),
    un.body(1, 1),
    t({ '', 'end' }),
  }),
  us.msn({
    { trig = 'rt' },
    { trig = 'ret' },
  }, {
    t('return '),
  }),
  us.sn({ trig = 'pr' }, {
    t('print('),
    i(1),
    t(')'),
  }),
  us.sn(
    {
      trig = 'pl',
      dscr = 'Print a line',
    },
    un.fmtad('print(<q><v><q>)', {
      q = un.qt(),
      v = c(1, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
    })
  ),
  us.msn({
    { trig = 'rq' },
    { trig = 'req' },
  }, {
    t('require('),
    i(1),
    t(')'),
  }),
  us.sn({ trig = 'ps' }, {
    t('pairs('),
    i(1),
    t(')'),
  }),
  us.msn({
    { trig = 'ip' },
    { trig = 'ips' },
  }, {
    t('ipairs('),
    i(1),
    t(')'),
  }),
  us.sn(
    { trig = 'pck' },
    un.fmtad('print(<q><v_esc>: <q> .. <inspect>(<v>)<e>)', {
      q = un.qt(),
      v = i(1),
      inspect = d(2, function()
        return sn(
          nil,
          c(1, is_nvim_lua() and {
            i(nil, 'vim.inspect'),
            i(nil, 'tostring'),
            i(nil, 'inspect'),
          } or {
            i(nil, 'inspect'),
            i(nil, 'tostring'),
            i(nil, 'vim.inspect'),
          })
        )
      end),
      v_esc = d(3, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
      e = i(4),
    })
  ),
  us.sn(
    { trig = 'ck', priority = 999 },
    un.fmtad('<q><v_esc>: <q> .. <inspect>(<v>)', {
      q = un.qt(),
      v = i(1),
      inspect = d(2, function()
        return sn(
          nil,
          c(1, is_nvim_lua() and {
            i(nil, 'vim.inspect'),
            i(nil, 'tostring'),
            i(nil, 'inspect'),
          } or {
            i(nil, 'inspect'),
            i(nil, 'tostring'),
            i(nil, 'vim.inspect'),
          })
        )
      end),
      v_esc = d(3, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.snr(
    { trig = '(%S*)(%s*)%.%.%s*ck' },
    un.fmtad('<spc>.. <q>, <v_esc>: <q> .. <inspect>(<v>)', {
      spc = f(function(_, snip, _)
        return snip.captures[1] == '' and snip.captures[2]
          or snip.captures[1] .. ' '
      end, {}, {}),
      q = un.qt(),
      v = i(1),
      inspect = d(2, function()
        return sn(
          nil,
          c(1, is_nvim_lua() and {
            i(nil, 'vim.inspect'),
            i(nil, 'tostring'),
            i(nil, 'inspect'),
          } or {
            i(nil, 'inspect'),
            i(nil, 'tostring'),
            i(nil, 'vim.inspect'),
          })
        )
      end),
      v_esc = d(3, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.sn(
    { trig = 'nf', desc = 'Disable stylua format' },
    un.fmtad(
      [[
        -- stylua: ignore start
        <body>
        -- stylua: ignore end
      ]],
      { body = un.body(1, 0) }
    )
  ),
  us.ssn(
    {
      trig = 'mod',
      desc = 'Define a module',
    },
    un.fmtad(
      [[
        local <mod> = {}

        <body>

        return <mod>
      ]],
      {
        mod = i(1, 'M'),
        body = un.body(2, 0),
      }
    )
  ),
  us.msn(
    {
      { trig = 'st' },
      { trig = 'cls' },
      { trig = 'class' },
      { trig = 'struct' },
      common = { desc = 'Class definition' },
    },
    un.fmtad(
      [[
        ---@class <class_name>
        local <class_name> = {}

        function <class_name>:new(<opts>)
        <body>
        end
      ]],
      {
        class_name = i(1, 'class_name'),
        opts = i(2),
        body = un.body(2, 1),
      }
    )
  ),
}

return M
