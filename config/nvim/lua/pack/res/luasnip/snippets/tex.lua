local M = {}
local uf = require('utils.snip.funcs')
local un = require('utils.snip.nodes')
local us = require('utils.snip.snips')
local ls = require('luasnip')
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local r = ls.restore_node
local sn = ls.snippet_node
local d = ls.dynamic_node
local f = ls.function_node

M.math = {
  us.samWr({ trig = '([%a%}])(%d)' }, {
    f(function(_, parent)
      return string.format(
        '%s_%s',
        parent.snippet.captures[1],
        parent.snippet.captures[2]
      )
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
  -- determinant
  us.sam({ trig = 'det' }, {
    t('\\det\\left('),
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
  -- We are not using '\gets -' here as trigger to avoid confuse with negative
  -- values following the '\gets' command
  us.samW({ trig = '\\gets --', priority = 999 }, t('\\leftarrow ')),
  us.samW({ trig = '<==', priority = 999 }, t('\\Leftarrow ')),
  us.samW({ trig = '\\le =', priority = 999 }, t('\\Leftarrow ')),
  us.samW({ trig = '-->', priority = 999 }, t('\\rightarrow ')),
  us.samW({ trig = '==>', priority = 999 }, t('\\Rightarrow ')),
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
  us.samW({ trig = '>>' }, t('\\gg ')),
  us.samW({ trig = '<<' }, t('\\ll ')),
  us.samW({ trig = '...' }, t('\\ldots')),
  us.samW({ trig = '....' }, t('\\cdots')),
  us.samW({ trig = '\\ldots.' }, t('\\cdots')),
  us.samW({ trig = '\\..' }, t('\\ddots')),
  us.samW({ trig = ':..' }, t('\\vdots')),
  us.samW({ trig = '|..' }, t('\\vdots')),
  us.samW({ trig = '~~' }, t('\\sim ')),
  us.samW({ trig = '~=' }, t('\\approx ')),
  us.samW({ trig = '+-' }, t('\\pm ')),
  us.samW({ trig = '-+' }, t('\\mp ')),
  us.samWr({ trig = '%s*||' }, t(' \\mid ')),
  us.samW({ trig = '\\\\\\' }, { t('\\setminus ') }),
  us.samW({ trig = '%%' }, t('\\%')),
  us.samW({ trig = '##' }, t('\\#')),
  us.samW({ trig = '::' }, t('\\colon ')),
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
  us.samW({ trig = 'lr]' }, { t('\\left['), i(1), t('\\right]') }),
  us.samW(
    { trig = 'norm' },
    { t('\\left\\lVert '), i(1), t(' \\right\\rVert') }
  ),
  us.msamW(
    { { trig = 'lr}' }, { trig = 'lrB' } },
    { t('\\left{'), i(1), t('\\right}') }
  ),
  us.msamW(
    { { trig = 'lr)' }, { trig = 'lrb' } },
    { t('\\left('), i(1), t('\\right)') }
  ),
  us.msamW(
    { { trig = 'lr>' }, { trig = 'lra' } },
    { t('\\left<'), i(1), t('\\right>') }
  ),

  us.sambW({ trig = 'ks' }, t('^{*}')),
  us.sambW({ trig = 'sq' }, t('^{2}')),
  us.sambW({ trig = 'cb' }, t('^{3}')),
  us.sambW({ trig = 'cm' }, t('^{C}')),
  us.sambW({ trig = 'inv' }, t('^{-1}')),
  us.sambW({ trig = '\\in v' }, t('^{-1}')),
  us.sambW({ trig = '.T' }, t('^{\\intercal}')),

  -- Math bold symbol with `\bm`
  us.samWr(
    { trig = '(\\?%w*_*%w*),,' },
    d(1, function(_, snip)
      local symbol = snip.captures[1]
      if not symbol or not symbol:match('%S') then
        return sn(1, {
          c(1, { i(1, '\\bm'), i(1, '\\boldsymbol'), i(1, '\\mathbf') }),
          t('{'),
          i(2),
          t('}'),
        })
      end
      return sn(1, { t('\\bm{'), t(symbol), t('}') })
    end)
  ),
  -- Math bold symbol with `\mathbf`
  us.samWr(
    { trig = '(\\?%w*_*%w*);;' },
    d(1, function(_, snip)
      local symbol = snip.captures[1]
      if not symbol or not symbol:match('%S') then
        return sn(1, {
          c(1, { i(1, '\\mathbf'), i(1, '\\boldsymbol'), i(1, '\\bm') }),
          t('{'),
          i(2),
          t('}'),
        })
      end
      return sn(1, {
        -- `\mathbf` does not work for special symbols that starts with `\`,
        -- e.g. Greek letters such as `\alpha`
        vim.startswith(symbol, '\\') and t('\\boldsymbol{') or t('\\mathbf{'),
        t(symbol),
        t('}'),
      })
    end)
  ),
  us.samWr({ trig = '(\\?%w*_*%w*)vv' }, un.sdn(1, '\\vec{', '}')),
  us.samWr({ trig = '(\\?%w*_*%w*)hat' }, un.sdn(1, '\\hat{', '}')),
  us.samWr({ trig = '(\\?%w*_*%w*)bar' }, un.sdn(1, '\\bar{', '}')),
  us.samWr({ trig = '(\\?%w*_*%w*)tld' }, un.sdn(1, '\\tilde{', '}')),
  us.samWr(
    { trig = '(\\?%w*_*%w*)dot', priority = 999 },
    un.sdn(1, '\\dot{', '}')
  ),
  us.samWr({ trig = '(\\?%w*_*%w*)ddot' }, un.sdn(1, '\\ddot{', '}')),
  us.samWr(
    { trig = '(\\?%w*_*%w*)\\operatorname{d}ot' },
    un.sdn(1, '\\ddot{', '}')
  ),
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
    { trig = 'mat', dscr = 'matrix' },
    un.fmtad(
      [[
        \begin{bmatrix}
        <idnt><el00> & <el01> & \ldots & <el0M> \\
        <idnt><el10> & <el11> & \ldots & <el1M> \\
        <idnt>\vdots & \vdots & \ddots & \vdots \\
        <idnt><elN0> & <elN1> & \ldots & <elNM> \\
        \end{bmatrix}
      ]],
      {
        idnt = un.idnt(1),
        el00 = i(1, 'a_{0, 0}'),
        el01 = i(2, 'a_{0, 1}'),
        el0M = i(3, 'a_{0, M-1}'),
        el10 = i(4, 'a_{1, 0}'),
        el11 = i(5, 'a_{1, 1}'),
        el1M = i(6, 'a_{1, M-1}'),
        elN0 = i(7, 'a_{N-1, 0}'),
        elN1 = i(8, 'a_{N-1, 1}'),
        elNM = i(9, 'a_{N-1, M-1}'),
      }
    )
  ),
  us.sam(
    { trig = 'rot', desc = 'Rotation matrix' },
    un.fmtad(
      [[
        \begin{bmatrix}
        <idnt>\cos\left(<angle>\right) x & -\sin\left(<angle>\right) y \\
        <idnt>\sin\left(<angle>\right) x &  \cos\left(<angle>\right) y \\
        \end{bmatrix}
      ]],
      {
        idnt = un.idnt(1),
        angle = i(1, '\\theta'),
      }
    )
  ),
  us.msam({ { trig = 'prop' }, { trig = 'oc' } }, t('\\propto ')),
  us.msam({ { trig = 'cop' }, { trig = 'perp' } }, t('\\perp ')),
  us.sam({ trig = 'deg' }, t('\\degree')),
  us.sam({ trig = 'ang' }, t('\\angle ')),
  us.sam({ trig = 'mcal' }, { t('\\mathcal{'), i(1), t('}') }),
  us.sam({ trig = 'msrc' }, { t('\\mathsrc{'), i(1), t('}') }),
  us.sam({ trig = 'mbb' }, { t('\\mathbb{'), i(1), t('}') }),
  us.sam({ trig = 'mbf' }, { t('\\mathbf{'), i(1), t('}') }),
  us.sam({ trig = 'mff' }, { t('\\mff{'), i(1), t('}') }),
  us.sam({ trig = 'mrm' }, { t('\\mathrm{'), i(1), t('}') }),
  us.sam({ trig = 'mit' }, { t('\\mathit{'), i(1), t('}') }),
  us.sam({ trig = 'op' }, { t('\\operatorname{'), i(1), t('}') }),
  us.sam({ trig = 'xx' }, t('\\times ')),
  us.sam({ trig = 'o*' }, t('\\circledast ')),
  us.sam({ trig = 'o.' }, t('\\odot ')),
  us.sam({ trig = 'ox' }, t('\\otimes ')),
  us.sam({ trig = 'Ox' }, t('\\bigotimes ')),
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

  us.sam({ trig = 'Aa' }, t('\\mathcal{A}')),
  us.sam({ trig = 'Bb' }, t('\\mathcal{B}')),
  us.sam({ trig = 'Cc' }, t('\\mathcal{C}')),
  us.sam({ trig = 'Dd' }, t('\\mathcal{D}')),
  us.sam({ trig = 'Ee' }, t('\\mathcal{E}')),
  us.sam({ trig = 'Ff' }, t('\\mathcal{F}')),
  us.sam({ trig = 'Gg' }, t('\\mathcal{G}')),
  us.sam({ trig = 'Hh' }, t('\\mathcal{H}')),
  us.sam({ trig = 'Ii' }, t('\\mathcal{I}')),
  us.sam({ trig = 'Jj' }, t('\\mathcal{J}')),
  us.sam({ trig = 'Kk' }, t('\\mathcal{K}')),
  us.sam({ trig = 'Ll' }, t('\\mathcal{L}')),
  us.sam({ trig = 'Mm' }, t('\\mathcal{M}')),
  us.sam({ trig = 'Nn' }, t('\\mathcal{N}')),
  us.sam({ trig = 'Oo' }, t('\\mathcal{O}')),
  us.sam({ trig = 'Pp' }, t('\\mathcal{P}')),
  us.sam({ trig = 'Qq' }, t('\\mathcal{Q}')),
  us.sam({ trig = 'Rr' }, t('\\mathcal{R}')),
  us.sam({ trig = 'Ss' }, t('\\mathcal{S}')),
  us.sam({ trig = 'Tt' }, t('\\mathcal{T}')),
  us.sam({ trig = 'Uu' }, t('\\mathcal{U}')),
  us.sam({ trig = 'Vv' }, t('\\mathcal{V}')),
  us.sam({ trig = 'Ww' }, t('\\mathcal{W}')),
  us.sam({ trig = 'Xx' }, t('\\mathcal{X}')),
  us.sam({ trig = 'Yy' }, t('\\mathcal{Y}')),
  us.sam({ trig = 'Zz' }, t('\\mathcal{Z}')),

  us.sam({ trig = 'ell' }, t('\\ell')),

  us.sam({ trig = 'set' }, { t('\\{'), i(1), t('\\}') }),
  us.sam({ trig = 'void' }, t('\\varnothing')),
  us.sam({ trig = 'o/' }, t('\\varnothing')),
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
  us.sam({ trig = '\\neg in' }, t('\\notin ')),
  us.sam({ trig = 'in', priority = 999 }, t('\\in ')),
  us.sam({ trig = 'uu' }, t('\\cup ')),
  us.sam({ trig = 'nn' }, t('\\cap ')),
  us.sam({ trig = 'and' }, t('\\land ')),
  us.sam({ trig = 'or' }, t('\\lor ')),
  us.sam({ trig = 'neg' }, t('\\neg ')),
  us.sam({ trig = 'not' }, t('\\neg ')),
  us.sam({ trig = 'bigv' }, t('\\big\\rvert_{'), i(1), t('}')),
  us.sam({ trig = 'forall' }, t('\\forall ')),
  us.sam({ trig = 'any' }, t('\\forall ')),
  us.sam({ trig = 'exists' }, t('\\exists ')),
  us.msam({ { trig = 'quad' }, { trig = '\\ \\ ' } }, t('\\quad ')),
  us.msam(
    { { trig = 'qquad' }, { trig = '\\ \\ \\ ' }, { trig = '\\quad \\ ' } },
    t('\\qquad ')
  ),

  us.sam(
    { trig = 'log' },
    c(1, {
      sn(1, {
        t('\\log'),
        t('\\left('),
        r(1, 'param'),
        t('\\right)'),
      }),
      sn(1, {
        t('\\log_{'),
        c(1, {
          i(nil, '2'),
          i(nil, '10'),
          i(nil, 'e'),
        }),
        t('}\\left('),
        r(2, 'param'),
        t('\\right)'),
      }),
    }),
    {
      stored = {
        param = i(1),
      },
    }
  ),
  us.sam({ trig = 'lg', priority = 999 }, {
    t('\\lg'),
    t('\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'ln', priority = 999 }, {
    t('\\ln'),
    t('\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'argmin' }, {
    t('\\operatorname{argmin}_{'),
    i(1),
    t('}'),
  }),
  us.sam({ trig = 'argmax' }, {
    t('\\operatorname{argmax}_{'),
    i(1),
    t('}'),
  }),
  us.sam(
    { trig = 'min', priority = 999 },
    c(1, {
      sn(nil, {
        t('\\min'),
        t('\\left('),
        r(1, 'expr'),
        t('\\right)'),
      }),
      sn(nil, {
        t('\\min_{'),
        i(1),
        t('}'),
        t('\\left('),
        r(2, 'expr'),
        t('\\right)'),
      }),
    })
  ),
  us.sam(
    { trig = 'max', priority = 999 },
    c(1, {
      sn(nil, {
        t('\\max'),
        t('\\left('),
        r(1, 'expr'),
        t('\\right)'),
      }),
      sn(nil, {
        t('\\max_{'),
        i(1),
        t('}'),
        t('\\left('),
        r(2, 'expr'),
        t('\\right)'),
      }),
    })
  ),

  us.sam({ trig = 'sin', priority = 999 }, {
    t('\\sin\\left('),
    i(1, '\\theta'),
    t('\\right)'),
  }),
  us.sam({ trig = 'cos', priority = 999 }, {
    t('\\cos\\left('),
    i(1, '\\theta'),
    t('\\right)'),
  }),
  us.sam({ trig = 'tan', priority = 999 }, {
    t('\\tan\\left('),
    i(1, '\\theta'),
    t('\\right)'),
  }),
  us.sam({ trig = 'asin' }, {
    t('\\arcsin\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'acos' }, {
    t('\\arccos\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'atan' }, {
    t('\\arctan\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'sc' }, {
    t('\\operatorname{sinc}\\left('),
    i(1, '\\theta'),
    t('\\right)'),
  }),
  us.sam({ trig = 'exp' }, {
    t('\\exp\\left('),
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
  us.msam({
    { trig = 'bmat' },
    { trig = 'vec' },
  }, {
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
          i(nil, 'align*'),
          i(nil, 'align'),
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
          i(nil, 'equation*'),
          i(nil, 'equation'),
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
  us.sam({ trig = 'grad' }, {
    t('\\nabla_{'),
    i(1, 'x'),
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
        i(1, 'i=1'),
        t('}^{'),
        i(2, 'N'),
        t('} '),
        r(3, 'term'),
      }),
      sn(nil, {
        t('\\prod \\limits_{'),
        i(1, 'x'),
        t('} '),
        r(2, 'term'),
      }),
      sn(nil, {
        t('\\prod '),
        r(1, 'term'),
      }),
    }),
  }, {
    stored = {
      term = i(nil, 'x_i'),
    },
  }),
  us.sam({ trig = 'sum' }, {
    c(1, {
      sn(nil, {
        t('\\sum \\limits_{'),
        i(1, 'i=1'),
        t('}^{'),
        i(2, 'N'),
        t('} '),
        r(3, 'term'),
      }),
      sn(nil, {
        t('\\sum \\limits_{'),
        i(1, 'x'),
        t('} '),
        r(2, 'term'),
      }),
      sn(nil, {
        t('\\sum '),
        r(1, 'term'),
      }),
    }),
  }, {
    stored = {
      term = i(nil, 'x_i'),
    },
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
  us.sam({ trig = 'omega' }, t('\\omega')),

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
  us.sam({ trig = 'Omega' }, t('\\Omega')),

  -- special functions and other notations
  us.sam({ trig = 'sigmoid' }, {
    t('\\operatorname{sigmoid}\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'sign' }, {
    t('\\operatorname{sign}\\left('),
    i(1),
    t('\\right)'),
  }),
  us.sam({ trig = 'cov' }, {
    t('\\operatorname{Cov}\\left('),
    i(1, 'X'),
    t(','),
    i(2, 'Y'),
    t('\\right)'),
  }),
  us.sam({ trig = 'var' }, {
    t('\\operatorname{Var}\\left('),
    i(1, 'X'),
    t('\\right)'),
  }),
  us.sam({ trig = 'ee' }, {
    t('\\operatorname{E}\\left['),
    i(1, 'X'),
    t('\\right]'),
  }),
  -- VC dimension
  us.sam({ trig = 'vc' }, {
    t('\\operatorname{VC}\\left('),
    i(1, '\\mathcal{H}'),
    t('\\right)'),
  }),
  us.sam({ trig = 'mse' }, { t('\\operatorname{MSE}') }),
  us.sam({ trig = 'err' }, { t('\\operatorname{error}') }),
  us.sam(
    {
      trig = 'bys',
      dscr = 'Bayes Formula',
    },
    un.fmtad(
      '\\frac{P(<cond_x> \\mid <cond_y>) P(<cond_y>)}{P(<cond_x>)}',
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
  us.sam({ trig = 'mod' }, { t('\\operatorname{mod} ') }),

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
    i(1),
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
        i(1, sel_dedent),
        t({ '', '$$' }),
      })
    end)
  ),
}

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
  us.sM({ trig = 'bb' }, { t('\\textbf{'), i(1), t('}') }),
  us.sM({ trig = 'ul' }, { t('\\underline{'), i(1), t('}') }),
  us.msM(
    { { trig = 'tt' }, { trig = 'cd' } },
    { t('\\texttt{'), i(1), t('}') }
  ),
}

return M
