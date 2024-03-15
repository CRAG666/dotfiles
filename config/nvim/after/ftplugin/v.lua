local v_analyzer = {
  name = "v_analyzer",
  cmd = { "v-analyzer" },
  root_patterns = { "v.mod" },
}
require("config.lsp").setup(v_analyzer)
