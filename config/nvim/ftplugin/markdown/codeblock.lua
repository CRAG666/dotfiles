-- Highlight code blocks and extend dashes in markdown files
-- Ported from https://github.com/lukas-reineke/headlines.nvim

local ft = vim.bo.ft
local loaded_flag = 'loaded_codeblock_' .. ft

-- Load plugin only once per filetype
if vim.g[loaded_flag] ~= nil then
  return
end
vim.g[loaded_flag] = true

local ns_name = ft .. 'CodeBlocks'
local ns = vim.api.nvim_create_namespace(ns_name)

local has_quantified_captures = vim.fn.has('nvim-0.11.0') == 1

local dash_string = '-'
local query = vim.F.npcall(
  vim.treesitter.query.parse,
  ft,
  [[
    (thematic_break) @dash
    (fenced_code_block) @codeblock
  ]]
)

---@param buf? integer
local function refresh(buf)
  buf = buf ~= 0 and buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  if
    not query
    or vim.b.bigfile
    or vim.bo[buf].ft ~= ft
    or vim.fn.win_gettype() ~= ''
    or not vim.api.nvim_buf_is_loaded(buf)
  then
    return
  end

  local lang_tree = vim.treesitter.get_parser(buf, ft)
  if not lang_tree then
    return
  end

  local syntax_tree = lang_tree:parse()
  if not syntax_tree then
    return
  end

  local root = syntax_tree[1]:root()
  local left_offset = vim.fn.winsaveview().leftcol
  local width = vim.api.nvim_win_get_width(0)

  for _, match, metadata in query:iter_matches(root, buf) do
    for id, node in pairs(match) do
      if has_quantified_captures then
        node = node[#node]
      end

      local capture = query.captures[id]
      local start_row, _, end_row, _ = unpack(
        vim.tbl_extend(
          'force',
          { node:range() },
          (metadata[id] or {}).range or {}
        )
      )

      if capture == 'dash' and dash_string then
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, start_row, 0, {
          virt_text = {
            { dash_string:rep(width), 'Dash' },
          },
          virt_text_pos = 'overlay',
          hl_mode = 'combine',
        })
      end

      if capture == 'codeblock' then
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, start_row, 0, {
          end_col = 0,
          end_row = end_row,
          hl_group = 'CodeBlock',
          hl_eol = true,
        })

        local start_line =
          vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
        local _, padding = start_line:find('^ +')
        local codeblock_padding = math.max((padding or 0) - left_offset, 0)

        if codeblock_padding > 0 then
          for i = start_row, end_row - 1 do
            pcall(vim.api.nvim_buf_set_extmark, buf, ns, i, 0, {
              virt_text = {
                { string.rep(' ', codeblock_padding - 2), 'Normal' },
              },
              virt_text_win_col = 0,
              priority = 1,
            })
          end
        end
      end
    end
  end
end

refresh()

local groupid = vim.api.nvim_create_augroup(ns_name, {})

vim.api.nvim_create_autocmd({
  'FileChangedShellPost',
  'InsertLeave',
  'TextChanged',
}, {
  group = groupid,
  desc = 'Refresh headlines.',
  callback = function(args)
    if vim.bo[args.buf].ft ~= ft then
      return
    end
    refresh(args.buf)
  end,
})

vim.api.nvim_create_autocmd('Syntax', {
  group = groupid,
  pattern = ft,
  desc = 'Refresh headlines.',
  callback = function(args)
    refresh(args.buf)
  end,
})

local function set_default_hlgroups()
  local hl = require('utils.hl')
  hl.set_default(0, 'CodeBlock', { link = 'CursorLine' })
  hl.set_default(0, 'Dash', { link = 'LineNr' })
  hl.set(0, 'markdownCode', { bg = 'CodeBlock' })
  hl.set(0, 'markdownCodeDelimiter', { bg = 'CodeBlock' })
  -- Treesitter hl
  hl.set(0, '@markup.raw.markdown_inline', { fg = 'String', bg = 'CodeBlock' })
end

set_default_hlgroups()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = groupid,
  desc = 'Set default highlight groups for headlines.nvim.',
  callback = set_default_hlgroups,
})
