;;; lang.el -*- lexical-binding: t; -*-
;;
;; Per-language settings that are NOT Doom defaults.
;; (Doom :lang python already does indent 4, virtualenv, LSP.
;;  Doom :lang lua already does indent 2.
;;  Doom :lang cc already has a "doom" style based on the Linux kernel.
;;  Doom :lang markdown already does spell-check + LSP.
;;  Doom :lang latex already integrates SyncTeX + viewer + RefTeX.)

;; ---------- Python ----------
;; `python-base-mode' is the common parent of python-mode and python-ts-mode,
;; so a single hook covers both the traditional and the tree-sitter mode.
(after! python
  (define-abbrev-table 'python-mode-abbrev-table
    '(("true"  "True")
      ("ture"  "True")
      ("false" "False")
      ("flase" "False"))))

(add-hook! 'python-base-mode-hook #'abbrev-mode)

;; Black formatter (88) + colorcolumn +1 = 89
(setq-hook! 'python-base-mode-hook fill-column 89)

;; ---------- Zsh: treat .zsh as sh-mode ----------
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))

;; ---------- HTML/JSX: tag auto-rename (port of ts-autotag.nvim) ----------
(use-package! auto-rename-tag
  :hook ((html-mode mhtml-mode web-mode nxml-mode
          js-jsx-mode tsx-ts-mode rjsx-mode)
         . auto-rename-tag-mode))

;; ---------- CSV: border view (port of csvview.nvim) ----------
;; csv-mode autoloads `.csv' on its own; we only hook csv-align-mode
;; (a real minor mode) for the border/column effect.
;; `csv-header-line' is NOT a minor mode: if wanted, M-x csv-header-line.
(use-package! csv-mode
  :hook (csv-mode . csv-align-mode))

;; ---------- Prose modes: visual-line + truncate-lines off ----------
;; LaTeX (88), markdown (no custom fill), org (106) — all with visual wrap.
(setq-hook! 'LaTeX-mode-hook    fill-column 88  truncate-lines nil)
(setq-hook! 'markdown-mode-hook                 truncate-lines nil)
(setq-hook! 'org-mode-hook      fill-column 106 truncate-lines nil)

(add-hook! '(LaTeX-mode-hook markdown-mode-hook org-mode-hook) #'visual-line-mode)

;; ---------- Markdown pretty (port of render-markdown.nvim) ----------
(after! markdown-mode
  (setq markdown-fontify-code-blocks-natively t   ; highlight ```lang blocks
        markdown-hide-urls                    t   ; hide URLs in links
        markdown-header-scaling               t   ; scaled H1>H2>…
        markdown-italic-underscore            t
        markdown-list-indent-width            2
        markdown-asymmetric-header            t))

;; Align markdown/org tables live (similar to render-markdown.nvim).
(use-package! valign
  :hook ((markdown-mode org-mode) . valign-mode))
