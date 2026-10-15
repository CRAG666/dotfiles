-- Port of nvim's `colors/eyes.lua`
-- The variant follows `~/.config/eyes/mode` ('light' or 'dark'), the same
-- file nvim and the rest of the desktop read

local lexers = vis.lexers

---@return 'light'|'dark'
local function eyes_mode()
  local f = io.open(os.getenv('HOME') .. '/.config/eyes/mode', 'r')
  local mode = f and f:read('*l') or 'light'
  if f then
    f:close()
  end
  return mode == 'dark' and 'dark' or 'light'
end

-- Palette {{{
-- stylua: ignore start
local c
if eyes_mode() == 'dark' then
  c = {
    bg0 = '#192019', bg1 = '#1f271f', bg2 = '#252f25', bg3 = '#2c372c',
    bg4 = '#3a463a', bg5 = '#667366',
    fg0 = '#e4e0cc', fg1 = '#d0d4be', fg2 = '#bbc7b0',
    green0 = '#bfe6a1', green1 = '#96d4a6', green2 = '#c3c799',
    teal = '#95ded1', blue0 = '#a2cdf7', blue1 = '#a8d7f0',
    violet = '#d5c9fc', aqua = '#96d4e2',
    orange0 = '#f7bc95', orange1 = '#f4cb94',
    red = '#ffbab1', yellow = '#f1de95', pink = '#efb7db',
    ash = '#9fb9a1', gray0 = '#adbaa9', gray1 = '#b6b4ac', gray2 = '#a2afa0',
    winterGreen = '#253525', winterBlue = '#223243',
    winterRed = '#442928', winterYellow = '#3b3520',
    statusline = '#2c372c',
  }
else
  c = {
    bg0 = '#f7dbb9', bg1 = '#f2d5b2', bg2 = '#edcfac', bg3 = '#e6c7a3',
    bg4 = '#dab992', bg5 = '#b1936e',
    fg0 = '#231d18', fg1 = '#31251a', fg2 = '#483523',
    green0 = '#294f01', green1 = '#003d1b', green2 = '#383f17',
    teal = '#004d44', blue0 = '#073c6e', blue1 = '#00314e',
    violet = '#3f206c', aqua = '#003e4c',
    orange0 = '#5e2600', orange1 = '#5f3700',
    red = '#630005', yellow = '#574a00', pink = '#661b53',
    ash = '#504531', gray0 = '#473b2d', gray1 = '#3b3931', gray2 = '#392e23',
    winterGreen = '#b2e2af', winterBlue = '#b3d7e9',
    winterRed = '#f2c7c2', winterYellow = '#e4dcab',
    statusline = '#f2d5b2',
  }
end
-- stylua: ignore end
-- }}}

---Build a vis style string
---@param spec { fg?: string, bg?: string, [integer]: string }
---@return string
local function style(spec)
  local parts = {}
  if spec.fg then
    table.insert(parts, 'fore:' .. spec.fg)
  end
  if spec.bg then
    table.insert(parts, 'back:' .. spec.bg)
  end
  for _, attr in ipairs(spec) do
    table.insert(parts, attr)
  end
  return table.concat(parts, ',')
end

-- Exposed so other modules (statusline, lsp diagnostics) can reuse it
lexers.eyes = c

-- UI {{{
lexers.STYLE_DEFAULT = style({ fg = c.fg0, bg = c.bg0 })
lexers.STYLE_NOTHING = ''
lexers.STYLE_CURSOR = style({ fg = c.bg0, bg = c.fg0 })
lexers.STYLE_CURSOR_PRIMARY = lexers.STYLE_CURSOR
lexers.STYLE_CURSOR_LINE = style({ bg = c.bg2 })
lexers.STYLE_COLOR_COLUMN = style({ bg = c.bg2 })
lexers.STYLE_SELECTION = style({ bg = c.bg4 })
lexers.STYLE_LINENUMBER = style({ fg = c.bg5 })
lexers.STYLE_LINENUMBER_CURSOR = style({ fg = c.gray0, 'bold' })
lexers.STYLE_STATUS = style({ fg = c.bg5, bg = c.bg2 })
lexers.STYLE_STATUS_FOCUSED = style({ fg = c.fg1, bg = c.statusline })
lexers.STYLE_SEPARATOR = style({ fg = c.bg4 })
lexers.STYLE_INFO = style({ fg = c.fg1 })
lexers.STYLE_EOF = style({ fg = c.bg1 })
lexers.STYLE_WHITESPACE = style({ fg = c.bg4 })
-- }}}

