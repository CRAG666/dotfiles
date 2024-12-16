-- Name:         cockatoo
-- Description:  Soft but colorful colorscheme with light and dark variants
-- Author:       Bekaboo <kankefengjing@gmail.com>
-- Maintainer:   Bekaboo <kankefengjing@gmail.com>
-- License:      GPL-3.0
-- Last Updated: Tue Aug 27 08:38:05 PM EDT 2024

-- Clear hlgroups and set colors_name {{{
vim.cmd.hi('clear')
vim.g.colors_name = 'cockatoo'
-- }}}

-- Palette {{{
-- stylua: ignore start
local c_yellow
local c_earth
local c_orange
local c_pink
local c_ochre
local c_scarlet
local c_wine
local c_tea
local c_aqua
local c_turquoise
local c_flashlight
local c_skyblue
local c_cerulean
local c_lavender
local c_purple
local c_magenta
local c_pigeon
local c_cumulonimbus
local c_thunder
local c_white
local c_smoke
local c_beige
local c_steel
local c_iron
local c_deepsea
local c_ocean
local c_jeans
local c_space
local c_black
local c_shadow
local c_tea_blend
local c_aqua_blend
local c_purple_blend
local c_lavender_blend
local c_scarlet_blend
local c_wine_blend
local c_earth_blend
local c_smoke_blend

if vim.go.bg == 'dark' then
  c_yellow         = '#e6bb86'
  c_earth          = '#c1a575'
  c_orange         = '#f0a16c'
  c_pink           = '#f49ba7'
  c_ochre          = '#e87c69'
  c_scarlet        = '#d85959'
  c_wine           = '#a52929'
  c_tea            = '#a4bd84'
  c_aqua           = '#79ada7'
  c_turquoise      = '#7fa0af'
  c_flashlight     = '#add0ef'
  c_skyblue        = '#a5d5ff'
  c_cerulean       = '#86aadc'
  c_lavender       = '#caafeb'
  c_purple         = '#a48fd1'
  c_magenta        = '#dc8ed3'
  c_pigeon         = '#8f9fbc'
  c_cumulonimbus   = '#557396'
  c_thunder        = '#425974'
  c_white          = '#e5e5eb'
  c_smoke          = '#bebec3'
  c_beige          = '#b1aca7'
  c_steel          = '#606d86'
  c_iron           = '#313742'
  c_deepsea        = '#334154'
  c_ocean          = '#303846'
  c_jeans          = '#262f3e'
  c_space          = '#13161f'
  c_black          = '#09080b'
  c_shadow         = '#09080b'
  c_tea_blend      = '#425858'
  c_aqua_blend     = '#2f3f48'
  c_purple_blend   = '#33374b'
  c_lavender_blend = '#4b4b6e'
  c_scarlet_blend  = '#4b323c'
  c_wine_blend     = '#35262d'
  c_earth_blend    = '#303032'
  c_smoke_blend    = '#272d3a'
else
  c_yellow         = '#c88500'
  c_earth          = '#b48327'
  c_orange         = '#a84a24'
  c_pink           = '#df6d73'
  c_ochre          = '#c84b2b'
  c_scarlet        = '#d85959'
  c_wine           = '#a52929'
  c_tea            = '#5f8c3f'
  c_aqua           = '#3b8f84'
  c_turquoise      = '#29647a'
  c_flashlight     = '#97c0dc'
  c_skyblue        = '#4c99d4'
  c_cerulean       = '#3c70b4'
  c_lavender       = '#9d7bca'
  c_purple         = '#8b71c7'
  c_magenta        = '#ac4ea1'
  c_pigeon         = '#6666a8'
  c_cumulonimbus   = '#486a91'
  c_thunder        = '#dfd6ce'
  c_white          = '#385372'
  c_smoke          = '#404553'
  c_beige          = '#385372'
  c_steel          = '#9a978a'
  c_iron           = '#b8b7b3'
  c_deepsea        = '#e6ded6'
  c_ocean          = '#f0e8e2'
  c_jeans          = '#faf4ed'
  c_space          = '#faf7ee'
  c_black          = '#efefef'
  c_shadow         = '#3c3935'
  c_tea_blend      = '#bdc8ad'
  c_aqua_blend     = '#c4cdc2'
  c_purple_blend   = '#e1dbe2'
  c_lavender_blend = '#bcb0cd'
  c_scarlet_blend  = '#e6b8b3'
  c_wine_blend     = '#e6c9c3'
  c_earth_blend    = '#ebe0ce'
  c_smoke_blend    = '#e4e4e2'
end
-- stylua: ignore end
-- }}}

