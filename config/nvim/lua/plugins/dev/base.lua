local key = require('utils.keymap')
local fn = require('utils.fn') -- Asumimos que tu función M.lazy_load está aquí

--------------------------------------------------------------------------------
--  Mason: Carga por Comando y Mapeo
--------------------------------------------------------------------------------

-- Opciones de Mason. Se definen una vez y se reutilizan.
local mason_opts = {
  ensure_installed = {
    'stylua',
    'shfmt',
    'lua-language-server',
    'efm',
    'luacheck',
  },
}

-- 💡 Función central para cargar y configurar Mason.
-- Es la forma más limpia de manejar la carga activada por el usuario.
local function ensure_mason()
  if package.loaded['mason'] then
    return
  end
  vim.pack.add({ { src = 'https://github.com/williamboman/mason.nvim' } })
  require('mason').setup(mason_opts)
end

-- Mapeo de tecla para abrir Mason.
key.map('n', '<leader>pm', function()
  ensure_mason()
  vim.cmd.Mason()
end, { desc = '[P]ackage [M]anager' })

-- Comando para instalar todas las herramientas.
vim.api.nvim_create_user_command('MasonInstallAll', function()
  ensure_mason()
  local mr = require('mason-registry')
  mr.refresh(function()
    for _, tool in ipairs(mason_opts.ensure_installed) do
      local p = mr.get_package(tool)
      if not p:is_installed() then
        p:install()
      end
    end
    vim.notify(
      'Mason: Comprobación de paquetes finalizada.',
      vim.log.levels.INFO
    )
  end)
end, { desc = 'Instala todas las herramientas de Mason definidas' })

--------------------------------------------------------------------------------
-- Plugins simples cargados por mapeo de tecla
--------------------------------------------------------------------------------

-- Undotree: Este patrón simple es muy eficiente.
key.map('n', '<leader>ut', function()
  vim.pack.add({ { src = 'https://github.com/mbbill/undotree' } })
  vim.cmd.UndotreeToggle()
end, { desc = '[U]ndotree' })

-- Minty: Igual que undotree, simple y efectivo.
key.map('n', '<leader>my', function()
  vim.pack.add({ { src = 'https://github.com/nvzone/minty' } })
  vim.cmd.Minty()
end, { desc = '[M]int[y]' })

--------------------------------------------------------------------------------
-- Plugins cargados por eventos usando lazy_load
--------------------------------------------------------------------------------

-- ✅ ts-comments: Se carga perezosamente la primera vez que abres un archivo compatible.
fn.lazy_load('FileType', 'ts-comments', function()
  vim.pack.add({ { src = 'https://github.com/folke/ts-comments.nvim' } })
  require('ts-comments').setup({})
end, {
  pattern = { 'typescript', 'javascript', 'lua', 'go', 'rust', 'python' },
  desc = 'Carga ts-comments para tipos de archivo soportados',
})

-- ✅ Utilidades de LSP: Se cargan una sola vez cuando un servidor LSP se conecta.
-- Este es el lugar perfecto para cargar también dependencias como Plenary.
fn.lazy_load('LspAttach', 'LSP_Utils', function()
  -- Se carga Plenary junto con los plugins que dependen de él. ¡No antes!
  vim.pack.add({
    { src = 'https://github.com/rachartier/tiny-code-action.nvim' },
    { src = 'https://github.com/VidocqH/lsp-lens.nvim' },
    { src = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim' },
  })

  require('lsp-lens').setup({})
  require('tiny-code-action').setup({})
  require('tiny-inline-diagnostic').setup()

  -- El mapeo se crea solo después de que el plugin ha sido cargado.
  key.map('n', '<C-.>', function()
    require('tiny-code-action').code_action()
  end, { desc = 'Code Action' })
end, {
  desc = 'Carga utilidades de LSP al adjuntar un servidor',
})
