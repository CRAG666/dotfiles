local M = {}
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local conds = require('utils.snippets.conds')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local l = require('luasnip.extras').lambda
local dl = require('luasnip.extras').dynamic_lambda

M.math = require('snippets.tex.math')

M.snippets = {
  us.msnr({
    { trig = '^# ', snippetType = 'autosnippet' },
    { trig = '^h1' },
  }, {
    t('# '),
    dl(
      1,
      l.TM_FILENAME
        :gsub('^%d*_', '')
        :gsub('_', ' ')
        :gsub('^%l', string.upper)
        :gsub(' %l', string.upper)
        :gsub('%..*', ''),
      {}
    ),
  }),
  us.snr({ trig = '^h2' }, { t('## '), i(0) }),
  us.snr({ trig = '^h3' }, { t('### '), i(0) }),
  us.snr({ trig = '^h4' }, { t('#### '), i(0) }),
  us.snr({ trig = '^h5' }, { t('##### '), i(0) }),
  us.snr({ trig = '^h6' }, { t('###### '), i(0) }),

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
    d(1, function()
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':e') == 'ipynb'
          and sn(nil, i(1, 'python'))
        or sn(nil, i(1))
    end, {}),
    t({ '', '' }),
    un.body(2, 0),
    t({ '', '```' }),
  }),
  us.sn({
    trig = 'cd',
    desc = 'Inline code',
  }, {
    t('`'),
    un.body(1, 0),
    t('`'),
  }),

  us.sn({ trig = 'theo' }, { t('***'), i(1, 'Theorem'), t('***') }),
  us.sn({ trig = 'def' }, { t('***'), i(1, 'Definition'), t('***') }),
  us.sn({ trig = 'pro' }, { t('***'), i(1, 'Proof'), t('***') }),
  us.sn({ trig = 'lem' }, { t('***'), i(1, 'Lemma'), t('***') }),
}

return M
