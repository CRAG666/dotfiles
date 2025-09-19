return {
  src = 'https://github.com/jbyuki/one-small-step-for-vimkind',
  data = {
    deps = 'https://github.com/mfussenegger/nvim-dap',
    cmds = 'DapOSVLaunchServer',
    postload = function()
      local utils = require('utils')
      local osv = require('osv')

      vim.api.nvim_create_user_command('DapOSVLaunchServer', function(args)
        local opts = utils.cmd.parse_cmdline_args(args.fargs)
        opts.port = opts.port or 8086
        osv.launch(opts)
      end, {
        nargs = '*',
        complete = utils.cmd.complete({}, {
          'host',
          'port',
          config_file = function(arglead)
            return vim.fn.getcompletion(
              (arglead:gsub('^%-%-[%w_]*=', '')),
              'file'
            )
          end,
        }),
        desc = [[
          Launches an osv debug server.
          Usage: DapOSVLaunchServer [--host=<host>] [--port=<port>] [--config_file=<config_file>]
        ]],
      })
    end,
  },
}
