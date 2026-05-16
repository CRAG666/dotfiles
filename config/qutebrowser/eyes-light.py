# eyes (light) — sage-green palette for qutebrowser.

bg0    = '#add4a0'
bg1    = '#a4cc98'
bg2    = '#9fc895'
bg3    = '#96be8c'
bg4    = '#88b07e'
bg5    = '#6a9060'
fg0    = '#1a1a1a'
fg1    = '#1e2e1c'
fg2    = '#3d5c38'
fg3    = '#486040'
accent = '#1e4868'
accent_hover = '#143c52'
visited = '#3a2860'
red    = '#7a1e18'
red2   = '#8a2820'
yellow = '#5a4808'
green  = '#1e4a18'
green2 = '#2a5c22'
cyan   = '#145850'
magenta = '#5a2858'
orange = '#6a3c10'

# ─── Completion ───────────────────────────────────────────────────────────────
c.colors.completion.fg = fg0
c.colors.completion.odd.bg = bg1
c.colors.completion.even.bg = bg0
c.colors.completion.category.fg = accent
c.colors.completion.category.bg = bg3
c.colors.completion.category.border.top = bg5
c.colors.completion.category.border.bottom = bg5
c.colors.completion.item.selected.fg = bg0
c.colors.completion.item.selected.bg = accent
c.colors.completion.item.selected.border.top = accent
c.colors.completion.item.selected.border.bottom = accent
c.colors.completion.item.selected.match.fg = yellow
c.colors.completion.match.fg = red
c.colors.completion.scrollbar.fg = fg0
c.colors.completion.scrollbar.bg = bg2

# ─── Context menu ─────────────────────────────────────────────────────────────
c.colors.contextmenu.menu.bg = bg1
c.colors.contextmenu.menu.fg = fg0
c.colors.contextmenu.selected.bg = accent
c.colors.contextmenu.selected.fg = bg0
c.colors.contextmenu.disabled.bg = bg1
c.colors.contextmenu.disabled.fg = fg3

# ─── Downloads ────────────────────────────────────────────────────────────────
c.colors.downloads.bar.bg = bg0
c.colors.downloads.start.fg = bg0
c.colors.downloads.start.bg = accent
c.colors.downloads.stop.fg = bg0
c.colors.downloads.stop.bg = green
c.colors.downloads.error.fg = bg0
c.colors.downloads.error.bg = red
c.colors.downloads.system.fg = 'rgb'
c.colors.downloads.system.bg = 'rgb'

# ─── Hints ────────────────────────────────────────────────────────────────────
c.colors.hints.bg = yellow
c.colors.hints.fg = bg0
c.colors.hints.match.fg = red

# ─── Keyhint ──────────────────────────────────────────────────────────────────
c.colors.keyhint.bg = bg1
c.colors.keyhint.fg = fg0
c.colors.keyhint.suffix.fg = accent

# ─── Messages ─────────────────────────────────────────────────────────────────
c.colors.messages.error.bg = red
c.colors.messages.error.fg = bg0
c.colors.messages.error.border = red2
c.colors.messages.warning.bg = yellow
c.colors.messages.warning.fg = bg0
c.colors.messages.warning.border = yellow
c.colors.messages.info.bg = bg1
c.colors.messages.info.fg = fg0
c.colors.messages.info.border = bg5

# ─── Prompts ──────────────────────────────────────────────────────────────────
c.colors.prompts.bg = bg1
c.colors.prompts.fg = fg0
c.colors.prompts.border = bg5
c.colors.prompts.selected.bg = accent
c.colors.prompts.selected.fg = bg0

# ─── Statusbar ────────────────────────────────────────────────────────────────
c.colors.statusbar.normal.bg = bg1
c.colors.statusbar.normal.fg = fg0
c.colors.statusbar.insert.bg = green
c.colors.statusbar.insert.fg = bg0
c.colors.statusbar.passthrough.bg = accent
c.colors.statusbar.passthrough.fg = bg0
c.colors.statusbar.private.bg = magenta
c.colors.statusbar.private.fg = bg0
c.colors.statusbar.command.bg = bg2
c.colors.statusbar.command.fg = fg0
c.colors.statusbar.command.private.bg = magenta
c.colors.statusbar.command.private.fg = bg0
c.colors.statusbar.caret.bg = magenta
c.colors.statusbar.caret.fg = bg0
c.colors.statusbar.caret.selection.bg = accent
c.colors.statusbar.caret.selection.fg = bg0
c.colors.statusbar.progress.bg = accent

c.colors.statusbar.url.fg = fg0
c.colors.statusbar.url.error.fg = red
c.colors.statusbar.url.hover.fg = accent
c.colors.statusbar.url.success.http.fg = yellow
c.colors.statusbar.url.success.https.fg = green
c.colors.statusbar.url.warn.fg = orange

# ─── Tabs ─────────────────────────────────────────────────────────────────────
c.colors.tabs.bar.bg = bg1
c.colors.tabs.indicator.start = accent
c.colors.tabs.indicator.stop = green
c.colors.tabs.indicator.error = red
c.colors.tabs.indicator.system = 'rgb'

c.colors.tabs.odd.fg = fg0
c.colors.tabs.odd.bg = bg2
c.colors.tabs.even.fg = fg0
c.colors.tabs.even.bg = bg1

c.colors.tabs.selected.odd.fg = bg0
c.colors.tabs.selected.odd.bg = accent
c.colors.tabs.selected.even.fg = bg0
c.colors.tabs.selected.even.bg = accent

c.colors.tabs.pinned.odd.fg = bg0
c.colors.tabs.pinned.odd.bg = green
c.colors.tabs.pinned.even.fg = bg0
c.colors.tabs.pinned.even.bg = green
c.colors.tabs.pinned.selected.odd.fg = bg0
c.colors.tabs.pinned.selected.odd.bg = accent
c.colors.tabs.pinned.selected.even.fg = bg0
c.colors.tabs.pinned.selected.even.bg = accent

# ─── Webpage ──────────────────────────────────────────────────────────────────
c.colors.webpage.bg = bg0
c.colors.webpage.preferred_color_scheme = 'light'
c.colors.webpage.darkmode.enabled = False
