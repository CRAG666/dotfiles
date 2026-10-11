-- Port of nvim's `plugin/colorify`: highlight `#rrggbb` colors in place

---@type integer?
local style_id

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
  if win.bigfile then
    return
  end
  local viewport = win.viewport.bytes
  local text = win.file:content(viewport)
  for col, hex in text:gmatch('()#(%x%x%x%x%x%x)') do
    style_id = style_id or vis.ui:style_push()
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    local fore = (r * 30 + g * 59 + b * 11) > 12000 and '#000000' or '#ffffff'
    -- Styles are copied into cells when applied, so one id serves all colors
    vis.ui:style_define(style_id, 'fore:' .. fore .. ',back:#' .. hex)
    local start = viewport.start + col - 1
    win:style(style_id, start, start + 6)
  end
end)
