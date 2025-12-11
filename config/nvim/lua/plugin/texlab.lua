-- Función auxiliar para obtener el cliente
local function client_with_fn(fn)
  return function()
    local bufnr = vim.api.nvim_get_current_buf()
    local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'texlab' })[1]
    if not client then
      return vim.notify(
        ('texlab client not found in bufnr %d'):format(bufnr),
        vim.log.levels.ERROR
      )
    end
    fn(client, bufnr)
  end
end

-- Función para construir el documento
local function buf_build(client, bufnr)
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  client.request('textDocument/build', params, function(err, result)
    if err then
      error(tostring(err))
    end
    local texlab_build_status = {
      [0] = 'Success',
      [1] = 'Error',
      [2] = 'Failure',
      [3] = 'Cancelled',
    }
    vim.notify(
      'Build ' .. texlab_build_status[result.status],
      vim.log.levels.INFO
    )
  end, bufnr)
end

-- Función para forward search
local function buf_search(client, bufnr)
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  client.request('textDocument/forwardSearch', params, function(err, result)
    if err then
      error(tostring(err))
    end
    local texlab_forward_status = {
      [0] = 'Success',
      [1] = 'Error',
      [2] = 'Failure',
      [3] = 'Unconfigured',
    }
    vim.notify(
      'Search ' .. texlab_forward_status[result.status],
      vim.log.levels.INFO
    )
  end, bufnr)
end

-- Función para cancelar build
local function buf_cancel_build(client, bufnr)
  return client:exec_cmd({
    title = 'cancel',
    command = 'texlab.cancelBuild',
  }, { bufnr = bufnr })
end

-- Función para mostrar grafo de dependencias
local function dependency_graph(client)
  client.request(
    'workspace/executeCommand',
    { command = 'texlab.showDependencyGraph' },
    function(err, result)
      if err then
        return vim.notify(
          err.code .. ': ' .. err.message,
          vim.log.levels.ERROR
        )
      end
      vim.notify(
        'The dependency graph has been generated:\n' .. result,
        vim.log.levels.INFO
      )
    end,
    0
  )
end

-- Factory para comandos de limpieza
local function command_factory(kind)
  return function(client, bufnr)
    local win = vim.api.nvim_get_current_win()
    local params =
      vim.lsp.util.make_position_params(win, client.offset_encoding)
    client.request('workspace/executeCommand', {
      command = 'texlab.clean' .. kind,
      arguments = { params.textDocument.uri },
    }, function(err, result)
      if err then
        return vim.notify(
          err.code .. ': ' .. err.message,
          vim.log.levels.ERROR
        )
      end
      vim.notify(kind .. ' cleaned', vim.log.levels.INFO)
    end, bufnr)
  end
end

-- Función para encontrar entornos
local function buf_find_envs(client, bufnr)
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  client.request('textDocument/documentSymbol', params, function(err, result)
    if err then
      return vim.notify(err.code .. ': ' .. err.message, vim.log.levels.ERROR)
    end

    local environments = {}
    for _, symbol in ipairs(result or {}) do
      if symbol.kind == 5 then -- Class kind for environments
        table.insert(environments, symbol.name)
      end
    end

    if #environments == 0 then
      vim.notify('No environments found', vim.log.levels.INFO)
    else
      vim.notify(
        'Environments: ' .. table.concat(environments, ', '),
        vim.log.levels.INFO
      )
    end
  end, bufnr)
end

-- Función para cambiar entorno
local function buf_change_env(client, bufnr)
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)

  vim.ui.input({ prompt = 'New environment name: ' }, function(input)
    if not input or input == '' then
      return
    end

    client.request('workspace/executeCommand', {
      command = 'texlab.changeEnvironment',
      arguments = { params.textDocument.uri, params.position, input },
    }, function(err, result)
      if err then
        return vim.notify(
          err.code .. ': ' .. err.message,
          vim.log.levels.ERROR
        )
      end
      vim.notify('Environment changed to ' .. input, vim.log.levels.INFO)
    end, bufnr)
  end)
end

-- Tabla de comandos
local commands = {
  TexlabBuild = {
    client_with_fn(buf_build),
    description = 'Build the current buffer',
  },
  TexlabForward = {
    client_with_fn(buf_search),
    description = 'Forward search from current position',
  },
  TexlabCancelBuild = {
    client_with_fn(buf_cancel_build),
    description = 'Cancel the current build',
  },
  TexlabDependencyGraph = {
    client_with_fn(dependency_graph),
    description = 'Show the dependency graph',
  },
  TexlabCleanArtifacts = {
    client_with_fn(command_factory('Artifacts')),
    description = 'Clean the artifacts',
  },
  TexlabCleanAuxiliary = {
    client_with_fn(command_factory('Auxiliary')),
    description = 'Clean the auxiliary files',
  },
  TexlabFindEnvironments = {
    client_with_fn(buf_find_envs),
    description = 'Find the environments at current position',
  },
  TexlabChangeEnvironment = {
    client_with_fn(buf_change_env),
    description = 'Change the environment at current position',
  },
}

-- Autocomando para crear los comandos cuando texlab se adjunta
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client.name == 'texlab' then
      local bufnr = args.buf

      -- Crear cada comando en el buffer
      for cmd_name, cmd_def in pairs(commands) do
        vim.api.nvim_buf_create_user_command(
          bufnr,
          cmd_name,
          cmd_def[1],
          { desc = cmd_def.description }
        )
      end

      vim.notify('Texlab commands created', vim.log.levels.INFO)
    end
  end,
})
