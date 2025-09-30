-- Name:         sonokai
-- Description:  Sonokai theme with dark and light variants, originally by @sainnhe
-- Author:       Bekaboo <kankefengjing@gmail.com>
-- Maintainer:   Bekaboo <kankefengjing@gmail.com>
-- License:      GPL-3.0
-- Last Updated: Sat 27 Sep 2025 01:37:57 AM EDT

-- Clear hlgroups and set colors_name {{{
vim.cmd.hi('clear')
vim.g.colors_name = 'sonokai'
-- }}}

-- Palette {{{
-- stylua: ignore start
local c_bg0
local c_bg1
local c_bg2
local c_bg3
local c_bg4
local c_bg5
local c_diff_red
local c_diff_green
local c_diff_blue
local c_fg
local c_red
local c_orange
local c_yellow
local c_green
local c_blue
local c_purple
local c_grey
local c_grey_dim
local c_none

if vim.go.bg == 'dark' then
  c_bg0         = { '#222328',   234    }
  c_bg1         = { '#2c2e34',   235    }
  c_bg2         = { '#33353f',   236    }
  c_bg3         = { '#363944',   236    }
  c_bg4         = { '#3b3e48',   237    }
  c_bg5         = { '#414550',   237    }
  c_diff_red    = { '#55393d',   52     }
  c_diff_green  = { '#40463e',   22     }
  c_diff_blue   = { '#354157',   17     }
  c_fg          = { '#e2e2e3',   250    }
  c_red         = { '#fc5d7c',   203    }
  c_orange      = { '#f39660',   215    }
  c_yellow      = { '#e7c664',   179    }
  c_green       = { '#9ed072',   107    }
  c_blue        = { '#76cce0',   110    }
  c_purple      = { '#b39df3',   176    }
  c_grey        = { '#7f8490',   246    }
  c_grey_dim    = { '#595f6f',   240    }
  c_none        = { 'NONE',      'NONE' }
else
  c_bg0         = { '#f8f8f8',   231    }
  c_bg1         = { '#f3f3f3',   15     }
  c_bg2         = { '#e7e7e7',   251    }
  c_bg3         = { '#e3e3e3',   252    }
  c_bg4         = { '#d4d4d4',   253    }
  c_bg5         = { '#cbcbcb',   254    }
  c_diff_red    = { '#ffc1ce',   204    }
  c_diff_green  = { '#cde2b7',   40     }
  c_diff_blue   = { '#afd5e0',   17     }
  c_fg          = { '#181819',   232    }
  c_red         = { '#d44e69',   203    }
  c_orange      = { '#be683c',   215    }
  c_yellow      = { '#be9b44',   179    }
  c_green       = { '#72ac38',   22     }
  c_blue        = { '#65b1c2',   110    }
  c_purple      = { '#a793e3',   176    }
  c_grey        = { '#7f8490',   246    }
  c_grey_dim    = { '#595f6f',   240    }
  c_none        = { 'NONE',      'NONE' }
end
-- stylua: ignore end
-- }}}

-- Terminal colors {{{
-- stylua: ignore start
vim.g.terminal_color_0  = c_bg2[1]
vim.g.terminal_color_1  = c_red[1]
vim.g.terminal_color_2  = c_green[1]
vim.g.terminal_color_3  = c_yellow[1]
vim.g.terminal_color_4  = c_blue[1]
vim.g.terminal_color_5  = c_purple[1]
vim.g.terminal_color_6  = c_blue[1]
vim.g.terminal_color_7  = c_fg[1]
vim.g.terminal_color_8  = c_grey[1]
vim.g.terminal_color_9  = c_red[1]
vim.g.terminal_color_10 = c_green[1]
vim.g.terminal_color_11 = c_yellow[1]
vim.g.terminal_color_12 = c_blue[1]
vim.g.terminal_color_13 = c_purple[1]
vim.g.terminal_color_14 = c_blue[1]
vim.g.terminal_color_15 = c_fg[1]
vim.g.terminal_color_16 = c_orange[1]
vim.g.terminal_color_17 = c_orange[1]
-- stylua: ignore end
--- }}}

