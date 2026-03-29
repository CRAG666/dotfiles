vim.cmd.hi('clear')
vim.g.colors_name = 'vistaverda'
-- Palette {{{
-- stylua: ignore start
-- Base: fondo #add4a0 (verde salvia suave, ideal para protección visual)
-- Todos los colores están calibrados para bajo contraste sin perder legibilidad

local c_bg0          -- fondo principal
local c_bg1          -- fondo alternativo ligero
local c_bg2          -- cursorline / colorcolumn
local c_bg3          -- pmenu / statusline
local c_bg4          -- selección / match
local c_bg5          -- separadores / nontext oscuro

local c_fg0          -- texto principal
local c_fg1          -- texto secundario
local c_fg2          -- texto tenue

local c_green0       -- verde comentarios
local c_green1       -- verde strings
local c_green2       -- verde funciones (más profundo)

local c_teal         -- teal para tipos/especiales
local c_blue0        -- azul tranquilo para keywords
local c_blue1        -- azul claro para funciones/dirs

local c_violet       -- violeta suave para statements
local c_aqua         -- aqua para constructores

local c_orange0      -- naranja cálido constantes
local c_orange1      -- naranja oscuro números

local c_red          -- rojo apagado para errores/ops
local c_yellow       -- amarillo tierra para warnings
local c_pink         -- rosa suave para números/macros

local c_ash          -- gris para comentarios / info discreta
local c_gray0        -- gris medio
local c_gray1        -- gris más oscuro
local c_gray2        -- gris para signcolumn

-- Colores diff / winter (tintes sobre el fondo verde)
local c_winterGreen
local c_winterBlue
local c_winterRed
local c_winterYellow

if vim.go.bg == 'dark' then
  -- Versión oscura: fondo derivado del verde (#add4a0) muy oscurecido
  c_bg0        = { '#1a211a', 234 }
  c_bg1        = { '#202820', 235 }
  c_bg2        = { '#263026', 236 }
  c_bg3        = { '#2d382d', 237 }
  c_bg4        = { '#3a463a', 238 }
  c_bg5        = { '#536053', 240 }

  c_fg0        = { '#d0dcc8', 251 }
  c_fg1        = { '#b8c8b0', 249 }
  c_fg2        = { '#9aab94', 247 }

  c_green0     = { '#7aab72', 107 }
  c_green1     = { '#82a870', 107 }
  c_green2     = { '#6a9460', 101 }

  c_teal       = { '#6aaa9a', 72  }
  c_blue0      = { '#6a94a8', 67  }
  c_blue1      = { '#82aab8', 109 }

  c_violet     = { '#8a8aaa', 103 }
  c_aqua       = { '#7aaaa8', 72  }

  c_orange0    = { '#b89a6a', 137 }
  c_orange1    = { '#c8a870', 137 }

  c_red        = { '#b07868', 131 }
  c_yellow     = { '#c8b070', 179 }
  c_pink       = { '#a888a0', 139 }

  c_ash        = { '#708070', 242 }
  c_gray0      = { '#8a9a88', 244 }
  c_gray1      = { '#7a8a78', 243 }
  c_gray2      = { '#6a7868', 242 }

  c_winterGreen  = { '#243224', 236 }
  c_winterBlue   = { '#223040', 237 }
  c_winterRed    = { '#402828', 52  }
  c_winterYellow = { '#3a3420', 236 }
else
  -- Versión clara: fondo exacto #add4a0
  c_bg0        = { '#add4a0', 151 }   -- fondo principal (el color pedido)
  c_bg1        = { '#a4cc98', 150 }   -- fondo alternativo
  c_bg2        = { '#9fc895', 150 }   -- cursorline
  c_bg3        = { '#96be8c', 149 }   -- statusline / pmenu
  c_bg4        = { '#88b07e', 107 }   -- selección visual
  c_bg5        = { '#6a9060', 65  }   -- separadores

  c_fg0        = { '#222222', 234 }   -- texto principal
  c_fg1        = { '#1e2e1c', 235 }   -- texto secundario
  c_fg2        = { '#4a6044', 239 }   -- texto tenue

  c_green0     = { '#3a6832', 28  }   -- comentarios
  c_green1     = { '#2e5a28', 22  }   -- strings
  c_green2     = { '#486040', 65  }   -- verde medio

  c_teal       = { '#206860', 23  }   -- tipos / speciales
  c_blue0      = { '#2a5872', 24  }   -- keywords
  c_blue1      = { '#1e4a60', 23  }   -- funciones / dirs

  c_violet     = { '#4a3870', 54  }   -- statements
  c_aqua       = { '#2a6868', 23  }   -- constructores

  c_orange0    = { '#7a4a18', 130 }   -- constantes
  c_orange1    = { '#8a5820', 130 }   -- números

  c_red        = { '#8a2820', 88  }   -- errores / operadores (rojo oscuro suave)
  c_yellow     = { '#786018', 58  }   -- warnings
  c_pink       = { '#6a3868', 90  }   -- macros / números especiales

  c_ash        = { '#507848', 65  }   -- comentarios / info discreta
  c_gray0      = { '#5a7052', 66  }   -- gris-verde medio
  c_gray1      = { '#4a6044', 65  }   -- gris-verde oscuro
  c_gray2      = { '#3a5038', 64  }   -- sigcolumn

  c_winterGreen  = { '#94cc88', 150 }
  c_winterBlue   = { '#90bcd0', 110 }
  c_winterRed    = { '#d8a8a0', 174 }
  c_winterYellow = { '#d0c890', 186 }
end
-- stylua: ignore end
-- }}}
-- Terminal colors {{{
-- stylua: ignore start
if vim.go.bg == 'dark' then
  vim.g.terminal_color_0  = c_bg0[1]
  vim.g.terminal_color_1  = c_red[1]
  vim.g.terminal_color_2  = c_green1[1]
  vim.g.terminal_color_3  = c_yellow[1]
  vim.g.terminal_color_4  = c_blue1[1]
  vim.g.terminal_color_5  = c_pink[1]
  vim.g.terminal_color_6  = c_aqua[1]
  vim.g.terminal_color_7  = c_fg1[1]
  vim.g.terminal_color_8  = c_bg4[1]
  vim.g.terminal_color_9  = c_red[1]
  vim.g.terminal_color_10 = c_green0[1]
  vim.g.terminal_color_11 = c_orange0[1]
  vim.g.terminal_color_12 = c_blue0[1]
  vim.g.terminal_color_13 = c_violet[1]
  vim.g.terminal_color_14 = c_teal[1]
  vim.g.terminal_color_15 = c_fg0[1]
  vim.g.terminal_color_16 = c_orange0[1]
  vim.g.terminal_color_17 = c_orange1[1]
else
  vim.g.terminal_color_0  = c_bg1[1]
  vim.g.terminal_color_1  = c_red[1]
  vim.g.terminal_color_2  = c_green1[1]
  vim.g.terminal_color_3  = c_yellow[1]
  vim.g.terminal_color_4  = c_blue1[1]
  vim.g.terminal_color_5  = c_violet[1]
  vim.g.terminal_color_6  = c_aqua[1]
  vim.g.terminal_color_7  = c_fg0[1]
  vim.g.terminal_color_8  = c_bg3[1]
  vim.g.terminal_color_9  = c_red[1]
  vim.g.terminal_color_10 = c_green0[1]
  vim.g.terminal_color_11 = c_orange1[1]
  vim.g.terminal_color_12 = c_blue0[1]
  vim.g.terminal_color_13 = c_pink[1]
  vim.g.terminal_color_14 = c_teal[1]
  vim.g.terminal_color_15 = c_bg5[1]
  vim.g.terminal_color_16 = c_orange0[1]
  vim.g.terminal_color_17 = c_orange1[1]
end
-- stylua: ignore end
--- }}}
-- Highlight groups {{{1
local hlgroups = {
  -- UI {{{2
  ColorColumn = { bg = c_bg2 },
  Conceal = { bold = true, fg = c_gray2 },
  CurSearch = { link = 'IncSearch' },
  Cursor = { bg = c_fg0, fg = c_bg0 },
  CursorColumn = { link = 'CursorLine' },
  CursorIM = { link = 'Cursor' },
  CursorLine = { bg = c_bg2 },
  CursorLineNr = { fg = c_gray0, bold = true },
  DebugPC = { bg = c_winterRed },
  DiffAdd = { bg = c_winterGreen },
  DiffAdded = { fg = c_green0 },
  DiffChange = { bg = c_winterBlue },
  DiffChanged = { fg = c_yellow },
  DiffDelete = { fg = c_bg4 },
  DiffDeleted = { fg = c_red },
  DiffNewFile = { fg = c_green0 },
  DiffOldFile = { fg = c_red },
  DiffRemoved = { fg = c_red },
  DiffText = { bg = c_bg5 },
  Directory = { fg = c_blue1 },
  EndOfBuffer = { fg = c_bg1 },
  ErrorMsg = { fg = c_red },
  FloatBorder = { bg = c_bg0, fg = c_bg5 },
  FloatFooter = { bg = c_bg0, fg = c_bg5 },
  FloatTitle = { bg = c_bg0, fg = c_gray2, bold = true },
  FoldColumn = { fg = c_bg5 },
  Folded = { bg = c_bg2, fg = c_ash },
  Ignore = { link = 'NonText' },
  IncSearch = { bg = c_yellow, fg = c_bg0 },
  LineNr = { fg = c_bg5 },
  MatchParen = { bg = c_bg4 },
  ModeMsg = { fg = c_green2, bold = true },
  MoreMsg = { fg = c_blue0 },
  MsgArea = { fg = c_fg1 },
  MsgSeparator = { bg = c_bg0 },
  NonText = { fg = c_bg5 },
  Normal = { bg = c_bg0, fg = c_fg0 },
  NormalFloat = { bg = c_bg1, fg = c_fg1 },
  NormalNC = { link = 'Normal' },
  Pmenu = { bg = c_bg3, fg = c_fg1 },
  PmenuExtra = { fg = c_ash },
  PmenuSbar = { bg = c_bg4 },
  PmenuSel = { bg = c_bg4, fg = 'NONE' },
  PmenuThumb = { bg = c_bg5 },
  Question = { link = 'MoreMsg' },
  QuickFixLine = { bg = c_winterGreen },
  Search = { bg = c_bg3 },
  SignColumn = { fg = c_gray2 },
  SpellBad = { underdashed = true },
  SpellCap = { underdashed = true },
  SpellLocal = { underdashed = true },
  SpellRare = { underdashed = true },
  StatusLine = { bg = c_bg3, fg = c_fg1 },
  StatusLineNC = { bg = c_bg2, fg = c_bg5 },
  Substitute = { bg = c_violet, fg = c_bg0 },
  TabLine = { link = 'StatusLineNC' },
  TabLineFill = { link = 'Normal' },
  TabLineSel = { link = 'StatusLine' },
  TermCursor = { fg = c_bg0, bg = c_teal },
  Title = { bold = true, fg = c_blue1 },
  Underlined = { fg = c_teal, underline = true },
  VertSplit = { link = 'WinSeparator' },
  Visual = { bg = c_bg4 },
  VisualNOS = { link = 'Visual' },
  WarningMsg = { fg = c_yellow },
  Whitespace = { fg = c_bg4 },
  WildMenu = { link = 'Pmenu' },
  WinBar = { bg = c_bg1, fg = c_fg1 },
  WinBarNC = { bg = c_bg1, fg = c_bg5 },
  WinSeparator = { fg = c_bg4 },
  lCursor = { link = 'Cursor' },
  -- }}}2
  -- Syntax {{{2
  Boolean = { fg = c_orange0, bold = true },
  Character = { link = 'String' },
  Comment = { fg = c_ash, italic = true },
  Constant = { fg = c_orange0 },
  Delimiter = { fg = c_gray1 },
  Error = { fg = c_red },
  Exception = { fg = c_red },
  Float = { link = 'Number' },
  Function = { fg = c_blue1 },
  Identifier = { fg = c_fg0 },
  Keyword = { fg = c_violet },
  Number = { fg = c_pink },
  Operator = { fg = c_teal },
  PreProc = { fg = c_red },
  Special = { fg = c_teal },
  SpecialKey = { fg = c_gray2 },
  Statement = { fg = c_violet },
  String = { fg = c_green1 },
  Todo = { fg = c_bg0, bg = c_blue0, bold = true },
  Type = { fg = c_aqua },
  -- }}}2
  -- Treesitter syntax {{{2
  ['@attribute'] = { link = 'Constant' },
  ['@constructor'] = { fg = c_teal },
  ['@constructor.lua'] = { fg = c_violet },
  ['@keyword.exception'] = { bold = true, fg = c_red },
  ['@keyword.import'] = { link = 'PreProc' },
  ['@keyword.luap'] = { link = '@string.regexp' },
  ['@keyword.operator'] = { bold = true, fg = c_teal },
  ['@keyword.return'] = { fg = c_red },
  ['@module'] = { fg = c_orange0 },
  ['@operator'] = { link = 'Operator' },
  ['@property.yaml'] = { link = 'Special' },
  ['@punctuation.bracket'] = { fg = c_gray1 },
  ['@punctuation.delimiter'] = { fg = c_gray1 },
  ['@markup.list'] = { fg = c_teal },
  ['@string.escape'] = { fg = c_orange0 },
  ['@string.regexp'] = { fg = c_orange0 },
  ['@string.yaml'] = { link = 'Normal' },
  ['@markup.link.label.symbol'] = { fg = c_fg0 },
  ['@tag.attribute'] = { fg = c_fg0 },
  ['@tag.delimiter'] = { fg = c_gray1 },
  ['@comment.error'] = { bg = c_red, fg = c_bg0, bold = true },
  ['@diff.delta'] = { link = 'DiffChanged' },
  ['@diff.minus'] = { link = 'DiffRemoved' },
  ['@diff.plus'] = { link = 'DiffAdded' },
  ['@markup.emphasis'] = { italic = true },
  ['@markup.environment'] = { link = 'Keyword' },
  ['@markup.environment.name'] = { link = 'String' },
  ['@markup.raw'] = { link = 'String' },
  ['@comment.note'] = { bg = c_teal, fg = c_bg0, bold = true },
  ['@markup.quote'] = { link = '@variable.parameter' },
  ['@markup.strong'] = { bold = true },
  ['@markup.heading'] = { link = 'Function' },
  ['@markup.heading.1.markdown'] = { fg = c_blue0, bold = true },
  ['@markup.heading.2.markdown'] = { fg = c_blue1, bold = true },
  ['@markup.heading.3.markdown'] = { fg = c_teal, bold = true },
  ['@markup.heading.4.markdown'] = { fg = c_green2, bold = true },
  ['@markup.heading.5.markdown'] = { fg = c_violet, bold = true },
  ['@markup.heading.6.markdown'] = { fg = c_aqua, bold = true },
  ['@markup.heading.1.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.2.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.3.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.4.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.5.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.6.marker.markdown'] = { link = 'Delimiter' },
  ['@markup.heading.1.delimiter.vimdoc'] = { link = 'helpSectionDelim' },
  ['@markup.heading.2.delimiter.vimdoc'] = { link = 'helpSectionDelim' },
  ['@comment.todo.checked'] = { fg = c_ash },
  ['@comment.todo.unchecked'] = { fg = c_red },
  ['@markup.link.label.markdown_inline'] = { link = 'htmlLink' },
  ['@markup.link.url.markdown_inline'] = { link = 'htmlString' },
  ['@comment.warning'] = { bg = c_yellow, fg = c_bg0, bold = true },
  ['@variable'] = { fg = c_fg0 },
  ['@variable.builtin'] = { fg = c_red },
  -- }}}
  -- LSP semantic {{{2
  ['@lsp.mod.readonly'] = { link = 'Constant' },
  ['@lsp.mod.typeHint'] = { link = 'Type' },
  ['@lsp.type.builtinConstant'] = { link = '@constant.builtin' },
  ['@lsp.type.comment'] = { fg = 'NONE' },
  ['@lsp.type.macro'] = { fg = c_pink },
  ['@lsp.type.magicFunction'] = { link = '@function.builtin' },
  ['@lsp.type.method'] = { link = '@function.method' },
  ['@lsp.type.namespace'] = { link = '@module' },
  ['@lsp.type.parameter'] = { link = '@variable.parameter' },
  ['@lsp.type.selfParameter'] = { link = '@variable.builtin' },
  ['@lsp.type.variable'] = { fg = 'NONE' },
  ['@lsp.typemod.function.builtin'] = { link = '@function.builtin' },
  ['@lsp.typemod.function.defaultLibrary'] = { link = '@function.builtin' },
  ['@lsp.typemod.function.readonly'] = { bold = true, fg = c_blue1 },
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
  LspCodeLens = { fg = c_ash },
  LspInfoBorder = { link = 'FloatBorder' },
  LspReferenceRead = { link = 'LspReferenceText' },
  LspReferenceText = { bg = c_winterYellow },
  LspReferenceWrite = { bg = c_winterYellow, underline = true },
  LspSignatureActiveParameter = { fg = c_yellow },
  -- }}}
  -- Diagnostic {{{2
  DiagnosticError = { fg = c_red },
  DiagnosticHint = { fg = c_aqua },
  DiagnosticInfo = { fg = c_blue1 },
  DiagnosticOk = { fg = c_green1 },
  DiagnosticWarn = { fg = c_yellow },
  DiagnosticSignError = { fg = c_red },
  DiagnosticSignHint = { fg = c_aqua },
  DiagnosticSignInfo = { fg = c_blue1 },
  DiagnosticSignWarn = { fg = c_yellow },
  DiagnosticUnderlineError = { sp = c_red, undercurl = true },
  DiagnosticUnderlineHint = { sp = c_aqua, undercurl = true },
  DiagnosticUnderlineInfo = { sp = c_blue1, undercurl = true },
  DiagnosticUnderlineWarn = { sp = c_yellow, undercurl = true },
  DiagnosticVirtualTextError = { bg = c_winterRed, fg = c_red },
  DiagnosticVirtualTextHint = { bg = c_winterGreen, fg = c_aqua },
  DiagnosticVirtualTextInfo = { bg = c_winterBlue, fg = c_blue1 },
  DiagnosticVirtualTextWarn = { bg = c_winterYellow, fg = c_yellow },
  DiagnosticUnnecessary = { fg = c_ash, sp = c_aqua, undercurl = true },
  -- }}}
  -- FileType {{{2
  -- Git
  gitHash = { fg = c_ash },
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
  htmlH1 = { fg = c_blue0, bold = true },
  htmlH2 = { fg = c_blue1, bold = true },
  htmlH3 = { fg = c_teal, bold = true },
  htmlH4 = { fg = c_green2, bold = true },
  htmlH5 = { fg = c_violet, bold = true },
  htmlH6 = { fg = c_aqua, bold = true },
  htmlItalic = { italic = true },
  htmlLink = { fg = c_blue0, underline = true },
  htmlSpecialChar = { link = 'SpecialChar' },
  htmlSpecialTagName = { fg = c_violet },
  htmlString = { link = 'String' },
  htmlTagName = { link = 'Tag' },
  htmlTitle = { link = 'Title' },
  -- Markdown
  markdownBold = { bold = true },
  markdownBoldItalic = { bold = true, italic = true },
  markdownCode = { fg = c_green1 },
  markdownCodeBlock = { fg = c_green1 },
  markdownError = { link = 'NONE' },
  markdownEscape = { fg = 'NONE' },
  markdownH1 = { link = 'htmlH1' },
  markdownH2 = { link = 'htmlH2' },
  markdownH3 = { link = 'htmlH3' },
  markdownH4 = { link = 'htmlH4' },
  markdownH5 = { link = 'htmlH5' },
  markdownH6 = { link = 'htmlH6' },
  markdownListMarker = { fg = c_teal },
  -- Checkhealth
  healthError = { fg = c_red },
  healthSuccess = { fg = c_green0 },
  healthWarning = { fg = c_yellow },
  helpHeader = { link = 'Title' },
  helpSectionDelim = { link = 'Title' },
  -- Qf
  qfFileName = { link = 'Directory' },
  qfLineNr = { link = 'LineNr' },
  -- }}}
  -- Plugins {{{2
  -- gitsigns
  GitSignsAdd = { fg = c_green1 },
  GitSignsChange = { fg = c_yellow },
  GitSignsDelete = { fg = c_red },
  GitSignsDeletePreview = { bg = c_winterRed },
  -- fugitive
  fugitiveHash = { link = 'gitHash' },
  fugitiveHeader = { link = 'Title' },
  fugitiveHeading = { link = 'Title' },
  fugitiveStagedHeading = { fg = c_green0, bold = true },
  fugitiveStagedModifier = { fg = c_green0 },
  fugitiveUnStagedHeading = { fg = c_yellow, bold = true },
  fugitiveUnstagedModifier = { fg = c_yellow },
  fugitiveUntrackedHeading = { fg = c_aqua, bold = true },
  fugitiveUntrackedModifier = { fg = c_aqua },
  -- telescope
  TelescopeBorder = { bg = c_bg2, fg = c_bg5 },
  TelescopeMatching = { fg = c_blue0, bold = true },
  TelescopeNormal = { bg = c_bg2, fg = c_fg2 },
  TelescopePromptBorder = { bg = c_bg3, fg = c_bg5 },
  TelescopePromptNormal = { bg = c_bg3, fg = c_fg2 },
  TelescopeResultsClass = { link = 'Structure' },
  TelescopeResultsField = { link = '@variable.member' },
  TelescopeResultsMethod = { link = 'Function' },
  TelescopeResultsStruct = { link = 'Structure' },
  TelescopeResultsVariable = { link = '@variable' },
  TelescopeSelection = { link = 'Visual' },
  TelescopeTitle = { bg = c_teal, fg = c_bg0 },
  -- nvim-dap-ui
  DapUIBreakpointsCurrentLine = { bold = true, fg = c_fg0 },
  DapUIBreakpointsDisabledLine = { link = 'Comment' },
  DapUIBreakpointsInfo = { fg = c_blue0 },
  DapUIBreakpointsPath = { link = 'Directory' },
  DapUIDecoration = { fg = c_bg5 },
  DapUIFloatBorder = { fg = c_bg5 },
  DapUILineNumber = { fg = c_teal },
  DapUIModifiedValue = { bold = true, fg = c_teal },
  DapUIPlayPause = { fg = c_green1 },
  DapUIRestart = { fg = c_green1 },
  DapUIScope = { link = 'Special' },
  DapUISource = { fg = c_red },
  DapUIStepBack = { fg = c_teal },
  DapUIStepInto = { fg = c_teal },
  DapUIStepOut = { fg = c_teal },
  DapUIStepOver = { fg = c_teal },
  DapUIStop = { fg = c_red },
  DapUIStoppedThread = { fg = c_teal },
  DapUIThread = { fg = c_fg0 },
  DapUIType = { link = 'Type' },
  DapUIUnavailable = { fg = c_ash },
  DapUIWatchesEmpty = { fg = c_red },
  DapUIWatchesError = { fg = c_red },
  DapUIWatchesValue = { fg = c_fg0 },
  -- lazy.nvim
  LazyProgressTodo = { fg = c_bg5 },
  -- statusline
  StatusLineGitAdded = { bg = c_bg3, fg = c_green1 },
  StatusLineGitChanged = { bg = c_bg3, fg = c_yellow },
  StatusLineGitRemoved = { bg = c_bg3, fg = c_red },
  StatusLineGitBranch = { bg = c_bg3, fg = c_ash },
  StatusLineHeader = { bg = c_bg5, fg = c_fg1 },
  StatusLineHeaderModified = { bg = c_red, fg = c_bg0 },
  -- }}}
}
-- }}}1
-- Highlight group overrides {{{1
if vim.go.bg == 'light' then
  hlgroups.CursorLine = { bg = c_bg2 }
  hlgroups.DiagnosticSignWarn = { fg = c_yellow }
  hlgroups.DiagnosticUnderlineWarn = { sp = c_yellow, undercurl = true }
  hlgroups.DiagnosticVirtualTextWarn = { bg = c_winterYellow, fg = c_yellow }
  hlgroups.DiagnosticWarn = { fg = c_yellow }
  hlgroups.IncSearch = { bg = c_yellow, fg = c_bg0, bold = true }
  hlgroups.Keyword = { fg = c_violet }
  hlgroups.ModeMsg = { fg = c_green2, bold = true }
  hlgroups.Pmenu = { bg = c_bg1, fg = c_fg1 }
  hlgroups.PmenuSbar = { bg = c_bg3 }
  hlgroups.PmenuSel = { bg = c_fg0, fg = c_bg0 }
  hlgroups.PmenuThumb = { bg = c_bg4 }
  hlgroups.Search = { bg = c_bg3 }
  hlgroups.StatusLine = { bg = c_bg1 }
  hlgroups.StatusLineGitAdded = { bg = c_bg1, fg = c_green1 }
  hlgroups.StatusLineGitChanged = { bg = c_bg1, fg = c_yellow }
  hlgroups.StatusLineGitRemoved = { bg = c_bg1, fg = c_red }
  hlgroups.StatusLineGitBranch = { bg = c_bg1, fg = c_ash }
  hlgroups.StatusLineHeader = { bg = c_fg0, fg = c_bg0 }
  hlgroups.StatusLineHeaderModified = { bg = c_red, fg = c_bg0 }
  hlgroups.Visual = { bg = c_bg4 }
  hlgroups.WinBar = { bg = c_bg1, fg = c_fg1 }
  hlgroups.WinBarNC = { bg = c_bg2, fg = c_bg5 }
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
