-- Name:         macro
-- Description:  Colorscheme for MΛCRO Neovim inspired by kanagawa-dragon @rebelot and mellifluous @ramojus
-- Author:       Bekaboo <kankefengjing@gmail.com>
-- Maintainer:   Bekaboo <kankefengjing@gmail.com>
-- License:      GPL-3.0
-- Last Updated: Thu Oct  3 11:58:48 PM EDT 2024

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
local c_katanaGray
local c_lotusBlue
local c_lotusGray
local c_lotusRed0
local c_lotusRed1
local c_lotusRed2
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
local c_waveBlue1
local c_waveRed
local c_winterBlue
local c_winterGreen
local c_winterRed
local c_winterYellow

if vim.go.bg == 'dark' then
  c_autumnGreen  = '#76946a'
  c_autumnRed    = '#c34043'
  c_autumnYellow = '#dca561'
  c_carpYellow   = '#c8ae81'
  c_katanaGray   = '#717c7c'
  c_lotusBlue    = '#9fb5c9'
  c_lotusGray    = '#716e61'
  c_lotusRed0    = '#d7474b'
  c_lotusRed1    = '#e84444'
  c_lotusRed2    = '#d9a594'
  c_macroAqua    = '#95aeac'
  c_macroAsh     = '#626462'
  c_macroBg0     = '#0d0c0c'
  c_macroBg1     = '#181616'
  c_macroBg2     = '#201d1d'
  c_macroBg3     = '#282727'
  c_macroBg4     = '#393836'
  c_macroBg5     = '#625e5a'
  c_macroBlue0   = '#658594'
  c_macroBlue1   = '#8ba4b0'
  c_macroFg0     = '#c5c9c5'
  c_macroFg1     = '#b4b3a7'
  c_macroFg2     = '#a09f95'
  c_macroGray0   = '#a6a69c'
  c_macroGray1   = '#9e9b93'
  c_macroGray2   = '#7a8382'
  c_macroGreen0  = '#87a987'
  c_macroGreen1  = '#8a9a7b'
  c_macroOrange0 = '#b6927b'
  c_macroOrange1 = '#b98d7b'
  c_macroPink    = '#a292a3'
  c_macroRed     = '#c4746e'
  c_macroTeal    = '#949fb5'
  c_macroViolet  = '#8992a7'
  c_roninYellow  = '#ff9e3b'
  c_springBlue   = '#7fb4ca'
  c_springGreen  = '#98bb6c'
  c_springViolet = '#938aa9'
  c_sumiInk6     = '#54546d'
  c_waveAqua0    = '#6a9589'
  c_waveAqua1    = '#7aa89f'
  c_waveBlue0    = '#223249'
  c_waveBlue1    = '#2d4f67'
  c_waveRed      = '#e46876'
  c_winterBlue   = '#252535'
  c_winterGreen  = '#2e322d'
  c_winterRed    = '#43242b'
  c_winterYellow = '#322e29'
else
  c_autumnGreen  = '#969438'
  c_autumnRed    = '#b73242'
  c_autumnYellow = '#a0713c'
  c_carpYellow   = '#debe97'
  c_katanaGray   = '#717c7c'
  c_lotusBlue    = '#9fb5c9'
  c_lotusGray    = '#716e61'
  c_lotusRed0    = '#d7474b'
  c_lotusRed1    = '#e84444'
  c_lotusRed2    = '#d9a594'
  c_macroAqua    = '#586e62'
  c_macroAsh     = '#a0a0a0'
  c_macroBg0     = '#f6f6f6'
  c_macroBg1     = '#e7e7e7'
  c_macroBg2     = '#eeeeee'
  c_macroBg3     = '#d8d8d8'
  c_macroBg4     = '#c8c8c8'
  c_macroBg5     = '#a0a0a0'
  c_macroBlue0   = '#658594'
  c_macroBlue1   = '#537788'
  c_macroFg0     = '#1b1b1b'
  c_macroFg1     = '#303030'
  c_macroFg2     = '#787878'
  c_macroGray0   = '#827f79'
  c_macroGray1   = '#6e6b66'
  c_macroGray2   = '#7a8382'
  c_macroGreen0  = '#87a987'
  c_macroGreen1  = '#6a824f'
  c_macroOrange0 = '#a06c4e'
  c_macroOrange1 = '#825c45'
  c_macroPink    = '#a292a3'
  c_macroRed     = '#b23b34'
  c_macroTeal    = '#445f96'
  c_macroViolet  = '#373e50'
  c_roninYellow  = '#c87b2e'
  c_springBlue   = '#7fb4ca'
  c_springGreen  = '#98bb6c'
  c_springViolet = '#938aa9'
  c_sumiInk6     = '#b1b1d2'
  c_waveAqua0    = '#69827b'
  c_waveAqua1    = '#7aa89f'
  c_waveBlue0    = '#223249'
  c_waveBlue1    = '#2d4f67'
  c_waveRed      = '#e46876'
  c_winterBlue   = '#d4d4f0'
  c_winterGreen  = '#d5dcd2'
  c_winterRed    = '#e6c2c7'
  c_winterYellow = '#e2dcd4'