-- Set terminal colors {{{
-- stylua: ignore start
if vim.go.bg == 'dark' then
  vim.g.terminal_color_0  = c_ocean
  vim.g.terminal_color_1  = c_ochre
  vim.g.terminal_color_2  = c_tea
  vim.g.terminal_color_3  = c_yellow
  vim.g.terminal_color_4  = c_cumulonimbus
  vim.g.terminal_color_5  = c_lavender
  vim.g.terminal_color_6  = c_aqua
  vim.g.terminal_color_7  = c_white
  vim.g.terminal_color_8  = c_white
  vim.g.terminal_color_9  = c_ochre
  vim.g.terminal_color_10 = c_tea
  vim.g.terminal_color_11 = c_yellow
  vim.g.terminal_color_12 = c_cumulonimbus
  vim.g.terminal_color_13 = c_lavender
  vim.g.terminal_color_14 = c_aqua
  vim.g.terminal_color_15 = c_pigeon
else
  vim.g.terminal_color_0  = c_ocean
  vim.g.terminal_color_1  = c_ochre
  vim.g.terminal_color_2  = c_tea
  vim.g.terminal_color_3  = c_yellow
  vim.g.terminal_color_4  = c_flashlight
  vim.g.terminal_color_5  = c_pigeon
  vim.g.terminal_color_6  = c_aqua
  vim.g.terminal_color_7  = c_white
  vim.g.terminal_color_8  = c_white
  vim.g.terminal_color_9  = c_ochre
  vim.g.terminal_color_10 = c_tea
  vim.g.terminal_color_11 = c_yellow
  vim.g.terminal_color_12 = c_cumulonimbus
  vim.g.terminal_color_13 = c_pigeon
  vim.g.terminal_color_14 = c_aqua
  vim.g.terminal_color_15 = c_pigeon
end
-- }}}

