---@param config {args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.input("Run with args: ", table.concat(args, " ")) --[[@as string]]
    return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
  end
  return config
end

return {
  "mfussenegger/nvim-dap",

  dependencies = {

    -- fancy UI for the debugger
    {
      "rcarriga/nvim-dap-ui",
      -- stylua: ignore
      keys = {
        { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
        { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
      },
      opts = {},
      config = function(_, opts)
        -- setup dap config by VsCode launch.json file
        -- require("dap.ext.vscode").load_launchjs()
        local dap = require "dap"
        local dapui = require "dapui"
        dapui.setup(opts)
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open {}
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close {}
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close {}
        end
      end,
    },

    -- virtual text for the debugger
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },

    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = "mason.nvim",
      cmd = { "DapInstall", "DapUninstall" },
      opts = {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
        },
      },
    },
  },

  -- stylua: ignore
  keys = {
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('[B]reakpoint condition: ')) end, desc = "Breakpoint Condition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle [b]reakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Debug [c]ontinue" },
    { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with [a]rgs" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to [C]ursor" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "[g]o to line (no execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step [i]nto" },
    { "<leader>dj", function() require("dap").down() end, desc = "Debug Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Debug Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run [l]ast" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step [o]ut" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "Step [O]ver" },
    { "<leader>dp", function() require("dap").pause() end, desc = "[p]ause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle [r]EPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "[s]ession" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "[t]erminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "[w]idgets" },
  },

  config = function()
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    for name, sign in pairs(Icons.dap) do
      sign = type(sign) == "table" and sign or { sign }
      vim.fn.sign_define(
        "Dap" .. name,
        { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
      )
    end
  end,
}
