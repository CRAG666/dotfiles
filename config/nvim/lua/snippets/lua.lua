local M = {}
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

M.syntax = {
  us.msn({
    { trig = 'lv' },
    { trig = 'lc' },
    { trig = 'l=' },
  }, {
    t('local '),
    i(1, 'var'),
    t(' = '),
    i(0, 'value'),
  }),
  us.msn({
    { trig = 'lf' },
    { trig = 'lfn' },
    { trig = 'lfun' },
    { trig = 'lfunc' },
    { trig = 'lfunction' },
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
    { trig = 'function' },
  }, {
    c(1, {
      sn(nil, {
        t('function('),
        r(1, 'params'),
        t({ ')', '' }),
      }),
      sn(nil, {
        t('function '),
        i(1, 'fn_name'),
        t('('),
        r(2, 'params'),
        t({ ')', '' }),
      }),
    }),
    un.body(2, 1),
    t({ '', 'end' }),
  }),
  us.msn({
    { trig = 'me' },
    { trig = 'method' },
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
  us.sn({ trig = 'for' }, {
    t('for '),
    c(1, {
      sn(nil, {
        r(1, 'idx'),
        t(', '),
        r(2, 'val'),
        t(' in ipairs('),
        r(3, 'it'),
        t(')'),
      }),
      sn(nil, {
        i(1, 'key'),
        t(', '),
        r(2, 'val'),
        t(' in pairs('),
        r(3, 'it'),
        t(')'),
      }),
      sn(nil, {
        r(1, 'val'),
        t(' in '),
        r(2, 'it'),
      }),
      sn(nil, {
        r(1, 'idx'),
        t(' = '),
        r(2, 'start'),
        t(', '),
        r(3, 'stop'),
        t(', '),
        i(4, 'step'),
      }),
      sn(nil, {
        r(1, 'idx'),
        t(' = '),
        r(2, 'start'),
        t(', '),
        r(3, 'stop'),
      }),
    }),
    t({ ' do', '' }),
    un.body(2, 1),
    t({ '', 'end' }),
  }, {
    stored = {
      idx = i(nil, '_'),
      it = i(nil, 'iterable'),
      val = i(nil, 'val'),
      start = i(nil, 'start'),
      stop = i(nil, 'stop'),
    },
  }),
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
  us.msn({
    { trig = 'p' },
  }, {
    t('print('),
    i(1),
    t(')'),
  }),
  us.msn(
    {
      {
        trig = 'pl',
        dscr = 'Print a line',
      },
    },
    un.fmtad('print(<q><v><q>)', {
      q = un.qt(),
      v = c(1, {
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
  us.msn(
    {
      { trig = 'pck' },
      { trig = 'pcheck' },
    },
    un.fmtad('print(<q><v_esc>: <q> .. <inspect>(<v>)<e>)', {
      q = un.qt(),
      v = i(1),
      inspect = c(2, {
        i(nil, 'inspect'),
        i(nil, 'vim.inspect'),
        i(nil, 'tostring'),
      }),
      v_esc = d(3, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
      e = i(4),
    })
  ),
  us.msn(
    {
      common = { priority = 999 },
      { trig = 'ck' },
      { trig = 'check' },
    },
    un.fmtad('<q><v_esc>: <q> .. <inspect>(<v>)', {
      q = un.qt(),
      v = i(1),
      inspect = c(2, {
        i(nil, 'inspect'),
        i(nil, 'vim.inspect'),
        i(nil, 'tostring'),
      }),
      v_esc = d(3, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.msnr(
    {
      { trig = '(%S*)(%s*)%.%.%s*ck' },
      { trig = '(%S*)(%s*)%.%.%s*check' },
    },
    un.fmtad('<spc>.. <q>, <v_esc>: <q> .. <inspect>(<v>)', {
      spc = f(function(_, snip, _)
        return snip.captures[1] == '' and snip.captures[2]
          or snip.captures[1] .. ' '
      end, {}, {}),
      q = un.qt(),
      v = i(1),
      inspect = c(2, {
        i(nil, 'inspect'),
        i(nil, 'vim.inspect'),
        i(nil, 'tostring'),
      }),
      v_esc = d(3, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.sn({ trig = 'nf', desc = 'Disable stylua format' }, {
    t({ '-- stylua: ignore start', '' }),
    un.body(1, 0),
    t({ '', '-- stylua: ignore off' }),
  }),
}

return M
