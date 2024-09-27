return {
  {
    event = "InsertEnter",
    "m4xshen/autoclose.nvim",
    config = true,
  },
  {
    "chaoren/vim-wordmotion",
    keys = {
      { "w" },
      { "W" },
      { "b" },
      { "B" },
      { "e" },
      { "E" },
      { "ge" },
      { "gE" },
      { "caw" },
      { "caW" },
      { "ciw" },
      { "ciW" },
      { "daw" },
      { "daW" },
      { "diw" },
      { "diW" },
      { "yaw" },
      { "daW" },
      { "yiw" },
      { "yiW" },
    },
  },
  {
    "kylechui/nvim-surround",
    keys = { { "cs" }, { "ds" }, { "ys" } },
    config = true,
  },
  {
    "preservim/vim-pencil",
    cmd = {
      "Pencil",
      "TogglePencil",
      "SoftPencil",
      "HardPencil",
    },
    init = function()
      vim.g["pencil#wrapModeDefault"] = "soft"
      vim.g["pencil#autoformat"] = 1
      vim.g["pencil#textwidth"] = 80
    end,
  },
  {
    "folke/ts-comments.nvim",
    opts = {
      lang = {
        astro = "<!-- %s -->",
        axaml = "<!-- %s -->",
        blueprint = "// %s",
        c = "// %s",
        c_sharp = "// %s",
        clojure = { ";; %s", "; %s" },
        cpp = "// %s",
        cs_project = "<!-- %s -->",
        cue = "// %s",
        fsharp = "// %s",
        fsharp_project = "<!-- %s -->",
        gleam = "// %s",
        glimmer = "{{! %s }}",
        graphql = "# %s",
        handlebars = "{{! %s }}",
        hcl = "# %s",
        html = "<!-- %s -->",
        hyprlang = "# %s",
        ini = "; %s",
        ipynb = "# %s",
        javascript = {
          "// %s", -- default commentstring when no treesitter node matches
          "/* %s */",
          call_expression = "// %s", -- specific commentstring for call_expression
          jsx_attribute = "// %s",
          jsx_element = "{/* %s */}",
          jsx_fragment = "{/* %s */}",
          spread_element = "// %s",
          statement_block = "// %s",
        },
        php = "// %s",
        rego = "# %s",
        rescript = "// %s",
        rust = { "// %s", "/* %s */" },
        sql = "-- %s",
        svelte = "<!-- %s -->",
        terraform = "# %s",
        tex = "% %s",
        tsx = {
          "// %s", -- default commentstring when no treesitter node matches
          "/* %s */",
          call_expression = "// %s", -- specific commentstring for call_expression
          jsx_attribute = "// %s",
          jsx_element = "{/* %s */}",
          jsx_fragment = "{/* %s */}",
          spread_element = "// %s",
          statement_block = "// %s",
        },
        twig = "{# %s #}",
        typescript = { "// %s", "/* %s */" }, -- langs can have multiple commentstrings
        vue = "<!-- %s -->",
        xaml = "<!-- %s -->",
      },
    },
    event = "VeryLazy",
  },
  {
    "quentingruber/pomodoro.nvim",
    lazy = false, -- needed so the pomodoro can start at launch
    opts = {
      start_at_launch = true,
      work_duration = 25,
      break_duration = 5,
      delay_duration = 1, -- The additionnal work time you get when you delay a break
      long_break_duration = 15,
      breaks_before_long = 4,
    },
  },
}
