-- Name:         macro
-- Description:  Colorscheme for MΛCRO Neovim inspired by kanagawa-dragon @rebelot and mellifluous @ramojus
-- Author:       Bekaboo <kankefengjing@gmail.com>
-- Maintainer:   Bekaboo <kankefengjing@gmail.com>
-- License:      GPL-3.0
-- Last Updated: Sat 27 Sep 2025 02:30:15 AM EDT

-- Clear hlgroups and set colors_name {{{
vim.cmd.hi('clear')
vim.g.colors_name = 'macro'
-- }}}

-- Palette {{{
-- stylua: ignore start
local c_autumnGreen
local c_autumnRed
local c_autumnYellow
local c_carpYellow
local c_lotusBlue
local c_lotusGray
local c_lotusRed0
local c_lotusRed1
local c_macroAqua
local c_macroAsh
local c_macroBg0
local c_macroBg1
local c_macroBg2
local c_macroBg3
local c_macroBg4
local c_macroBg5
local c_macroBlue0
local c_macroBlue1
local c_macroFg0
local c_macroFg1
local c_macroFg2
local c_macroGray0
local c_macroGray1
local c_macroGray2
local c_macroGreen0
local c_macroGreen1
local c_macroOrange0
local c_macroOrange1
local c_macroPink
local c_macroRed
local c_macroTeal
local c_macroViolet
local c_roninYellow
local c_springBlue
local c_springGreen
local c_springViolet
local c_sumiInk6
local c_waveAqua0
local c_waveAqua1
local c_waveBlue0
local c_waveRed
local c_winterBlue
local c_winterGreen
local c_winterRed
local c_winterYellow

if vim.go.bg == 'dark' then
    c_autumnGreen  = { '#76946a', 107 }
    c_autumnRed    = { '#c34043', 203 }
    c_autumnYellow = { '#dca561', 179 }
    c_carpYellow   = { '#c8ae81', 180 }
    c_lotusBlue    = { '#9fb5c9', 110 }
    c_lotusGray    = { '#716e61', 242 }
    c_lotusRed0    = { '#d7474b', 203 }
    c_lotusRed1    = { '#e84444', 203 }
    c_macroAqua    = { '#95aeac', 109 }
    c_macroAsh     = { '#626462', 241 }
    c_macroBg0     = { '#0d0c0c', 232 }
    c_macroBg1     = { '#181616', 233 }
    c_macroBg2     = { '#201d1d', 234 }
    c_macroBg3     = { '#282727', 235 }
    c_macroBg4     = { '#393836', 237 }
    c_macroBg5     = { '#625e5a', 241 }
    c_macroBlue0   = { '#658594', 66  }
    c_macroBlue1   = { '#8ba4b0', 109 }
    c_macroFg0     = { '#c5c9c5', 251 }
    c_macroFg1     = { '#b4b3a7', 248 }
    c_macroFg2     = { '#a09f95', 247 }
    c_macroGray0   = { '#a6a69c', 247 }
    c_macroGray1   = { '#9e9b93', 246 }
    c_macroGray2   = { '#7a8382', 243 }
    c_macroGreen0  = { '#87a987', 108 }
    c_macroGreen1  = { '#8a9a7b', 107 }
    c_macroOrange0 = { '#b6927b', 137 }
    c_macroOrange1 = { '#b98d7b', 137 }
    c_macroPink    = { '#a292a3', 139 }
    c_macroRed     = { '#c4746e', 174 }
    c_macroTeal    = { '#949fb5', 103 }
    c_macroViolet  = { '#8992a7', 103 }
    c_roninYellow  = { '#ff9e3b', 215 }
    c_springBlue   = { '#7fb4ca', 110 }
    c_springGreen  = { '#98bb6c', 107 }
    c_springViolet = { '#938aa9', 103 }
    c_sumiInk6     = { '#54546d', 60  }
    c_waveAqua0    = { '#6a9589', 66  }
    c_waveAqua1    = { '#7aa89f', 108 }
    c_waveBlue0    = { '#223249', 237 }
    c_waveRed      = { '#e46876', 204 }
    c_winterBlue   = { '#252535', 235 }
    c_winterGreen  = { '#2e322d', 236 }
    c_winterRed    = { '#43242b', 52  }
    c_winterYellow = { '#322e29', 236 }
  else
    c_autumnGreen  = { '#969438', 100 }
    c_autumnRed    = { '#b73242', 131 }
    c_autumnYellow = { '#a0713c', 130 }
    c_carpYellow   = { '#debe97', 180 }
    c_lotusBlue    = { '#9fb5c9', 110 }
    c_lotusGray    = { '#716e61', 242 }
    c_lotusRed0    = { '#d7474b', 203 }
    c_lotusRed1    = { '#e84444', 203 }
    c_macroAqua    = { '#586e62', 65  }
    c_macroAsh     = { '#a0a0a0', 247 }
    c_macroBg0     = { '#f6f6f6', 255 }
    c_macroBg1     = { '#e7e7e7', 254 }
    c_macroBg2     = { '#eeeeee', 255 }
    c_macroBg3     = { '#d8d8d8', 252 }
    c_macroBg4     = { '#c8c8c8', 251 }
    c_macroBg5     = { '#a0a0a0', 247 }
    c_macroBlue0   = { '#658594', 66  }
    c_macroBlue1   = { '#537788', 24  }
    c_macroFg0     = { '#1b1b1b', 234 }
    c_macroFg1     = { '#303030', 236 }
    c_macroFg2     = { '#787878', 243 }
    c_macroGray0   = { '#827f79', 244 }
    c_macroGray1   = { '#6e6b66', 242 }
    c_macroGray2   = { '#7a8382', 243 }
    c_macroGreen0  = { '#87a987', 108 }
    c_macroGreen1  = { '#6a824f', 101 }
    c_macroOrange0 = { '#a06c4e', 130 }
    c_macroOrange1 = { '#825c45', 95  }
    c_macroPink    = { '#a292a3', 139 }
    c_macroRed     = { '#b23b34', 131 }
    c_macroTeal    = { '#445f96', 60  }
    c_macroViolet  = { '#373e50', 59  }
    c_roninYellow  = { '#c87b2e', 172 }
    c_springBlue   = { '#7fb4ca', 110 }
    c_springGreen  = { '#98bb6c', 107 }
    c_springViolet = { '#938aa9', 103 }
    c_sumiInk6     = { '#b1b1d2', 146 }
    c_waveAqua0    = { '#69827b', 66  }
    c_waveAqua1    = { '#7aa89f', 108 }
    c_waveBlue0    = { '#223249', 237 }
    c_waveRed      = { '#e46876', 204 }
    c_winterBlue   = { '#d4d4f0', 189 }
    c_winterGreen  = { '#d5dcd2', 188 }
    c_winterRed    = { '#e6c2c7', 181 }
    c_winterYellow = { '#e2dcd4', 188 }
  end
-- stylua: ignore end
-- }}}