-- Highlight groups {{{1
local hlgroups = {
  -- UI {{{2
  ColorColumn = { bg = c_bg2 },
  Conceal = { fg = c_fg },
  CurSearch = { link = 'IncSearch' },
  Cursor = { fg = c_bg1, bg = c_fg },
  CursorColumn = { link = 'CursorLine' },
  CursorIM = { link = 'Cursor' },
  CursorLine = { bg = c_bg2 },
  CursorLineNr = { fg = c_fg, bold = true },
  DebugPC = { bg = c_green, fg = c_bg1 },
  DiffAdd = { bg = c_diff_green },
  DiffAdded = { fg = c_green },
  DiffChange = { bg = c_diff_blue },
  DiffChanged = { fg = c_diff_blue },
  DiffDelete = { fg = c_grey },
  DiffDeleted = { bg = c_diff_red },
  DiffNewFile = { fg = c_orange },
  DiffOldFile = { fg = c_yellow },
  DiffRemoved = { fg = c_red },
  DiffText = { bg = c_blue, fg = c_bg1 },
  Directory = { fg = c_green },
  EndOfBuffer = { fg = c_bg5 },
  ErrorMsg = { fg = c_red },
  FloatBorder = { bg = c_bg3, fg = c_grey },
  FloatFooter = { link = 'FloatTitle' },
  FloatTitle = { bg = c_bg3, fg = c_red, bold = true },
  FoldColumn = { fg = c_grey_dim },
  Folded = { bg = c_bg2, fg = c_grey },
  Ignore = { fg = c_grey },
  IncSearch = { bg = c_red, fg = c_bg1 },
  LineNr = { fg = c_grey_dim },
  MatchParen = { bg = c_bg5 },
  ModeMsg = { bold = true },
  MoreMsg = { fg = c_blue, bold = true },
  MsgSeparator = { link = 'StatusLine' },
  NonText = { fg = c_grey },
  Normal = { bg = c_bg1, fg = c_fg },
  NormalFloat = { bg = c_bg3, fg = c_fg },
  NormalNC = { link = 'Normal' },
  Pmenu = { bg = c_bg3, fg = c_fg },
  PmenuExtra = { fg = c_grey, bg = c_bg3 },
  PmenuExtraSel = { link = 'PmenuSel' },
  PmenuKind = { fg = c_green, bg = c_bg3 },
  PmenuKindSel = { link = 'PmenuSel' },
  PmenuSbar = { bg = c_bg3 },
  PmenuSel = { bg = c_blue, fg = c_bg1 },
  PmenuThumb = { bg = c_grey },
  Question = { fg = c_yellow },
  QuickFixLine = { bg = c_blue, fg = c_bg1 },
  Search = { bg = c_green, fg = c_bg1 },
  SignColumn = { fg = c_purple },
  SpellBad = { underdashed = true },
  SpellCap = { underdashed = true },
  SpellLocal = { underdashed = true },
  SpellRare = { underdashed = true },
  StatusLine = { bg = c_bg4, fg = c_fg },
  StatusLineNC = { bg = c_bg2, fg = c_grey },
  Substitute = { bg = c_yellow, fg = c_bg1 },
  TabLine = { bg = c_bg5, fg = c_fg },
  TabLineFill = { bg = c_bg2, fg = c_grey },
  TabLineSel = { bg = c_red, fg = c_bg1 },
  TermCursor = { bg = c_orange, fg = c_bg1 },
  Title = { bold = true, fg = c_red },
  Underlined = { underline = true },
  VertSplit = { fg = c_bg5 },
  Visual = { bg = c_bg4 },
  VisualNOS = { link = 'Visual' },
  WarningMsg = { fg = c_yellow },
  Whitespace = { fg = c_bg4 },
  WildMenu = { link = 'Pmenu' },
  WinBar = { bg = c_bg0 },
  WinBarNC = { bg = c_bg0, fg = c_grey },
  WinSeparator = { link = 'VertSplit' },
  lCursor = { link = 'Cursor' },
  -- }}}2

  -- Syntax {{{2
  Boolean = { fg = c_purple },
  Character = { link = 'String' },
  Comment = { fg = c_grey },
  Conditional = { fg = c_red },
  Constant = { fg = c_orange },
  Delimiter = { fg = c_grey },
  Error = { fg = c_red },
  Exception = { fg = c_red },
  Float = { link = 'Number' },
  Function = { fg = c_green },
  Identifier = { fg = c_fg },
  Keyword = { fg = c_red },
  Number = { fg = c_purple },
  Operator = { fg = c_red },
  PreProc = { fg = c_red },
  Special = { fg = c_purple },
  SpecialKey = { fg = c_purple },
  Statement = { fg = c_red },
  String = { fg = c_yellow },
  Todo = { bg = c_blue, fg = c_bg1, bold = true },
  Type = { fg = c_blue },
  Typedef = { fg = c_red },
  -- }}}2

  -- Treesitter syntax {{{2
  ['@attribute.builtin'] = { link = 'Special' },
  ['@conceal'] = { fg = c_grey },
  ['@constructor.lua'] = {},
  ['@diff.delta'] = { link = 'DiffChanged' },
  ['@diff.minus'] = { link = 'DiffRemoved' },
  ['@diff.plus'] = { link = 'DiffAdded' },
  ['@markup'] = { link = 'Special' },
  ['@markup.heading.1.markdown'] = { link = 'markdownH1' },
  ['@markup.heading.2.markdown'] = { link = 'markdownH2' },
  ['@markup.heading.3.markdown'] = { link = 'markdownH3' },
  ['@markup.heading.4.markdown'] = { link = 'markdownH4' },
  ['@markup.heading.5.markdown'] = { link = 'markdownH5' },
  ['@markup.heading.6.markdown'] = { link = 'markdownH6' },
  ['@markup.heading.1.marker.markdown'] = { link = '@conceal' },
  ['@markup.heading.2.marker.markdown'] = { link = '@conceal' },
  ['@markup.heading.3.marker.markdown'] = { link = '@conceal' },
  ['@markup.heading.4.marker.markdown'] = { link = '@conceal' },
  ['@markup.heading.5.marker.markdown'] = { link = '@conceal' },
  ['@markup.heading.6.marker.markdown'] = { link = '@conceal' },
  ['@markup.heading.1.delimiter.vimdoc'] = { link = 'helpSectionDelim' },
  ['@markup.heading.2.delimiter.vimdoc'] = { link = 'helpSectionDelim' },
  ['@markup.italic'] = { italic = true },
  ['@markup.link'] = { fg = c_purple, underline = true },
  ['@markup.link.label'] = { link = 'SpecialChar' },
  ['@markup.link.markdown_inline'] = { link = 'Constant' },
  ['@markup.link.url'] = { link = 'htmlLink' },
  ['@markup.list'] = { fg = c_yellow },
  ['@markup.list.checked'] = { fg = c_green },
  ['@markup.list.unchecked'] = { link = 'Ignore' },
  ['@markup.quote'] = { fg = c_yellow },
  ['@markup.raw'] = { fg = c_yellow },
  ['@markup.strikethrough'] = { strikethrough = true },
  ['@module.builtin'] = { link = 'Special' },
  ['@punctuation'] = { link = 'Delimiter' },
  ['@string.special'] = { link = 'Special' },
  ['@string.special.url'] = { link = 'htmlLink' },
  ['@string.yaml'] = { link = 'Normal' },
  ['@tag.builtin'] = { link = 'Special' },
  ['@text.diff.add'] = { link = 'DiffAdded' },
  ['@text.diff.delete'] = { link = 'DiffRemoved' },
  ['@text.todo.checked'] = { fg = c_green },
  ['@text.todo.unchecked'] = { link = 'Ignore' },
  ['@variable.parameter.builtin'] = { link = 'Special' },
  -- }}}

  -- LSP semantic {{{2
  ['@lsp.mod.deprecated'] = { link = 'DiagnosticDeprecated' },
  ['@lsp.type.class'] = { link = '@type' },
  ['@lsp.type.comment'] = { link = '@comment' },
  ['@lsp.type.decorator'] = { link = '@function' },
  ['@lsp.type.enum'] = { link = '@type' },
  ['@lsp.type.enumMember'] = { link = '@property' },
  ['@lsp.type.event'] = { link = '@type' },
  ['@lsp.type.events'] = { link = '@label' },
  ['@lsp.type.function'] = { link = '@function' },
  ['@lsp.type.interface'] = { link = '@type' },
  ['@lsp.type.keyword'] = { link = '@keyword' },
  ['@lsp.type.macro'] = { link = '@const.macro' },
  ['@lsp.type.method'] = { link = '@method' },
  ['@lsp.type.modifier'] = { link = '@type.qualifier' },
  ['@lsp.type.namespace'] = { link = '@module' },
  ['@lsp.type.number'] = { link = '@number' },
  ['@lsp.type.operator'] = { link = '@operator' },
  ['@lsp.type.parameter'] = { link = '@parameter' },
  ['@lsp.type.property'] = { link = '@property' },
  ['@lsp.type.regexp'] = { link = '@string.regex' },
  ['@lsp.type.string'] = { link = '@string' },
  ['@lsp.type.struct'] = { link = '@type' },
  ['@lsp.type.type'] = { link = '@type' },
  ['@lsp.type.typeParameter'] = { link = '@type.definition' },
  ['@lsp.type.variable'] = { link = '@variable' },
  -- }}}

  -- LSP {{{2
  LspCodeLens = { fg = c_grey },
  LspInfoBorder = { link = 'FloatBorder' },
  LspInlayHint = { bg = c_bg3, fg = c_grey },
  LspReferenceRead = { link = 'LspReferenceText' },
  LspReferenceText = { bg = c_bg3 },
  LspReferenceWrite = { link = 'LspReferenceWrite' },
  LspSignatureActiveParameter = { link = 'Search' },
  -- }}}

  -- Diagnostic {{{2
  DiagnosticDeprecated = { strikethrough = true },
  DiagnosticError = { fg = c_red },
  DiagnosticHint = { fg = c_green },
  DiagnosticInfo = { fg = c_blue },
  DiagnosticOk = { fg = c_green },
  DiagnosticUnnecessary = { fg = c_grey },
  DiagnosticWarn = { fg = c_yellow },
  DiagnosticFloatingError = { fg = c_red },
  DiagnosticFloatingHint = { fg = c_green },
  DiagnosticFloatingInfo = { fg = c_blue },
  DiagnosticFloatingOk = { fg = c_green },
  DiagnosticFloatingWarn = { fg = c_yellow },
  DiagnosticSignError = { fg = c_red },
  DiagnosticSignHint = { fg = c_green },
  DiagnosticSignInfo = { fg = c_blue },
  DiagnosticSignOk = { fg = c_green },
  DiagnosticSignWarn = { fg = c_yellow },
  DiagnosticUnderlineError = { undercurl = true, sp = c_red },
  DiagnosticUnderlineHint = { undercurl = true, sp = c_green },
  DiagnosticUnderlineInfo = { undercurl = true, sp = c_blue },
  DiagnosticUnderlineOk = { underline = true, sp = c_green },
  DiagnosticUnderlineWarn = { undercurl = true, sp = c_yellow },
  DiagnosticVirtualTextError = { fg = c_grey },
  DiagnosticVirtualTextHint = { fg = c_grey },
  DiagnosticVirtualTextInfo = { fg = c_grey },
  DiagnosticVirtualTextOk = { fg = c_grey },
  DiagnosticVirtualTextWarn = { fg = c_grey },
  -- }}}

  -- Filetype {{{2
  -- Git
  gitHash = { fg = c_grey },

  -- Gitcommit
  gitcommitArrow = { fg = c_grey },
  gitcommitDiscarded = { fg = c_grey },
  gitcommitFile = { fg = c_green },
  gitcommitOnBranch = { fg = c_grey },
  gitcommitOverflow = { fg = c_red },
  gitcommitSelected = { fg = c_grey },
  gitcommitSummary = { fg = c_fg },
  gitcommitUnmerged = { fg = c_grey },
  gitcommitUntracked = { fg = c_grey },

  -- Sh/Bash
  bashSpecialVariables = { link = 'Constant' },
  shAstQuote = { link = 'Constant' },
  shCaseEsac = { link = 'Operator' },
  shDeref = { link = 'Special' },
  shDerefOff = { fg = c_blue, italic = true },
  shDerefSimple = { link = 'shDerefVar' },
  shDerefSpecial = { fg = c_blue, italic = true },
  shDerefVar = { link = 'Constant' },
  shFunction = { fg = c_green },
  shFunctionKey = { fg = c_red },
  shNoQuote = { link = 'shAstQuote' },
  shOption = { fg = c_purple },
  shQuote = { link = 'String' },
  shTestOpr = { link = 'Operator' },
  shVarAssign = { fg = c_red },
  shVariable = { link = 'Constant' },

  -- HTML
  htmlArg = { fg = c_blue },
  htmlBold = { bold = true },
  htmlBoldItalic = { bold = true, italic = true },
  htmlEndTag = { fg = c_blue },
  htmlH1 = { bold = true, fg = c_red },
  htmlH2 = { bold = true, fg = c_orange },
  htmlH3 = { bold = true, fg = c_yellow },
  htmlH4 = { bold = true, fg = c_green },
  htmlH5 = { bold = true, fg = c_blue },
  htmlH6 = { bold = true, fg = c_purple },
  htmlItalic = { italic = true },
  htmlLink = { fg = c_blue, underline = true },
  htmlScriptTag = { fg = c_purple },
  htmlSpecialChar = { link = 'SpecialChar' },
  htmlSpecialTagName = { fg = c_red, italic = true },
  htmlString = { fg = c_green },
  htmlTag = { fg = c_green },
  htmlTagN = { fg = c_red, italic = true },
  htmlTagName = { link = 'Tag' },
  htmlTitle = { link = 'Title' },

  -- Markdown
  markdownBlockquote = { fg = c_grey },
  markdownBold = { bold = true },
  markdownBoldDelimiter = { fg = c_grey },
  markdownBoldItalic = { bold = true, italic = true },
  markdownCode = { fg = c_green },
  markdownCodeBlock = { fg = c_green },
  markdownCodeDelimiter = { fg = c_green },
  markdownError = { fg = c_none },
  markdownEscape = { fg = c_none },
  markdownH1 = { link = 'htmlH1' },
  markdownH2 = { link = 'htmlH2' },
  markdownH3 = { link = 'htmlH3' },
  markdownH4 = { link = 'htmlH4' },
  markdownH5 = { link = 'htmlH5' },
  markdownH6 = { link = 'htmlH6' },
  markdownHeadingDelimiter = { fg = c_grey },
  markdownHeadingRule = { fg = c_grey },
  markdownId = { fg = c_yellow },
  markdownIdDeclaration = { link = 'markdownLinkText' },
  markdownItalicDelimiter = { fg = c_grey, italic = true },
  markdownLinkDelimiter = { fg = c_grey },
  markdownLinkText = { fg = c_purple },
  markdownLinkTextDelimiter = { fg = c_grey },
  markdownListMarker = { fg = c_red },
  markdownOrderedListMarker = { fg = c_red },
  markdownRule = { fg = c_purple },
  markdownUrl = { link = 'htmlLink' },
  markdownUrlDelimiter = { fg = c_grey },
  markdownUrlTitleDelimiter = { fg = c_green },

  -- Checkhealth
  healthError = { fg = c_red },
  healthSuccess = { fg = c_green },
  healthWarning = { fg = c_yellow },
  helpHeader = { link = 'Title' },
  helpSectionDelim = { link = 'Title' },

  -- Qf
  qfFileName = { link = 'Directory' },
  qfLineNr = { link = 'lineNr' },
  -- }}}

  -- Plugins {{{2
  -- gitsigns
  GitSignsAdd = { fg = c_green },
  GitSignsAddInline = { bg = c_green, fg = c_bg1 },
  GitSignsAddNr = { fg = c_green },
  GitSignsChange = { fg = c_blue },
  GitSignsChangeNr = { fg = c_blue },
  GitSignsCurrentLineBlame = { fg = c_grey },
  GitSignsDelete = { fg = c_red },
  GitSignsDeleteNr = { fg = c_red },
  GitSignsDeletePreview = { bg = c_diff_red },
  GitSignsDeleteInline = { bg = c_red, fg = c_bg1 },

  -- fugitive
  fugitiveHash = { link = 'gitHash' },
  fugitiveHeader = { link = 'Title' },
  fugitiveStagedHeading = { fg = c_green, bold = true },
  fugitiveStagedModifier = { fg = c_green, bold = true },
  fugitiveUnstagedHeading = { fg = c_yellow, bold = true },
  fugitiveUnstagedModifier = { fg = c_yellow, bold = true },
  fugitiveUntrackedHeading = { fg = c_grey, bold = true },
  fugitiveUntrackedModifier = { fg = c_grey, bold = true },

  -- telescope
  TelescopeBorder = { bg = c_bg2, fg = c_fg },
  TelescopeMatching = { fg = c_red, bold = true },
  TelescopeNormal = { bg = c_bg2, fg = c_fg },
  TelescopePromptBorder = { bg = c_bg4, fg = c_fg },
  TelescopePromptNormal = { bg = c_bg4, fg = c_fg },
  TelescopeResultsClass = { link = 'Structure' },
  TelescopeResultsField = { link = '@variable.member' },
  TelescopeResultsMethod = { link = 'Function' },
  TelescopeResultsStruct = { link = 'Structure' },
  TelescopeResultsVariable = { link = '@variable' },
  TelescopeSelection = { link = 'Visual' },
  TelescopeTitle = { bg = c_purple, fg = c_bg1 },

  -- nvim-dap-ui
  DapUIBreakpointsCurrentLine = { bold = true, fg = c_red },
  DapUIBreakpointsDisabledLine = { link = 'Comment' },
  DapUIBreakpointsInfo = { fg = c_blue },
  DapUIBreakpointsPath = { link = 'Directory' },
  DapUIDecoration = { fg = c_blue },
  DapUIFloatBorder = { link = 'FloatBorder' },
  DapUILineNumber = { link = 'LineNr' },
  DapUIModifiedValue = { bold = true, fg = c_blue },
  DapUIPlayPause = { fg = c_green },
  DapUIRestart = { fg = c_green },
  DapUIScope = { link = 'Special' },
  DapUISource = { fg = c_red },
  DapUIStepBack = { fg = c_blue },
  DapUIStepInto = { fg = c_blue },
  DapUIStepOut = { fg = c_blue },
  DapUIStepOver = { fg = c_blue },
  DapUIStop = { fg = c_red },
  DapUIStoppedThread = { fg = c_grey },
  DapUIThread = { fg = c_fg },
  DapUIType = { link = 'Type' },
  DapUIUnavailable = { fg = c_grey },
  DapUIWatchesEmpty = { fg = c_red },
  DapUIWatchesError = { fg = c_red },
  DapUIWatchesValue = { fg = c_fg },

  -- lazy.nvim
  LazyProgressTodo = { fg = c_bg5 },

  -- statusline
  StatusLineHeader = { bg = c_purple, fg = c_bg1 },
  StatusLineHeaderModified = { bg = c_yellow, fg = c_bg1 },
  -- }}}
}
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
