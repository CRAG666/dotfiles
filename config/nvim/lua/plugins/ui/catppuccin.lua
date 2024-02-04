return {
  "catppuccin/nvim",
  lazy = true,
  priority = 1000,
  name = "catppuccin",
  init = function()
    vim.cmd.colorscheme "catppuccin"
  end,
  config = function()
    local transparent_background = false
    local clear = {}

    require("catppuccin").setup {
      background = { light = "latte", dark = "mocha" }, -- latte, frappe, macchiato, mocha
      dim_inactive = {
        enabled = false,
        -- Dim inactive splits/windows/buffers.
        -- NOT recommended if you use old palette (a.k.a., mocha).
        shade = "dark",
        percentage = 0.15,
      },
      transparent_background = transparent_background,
      show_end_of_buffer = false, -- show the '~' characters after the end of buffers
      term_colors = true,
      compile_path = vim.fn.stdpath "cache" .. "/catppuccin",
      styles = {
        comments = { "italic" },
        properties = { "italic" },
        functions = { "bold" },
        keywords = { "italic" },
        operators = { "bold" },
        conditionals = { "bold" },
        loops = { "bold" },
        booleans = { "bold", "italic" },
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
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
        aerial = true,
        alpha = false,
        barbar = false,
        beacon = false,
        cmp = true,
        coc_nvim = false,
        dap = true,
        dap_ui = true,
        dashboard = false,
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
        neotest = false,
        neotree = { enabled = false, show_root = true, transparent_panel = false },
        noice = true,
        notify = true,
        nvimtree = false,
        overseer = false,
        pounce = false,
        rainbow_delimiters = true,
        sandwich = false,
        semantic_tokens = true,
        symbols_outline = true,
        telekasten = false,
        telescope = { enabled = true, style = "nvchad" },
        treesitter_context = true,
        ts_rainbow = false,
        vim_sneak = false,
        vimwiki = false,
        which_key = true,
      },
      color_overrides = {},
      highlight_overrides = {
        ---@param cp palette
        all = function(cp)
          return {
            -- Tabline
            TabLineFill = { bg = C.crust },
            TabLine = { fg = C.overlay0, bg = C.crust },
            TabLineSel = { fg = C.lavender, bg = C.base },
            -- Neorg
            ["@neorg.headings.1.title.norg"] = { fg = C.pink },
            ["@neorg.links.location.heading.1.norg"] = { fg = C.pink },
            ["@neorg.headings.2.title.norg"] = { fg = C.yellow },
            ["@neorg.links.location.heading.2.norg"] = { fg = C.yellow },
            -- CMP
            CmpItemKindSnippet = { fg = C.base, bg = C.mauve },
            CmpItemKindKeyword = { fg = C.base, bg = C.red },
            CmpItemKindText = { fg = C.base, bg = C.teal },
            CmpItemKindMethod = { fg = C.base, bg = C.blue },
            CmpItemKindConstructor = { fg = C.base, bg = C.blue },
            CmpItemKindFunction = { fg = C.base, bg = C.blue },
            CmpItemKindFolder = { fg = C.base, bg = C.blue },
            CmpItemKindModule = { fg = C.base, bg = C.blue },
            CmpItemKindConstant = { fg = C.base, bg = C.peach },
            CmpItemKindField = { fg = C.base, bg = C.green },
            CmpItemKindProperty = { fg = C.base, bg = C.green },
            CmpItemKindEnum = { fg = C.base, bg = C.green },
            CmpItemKindUnit = { fg = C.base, bg = C.green },
            CmpItemKindClass = { fg = C.base, bg = C.yellow },
            CmpItemKindVariable = { fg = C.base, bg = C.flamingo },
            CmpItemKindFile = { fg = C.base, bg = C.blue },
            CmpItemKindInterface = { fg = C.base, bg = C.yellow },
            CmpItemKindColor = { fg = C.base, bg = C.red },
            CmpItemKindReference = { fg = C.base, bg = C.red },
            CmpItemKindEnumMember = { fg = C.base, bg = C.red },
            CmpItemKindStruct = { fg = C.base, bg = C.blue },
            CmpItemKindValue = { fg = C.base, bg = C.peach },
            CmpItemKindEvent = { fg = C.base, bg = C.blue },
            CmpItemKindOperator = { fg = C.base, bg = C.blue },
            CmpItemKindTypeParameter = { fg = C.base, bg = C.blue },
            CmpItemKindCopilot = { fg = C.base, bg = C.teal },
            -- For base configs
            NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.mantle },
            FloatBorder = {
              fg = transparent_background and cp.blue or cp.mantle,
              bg = transparent_background and cp.none or cp.mantle,
            },
            CursorLineNr = { fg = cp.green },

            -- For native lsp configs
            DiagnosticVirtualTextError = { bg = cp.none },
            DiagnosticVirtualTextWarn = { bg = cp.none },
            DiagnosticVirtualTextInfo = { bg = cp.none },
            DiagnosticVirtualTextHint = { bg = cp.none },
            LspInfoBorder = { link = "FloatBorder" },

            -- For mason.nvim
            MasonNormal = { link = "NormalFloat" },

            -- For indent-blankline
            IblIndent = { fg = cp.surface0 },
            IblScope = { fg = cp.surface2, style = { "bold" } },

            -- For nvim-cmp and wilder.nvim
            Pmenu = { fg = cp.overlay2, bg = transparent_background and cp.none or cp.base },
            PmenuBorder = { fg = cp.surface1, bg = transparent_background and cp.none or cp.base },
            PmenuSel = { bg = cp.green, fg = cp.base },
            CmpItemAbbr = { fg = cp.overlay2 },
            CmpItemAbbrMatch = { fg = cp.blue, style = { "bold" } },
            CmpDoc = { link = "NormalFloat" },
            CmpDocBorder = {
              fg = transparent_background and cp.surface1 or cp.mantle,
              bg = transparent_background and cp.none or cp.mantle,
            },

            -- For fidget
            FidgetTask = { bg = cp.none, fg = cp.surface2 },
            FidgetTitle = { fg = cp.blue, style = { "bold" } },

            -- For nvim-notify
            NotifyBackground = { bg = cp.base },

            -- For nvim-tree
            NvimTreeRootFolder = { fg = cp.pink },
            NvimTreeIndentMarker = { fg = cp.surface2 },

            -- For trouble.nvim
            TroubleNormal = { bg = transparent_background and cp.none or cp.base },

            -- For telescope.nvim
            TelescopeMatching = { fg = cp.lavender },
            TelescopeResultsDiffAdd = { fg = cp.green },
            TelescopeResultsDiffChange = { fg = cp.yellow },
            TelescopeResultsDiffDelete = { fg = cp.red },

            -- For glance.nvim
            GlanceWinBarFilename = { fg = cp.subtext1, style = { "bold" } },
            GlanceWinBarFilepath = { fg = cp.subtext0, style = { "italic" } },
            GlanceWinBarTitle = { fg = cp.teal, style = { "bold" } },
            GlanceListCount = { fg = cp.lavender },
            GlanceListFilepath = { link = "Comment" },
            GlanceListFilename = { fg = cp.blue },
            GlanceListMatch = { fg = cp.lavender, style = { "bold" } },
            GlanceFoldIcon = { fg = cp.green },

            -- For nvim-treehopper
            TSNodeKey = {
              fg = cp.peach,
              bg = transparent_background and cp.none or cp.base,
              style = { "bold", "underline" },
            },

            -- For treesitter
            ["@keyword.return"] = { fg = cp.pink, style = clear },
            ["@error.c"] = { fg = cp.none, style = clear },
            ["@error.cpp"] = { fg = cp.none, style = clear },
          }
        end,
      },
    }
  end,
}