-- Terminal colors {{{
-- stylua: ignore start
if vim.go.bg == 'dark' then
  vim.g.terminal_color_0  = c_macroBg0[1]
  vim.g.terminal_color_1  = c_macroRed[1]
  vim.g.terminal_color_2  = c_macroGreen1[1]
  vim.g.terminal_color_3  = c_carpYellow[1]
  vim.g.terminal_color_4  = c_macroBlue1[1]
  vim.g.terminal_color_5  = c_macroPink[1]
  vim.g.terminal_color_6  = c_macroAqua[1]
  vim.g.terminal_color_7  = c_macroFg1[1]
  vim.g.terminal_color_8  = c_macroBg4[1]
  vim.g.terminal_color_9  = c_waveRed[1]
  vim.g.terminal_color_10 = c_macroGreen0[1]
  vim.g.terminal_color_11 = c_autumnYellow[1]
  vim.g.terminal_color_12 = c_springBlue[1]
  vim.g.terminal_color_13 = c_springViolet[1]
  vim.g.terminal_color_14 = c_waveAqua1[1]
  vim.g.terminal_color_15 = c_macroFg0[1]
  vim.g.terminal_color_16 = c_macroOrange0[1]
  vim.g.terminal_color_17 = c_macroOrange1[1]
else
  vim.g.terminal_color_0  = c_macroBg1[1]
  vim.g.terminal_color_1  = c_macroRed[1]
  vim.g.terminal_color_2  = c_macroGreen1[1]
  vim.g.terminal_color_3  = c_autumnYellow[1]
  vim.g.terminal_color_4  = c_macroBlue1[1]
  vim.g.terminal_color_5  = c_springViolet[1]
  vim.g.terminal_color_6  = c_macroAqua[1]
  vim.g.terminal_color_7  = c_macroFg0[1]
  vim.g.terminal_color_8  = c_macroBg3[1]
  vim.g.terminal_color_9  = c_waveRed[1]
  vim.g.terminal_color_10 = c_macroGreen0[1]
  vim.g.terminal_color_11 = c_carpYellow[1]
  vim.g.terminal_color_12 = c_springBlue[1]
  vim.g.terminal_color_13 = c_sumiInk6[1]
  vim.g.terminal_color_14 = c_waveAqua1[1]
  vim.g.terminal_color_15 = c_macroBg5[1]
  vim.g.terminal_color_16 = c_macroOrange0[1]
  vim.g.terminal_color_17 = c_macroOrange1[1]
end
-- stylua: ignore end
--- }}}

