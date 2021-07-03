local utils = require 'utils'
local lspc = require 'lspconfig'
require'lspkind'.init({})

local on_attach = function(client, bufnr)

    require'lsp_signature'.on_attach(client)
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = {noremap = true, silent = true}
    utils.map('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    utils.map('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    utils.map('n', 'ħ', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    utils.map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    -- utils.map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    utils.map('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    utils.map('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    utils.map('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    utils.map('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    utils.map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    utils.map('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    -- utils.map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    -- utils.map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    -- utils.map('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    -- utils.map('n', '<A-Left>', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    -- utils.map('n', '<A-Right>', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        utils.map("n", "<leader>lf",
                       "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    elseif client.resolved_capabilities.document_range_formatting then
        utils.map("n", "<leader>lf",
                       "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
        hi LspReferenceRead cterm=bold ctermbg=red guibg=DarkOrchid3 guifg=#f2f2f2
        hi LspReferenceText cterm=bold ctermbg=red guibg=DarkOrchid3 guifg=#f2f2f2
        hi LspReferenceWrite cterm=bold ctermbg=red guibg=DarkOrchid3 guifg=#f2f2f2
        augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
        ]], false)
    end
end

local function make_base_config()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.codeAction = {
    dynamicRegistration = true,
    codeActionLiteralSupport = {
        codeActionKind = {
            valueSet = (function()
                local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
                table.sort(res)
                return res
            end)()
        }
      }
    }
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {"documentation", "detail", "additionalTextEdits"}
    }
    return {capabilities = capabilities, on_attach = on_attach}
end

local flake8 = {
  lintCommand = "flake8 ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "black --line-length 79 ${INPUT}",
  formatStdin = true
}
-- capabilities = capabilities,
local servers = {"pyright", "elixirls", "ccls", "tsserver", "dockerls", "bashls"}
for _, lsp in ipairs(servers) do
    lspc[lsp].setup(make_base_config())
end

lspc.efm.setup {
  init_options = {documentFormatting = true},
  --[[ root_dir = function()
    return vim.fn.getcwd()
  end, ]]
  settings = {
    rootMarkers = {".git/"},
    languages = {
      python = {flake8},
    }
  },
  filetypes = {
    "python",
  },
}
