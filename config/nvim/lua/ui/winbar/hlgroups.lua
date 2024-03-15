--stylua: ignore start
local hlgroups = {
  WinBarCurrentContext            = { link = 'Visual' },
  WinBarHover                     = { link = 'Visual' },
  WinBarIconKindArray             = { link = 'Operator' },
  WinBarIconKindBoolean           = { link = 'Boolean' },
  WinBarIconKindBreakStatement    = { link = 'Error' },
  WinBarIconKindCall              = { link = 'Function' },
  WinBarIconKindCaseStatement     = { link = 'Conditional' },
  WinBarIconKindClass             = { link = 'CmpItemKindClass' },
  WinBarIconKindConstant          = { link = 'Constant' },
  WinBarIconKindConstructor       = { link = 'CmpItemKindConstructor' },
  WinBarIconKindContinueStatement = { link = 'Repeat' },
  WinBarIconKindDeclaration       = { link = 'CmpItemKindSnippet' },
  WinBarIconKindDelete            = { link = 'Error' },
  WinBarIconKindDoStatement       = { link = 'Repeat' },
  WinBarIconKindElseStatement     = { link = 'Conditional' },
  WinBarIconKindEnum              = { link = 'CmpItemKindEnum' },
  WinBarIconKindEnumMember        = { link = 'CmpItemKindEnumMember' },
  WinBarIconKindEvent             = { link = 'CmpItemKindEvent' },
  WinBarIconKindField             = { link = 'CmpItemKindField' },
  WinBarIconKindFile              = { link = 'Field' },
  WinBarIconKindFolder            = { link = 'Directory' },
  WinBarIconKindForStatement      = { link = 'Repeat' },
  WinBarIconKindFunction          = { link = 'Function' },
  WinBarIconKindH1Marker          = { link = 'markdownH1' },
  WinBarIconKindH2Marker          = { link = 'markdownH2' },
  WinBarIconKindH3Marker          = { link = 'markdownH3' },
  WinBarIconKindH4Marker          = { link = 'markdownH4' },
  WinBarIconKindH5Marker          = { link = 'markdownH5' },
  WinBarIconKindH6Marker          = { link = 'markdownH6' },
  WinBarIconKindIdentifier        = { link = 'CmpItemKindVariable' },
  WinBarIconKindIfStatement       = { link = 'Conditional' },
  WinBarIconKindInterface         = { link = 'CmpItemKindInterface' },
  WinBarIconKindKeyword           = { link = 'Keyword' },
  WinBarIconKindList              = { link = 'Operator' },
  WinBarIconKindMacro             = { link = 'Macro' },
  WinBarIconKindMarkdownH1        = { link = 'markdownH1' },
  WinBarIconKindMarkdownH2        = { link = 'markdownH2' },
  WinBarIconKindMarkdownH3        = { link = 'markdownH3' },
  WinBarIconKindMarkdownH4        = { link = 'markdownH4' },
  WinBarIconKindMarkdownH5        = { link = 'markdownH5' },
  WinBarIconKindMarkdownH6        = { link = 'markdownH6' },
  WinBarIconKindMethod            = { link = 'CmpItemKindMethod' },
  WinBarIconKindModule            = { link = 'CmpItemKindModule' },
  WinBarIconKindNamespace         = { link = 'NameSpace' },
  WinBarIconKindNull              = { link = 'Constant' },
  WinBarIconKindNumber            = { link = 'Number' },
  WinBarIconKindObject            = { link = 'Statement' },
  WinBarIconKindOperator          = { link = 'Operator' },
  WinBarIconKindPackage           = { link = 'CmpItemKindModule' },
  WinBarIconKindPair              = { link = 'String' },
  WinBarIconKindProperty          = { link = 'CmpItemKindProperty' },
  WinBarIconKindReference         = { link = 'CmpItemKindReference' },
  WinBarIconKindRepeat            = { link = 'Repeat' },
  WinBarIconKindScope             = { link = 'NameSpace' },
  WinBarIconKindSpecifier         = { link = 'Keyword' },
  WinBarIconKindStatement         = { link = 'Statement' },
  WinBarIconKindString            = { link = 'String' },
  WinBarIconKindStruct            = { link = 'CmpItemKindStruct' },
  WinBarIconKindSwitchStatement   = { link = 'Conditional' },
  WinBarIconKindType              = { link = 'CmpItemKindClass' },
  WinBarIconKindTypeParameter     = { link = 'CmpItemKindTypeParameter' },
  WinBarIconKindUnit              = { link = 'CmpItemKindUnit' },
  WinBarIconKindValue             = { link = 'Number' },
  WinBarIconKindVariable          = { link = 'CmpItemKindVariable' },
  WinBarIconKindWhileStatement    = { link = 'Repeat' },
  WinBarIconUIIndicator           = { link = 'SpecialChar' },
  WinBarIconUIPickPivot           = { link = 'Error' },
  WinBarIconUISeparator           = { link = 'Comment' },
  WinBarIconUISeparatorMenu       = { link = 'WinBarIconUISeparator' },
  WinBarMenuCurrentContext        = { link = 'PmenuSel' },
  WinBarMenuFloatBorder           = { link = 'FloatBorder' },
  WinBarMenuHoverEntry            = { link = 'IncSearch' },
  WinBarMenuHoverIcon             = { reverse = true },
  WinBarMenuHoverSymbol           = { bold = true },
  WinBarMenuNormalFloat           = { link = 'NormalFloat' },
  WinBarMenuSbar                  = { link = 'PmenuSbar' },
  WinBarMenuThumb                 = { link = 'PmenuThumb' },
  WinBarPreview                   = { link = 'Visual' },
}
--stylua: ignore end

---Set winbar highlight groups
---@return nil
local function set_hlgroups()
  for hl_name, hl_settings in pairs(hlgroups) do
    hl_settings.default = true
    vim.api.nvim_set_hl(0, hl_name, hl_settings)
  end
end

---Initialize highlight groups for winbar
local function init()
  set_hlgroups()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('WinBarHlGroups', {}),
    callback = set_hlgroups,
  })
end

return {
  init = init,
}
