local utils = require('utils')

require("telescope").setup {
    defaults = {
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
        },
        prompt_position = "bottom",
        prompt_prefix = " ",
        selection_caret = " ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "horizontal",
        layout_defaults = {
            horizontal = {
                mirror = false,
                preview_width = 0.5
            },
            vertical = {
                mirror = false
            }
        },
        file_sorter = require "telescope.sorters".get_fuzzy_file,
        file_ignore_patterns = {},
        generic_sorter = require "telescope.sorters".get_generic_fuzzy_sorter,
        shorten_path = true,
        winblend = 0,
        width = 0.75,
        preview_cutoff = 120,
        results_height = 1,
        results_width = 0.8,
        border = {},
        borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
        color_devicons = true,
        use_less = true,
        set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
        file_previewer = require "telescope.previewers".vim_buffer_cat.new,
        grep_previewer = require "telescope.previewers".vim_buffer_vimgrep.new,
        qflist_previewer = require "telescope.previewers".vim_buffer_qflist.new,
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require "telescope.previewers".buffer_previewer_maker
    },
    extensions = {
        media_files = {
            filetypes = {"png", "webp", "jpg", "jpeg"},
            find_cmd = "rg" -- find command (defaults to `fd`)
        }
    }
}

require("telescope").load_extension("media_files")

local opt = {noremap = true, silent = true}

-- mappings
utils.map(
    "n",
    "µ",
    [[<Cmd>lua require('telescope').extensions.media_files.media_files()<CR>]],
    opt
)

utils.map("n", "<Leader>b", [[<Cmd>lua require('telescope.builtin').buffers()<CR>]], opt)
utils.map("n", "<Leader>fh", [[<Cmd>lua require('telescope.builtin').help_tags()<CR>]], opt)
utils.map("n", "<Leader>fo", [[<Cmd>lua require('telescope.builtin').oldfiles()<CR>]], opt)
utils.map('n', 'ł',  [[<Cmd>lua require('telescope.builtin').git_status()<CR>]], opts)
--AltGr .
utils.map('n', '·', [[<cmd>lua require('telescope.builtin').builtin.commands()<CR>]], opts)
-- Find files
--AltGr p
utils.map('n', 'þ' , [[<cmd>lua require('telescope.builtin').file_browser()<CR>]], opt)
utils.map('i', 'þ' , [[<cmd>lua require('telescope.builtin').file_browser()<CR>]], opt)
utils.map('n', '<leader>f', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], opts)
utils.map('n', '<leader>fg', [[<cmd>lua require('telescope.builtin').git_files()<CR>]], opts)
-- Grep Files
utils.map('n', '<leader>g', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], opts)
utils.map('n', '<leader>gg', [[<cmd>lua require('telescope.builtin').grep_string()<CR>]], opts)
utils.map('n', '<leader>h', [[<cmd>lua require('telescope.builtin').command_history()<CR>]], opts)


-- highlights

local cmd = vim.cmd

cmd "hi TelescopeBorder   guifg=#2a2e36"
cmd "hi TelescopePromptBorder   guifg=#2a2e36"
cmd "hi TelescopeResultsBorder  guifg=#2a2e36"
cmd "hi TelescopePreviewBorder  guifg=#525865"
