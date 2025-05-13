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
  us.sn(
    { trig = 'hti', desc = 'Import a HTML table' },
    un.fmtad(
      [[
        \usepackage{xkeyval}
        \usepackage{etoolbox}
        \usepackage{expl3}
        \usepackage{graphicx}
        \usepackage{xcolor}
        \usepackage{caption}
        \usepackage[cssfile=<style>.sty]{<package>}
      ]],
      {
        style = i(1, "table"),
        package = i(2, "/home/think-crag/Documentos/Proyectos/Writings/utils/latex/htmltabs"),
      }
    )
  ),
  us.sn(
    { trig = 'htt', desc = 'Create a HTML table' },
    un.fmtad(
      [[
        \begin{table}
          \centering
          \caption{<caption>}
          \label{tab:<label>}
          \begin{htmltab}[class=<class>, width=\textwidth]
            \begin{colgroup}
              \HTcol[width=50\%]
              \HTcol[width=50\%]
            \end{colgroup}
            \begin{thead}
              \HTtr{
                \HTtd{header1}
                \HTtd{header2}
              }
            \end{thead}
            \begin{tbody}
              \HTtr{
                \HTtd{colunm1}
                \HTtd{column2}
              }
            \end{tbody}
          \end{htmltab}
        \end{table}
      ]],
      {
        caption = i(1, "caption"),
        label = i(2, "label"),
        class = i(3, "Default"),
      }
    )
  ),
  us.sn(
    { trig = 'htc', desc = 'Create a HTML table with cencer' },
    un.fmtad(
      [[
        \begin{center}
          \captionof{table}{<caption>}
          \label{tab:<label>}
          \vspace{3mm}
          \begin{htmltab}[class=<class>, width=\textwidth]
            \begin{colgroup}
              \HTcol[width=50\%]
              \HTcol[width=50\%]
            \end{colgroup}
            \begin{thead}
              \HTtr{
                \HTtd{header1}
                \HTtd{header2}
              }
            \end{thead}
            \begin{tbody}
              \HTtr{
                \HTtd{colunm1}
                \HTtd{column2}
              }
            \end{tbody}
          \end{htmltab}
        \end{center}
      ]],
      {
        caption = i(1, "caption"),
        label = i(2, "label"),
        class = i(3, "Default"),
      }
    )
  ),
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
    { trig = 'fig' },
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