-- Highlight groups {{{1
local hlgroups = {
  -- UI {{{2
  ColorColumn = { bg = c_macroBg2 },
  Conceal = { bold = true, fg = c_macroGray2 },
  CurSearch = { link = 'IncSearch' },
  Cursor = { bg = c_macroFg0, fg = c_macroBg1 },
  CursorColumn = { link = 'CursorLine' },
  CursorIM = { link = 'Cursor' },
  CursorLine = { bg = c_macroBg2 },
  CursorLineNr = { fg = c_macroGray0, bold = true },
  DebugPC = { bg = c_winterRed },
  DiffAdd = { bg = c_winterGreen },
  DiffAdded = { fg = c_autumnGreen },
  DiffChange = { bg = c_winterBlue },
  DiffChanged = { fg = c_autumnYellow },
  DiffDelete = { fg = c_macroBg4 },
  DiffDeleted = { fg = c_autumnRed },
  DiffNewFile = { fg = c_autumnGreen },
  DiffOldFile = { fg = c_autumnRed },
  DiffRemoved = { fg = c_autumnRed },
  DiffText = { bg = c_sumiInk6 },
  Directory = { fg = c_macroBlue1 },
  EndOfBuffer = { fg = c_macroBg1 },
  ErrorMsg = { fg = c_lotusRed1 },
  FloatBorder = { bg = c_macroBg0, fg = c_sumiInk6 },
  FloatFooter = { bg = c_macroBg0, fg = c_macroBg5 },
  FloatTitle = { bg = c_macroBg0, fg = c_macroGray2, bold = true },
  FoldColumn = { fg = c_macroBg5 },
  Folded = { bg = c_macroBg2, fg = c_lotusGray },
  Ignore = { link = 'NonText' },
  IncSearch = { bg = c_carpYellow, fg = c_waveBlue0 },
  LineNr = { fg = c_macroBg5 },
  MatchParen = { bg = c_macroBg4 },
  ModeMsg = { fg = c_macroRed, bold = true },
  MoreMsg = { fg = c_macroBlue0 },
  MsgArea = { fg = c_macroFg1 },
  MsgSeparator = { bg = c_macroBg0 },
  NonText = { fg = c_macroBg5 },
  Normal = { bg = c_macroBg1, fg = c_macroFg0 },
  NormalFloat = { bg = c_macroBg0, fg = c_macroFg1 },
  NormalNC = { link = 'Normal' },
  Pmenu = { bg = c_macroBg3, fg = c_macroFg1 },
  PmenuExtra = { fg = c_macroAsh },
  PmenuSbar = { bg = c_macroBg4 },
  PmenuSel = { bg = c_macroBg4, fg = 'NONE' },
  PmenuThumb = { bg = c_macroBg5 },
  Question = { link = 'MoreMsg' },
  QuickFixLine = { bg = c_winterGreen },
  Search = { bg = c_macroBg4 },
  SignColumn = { fg = c_macroGray2 },
  SpellBad = { underdashed = true },
  SpellCap = { underdashed = true },
  SpellLocal = { underdashed = true },
  SpellRare = { underdashed = true },
  StatusLine = { bg = c_macroBg3, fg = c_macroFg1 },
  StatusLineNC = { bg = c_macroBg2, fg = c_macroBg5 },
  Substitute = { bg = c_autumnRed, fg = c_macroFg0 },
  TabLine = { link = 'StatusLineNC' },
  TabLineFill = { link = 'Normal' },
  TabLineSel = { link = 'StatusLine' },
  TermCursor = { fg = c_macroBg1, bg = c_macroRed },
  Title = { bold = true, fg = c_macroBlue1 },
  Underlined = { fg = c_macroTeal, underline = true },
  VertSplit = { link = 'WinSeparator' },
  Visual = { bg = c_macroBg4 },
  VisualNOS = { link = 'Visual' },
  WarningMsg = { fg = c_roninYellow },
  Whitespace = { fg = c_macroBg4 },
  WildMenu = { link = 'Pmenu' },
  WinBar = { bg = c_macroBg0, fg = c_macroFg1 },
  WinBarNC = { bg = c_macroBg0, fg = c_macroBg5 },
  WinSeparator = { fg = c_macroBg4 },
  lCursor = { link = 'Cursor' },
  -- }}}2

  -- Syntax {{{2
  Boolean = { fg = c_macroOrange0, bold = true },
  Character = { link = 'String' },
  Comment = { fg = c_macroAsh },
  Constant = { fg = c_macroOrange0 },
  Delimiter = { fg = c_macroGray1 },
  Error = { fg = c_lotusRed1 },
  Exception = { fg = c_macroRed },
  Float = { link = 'Number' },
  Function = { fg = c_macroBlue1 },
  Identifier = { fg = c_macroFg0 },
  Keyword = { fg = c_macroViolet },
  Number = { fg = c_macroPink },
  Operator = { fg = c_macroRed },
  PreProc = { fg = c_macroRed },
  Special = { fg = c_macroTeal },
  SpecialKey = { fg = c_macroGray2 },
  Statement = { fg = c_macroViolet },
  String = { fg = c_macroGreen1 },
  Todo = { fg = c_macroBg0, bg = c_macroBlue0, bold = true },
  Type = { fg = c_macroAqua },
  -- }}}2

  -- Treesitter syntax {{{2
  ['@attribute'] = { link = 'Constant' },
  ['@constructor'] = { fg = c_macroTeal },
  ['@constructor.lua'] = { fg = c_macroViolet },
  ['@keyword.exception'] = { bold = true, fg = c_macroRed },
  ['@keyword.import'] = { link = 'PreProc' },
  ['@keyword.luap'] = { link = '@string.regexp' },
  ['@keyword.operator'] = { bold = true, fg = c_macroRed },
  ['@keyword.return'] = { fg = c_macroRed },
  ['@module'] = { fg = c_macroOrange0 },
  ['@operator'] = { link = 'Operator' },
  ['@punctuation.bracket'] = { fg = c_macroGray1 },
  ['@punctuation.delimiter'] = { fg = c_macroGray1 },
  ['@markup.list'] = { fg = c_macroTeal },
  ['@string.escape'] = { fg = c_macroOrange0 },
  ['@string.regexp'] = { fg = c_macroOrange0 },
  ['@string.yaml'] = { link = 'Normal' },
  ['@markup.link.label.symbol'] = { fg = c_macroFg0 },
  ['@tag.attribute'] = { fg = c_macroFg0 },
  ['@tag.delimiter'] = { fg = c_macroGray1 },
  ['@comment.error'] = { bg = c_lotusRed1, fg = c_macroFg0, bold = true },
  ['@diff.delta'] = { link = 'DiffChanged' },
  ['@diff.minus'] = { link = 'DiffRemoved' },
  ['@diff.plus'] = { link = 'DiffAdded' },
  ['@markup.emphasis'] = { italic = true },
  ['@markup.environment'] = { link = 'Keyword' },
  ['@markup.environment.name'] = { link = 'String' },
  ['@markup.raw'] = { link = 'String' },
  ['@comment.info'] = { bg = c_waveAqua0, fg = c_waveBlue0, bold = true },
  ['@markup.quote'] = { link = '@variable.parameter' },
  ['@markup.strong'] = { bold = true },
  ['@markup.heading'] = { link = 'Function' },
  ['@markup.heading.1.markdown'] = { fg = c_macroRed },
  ['@markup.heading.2.markdown'] = { fg = c_macroRed },
  ['@markup.heading.3.markdown'] = { fg = c_macroRed },
  ['@markup.heading.4.markdown'] = { fg = c_macroRed },
  ['@markup.heading.5.markdown'] = { fg = c_macroRed },
  ['@markup.heading.6.markdown'] = { fg = c_macroRed },
  ['@markup.heading.1.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.2.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.3.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.4.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.5.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.6.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.1.delimiter.vimdoc'] = { link = 'helpSectionDelim' },
  ['@markup.heading.2.delimiter.vimdoc'] = { link = 'helpSectionDelim' },
  ['@comment.todo.checked'] = { fg = c_macroAsh },
  ['@comment.todo.unchecked'] = { fg = c_macroRed },
  ['@markup.link.label.markdown_inline'] = { link = 'htmlLink' },
  ['@markup.link.url.markdown_inline'] = { link = 'htmlString' },
  ['@comment.warning'] = { bg = c_roninYellow, fg = c_waveBlue0, bold = true },
  ['@variable'] = { fg = c_macroFg0 },
  ['@variable.builtin'] = { fg = c_macroRed },
  -- }}}

  -- LSP semantic {{{2
  ['@lsp.mod.readonly'] = { link = 'Constant' },
  ['@lsp.mod.typeHint'] = { link = 'Type' },
  ['@lsp.type.builtinConstant'] = { link = '@constant.builtin' },
  ['@lsp.type.comment'] = { fg = 'NONE' },
  ['@lsp.type.macro'] = { fg = c_macroPink },
  ['@lsp.type.magicFunction'] = { link = '@function.builtin' },
  ['@lsp.type.method'] = { link = '@function.method' },
  ['@lsp.type.namespace'] = { link = '@module' },
  ['@lsp.type.parameter'] = { link = '@variable.parameter' },
  ['@lsp.type.selfParameter'] = { link = '@variable.builtin' },
  ['@lsp.type.variable'] = { fg = 'NONE' },
  ['@lsp.typemod.function.builtin'] = { link = '@function.builtin' },
  ['@lsp.typemod.function.defaultLibrary'] = { link = '@function.builtin' },
  ['@lsp.typemod.function.readonly'] = { bold = true, fg = c_macroBlue1 },
  ['@lsp.typemod.keyword.documentation'] = { link = 'Special' },
  ['@lsp.typemod.method.defaultLibrary'] = { link = '@function.builtin' },
  ['@lsp.typemod.operator.controlFlow'] = { link = '@keyword.exception' },
  ['@lsp.typemod.operator.injected'] = { link = 'Operator' },
  ['@lsp.typemod.string.injected'] = { link = 'String' },
  ['@lsp.typemod.variable.defaultLibrary'] = { link = '@variable.builtin' },
  ['@lsp.typemod.variable.injected'] = { link = '@variable' },
  ['@lsp.typemod.variable.static'] = { link = 'Constant' },
  -- }}}

  -- LSP {{{2
  LspCodeLens = { fg = c_macroAsh },
  LspInfoBorder = { link = 'FloatBorder' },
  LspReferenceRead = { link = 'LspReferenceText' },
  LspReferenceText = { bg = c_winterYellow },
  LspReferenceWrite = { bg = c_winterYellow, underline = true },
  LspSignatureActiveParameter = { fg = c_roninYellow },
  -- }}}

  -- Diagnostic {{{2
  DiagnosticError = { fg = c_macroRed },
  DiagnosticHint = { fg = c_macroAqua },
  DiagnosticInfo = { fg = c_macroBlue1 },
  DiagnosticOk = { fg = c_macroGreen1 },
  DiagnosticWarn = { fg = c_carpYellow },
  DiagnosticSignError = { fg = c_macroRed },
  DiagnosticSignHint = { fg = c_macroAqua },
  DiagnosticSignInfo = { fg = c_macroBlue1 },
  DiagnosticSignWarn = { fg = c_carpYellow },
  DiagnosticUnderlineError = { sp = c_macroRed, undercurl = true },
  DiagnosticUnderlineHint = { sp = c_macroAqua, undercurl = true },
  DiagnosticUnderlineInfo = { sp = c_macroBlue1, undercurl = true },
  DiagnosticUnderlineWarn = { sp = c_carpYellow, undercurl = true },
  DiagnosticVirtualTextError = { bg = c_winterRed, fg = c_macroRed },
  DiagnosticVirtualTextHint = { bg = c_winterGreen, fg = c_macroAqua },
  DiagnosticVirtualTextInfo = { bg = c_winterBlue, fg = c_macroBlue1 },
  DiagnosticVirtualTextWarn = { bg = c_winterYellow, fg = c_carpYellow },
  DiagnosticUnnecessary = {
    fg = c_macroAsh,
    sp = c_macroAqua,
    undercurl = true,
  },
  -- }}}

  -- Filetype {{{2
  -- Git
  gitHash = { fg = c_macroAsh },

  -- Sh/Bash
  bashSpecialVariables = { link = 'Constant' },
  shAstQuote = { link = 'Constant' },
  shCaseEsac = { link = 'Operator' },
  shDeref = { link = 'Special' },
  shDerefSimple = { link = 'shDerefVar' },
  shDerefVar = { link = 'Constant' },
  shNoQuote = { link = 'shAstQuote' },
  shQuote = { link = 'String' },
  shTestOpr = { link = 'Operator' },

  -- HTML
  htmlBold = { bold = true },
  htmlBoldItalic = { bold = true, italic = true },
  htmlH1 = { fg = c_macroRed, bold = true },
  htmlH2 = { fg = c_macroRed, bold = true },
  htmlH3 = { fg = c_macroRed, bold = true },
  htmlH4 = { fg = c_macroRed, bold = true },
  htmlH5 = { fg = c_macroRed, bold = true },
  htmlH6 = { fg = c_macroRed, bold = true },
  htmlItalic = { italic = true },
  htmlLink = { fg = c_lotusBlue, underline = true },
  htmlSpecialChar = { link = 'SpecialChar' },
  htmlSpecialTagName = { fg = c_macroViolet },
  htmlString = { link = 'String' },
  htmlTagName = { link = 'Tag' },
  htmlTitle = { link = 'Title' },

  -- Markdown
  markdownBold = { bold = true },
  markdownBoldItalic = { bold = true, italic = true },
  markdownCode = { fg = c_macroGreen1 },
  markdownCodeBlock = { fg = c_macroGreen1 },
  markdownError = { link = 'NONE' },
  markdownEscape = { fg = 'NONE' },
  markdownH1 = { link = 'htmlH1' },
  markdownH2 = { link = 'htmlH2' },
  markdownH3 = { link = 'htmlH3' },
  markdownH4 = { link = 'htmlH4' },
  markdownH5 = { link = 'htmlH5' },
  markdownH6 = { link = 'htmlH6' },
  markdownListMarker = { fg = c_autumnYellow },

  -- Checkhealth
  healthError = { fg = c_lotusRed0 },
  healthSuccess = { fg = c_springGreen },
  healthWarning = { fg = c_roninYellow },
  helpHeader = { link = 'Title' },
  helpSectionDelim = { link = 'Title' },

  -- Qf
  qfFileName = { link = 'Directory' },
  qfLineNr = { link = 'lineNr' },
  -- }}}

  -- Plugins {{{2
  -- gitsigns
  GitSignsAdd = { fg = c_autumnGreen },
  GitSignsChange = { fg = c_sumiInk6 },
  GitSignsDelete = { fg = c_lotusRed0 },
  GitSignsDeletePreview = { bg = c_winterRed },

  -- fugitive
  fugitiveHash = { link = 'gitHash' },
  fugitiveHeader = { link = 'Title' },
  fugitiveHeading = { link = 'Title' },
  fugitiveStagedHeading = { fg = c_autumnGreen, bold = true },
  fugitiveStagedModifier = { fg = c_autumnGreen },
  fugitiveUnStagedHeading = { fg = c_autumnYellow, bold = true },
  fugitiveUnstagedModifier = { fg = c_autumnYellow },
  fugitiveUntrackedHeading = { fg = c_macroAqua, bold = true },
  fugitiveUntrackedModifier = { fg = c_macroAqua },

  -- telescope
  TelescopeBorder = { bg = c_macroBg2, fg = c_sumiInk6 },
  TelescopeMatching = { fg = c_macroRed, bold = true },
  TelescopeNormal = { bg = c_macroBg2, fg = c_macroFg2 },
  TelescopePromptBorder = { bg = c_macroBg3, fg = c_sumiInk6 },
  TelescopePromptNormal = { bg = c_macroBg3, fg = c_macroFg2 },
  TelescopeResultsClass = { link = 'Structure' },
  TelescopeResultsField = { link = '@variable.member' },
  TelescopeResultsMethod = { link = 'Function' },
  TelescopeResultsStruct = { link = 'Structure' },
  TelescopeResultsVariable = { link = '@variable' },
  TelescopeSelection = { link = 'Visual' },
  TelescopeTitle = { bg = c_macroTeal, fg = c_macroBg0 },

  -- nvim-dap-ui
  DapUIBreakpointsCurrentLine = { bold = true, fg = c_macroFg0 },
  DapUIBreakpointsDisabledLine = { link = 'Comment' },
  DapUIBreakpointsInfo = { fg = c_macroBlue0 },
  DapUIBreakpointsPath = { link = 'Directory' },
  DapUIDecoration = { fg = c_sumiInk6 },
  DapUIFloatBorder = { fg = c_sumiInk6 },
  DapUILineNumber = { fg = c_macroTeal },
  DapUIModifiedValue = { bold = true, fg = c_macroTeal },
  DapUIPlayPause = { fg = c_macroGreen1 },
  DapUIRestart = { fg = c_macroGreen1 },
  DapUIScope = { link = 'Special' },
  DapUISource = { fg = c_macroRed },
  DapUIStepBack = { fg = c_macroTeal },
  DapUIStepInto = { fg = c_macroTeal },
  DapUIStepOut = { fg = c_macroTeal },
  DapUIStepOver = { fg = c_macroTeal },
  DapUIStop = { fg = c_lotusRed0 },
  DapUIStoppedThread = { fg = c_macroTeal },
  DapUIThread = { fg = c_macroFg0 },
  DapUIType = { link = 'Type' },
  DapUIUnavailable = { fg = c_macroAsh },
  DapUIWatchesEmpty = { fg = c_lotusRed0 },
  DapUIWatchesError = { fg = c_lotusRed0 },
  DapUIWatchesValue = { fg = c_macroFg0 },

  -- lazy.nvim
  LazyProgressTodo = { fg = c_macroBg5 },

  -- statusline
  StatusLineGitAdded = { bg = c_macroBg3, fg = c_macroGreen1 },
  StatusLineGitChanged = { bg = c_macroBg3, fg = c_carpYellow },
  StatusLineGitRemoved = { bg = c_macroBg3, fg = c_macroRed },
  StatusLineGitBranch = { bg = c_macroBg3, fg = c_macroAsh },
  StatusLineHeader = { bg = c_macroBg5, fg = c_macroFg1 },
  StatusLineHeaderModified = { bg = c_macroRed, fg = c_macroBg1 },

  -- }}}
}
-- }}}1

