-- Name:         nano
-- Description:  Colorscheme inspired by nano-emacs @rougier and nanovim @Anthony
-- Author:       Bekaboo <kankefengjing@gmail.com>
-- Maintainer:   Bekaboo <kankefengjing@gmail.com>
-- License:      GPL-3.0
-- Last Updated: Sat 27 Sep 2025 01:37:57 AM EDT

-- Clear hlgroups and set colors_name {{{
vim.cmd.hi('clear')
vim.g.colors_name = 'nano'
-- }}}

-- Palette {{{
-- stylua: ignore start
local c_foreground
local c_background
local c_highlight
local c_critical
local c_salient
local c_strong
local c_popout
local c_subtle
local c_shaded
local c_faint
local c_faded
local c_grass
local c_pine
local c_lavender
local c_violet
local c_black

if vim.go.bg == 'dark' then
  c_foreground = { '#cbced2', 251 }
  c_background = { '#2e3440', 236 }
  c_highlight  = { '#3b4252', 238 }
  c_critical   = { '#ebcb8b', 222 }
  c_salient    = { '#81a1c0', 110 }
  c_strong     = { '#e5e7ec', 255 }
  c_popout     = { '#d08770', 173 }
  c_subtle     = { '#434c5e', 239 }
  c_shaded     = { '#4f596e', 60  }
  c_faint      = { '#6d7d9a', 103 }
  c_faded      = { '#99aac8', 110 }
  c_grass      = { '#43565a', 23  }
  c_pine       = { '#8eb0a2', 109 }
  c_lavender   = { '#48506e', 60  }
  c_violet     = { '#97a5dc', 146 }
  c_black      = { '#1c2027', 234 }
else
  c_foreground = { '#495b64', 59  }
  c_background = { '#ffffff', 231 }
  c_highlight  = { '#f5f8fa', 255 }
  c_critical   = { '#e0b153', 208 }
  c_salient    = { '#673ab7', 98  }
  c_strong     = { '#000000', 16  }
  c_popout     = { '#f09276', 216 }
  c_subtle     = { '#e9eef1', 255 }
  c_shaded     = { '#dde3e6', 254 }
  c_faint      = { '#bec8cc', 250 }
  c_faded      = { '#9fadb4', 247 }
  c_grass      = { '#e8f5e9', 194 }
  c_pine       = { '#608c88', 66  }
  c_lavender   = { '#f4eef8', 255 }
  c_violet     = { '#d9caf0', 183 }
  c_black      = { '#5b6c75', 242 }
end
-- stylua: ignore end
-- }}}

-- Set terminal colors {{{
-- stylua: ignore start
if vim.go.bg == 'dark' then
  vim.g.terminal_color_0  = c_subtle[1]
  vim.g.terminal_color_1  = c_popout[1]
  vim.g.terminal_color_2  = c_pine[1]
  vim.g.terminal_color_3  = c_critical[1]
  vim.g.terminal_color_4  = c_faint[1]
  vim.g.terminal_color_5  = c_strong[1]
  vim.g.terminal_color_6  = c_salient[1]
  vim.g.terminal_color_7  = c_faded[1]
  vim.g.terminal_color_8  = c_faded[1]
  vim.g.terminal_color_9  = c_popout[1]
  vim.g.terminal_color_10 = c_pine[1]
  vim.g.terminal_color_11 = c_critical[1]
  vim.g.terminal_color_12 = c_faded[1]
  vim.g.terminal_color_13 = c_strong[1]
  vim.g.terminal_color_14 = c_salient[1]
  vim.g.terminal_color_15 = c_faded[1]
else
  vim.g.terminal_color_0  = c_subtle[1]
  vim.g.terminal_color_1  = c_critical[1]
  vim.g.terminal_color_2  = c_pine[1]
  vim.g.terminal_color_3  = c_popout[1]
  vim.g.terminal_color_4  = c_faint[1]
  vim.g.terminal_color_5  = c_strong[1]
  vim.g.terminal_color_6  = c_salient[1]
  vim.g.terminal_color_7  = c_faded[1]
  vim.g.terminal_color_8  = c_faded[1]
  vim.g.terminal_color_9  = c_critical[1]
  vim.g.terminal_color_10 = c_pine[1]
  vim.g.terminal_color_11 = c_popout[1]
  vim.g.terminal_color_12 = c_faded[1]
  vim.g.terminal_color_13 = c_strong[1]
  vim.g.terminal_color_14 = c_salient[1]
  vim.g.terminal_color_15 = c_faded[1]
end
-- stylua: ignore end
-- }}}