-- Syntax {{{
lexers.STYLE_ANNOTATION = style({ fg = c.orange0 })
lexers.STYLE_ATTRIBUTE = style({ fg = c.orange0 })
lexers.STYLE_CLASS = style({ fg = c.aqua })
lexers.STYLE_COMMENT = style({ fg = c.ash, 'italics' })
lexers.STYLE_CONSTANT = style({ fg = c.orange0 })
lexers.STYLE_CONSTANT_BUILTIN = style({ fg = c.orange0, 'bold' })
lexers.STYLE_DEFINITION = style({ fg = c.blue1 })
lexers.STYLE_EMBEDDED = style({ fg = c.teal })
lexers.STYLE_ERROR = style({ fg = c.red })
lexers.STYLE_FUNCTION = style({ fg = c.blue1 })
lexers.STYLE_FUNCTION_BUILTIN = style({ fg = c.teal })
lexers.STYLE_FUNCTION_METHOD = style({ fg = c.blue1 })
lexers.STYLE_IDENTIFIER = style({ fg = c.fg0 })
lexers.STYLE_KEYWORD = style({ fg = c.violet })
lexers.STYLE_LABEL = style({ fg = c.violet })
lexers.STYLE_NUMBER = style({ fg = c.pink })
lexers.STYLE_OPERATOR = style({ fg = c.teal })
lexers.STYLE_PREPROCESSOR = style({ fg = c.red })
lexers.STYLE_REGEX = style({ fg = c.orange0 })
lexers.STYLE_STRING = style({ fg = c.green1 })
lexers.STYLE_TAG = style({ fg = c.teal })
lexers.STYLE_TYPE = style({ fg = c.aqua })
lexers.STYLE_VARIABLE = style({ fg = c.fg0 })
lexers.STYLE_VARIABLE_BUILTIN = style({ fg = c.red })
-- }}}

-- Markup {{{
lexers.STYLE_HEADING = style({ fg = c.blue1, 'bold' })
lexers.STYLE_HEADING_H1 = style({ fg = c.blue0, 'bold' })
lexers.STYLE_HEADING_H2 = style({ fg = c.blue1, 'bold' })
lexers.STYLE_HEADING_H3 = style({ fg = c.teal, 'bold' })
lexers.STYLE_HEADING_H4 = style({ fg = c.green2, 'bold' })
lexers.STYLE_HEADING_H5 = style({ fg = c.violet, 'bold' })
lexers.STYLE_HEADING_H6 = style({ fg = c.aqua, 'bold' })
lexers.STYLE_BOLD = 'bold'
lexers.STYLE_ITALIC = 'italics'
lexers.STYLE_UNDERLINE = 'underlined'
lexers.STYLE_CODE = style({ fg = c.green1 })
lexers.STYLE_LINK = style({ fg = c.blue0, 'underlined' })
lexers.STYLE_REFERENCE = style({ fg = c.blue0 })
lexers.STYLE_LIST = style({ fg = c.teal })
lexers.STYLE_HR = style({ fg = c.gray1 })
-- }}}

-- Lexer specific {{{
-- Diff
lexers.STYLE_ADDITION = style({ fg = c.green0 })
lexers.STYLE_DELETION = style({ fg = c.red })
lexers.STYLE_CHANGE = style({ fg = c.yellow })
-- CSS
lexers.STYLE_PROPERTY = lexers.STYLE_ATTRIBUTE
-- HTML
lexers.STYLE_TAG_UNKNOWN = lexers.STYLE_TAG .. ',italics'
lexers.STYLE_TAG_SINGLE = lexers.STYLE_TAG
lexers.STYLE_TAG_DOCTYPE = lexers.STYLE_TAG .. ',bold'
lexers.STYLE_ATTRIBUTE_UNKNOWN = lexers.STYLE_ATTRIBUTE .. ',italics'
-- LaTeX
lexers.STYLE_COMMAND = lexers.STYLE_KEYWORD
lexers.STYLE_COMMAND_SECTION = lexers.STYLE_HEADING
lexers.STYLE_ENVIRONMENT = lexers.STYLE_KEYWORD
lexers.STYLE_ENVIRONMENT_MATH = lexers.STYLE_NUMBER
-- Python
lexers.STYLE_KEYWORD_SOFT = lexers.STYLE_KEYWORD
-- YAML
lexers.STYLE_ERROR_INDENT = style({ bg = c.winterRed })
-- }}}

-- vim:ts=2:sw=2:sts=2:fdm=marker