-- Highlight group overrides {{{1
if vim.go.bg == 'light' then
  hlgroups.CursorLine = { bg = c_macroBg2 }
  hlgroups.DiagnosticSignWarn = { fg = c_autumnYellow }
  hlgroups.DiagnosticUnderlineWarn = { sp = c_autumnYellow, undercurl = true }
  hlgroups.DiagnosticVirtualTextWarn =
    { bg = c_winterYellow, fg = c_autumnYellow }
  hlgroups.DiagnosticWarn = { fg = c_autumnYellow }
  hlgroups.IncSearch = { bg = c_autumnYellow, fg = c_macroBg0, bold = true }
  hlgroups.Keyword = { fg = c_macroRed }
  hlgroups.ModeMsg = { fg = c_macroRed, bold = true }
  hlgroups.Pmenu = { bg = c_macroBg0, fg = c_macroFg1 }
  hlgroups.PmenuSbar = { bg = c_macroBg2 }
  hlgroups.PmenuSel = { bg = c_macroFg0, fg = c_macroBg0 }
  hlgroups.PmenuThumb = { bg = c_macroBg4 }
  hlgroups.Search = { bg = c_macroBg3 }
  hlgroups.StatusLine = { bg = c_macroBg0 }
  hlgroups.StatusLineGitAdded = { bg = c_macroBg0, fg = c_macroGreen1 }
  hlgroups.StatusLineGitChanged = { bg = c_macroBg0, fg = c_autumnYellow }
  hlgroups.StatusLineGitRemoved = { bg = c_macroBg0, fg = c_macroRed }
  hlgroups.StatusLineGitBranch = { bg = c_macroBg0, fg = c_macroAsh }
  hlgroups.StatusLineHeader = { bg = c_macroFg0, fg = c_macroBg0 }
  hlgroups.StatusLineHeaderModified = { bg = c_macroRed, fg = c_macroBg0 }
  hlgroups.Visual = { bg = c_macroBg3 }
  hlgroups.WinBar = { bg = c_macroBg0, fg = c_macroFg1 }
  hlgroups.WinBarNC = { bg = c_macroBg2, fg = c_macroBg5 }
  hlgroups['@variable.parameter'] = { link = 'Identifier' }
end
-- }}}1

-- Set highlight groups {{{1
for name, attr in pairs(hlgroups) do
  attr.ctermbg = attr.bg and attr.bg[2]
  attr.ctermfg = attr.fg and attr.fg[2]
  attr.bg = attr.bg and attr.bg[1]
  attr.fg = attr.fg and attr.fg[1]
  attr.sp = attr.sp and attr.sp[1]
  vim.api.nvim_set_hl(0, name, attr)
end
-- }}}1

-- vim:ts=2:sw=2:sts=2:fdm=marker