-- Highlight groups {{{1
local hlgroups = {
  -- Common {{{2
  ColorColumn = { bg = c_highlight },
  Conceal = { fg = c_foreground },
  CurSearch = { link = 'IncSearch' },
  Cursor = { fg = c_subtle, bg = c_foreground },
  CursorColumn = { bg = c_highlight },
  CursorIM = { link = 'Cursor' },
  CursorLine = { bg = c_highlight },
  CursorLineNr = { fg = c_faded, bold = true },
  DebugPC = { bg = c_subtle },
  DiffAdd = { bg = c_grass },
  DiffAdded = { fg = c_pine },
  DiffChange = { bg = c_lavender },
  DiffDelete = { fg = c_faint },
  DiffText = { fg = c_strong, bg = c_violet },
  Directory = { fg = c_faded },
  EndOfBuffer = { fg = c_subtle },
  ErrorMsg = { fg = c_popout },
  FloatBorder = { fg = c_foreground, bg = c_subtle },
  FloatFooter = { link = 'FloatTitle' },
  FloatShadow = { bg = c_black, blend = 70 },
  FloatShadowThrough = { link = 'None' },
  FloatTitle = { fg = c_foreground, bg = c_subtle, bold = true },
  FoldColumn = { fg = c_faded },
  Folded = { fg = c_faded, bg = c_highlight },
  HealthSuccess = { fg = c_faded },
  IncSearch = { fg = c_background, bg = c_popout, bold = true },
  LineNr = { fg = c_faint },
  MatchParen = { bg = c_subtle, bold = true },
  ModeMsg = { fg = c_foreground },
  MoreMsg = { fg = c_foreground },
  MsgArea = { link = 'Normal' },
  MsgSeparator = { link = 'StatusLine' },
  NonText = { fg = c_faded },
  Normal = { fg = c_foreground, bg = c_background },
  NormalFloat = { fg = c_foreground, bg = c_subtle },
  NormalNC = { link = 'Normal' },
  Pmenu = { fg = c_foreground, bg = c_highlight },
  PmenuExtra = { fg = c_faded },
  PmenuSbar = { bg = c_subtle },
  PmenuSel = { bg = c_subtle, bold = true },
  PmenuThumb = { bg = c_popout },
  Question = { fg = c_foreground },
  QuickFixLine = { bg = c_grass },
  Search = { bg = c_subtle },
  SignColumn = { fg = c_faded },
  SpecialKey = { fg = c_salient },
  SpellBad = { underdashed = true },
  SpellCap = { link = 'SpellBad' },
  SpellLocal = { link = 'SpellBad' },
  SpellRare = { link = 'SpellBad' },
  StatusLine = { fg = c_foreground, bg = c_subtle },
  StatusLineNC = { fg = c_faded, bg = c_subtle },
  Substitute = { link = 'Search' },
  TabLine = { link = 'StatusLine' },
  TabLineFill = { fg = c_foreground, bg = c_subtle },
  TabLineSel = { fg = c_strong, bg = c_shaded, bold = true },
  TermCursor = { fg = c_subtle, bg = c_popout },
  Title = { fg = c_foreground, bold = true },
  VertSplit = { fg = c_subtle },
  Visual = { bg = c_subtle },
  VisualNOS = { link = 'Visual' },
  WarningMsg = { fg = c_popout },
  Whitespace = { link = 'NonText' },
  WildMenu = { link = 'PmenuSel' },
  WinBar = { fg = c_foreground, bg = c_highlight },
  WinBarNC = { fg = c_faded, bg = c_highlight },
  WinSeparator = { link = 'VertSplit' },
  lCursor = { link = 'Cursor' },
  -- }}}2

  -- Syntax {{{2
  Comment = { fg = c_faint },
  Constant = { fg = c_faded },
  String = { fg = c_popout },
  DocumentKeyword = { link = 'Keyword' },
  Character = { fg = c_critical },
  Number = { fg = c_faded },
  Boolean = { link = 'Constant' },
  Array = { fg = c_critical },
  Float = { link = 'Number' },
  Identifier = { fg = c_foreground },
  Builtin = { fg = c_foreground },
  Field = { link = 'None' },
  Enum = { fg = c_faded },
  Namespace = { fg = c_foreground },
  Function = { fg = c_strong, bold = true },
  Statement = { fg = c_salient },
  Specifier = { fg = c_salient },
  Object = { fg = c_salient },
  Conditional = { fg = c_salient },
  Repeat = { fg = c_salient },
  Label = { fg = c_salient },
  Operator = { fg = c_salient },
  Keyword = { fg = c_salient },
  Exception = { fg = c_salient },
  PreProc = { fg = c_salient },
  PreCondit = { link = 'PreProc' },
  Include = { link = 'PreProc' },
  Define = { link = 'PreProc' },
  Macro = { fg = c_faded },
  Type = { fg = c_salient },
  StorageClass = { link = 'Keyword' },
  Structure = { link = 'Type' },
  Typedef = { fg = c_salient },
  Special = { fg = c_salient },
  SpecialChar = { link = 'Special' },
  Tag = { fg = c_pine, underline = true },
  Delimiter = { fg = c_foreground },
  Bracket = { fg = c_foreground },
  SpecialComment = { link = 'SpecialChar' },
  Debug = { link = 'Special' },
  Underlined = { underline = true },
  Ignore = { fg = c_subtle },
  Error = { fg = c_popout },
  Todo = { fg = c_background, bg = c_popout, bold = true },
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
  ['@string.escape'] = { fg = c_critical },
  ['@string.regexp'] = { fg = c_popout },
  ['@string.yaml'] = { link = 'Normal' },
  ['@character'] = { link = 'Character' },
  ['@character.special'] = { link = 'SpecialChar' },
  ['@boolean'] = { link = 'Boolean' },
  ['@number'] = { link = 'Number' },
  ['@number.float'] = { link = 'Float' },
  ['@function'] = { link = 'Function' },
  ['@function.call'] = { link = 'Function' },
  ['@function.builtin'] = { link = 'Function' },
  ['@function.macro'] = { link = 'Macro' },
  ['@function.method'] = { link = 'Function' },
  ['@function.method.call'] = { link = 'Function' },
  ['@constructor'] = { link = 'Function' },
  ['@constructor.lua'] = { link = 'None' },
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
  ['@type.builtin'] = { link = 'Type' },
  ['@type.qualifier'] = { link = 'Type' },
  ['@type.definition'] = { link = 'Typedef' },
  ['@keyword.storage'] = { link = 'StorageClass' },
  ['@attribute'] = { link = 'Label' },
  ['@variable'] = { link = 'Identifier' },
  ['@variable.builtin'] = { link = 'Builtin' },
  ['@constant'] = { link = 'Constant' },
  ['@constant.builtin'] = { link = 'Constant' },
  ['@constant.macro'] = { link = 'Macro' },
  ['@module'] = { link = 'Namespace' },
  ['@markup.heading'] = { link = 'Title' },
  ['@markup.raw'] = { link = 'String' },
  ['@markup.link.url'] = { link = 'htmlLink' },
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
  ['@markup.heading.1.delimiter.vimdoc'] = { link = 'helpSectionDelim' },
  ['@markup.heading.2.delimiter.vimdoc'] = { link = 'helpSectionDelim' },
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
  ['@markup.emphasis'] = { fg = c_popout, bold = true },
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
  ['@lsp.typemod.function.defaultLibrary'] = { link = 'Function' },
  ['@lsp.typemod.variable.defaultLibrary'] = { link = 'Builtin' },
  ['@lsp.typemod.variable.global'] = { link = 'Identifier' },
  -- }}}2

  -- LSP {{{2
  LspReferenceText = { link = 'Visual' },
  LspReferenceRead = { link = 'LspReferenceText' },
  LspReferenceWrite = { link = 'LspReferenceText' },
  LspSignatureActiveParameter = { link = 'IncSearch' },
  LspInfoBorder = { link = 'FloatBorder' },
  -- }}}2

  -- Diagnostic {{{2
  DiagnosticOk = { fg = c_pine },
  DiagnosticError = { fg = c_critical },
  DiagnosticWarn = { fg = c_popout },
  DiagnosticInfo = { fg = c_salient },
  DiagnosticHint = { fg = c_foreground },
  DiagnosticVirtualTextOk = { fg = c_faded, bg = c_highlight },
  DiagnosticVirtualTextError = { fg = c_critical, bg = c_highlight },
  DiagnosticVirtualTextWarn = { fg = c_popout, bg = c_highlight },
  DiagnosticVirtualTextInfo = { fg = c_salient, bg = c_highlight },
  DiagnosticVirtualTextHint = { fg = c_foreground, bg = c_highlight },
  DiagnosticUnderlineOk = { underline = true, sp = c_faded },
  DiagnosticUnderlineError = { undercurl = true, sp = c_critical },
  DiagnosticUnderlineWarn = { undercurl = true, sp = c_popout },
  DiagnosticUnderlineInfo = { undercurl = true, sp = c_salient },
  DiagnosticUnderlineHint = { undercurl = true, sp = c_subtle },
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
    fg = c_faint,
    sp = c_foreground,
    undercurl = true,
  },
  -- }}}2

  -- Filetype {{{2
  -- HTML
  htmlArg = { fg = c_foreground },
  htmlBold = { bold = true },
  htmlBoldItalic = { bold = true, italic = true },
  htmlTag = { fg = c_foreground },
  htmlTagName = { link = 'Tag' },
  htmlSpecialTagName = { fg = c_strong },
  htmlEndTag = { fg = c_strong },
  htmlH1 = { fg = c_salient, bold = true },
  htmlH2 = { fg = c_salient, bold = true },
  htmlH3 = { fg = c_salient, bold = true },
  htmlH4 = { fg = c_salient, bold = true },
  htmlH5 = { fg = c_salient, bold = true },
  htmlH6 = { fg = c_salient, bold = true },
  htmlItalic = { italic = true },
  htmlLink = { fg = c_faded, underline = true },
  htmlSpecialChar = { link = 'SpecialChar' },
  htmlTitle = { fg = c_foreground },

  -- Json
  jsonKeyword = { link = 'Keyword' },
  jsonBraces = { fg = c_foreground },

  -- Markdown
  markdownBold = { bold = true },
  markdownBoldItalic = { bold = true, italic = true },
  markdownCode = { fg = c_popout },
  markdownError = { link = 'None' },
  markdownEscape = { link = 'None' },
  markdownListMarker = { fg = c_critical },
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
  gitHash = { fg = c_faded },

  -- Checkhealth
  helpHeader = { fg = c_foreground, bold = true },
  helpSectionDelim = { fg = c_faded, bold = true },
  helpCommand = { fg = c_salient },
  helpBacktick = { fg = c_salient },

  -- Man
  manBold = { fg = c_salient, bold = true },
  manItalic = { fg = c_faded, italic = true },
  manOptionDesc = { fg = c_faded },
  manReference = { link = 'htmlLink' },
  manSectionHeading = { link = 'manBold' },
  manUnderline = { fg = c_popout },
  -- }}}2

  -- Plugins {{{2
  -- netrw
  netrwClassify = { link = 'Directory' },

  -- gitsigns
  GitSignsAdd = { fg = c_pine },
  GitSignsAddInline = { fg = c_pine },
  GitSignsAddLnInline = { fg = c_pine },
  GitSignsAddPreview = { fg = c_pine },
  GitSignsChange = { fg = c_violet },
  GitSignsChangeInline = { fg = c_violet },
  GitSignsChangeLnInline = { fg = c_violet },
  GitSignsCurrentLineBlame = { fg = c_violet },
  GitSignsDelete = { fg = c_popout },
  GitSignsDeleteInline = { fg = c_popout },
  GitSignsDeleteLnInline = { fg = c_popout },
  GitSignsDeletePreview = { fg = c_popout },
  GitSignsDeleteVirtLnInLine = { fg = c_popout },
  GitSignsUntracked = { fg = c_subtle },
  GitSignsUntrackedLn = { fg = c_subtle },
  GitSignsUntrackedNr = { fg = c_subtle },

  -- fugitive
  fugitiveHash = { link = 'gitHash' },
  fugitiveHeader = { link = 'Title' },
  fugitiveHeading = { fg = c_critical, bold = true },
  fugitiveHelpTag = { fg = c_critical },
  fugitiveSymbolicRef = { fg = c_strong },
  fugitiveStagedModifier = { fg = c_pine, bold = true },
  fugitiveUnstagedModifier = { fg = c_salient, bold = true },
  fugitiveUntrackedModifier = { fg = c_faded, bold = true },
  fugitiveStagedHeading = { fg = c_pine, bold = true },
  fugitiveUnstagedHeading = { fg = c_salient, bold = true },
  fugitiveUntrackedHeading = { fg = c_faded, bold = true },

  -- telescope
  TelescopeNormal = { fg = c_faded, bg = c_subtle },
  TelescopePromptNormal = { bg = c_highlight },
  TelescopeTitle = { fg = c_subtle, bg = c_faded, bold = true },
  TelescopeBorder = { fg = c_foreground, bg = c_subtle },
  TelescopePromptBorder = { fg = c_foreground, bg = c_highlight },
  TelescopePreviewLine = { bg = c_shaded },
  TelescopePreviewMatch = { fg = c_salient, bold = true },
  TelescopeMatching = { fg = c_salient, bold = true },
  TelescopePromptCounter = { link = 'Comment' },
  TelescopePromptPrefix = { fg = c_critical },
  TelescopeSelection = { fg = c_foreground, bg = c_shaded },
  TelescopeMultiIcon = { fg = c_salient, bold = true },
  TelescopeMultiSelection = { bg = c_shaded, bold = true },
  TelescopeSelectionCaret = { fg = c_critical, bg = c_shaded },

  -- nvim-dap-ui
  DapUIBreakpointsCurrentLine = { link = 'CursorLineNr' },
  DapUIBreakpointsInfo = { fg = c_faded },
  DapUIBreakpointsPath = { link = 'Directory' },
  DapUICurrentFrameName = { fg = c_faded, bold = true },
  DapUIDecoration = { fg = c_strong },
  DapUIFloatBorder = { link = 'FloatBorder' },
  DapUILineNumber = { link = 'LineNr' },
  DapUIModifiedValue = { fg = c_salient, bold = true },
  DapUINormalFloat = { link = 'NormalFloat' },
  DapUIPlayPause = { fg = c_faded },
  DapUIPlayPauseNC = { fg = c_faded },
  DapUIRestart = { fg = c_faded },
  DapUIRestartNC = { fg = c_faded },
  DapUIScope = { fg = c_critical },
  DapUISource = { link = 'Directory' },
  DapUIStepBack = { fg = c_salient },
  DapUIStepBackRC = { fg = c_salient },
  DapUIStepInto = { fg = c_salient },
  DapUIStepIntoRC = { fg = c_salient },
  DapUIStepOut = { fg = c_salient },
  DapUIStepOutRC = { fg = c_salient },
  DapUIStepOver = { fg = c_salient },
  DapUIStepOverRC = { fg = c_salient },
  DapUIStop = { fg = c_popout },
  DapUIStopNC = { fg = c_popout },
  DapUIStoppedThread = { fg = c_faded },
  DapUIThread = { fg = c_foreground },
  DapUIType = { link = 'Type' },
  DapUIValue = { link = 'Number' },
  DapUIVariable = { link = 'Identifier' },
  DapUIWatchesEmpty = { link = 'Comment' },
  DapUIWatchesError = { link = 'Error' },
  DapUIWatchesValue = { fg = c_critical },

  -- vimtex
  texArg = { fg = c_foreground },
  texArgNew = { fg = c_salient },
  texCmd = { fg = c_strong },
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
  texDelim = { fg = c_foreground },
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
  texLength = { fg = c_salient },
  texLigature = { fg = c_foreground },
  texOpt = { fg = c_foreground },
  texOptEqual = { fg = c_critical },
  texOptSep = { fg = c_critical },
  texParm = { fg = c_foreground },
  texRefArg = { fg = c_salient },
  texRefOpt = { link = 'texOpt' },
  texSymbol = { fg = c_critical },
  texTitleArg = { link = 'Title' },
  texVerbZone = { fg = c_foreground },
  texZone = { fg = c_popout },
  texMathArg = { fg = c_foreground },
  texMathCmd = { link = 'texCmd' },
  texMathSub = { fg = c_foreground },
  texMathOper = { fg = c_critical },
  texMathZone = { fg = c_strong },
  texMathDelim = { fg = c_foreground },
  texMathError = { link = 'Error' },
  texMathGroup = { fg = c_foreground },
  texMathSuper = { fg = c_foreground },
  texMathSymbol = { fg = c_strong },
  texMathZoneLD = { fg = c_foreground },
  texMathZoneLI = { fg = c_foreground },
  texMathZoneTD = { fg = c_foreground },
  texMathZoneTI = { fg = c_foreground },
  texMathCmdText = { link = 'texCmd' },
  texMathZoneEnv = { fg = c_foreground },
  texMathArrayArg = { fg = c_strong },
  texMathCmdStyle = { link = 'texCmd' },
  texMathDelimMod = { fg = c_foreground },
  texMathSuperSub = { fg = c_foreground },
  texMathDelimZone = { fg = c_foreground },
  texMathStyleBold = { fg = c_foreground, bold = true },
  texMathStyleItal = { fg = c_foreground, italic = true },
  texMathEnvArgName = { fg = c_salient },
  texMathErrorDelim = { link = 'Error' },
  texMathDelimZoneLD = { fg = c_faded },
  texMathDelimZoneLI = { fg = c_faded },
  texMathDelimZoneTD = { fg = c_faded },
  texMathDelimZoneTI = { fg = c_faded },
  texMathZoneEnsured = { fg = c_foreground },
  texMathCmdStyleBold = { fg = c_strong, bold = true },
  texMathCmdStyleItal = { fg = c_strong, italic = true },
  texMathStyleConcArg = { fg = c_foreground },
  texMathZoneEnvStarred = { fg = c_foreground },

  -- lazy.nvim
  LazyDir = { link = 'Directory' },
  LazyUrl = { link = 'htmlLink' },
  LazySpecial = { link = 'Special' },
  LazyCommit = { fg = c_faded },
  LazyReasonFt = { fg = c_salient },
  LazyReasonCmd = { fg = c_salient },
  LazyReasonPlugin = { fg = c_salient },
  LazyReasonSource = { fg = c_salient },
  LazyReasonRuntime = { fg = c_salient },
  LazyReasonEvent = { fg = c_salient },
  LazyReasonKeys = { fg = c_faded },
  LazyButton = { bg = c_subtle },
  LazyButtonActive = { bg = c_shaded, bold = true },
  LazyH1 = { fg = c_subtle, bg = c_faint, bold = true },

  -- copilot.lua
  CopilotSuggestion = { fg = c_faint, italic = true },
  CopilotAnnotation = { fg = c_faint, italic = true },

  -- statusline
  StatusLineDiagnosticError = { fg = c_critical, bg = c_subtle },
  StatusLineDiagnosticHint = { fg = c_foreground, bg = c_subtle },
  StatusLineDiagnosticInfo = { fg = c_salient, bg = c_subtle },
  StatusLineDiagnosticWarn = { fg = c_popout, bg = c_subtle },
  StatusLineGitAdded = { fg = c_pine, bg = c_subtle },
  StatusLineGitChanged = { fg = c_faded, bg = c_subtle },
  StatusLineGitRemoved = { fg = c_popout, bg = c_subtle },
  StatusLineHeader = { fg = c_background, bg = c_faded },
  StatusLineHeaderModified = { fg = c_background, bg = c_popout },

  -- winbar
  WinBarIconUIIndicator = { fg = c_salient },
  WinBarMenuNormalFloat = { fg = c_foreground, bg = c_highlight },
  WinBarMenuHoverIcon = { fg = c_salient, bg = c_faint },
  WinBarMenuHoverEntry = { fg = c_foreground, bg = c_subtle },
  WinBarMenuCurrentContext = { fg = c_foreground, bg = c_subtle },

  -- }}}2
}
-- }}}1

-- Highlight group overrides {{{1
if vim.go.bg == 'dark' then
  hlgroups.CmpItemAbbrMatch = { fg = c_critical }
  hlgroups.DiffText = { fg = c_background, bg = c_faded }
  hlgroups.TelescopePreviewMatch = { fg = c_critical, bold = true }
  hlgroups.TelescopeMatching = { fg = c_critical, bold = true }
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
