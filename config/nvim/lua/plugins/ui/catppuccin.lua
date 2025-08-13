vim.pack.add({ 'https://github.com/catppuccin/nvim' })

local transparent_background = false
local clear = {}

require('catppuccin').setup({
  background = { light = 'latte', dark = 'mocha' }, -- latte, frappe, macchiato, mocha
  dim_inactive = {
    enabled = false,
    shade = 'dark',
    percentage = 0.15,
  },
  transparent_background = transparent_background,
  show_end_of_buffer = false, -- show the '~' characters after the end of buffers
  term_colors = true,
  compile_path = vim.fn.stdpath('cache') .. '/catppuccin',
  styles = {
    comments = { 'italic' },
    properties = { 'italic' },
    functions = { 'bold' },
    keywords = { 'italic' },
    operators = { 'bold' },
    conditionals = { 'bold' },
    loops = { 'bold' },
    booleans = { 'bold', 'italic' },
    numbers = {},
    types = {},
    strings = {},
    variables = {},
  },
  integrations = {
    treesitter = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { 'italic' },
        hints = { 'italic' },
        warnings = { 'italic' },
        information = { 'italic' },
      },
      underlines = {
        errors = { 'underline' },
        hints = { 'underline' },
        warnings = { 'underline' },
        information = { 'underline' },
      },
    },
    aerial = false,
    alpha = false,
    barbar = false,
    beacon = false,
    blink_cmp = true,
    cmp = false,
    coc_nvim = false,
    dap = true,
    dap_ui = true,
    dashboard = false,
    diffview = true,
    dropbar = { enabled = false },
    fern = false,
    fidget = false,
    flash = true,
    gitgraph = true,
    gitgutter = false,
    gitsigns = true,
    harpoon = true,
    headlines = false,
    hop = false,
    illuminate = true,
    indent_blankline = { enabled = false },
    leap = false,
    lightspeed = false,
    lsp_saga = false,
    lsp_trouble = false,
    markdown = true,
    markview = true,
    mason = true,
    mini = { enabled = false, indentscope_color = 'green' },
    snacks = {
      enabled = true,
      indent_scope_color = 'green',
    },
    navic = { enabled = false },
    neogit = false,
    neotest = true,
    neotree = { enabled = false },
    noice = true,
    notify = true,
    nvim_surround = true,
    nvimtree = false,
    overseer = false,
    pounce = false,
    rainbow_delimiters = true,
    sandwich = false,
    semantic_tokens = true,
    symbols_outline = true,
    telekasten = false,
    -- telescope = { enabled = true, style = 'nvchad' },
    treesitter_context = true,
    ts_rainbow = false,
    vim_sneak = false,
    vimwiki = true,
    which_key = true,
  },
  color_overrides = {},
  highlight_overrides = {
    ---@param C palette
    all = function(C)
      return {
        -- Statusline
        StatusLineGitBranch = {
          fg = C.red,
          style = { 'italic' },
        },
        StatusLineHeader = {
          bg = C.green,
          fg = C.base,
          style = { 'bold' },
        },
        StatusLineHeaderModified = {
          bg = C.red,
          fg = C.base,
          style = { 'italic' },
        },
        StatuslineItalic = { fg = C.text, style = { 'italic' } },
        StatuslineSpinner = { fg = C.green },
        StatuslineTitle = { fg = C.text, style = { 'bold' } },
        StatusLine = { bg = C.base },

        -- Tabline
        TabLineFill = { bg = C.crust },
        TabLine = { fg = C.overlay0, bg = C.crust },
        BetterTermSymbol = { fg = C.base, bg = C.green },
        TabLineSel = { fg = C.lavender, bg = C.base },

        -- Neorg

        ['@neorg.lists.unordered.prefix.norg'] = { fg = C.mauve },
        ['@neorg.anchors.declaration.norg'] = { fg = C.blue },

        ['@neorg.headings.1.title.norg'] = { fg = C.pink },
        ['@neorg.headings.1.prefix'] = { fg = C.pink },
        ['@neorg.headings.1.prefix.norg'] = { fg = C.pink },
        ['@neorg.links.location.heading.1.norg'] = { fg = C.pink },

        ['@neorg.headings.2.title.norg'] = { fg = C.yellow },
        ['@neorg.headings.2.prefix'] = { fg = C.yellow },
        ['@neorg.headings.2.prefix.norg'] = { fg = C.yellow },
        ['@neorg.links.location.heading.2.norg'] = { fg = C.yellow },

        ['@neorg.headings.3.title.norg'] = { fg = C.red },
        ['@neorg.headings.3.prefix'] = { fg = C.red },
        ['@neorg.headings.3.prefix.norg'] = { fg = C.red },
        ['@neorg.links.location.heading.3.norg'] = { fg = C.red },

        ['@neorg.headings.4.title.norg'] = { fg = C.sky },
        ['@neorg.headings.4.prefix'] = { fg = C.sky },
        ['@neorg.headings.4.prefix.norg'] = { fg = C.sky },
        ['@neorg.links.location.heading.4.norg'] = { fg = C.sky },

        ['@neorg.headings.5.title.norg'] = { fg = C.green },
        ['@neorg.headings.5.prefix'] = { fg = C.green },
        ['@neorg.headings.5.prefix.norg'] = { fg = C.green },
        ['@neorg.links.location.heading.5.norg'] = { fg = C.green },

        ['@neorg.headings.6.title.norg'] = { fg = C.lavender },
        ['@neorg.headings.6.prefix'] = { fg = C.lavender },
        ['@neorg.headings.6.prefix.norg'] = { fg = C.lavender },
        ['@neorg.links.location.heading.6.norg'] = { fg = C.lavender },

        -- CMP
        BlinkCmpMenu = { bg = C.base, italic = true },
        BlinkCmpCustomType = { bg = C.base, fg = C.lavender },
        BlinkCmpMenuBorder = { fg = C.crust, bg = C.crust },
        BlinkCmpKindCodeium = { fg = C.base, bg = C.green },
        BlinkCmpKindSupermaven = { fg = C.base, bg = C.pink },
        BlinkCmpKindClass = { fg = C.base, bg = C.yellow },
        BlinkCmpKindColor = { fg = C.base, bg = C.red },
        BlinkCmpKindConstant = { fg = C.base, bg = C.peach },
        BlinkCmpKindConstructor = { fg = C.base, bg = C.blue },
        BlinkCmpKindCopilot = { fg = C.base, bg = C.teal },
        BlinkCmpKindEnum = { fg = C.base, bg = C.green },
        BlinkCmpKindEnumMember = { fg = C.base, bg = C.red },
        BlinkCmpKindEvent = { fg = C.base, bg = C.blue },
        BlinkCmpKindField = { fg = C.base, bg = C.green },
        BlinkCmpKindFile = { fg = C.base, bg = C.blue },
        BlinkCmpKindFolder = { fg = C.base, bg = C.blue },
        BlinkCmpKindFunction = { fg = C.base, bg = C.blue },
        BlinkCmpKindInterface = { fg = C.base, bg = C.yellow },
        BlinkCmpKindKeyword = { fg = C.base, bg = C.red },
        BlinkCmpKindMethod = { fg = C.base, bg = C.blue },
        BlinkCmpKindModule = { fg = C.base, bg = C.blue },
        BlinkCmpKindOperator = { fg = C.base, bg = C.blue },
        BlinkCmpKindProperty = { fg = C.base, bg = C.green },
        BlinkCmpKindReference = { fg = C.base, bg = C.red },
        BlinkCmpKindSnippet = { fg = C.base, bg = C.mauve },
        BlinkCmpKindStruct = { fg = C.base, bg = C.blue },
        BlinkCmpKindText = { fg = C.base, bg = C.teal },
        BlinkCmpKindTypeParameter = { fg = C.base, bg = C.blue },
        BlinkCmpKindUnit = { fg = C.base, bg = C.green },
        BlinkCmpKindValue = { fg = C.base, bg = C.peach },
        BlinkCmpKindVariable = { fg = C.base, bg = C.flamingo },

        -- For base configs
        NormalFloat = {
          fg = C.text,
          bg = transparent_background and C.none or C.mantle,
        },
        FloatBorder = {
          fg = transparent_background and C.blue or C.mantle,
          bg = transparent_background and C.none or C.mantle,
        },
        CursorLineNr = { fg = C.green },

        -- For native lsp configs
        DiagnosticVirtualTextError = { bg = C.none },
        DiagnosticVirtualTextWarn = { bg = C.none },
        DiagnosticVirtualTextInfo = { bg = C.none },
        DiagnosticVirtualTextHint = { bg = C.none },
        LspInfoBorder = { link = 'FloatBorder' },

        -- For mason.nvim
        MasonNormal = { link = 'NormalFloat' },

        -- For telescope.nvim
        TelescopeMatching = { fg = C.lavender },
        TelescopeResultsDiffAdd = { fg = C.green },
        TelescopeResultsDiffChange = { fg = C.yellow },
        TelescopeResultsDiffDelete = { fg = C.red },

        -- For treesitter
        ['@keyword.return'] = { fg = C.pink, style = clear },
        ['@error.c'] = { fg = C.none, style = clear },
        ['@error.cpp'] = { fg = C.none, style = clear },
      }
    end,
  },
})

vim.cmd.colorscheme('catppuccin')
