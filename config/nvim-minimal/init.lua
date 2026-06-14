local disabled_built_ins = {
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"2html_plugin",
	"logiPat",
	"rrhelper",
	"spellfile_plugin",
	"matchit",
	"compiler",
	"ftplugin",
	"rplugin",
	"synmenu",
	"syntax",
	"tohtml",
	"tutor",
	"tutor_mode_plugin",
}

for _, plugin in ipairs(disabled_built_ins) do
	vim.g["loaded_" .. plugin] = 1
end

vim.cmd.colorscheme("macro")

vim.api.nvim_create_autocmd("FileType", {
	once = true,
	group = vim.api.nvim_create_augroup("WinBarSetup", {}),
	callback = function()
		if vim.g.loaded_winbar ~= nil then
			return
		end

		local winbar = require("plugin.winbar")
		local api = require("plugin.winbar.api")
		winbar.setup({ bar = { hover = false } })

    -- stylua: ignore start
    vim.keymap.set('n', '<leader>w', api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[w', api.goto_context_start, { desc = 'Go to start of current context' })
    vim.keymap.set('n', ']w', api.select_next_context, { desc = 'Select next context' })
		-- stylua: ignore end
	end,
})

---Load ui elements e.g. tabline, statusline, statuscolumn
---@param name string
local function load_ui(name)
	local loaded_flag = "loaded_" .. name
	if vim.g[loaded_flag] ~= nil then
		return
	end
	vim.g[loaded_flag] = true
	vim.opt[name] = string.format("%%!v:lua.require'plugin.%s'()", name)
end

load_ui("tabline")
load_ui("statusline")
load_ui("statuscolumn")

require("core.keymaps")
require("plugin.term")
require("plugin.run_code")

vim.pack.add({ { src = "https://github.com/chaoren/vim-wordmotion" } })
vim.pack.add({ { src = "https://github.com/kylechui/nvim-surround" } })
require("nvim-surround").setup({})

