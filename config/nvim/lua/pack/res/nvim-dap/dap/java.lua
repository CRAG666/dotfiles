-- The debug adapter for java is an extension to jdtls: java-debug
-- (https://github.com/microsoft/java-debug)
--
-- As a result many of the debug adapter configs has to be retrieved from
-- jdtls, e.g. port number, project name, main class, module paths, etc.

local M = {}

---@param buf? integer
---@return vim.lsp.Client?
local function get_jdtls_client(buf)
  return vim.lsp.get_clients({
    name = 'jdtls',
    bufnr = vim._resolve_bufnr(buf),
  })[1]
end

---Execute a jdtls command, yielding the running coroutine until it responds
---@param client vim.lsp.Client
---@param command string
---@param arguments? any[]
---@return lsp.ResponseError? err
---@return any response
local function execute_command(client, command, arguments)
  local co = coroutine.running()
  client:request(
    'workspace/executeCommand',
    { command = command, arguments = arguments },
    function(err, response)
      coroutine.resume(co, err, response)
    end
  )
  return coroutine.yield()
end

M.adapter = function(cb)
  local client = get_jdtls_client()
  if not client then
    vim.notify(
      '[dap-java] no jdtls client attached to current buffer',
      vim.log.levels.ERROR
    )
    return
  end

  client:request(
    'workspace/executeCommand',
    { command = 'vscode.java.startDebugSession', arguments = {} },
    function(err, response)
      if err then
        vim.notify(
          '[dap-java] error starting debug session: ' .. vim.inspect(err),
          vim.log.levels.ERROR
        )
        return
      end

      local response_type = type(response)
      local port = response_type == 'number' and response
        or response_type == 'table'
          and (response.port or response.debugServer or response.serverPort or response[1])
      if not port then
        vim.notify(
          '[dap-java] could not determine debug server port from response: '
            .. vim.inspect(response),
          vim.log.levels.ERROR
        )
        return
      end

      cb({
        type = 'server',
        host = '127.0.0.1',
        port = port,
      })
    end,
    0
  )
end

---Config provider, resolved by jdtls on each `dap.continue()` inside
---nvim-dap's coroutine, see `:h dap-providers-configs`
---
---Ported from
---https://github.com/mfussenegger/nvim-jdtls/blob/master/lua/jdtls/dap.lua
---@param buf integer
---@return dap.Configuration[]
function M.provider(buf)
  local client = get_jdtls_client(buf)
  if not client then
    return {}
  end

  local err, classes = execute_command(client, 'vscode.java.resolveMainClass')
  if err then
    vim.notify(
      '[dap-java] error resolving main class: ' .. vim.inspect(err),
      vim.log.levels.ERROR
    )
    return {}
  end

  local configs = {}
  local java_exec_path = vim.fn.exepath('java')
  for _, class in ipairs(classes or {}) do
    local _, paths = execute_command(
      client,
      'vscode.java.resolveClasspath',
      { class.mainClass, class.projectName }
    )
    if paths then
      table.insert(configs, {
        cwd = client.config.root_dir,
        type = 'java',
        request = 'launch',
        console = 'integratedTerminal',
        name = string.format(
          'Launch %s: %s',
          class.projectName,
          class.mainClass
        ),
        projectName = class.projectName,
        mainClass = class.mainClass,
        modulePaths = paths[1],
        classPaths = paths[2],
        javaExec = java_exec_path,
      })
    end
  end
  return configs
end

return M