end
-- stylua: ignore end
-- }}}

-- Terminal colors {{{
-- stylua: ignore start
if vim.go.bg == 'dark' then
  vim.g.terminal_color_0  = c_macroBg0
  vim.g.terminal_color_1  = c_macroRed
  vim.g.terminal_color_2  = c_macroGreen1
  vim.g.terminal_color_3  = c_carpYellow
  vim.g.terminal_color_4  = c_macroBlue1
  vim.g.terminal_color_5  = c_macroPink
  vim.g.terminal_color_6  = c_macroAqua
  vim.g.terminal_color_7  = c_macroFg1
  vim.g.terminal_color_8  = c_macroBg4
  vim.g.terminal_color_9  = c_waveRed
  vim.g.terminal_color_10 = c_macroGreen0
  vim.g.terminal_color_11 = c_autumnYellow
  vim.g.terminal_color_12 = c_springBlue
  vim.g.terminal_color_13 = c_springViolet
  vim.g.terminal_color_14 = c_waveAqua1
  vim.g.terminal_color_15 = c_macroFg0
  vim.g.terminal_color_16 = c_macroOrange0
  vim.g.terminal_color_17 = c_macroOrange1
else
  vim.g.terminal_color_0  = c_macroBg1
  vim.g.terminal_color_1  = c_macroRed
  vim.g.terminal_color_2  = c_macroGreen1
  vim.g.terminal_color_3  = c_autumnYellow
  vim.g.terminal_color_4  = c_macroBlue1
  vim.g.terminal_color_5  = c_springViolet
  vim.g.terminal_color_6  = c_macroAqua
  vim.g.terminal_color_7  = c_macroBg5
  vim.g.terminal_color_8  = c_macroBg3
  vim.g.terminal_color_9  = c_waveRed
  vim.g.terminal_color_10 = c_macroGreen0
  vim.g.terminal_color_11 = c_carpYellow
  vim.g.terminal_color_12 = c_springBlue
  vim.g.terminal_color_13 = c_sumiInk6
  vim.g.terminal_color_14 = c_waveAqua1
  vim.g.terminal_color_15 = c_macroFg0
  vim.g.terminal_color_16 = c_macroOrange0
  vim.g.terminal_color_17 = c_macroOrange1
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
  PmenuSbar = { bg = c_macroBg4 },
  PmenuSel = { bg = c_macroBg4, fg = 'NONE' },
  PmenuThumb = { bg = c_macroBg5 },
  Question = { link = 'MoreMsg' },
  QuickFixLine = { bg = c_macroBg3 },
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
  TermCursorNC = { fg = c_macroBg1, bg = c_macroAsh },
  Title = { bold = true, fg = c_macroBlue1 },
  Underlined = { fg = c_macroTeal, underline = true },
  VertSplit = { link = 'WinSeparator' },
  Visual = { bg = c_macroBg4 },
  VisualNOS = { link = 'Visual' },
  WarningMsg = { fg = c_roninYellow },
  Whitespace = { fg = c_macroBg4 },
  WildMenu = { link = 'Pmenu' },
  WinBar = { bg = 'NONE', fg = c_macroFg1 },
  WinBarNC = { link = 'WinBar' },
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
  ['@keyword.return'] = { fg = c_macroRed, italic = true },
  ['@module'] = { fg = c_macroOrange0 },
  ['@operator'] = { link = 'Operator' },
  ['@punctuation.bracket'] = { fg = c_macroGray1 },
  ['@punctuation.delimiter'] = { fg = c_macroGray1 },
  ['@markup.list'] = { fg = c_macroTeal },
  ['@string.escape'] = { fg = c_macroOrange0 },
  ['@string.regexp'] = { fg = c_macroOrange0 },
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
  ['@comment.todo.checked'] = { fg = c_macroAsh },
  ['@comment.todo.unchecked'] = { fg = c_macroRed },
  ['@markup.link.label.markdown_inline'] = { link = 'htmlLink' },
  ['@markup.link.url.markdown_inline'] = { link = 'htmlString' },
  ['@comment.warning'] = { bg = c_roninYellow, fg = c_waveBlue0, bold = true },
  ['@variable'] = { fg = c_macroFg0 },
  ['@variable.builtin'] = { fg = c_macroRed, italic = true },
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
  ['@lsp.typemod.variable.global'] = { link = 'Constant' },
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
  htmlString = { fg = c_macroAsh },
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
  -- nvim-cmp
  CmpCompletion = { link = 'Pmenu' },
  CmpCompletionBorder = { bg = c_waveBlue0, fg = c_waveBlue1 },
  CmpCompletionSbar = { link = 'PmenuSbar' },
  CmpCompletionSel = { bg = c_waveBlue1, fg = 'NONE' },
  CmpCompletionThumb = { link = 'PmenuThumb' },
  CmpDocumentation = { link = 'NormalFloat' },
  CmpDocumentationBorder = { link = 'FloatBorder' },
  CmpItemAbbr = { fg = c_macroFg2 },
  CmpItemAbbrDeprecated = { fg = c_macroAsh, strikethrough = true },
  CmpItemAbbrMatch = { fg = c_macroRed },
  CmpItemAbbrMatchFuzzy = { link = 'CmpItemAbbrMatch' },
  CmpItemKindClass = { link = 'Type' },
  CmpItemKindConstant = { link = 'Constant' },
  CmpItemKindConstructor = { link = '@constructor' },
  CmpItemKindCopilot = { link = 'String' },
  CmpItemKindDefault = { fg = c_katanaGray },
  CmpItemKindEnum = { link = 'Type' },
  CmpItemKindEnumMember = { link = 'Constant' },
  CmpItemKindField = { link = '@variable.member' },
  CmpItemKindFile = { link = 'Directory' },
  CmpItemKindFolder = { link = 'Directory' },
  CmpItemKindFunction = { link = 'Function' },
  CmpItemKindInterface = { link = 'Type' },
  CmpItemKindKeyword = { link = '@keyword' },
  CmpItemKindMethod = { link = 'Function' },
  CmpItemKindModule = { link = '@keyword.import' },
  CmpItemKindOperator = { link = 'Operator' },
  CmpItemKindProperty = { link = '@property' },
  CmpItemKindReference = { link = 'Type' },
  CmpItemKindSnippet = { fg = c_macroTeal },
  CmpItemKindStruct = { link = 'Type' },
  CmpItemKindText = { fg = c_macroFg2 },
  CmpItemKindTypeParameter = { link = 'Type' },
  CmpItemKindValue = { link = 'String' },
  CmpItemKindVariable = { fg = c_lotusRed2 },
  CmpItemMenu = { fg = c_macroAsh },

  -- gitsigns
  GitSignsAdd = { fg = c_autumnGreen },
  GitSignsChange = { fg = c_sumiInk6 },
  GitSignsDelete = { fg = c_lotusRed0 },
  GitSignsDeletePreview = { bg = c_winterRed },

  -- fugitive
  fugitiveHash = { link = 'gitHash' },
  fugitiveHeader = { link = 'Title' },
  fugitiveStagedModifier = { fg = c_autumnGreen },
  fugitiveUnstagedModifier = { fg = c_autumnYellow },
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
  hlgroups.StatusLineHeader = { bg = c_macroFg0, fg = c_macroBg0 }
  hlgroups.StatusLineHeaderModified = { bg = c_macroRed, fg = c_macroBg0 }
  hlgroups.Visual = { bg = c_macroBg3 }
  hlgroups['@variable.parameter'] = { link = 'Identifier' }
end
-- }}}1

-- Set highlight groups {{{1
for hlgroup_name, hlgroup_attr in pairs(hlgroups) do
  vim.api.nvim_set_hl(0, hlgroup_name, hlgroup_attr)
end
-- }}}1

-- vim:ts=2:sw=2:sts=2:fdm=marker:fdl=0
