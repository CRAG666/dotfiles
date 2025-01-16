local utils = require "utils.keymap"
local api = vim.api
local fn = vim.fn

-- Función para obtener el tipo de archivo actual
local function get_current_filetype()
  return vim.bo.filetype
end

-- Función para crear un buffer temporal
local function create_temp_buffer()
  -- Crear nuevo buffer
  local buf = api.nvim_create_buf(false, true)

  -- Configurar el buffer como temporal y markdown
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "filetype", "markdown")

  -- Crear ventana para el buffer
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  }

  local win = api.nvim_open_win(buf, true, opts)
  api.nvim_win_set_option(win, "wrap", true)

  return buf
end

-- Función para realizar la búsqueda HTTP
local function http_get(url)
  local curl = require "plenary.curl"
  local response = curl.get(url)
  return response.body
end

-- Función para parsear la respuesta de cht.sh
local function parse_cht_response(response)
  -- Eliminar códigos de color ANSI
  response = response:gsub("\27%[[0-9;]*m", "")
  return response
end

-- Función para mostrar el input de búsqueda
local function search()
  local filetype = get_current_filetype()
  local input = fn.input(string.format("Buscar (%s): ", filetype))

  if input == "" then
    return
  end

  -- Codificar la consulta para URLs
  local encoded_query = fn.shellescape(input):gsub("'", "")

  -- Realizar búsquedas
  local cht_url = string.format("https://cht.sh/%s/%s", filetype, encoded_query)
  local so_url = string.format("https://stackoverflow.com/search?q=[%s]+%s", filetype, encoded_query:gsub(" ", "+"))

  -- Obtener resultados
  local cht_response = http_get(cht_url)

  -- Crear buffer temporal y mostrar resultados
  local buf = create_temp_buffer()

  -- Formatear contenido en markdown
  local content = string.format(
    [[
# Resultados de búsqueda para: %s

## cht.sh
```%s
%s
```

## Stack Overflow
[Ver resultados en Stack Overflow](%s)

Presiona 'q' para cerrar esta ventana.
]],
    input,
    filetype,
    parse_cht_response(cht_response),
    so_url
  )

  -- Establecer contenido en el buffer
  api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))

  -- Configurar mapeo para cerrar la ventana
  local opts = { noremap = true, silent = true }
  api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", opts)
end

-- Mapeo sugerido (puede ser modificado por el usuario)
utils.map("n", "<leader>ch", search)
