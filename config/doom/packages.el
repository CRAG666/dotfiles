;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
;;
;; Cambios aquí requieren `doom sync` + restart de Emacs.
;; Referencia de :recipe: https://github.com/radian-software/straight.el#the-recipe-format

;; ---------- Edición ----------
(package! evil-textobj-anyblock)
(package! embrace)

;; Tree-sitter text-objects (am/im function, ak/ik class, a,/i, param, etc.)
;; — port de nvim-treesitter-textobjects.
(package! evil-textobj-tree-sitter)

;; HTML/JSX auto-close + auto-rename de tags (port de ts-autotag.nvim).
(package! auto-rename-tag)

;; CSV con border view nativo (port de csvview.nvim).
(package! csv-mode)

;; Alinea tablas en markdown/org (similar a render-markdown.nvim)
(package! valign)

;; ---------- Tree-sitter nativo (treesit.el, Emacs 29+) ----------
;; Migración fuera de :tools tree-sitter + flag +tree-sitter. `treesit-auto'
;; instala gramáticas faltantes y remappea *-mode → *-ts-mode.
;; `evil-textobj-tree-sitter' auto-detecta `*-ts-mode' y usa el backend
;; nativo (treesit.el), así que el paquete legacy `tree-sitter' viene como
;; dep transitiva pero queda dormido (sin highlight ni parser activo).
(package! treesit-auto)