-- Highlight groups {{{1
local hlgroups = {
  -- Common {{{2
  Normal = { fg = c_smoke, bg = c_jeans },
  NormalFloat = { fg = c_smoke, bg = c_ocean },
  NormalNC = { link = 'Normal' },
  ColorColumn = { bg = c_deepsea },
  Conceal = { fg = c_smoke },
  Cursor = { fg = c_space, bg = c_white },
  CursorColumn = { bg = c_ocean },
  CursorIM = { fg = c_space, bg = c_flashlight },
  CursorLine = { bg = c_ocean },
  CursorLineNr = { fg = c_orange, bold = true },
  DebugPC = { bg = c_purple_blend },
  lCursor = { link = 'Cursor' },
  TermCursor = { fg = c_space, bg = c_orange },
  TermCursorNC = { fg = c_orange, bg = c_ocean },
  DiffAdd = { bg = c_aqua_blend },
  DiffAdded = { fg = c_tea, bg = c_aqua_blend },
  DiffChange = { bg = c_purple_blend },
  DiffDelete = { fg = c_wine, bg = c_wine_blend },
  DiffRemoved = { fg = c_scarlet, bg = c_wine_blend },
  DiffText = { bg = c_lavender_blend },
  Directory = { fg = c_pigeon },
  EndOfBuffer = { fg = c_iron },
  ErrorMsg = { fg = c_scarlet },
  FoldColumn = { fg = c_steel },
  Folded = { fg = c_steel, bg = c_ocean },
  FloatBorder = { fg = c_smoke, bg = c_ocean },
  FloatShadow = { bg = c_shadow, blend = 70 },
  FloatShadowThrough = { link = 'None' },
  HealthSuccess = { fg = c_tea },
  Search = { bg = c_thunder },
  IncSearch = { fg = c_black, bg = c_orange, bold = true },
  CurSearch = { link = 'IncSearch' },
  LineNr = { fg = c_steel },
  ModeMsg = { fg = c_smoke },
  MoreMsg = { fg = c_aqua },
  MsgArea = { link = 'Normal' },
  MsgSeparator = { link = 'StatusLine' },
  MatchParen = { bg = c_thunder, bold = true },
  NonText = { fg = c_steel },
  Pmenu = { fg = c_smoke, bg = c_ocean },
  PmenuSbar = { bg = c_deepsea },
  PmenuSel = { fg = c_white, bg = c_thunder },
  PmenuThumb = { bg = c_orange },
  Question = { fg = c_smoke },
  QuickFixLine = { link = 'Visual' },
  SignColumn = { fg = c_smoke },
  SpecialKey = { fg = c_orange },
  SpellBad = { underdashed = true },
  SpellCap = { link = 'SpellBad' },
  SpellLocal = { link = 'SpellBad' },
  SpellRare = { link = 'SpellBad' },
  StatusLine = { fg = c_smoke, bg = c_deepsea },
  StatusLineNC = { fg = c_steel, bg = c_ocean },
  Substitute = { link = 'Search' },
  TabLine = { link = 'StatusLine' },
  TabLineFill = { fg = c_pigeon, bg = c_ocean },
  Title = { fg = c_pigeon, bold = true },
  VertSplit = { fg = c_ocean },
  Visual = { bg = c_deepsea },
  VisualNOS = { link = 'Visual' },
  WarningMsg = { fg = c_yellow },
  Whitespace = { link = 'NonText' },
  WildMenu = { link = 'PmenuSel' },
  WinSeparator = { link = 'VertSplit' },
  WinBar = { fg = c_smoke },
  WinBarNC = { fg = c_pigeon },
  -- }}}2

  -- Syntax {{{2
  Comment = { fg = c_steel },
  Constant = { fg = c_ochre },
  String = { fg = c_turquoise },
  DocumentKeyword = { fg = c_tea },
  Character = { fg = c_orange },
  Number = { fg = c_purple },
  Boolean = { fg = c_ochre },
  Array = { fg = c_orange },
  Float = { link = 'Number' },
  Identifier = { fg = c_smoke },
  Builtin = { fg = c_pink },
  Field = { fg = c_pigeon },
  Enum = { fg = c_ochre },
  Namespace = { fg = c_ochre },
  Function = { fg = c_yellow },
  Statement = { fg = c_lavender },
  Specifier = { fg = c_lavender },
  Object = { fg = c_lavender },
  Conditional = { fg = c_magenta },
  Repeat = { fg = c_magenta },
  Label = { fg = c_magenta },
  Operator = { fg = c_orange },
  Keyword = { fg = c_cerulean },
  Exception = { fg = c_magenta },
  PreProc = { fg = c_turquoise },
  PreCondit = { link = 'PreProc' },
  Include = { link = 'PreProc' },
  Define = { link = 'PreProc' },
  Macro = { fg = c_ochre },
  Type = { fg = c_lavender },
  StorageClass = { link = 'Keyword' },
  Structure = { link = 'Type' },
  Typedef = { fg = c_beige },
  Special = { fg = c_orange },
  SpecialChar = { link = 'Special' },
  Tag = { fg = c_flashlight, underline = true },
  Delimiter = { fg = c_orange },
  Bracket = { fg = c_cumulonimbus },
  SpecialComment = { link = 'SpecialChar' },
  Debug = { link = 'Special' },
  Underlined = { underline = true },
  Ignore = { fg = c_iron },
  Error = { fg = c_scarlet },
  Todo = { fg = c_black, bg = c_beige, bold = true },
  -- }}}2

  -- Treesitter syntax {{{2
  ['@variable.member'] = { link = 'Field' },
  ['@property'] = { link = 'Field' },
  ['@annotation'] = { link = 'Operator' },
  ['@comment'] = { link = 'Comment' },
  ['@none'] = { link = 'None' },
  ['@keyword.directive'] = { link = 'PreProc' },
  ['@keyword.directive.define'] = { link = 'Define' },
  ['@operator'] = { link = 'Operator' },
  ['@punctuation.delimiter'] = { link = 'Delimiter' },
  ['@punctuation.bracket'] = { link = 'Bracket' },
  ['@markup.list'] = { link = 'Delimiter' },
  ['@string'] = { link = 'String' },
  ['@string.regexp'] = { link = 'String' },
  ['@string.escape'] = { link = 'SpecialChar' },
  ['@markup.link.label'] = { link = 'SpecialChar' },
  ['@character'] = { link = 'Character' },
  ['@character.special'] = { link = 'SpecialChar' },
  ['@boolean'] = { link = 'Boolean' },
  ['@number'] = { link = 'Number' },
  ['@number.float'] = { link = 'Float' },
  ['@function'] = { link = 'Function' },
  ['@function.call'] = { link = 'Function' },
  ['@function.builtin'] = { link = 'Special' },
  ['@function.macro'] = { link = 'Macro' },
  ['@function.method'] = { link = 'Function' },
  ['@function.method.call'] = { link = 'Function' },
  ['@constructor'] = { link = 'Function' },
  ['@variable.parameter'] = { link = 'Parameter' },
  ['@keyword'] = { link = 'Keyword' },
  ['@keyword.function'] = { link = 'Keyword' },
  ['@keyword.return'] = { link = 'Keyword' },
  ['@keyword.conditional'] = { link = 'Conditional' },
  ['@keyword.repeat'] = { link = 'Repeat' },
  ['@keyword.debug'] = { link = 'Debug' },
  ['@label'] = { link = 'Keyword' },
  ['@keyword.import'] = { link = 'Include' },
  ['@keyword.exception'] = { link = 'Exception' },
  ['@type'] = { link = 'Type' },
  ['@type.Builtin'] = { link = 'Type' },
  ['@type.qualifier'] = { link = 'Type' },
  ['@type.definition'] = { link = 'Typedef' },
  ['@keyword.storage'] = { link = 'StorageClass' },
  ['@attribute'] = { link = 'Label' },
  ['@variable'] = { link = 'Identifier' },
  ['@variable.Builtin'] = { link = 'Builtin' },
  ['@constant'] = { link = 'Constant' },
  ['@constant.Builtin'] = { link = 'Constant' },
  ['@constant.macro'] = { link = 'Macro' },
  ['@module'] = { link = 'Namespace' },
  ['@markup.link.label.symbol'] = { link = 'Identifier' },
  ['@markup'] = { link = 'String' },
  ['@markup.heading'] = { link = 'Title' },
  ['@markup.raw'] = { link = 'String' },
  ['@markup.link.url'] = { link = 'htmlLink' },
  ['@markup.math'] = { link = 'Special' },
  ['@markup.environment'] = { link = 'Macro' },
  ['@markup.environment.name'] = { link = 'Type' },
  ['@markup.link'] = { link = 'Constant' },
  ['@markup.heading.1.markdown'] = { link = 'markdownH1' },
  ['@markup.heading.2.markdown'] = { link = 'markdownH2' },
  ['@markup.heading.3.markdown'] = { link = 'markdownH3' },
  ['@markup.heading.4.markdown'] = { link = 'markdownH4' },
  ['@markup.heading.5.markdown'] = { link = 'markdownH5' },
  ['@markup.heading.6.markdown'] = { link = 'markdownH6' },
  ['@markup.heading.1.marker.markdown'] = { link = 'markdownH1Delimiter' },
  ['@markup.heading.2.marker.markdown'] = { link = 'markdownH2Delimiter' },
  ['@markup.heading.3.marker.markdown'] = { link = 'markdownH3Delimiter' },
  ['@markup.heading.4.marker.markdown'] = { link = 'markdownH4Delimiter' },
  ['@markup.heading.5.marker.markdown'] = { link = 'markdownH5Delimiter' },
  ['@markup.heading.6.marker.markdown'] = { link = 'markdownH6Delimiter' },
  ['@comment.todo'] = { link = 'Todo' },
  ['@comment.todo.unchecked'] = { link = 'Todo' },
  ['@comment.todo.checked'] = { link = 'Done' },
  ['@comment.info'] = { link = 'SpecialComment' },
  ['@comment.warning'] = { link = 'WarningMsg' },
  ['@comment.error'] = { link = 'ErrorMsg' },
  ['@diff.delta'] = { link = 'DiffChanged' },
  ['@diff.minus'] = { link = 'DiffRemoved' },
  ['@diff.plus'] = { link = 'DiffAdded' },
  ['@tag'] = { link = 'Tag' },
  ['@tag.attribute'] = { link = 'Identifier' },
  ['@tag.delimiter'] = { link = 'Delimiter' },
  ['@markup.strong'] = { bold = true },
  ['@markup.strike'] = { strikethrough = true },
  ['@markup.emphasis'] = { fg = c_beige, bold = true, italic = true, },
  ['@markup.underline'] = { underline = true },
  ['@keyword.operator'] = { link = 'Operator' },
  -- }}}2

  -- LSP semantic {{{2
  ['@lsp.type.enum'] = { link = 'Type' },
  ['@lsp.type.type'] = { link = 'Type' },
  ['@lsp.type.class'] = { link = 'Structure' },
  ['@lsp.type.struct'] = { link = 'Structure' },
  ['@lsp.type.macro'] = { link = 'Macro' },
  ['@lsp.type.method'] = { link = 'Function' },
  ['@lsp.type.comment'] = { link = 'Comment' },
  ['@lsp.type.function'] = { link = 'Function' },
  ['@lsp.type.property'] = { link = 'Field' },
  ['@lsp.type.variable'] = { link = 'Variable' },
  ['@lsp.type.decorator'] = { link = 'Label' },
  ['@lsp.type.interface'] = { link = 'Structure' },
  ['@lsp.type.namespace'] = { link = 'Namespace' },
  ['@lsp.type.parameter'] = { link = 'Parameter' },
  ['@lsp.type.enumMember'] = { link = 'Enum' },
  ['@lsp.type.typeParameter'] = { link = 'Parameter' },
  ['@lsp.typemod.keyword.documentation'] = { link = 'DocumentKeyword' },
  ['@lsp.typemod.function.defaultLibrary'] = { link = 'Special' },
  ['@lsp.typemod.variable.defaultLibrary'] = { link = 'Builtin' },
  ['@lsp.typemod.variable.global'] = { link = 'Identifier' },
  -- }}}2

  -- LSP {{{2
  LspReferenceText = { link = 'Identifier' },
  LspReferenceRead = { link = 'LspReferenceText' },
  LspReferenceWrite = { link = 'LspReferenceText' },
  LspSignatureActiveParameter = { link = 'IncSearch' },
  LspInfoBorder = { link = 'FloatBorder' },
  -- }}}2

  -- Diagnostic {{{2
  DiagnosticOk = { fg = c_tea },
  DiagnosticError = { fg = c_wine },
  DiagnosticWarn = { fg = c_earth },
  DiagnosticInfo = { fg = c_smoke },
  DiagnosticHint = { fg = c_pigeon },
  DiagnosticVirtualTextOk = { fg = c_tea, bg = c_tea_blend },
  DiagnosticVirtualTextError = { fg = c_wine, bg = c_wine_blend },
  DiagnosticVirtualTextWarn = { fg = c_earth, bg = c_earth_blend },
  DiagnosticVirtualTextInfo = { fg = c_smoke, bg = c_smoke_blend },
  DiagnosticVirtualTextHint = { fg = c_pigeon, bg = c_deepsea },
  DiagnosticUnderlineOk = { underline = true, sp = c_tea },
  DiagnosticUnderlineError = { undercurl = true, sp = c_wine },
  DiagnosticUnderlineWarn = { undercurl = true, sp = c_earth },
  DiagnosticUnderlineInfo = { undercurl = true, sp = c_flashlight },
  DiagnosticUnderlineHint = { undercurl = true, sp = c_pigeon },
  DiagnosticFloatingOk = { link = 'DiagnosticOk' },
  DiagnosticFloatingError = { link = 'DiagnosticError' },
  DiagnosticFloatingWarn = { link = 'DiagnosticWarn' },
  DiagnosticFloatingInfo = { link = 'DiagnosticInfo' },
  DiagnosticFloatingHint = { link = 'DiagnosticHint' },
  DiagnosticSignOk = { link = 'DiagnosticOk' },
  DiagnosticSignError = { link = 'DiagnosticError' },
  DiagnosticSignWarn = { link = 'DiagnosticWarn' },
  DiagnosticSignInfo = { link = 'DiagnosticInfo' },
  DiagnosticSignHint = { link = 'DiagnosticHint' },
  DiagnosticUnnecessary = {
    fg = c_steel,
    sp = c_pigeon,
    undercurl = true,
  },
  -- }}}2

  -- Filetype {{{2
  -- HTML
  htmlArg = { fg = c_pigeon },
  htmlBold = { bold = true },
  htmlBoldItalic = { bold = true, italic = true },
  htmlTag = { fg = c_smoke },
  htmlTagName = { link = 'Tag' },
  htmlSpecialTagName = { fg = c_yellow },
  htmlEndTag = { fg = c_yellow },
  htmlH1 = { fg = c_yellow, bold = true },
  htmlH2 = { fg = c_ochre, bold = true },
  htmlH3 = { fg = c_pink, bold = true },
  htmlH4 = { fg = c_lavender, bold = true },
  htmlH5 = { fg = c_cerulean, bold = true },
  htmlH6 = { fg = c_aqua, bold = true },
  htmlItalic = { italic = true },
  htmlLink = { fg = c_flashlight, underline = true },
  htmlSpecialChar = { fg = c_beige },
  htmlTitle = { fg = c_pigeon },

  -- Json
  jsonKeyword = { link = 'Keyword' },
  jsonBraces = { fg = c_smoke },

  -- Markdown
  markdownBold = { fg = c_aqua, bold = true },
  markdownBoldItalic = { fg = c_skyblue, bold = true, italic = true },
  markdownCode = { fg = c_pigeon },
  markdownError = { link = 'None' },
  markdownEscape = { link = 'None' },
  markdownListMarker = { fg = c_orange },
  markdownH1 = { link = 'htmlH1' },
  markdownH2 = { link = 'htmlH2' },
  markdownH3 = { link = 'htmlH3' },
  markdownH4 = { link = 'htmlH4' },
  markdownH5 = { link = 'htmlH5' },
  markdownH6 = { link = 'htmlH6' },

  -- Shell
  shDeref = { link = 'Macro' },
  shDerefVar = { link = 'Macro' },

  -- Git
  gitHash = { fg = c_pigeon },

  -- Checkhealth
  helpHeader = { fg = c_pigeon, bold = true },
  helpSectionDelim = { fg = c_ochre, bold = true },
  helpCommand = { fg = c_turquoise },
  helpBacktick = { fg = c_turquoise },

  -- Man
  manBold = { fg = c_ochre, bold = true },
  manItalic = { fg = c_turquoise, italic = true },
  manOptionDesc = { fg = c_ochre },
  manReference = { link = 'htmlLink' },
  manSectionHeading = { link = 'manBold' },
  manUnderline = { fg = c_cerulean },
  -- }}}2

  -- Plugins {{{2
  -- netrw
  netrwClassify = { link = 'Directory' },

  -- nvim-cmp
  CmpItemAbbr = { fg = c_smoke },
  CmpItemAbbrDeprecated = { strikethrough = true },
  CmpItemAbbrMatch = { fg = c_white, bold = true },
  CmpItemAbbrMatchFuzzy = { link = 'CmpItemAbbrMatch' },
  CmpItemKindText = { link = 'String' },
  CmpItemKindMethod = { link = 'Function' },
  CmpItemKindFunction = { link = 'Function' },
  CmpItemKindConstructor = { link = 'Function' },
  CmpItemKindField = { fg = c_purple },
  CmpItemKindProperty = { link = 'CmpItemKindField' },
  CmpItemKindVariable = { fg = c_aqua },
  CmpItemKindReference = { link = 'CmpItemKindVariable' },
  CmpItemKindModule = { fg = c_magenta },
  CmpItemKindEnum = { fg = c_ochre },
  CmpItemKindEnumMember = { link = 'CmpItemKindEnum' },
  CmpItemKindKeyword = { link = 'Keyword' },
  CmpItemKindOperator = { link = 'Operator' },
  CmpItemKindSnippet = { fg = c_tea },
  CmpItemKindColor = { fg = c_pink },
  CmpItemKindConstant = { link = 'Constant' },
  CmpItemKindCopilot = { fg = c_magenta },
  CmpItemKindValue = { link = 'Number' },
  CmpItemKindClass = { link = 'Type' },
  CmpItemKindStruct = { link = 'Type' },
  CmpItemKindEvent = { fg = c_flashlight },
  CmpItemKindInterface = { fg = c_flashlight },
  CmpItemKindFile = { link = 'DevIconDefault' },
  CmpItemKindFolder = { link = 'Directory' },
  CmpItemKindUnit = { fg = c_cerulean },
  CmpItemKind = { fg = c_smoke },
  CmpItemMenu = { link = 'Pmenu' },
  CmpVirtualText = { fg = c_steel, italic = true },

  -- gitsigns
  GitSignsAdd = { fg = c_tea_blend },
  GitSignsAddInline = { fg = c_tea, bg = c_tea_blend },
  GitSignsAddLnInline = { fg = c_tea, bg = c_tea_blend },
  GitSignsAddPreview = { link = 'DiffAdded' },
  GitSignsChange = { fg = c_lavender_blend },
  GitSignsChangeInline = { fg = c_lavender, bg = c_lavender_blend },
  GitSignsChangeLnInline = { fg = c_lavender, bg = c_lavender_blend, },
  GitSignsCurrentLineBlame = { fg = c_smoke, bg = c_smoke_blend },
  GitSignsDelete = { fg = c_wine },
  GitSignsDeleteInline = { fg = c_scarlet, bg = c_scarlet_blend },
  GitSignsDeleteLnInline = { fg = c_scarlet, bg = c_scarlet_blend },
  GitSignsDeletePreview = { fg = c_scarlet, bg = c_wine_blend },
  GitSignsDeleteVirtLnInLine = { fg = c_scarlet, bg = c_scarlet_blend, },
  GitSignsUntracked = { fg = c_scarlet_blend },
  GitSignsUntrackedLn = { bg = c_scarlet_blend },
  GitSignsUntrackedNr = { fg = c_pink },

  -- fugitive
  fugitiveHash = { link = 'gitHash' },
  fugitiveHeader = { link = 'Title' },
  fugitiveHeading = { fg = c_orange, bold = true },
  fugitiveHelpTag = { fg = c_orange },
  fugitiveSymbolicRef = { fg = c_yellow },
  fugitiveStagedModifier = { fg = c_tea, bold = true },
  fugitiveUnstagedModifier = { fg = c_scarlet, bold = true },
  fugitiveUntrackedModifier = { fg = c_pigeon, bold = true },
  fugitiveStagedHeading = { fg = c_aqua, bold = true },
  fugitiveUnstagedHeading = { fg = c_ochre, bold = true },
  fugitiveUntrackedHeading = { fg = c_lavender, bold = true },

  -- telescope
  TelescopeNormal = { link = 'NormalFloat' },
  TelescopePromptNormal = { bg = c_deepsea },
  TelescopeTitle = { fg = c_space, bg = c_turquoise, bold = true },
  TelescopePromptTitle = { fg = c_space, bg = c_yellow, bold = true, },
  TelescopeBorder = { fg = c_smoke, bg = c_ocean },
  TelescopePromptBorder = { fg = c_smoke, bg = c_deepsea },
  TelescopeSelection = { fg = c_smoke, bg = c_thunder },
  TelescopeMultiIcon = { fg = c_pigeon, bold = true },
  TelescopeMultiSelection = { bg = c_thunder, bold = true },
  TelescopePreviewLine = { bg = c_thunder },
  TelescopeMatching = { link = 'Search' },
  TelescopePromptCounter = { link = 'Comment' },
  TelescopePromptPrefix = { fg = c_orange },
  TelescopeSelectionCaret = { fg = c_orange, bg = c_thunder },

  -- nvim-dap-ui
  DapUIBreakpointsCurrentLine = { link = 'CursorLineNr' },
  DapUIBreakpointsInfo = { fg = c_tea },
  DapUIBreakpointsPath = { link = 'Directory' },
  DapUICurrentFrameName = { fg = c_tea, bold = true },
  DapUIDecoration = { fg = c_yellow },
  DapUIFloatBorder = { link = 'FloatBorder' },
  DapUINormalFloat = { link = 'NormalFloat' },
  DapUILineNumber = { link = 'LineNr' },
  DapUIModifiedValue = { fg = c_skyblue, bold = true },
  DapUIPlayPause = { fg = c_tea },
  DapUIPlayPauseNC = { fg = c_tea },
  DapUIRestart = { fg = c_tea },
  DapUIRestartNC = { fg = c_tea },
  DapUIScope = { fg = c_orange },
  DapUISource = { link = 'Directory' },
  DapUIStepBack = { fg = c_lavender },
  DapUIStepBackRC = { fg = c_lavender },
  DapUIStepInto = { fg = c_lavender },
  DapUIStepIntoRC = { fg = c_lavender },
  DapUIStepOut = { fg = c_lavender },
  DapUIStepOutRC = { fg = c_lavender },
  DapUIStepOver = { fg = c_lavender },
  DapUIStepOverRC = { fg = c_lavender },
  DapUIStop = { fg = c_scarlet },
  DapUIStopNC = { fg = c_scarlet },
  DapUIStoppedThread = { fg = c_tea },
  DapUIThread = { fg = c_aqua },
  DapUIType = { link = 'Type' },
  DapUIVariable = { link = 'Identifier' },
  DapUIWatchesEmpty = { link = 'Comment' },
  DapUIWatchesError = { link = 'Error' },
  DapUIWatchesValue = { fg = c_orange },

  -- vimtex
  texArg = { fg = c_pigeon },
  texArgNew = { fg = c_skyblue },
  texCmd = { fg = c_yellow },
  texCmdBib = { link = 'texCmd' },
  texCmdClass = { link = 'texCmd' },
  texCmdDef = { link = 'texCmd' },
  texCmdE3 = { link = 'texCmd' },
  texCmdEnv = { link = 'texCmd' },
  texCmdEnvM = { link = 'texCmd' },
  texCmdError = { link = 'ErrorMsg' },
  texCmdFatal = { link = 'ErrorMsg' },
  texCmdGreek = { link = 'texCmd' },
  texCmdInput = { link = 'texCmd' },
  texCmdItem = { link = 'texCmd' },
  texCmdLet = { link = 'texCmd' },
  texCmdMath = { link = 'texCmd' },
  texCmdNew = { link = 'texCmd' },
  texCmdPart = { link = 'texCmd' },
  texCmdRef = { link = 'texCmd' },
  texCmdSize = { link = 'texCmd' },
  texCmdStyle = { link = 'texCmd' },
  texCmdTitle = { link = 'texCmd' },
  texCmdTodo = { link = 'texCmd' },
  texCmdType = { link = 'texCmd' },
  texCmdVerb = { link = 'texCmd' },
  texComment = { link = 'Comment' },
  texDefParm = { link = 'Keyword' },
  texDelim = { fg = c_pigeon },
  texE3Cmd = { link = 'texCmd' },
  texE3Delim = { link = 'texDelim' },
  texE3Opt = { link = 'texOpt' },
  texE3Parm = { link = 'texParm' },
  texE3Type = { link = 'texCmd' },
  texEnvOpt = { link = 'texOpt' },
  texError = { link = 'ErrorMsg' },
  texFileArg = { link = 'Directory' },
  texFileOpt = { link = 'texOpt' },
  texFilesArg = { link = 'texFileArg' },
  texFilesOpt = { link = 'texFileOpt' },
  texLength = { fg = c_lavender },
  texLigature = { fg = c_pigeon },
  texOpt = { fg = c_smoke },
  texOptEqual = { fg = c_orange },
  texOptSep = { fg = c_orange },
  texParm = { fg = c_pigeon },
  texRefArg = { fg = c_lavender },
  texRefOpt = { link = 'texOpt' },
  texSymbol = { fg = c_orange },
  texTitleArg = { link = 'Title' },
  texVerbZone = { fg = c_pigeon },
  texZone = { fg = c_pigeon },
  texMathArg = { fg = c_pigeon },
  texMathCmd = { link = 'texCmd' },
  texMathSub = { fg = c_pigeon },
  texMathOper = { fg = c_orange },
  texMathZone = { fg = c_yellow },
  texMathDelim = { fg = c_smoke },
  texMathError = { link = 'Error' },
  texMathGroup = { fg = c_pigeon },
  texMathSuper = { fg = c_pigeon },
  texMathSymbol = { fg = c_yellow },
  texMathZoneLD = { fg = c_pigeon },
  texMathZoneLI = { fg = c_pigeon },
  texMathZoneTD = { fg = c_pigeon },
  texMathZoneTI = { fg = c_pigeon },
  texMathCmdText = { link = 'texCmd' },
  texMathZoneEnv = { fg = c_pigeon },
  texMathArrayArg = { fg = c_yellow },
  texMathCmdStyle = { link = 'texCmd' },
  texMathDelimMod = { fg = c_smoke },
  texMathSuperSub = { fg = c_smoke },
  texMathDelimZone = { fg = c_pigeon },
  texMathStyleBold = { fg = c_smoke, bold = true },
  texMathStyleItal = { fg = c_smoke, italic = true },
  texMathEnvArgName = { fg = c_lavender },
  texMathErrorDelim = { link = 'Error' },
  texMathDelimZoneLD = { fg = c_steel },
  texMathDelimZoneLI = { fg = c_steel },
  texMathDelimZoneTD = { fg = c_steel },
  texMathDelimZoneTI = { fg = c_steel },
  texMathZoneEnsured = { fg = c_pigeon },
  texMathCmdStyleBold = { fg = c_yellow, bold = true },
  texMathCmdStyleItal = { fg = c_yellow, italic = true },
  texMathStyleConcArg = { fg = c_pigeon },
  texMathZoneEnvStarred = { fg = c_pigeon },

  -- lazy.nvim
  LazyDir = { link = 'Directory' },
  LazyUrl = { link = 'htmlLink' },
  LazySpecial = { fg = c_orange },
  LazyCommit = { fg = c_tea },
  LazyReasonFt = { fg = c_pigeon },
  LazyReasonCmd = { fg = c_yellow },
  LazyReasonPlugin = { fg = c_turquoise },
  LazyReasonSource = { fg = c_orange },
  LazyReasonRuntime = { fg = c_lavender },
  LazyReasonEvent = { fg = c_flashlight },
  LazyReasonKeys = { fg = c_pink },
  LazyButton = { bg = c_ocean },
  LazyButtonActive = { bg = c_thunder, bold = true },
  LazyH1 = { fg = c_space, bg = c_yellow, bold = true },

  -- copilot.lua
  CopilotSuggestion = { fg = c_steel, italic = true },
  CopilotAnnotation = { fg = c_steel, italic = true },

  -- statusline plugin
  StatusLineDiagnosticError = { fg = c_wine, bg = c_deepsea },
  StatusLineDiagnosticHint = { fg = c_pigeon, bg = c_deepsea },
  StatusLineDiagnosticInfo = { fg = c_smoke, bg = c_deepsea },
  StatusLineDiagnosticWarn = { fg = c_earth, bg = c_deepsea },
  StatusLineGitAdded = { fg = c_tea, bg = c_deepsea },
  StatusLineGitChanged = { fg = c_lavender, bg = c_deepsea },
  StatusLineGitRemoved = { fg = c_scarlet, bg = c_deepsea },
  StatusLineHeader = { fg = c_jeans, bg = c_pigeon },
  StatusLineHeaderModified = { fg = c_jeans, bg = c_ochre },

  -- }}}2

  -- Extra {{{2
  Yellow = { fg = c_yellow },
  Earth = { fg = c_earth },
  Orange = { fg = c_orange },
  Scarlet = { fg = c_scarlet },
  Ochre = { fg = c_ochre },
  Wine = { fg = c_wine },
  Pink = { fg = c_pink },
  Tea = { fg = c_tea },
  Flashlight = { fg = c_flashlight },
  Aqua = { fg = c_aqua },
  Cerulean = { fg = c_cerulean },
  SkyBlue = { fg = c_skyblue },
  Turquoise = { fg = c_turquoise },
  Lavender = { fg = c_lavender },
  Magenta = { fg = c_magenta },
  Purple = { fg = c_purple },
  Thunder = { fg = c_thunder },
  White = { fg = c_white },
  Beige = { fg = c_beige },
  Pigeon = { fg = c_pigeon },
  Steel = { fg = c_steel },
  Smoke = { fg = c_smoke },
  Iron = { fg = c_iron },
  Deepsea = { fg = c_deepsea },
  Ocean = { fg = c_ocean },
  Space = { fg = c_space },
  Black = { fg = c_black },
  -- }}}2
}
-- }}}1

-- Set highlight groups {{{1
for hlgroup_name, hlgroup_attr in pairs(hlgroups) do
  vim.api.nvim_set_hl(0, hlgroup_name, hlgroup_attr)
end
-- }}}1

-- vim:ts=2:sw=2:sts=2:fdm=marker:fdl=0
