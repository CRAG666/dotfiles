local function setup()
  local utils = require "utils.keymaps"
  local rest = require "rest-nvim"
  rest.setup {
    result_split_horizontal = false,
    result_split_in_place = false,
    skip_ssl_verification = true,
    encode_url = true,
    highlight = {
      enabled = true,
      timeout = 150,
    },
    result = {
      show_url = true,
      show_http_info = true,
      show_headers = true,
      formatters = {
        json = "jq",
        html = function(body)
          return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
        end,
      },
    },
    jump_to_request = false,
    env_file = ".env",
    custom_dynamic_variables = {},
    yank_dry_run = true,
  }
  utils.map("n", "<leader><leader>r", rest.run, { desc = "Run Endpoint" })
end
return {
  {
    "rest-nvim/rest.nvim",
    ft = { "http" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = setup,
  },
}
