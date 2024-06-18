local M = {}
local un = require "snippets.utils.nodes"
local uf = require "snippets.utils.funcs"
local us = require "snippets.utils.snips"
local ls = require "luasnip"
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

M.syntax = {
  us.msn({
    { trig = "lv" },
    { trig = "lc" },
    { trig = "l=" },
  }, {
    t "local ",
    i(1, "var"),
    t " = ",
    i(0, "value"),
  }),
  us.msn({
    { trig = "lf" },
    { trig = "lfn" },
    { trig = "lfun" },
    { trig = "lfunc" },
    { trig = "lfunction" },
  }, {
    t "local function ",
    i(1, "func"),
    t "(",
    i(2),
    t { ")", "" },
    un.body(3, 1),
    t { "", "end" },
  }),
  us.msn({
    { trig = "fn" },
    { trig = "fun" },
    { trig = "func" },
    { trig = "function" },
  }, {
    c(1, {
      sn(nil, {
        t "function(",
        r(1, "params"),
        t { ")", "" },
      }),
      sn(nil, {
        t "function ",
        i(1, "fn_name"),
        t "(",
        r(2, "params"),
        t { ")", "" },
      }),
    }),
    un.body(2, 1),
    t { "", "end" },
  }),
  us.msn({
    { trig = "me" },
    { trig = "method" },
  }, {
    t "function ",
    i(1, "class"),
    t ":",
    i(2, "method"),
    t "(",
    i(3),
    t { ")", "" },
    un.body(4, 1),
    t { "", "end" },
  }),
  us.sn({ trig = "if" }, {
    t "if ",
    i(1, "condition"),
    t { " then", "" },
    un.body(2, 1),
    t { "", "end" },
  }),
  us.msn({
    { trig = "ife" },
    { trig = "ifel" },
    { trig = "ifelse" },
  }, {
    t "if ",
    i(1, "condition"),
    t { " then", "" },
    un.body(2, 1),
    t { "", "else", "" },
    un.idnt(1),
    i(0),
    t { "", "end" },
  }),
  us.msn({
    { trig = "ifelif" },
    { trig = "ifelseif" },
  }, {
    t "if ",
    i(1, "condition_1"),
    t { " then", "" },
    un.body(2, 1),
    t { "", "elseif " },
    i(3, "condition_2"),
    t { "", "" },
    un.idnt(1),
    i(0),
    t { "", "end" },
  }),
  us.snr({ trig = "^(%s*)elif" }, {
    un.idnt(function(_, parent)
      return uf.get_indent_depth(parent.captures[1]) - 1
    end),
    t { "elseif " },
    i(1, "condition"),
    t { " then", "" },
    un.body(2, function(_, parent)
      return uf.get_indent_depth(parent.snippet.captures[1])
    end, false),
  }),
  us.sn({ trig = "elseif" }, {
    t "elseif ",
    i(1, "condition"),
    t { " then", "" },
    un.body(2, 1),
  }),
  us.sn({ trig = "for" }, {
    t "for ",
    c(1, {
      sn(nil, {
        i(1, "_"),
        t ", ",
        i(2, "v"),
        t " in ipairs(",
        i(3, "tbl"),
        t ")",
      }),
      sn(nil, {
        i(1, "k"),
        t ", ",
        i(2, "v"),
        t " in pairs(",
        i(3, "tbl"),
        t ")",
      }),
      sn(nil, {
        i(1, "elements"),
        t " in ",
        i(2, "iterable"),
      }),
      sn(nil, {
        t "i",
        t " = ",
        i(1, "start"),
        t ", ",
        i(2, "stop"),
        t ", ",
        i(3, "step"),
      }),
      sn(nil, {
        t "i",
        t " = ",
        i(1, "start"),
        t ", ",
        i(2, "stop"),
      }),
    }),
    t { " do", "" },
    un.body(2, 1),
    t { "", "end" },
  }),
  us.msn({
    { trig = "fr" },
    { trig = "frange" },
    { trig = "forr" },
    { trig = "forange" },
    { trig = "forrange" },
  }, {
    t "for ",
    c(1, {
      sn(nil, {
        i(1, "i"),
        t " = ",
        i(2, "start"),
        t ", ",
        i(3, "stop"),
      }),
      sn(nil, {
        i(1, "i"),
        t " = ",
        i(2, "start"),
        t ", ",
        i(3, "stop"),
        t ", ",
        i(4, "step"),
      }),
    }),
    t { " do", "" },
    un.body(2, 1),
    t { "", "end" },
  }),
  us.msn({
    { trig = "fp" },
    { trig = "fps" },
    { trig = "fpairs" },
    { trig = "forp" },
    { trig = "forps" },
    { trig = "forpairs" },
  }, {
    t "for ",
    i(1, "_"),
    t ", ",
    i(2, "v"),
    t " in pairs(",
    i(3, "tbl"),
    t { ") do", "" },
    un.body(4, 1),
    t { "", "end" },
  }),
  us.msn({
    { trig = "fip" },
    { trig = "fips" },
    { trig = "fipairs" },
    { trig = "forip" },
    { trig = "forips" },
    { trig = "foripairs" },
  }, {
    t "for ",
    i(1, "_"),
    t ", ",
    i(2, "v"),
    t " in ipairs(",
    i(3, "tbl"),
    t { ") do", "" },
    un.body(4, 1),
    t { "", "end" },
  }),
  us.msn({
    { trig = "wh" },
    { trig = "while" },
  }, {
    t "while ",
    i(1, "condition"),
    t { " do", "" },
    un.body(2, 1),
    t { "", "end" },
  }),
  us.sn({ trig = "do" }, {
    t { "do", "" },
    un.body(1, 1),
    t { "", "end" },
  }),
  us.msn({
    { trig = "rt" },
    { trig = "ret" },
  }, {
    t "return ",
  }),
  us.msn({
    { trig = "p" },
  }, {
    t "print(",
    i(1),
    t ")",
  }),
  us.msn(
    {
      {
        trig = "pl",
        dscr = "Print a line",
      },
    },
    un.fmtad("print(<q><v><q>)", {
      q = un.qt(),
      v = c(1, {
        -- stylua: ignore start
        i(nil, '-----------------------------------------------------------------'),
        i(nil, '================================================================='),
        i(nil, '.................................................................'),
        i(nil, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'),
        i(nil, '*****************************************************************'),
        i(nil, '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'),
        i(nil, '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'),
        i(nil, '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'),
        i(nil, '#################################################################'),
        i(nil, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'),
        -- stylua: ignore end
      }),
    })
  ),
  us.msn({
    { trig = "rq" },
    { trig = "req" },
  }, {
    t "require(",
    i(1),
    t ")",
  }),
  us.sn({ trig = "ps" }, {
    t "pairs(",
    i(1),
    t ")",
  }),
  us.msn({
    { trig = "ip" },
    { trig = "ips" },
  }, {
    t "ipairs(",
    i(1),
    t ")",
  }),
}

M.nvim = {
  us.sn(
    { trig = "spec" },
    un.fmtad(
      [[
        {
        <idnt><q><author>/<plugin_name><q>,<cont>
        <idnt>config = function()
        <idnt><idnt>require(<q>configs.<plugin_base_name><q>)
        <idnt>end,
        },<fin>
      ]],
      {
        plugin_name = i(1),
        plugin_base_name = f(function(text, _, _)
          return text[1][1]:gsub("%..*", "")
        end, { 1 }),
        author = i(2),
        cont = i(3),
        fin = i(0),
        idnt = t "\t",
        q = un.qt(),
      }
    )
  ),
  us.msn({
    { trig = "nt" },
    { trig = "not" },
    { trig = "noti" },
    { trig = "notify" },
  }, {
    t "vim.notify(",
    i(1),
    t ", vim.log.levels.",
    c(2, {
      i(nil, "DEBUG"),
      i(nil, "WARN"),
      i(nil, "ERROR"),
      i(nil, "INFO"),
      i(nil, "OFF"),
      i(nil, "TRACE"),
    }),
    t ")",
  }),
  us.sn({ trig = "api" }, {
    t "vim.api.nvim_",
  }),
  us.sn({ trig = "vfn" }, {
    t "vim.fn.",
  }),
  us.msn({
    { trig = "in" },
    { trig = "ins" },
    { trig = "insp" },
  }, {
    t "vim.inspect(",
    i(1),
    t ")",
  }),
  us.msn({
    { trig = "pin" },
    { trig = "pins" },
    { trig = "pinsp" },
  }, {
    t "print(vim.inspect(",
    i(1),
    t ")",
    i(2),
    t ")",
  }),
  us.msn(
    {
      { trig = "pck" },
      { trig = "pcheck" },
    },
    un.fmtad("print(<q><v_esc>: <q> .. vim.inspect(<v>)<e>)", {
      q = un.qt(),
      v = i(1),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], "\\" .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
      e = i(3),
    })
  ),
  us.msn(
    {
      common = { priority = 999 },
      { trig = "ck" },
      { trig = "check" },
    },
    un.fmtad("<q><v_esc>: <q> .. vim.inspect(<v>)", {
      q = un.qt(),
      v = i(1),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], "\\" .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.msnr(
    {
      { trig = "(%S*)(%s*)%.%.%s*ck" },
      { trig = "(%S*)(%s*)%.%.%s*check" },
    },
    un.fmtad("<spc>.. <q>, <v_esc>: <q> .. vim.inspect(<v>)", {
      spc = f(function(_, snip, _)
        return snip.captures[1] == "" and snip.captures[2] or snip.captures[1] .. " "
      end, {}, {}),
      q = un.qt(),
      v = i(1),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], "\\" .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
}

return M
