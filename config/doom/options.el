;;; options.el -*- lexical-binding: t; -*-
;;
;; Options that are NOT Doom Emacs defaults.
;; Verified against modules/* on the master branch.

;; ---------- Visual ----------
(setq-default fill-column     80
              truncate-lines  t)            ; nvim: wrap = false
(global-display-fill-column-indicator-mode 1)
(setq display-fill-column-indicator-character ?│)

(setq scroll-margin          2              ; nvim: scrolloff
      hscroll-margin         8              ; nvim: sidescrolloff
      scroll-conservatively  101)

;; ---------- Splits to the right / below (nvim: splitright/splitbelow) ----------
;; Doom does NOT set these by default; we keep them top-level because evil
;; reads them when splitting.
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

;; ---------- Fringe: fixed width (nvim: signcolumn = yes:1) ----------
(set-fringe-mode '(8 . 8))

;; ---------- Smooth scroll (nvim: smoothscroll = true) ----------
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; ---------- Confirmations (nvim: confirm = true) ----------
(setq confirm-nonexistent-file-or-buffer t)

;; ---------- Spell ----------
(setq ispell-dictionary "en_US")
;; nvim: spelloptions = camel → split camelCase for spell-check
(after! ispell
  (setq ispell-extra-args (append ispell-extra-args '("--camel-case"))))

;; ---------- Cursorline only on the number (nvim: cursorlineopt = 'number') ----------
;; Doom hooks `global-hl-line-mode' into `doom-first-buffer-hook' via
;; `use-package! hl-line :hook (doom-first-buffer . …)' in doom-ui.el.
;; We remove that hook before it fires; only the theme's
;; `line-number-current-line' face highlight remains.
(remove-hook! 'doom-first-buffer-hook #'global-hl-line-mode)

;; ---------- Help: focus the window on open ----------
(setq help-window-select t)

;; ---------- Folds: open all on load (nvim: foldlevelstart = 99) ----------
(add-hook! 'hs-minor-mode-hook #'hs-show-all)

;; `+fold-ellipsis' is defined by the :editor fold module in its config.el
;; (runs before this `load!'), so a plain top-level setq is enough.
;; (after! fold …) would NOT work: no `fold' feature is provided.
(setq +fold-ellipsis "·")

;; ---------- Completion (parity with nvim's blink.cmp) ----------
;; corfu-popupinfo-delay is NOT set to 0.0: the official docs warn it
;; floods Emacs with LSP backend requests. `(0.1 . 0.1)' feels
;; instant without the penalty.
(after! corfu
  (setq corfu-count           16              ; nvim pumheight
        corfu-auto-delay      0.0             ; blink: instant
        corfu-auto-prefix     1               ; blink: from 1st char
        corfu-preselect       'first          ; blink: preselect first
        corfu-preview-current 'insert         ; blink: auto_insert preview
        corfu-popupinfo-delay '(0.1 . 0.1))  ; blink: near-instant docs
  ;; Upstream: TAB=corfu-complete (completes prefix) and S-TAB unbound.
  ;; Rebind to cycle next/prev (RET still accepts).
  ;; ↑/↓ are already corfu-previous/next by default.
  (map! :map corfu-map
        "TAB"     #'corfu-next
        [tab]     #'corfu-next
        "S-TAB"   #'corfu-previous
        [backtab] #'corfu-previous))

;; ---------- Magit ----------
(after! magit
  (setq magit-diff-refine-hunk 'all)
  ;; nvim: diffopt += algorithm:histogram
  ;; `magit-diff-arguments' is a FUNCTION (not a var); to force histogram
  ;; across magit we pass `-c diff.algorithm=histogram' to git.
  (unless (member "diff.algorithm=histogram" magit-git-global-arguments)
    (setq magit-git-global-arguments
          (append magit-git-global-arguments
                  '("-c" "diff.algorithm=histogram")))))
