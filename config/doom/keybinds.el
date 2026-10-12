;;; keybinds.el -*- lexical-binding: t; -*-
;;
;; Custom keymaps. Verified against:
;;   modules/config/default/+evil-bindings.el
;;   modules/editor/evil/config.el
;;   modules/ui/workspaces/config.el
;;
;; Doom defaults NOT duplicated:
;;   ]b/[b           switch buffer (NOT using Tab/S-Tab)
;;   M-1..M-9        jump to workspace (NOT using SPC 1..9)
;;   SPC TAB n/d/r/o manage workspaces (NOT using SPC tn/tc/to)
;;   C-=/C--         zoom (doom/zoom-frame)
;;
;; Overridden (parity with nvim):
;;   s / S           → avy jump-to-char / word (port flash.nvim)
;;   C-d / C-u       → scroll + recenter
;;   n / N           → search + recenter
;;   C-w >/</+/-     → resize by factor 2 (nvim default)
;;   <BS>            → buffer alternate

;; ============================================================
;; Extra PACKAGES
;; ============================================================

(use-package! evil-textobj-anyblock
  :after evil
  :config
  (define-key evil-inner-text-objects-map "b" #'evil-textobj-anyblock-inner-block)
  (define-key evil-outer-text-objects-map "b" #'evil-textobj-anyblock-a-block))

(use-package! embrace
  :after evil
  :config
  (add-hook! 'org-mode-hook #'embrace-org-mode-hook)
  (setq embrace-show-help-p t)
  (evil-define-key 'visual 'global "s" #'embrace-commander))

;; ---------- Tree-sitter text-objects (port nvim-treesitter-textobjects) ----------
;; am/im function, ak/ik class, a,/i, parameter, a./i. assignment,
;; a?/i? conditional, a=/i= loop, ar/ir return, a#/i# comment.
(use-package! evil-textobj-tree-sitter
  :after evil
  :config
  (pcase-dolist (`(,key . ,name) '(("m" . "function")
                                   ("k" . "class")
                                   ("," . "parameter")
                                   ("." . "assignment")
                                   ("?" . "conditional")
                                   ("=" . "loop")
                                   ("r" . "return")
                                   ("#" . "comment")))
    (define-key evil-outer-text-objects-map key
                (eval `(evil-textobj-tree-sitter-get-textobj ,(concat name ".outer")) t))
    (define-key evil-inner-text-objects-map key
                (eval `(evil-textobj-tree-sitter-get-textobj ,(concat name ".inner")) t))))

;; ============================================================
;; VTERM toggle (persistent popup)
;; ============================================================

(defvar my/vterm-counter 2)

(defun my/vterm-buffer-name (n)
  (format "*doom:vterm:%d*" n))

(defun my/toggle-vterm (&optional n)
  "Toggle persistent vterm popup number N (default 0)."
  (interactive)
  (let* ((name (my/vterm-buffer-name (or n 0)))
         (buf  (get-buffer name)))
    (if buf
        (if (get-buffer-window buf)
            (delete-window (get-buffer-window buf))
          (pop-to-buffer buf))
      (vterm name)
      (pop-to-buffer name))))

(defun my/vterm-select ()
  "Pick among existing vterm buffers."
  (interactive)
  (let ((names (cl-loop for b in (buffer-list)
                        for n = (buffer-name b)
                        when (string-match-p "\\*doom:vterm" n)
                        collect n)))
    (if names
        (pop-to-buffer (completing-read "vterm: " names nil t))
      (message "No hay buffers vterm"))))

(defun my/vterm-new ()
  "Open a new numbered vterm and bump the counter."
  (interactive)
  (my/toggle-vterm my/vterm-counter)
  (setq my/vterm-counter (1+ my/vterm-counter)))

(defun my/vterm-rename (new-name)
  "Rename the current vterm buffer."
  (interactive "sNuevo nombre: ")
  (when (derived-mode-p 'vterm-mode)
    (rename-buffer new-name t)))

(map! :leader
      :desc "Toggle vterm 0" "t t" #'my/toggle-vterm
      :desc "Vterm 0"        "t 0" (cmd! (my/toggle-vterm 0))
      :desc "Vterm 1"        "t 1" (cmd! (my/toggle-vterm 1))
      :desc "Select vterm"   "t s" #'my/vterm-select
      :desc "New vterm"      "t o" #'my/vterm-new
      :desc "Rename vterm"   "t r" #'my/vterm-rename)

;; ============================================================
;; REPLACE prefix (SPC r ...) — nvim: <leader>r{r,l,w,e,n,N}
;; ============================================================

(defun my/replace-in-line      () (interactive) (evil-ex "s/"))
(defun my/replace-in-file      () (interactive) (evil-ex "%s/"))
(defun my/replace-in-structure () (interactive) (evil-ex "%s/\\(.*\\)/\\1/g"))

(defun my/replace-word-in-file ()
  "Replace the word under cursor across the whole file."
  (interactive)
  (when-let ((word (thing-at-point 'word t)))
    (evil-ex (format "%%s/\\<%s\\>/" word))))

(defun my/replace-next-word ()
  "Change the next occurrence of the word under cursor."
  (interactive)
  (when-let ((word (thing-at-point 'word t)))
    (evil-search word 'forward t)
    (evil-change (point) (progn (evil-search word 'forward t) (point)))))

(defun my/replace-prev-word ()
  "Change the previous occurrence of the word under cursor."
  (interactive)
  (when-let ((word (thing-at-point 'word t)))
    (evil-search word 'backward t)
    (evil-change (point) (progn (evil-search word 'backward t) (point)))))

(defun my/replace-in-visual ()
  "Replace within the visual selection."
  (interactive)
  (evil-ex (format "%d,%ds/"
                   (line-number-at-pos (region-beginning))
                   (line-number-at-pos (region-end)))))

(map! :leader
      (:prefix ("r" . "replace")
       :desc "Replace in line"      "l" #'my/replace-in-line
       :desc "Replace in file"      "r" #'my/replace-in-file
       :desc "Replace structure"    "e" #'my/replace-in-structure
       :desc "Replace word in file" "w" #'my/replace-word-in-file
       :desc "Replace next word"    "n" #'my/replace-next-word
       :desc "Replace prev word"    "N" #'my/replace-prev-word))

(map! :leader :v :desc "Replace in selection" "r r" #'my/replace-in-visual)

;; ============================================================
;; SPELL toggle (es/en) — nvim: <localleader>s
;; ============================================================

(defun my/toggle-flyspell ()
  "Toggle flyspell; prompt for es/en when enabling."
  (interactive)
  (if (bound-and-true-p flyspell-mode)
      (progn (flyspell-mode -1) (message "Flyspell off"))
    (let ((dict (completing-read "Dictionary: " '("es" "en_US") nil t)))
      (if (member dict (ispell-valid-dictionary-list))
          (progn
            (ispell-change-dictionary dict)
            (flyspell-mode 1)
            (message "Flyspell on (%s)" dict))
        (user-error "Dictionary %s no disponible" dict)))))

(map! :leader      :desc "Toggle spell" "s c" #'my/toggle-flyspell
      :localleader :desc "Toggle spell" "s"   #'my/toggle-flyspell)

;; ============================================================
;; MOVEMENT — nvim parity
;; ============================================================

;; g{ / g}  → first/last line of paragraph
(map! :nv "g {" #'backward-paragraph
      :nv "g }" #'forward-paragraph)

;; gz → reselect last yank/change
(defun my/select-last-yank-or-change ()
  "Select the text of the last yank or change."
  (interactive)
  (when (and (evil-get-marker ?\[) (evil-get-marker ?\]))
    (goto-char (evil-get-marker ?\[))
    (set-mark (point))
    (goto-char (evil-get-marker ?\]))
    (evil-visual-state)))

(map! :n "g z" #'my/select-last-yank-or-change)

;; gy → yank joining paragraphs into one line (handy for pasting in a browser)
(defun my/yank-joined-paragraphs (beg end)
  "Yank the region, joining each paragraph into a single line."
  (interactive "r")
  (let* ((text       (buffer-substring-no-properties beg end))
         (paragraphs (split-string text "\n[ \t]*\n+"))
         (joined     (mapconcat
                      (lambda (p)
                        (replace-regexp-in-string "[ \t]*\n[ \t]*" " " (string-trim p)))
                      paragraphs "\n\n")))
    (kill-new joined)
    (message "Yanked %d párrafos unidos" (length paragraphs))))

(map! :v "g y" #'my/yank-joined-paragraphs)

;; ============================================================
;; EVIL: text-objects, ex-cmds, no-yank, paste — all grouped
;; ============================================================

(after! evil
  ;; --- Text-object: whole buffer (af/if) ---
  (evil-define-text-object my/textobj-buffer (count &optional beg end type)
    "Text-object: whole buffer."
    (evil-range (point-min) (point-max) 'line))
  (define-key evil-outer-text-objects-map "f" #'my/textobj-buffer)
  (define-key evil-inner-text-objects-map "f" #'my/textobj-buffer)

  ;; --- a"/a'/a` behave like i" (no surrounding spaces) ---
  (define-key evil-outer-text-objects-map "\"" #'evil-inner-double-quote)
  (define-key evil-outer-text-objects-map "'"  #'evil-inner-single-quote)
  (define-key evil-outer-text-objects-map "`"  #'evil-inner-back-quote)

  ;; --- x → black hole register (does not fill the yank) ---
  (define-key evil-normal-state-map "x"
              (lambda (count) (interactive "p")
                (evil-delete (point) (+ (point) count) 'char ?_)))

  ;; --- Visual paste does not clobber the register ---
  (define-key evil-visual-state-map "p" #'evil-paste-after)

  ;; --- Ex command abbreviations (nvim cabbrev parity) ---
  (evil-ex-define-cmd "rm"    (lambda (&rest _) (call-interactively #'delete-file)))
  (evil-ex-define-cmd "mv"    (lambda (&rest _) (call-interactively #'rename-file)))
  (evil-ex-define-cmd "mkdir" (lambda (&rest _) (call-interactively #'make-directory)))
  (evil-ex-define-cmd "git"   (lambda (&rest _) (call-interactively #'magit-status)))
  (evil-ex-define-cmd "man"   (lambda (&rest _) (call-interactively #'man))))

;; Insert: C-v pastes from the system clipboard
(map! :i "C-v" #'clipboard-yank)

;; ============================================================
;; AVY: jump-to-char (port of flash.nvim)
;; ============================================================
;; Doom binds s/S to `evil-snipe' by default; we disable it and use avy.

(after! evil-snipe
  (map! :map evil-snipe-local-mode-map
        "s" nil
        "S" nil))

(map! :n "s" #'evil-avy-goto-char-2
      :n "S" #'evil-avy-goto-word-0)

;; ============================================================
;; SCROLL + CENTER (nvim: C-d zz / C-u zz / n zzzv / N zzzv)
;; ============================================================

(defun my/scroll-down-center () (interactive) (evil-scroll-down nil) (recenter))
(defun my/scroll-up-center   () (interactive) (evil-scroll-up   nil) (recenter))
(defun my/search-next-center () (interactive) (evil-ex-search-next)     (recenter))
(defun my/search-prev-center () (interactive) (evil-ex-search-previous) (recenter))

(map! :nv "C-d" #'my/scroll-down-center
      :nv "C-u" #'my/scroll-up-center
      :n  "n"   #'my/search-next-center
      :n  "N"   #'my/search-prev-center)

;; ============================================================
;; HUNK text-object + preview (gitsigns parity)
;; ============================================================
;; Doom already provides SPC g s/r/[/] via +vc-gutter. Adds preview and text-object.

(after! evil
  (evil-define-text-object my/textobj-hunk (count &optional beg end type)
    "Text-object: the diff-hl hunk under the cursor."
    (require 'diff-hl)
    (let ((ov (diff-hl-hunk-overlay-at (point))))
      (unless ov (user-error "No hay hunk en este punto"))
      (evil-range (overlay-start ov) (overlay-end ov) 'line)))
  (define-key evil-outer-text-objects-map "g" #'my/textobj-hunk)
  (define-key evil-inner-text-objects-map "g" #'my/textobj-hunk))

(map! :leader
      (:prefix "g"
       :desc "Preview hunk at point" "p" #'diff-hl-show-hunk))

;; ============================================================
;; Misc KEYMAPS (nvim parity)
;; ============================================================

;; <BS> → alternate buffer (nvim: <bs> = :b#)
(map! :n "<backspace>" #'evil-switch-to-windows-last-buffer)

;; C-l → redraw + nohlsearch
(defun my/redraw-and-nohlsearch ()
  (interactive)
  (evil-ex-nohighlight)
  (recenter))
(map! :n "C-l" #'my/redraw-and-nohlsearch)

;; M-/ / M-? → search within the visual selection
(map! :v "M-/" #'evil-ex-search-forward
      :v "M-?" #'evil-ex-search-backward)

;; gF → go to file + line number (nvim: gF / ]f)
(map! :n "g F" #'find-file-at-point)

;; C-w >/< → resize by factor 2 (nvim default; Doom default is 1)
(map! :n "C-w >" (cmd! (evil-window-increase-width 2))
      :n "C-w <" (cmd! (evil-window-decrease-width 2))
      :n "C-w +" (cmd! (evil-window-increase-height 2))
      :n "C-w -" (cmd! (evil-window-decrease-height 2)))

;; zV → close all folds except the current one
(defun my/fold-all-except-current ()
  "Hide all folds, then show only the block at point."
  (interactive)
  (when (bound-and-true-p hs-minor-mode)
    (hs-hide-all)
    (hs-show-block)))
(map! :n "z V" #'my/fold-all-except-current)

;; C-g + / C-g = → fix spelling in insert
(after! flyspell-correct
  (map! :i "C-g +" #'flyspell-correct-at-point
        :i "C-g =" #'flyspell-correct-previous))

;; ============================================================
;; FOLD text-object (nvim: iz / az)
;; ============================================================
(after! evil
  (evil-define-text-object my/textobj-fold (count &optional beg end type)
    "Text-object: the fold under the cursor (hideshow)."
    (when (bound-and-true-p hs-minor-mode)
      (save-excursion
        (let ((start (progn (back-to-indentation) (point)))
              (end   (progn (hs-find-block-beginning)
                            (forward-list)
                            (point))))
          (evil-range start end 'line)))))
  (define-key evil-outer-text-objects-map "z" #'my/textobj-fold)
  (define-key evil-inner-text-objects-map "z" #'my/textobj-fold))

;; ============================================================
;; DOOM plugin manager wrapper (nvim: <Leader>P {u,r,d})
;; ============================================================
(defun my/doom-shell (subcmd)
  "Run `doom SUBCMD' asynchronously from `user-emacs-directory'."
  (let ((default-directory user-emacs-directory))
    (compile (format "doom %s" subcmd))))

(defun my/doom-sync    () (interactive) (my/doom-shell "sync"))
(defun my/doom-upgrade () (interactive) (my/doom-shell "upgrade"))
(defun my/doom-purge   () (interactive) (my/doom-shell "purge"))
(defun my/doom-doctor  () (interactive) (my/doom-shell "doctor"))

(map! :leader
      (:prefix ("P" . "doom plugins")
       :desc "Sync"     "u" #'my/doom-sync
       :desc "Upgrade"  "U" #'my/doom-upgrade
       :desc "Purge"    "d" #'my/doom-purge
       :desc "Doctor"   "?" #'my/doom-doctor))

;; ============================================================
;; OTHER
;; ============================================================

;; SPC ; → quick eval-expression (nvim: cabbrev `;` → :=)
(map! :leader :desc "Eval expression" ";" #'eval-expression)

;; yc → yank line commented (nvim parity)
(defun my/yank-line-commented ()
  "Duplicate the current line and comment out the copy below."
  (interactive)
  (let ((line (buffer-substring (line-beginning-position) (line-end-position))))
    (save-excursion (end-of-line) (newline) (insert line))
    (forward-line)
    (comment-line 1)))

(map! :n "y c" #'my/yank-line-commented)

;; SPC c c → clear search hl
(map! :leader :desc "Clear search hl" "c c" #'evil-ex-nohighlight)
