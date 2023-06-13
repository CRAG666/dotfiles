-- utils.fg_bg("CmpItemKindClass", colors.base, colors.green)
-- utils.fg_bg("CmpItemKindInterface", colors.base, colors.teal)
-- utils.fg_bg("CmpItemKindConstructor", colors.base, colors.sky)
-- utils.fg_bg("CmpItemKindMethod", colors.base, colors.sapphire)
-- utils.fg_bg("CmpItemKindFunction", colors.base, colors.red)
-- utils.fg_bg("CmpItemKindVariable", colors.base, colors.peach)
-- utils.fg_bg("CmpItemKindProperty", colors.base, colors.yellow)
-- utils.fg_bg("CmpItemKindKeyword", colors.base, colors.blue)
-- utils.fg_bg("CmpItemKindField", colors.base, colors.rosewater)
-- utils.fg_bg("CmpItemKindText", colors.base, colors.mauve)
-- utils.fg_bg("CmpItemKindUnit", colors.base, colors.lavender)
-- utils.fg_bg("CmpItemKindValue", colors.base, colors.pink)
-- utils.fg_bg("CmpItemKindSnippet", colors.base, colors.maroon)
-- utils.fg_bg("CmpItemKindFile", colors.base, colors.flamingo)
-- utils.fg_bg("CmpItemKindFolder", colors.base, colors.subtext0)
-- utils.fg_bg("CmpItemKindTypeParameter", colors.base, colors.surface1)
-- end
-- end

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  -- lazy = true,
  config = function()
    local transparent_background = false -- Set background transparency here!

    require("catppuccin").setup {
      flavour = "mocha", -- Can be one of: latte, frappe, macchiato, mocha
      background = { light = "latte", dark = "mocha" },
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
      -- compile_path = vim.fn.stdpath "cache" .. "/catppuccin",
      styles = {
        comments = { "bold" },
        properties = { "italic" },
        functions = { "bold" },
        keywords = { "italic" },
        operators = { "bold" },
        conditionals = { "italic" },
        loops = { "italic" },
        -- booleans = { "bold", "italic" },
        numbers = {},
        types = { "italic" },
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
        aerial = false,
        alpha = false,
        barbar = false,
        beacon = false,
        cmp = true,
        coc_nvim = false,
        dap = { enabled = true, enable_ui = true },
        dashboard = false,
        fern = false,
        fidget = false,
        gitgutter = false,
        gitsigns = true,
        harpoon = true,
        hop = false,
        illuminate = true,
        indent_blankline = { enabled = true, colored_indent_levels = false },
        leap = true,
        lightspeed = false,
        lsp_saga = false,
        lsp_trouble = false,
        markdown = true,
        mason = true,
        mini = true,
        navic = { enabled = false },
        neogit = false,
        neotest = false,
        neotree = { enabled = false, show_root = false, transparent_panel = false },
        noice = true,
        notify = true,
        nvimtree = false,
        overseer = false,
        pounce = false,
        semantic_tokens = true,
        symbols_outline = true,
        telekasten = false,
        telescope = true,
        treesitter_context = true,
        ts_rainbow = false,
        vim_sneak = false,
        vimwiki = true,
        which_key = true,
      },
      color_overrides = {
        mocha = {
          -- rosewater = "#F5E0DC",
          -- flamingo = "#F2CDCD",
          -- mauve = "#DDB6F2",
          -- pink = "#F5C2E7",
          pink = "#FFBDD9",
          -- red = "#F28FAD",
          -- maroon = "#E8A2AF",
          -- peach = "#F8BD96",
          -- yellow = "#FAE3B0",
          -- yellow = "#FFD03C",
          -- green = "#ABE9B3",
          -- blue = "#96CDFB",
          -- sky = "#89DCEB",
          -- teal = "#B5E8E0",
          -- lavender = "#C9CBFF",
          --
          -- text = "#D9E0EE",
          -- subtext1 = "#BAC2DE",
          -- subtext0 = "#A6ADC8",
          -- overlay2 = "#C3BAC6",
          -- overlay1 = "#988BA2",
          -- overlay0 = "#6E6C7E",
          -- surface2 = "#6E6C7E",
          -- surface1 = "#575268",
          -- surface0 = "#302D41",
          --
          -- base = "#1E1E2E",
          -- mantle = "#1A1826",
          -- crust = "#161320",
        },
      },
      custom_highlights = function(C)
        return {
          -- norg
          ["@neorg.headings.1.title.norg"] = { fg = C.pink },
          ["@neorg.links.location.heading.1.norg"] = { fg = C.pink },
          ["@neorg.headings.2.title.norg"] = { fg = C.yellow },
          ["@neorg.links.location.heading.2.norg"] = { fg = C.yellow },
          ["@neorg.links.description.norg"] = { fg = C.teal, style = { "underline" } },
          -- StatusLine
          StatusLine = { fg = "NONE", bg = C.base },
          TabLineFill = { bg = C.crust },
          TabLine = { fg = C.overlay0, bg = C.crust },
          TabLineSel = { fg = C.lavender, bg = C.base },
          Folded = { fg = C.yellow, bg = C.crust },
          -- StatusColumn
          -- StatusColumnBufferCursorLine = { bg = C.blue },
          -- Telescope
          TelescopePromptNormal = { fg = C.flamingo, bg = C.base },
          TelescopePromptBorder = { bg = C.base },
          TelescopePromptPrefix = { fg = C.sapphire, bg = C.base },
          TelescopePromptCounter = { fg = "white" },
          TelescopePromptTitle = { fg = C.base, bg = C.red },
          TelescopePreviewTitle = { fg = C.base, bg = C.teal },
          TelescopeResultsTitle = { fg = C.base, bg = C.peach },
          TelescopeSelectionCaret = { fg = C.red },
          TelescopeMatching = { fg = C.green },
          --- Lsp
          LspLens = { fg = C.lavender },
          -- Cmp config
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
        }
      end,
      highlight_overrides = {
        mocha = function(cp)
          return {
            --       -- For base configs.
            NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.base },
            CursorLineNr = { fg = cp.green },
            --       Search = { bg = cp.surface1, fg = cp.pink, style = { "bold" } },
            --       IncSearch = { bg = cp.pink, fg = cp.surface1 },
            --       Keyword = { fg = cp.pink },
            --       Type = { fg = cp.blue },
            --       Typedef = { fg = cp.yellow },
            --       StorageClass = { fg = cp.red, style = { "italic" } },
            --
            -- For native lsp configs.
            DiagnosticVirtualTextError = { bg = cp.none },
            DiagnosticVirtualTextWarn = { bg = cp.none },
            DiagnosticVirtualTextInfo = { bg = cp.none },
            DiagnosticVirtualTextHint = { fg = cp.rosewater, bg = cp.none },
            --
            --       DiagnosticHint = { fg = cp.rosewater },
            --       LspDiagnosticsDefaultHint = { fg = cp.rosewater },
            --       LspDiagnosticsHint = { fg = cp.rosewater },
            --       LspDiagnosticsVirtualTextHint = { fg = cp.rosewater },
            --       LspDiagnosticsUnderlineHint = { sp = cp.rosewater },
            --
            --       -- For fidget.
            --       FidgetTask = { bg = cp.none, fg = cp.surface2 },
            --       FidgetTitle = { fg = cp.blue, style = { "bold" } },
            --
            --       -- For trouble.nvim
            --       TroubleNormal = { bg = cp.base },
            --
            --       -- For treesitter.
            --       ["@field"] = { fg = cp.rosewater },
            --       ["@property"] = { fg = cp.yellow },
            --
            --       ["@include"] = { fg = cp.teal },
            --       -- ["@operator"] = { fg = cp.sky },
            --       ["@keyword.operator"] = { fg = cp.sky },
            ["@punctuation.special"] = { fg = cp.maroon },
            --
            --       -- ["@float"] = { fg = cp.peach },
            --       -- ["@number"] = { fg = cp.peach },
            --       -- ["@boolean"] = { fg = cp.peach },
            --
            --       ["@constructor"] = { fg = cp.lavender },
            --       -- ["@constant"] = { fg = cp.peach },
            --       -- ["@conditional"] = { fg = cp.mauve },
            --       -- ["@repeat"] = { fg = cp.mauve },
            --       ["@exception"] = { fg = cp.peach },
            --
            --       ["@constant.builtin"] = { fg = cp.lavender },
            --       -- ["@function.builtin"] = { fg = cp.peach, style = { "italic" } },
            --       -- ["@type.builtin"] = { fg = cp.yellow, style = { "italic" } },
            --       ["@type.qualifier"] = { link = "@keyword" },
            --       ["@variable.builtin"] = { fg = cp.red, style = { "italic" } },
            --
            --       -- ["@function"] = { fg = cp.blue },
            --       ["@function.macro"] = { fg = cp.red, style = {} },
            --       ["@parameter"] = { fg = cp.rosewater },
            --       ["@keyword"] = { fg = cp.red, style = { "italic" } },
            --       ["@keyword.function"] = { fg = cp.maroon },
            --       ["@keyword.return"] = { fg = cp.pink, style = {} },
            --
            --       -- ["@text.note"] = { fg = cp.base, bg = cp.blue },
            --       -- ["@text.warning"] = { fg = cp.base, bg = cp.yellow },
            --       -- ["@text.danger"] = { fg = cp.base, bg = cp.red },
            --       -- ["@constant.macro"] = { fg = cp.mauve },
            --
            --       -- ["@label"] = { fg = cp.blue },
            --       ["@method"] = { fg = cp.blue, style = { "italic" } },
            --       ["@namespace"] = { fg = cp.rosewater, style = {} },
            --
            --       ["@punctuation.delimiter"] = { fg = cp.teal },
            --       ["@punctuation.bracket"] = { fg = cp.overlay2 },
            --       -- ["@string"] = { fg = cp.green },
            --       -- ["@string.regex"] = { fg = cp.peach },
            --       ["@type"] = { fg = cp.yellow },
            --       ["@variable"] = { fg = cp.text },
            --       ["@tag.attribute"] = { fg = cp.mauve, style = { "italic" } },
            --       ["@tag"] = { fg = cp.peach },
            --       ["@tag.delimiter"] = { fg = cp.maroon },
            --       ["@text"] = { fg = cp.text },
            --
            --       -- ["@text.uri"] = { fg = cp.rosewater, style = { "italic", "underline" } },
            --       -- ["@text.literal"] = { fg = cp.teal, style = { "italic" } },
            --       -- ["@text.reference"] = { fg = cp.lavender, style = { "bold" } },
            --       -- ["@text.title"] = { fg = cp.blue, style = { "bold" } },
            --       -- ["@text.emphasis"] = { fg = cp.maroon, style = { "italic" } },
            --       -- ["@text.strong"] = { fg = cp.maroon, style = { "bold" } },
            --       -- ["@string.escape"] = { fg = cp.pink },
            --
            --       -- ["@property.toml"] = { fg = cp.blue },
            --       -- ["@field.yaml"] = { fg = cp.blue },
            --
            --       -- ["@label.json"] = { fg = cp.blue },
            --
            --       ["@function.builtin.bash"] = { fg = cp.red, style = { "italic" } },
            --       ["@parameter.bash"] = { fg = cp.yellow, style = { "italic" } },
            --
            ["@field.lua"] = { fg = cp.lavender },
            --       ["@constructor.lua"] = { fg = cp.flamingo },
            --       ["@variable.builtin.lua"] = { fg = cp.flamingo, style = { "italic" } },
            --
            --       ["@constant.java"] = { fg = cp.teal },
            --
            --       ["@property.typescript"] = { fg = cp.lavender, style = { "italic" } },
            --       -- ["@constructor.typescript"] = { fg = cp.lavender },
            --
            --       -- ["@constructor.tsx"] = { fg = cp.lavender },
            --       -- ["@tag.attribute.tsx"] = { fg = cp.mauve },
            --
            --       ["@type.css"] = { fg = cp.lavender },
            --       ["@property.css"] = { fg = cp.yellow, style = { "italic" } },
            --
            --       ["@type.builtin.c"] = { fg = cp.yellow, style = {} },
            --
            --       ["@property.cpp"] = { fg = cp.text },
            --       ["@type.builtin.cpp"] = { fg = cp.yellow, style = {} },
            --
            --       -- ["@symbol"] = { fg = cp.flamingo },
          }
        end,
      },
    }
    -- vim.cmd.colorscheme "catppuccin"
  end,
}
