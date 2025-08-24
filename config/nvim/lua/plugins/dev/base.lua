local key = require('utils.keymap')
local fn = require('utils.fn') -- Asumimos que tu función M.lazy_load está aquí

--------------------------------------------------------------------------------
--  Mason: Carga por Comando y Mapeo
--------------------------------------------------------------------------------

-- 💡 Función central para cargar y configurar Mason.
-- Es la forma más limpia de manejar la carga activada por el usuario.
local function setup_mason()
  if package.loaded['mason'] then
    return
  end
  vim.pack.add({
    'https://github.com/williamboman/mason.nvim',
    'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  })
  require('mason').setup()
  vim.g.mason = vim.g.mason or {}
  require('mason-tool-installer').setup({
    ensure_installed = vim.g.mason,
  })
  vim.cmd.MasonToolsInstallSync()
end

-- Mapeo de tecla para abrir Mason.
key.map('n', '<leader>pm', function()
  setup_mason()
  vim.cmd.Mason()
end, { desc = '[P]ackage [M]anager' })

--------------------------------------------------------------------------------
-- Plugins simples cargados por mapeo de tecla
--------------------------------------------------------------------------------

-- Undotree: Este patrón simple es muy eficiente.
key.map('n', '<leader>ut', function()
  vim.pack.add({ { src = 'https://github.com/mbbill/undotree' } })
  vim.cmd.UndotreeToggle()
end, { desc = '[U]ndotree' })

-- Minty: Igual que undotree, simple y efectivo.
-- key.map('n', '<leader>my', function()
--   vim.pack.add({ { src = 'https://github.com/nvzone/minty' } })
--   vim.cmd.Minty()
-- end, { desc = '[M]int[y]' })

--------------------------------------------------------------------------------
-- Plugins cargados por eventos usando lazy_load
--------------------------------------------------------------------------------

-- ✅ ts-comments: Se carga perezosamente la primera vez que abres un archivo compatible.
fn.lazy_load('FileType', 'ts-comments', function()
  vim.pack.add({ { src = 'https://github.com/folke/ts-comments.nvim' } })
  require('ts-comments').setup({})
end)

-- ✅ Utilidades de LSP: Se cargan una sola vez cuando un servidor LSP se conecta.
-- Este es el lugar perfecto para cargar también dependencias como Plenary.
fn.lazy_load('LspAttach', 'tiny-code-action', function()
  vim.pack.add({
    { src = 'https://github.com/rachartier/tiny-code-action.nvim' },
  })

  require('tiny-code-action').setup({ picker = 'snacks' })

  -- El mapeo se crea solo después de que el plugin ha sido cargado.
  key.map('n', '<C-.>', function()
    require('tiny-code-action').code_action()
  end, { desc = 'Code Action' })
end, {
  desc = 'Carga utilidades de LSP al adjuntar un servidor',
})
