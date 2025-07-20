--stylua: ignore start
local hlgroups = {
  WinBarCurrentContext            = { link = 'Visual' },
  WinBarHover                     = { link = 'Visual' },
  WinBarPreview                   = { link = 'Visual' },

  WinBarIconKindArray             = { link = 'Operator' },
  WinBarIconKindBlockMappingPair  = { link = 'WinBarIconKindDefault' },
  WinBarIconKindBoolean           = { link = 'Boolean' },
  WinBarIconKindBreakStatement    = { link = 'Error' },
  WinBarIconKindCall              = { link = 'Function' },
  WinBarIconKindCaseStatement     = { link = '@keyword.conditional' },
  WinBarIconKindClass             = { link = 'Type' },
  WinBarIconKindConstant          = { link = 'Constant' },
  WinBarIconKindConstructor       = { link = '@constructor' },
  WinBarIconKindContinueStatement = { link = 'Repeat' },
  WinBarIconKindDeclaration       = { link = 'WinBarIconKindDefault' },
  WinBarIconKindDefault           = { link = 'Special' },
  WinBarIconKindDelete            = { link = 'Error' },
  WinBarIconKindDoStatement       = { link = 'Repeat' },
  WinBarIconKindElement           = { link = 'WinBarIconKindDefault' },
  WinBarIconKindElseStatement     = { link = '@keyword.conditional' },
  WinBarIconKindEnum              = { link = 'Constant' },
  WinBarIconKindEnumMember        = { link = 'WinBarIconKindEnumMember' },
  WinBarIconKindEvent             = { link = '@lsp.type.event' },
  WinBarIconKindField             = { link = 'WinBarIconKindDefault' },
  WinBarIconKindFile              = { link = 'WinBarIconKindFolder' },
  WinBarIconKindFolder            = { link = 'Directory' },
  WinBarIconKindForStatement      = { link = 'Repeat' },
  WinBarIconKindFunction          = { link = 'Function' },
  WinBarIconKindGotoStatement     = { link = '@keyword.return' },
  WinBarIconKindIdentifier        = { link = 'WinBarIconKindDefault' },
  WinBarIconKindIfStatement       = { link = '@keyword.conditional' },
  WinBarIconKindInterface         = { link = 'Type' },
  WinBarIconKindKeyword           = { link = '@keyword' },
  WinBarIconKindList              = { link = 'Operator' },
  WinBarIconKindMacro             = { link = 'Macro' },
  WinBarIconKindMarkdownH1        = { link = 'markdownH1' },
  WinBarIconKindMarkdownH2        = { link = 'markdownH2' },
  WinBarIconKindMarkdownH3        = { link = 'markdownH3' },
  WinBarIconKindMarkdownH4        = { link = 'markdownH4' },
  WinBarIconKindMarkdownH5        = { link = 'markdownH5' },
  WinBarIconKindMarkdownH6        = { link = 'markdownH6' },
  WinBarIconKindMessage           = { link = 'Type' },
  WinBarIconKindMethod            = { link = 'Function' },
  WinBarIconKindModule            = { link = '@module' },
  WinBarIconKindNamespace         = { link = '@lsp.type.namespace' },
  WinBarIconKindNull              = { link = 'Constant' },
  WinBarIconKindNumber            = { link = 'Number' },
  WinBarIconKindObject            = { link = 'Statement' },
  WinBarIconKindOperator          = { link = 'Operator' },
  WinBarIconKindPackage           = { link = '@module' },
  WinBarIconKindPair              = { link = 'WinBarIconKindDefault' },
  WinBarIconKindProperty          = { link = 'WinBarIconKindDefault' },
  WinBarIconKindReference         = { link = 'WinBarIconKindDefault' },
  WinBarIconKindRepeat            = { link = 'Repeat' },
  WinBarIconKindReturnStatement   = { link = '@keyword.return' },
  WinBarIconKindRpc               = { link = 'Function' },
  WinBarIconKindRuleSet           = { link = '@lsp.type.namespace' },
  WinBarIconKindScope             = { link = '@lsp.type.namespace' },
  WinBarIconKindSection           = { link = 'Title' },
  WinBarIconKindService           = { link = 'Type' },
  WinBarIconKindSpecifier         = { link = '@keyword' },
  WinBarIconKindStatement         = { link = 'Statement' },
  WinBarIconKindString            = { link = '@string' },
  WinBarIconKindStruct            = { link = 'Type' },
  WinBarIconKindSwitchStatement   = { link = '@keyword.conditional' },
  WinBarIconKindTable             = { link = 'WinBarIconKindDefault' },
  WinBarIconKindType              = { link = 'Type' },
  WinBarIconKindTypeParameter     = { link = 'WinBarIconKindDefault' },
  WinBarIconKindUnit              = { link = 'WinBarIconKindDefault' },
  WinBarIconKindValue             = { link = 'Number' },
  WinBarIconKindVariable          = { link = 'WinBarIconKindDefault' },
  WinBarIconKindWhileStatement    = { link = 'Repeat' },

  WinBarIconUIIndicator           = { link = 'SpecialChar' },
  WinBarIconUIPickPivot           = { link = 'Error' },
  WinBarIconUISeparator           = { link = 'NonText' },
  WinBarIconUISeparatorMenu       = { link = 'WinBarIconUISeparator' },

  WinBarMenuCurrentContext        = { link = 'PmenuSel' },
  WinBarMenuFloatBorder           = { link = 'FloatBorder' },
  WinBarMenuHoverEntry            = { link = 'IncSearch' },
  WinBarMenuHoverIcon             = { reverse = true },
  WinBarMenuHoverSymbol           = { bold = true },
  WinBarMenuNormalFloat           = { link = 'NormalFloat' },
  WinBarMenuSbar                  = { link = 'PmenuSbar' },
  WinBarMenuThumb                 = { link = 'PmenuThumb' },

  -- Highlight groups in non-current windows
  WinBarIconKindDefaultNC           = { link = 'WinBarNC' },

  WinBarIconKindArrayNC             = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindBlockMappingPairNC  = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindBooleanNC           = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindBreakStatementNC    = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindCallNC              = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindCaseStatementNC     = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindClassNC             = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindConstantNC          = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindConstructorNC       = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindContinueStatementNC = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindDeclarationNC       = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindDeleteNC            = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindDoStatementNC       = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindElementNC           = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindElseStatementNC     = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindEnumMemberNC        = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindEnumNC              = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindEventNC             = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindFieldNC             = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindFileNC              = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindFolderNC            = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindForStatementNC      = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindFunctionNC          = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindGotoStatementNC     = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindIdentifierNC        = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindIfStatementNC       = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindInterfaceNC         = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindKeywordNC           = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindListNC              = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindMacroNC             = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindMarkdownH1NC        = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindMarkdownH2NC        = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindMarkdownH3NC        = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindMarkdownH4NC        = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindMarkdownH5NC        = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindMarkdownH6NC        = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindMessageNC           = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindMethodNC            = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindModuleNC            = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindNamespaceNC         = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindNullNC              = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindNumberNC            = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindObjectNC            = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindOperatorNC          = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindPackageNC           = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindPairNC              = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindPropertyNC          = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindReferenceNC         = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindRepeatNC            = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindReturnStatementNC   = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindRpcNC               = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindRuleSetNC           = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindScopeNC             = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindSectionNC           = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindServiceNC           = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindSpecifierNC         = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindStatementNC         = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindStringNC            = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindStructNC            = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindSwitchStatementNC   = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindTableNC             = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindTypeNC              = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindTypeParameterNC     = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindUnitNC              = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindValueNC             = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindVariableNC          = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconKindWhileStatementNC    = { link = 'WinBarIconKindDefaultNC' },
  WinBarIconUISeparatorNC           = { link = 'NonText' },
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

---Check if `hl-WinBarNC` and `hl-WinBar` are equal
---@return boolean
local function winbar_hl_nc_equal()
  local hl = require('utils.hl')
  return vim.deep_equal(
    hl.get(0, { name = 'WinBar', link = false }),
    hl.get(0, { name = 'WinBarNC', link = false })
  )
end

---Dim/restore winbar highlights in given window
---@param win? integer
---@param do_dim? boolean `true` to dim highlights, `false` to restore, default to `true`
local function dim(win, do_dim)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  local hl_map = {}
  for hl_name, _ in pairs(hlgroups) do
    if vim.endswith(hl_name, 'NC') then
      hl_map[hl_name:gsub('NC$', '')] = hl_name
    end
  end

  vim.api.nvim_win_call(win, function()
    if do_dim ~= false then
      ---@diagnostic disable-next-line: undefined-field
      vim.opt_local.winhl:append(hl_map)
    else
      ---@diagnostic disable-next-line: undefined-field
      vim.opt_local.winhl:remove(vim.tbl_keys(hl_map))
    end
  end)
end

---Dim highlights in non-current windows if `hl-WinBarNC` differs from
---`hl-WinBar`
local function dim_nc_wins()
  if winbar_hl_nc_equal() then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      dim(win, false)
    end
  else
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      dim(win)
    end
    dim(0, false)
  end
end

---Initialize highlight groups for winbar
local function init()
  local groupid = vim.api.nvim_create_augroup('WinBarHlGroups', {})

  set_hlgroups()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = groupid,
    callback = set_hlgroups,
  })

  -- Dim winbar highlights in non-current windows
  dim_nc_wins()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = groupid,
    callback = dim_nc_wins,
  })

  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    group = groupid,
    callback = function()
      -- Only dim icon if current window's winbar color is the same as
      -- non-current windows'
      -- Also, don't dim for windows that does not have a winbar, this avoids
      -- extra overhead and most importantly, avoid dimming icons in drop-down
      -- menus
      if not winbar_hl_nc_equal() and vim.wo.winbar ~= '' then
        dim(0, false)
      end
    end,
  })

  vim.api.nvim_create_autocmd('WinLeave', {
    group = groupid,
    callback = function()
      if not winbar_hl_nc_equal() and vim.wo.winbar ~= '' then
        dim()
      end
    end,
  })
end

return { init = init }
