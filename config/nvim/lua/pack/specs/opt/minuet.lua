return {
  src = 'https://github.com/milanglacier/minuet-ai.nvim',
  data = {
    events = { 'InsertEnter' },
    postload = function()
      require('minuet').setup({
        provider = 'openai_fim_compatible',
        n_completions = 1,
        provider_options = {
          openai_fim_compatible = {
            -- Ollama ignores the key, minuet only requires the env var to be set
            api_key = 'TERM',
            name = 'Ollama',
            -- Cluster ollama through `otun-up`
            end_point = 'http://localhost:11652/v1/completions',
            model = 'qwen2.5-coder:14b-base',
            optional = { max_tokens = 128, stop = { '\n\n' } },
          },
        },
        virtualtext = {
          auto_trigger_ft = { '*' },
          keymap = {
            accept = '<C-.>',
            accept_line = '<C-,>',
            dismiss = '<C-]>',
          },
        },
      })

      -- minuet enables auto-trigger on `FileType`, which already fired for
      -- buffers opened before this lazy-load
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].ft ~= '' then
          vim.b[buf].minuet_virtual_text_auto_trigger = true
        end
      end
    end,
  },
}
