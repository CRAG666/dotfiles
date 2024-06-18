local M = {}
local un = require('snippets.utils.nodes')
local us = require('snippets.utils.snips')
local conds = require('snippets.utils.conds')
local ls = require('luasnip')
local t = ls.text_node
local i = ls.insert_node
local l = require('luasnip.extras').lambda
local dl = require('luasnip.extras').dynamic_lambda

M.math = require('snippets.shared.math')

M.format = {
  us.sn({
    trig = '^# ',
    regTrig = true,
    hidden = true,
    snippetType = 'autosnippet',
  }, {
    t('# '),
    dl(1, l.TM_FILENAME:gsub('^%d*_', ''):gsub('_', ' '):gsub('%..*', ''), {}),
  }),
  us.sn('pkgs', {
    t({ '---', '' }),
    t({ 'header-includes:', '' }),
    un.idnt(1),
    t({ '- \\usepackage{gensymb}', '' }),
    un.idnt(1),
    t({ '- \\usepackage{amsmath}', '' }),
    un.idnt(1),
    t({ '- \\usepackage{amssymb}', '' }),
    un.idnt(1),
    t({ '- \\usepackage{mathtools}', '' }),
    t({ '---', '' }),
  }),
}

M.markers = {
  us.msan({
    {
      trig = '**',
      priority = 999,
    },
    {
      trig = '*',
      condition = conds.in_normalzone
        * conds.before_pattern('%*')
        * conds.after_pattern('%*'),
      show_condition = conds.in_normalzone
        * conds.before_pattern('%*')
        * conds.after_pattern('%*'),
    },
  }, { t('*'), i(0), t('*') }),
  us.msn({
    common = { desc = 'Code block' },
    { trig = 'cb' },
    { trig = 'cdb' },
  }, {
    t('```'),
    i(1),
    t({ '', '' }),
    i(0),
    t({ '', '```' }),
  }),
  us.sn({
    trig = 'cd',
    desc = 'Inline code',
  }, {
    t('`'),
    i(1),
    t('`'),
  }),
}

M.titles = {
  us.sn({ trig = 'h1' }, { t('# '), i(0) }),
  us.sn({ trig = 'h2' }, { t('## '), i(0) }),
  us.sn({ trig = 'h3' }, { t('### '), i(0) }),
  us.sn({ trig = 'h4' }, { t('#### '), i(0) }),
  us.sn({ trig = 'h5' }, { t('##### '), i(0) }),
  us.sn({ trig = 'h6' }, { t('###### '), i(0) }),
}

M.theorems = {
  us.sn({ trig = 'theo' }, { t('***'), i(1, 'Theorem'), t('***') }),
  us.sn({ trig = 'def' }, { t('***'), i(1, 'Definition'), t('***') }),
  us.sn({ trig = 'pro' }, { t('***'), i(1, 'Proof'), t('***') }),
  us.sn({ trig = 'lem' }, { t('***'), i(1, 'Lemma'), t('***') }),
}

return M
