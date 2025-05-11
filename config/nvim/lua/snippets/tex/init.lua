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
local r = ls.restore_node

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
    c(1, {
      un.fmtad(
        [[
          \begin{figure}[<placement>]
          <idnt>\centering
          <idnt>\includegraphics[<size>]{<img_path>}
          \end{figure}
        ]],
        {
          placement = r(1, 'placement'),
          size = r(2, 'size'),
          img_path = r(3, 'img_path'),
          idnt = un.idnt(1),
        }
      ),
      un.fmtad(
        [[
          \begin{figure}[<placement>]
          <idnt>\centering
          <idnt>\includegraphics[<size>]{<img_path>}
          <idnt>\caption{<caption>}
          \end{figure}
        ]],
        {
          placement = r(1, 'placement'),
          size = r(2, 'size'),
          img_path = r(3, 'img_path'),
          caption = i(4),
          idnt = un.idnt(1),
        }
      ),
    }),
    {
      stored = {
        placement = i(nil, 'H'),
        size = i(nil, 'width=1.0\\textwidth'),
        img_path = i(nil, 'img/img.png'),
      },
    }
  ),
  us.sM({ trig = 'em' }, { t('\\emph{'), i(1), t('}') }),
  us.sM({ trig = 'bf' }, { t('\\textbf{'), i(1), t('}') }),
  us.sM({ trig = 'ul' }, { t('\\underline{'), i(1), t('}') }),
  us.sM({ trig = 'tt' }, { t('\\texttt{'), i(1), t('}') }),
}

return M
