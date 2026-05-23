;;; autocmds.el -*- lexical-binding: t; -*-
;;
;; Autocomandos que NO son defaults de Doom.
;; (Doom ya provee: save-place-mode, evil-goggles, so-long-mode,
;;  ws-butler para trim no-destructivo en líneas tocadas, etc.)

;; ---------- Trim agresivo en TODO el buffer al guardar (nvim parity) ----------
;; ws-butler de Doom sólo trimea líneas que tocaste. nvim usa %s/\s\+$//e
;; que trimea TODO. Paridad con nvim añadiendo el hook agresivo.
(add-hook! 'before-save-hook #'delete-trailing-whitespace)

;; ---------- Projectile: rutas de búsqueda para switch-project ----------
(after! projectile
  (setq projectile-project-search-path '("~/Git/" "~/Documents/")))
