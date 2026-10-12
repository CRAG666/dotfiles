;;; autocmds.el -*- lexical-binding: t; -*-
;;
;; Autocommands that are NOT Doom defaults.
;; (Doom already provides: save-place-mode, evil-goggles, so-long-mode,
;;  ws-butler for non-destructive trim on touched lines, etc.)

;; ---------- Aggressive trim of the WHOLE buffer on save (nvim parity) ----------
;; Doom's ws-butler only trims lines you touched. nvim uses %s/\s\+$//e
;; which trims EVERYTHING. nvim parity by adding the aggressive hook.
(add-hook! 'before-save-hook #'delete-trailing-whitespace)

;; ---------- Projectile: search paths for switch-project ----------
(after! projectile
  (setq projectile-project-search-path '("~/Git/" "~/Documents/")))
