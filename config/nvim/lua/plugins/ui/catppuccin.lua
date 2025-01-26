return {
  'catppuccin/nvim',
  priority = 1000,
  name = 'catppuccin',
  init = function()
    vim.cmd.colorscheme('catppuccin')
  end,
  config = function()
    local transparent_background = false
    local clear = {}

    require('catppuccin').setup({
      background = { light = 'latte', dark = 'mocha' }, -- latte, frappe, macchiato, mocha
      dim_inactive = {
        enabled = false,
        -- Dim inactive splits/windows/buffers.
        -- NOT recommended if you use old palette (a.k.a., mocha).
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
        aerial = true,
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
        dropbar = { enabled = true, color_mode = true },
        fern = false,
        fidget = true,
        flash = true,
        gitgutter = false,
        gitsigns = true,
        harpoon = true,
        headlines = false,
        hop = false,
        illuminate = true,
        indent_blankline = { enabled = true, colored_indent_levels = false },
        leap = false,
        lightspeed = false,
        lsp_saga = true,
        lsp_trouble = true,
        markdown = true,
        mason = true,
        mini = true,
        navic = { enabled = false },
        neogit = true,
        neotest = true,
        neotree = {
          enabled = false,
          show_root = true,
          transparent_panel = false,
        },
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
        telescope = { enabled = true, style = 'nvchad' },
        treesitter = true,
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

            -- For indent-blankline
            IblIndent = { fg = C.surface0 },
            IblScope = { fg = C.surface2, style = { 'bold' } },

            -- For nvim-cmp and wilder.nvim
            Pmenu = {
              fg = C.overlay2,
              bg = transparent_background and C.none or C.base,
            },
            PmenuBorder = {
              fg = C.surface1,
              bg = transparent_background and C.none or C.base,
            },
            PmenuSel = { bg = C.green, fg = C.base },
            CmpItemAbbr = { fg = C.overlay2 },
            CmpItemAbbrMatch = { fg = C.blue, style = { 'bold' } },
            CmpDoc = { link = 'NormalFloat' },
            CmpDocBorder = {
              fg = transparent_background and C.surface1 or C.mantle,
              bg = transparent_background and C.none or C.mantle,
            },

            -- For fidget
            FidgetTask = { bg = C.none, fg = C.surface2 },
            FidgetTitle = { fg = C.blue, style = { 'bold' } },

            -- For nvim-notify
            NotifyBackground = { bg = C.base },

            -- For nvim-tree
            NvimTreeRootFolder = { fg = C.pink },
            NvimTreeIndentMarker = { fg = C.surface2 },

            -- For trouble.nvim
            TroubleNormal = {
              bg = transparent_background and C.none or C.base,
            },

            -- For telescope.nvim
            TelescopeMatching = { fg = C.lavender },
            TelescopeResultsDiffAdd = { fg = C.green },
            TelescopeResultsDiffChange = { fg = C.yellow },
            TelescopeResultsDiffDelete = { fg = C.red },

            -- For glance.nvim
            GlanceWinBarFilename = { fg = C.subtext1, style = { 'bold' } },
            GlanceWinBarFilepath = { fg = C.subtext0, style = { 'italic' } },
            GlanceWinBarTitle = { fg = C.teal, style = { 'bold' } },
            GlanceListCount = { fg = C.lavender },
            GlanceListFilepath = { link = 'Comment' },
            GlanceListFilename = { fg = C.blue },
            GlanceListMatch = { fg = C.lavender, style = { 'bold' } },
            GlanceFoldIcon = { fg = C.green },

            -- For nvim-treehopper
            TSNodeKey = {
              fg = C.peach,
              bg = transparent_background and C.none or C.base,
              style = { 'bold', 'underline' },
            },

            -- For treesitter
            ['@keyword.return'] = { fg = C.pink, style = clear },
            ['@error.c'] = { fg = C.none, style = clear },
            ['@error.cpp'] = { fg = C.none, style = clear },
          }
        end,
      },
    })
  end,
}
