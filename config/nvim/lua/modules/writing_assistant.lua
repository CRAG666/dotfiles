local M = {}

local function insert_text(text)
  -- Obtener la posición actual
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1] - 1
  local col = pos[2]
  local current_line = vim.api.nvim_get_current_line()

  -- Encontrar el final de la palabra actual
  local word_end = col
  while
    word_end < #current_line
    and string.match(
      string.sub(current_line, word_end + 1, word_end + 1),
      '%S'
    )
  do
    word_end = word_end + 1
  end

  -- Preparar las partes de la línea
  local line_before = string.sub(current_line, 1, word_end)
  local line_after = string.sub(current_line, word_end + 1)

  -- Eliminar espacios extra al inicio de line_after
  line_after = string.gsub(line_after, '^%s+', '')

  -- Preparar el texto del snippet
  local snippet_text = text
  if #line_before > 0 then
    snippet_text = ' ' .. snippet_text
  end
  if #line_after > 0 then
    snippet_text = snippet_text .. ' '
  end

  -- Crear el snippet completo con el texto antes y después
  local full_snippet_text = line_before .. snippet_text .. line_after

  -- Crear y expandir el snippet
  local ls = require('luasnip')
  local snippet = ls.parser.parse_snippet({
    trig = '',
    name = 'dynamic_snippet',
    dscr = 'Dynamically created snippet',
  }, full_snippet_text)

  -- Eliminar la línea actual
  vim.api.nvim_set_current_line('')

  -- Expandir el snippet
  ls.snip_expand(snippet)
end

function load_as_table(json_path)
  local contents = ''
  local file = io.open(json_path, 'r')

  if file then
    -- read all contents of file into a string
    contents = file:read('*a')
    local status, result = pcall(vim.json.decode, contents)
    io.close(file)
    if status then
      return result
    else
      return
    end
  end
end

M.snippets = load_as_table(
  vim.fn.expand('~/.config/nvim/lua/modules/text_es.json')
).snippets

-- Función para mostrar los snippets filtrados por tag
function M.by_tag(tag)
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  -- Filtrar snippets por tag si se especifica uno
  local filtered_snippets = M.snippets
  if tag then
    filtered_snippets = vim.tbl_filter(function(item)
      return item.tag == tag
    end, M.snippets)
  end

  pickers
    .new({}, {
      prompt_title = tag and (tag:upper()) or 'Frases precocinadas por tag',
      finder = finders.new_table({
        results = filtered_snippets,
        entry_maker = function(entry)
          return {
            value = entry,
            display = string.format('%s', entry.title),
            ordinal = string.format('%s', entry.title),
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          -- Usar la función auxiliar para insertar el texto
          insert_text(selection.value.content)
        end)
        return true
      end,
    })
    :find()
end

-- Función para mostrar y seleccionar tags disponibles
function M.tags()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  -- Obtener tags únicos
  local tags = {}
  local seen = {}
  for _, snippet in ipairs(M.snippets) do
    if not seen[snippet.tag] then
      seen[snippet.tag] = true
      table.insert(tags, snippet.tag)
    end
  end

  pickers
    .new({}, {
      prompt_title = 'Seleccionar Categoría',
      finder = finders.new_table({
        results = tags,
        entry_maker = function(tag)
          return {
            value = tag,
            display = tag:upper(),
            ordinal = tag,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          M.by_tag(selection.value)
        end)
        return true
      end,
    })
    :find()
end

function M.all()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers
    .new({}, {
      prompt_title = 'Todas las frases precocinadas',
      finder = finders.new_table({
        results = M.snippets,
        entry_maker = function(entry)
          return {
            value = entry,
            -- Mostrar tag y título para facilitar el filtrado
            display = string.format('[%s] %s', entry.tag:upper(), entry.title),
            -- Permitir búsqueda por tag y título
            ordinal = string.format('%s %s', entry.tag, entry.title),
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          insert_text(selection.value.content)
        end)
        return true
      end,
    })
    :find()
end
return M
