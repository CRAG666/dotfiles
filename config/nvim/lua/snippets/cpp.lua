local M = {}
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

M.c = require('snippets.c').snippets

---@param node TSNode
---@return string?
local function get_class_name(node)
  return vim.treesitter
    .get_node_text(node, 0)
    :match('^%s*class%s*([A-Za-z_]+)')
end

M.snippets = {
  us.sn(
    { trig = 'for', desc = 'For loop', priority = 1001 },
    c(1, {
      un.fmtad(
        [[
          for (<init>; <cond>; <inc>) {
          <body>
          }
        ]],
        {
          init = i(1),
          cond = i(2),
          inc = i(3),
          body = un.body(4, 1),
        }
      ),
      un.fmtad(
        [[
          for (<type> <var> : <container>) {
          <body>
          }
        ]],
        {
          type = i(1, 'auto'),
          var = i(2, 'var'),
          container = i(3, 'container'),
          body = un.body(4, 1),
        }
      ),
    })
  ),
  us.msn(
    {
      { trig = 'fr' },
      { trig = 'forr' },
      { trig = 'forange' },
      { trig = 'forrange' },
      common = { desc = 'Range-based loop' },
    },
    un.fmtad(
      [[
        for (<type> <var> : <container>) {
        <body>
        }
      ]],
      {
        type = i(1, 'auto'),
        var = i(2, 'var'),
        container = i(3, 'container'),
        body = un.body(4, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fi' },
      { trig = 'fori' },
      common = {
        desc = 'For i loop',
        priority = 1001,
      },
    },
    un.fmtad(
      [[
        for (<init>; <cond>; <inc>) {
        <body>
        }
      ]],
      {
        init = i(1),
        cond = i(2),
        inc = i(3),
        body = un.body(4, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'cls' },
      { trig = 'class' },
      common = { desc = 'Class definition' },
    },
    c(1, {
      un.fmtad(
        [[
        class <name><inheritance> {
          public:
          <idnt><public_methods>

          private:
          <idnt><private_methods>
        };
        ]],
        {
          name = r(1, 'name'),
          inheritance = r(2, 'inheritance'),
          idnt = un.idnt(1),
          public_methods = i(3),
          private_methods = i(4),
        }
      ),
      un.fmtad('class <name><inheritance>;', {
        name = r(1, 'name'),
        inheritance = r(2, 'inheritance'),
      }),
    }),
    {
      common_opts = {
        stored = {
          name = i(1, 'ClassName'),
          inheritance = c(2, {
            t(''),
            sn(nil, { t(' : public '), i(1, 'BaseClass') }),
            sn(nil, { t(' : protected '), i(1, 'BaseClass') }),
            sn(nil, { t(' : private '), i(1, 'BaseClass') }),
          }),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'me' },
      { trig = 'meth' },
      common = { desc = 'C++ method' },
    },
    d(1, function()
      -- Inside class definition
      if
        require('utils.ts').find_node(
          'class_specifier',
          { ignore_injections = false }
        )
      then
        local ret_type = r(1, 'ret_type', i(nil, 'void'))
        local method_name = r(2, 'method_name', i(nil, 'methodName'))
        local args = r(3, 'args', i(nil))

        return sn(
          nil,
          c(1, {
            un.fmtad(
              [[
                <ret_type> <method_name>(<args>) {
                <body>
                }
              ]],
              {
                ret_type = vim.deepcopy(ret_type),
                method_name = vim.deepcopy(method_name),
                args = vim.deepcopy(args),
                body = un.body(4, 1),
              }
            ),
            un.fmtad('<ret_type> <method_name>(<args>);', {
              ret_type = vim.deepcopy(ret_type),
              method_name = vim.deepcopy(method_name),
              args = vim.deepcopy(args),
            }),
          })
        )
      end

      local ret_type = r(1, 'ret_type', i(nil, 'void'))
      local class_name = r(2, 'class_name', i(nil, 'ClassName'))
      local method_name = r(3, 'method_name', i(nil, 'methodName'))
      local args = r(4, 'args', i(nil))

      -- Outside class definition
      return sn(
        nil,
        c(1, {
          un.fmtad(
            [[
              <ret_type> <class_name>::<method_name>(<args>) {
              <body>
              }
            ]],
            {
              ret_type = vim.deepcopy(ret_type),
              class_name = vim.deepcopy(class_name),
              method_name = vim.deepcopy(method_name),
              args = vim.deepcopy(args),
              body = un.body(5, 1),
            }
          ),
          un.fmtad('<ret_type> <class_name>::<method_name>(<args>);', {
            ret_type = vim.deepcopy(ret_type),
            class_name = vim.deepcopy(class_name),
            method_name = vim.deepcopy(method_name),
            args = vim.deepcopy(args),
          }),
        })
      )
    end)
  ),
  us.msn(
    {
      { trig = 'ctor' },
      { trig = 'constructor' },
      common = { desc = 'C++ constructor definition' },
    },
    d(1, function()
      local class_node = require('utils.ts').find_node('class_specifier', {
        ignore_injections = false,
      })

      -- Outside class definition
      if not class_node then
        local class_name = r(1, 'class_name', i(nil, i(nil, 'ClassName')))
        local args = r(2, 'args')
        local body = un.body(3, 1)

        return sn(
          nil,
          c(1, {
            un.fmtad(
              [[
                <class_name>::<class_name>(<args>) {
                <body>
                }
              ]],
              {
                class_name = vim.deepcopy(class_name),
                args = vim.deepcopy(args),
                body = vim.deepcopy(body),
              }
            ),
            un.fmtad(
              [[
                <class_name>(<args>) {
                <body>
                }
              ]],
              {
                class_name = vim.deepcopy(class_name),
                args = vim.deepcopy(args),
                body = vim.deepcopy(body),
              }
            ),
          })
        )
      end

      local class_name = r(1, 'class_name', i(nil, get_class_name(class_node)))
      local args = r(2, 'args', i(nil))

      -- Inside class definition, use class name as constructor name
      return sn(
        nil,
        c(1, {
          un.fmtad(
            [[
              <class_name>(<args>) {
              <body>
              }
            ]],
            {
              class_name = vim.deepcopy(class_name),
              args = vim.deepcopy(args),
              body = un.body(3, 1),
            }
          ),
          un.fmtad('<class_name>(<args>);', {
            class_name = vim.deepcopy(class_name),
            args = vim.deepcopy(args),
          }),
        })
      )
    end)
  ),
  us.msn(
    {
      { trig = 'dtor' },
      { trig = 'destructor' },
      common = { desc = 'C++ destructor definition' },
    },
    d(1, function()
      local class_node = require('utils.ts').find_node('class_specifier', {
        ignore_injections = false,
      })

      -- Outside class definition
      if not class_node then
        local class_name = r(1, 'class_name', i(nil, i(nil, 'ClassName')))
        local args = r(2, 'args')
        local body = un.body(3, 1)

        return sn(
          nil,
          c(1, {
            un.fmtad(
              [[
                <class_name>::~<class_name>(<args>) {
                <body>
                }
              ]],
              {
                class_name = vim.deepcopy(class_name),
                args = vim.deepcopy(args),
                body = vim.deepcopy(body),
              }
            ),
            un.fmtad(
              [[
                ~<class_name>(<args>) {
                <body>
                }
              ]],
              {
                class_name = vim.deepcopy(class_name),
                args = vim.deepcopy(args),
                body = vim.deepcopy(body),
              }
            ),
          })
        )
      end

      local class_name = r(1, 'class_name', i(nil, get_class_name(class_node)))
      local args = r(2, 'args', i(nil))

      -- Inside class definition, use class name as destructor name
      return sn(
        nil,
        c(1, {
          un.fmtad(
            [[
              ~<class_name>(<args>) {
              <body>
              }
            ]],
            {
              class_name = vim.deepcopy(class_name),
              args = vim.deepcopy(args),
              body = un.body(3, 1),
            }
          ),
          un.fmtad('~<class_name>(<args>);', {
            class_name = vim.deepcopy(class_name),
            args = vim.deepcopy(args),
          }),
        })
      )
    end)
  ),
}

return M
