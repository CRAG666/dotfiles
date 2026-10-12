;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
;;
;; Changes here require `doom sync` + an Emacs restart.
;; :recipe reference: https://github.com/radian-software/straight.el#the-recipe-format

;; ---------- Editing ----------
(package! evil-textobj-anyblock)
(package! embrace)

;; Tree-sitter text-objects (am/im function, ak/ik class, a,/i, param, etc.)
;; — port of nvim-treesitter-textobjects.
(package! evil-textobj-tree-sitter)

;; HTML/JSX tag auto-close + auto-rename (port of ts-autotag.nvim).
(package! auto-rename-tag)

;; CSV with native border view (port of csvview.nvim).
(package! csv-mode)

;; Align tables in markdown/org (similar to render-markdown.nvim)
(package! valign)

;; ---------- Native tree-sitter (treesit.el, Emacs 29+) ----------
;; Migration away from :tools tree-sitter + the +tree-sitter flag. `treesit-auto'
;; installs missing grammars and remaps *-mode → *-ts-mode.
;; `evil-textobj-tree-sitter' auto-detects `*-ts-mode' and uses the native
;; backend (treesit.el), so the legacy `tree-sitter' package comes in as a
;; transitive dep but stays dormant (no highlight or active parser).
(package! treesit-auto)
