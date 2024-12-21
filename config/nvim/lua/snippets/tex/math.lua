local uf = require('utils.snippets.funcs')
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local r = ls.restore_node

return {
  us.samWr({ trig = '(%a)(%d)' }, {
    d(1, function(_, snip)
      local symbol = snip.captures[1]
      local subscript = snip.captures[2]
      return sn(nil, {
        t(symbol),
        t('_'),
        t(subscript),
      })
    end),
  }),
  us.msamWr({
    { trig = '//', priority = 999 },
    { trig = '(%b())//' },
    { trig = '(\\?%w+[_^]?%w?)//' },
    { trig = '(\\?%w+[_^]?%b{})//' },
    { trig = '(\\?%w+%b{}[_^]?%w?)//' },
    { trig = '(\\?%w+%b{}[_^]?%b{})//' },
    { trig = '(\\?%w+[_^]?%w?[_^]?%w?)//' },
    { trig = '(\\?%w+[_^]?%b{}[_^]?%w?)//' },
    { trig = '(\\?%w+[_^]?%w?[_^]?%b{})//' },
    { trig = '(\\?%w+[_^]?%b{}[_^]?%b{})//' },
    { trig = '(\\?%w+%b{}[_^]?%w?[_^]?%w?)//' },
    { trig = '(\\?%w+%b{}[_^]?%b{}[_^]?%w?)//' },
    { trig = '(\\?%w+%b{}[_^]?%w?[_^]?%b{})//' },
    { trig = '(\\?%w+%b{}[_^]?%b{}[_^]?%b{})//' },
  }, {
    d(1, function(_, snip)
      local numerator = snip.captures[1]
      if not numerator then
        return sn(nil, {
          t('\\frac{'),
          i(1),
          t('}{'),
          i(2),
          t('}'),
        })
      end

      -- Remove surrounding brackets
      if #(numerator:match('%b()') or '') == #numerator then
        numerator = numerator:sub(2, -2)
      end
      return sn(nil, {
        t('\\frac{'),
        t(numerator),
        t('}{'),
        i(1),
        t('}'),
      })
    end),
  }),
  -- matrix/vector bold font
  us.samWr({
    trig = ';(%a)',
    priority = 999,
    dscr = 'vector bold math font',
  }, {
    d(1, function(_, snip)
      return sn(nil, {
        t(string.format('\\mathbf{%s}', snip.captures[1])),
      })
    end),
  }),
  -- determinant
  us.sam({ trig = 'det' }, {
    t('\\mathrm{det}\\left('),
    i(1),
    t('\\right)'),
  }),

  us.samW({ trig = '==' }, t('&= ')),
  us.samW({ trig = ':=' }, t('\\coloneqq ')),
  us.samW({ trig = '!=' }, t('\\neq ')),
  us.samW({ trig = '&= =' }, t('\\equiv ')),
  us.samW({ trig = '>=' }, t('\\ge ')),
  us.samW({ trig = '<=' }, t('\\le ')),
  us.samW({ trig = '<->', priority = 999 }, t('\\leftrightarrow ')),
  us.samW({ trig = '\\le >', priority = 999 }, t('\\Leftrightarrow ')),
  us.samW({ trig = '<--', priority = 999 }, t('\\leftarrow ')),
  us.samW({ trig = '\\le =', priority = 999 }, t('\\Leftarrow ')),
  us.samW({ trig = '-->', priority = 999 }, t('\\rightarrow ')),
  us.samW({ trig = '&= >', priority = 999 }, t('\\Rightarrow ')),
  us.samW({ trig = '->', priority = 998 }, t('\\to ')),
  us.samW({ trig = '<-', priority = 998 }, t('\\gets ')),
  us.samW({ trig = '=>', priority = 998 }, t('\\implies ')),
  us.samW({ trig = '|>' }, t('\\mapsto ')),
  us.samW({ trig = '><' }, t('\\bowtie ')),
  us.samW({ trig = '**' }, t('\\cdot ')),
  us.samW({ trig = 'x<->' }, {
    t('\\xleftrightarrow['),
    i(1),
    t(']{'),
    i(2),
    t('} '),
  }),
  us.samW({ trig = 'x\\le >' }, {
    t('\\xLeftrightarrow['),
    i(1),
    t(']{'),
    i(2),
    t('} '),
    i(),
  }),
  us.samW({ trig = 'x<--' }, {
    t('\\xleftarrow['),
    i(1),
    t(']{'),
    i(2),
    t('} '),
  }),
  us.samW({ trig = 'x\\le =' }, {
    t('\\xLeftarrow['),
    i(1),
    t(']{'),
    i(2),
    t('} '),
  }),
  us.samW({ trig = 'x-->' }, {
    t('\\xrightarrow['),
    i(1),
    t(']{'),
    i(2),
    t('} '),
  }),
  us.samW({ trig = 'x&= >' }, {
    t('\\xRightarrow['),
    i(1),
    t(']{'),
    i(2),
    t('} '),
  }),

  us.samW({ trig = '_' }, {
    d(1, function()
      local char_after = uf.get_char_after()
      if char_after == '_' or char_after == '{' then
        return sn(nil, { t('_') })
      else
        return sn(nil, { t('_{'), i(1), t('}') })
      end
    end),
  }),
  us.samW({ trig = '^' }, {
    d(1, function()
      local char_after = uf.get_char_after()
      if char_after == '^' or char_after == '{' then
        return sn(nil, { t('^') })
      else
        return sn(nil, { t('^{'), i(1), t('}') })
      end
    end),
  }),
  us.msamW({ { trig = '>>' }, { trig = 'gg' } }, t('\\gg ')),
  us.msamW({ { trig = '<<' }, { trig = 'll' } }, t('\\ll ')),
  us.msamW({ { trig = '...' }, { trig = 'ldots' } }, t('\\ldots')),
  us.msamW({ { trig = '\\ldots.' }, { trig = 'cdots' } }, t('\\cdots')),
  us.msamW({ { trig = '\\..' }, { trig = 'ddots' } }, t('\\ddots')),
  us.msamW({ { trig = ':..' }, { trig = 'vdots' } }, t('\\vdots')),
  us.msamW({ { trig = '~~' }, { trig = 'sim' } }, t('\\sim ')),
  us.msamW({ { trig = '~=' }, { trig = 'approx' } }, t('\\approx ')),
  us.samW({ trig = '+-' }, t('\\pm ')),
  us.samW({ trig = '-+' }, t('\\mp ')),
  us.samWr({ trig = '%s*||' }, t(' \\mid ')),
  us.samW({ trig = '\\\\\\' }, { t('\\setminus ') }),
  us.samW({ trig = '%%' }, t('\\%')),
  us.samW({ trig = '##' }, t('\\#')),
  us.samW({ trig = ': ' }, t('\\colon ')),
  us.msamW({
    { trig = 'sqrt' },
    { trig = '^{2}rt' },
  }, {
    f(function(_, snip)
      return snip.trigger == '^{2}rt' and ' ' or ''
    end, {}, {}),
    c(1, {
      sn(nil, {
        t('\\sqrt{'),
        r(1, 'expr'),
        t('}'),
      }),
      sn(nil, {
        t('\\sqrt['),
        i(2, '3'),
        t(']{'),
        r(1, 'expr'),
        t('}'),
      }),
    }),
  }),

  us.samW({ trig = 'abs' }, { t('\\left\\vert '), i(1), t(' \\right\\vert') }),
  us.samW({ trig = 'lrv' }, { t('\\left\\vert '), i(1), t(' \\right\\vert') }),
  us.samW({ trig = 'lrb' }, { t('\\left('), i(1), t('\\right)') }),
  us.samW({ trig = 'lr)' }, { t('\\left('), i(1), t('\\right)') }),
  us.samW({ trig = 'lr]' }, { t('\\left['), i(1), t('\\right]') }),
  us.samW({ trig = 'lrB' }, { t('\\left{'), i(1), t('\\right}') }),
  us.samW({ trig = 'lr}' }, { t('\\left{'), i(1), t('\\right}') }),
  us.samW({ trig = 'lr>' }, { t('\\left<'), i(1), t('\\right>') }),
  us.samW(
    { trig = 'nor' },
    { t('\\left\\lVert '), i(1), t(' \\right\\rVert') }
  ),

  us.sambW({ trig = 'ks' }, t('^{*}')),
  us.sambW({ trig = 'sq' }, t('^{2}')),
  us.sambW({ trig = 'cb' }, t('^{3}')),
  us.sambW({ trig = 'cm' }, t('^{C}')),
  us.sambW({ trig = 'inv' }, t('^{-1}')),
  us.sambW({ trig = '\\in v' }, t('^{-1}')),
  us.msambW({
    { trig = 'tr' },
    { trig = '.T' },
  }, t('^{\\intercal}')),

  us.samWr({ trig = '(\\?%w*_*%w*)vv' }, un.sdn(1, '\\vec{', '}')),
  us.samWr({ trig = '(\\?%w*_*%w*)hat' }, un.sdn(1, '\\hat{', '}')),
  us.samWr({ trig = '(\\?%w*_*%w*)bar' }, un.sdn(1, '\\bar{', '}')),
  us.samWr({ trig = '(\\?%w*_*%w*)td' }, un.sdn(1, '\\tilde{', '}')),
  us.samWr(
    { trig = '(\\?%w*_*%w*)dot', priority = 999 },
    un.sdn(1, '\\dot{', '}')
  ),
  us.samWr({ trig = '(\\?%w*_*%w*)ddot' }, un.sdn(1, '\\ddot{', '}')),
  us.samWr({ trig = '(\\?%w*_*%w*)\\mathrm{d}ot' }, un.sdn(1, '\\ddot{', '}')),
  us.samWr({ trig = '(\\?%w*_*%w*)ovl' }, un.sdn(1, '\\overline{', '}')),
  us.samWr({ trig = '(\\?%w*_*%w*)ovs' }, {
    d(1, function(_, snip)
      local text = snip.captures[1]
      if text == nil or not text:match('%S') then
        return sn(nil, {
          t('\\overset{'),
          i(2),
          t('}{'),
          i(1),
          t('}'),
        })
      end
      return sn(nil, {
        t('\\overset{'),
        i(1),
        t('}{'),
        t(text),
        t('}'),
      })
    end),
  }),

  -- matrix/vector
  us.sam(
    { trig = 'rv', dscr = 'row vector', priority = 999 },
    un.fmtad(
      '\\begin{bmatrix} <el><_>{0<mod>} & <el><_>{1<mod>} & \\ldots & <el><_>{<end_idx><mod>} \\end{bmatrix}',
      {
        _ = i(3, '_'),
        el = i(1, 'a'),
        end_idx = i(2, 'N-1'),
        mod = i(4),
      }
    )
  ),
  us.sam(
    { trig = 'cv', dscr = 'column vector' },
    un.fmtad(
      '\\begin{bmatrix} <el><_>{0<mod>} \\\\ <el><_>{1,<mod>} \\\\ \\vdots \\\\ <el><_>{<end_idx><mod>} \\end{bmatrix}',
      {
        _ = i(3, '_'),
        el = i(1, 'a'),
        end_idx = i(2, 'N-1'),
        mod = i(4),
      }
    )
  ),
  us.sam(
    { trig = 'mt', dscr = 'matrix' },
    un.fmtad(
      [[
        \begin{bmatrix}
        <idnt><el><_>{<row0><comma><col0>} & <el><_>{<row0><comma><col1>} & \ldots & <el><_>{<row0><comma><width>} \\
        <idnt><el><_>{<row1><comma><col0>} & <el><_>{<row1><comma><col1>} & \ldots & <el><_>{<row1><comma><width>} \\
        <idnt>\vdots & \vdots & \ddots & \vdots \\
        <idnt><el><_>{<height><comma>0} & <el><_>{<height><comma>1} & \ldots & <el><_>{<height><comma><width>} \\
        \end{bmatrix}
      ]],
      {
        idnt = un.idnt(1),
        el = i(1, 'a'),
        _ = i(8, '_'),
        height = i(2, 'N-1'),
        width = i(3, 'M-1'),
        row0 = i(4, '0'),
        col0 = i(5, '0'),
        row1 = i(6, '1'),
        col1 = i(7, '1'),
        comma = i(9, ','),
      }
    )
  ),
  us.msam({
    { trig = 'prop' },
    { trig = 'oc' },
  }, t('\\propto ')),
  us.sam({ trig = 'deg' }, t('\\degree')),
  us.sam({ trig = 'ang' }, t('\\angle ')),
  us.sam({ trig = 'mcal' }, { t('\\mathcal{'), i(1), t('}') }),
  us.sam({ trig = 'msrc' }, { t('\\mathsrc{'), i(1), t('}') }),
  us.sam({ trig = 'mbb' }, { t('\\mathbb{'), i(1), t('}') }),
  us.sam({ trig = 'mbf' }, { t('\\mathbf{'), i(1), t('}') }),
  us.sam({ trig = 'mff' }, { t('\\mff{'), i(1), t('}') }),
  us.sam({ trig = 'mrm' }, { t('\\mathrm{'), i(1), t('}') }),
  us.sam({ trig = 'mit' }, { t('\\mathit{'), i(1), t('}') }),
  us.sam({ trig = 'xx' }, t('\\times ')),
  us.sam({ trig = 'o*' }, t('\\circledast ')),
  us.sam({ trig = 'dd' }, t('\\mathrm{d}')),
  us.sam({ trig = 'pp' }, t('\\partial ')),
  us.msam({ { trig = 'oo' }, { trig = '\\in f' } }, t('\\infty')),

  us.sam({ trig = 'AA' }, t('\\mathbb{A}')),
  us.sam({ trig = 'BB' }, t('\\mathbb{B}')),
  us.sam({ trig = 'CC' }, t('\\mathbb{C}')),
  us.sam({ trig = 'DD' }, t('\\mathbb{D}')),
  us.sam({ trig = 'EE' }, t('\\mathbb{E}')),
  us.sam({ trig = 'FF' }, t('\\mathbb{F}')),
  us.sam({ trig = 'GG' }, t('\\mathbb{G}')),
  us.sam({ trig = 'HH' }, t('\\mathbb{H}')),
  us.sam({ trig = 'II' }, t('\\mathbb{I}')),
  us.sam({ trig = 'JJ' }, t('\\mathbb{J}')),
  us.sam({ trig = 'KK' }, t('\\mathbb{K}')),
  us.sam({ trig = 'LL' }, t('\\mathbb{L}')),
  us.sam({ trig = 'MM' }, t('\\mathbb{M}')),
  us.sam({ trig = 'NN' }, t('\\mathbb{N}')),
  us.sam({ trig = 'OO' }, t('\\mathbb{O}')),
  us.sam({ trig = 'PP' }, t('\\mathbb{P}')),
  us.sam({ trig = 'QQ' }, t('\\mathbb{Q}')),
  us.sam({ trig = 'RR' }, t('\\mathbb{R}')),
  us.sam({ trig = 'SS' }, t('\\mathbb{S}')),
  us.sam({ trig = 'TT' }, t('\\mathbb{T}')),
  us.sam({ trig = 'UU' }, t('\\mathbb{U}')),
  us.sam({ trig = 'VV' }, t('\\mathbb{V}')),
  us.sam({ trig = 'WW' }, t('\\mathbb{W}')),
  us.sam({ trig = 'XX' }, t('\\mathbb{X}')),
  us.sam({ trig = 'YY' }, t('\\mathbb{Y}')),
  us.sam({ trig = 'ZZ' }, t('\\mathbb{Z}')),

  us.sam({ trig = 'set' }, { t('\\{'), i(1), t('\\}') }),
  us.sam({ trig = 'void' }, t('\\emptyset')),
  us.sam({ trig = 'emptyset' }, t('\\emptyset')),
  us.sam({ trig = 'tt' }, { t('\\text{'), i(1), t('}') }),
  us.sam({ trig = 'cc' }, t('\\subset ')),
  us.sam({ trig = ']c' }, t('\\sqsubset ')),
  us.samr({ trig = '\\subset%s*=' }, t('\\subseteq ')),
  us.samr({ trig = '\\subset%s*eq' }, t('\\subseteq ')),
  us.samr({ trig = '\\sqsubset%s*=' }, t('\\sqsubseteq ')),
  us.samr({ trig = '\\sqsubset%s*eq' }, t('\\sqsubseteq ')),
  us.sam({ trig = 'c=' }, t('\\subseteq ')),
  us.sam({ trig = 'notin' }, t('\\notin ')),
  us.sam({ trig = 'in', priority = 999 }, t('\\in ')),
  us.sam({ trig = 'uu' }, t('\\cup ')),
  us.sam({ trig = 'nn' }, t('\\cap ')),
  us.sam({ trig = 'land' }, t('\\land ')),
  us.sam({ trig = 'lor' }, t('\\lor ')),
  us.sam({ trig = 'neg' }, t('\\neg ')),
  us.sam({ trig = 'bigv' }, t('\\big\\rvert_{'), i(1), t('}')),
  us.sam({ trig = 'forall' }, t('\\forall ')),
  us.sam({ trig = 'any' }, t('\\forall ')),
  us.sam({ trig = 'exists' }, t('\\exists ')),

  us.sam({ trig = 'log' }, {
    t('\\mathrm{log}_{'),
    i(1, '10'),
    t('}\\left('),
    i(2),
    t('\\right)'),
  }),
  us.sam({ trig = 'lg', priority = 999 }, {
    t('\\mathrm{lg}'),
    t('\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'ln', priority = 999 }, {
    t('\\mathrm{ln}'),
    t('\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'argmin' }, {
    t('\\mathrm{argmin}_{'),
    i(1),
    t('}'),
  }),
  us.sam({ trig = 'argmax' }, {
    t('\\mathrm{argamx}_{'),
    i(1),
    t('}'),
  }),
  us.sam(
    { trig = 'min', priority = 999 },
    c(1, {
      sn(nil, {
        t('\\mathrm{min}'),
        t('\\left('),
        r(1, 'expr'),
        t('\\right)'),
      }),
      sn(nil, {
        t('\\mathrm{min}_{'),
        i(2),
        t('}'),
        t('\\left('),
        r(1, 'expr'),
        t('\\right)'),
      }),
    })
  ),
  us.sam(
    { trig = 'max', priority = 999 },
    c(1, {
      sn(nil, {
        t('\\mathrm{max}'),
        t('\\left('),
        r(1, 'expr'),
        t('\\right)'),
      }),
      sn(nil, {
        t('\\mathrm{max}_{'),
        i(2),
        t('}'),
        t('\\left('),
        r(1, 'expr'),
        t('\\right)'),
      }),
    })
  ),

  us.sam({ trig = 'sin', priority = 999 }, {
    t('\\mathrm{sin}\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'cos', priority = 999 }, {
    t('\\mathrm{cos}\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'tan', priority = 999 }, {
    t('\\mathrm{tan}\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'asin' }, {
    t('\\mathrm{arcsin}\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'acos' }, {
    t('\\mathrm{arccos}\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'atan' }, {
    t('\\mathrm{arctan}\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'sc' }, {
    t('\\mathrm{sinc}\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'exp' }, {
    t('\\mathrm{exp}\\left('),
    i(1),
    t('\\right)'),
  }),

  us.sam({ trig = 'flr' }, {
    t('\\left\\lfloor '),
    i(1),
    t(' \\right\\rfloor'),
  }),
  us.sam({ trig = 'clg' }, {
    t('\\left\\lceil '),
    i(1),
    t(' \\right\\rceil'),
  }),
  us.sam({ trig = 'bmat' }, {
    t('\\begin{bmatrix} '),
    i(1),
    t(' \\end{bmatrix}'),
  }),
  us.sam({ trig = 'pmat' }, {
    t('\\begin{pmatrix} '),
    i(1),
    t(' \\end{pmatrix}'),
  }),
  us.sam({ trig = 'Bmat' }, {
    t({ '\\begin{bmatrix}', '' }),
    un.idnt(1),
    i(1),
    t({ '', '\\end{bmatrix}' }),
  }),
  us.sam({ trig = 'Pmat' }, {
    t({ '\\begin{pmatrix}', '' }),
    un.idnt(1),
    i(1),
    t({ '', '\\end{pmatrix}' }),
  }),
  -- Cannot use choose node + restore node with jump index 0 here because of a
  -- weird limitation of LuaSnip, see
  -- https://github.com/L3MON4D3/LuaSnip/issues/1093
  us.sam(
    { trig = 'aln' },
    un.fmtad(
      [[
        \begin{<env>}
        <text>
        \end{<env>}
      ]],
      {
        env = c(1, {
          i(nil, 'align'),
          i(nil, 'align*'),
        }),
        text = un.body(2, 1),
      }
    )
  ),
  us.sam(
    { trig = 'eqt' },
    un.fmtad(
      [[
        \begin{<env>}
        <text>
        \end{<env>}
      ]],
      {
        env = c(1, {
          i(nil, 'equation'),
          i(nil, 'equation*'),
        }),
        text = un.body(2, 1),
      }
    )
  ),
  us.sam({ trig = 'cas' }, {
    t({ '\\begin{cases}', '' }),
    un.body(1, 1),
    t({ '', '\\end{cases}' }),
  }),
  us.sam({ trig = 'par' }, {
    t('\\frac{\\partial '),
    i(1),
    t('}{\\partial '),
    i(2),
    t('}'),
  }),
  us.sam({ trig = 'dif' }, {
    t('\\frac{\\mathrm{d}'),
    i(1),
    t('}{\\mathrm{d}'),
    i(2),
    t('} '),
  }),
  us.sam({
    trig = '\\in t',
    priority = 998,
  }, {
    t('\\int_{'),
    i(1),
    t('}^{'),
    i(2),
    t('} '),
  }),
  us.sam({
    trig = 'iint',
    priority = 999,
  }, {
    t('\\iint_{'),
    i(1),
    t('}^{'),
    i(2),
    t('} '),
  }),
  us.sam({
    trig = 'iiint',
  }, {
    t('\\iiint_{'),
    i(1),
    t('}^{'),
    i(2),
    t('} '),
  }),
  us.sam({ trig = 'prod' }, {
    c(1, {
      sn(nil, {
        t('\\prod \\limits_{'),
        i(1, 'n=0'),
        t('}^{'),
        i(2, 'N-1'),
        t('} '),
      }),
      sn(nil, {
        t('\\prod \\limits_{'),
        i(1, 'x'),
        t('} '),
      }),
    }),
  }),
  us.sam({ trig = 'sum' }, {
    c(1, {
      sn(nil, {
        t('\\sum \\limits_{'),
        i(1, 'n=0'),
        t('}^{'),
        i(2, 'N-1'),
        t('} '),
      }),
      sn(nil, {
        t('\\sum \\limits_{'),
        i(1, 'x'),
        t('} '),
      }),
    }),
  }),
  us.sam({ trig = 'lim' }, {
    t('\\lim_{'),
    i(1, 'n'),
    t('\\to '),
    i(2, '\\infty'),
    t('} '),
  }),
  us.sam(
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

  us.sam({ trig = 'nabla' }, t('\\nabla')),
  us.sam({ trig = 'alpha' }, t('\\alpha')),
  us.sam({ trig = 'beta' }, t('\\beta')),
  us.sam({ trig = 'gamma' }, t('\\gamma')),
  us.sam({ trig = 'delta' }, t('\\delta')),
  us.sam({ trig = 'zeta' }, t('\\zeta')),
  us.sam({ trig = 'mu' }, t('\\mu')),
  us.sam({ trig = 'rho' }, t('\\rho')),
  us.sam({ trig = 'sigma' }, t('\\sigma')),
  us.sam({ trig = 'eta', priority = 998 }, t('\\eta')),
  us.sam({ trig = 'eps', priority = 999 }, t('\\epsilon')),
  us.sam({ trig = 'veps' }, t('\\varepsilon')),
  us.sam({ trig = 'theta', priority = 999 }, t('\\theta')),
  us.sam({ trig = 'vtheta' }, t('\\vartheta')),
  us.sam({ trig = 'iota' }, t('\\iota')),
  us.sam({ trig = 'kappa' }, t('\\kappa')),
  us.sam({ trig = 'lambda' }, t('\\lambda')),
  us.sam({ trig = 'nu' }, t('\\nu')),
  us.sam({ trig = 'pi' }, t('\\pi')),
  us.sam({ trig = 'tau' }, t('\\tau')),
  us.sam({ trig = 'ups' }, t('\\upsilon')),
  us.sam({ trig = 'phi' }, t('\\phi')),
  us.sam({ trig = 'vphi' }, t('\\varphi')),
  us.sam({ trig = 'psi' }, t('\\psi')),
  us.sam({ trig = 'omg' }, t('\\omega')),

  us.sam({ trig = 'Alpha' }, t('\\Alpha')),
  us.sam({ trig = 'Beta' }, t('\\Beta')),
  us.sam({ trig = 'Gamma' }, t('\\Gamma')),
  us.sam({ trig = 'Delta' }, t('\\Delta')),
  us.sam({ trig = 'Zeta' }, t('\\Zeta')),
  us.sam({ trig = 'Mu' }, t('\\Mu')),
  us.sam({ trig = 'Rho' }, t('\\Rho')),
  us.sam({ trig = 'Sigma' }, t('\\Sigma')),
  us.sam({ trig = 'Eta' }, t('\\Eta')),
  us.sam({ trig = 'Eps' }, t('\\Epsilon')),
  us.sam({ trig = 'Theta' }, t('\\Theta')),
  us.sam({ trig = 'Iota' }, t('\\Iota')),
  us.sam({ trig = 'Kappa' }, t('\\Kappa')),
  us.sam({ trig = 'Lambda' }, t('\\Lambda')),
  us.sam({ trig = 'Nu' }, t('\\Nu')),
  us.sam({ trig = 'Pi' }, t('\\Pi')),
  us.sam({ trig = 'Tau' }, t('\\Tau')),
  us.sam({ trig = 'Ups' }, t('\\Upsilon')),
  us.sam({ trig = 'Phi' }, t('\\Phi')),
  us.sam({ trig = 'Psi' }, t('\\Psi')),
  us.sam({ trig = 'Omg' }, t('\\Omega')),

  -- special functions and other notations
  us.sam({ trig = 'Cov' }, {
    t('\\mathrm{Cov}\\left('),
    i(1, 'X'),
    t(','),
    i(2, 'Y'),
    t('\\right)'),
  }),
  us.sam({ trig = 'Var' }, {
    t('\\mathrm{Var}\\left('),
    i(1, 'X'),
    t('\\right)'),
  }),
  us.sam({ trig = 'MSE' }, { t('\\mathrm{MSE}') }),
  us.sam(
    {
      trig = 'bys',
      dscr = 'Bayes Formula',
    },
    un.fmtad(
      '\\frac{P(<cond_x> \\mid <cond_y>) P(<cond_y>)}{P(<cond_y>)}',
      { cond_x = i(2, 'X=x'), cond_y = i(1, 'Y=y') }
    )
  ),
  us.sam(
    {
      trig = 'nord',
      dscr = 'Normal Distribution',
    },
    un.fmtad(
      '\\mathcal{N} \\left(<mean>, <var>\\right)',
      { mean = i(1, '\\mu'), var = i(2, '\\sigma^2') }
    )
  ),

  -- Math env
  -- Press double '$' -> $|$ -> press '$' again -> multi-line math env
  -- Also support visual snippet:
  -- -> select text
  -- -> press snippet trigger (`<Tab>`)
  -- -> press double '$'
  -- -> inline or multi-line math env with selected text as content
  us.sa({
    trig = '$',
    condition = function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if line:sub(col + 1, col + 1) == '$' then
        vim.api.nvim_set_current_line(line:sub(1, -2))
        return true
      end
      return false
    end,
  }, {
    t({ '$', '' }),
    un.idnt(1),
    i(0),
    t({ '', '$$' }),
  }),

  us.sa(
    { trig = '$$', priority = 999 },
    d(1, function(_, snip)
      local sel_dedent = snip.env.LS_SELECT_DEDENT
      local sel_raw = snip.env.LS_SELECT_RAW

      if #sel_raw == 0 or #sel_raw == 1 and sel_raw[1]:match('^%S') then
        return sn(nil, { t('$'), i(1, sel_raw), t('$') })
      end

      for idx = 2, #sel_dedent do
        if sel_dedent[idx]:match('%S') then
          sel_dedent[idx] = uf.get_indent_str(1) .. sel_dedent[idx]
        end
      end
      return sn(nil, {
        t({ '$$', '' }),
        un.idnt(1),
        i(i, sel_dedent),
        t({ '', '$$' }),
      })
    end)
  ),
}
