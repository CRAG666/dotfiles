;;; options.el -*- lexical-binding: t; -*-
;;
;; Opciones que NO son defaults de Doom Emacs.
;; Verificado contra modules/* de la rama master.

;; ---------- Visual ----------
(setq-default fill-column     80
              truncate-lines  t)            ; nvim: wrap = false
(global-display-fill-column-indicator-mode 1)
(setq display-fill-column-indicator-character ?│)

(setq scroll-margin          2              ; nvim: scrolloff
      hscroll-margin         8              ; nvim: sidescrolloff
      scroll-conservatively  101)

;; ---------- Splits a derecha / abajo (nvim: splitright/splitbelow) ----------
;; Doom NO setea estos por defecto; los dejamos a top-level porque evil los
;; lee al hacer el split.
(setq evil-split-window-below  t
      evil-vsplit-window-right t)

;; ---------- Backups (nvim: backup = true, swapfile = false) ----------
(setq create-lockfiles    nil
      make-backup-files   t
      backup-by-copying   t
      version-control     t
      delete-old-versions t
      kept-new-versions   6
      kept-old-versions   2)

;; ---------- Whitespace visible (nvim: listchars tab=·, trail=·, nbsp=␣) ----------
(setq whitespace-style '(face trailing tab-mark space-mark)
      whitespace-display-mappings
      '((tab-mark   9   [?· ?\t] [?\\ ?\t])    ; tab
        (space-mark 160 [?␣]    [?_])))        ; nbsp

(add-hook! '(prog-mode-hook text-mode-hook) #'whitespace-mode)

;; ---------- Fringe: ancho fijo (nvim: signcolumn = yes:1) ----------
(set-fringe-mode '(8 . 8))

;; ---------- Smooth scroll (nvim: smoothscroll = true) ----------
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; ---------- Confirmaciones (nvim: confirm = true) ----------
(setq confirm-nonexistent-file-or-buffer t)

;; ---------- Spell ----------
(setq ispell-dictionary "en_US")
;; nvim: spelloptions = camel → split camelCase para spell-check
(after! ispell
  (setq ispell-extra-args (append ispell-extra-args '("--camel-case"))))

;; ---------- Cursorline solo en el número (nvim: cursorlineopt = 'number') ----------
;; Doom engancha `global-hl-line-mode' a `doom-first-buffer-hook' vía
;; `use-package! hl-line :hook (doom-first-buffer . …)' en doom-ui.el.
;; Quitamos ese enganche antes de que el hook dispare; queda sólo el
;; highlight del face `line-number-current-line' del tema.
(remove-hook! 'doom-first-buffer-hook #'global-hl-line-mode)

;; ---------- Help: enfoca la ventana al abrir ----------
(setq help-window-select t)

;; ---------- Folds: abrir todo al cargar (nvim: foldlevelstart = 99) ----------
(add-hook! 'hs-minor-mode-hook #'hs-show-all)

;; `+fold-ellipsis' lo define el módulo :editor fold en su config.el (corre
;; antes que este `load!'), así que el setq simple a top-level alcanza.
;; (after! fold …) NO funcionaría: no hay feature `fold' provided.
(setq +fold-ellipsis "·")

;; ---------- Completion (paridad con blink.cmp de nvim) ----------
;; corfu-popupinfo-delay NO se pone en 0.0: la doc oficial advierte que
;; satura Emacs con requests al backend LSP. `(0.1 . 0.1)' se siente
;; instantáneo sin castigar.
(after! corfu
  (setq corfu-count           16              ; nvim pumheight
        corfu-auto-delay      0.0             ; blink: instantáneo
        corfu-auto-prefix     1               ; blink: desde 1er char
        corfu-preselect       'first          ; blink: preselect primero
        corfu-preview-current 'insert         ; blink: auto_insert preview
        corfu-popupinfo-delay '(0.1 . 0.1))  ; blink: docs casi instantáneo
  ;; Upstream: TAB=corfu-complete (completa prefijo) y S-TAB sin bind.
  ;; Rebind a cycle next/prev (RET sigue siendo aceptar).
  ;; ↑/↓ ya son corfu-previous/next por default.
  (map! :map corfu-map
        "TAB"     #'corfu-next
        [tab]     #'corfu-next
        "S-TAB"   #'corfu-previous
        [backtab] #'corfu-previous))

;; ---------- Magit ----------
(after! magit
  (setq magit-diff-refine-hunk 'all)
  ;; nvim: diffopt += algorithm:histogram
  ;; `magit-diff-arguments' es una FUNCIÓN (no var); para forzar histogram
  ;; en todo magit lo pasamos vía `-c diff.algorithm=histogram' a git.
  (unless (member "diff.algorithm=histogram" magit-git-global-arguments)
    (setq magit-git-global-arguments
          (append magit-git-global-arguments
                  '("-c" "diff.algorithm=histogram")))))
