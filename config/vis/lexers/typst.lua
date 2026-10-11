-- Typst LPeg lexer (vis ships none)
-- Covers markup mode and the common parts of `#` code expressions

local lexer = lexer
local P, S = lpeg.P, lpeg.S

local lex = lexer.new(..., { no_user_word_lists = true })

-- Comments
local line_comment = lexer.to_eol('//')
local block_comment = lexer.range('/*', '*/')
lex:add_rule('comment', lex:tag(lexer.COMMENT, line_comment + block_comment))

-- Raw text and code blocks
local raw_block = lexer.range('```', '```')
local raw_inline = lexer.range('`', '`', true)
lex:add_rule('code', lex:tag(lexer.CODE, raw_block + raw_inline))

-- Headings: `= Title`, `== Section`, ...
local function h(n)
  return lex:tag(
    string.format('%s.h%s', lexer.HEADING, n),
    lexer.to_eol(lexer.starts_line(P(string.rep('=', n)) * ' '))
  )
end
lex:add_rule('heading', h(6) + h(5) + h(4) + h(3) + h(2) + h(1))

-- List and enum items
lex:add_rule(
  'list',
  lex:tag(
    lexer.LIST,
    lexer.starts_line(S('-+/') + lexer.digit ^ 1 * '.', true) * S(' \t')
  )
)

-- Code expressions: `#let`, `#set`, `#show`, `#func(...)`
local keyword = P('#')
  * lexer.word_match(
    'let set show import include if else for while in return break continue'
      .. ' context as not and or none auto true false'
  )
  * -(lexer.alnum + S('_-'))
lex:add_rule('keyword', lex:tag(lexer.KEYWORD, keyword))
local ident = (lexer.alpha + '_') * (lexer.alnum + S('_-')) ^ 0
lex:add_rule(
  'function',
  lex:tag(lexer.FUNCTION, P('#') * ident * (P('.') * ident) ^ 0)
)

-- Strings
lex:add_rule('string', lex:tag(lexer.STRING, lexer.range('"')))

-- Math
lex:add_rule('math', lex:tag(lexer.EMBEDDED, lexer.range('$', '$')))

-- Labels and references
lex:add_rule(
  'reference',
  lex:tag(lexer.REFERENCE, lexer.range('<', '>', true) + P('@') * ident)
)

-- Emphasis
lex:add_rule('bold', lex:tag(lexer.BOLD, lexer.range('*', '*', true)))
lex:add_rule('italic', lex:tag(lexer.ITALIC, lexer.range('_', '_', true)))

-- Escapes
lex:add_rule('escape', lex:tag(lexer.CONSTANT, P('\\') * lexer.any))

-- Plain words, matched in bulk instead of one char at a time
lex:add_rule('text', lex:tag(lexer.DEFAULT, lexer.alnum ^ 1))

lexer.property['scintillua.comment'] = '//'

return lex
