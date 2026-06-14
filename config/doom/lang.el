;;; lang.el -*- lexical-binding: t; -*-
;;
;; Ajustes per-lenguaje que NO son defaults de Doom.
;; (Doom :lang python ya hace indent 4, virtualenv, LSP.
;;  Doom :lang lua ya hace indent 2.
;;  Doom :lang cc ya tiene estilo "doom" basado en kernel Linux.
;;  Doom :lang markdown ya hace spell-check + LSP.
;;  Doom :lang latex ya integra SyncTeX + viewer + RefTeX.)

;; ---------- Python ----------
;; `python-base-mode' es el padre común de python-mode y python-ts-mode,
;; así un solo hook cubre tanto el modo tradicional como el tree-sitter.
(after! python
  (define-abbrev-table 'python-mode-abbrev-table
    '(("true"  "True")
      ("ture"  "True")
      ("false" "False")
      ("flase" "False"))))

(add-hook! 'python-base-mode-hook #'abbrev-mode)

;; Black formatter (88) + colorcolumn +1 = 89
(setq-hook! 'python-base-mode-hook fill-column 89)

;; ---------- Zsh: tratar .zsh como sh-mode ----------
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))

;; ---------- HTML/JSX: auto-rename de tags (port de ts-autotag.nvim) ----------
(use-package! auto-rename-tag
  :hook ((html-mode mhtml-mode web-mode nxml-mode
          js-jsx-mode tsx-ts-mode rjsx-mode)
         . auto-rename-tag-mode))

;; ---------- CSV: border view (port de csvview.nvim) ----------
;; csv-mode autoloadea `.csv' por sí solo; sólo enganchamos csv-align-mode
;; (minor mode real) para el efecto de bordes/columnas.
;; `csv-header-line' NO es minor mode: si lo querés, M-x csv-header-line.
(use-package! csv-mode
  :hook (csv-mode . csv-align-mode))

;; ---------- Modos de prosa: visual-line + truncate-lines off ----------
;; LaTeX (88), markdown (sin fill custom), org (106) — todos con wrap visual.
(setq-hook! 'LaTeX-mode-hook    fill-column 88  truncate-lines nil)
(setq-hook! 'markdown-mode-hook                 truncate-lines nil)
(setq-hook! 'org-mode-hook      fill-column 106 truncate-lines nil)

(add-hook! '(LaTeX-mode-hook markdown-mode-hook org-mode-hook) #'visual-line-mode)

;; ---------- Markdown pretty (port de render-markdown.nvim) ----------
(after! markdown-mode
  (setq markdown-fontify-code-blocks-natively t   ; resalta bloques ```lang
        markdown-hide-urls                    t   ; oculta URLs en links
        markdown-header-scaling               t   ; H1>H2>… escalados
        markdown-italic-underscore            t
        markdown-list-indent-width            2
        markdown-asymmetric-header            t))

;; Alinea tablas markdown/org en vivo (similar a render-markdown.nvim).
(use-package! valign
  :hook ((markdown-mode org-mode) . valign-mode))
