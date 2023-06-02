function _G.CustomFoldText()
  return vim.fn.getline(vim.v.foldstart) .. " ... " .. vim.fn.getline(vim.v.foldend):gsub("^%s*", "")
end
vim.opt.foldtext = "v:lua.CustomFoldText()"
-- vim.o.fillchars = [[eob: ,fold: ,foldopen:▼,foldsep: ,foldclose:⏵]]
vim.opt.fillchars:append { fold = " " }
