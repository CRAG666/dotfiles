local M = {}
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node

M.math = require('snippets.tex.math')

M.snippets = {
  us.sM(
    { trig = 'env' },
    un.fmtad(
      [[
        \begin{<env>}
        <text>
        \end{<env>}
      ]],
      {
        env = i(1),
        text = un.body(2, 1),
      }
    )
  ),
  us.sM({ trig = 'cs' }, {
    t({
      '\\begin{equation}',
      '\\begin{cases}',
      '',
    }),
    un.body(1, 1),
    t({
      '',
      '\\end{cases}',
      '\\end{equation}',
    }),
  }),
  us.sM(
    { trig = 'aln' },
    un.fmtad(
      [[
        \begin{<env>}
        <text>
        \end{<env>}
      ]],
      {
        env = c(1, {
          i(nil, 'align*'),
          i(nil, 'align'),
        }),
        text = un.body(2, 1),
      }
    )
  ),
  us.sM(
    { trig = 'eqt' },
    un.fmtad(
      [[
        \begin{<env>}
        <text>
        \end{<env>}
      ]],
      {
        env = c(1, {
          i(nil, 'equation*'),
          i(nil, 'equation'),
        }),
        text = un.body(2, 1),
      }
    )
  ),
  us.sM(
    { trig = 'img' },
    un.fmtad(
      [[
        \begin{figure}[<placement>]
        <idnt>\centering
        <idnt>\includegraphics[<size>]{<img_path>}
        <idnt>\caption{<caption>}
        \end{figure}
      ]],
      {
        placement = i(1, 'H'),
        size = i(2, 'width=1.0\\textwidth'),
        img_path = i(3, 'img/img.png'),
        caption = i(4),
        idnt = un.idnt(1),
      }
    )
  ),
  us.sM({ trig = 'em' }, { t('\\emph{'), i(1), t('}') }),
  us.sM({ trig = 'bf' }, { t('\\textbf{'), i(1), t('}') }),
  us.sM({ trig = 'ul' }, { t('\\underline{'), i(1), t('}') }),
  us.sM(
    {
      trig = '^(%s*)- ',
      regTrig = true,
      hidden = true,
      snippetType = 'autosnippet',
    },
    f(function(_, snip, _)
      return snip.captures[1] .. '\\item'
    end)
  ),
  us.sM(
    {
      trig = '\\item(%w)',
      regTrig = true,
      hidden = true,
      snippetType = 'autosnippet',
    },
    d(1, function(_, snip)
      return sn(nil, {
        t('\\item{' .. snip.captures[1]),
        i(1),
        t('}'),
      })
    end)
  ),
}

return M
