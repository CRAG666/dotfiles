-- The debug adapter for java is an extension to jdtls: java-debug
-- (https://github.com/microsoft/java-debug)
--
-- As a result many of the debug adapter configs has to be retrieved from
-- jdtls, e.g. port number, project name, main class, module paths, etc.

local M = {}

local JDTLS_ATTACH_TIMEOUT = 4000
local JDTLS_ATTACH_INTERVAL = 100

local JDTLS_REQUEST_TIMEOUT = 4000
local JDTLS_REQUEST_INTERVAL = 100

---Wait for jdtls client to attach to current buffer
---@param buf? integer
---@return vim.lsp.Client?
local function wait_jdtls_client(buf)
  local client ---@type vim.lsp.Client?

  vim.wait(JDTLS_ATTACH_TIMEOUT, function()
    client = unpack(vim.lsp.get_clients({
      name = 'jdtls',
      bufnr = vim._resolve_bufnr(buf),
    }))
    return client ~= nil
  end, JDTLS_ATTACH_INTERVAL)

  return client
end

M.adapter = function(cb)
  local client = wait_jdtls_client()
  if not client then
    vim.notify(
      '[dap-java] no jdtls client attached to current buffer',
      vim.log.levels.ERROR
    )
    return
  end

  client:request(
    vim.lsp.protocol.Methods.workspace_executeCommand,
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

-- Ported from
-- https://github.com/mfussenegger/nvim-jdtls/blob/master/lua/jdtls/dap.lua
M.config = (function()
  local client = wait_jdtls_client()
  if not client then
    vim.notify(
      '[dap-java] no jdtls client attached to current buffer',
      vim.log.levels.ERROR
    )
    return {}
  end

  local configs = {}
  local done = false

  client:request(
    vim.lsp.protocol.Methods.workspace_executeCommand,
    { command = 'vscode.java.resolveMainClass' },
    function(err, classes)
      if err then
        vim.notify(
          '[dap-java] error resolving main class: ' .. vim.inspect(err),
          vim.log.levels.ERROR
        )
        done = true
        return
      end

      classes = classes or {}

      local pending = #classes
      if pending == 0 then
        done = true
        return
      end

      local java_exec_path = vim.fn.exepath('java')

      for _, c in ipairs(classes) do
        client:request(vim.lsp.protocol.Methods.workspace_executeCommand, {
          command = 'vscode.java.resolveClasspath',
          arguments = { c.mainClass, c.projectName },
        }, function(_, paths)
          if paths then
            table.insert(configs, {
              cwd = client.config.root_dir,
              type = 'java',
              request = 'launch',
              console = 'integratedTerminal',
              name = string.format(
                'Launch %s: %s',
                c.projectName,
                c.mainClass
              ),
              projectName = c.projectName,
              mainClass = c.mainClass,
              modulePaths = paths[1],
              classPaths = paths[2],
              javaExec = java_exec_path,
            })
          end
          pending = pending - 1
          if pending == 0 then
            done = true
          end
        end)
      end
    end
  )

  -- Wait for async callbacks to populate configs
  vim.wait(JDTLS_REQUEST_TIMEOUT, function()
    return done
  end, JDTLS_REQUEST_INTERVAL)
  return configs
end)()

return M
