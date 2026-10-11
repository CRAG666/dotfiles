---Treesitter languages of markdown and tex documents, including math injected
---into markdown
local tex_langs = { 'markdown', 'markdown_inline', 'latex' }

---@param before string
---@return fun(ctx: blink.pairs.Context): boolean
local function after_text(before)
  return function(ctx)
    return ctx:text_before_cursor(#before) == before
  end
end

---@type pack.spec
return {
  src = 'https://github.com/saghen/blink.pairs',
  version = vim.version.range('*'),
  data = {
    deps = { 'https://github.com/saghen/blink.lib' },
    build = function()
      vim.cmd.packadd('blink.lib')
      vim.cmd.packadd('blink.pairs')
      require('blink.pairs').download():pwait(60000)
    end,
    events = { 'InsertEnter', 'CmdlineEnter' },
    postload = function()
      ---Record previous cmdline completion types,
      ---`compltype[1]` is the current completion type,
      ---`compltype[2]` is the previous completion type
      ---@type string[]
      local compltype = {}

      vim.api.nvim_create_autocmd('CmdlineChanged', {
        desc = 'Record cmd compltype to determine whether to autopair.',
        group = vim.api.nvim_create_augroup(
          'blink.pairs.record_cmdcompltype',
          {}
        ),
        callback = function()
          local type = vim.fn.getcmdcompltype()
          if compltype[1] == type then
            return
          end
          compltype[2] = compltype[1]
          compltype[1] = type
        end,
      })

      -- Disable autopairs in macros and when inserting a regex, e.g.
      -- `:s/{pattern}/{string}/[flags]` or `:g/{pattern}/[cmd]`
      local mappings = require('blink.pairs.mappings')
      local is_enabled = mappings.is_enabled
      ---@diagnostic disable-next-line: duplicate-set-field
      function mappings.is_enabled()
        return is_enabled()
          and vim.fn.reg_recording() == ''
          and vim.fn.reg_executing() == ''
          and (
            vim.fn.mode() ~= 'c'
            or compltype[2] ~= 'command'
            or compltype[1] ~= ''
          )
      end

      require('blink.pairs').setup({
        mappings = {
          wrap = {
            -- Conflict with readline's keymap, see `lua/plugin/readline.lua`
            ['<C-b>'] = false,
            ['<C-S-b>'] = false,
            ['<A-e>'] = 'motion',
            ['<A-E>'] = 'motion_reverse',
          },
          pairs = {
            ['('] = {
              { '\\left(', '\\right)', languages = tex_langs },
              { '(', ')' },
            },
            ['['] = {
              { '\\left[', '\\right]', languages = tex_langs },
              -- `[` repeats in the opening, so pair the last `[` of `[=[`,
              -- reusing the `]` paired with the first `[`
              {
                '[',
                ']=',
                languages = { 'lua' },
                -- Prefer over the next rule when the `]` exists
                priority = 100,
                when = function(ctx)
                  return after_text('[=')(ctx) and ctx:is_after_cursor(']')
                end,
              },
              { '[', ']=]', languages = { 'lua' }, when = after_text('[=') },
              {
                '[',
                ']',
                -- Same as the default rule
                space = function(ctx)
                  return not ctx.ts:is_language('markdown')
                    -- ignore markdown todo items (bullets and numbered)
                    or (
                      not ctx
                        :text_before_cursor()
                        :match('^%s*[%*%-+]%s+%[%s*$')
                      and not ctx
                        :text_before_cursor()
                        :match('^%s*%d+%.%s+%[%s*$')
                    )
                end,
              },
            },
            ['{'] = {
              { '\\left{', '\\right}', languages = tex_langs },
              { '{', '}' },
            },
            ['<'] = {
              { '\\left<', '\\right>', languages = tex_langs },
              { '<', '>>>', languages = { 'cuda' }, when = after_text('<<') },
              -- Ambiguous with the less than operator, only delete `<|>`
              { '<', '>', open = false, close = false },
            },
            ['>'] = {
              -- Expand `<tag>|</tag>` on enter and space
              {
                '>',
                '<',
                languages = { 'html', 'xml', 'markdown', 'markdown_inline' },
                open = false,
                close = false,
              },
            },
            ['*'] = {
              {
                '/*',
                '*/',
                languages = {
                  'c',
                  'cpp',
                  'cuda',
                  'go',
                  'java',
                  'scala',
                  'typescript',
                  'javascript',
                  'tsx',
                },
              },
              -- Pairing '$' and '*' are handled by snippets,
              -- only delete matched pairs here
              {
                '*',
                languages = { 'markdown', 'markdown_inline' },
                open_or_close = false,
              },
            },
            ['$'] = {
              { '$', languages = tex_langs, open_or_close = false },
            },
            ['_'] = {
              {
                '_',
                when = function()
                  return false
                end,
              },
            },
            -- Opened by snippets, only expand/delete them on enter, space
            -- and backspace
            ['\\'] = vim
              .iter({
                { '\\left\\lfloor', '\\right\\rfloor' },
                { '\\left\\lceil', '\\right\\rceil' },
                { '\\left\\vert', '\\right\\vert' },
                { '\\left\\lVert', '\\right\\rVert' },
                { '\\begin{bmatrix}', '\\end{bmatrix}' },
                { '\\begin{pmatrix}', '\\end{pmatrix}' },
              })
              :map(function(pair)
                return {
                  pair[1],
                  pair[2],
                  languages = tex_langs,
                  open = false,
                  close = false,
                }
              end)
              :totable(),
          },
        },
        -- Keep using builtin matchparen without rainbow pairs
        highlights = { enabled = false },
      })
    end,
  },
}
