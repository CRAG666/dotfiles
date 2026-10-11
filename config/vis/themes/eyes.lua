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
    bg0 = '#1a211a', bg1 = '#202820', bg2 = '#263026', bg3 = '#2d382d',
    bg4 = '#3a463a', bg5 = '#536053',
    fg0 = '#d0dcc8', fg1 = '#b8c8b0', fg2 = '#9aab94',
    green0 = '#7aab72', green1 = '#88b878', green2 = '#6a9460',
    teal = '#5ab8a8', blue0 = '#6a94a8', blue1 = '#82aab8',
    violet = '#9090b8', aqua = '#6ab8b0',
    orange0 = '#b89a6a', orange1 = '#c8a870',
    red = '#c87868', yellow = '#d4b85a', pink = '#b890b0',
    ash = '#7a8c72', gray0 = '#8a9a88', gray1 = '#7a8a78', gray2 = '#6a7868',
    winterGreen = '#243224', winterBlue = '#223040',
    winterRed = '#402828', winterYellow = '#3a3420',
    statusline = '#2d382d',
  }
else
  c = {
    bg0 = '#add4a0', bg1 = '#a4cc98', bg2 = '#9fc895', bg3 = '#96be8c',
    bg4 = '#88b07e', bg5 = '#6a9060',
    fg0 = '#1a1a1a', fg1 = '#1e2e1c', fg2 = '#3d5c38',
    green0 = '#2a5c22', green1 = '#1e4a18', green2 = '#3a5030',
    teal = '#145850', blue0 = '#1e4868', blue1 = '#143c52',
    violet = '#3a2860', aqua = '#1a5858',
    orange0 = '#6a3c10', orange1 = '#7a4a18',
    red = '#7a1e18', yellow = '#5a4808', pink = '#5a2858',
    ash = '#365c25', gray0 = '#486040', gray1 = '#385030', gray2 = '#2c4028',
    winterGreen = '#94cc88', winterBlue = '#90bcd0',
    winterRed = '#d8a8a0', winterYellow = '#d0c890',
    statusline = '#a4cc98',
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
