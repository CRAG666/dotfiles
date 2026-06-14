;;; keybinds.el -*- lexical-binding: t; -*-
;;
;; Keymaps custom. Verificado contra:
;;   modules/config/default/+evil-bindings.el
;;   modules/editor/evil/config.el
;;   modules/ui/workspaces/config.el
;;
;; NO se duplican defaults de Doom:
;;   ]b/[b           cambiar buffer (NO uso Tab/S-Tab)
;;   M-1..M-9        saltar workspace (NO uso SPC 1..9)
;;   SPC TAB n/d/r/o gestionar workspaces (NO uso SPC tn/tc/to)
;;   C-=/C--         zoom (doom/zoom-frame)
;;
;; SÍ se sobrescriben (paridad con nvim):
;;   s / S           → avy jump-to-char / word (port flash.nvim)
;;   C-d / C-u       → scroll + recenter
;;   n / N           → search + recenter
;;   C-w >/</+/-     → resize con factor 2 (nvim default)
;;   <BS>            → buffer alternate

;; ============================================================
;; PACKAGES adicionales
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
;; VTERM toggle (popup persistente)
;; ============================================================

(defvar my/vterm-counter 2)

(defun my/vterm-buffer-name (n)
  (format "*doom:vterm:%d*" n))

(defun my/toggle-vterm (&optional n)
  "Toggle de un vterm popup persistente numerado N (default 0)."
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
  "Selector entre buffers vterm existentes."
  (interactive)
  (let ((names (cl-loop for b in (buffer-list)
                        for n = (buffer-name b)
                        when (string-match-p "\\*doom:vterm" n)
                        collect n)))
    (if names
        (pop-to-buffer (completing-read "vterm: " names nil t))
      (message "No hay buffers vterm"))))

(defun my/vterm-new ()
  "Abre un nuevo vterm numerado e incrementa el contador."
  (interactive)
  (my/toggle-vterm my/vterm-counter)
  (setq my/vterm-counter (1+ my/vterm-counter)))

(defun my/vterm-rename (new-name)
  "Renombra el buffer vterm actual."
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
  "Reemplaza la palabra bajo cursor en todo el archivo."
  (interactive)
  (when-let ((word (thing-at-point 'word t)))
    (evil-ex (format "%%s/\\<%s\\>/" word))))

(defun my/replace-next-word ()
  "Cambia la siguiente ocurrencia de la palabra bajo cursor."
  (interactive)
  (when-let ((word (thing-at-point 'word t)))
    (evil-search word 'forward t)
    (evil-change (point) (progn (evil-search word 'forward t) (point)))))

(defun my/replace-prev-word ()
  "Cambia la ocurrencia anterior de la palabra bajo cursor."
  (interactive)
  (when-let ((word (thing-at-point 'word t)))
    (evil-search word 'backward t)
    (evil-change (point) (progn (evil-search word 'backward t) (point)))))

(defun my/replace-in-visual ()
  "Replace dentro de la selección visual."
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
  "Toggle flyspell; al activar pregunta es/en."
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
;; MOVIMIENTO — nvim parity
;; ============================================================

;; g{ / g}  → primera/última línea del párrafo
(map! :nv "g {" #'backward-paragraph
      :nv "g }" #'forward-paragraph)

;; gz → re-seleccionar último yank/cambio
(defun my/select-last-yank-or-change ()
  "Selecciona el texto del último yank o cambio."
  (interactive)
  (when (and (evil-get-marker ?\[) (evil-get-marker ?\]))
    (goto-char (evil-get-marker ?\[))
    (set-mark (point))
    (goto-char (evil-get-marker ?\]))
    (evil-visual-state)))

(map! :n "g z" #'my/select-last-yank-or-change)

;; gy → yank uniendo párrafos en una línea (útil para pegar en navegador)
(defun my/yank-joined-paragraphs (beg end)
  "Yank de la región uniendo cada párrafo en una sola línea."
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
;; EVIL: text-objects, ex-cmds, no-yank, paste — todo agrupado
;; ============================================================

(after! evil
  ;; --- Text-object: buffer entero (af/if) ---
  (evil-define-text-object my/textobj-buffer (count &optional beg end type)
    "Text-object: buffer entero."
    (evil-range (point-min) (point-max) 'line))
  (define-key evil-outer-text-objects-map "f" #'my/textobj-buffer)
  (define-key evil-inner-text-objects-map "f" #'my/textobj-buffer)

  ;; --- a"/a'/a` se comportan como i" (sin espacios alrededor) ---
  (define-key evil-outer-text-objects-map "\"" #'evil-inner-double-quote)
  (define-key evil-outer-text-objects-map "'"  #'evil-inner-single-quote)
  (define-key evil-outer-text-objects-map "`"  #'evil-inner-back-quote)

  ;; --- x → black hole register (no llena el yank) ---
  (define-key evil-normal-state-map "x"
              (lambda (count) (interactive "p")
                (evil-delete (point) (+ (point) count) 'char ?_)))

  ;; --- Visual paste no machaca el register ---
  (define-key evil-visual-state-map "p" #'evil-paste-after)

  ;; --- Ex command abbreviations (nvim cabbrev parity) ---
  (evil-ex-define-cmd "rm"    (lambda (&rest _) (call-interactively #'delete-file)))
  (evil-ex-define-cmd "mv"    (lambda (&rest _) (call-interactively #'rename-file)))
  (evil-ex-define-cmd "mkdir" (lambda (&rest _) (call-interactively #'make-directory)))
  (evil-ex-define-cmd "git"   (lambda (&rest _) (call-interactively #'magit-status)))
  (evil-ex-define-cmd "man"   (lambda (&rest _) (call-interactively #'man))))

;; Insert: C-v pega del clipboard del sistema
(map! :i "C-v" #'clipboard-yank)

;; ============================================================
;; AVY: jump-to-char (port de flash.nvim)
;; ============================================================
;; Doom bindea s/S a `evil-snipe' por default; lo desactivamos y usamos avy.

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
;; Doom ya provee SPC g s/r/[/] vía +vc-gutter. Sumo preview y text-object.

(after! evil
  (evil-define-text-object my/textobj-hunk (count &optional beg end type)
    "Text-object: el hunk diff-hl bajo el cursor."
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
;; KEYMAPS varios (nvim parity)
;; ============================================================

;; <BS> → buffer alterno (nvim: <bs> = :b#)
(map! :n "<backspace>" #'evil-switch-to-windows-last-buffer)

;; C-l → redraw + nohlsearch
(defun my/redraw-and-nohlsearch ()
  (interactive)
  (evil-ex-nohighlight)
  (recenter))
(map! :n "C-l" #'my/redraw-and-nohlsearch)

;; M-/ / M-? → buscar dentro de la selección visual
(map! :v "M-/" #'evil-ex-search-forward
      :v "M-?" #'evil-ex-search-backward)

;; gF → ir a archivo + número de línea (nvim: gF / ]f)
(map! :n "g F" #'find-file-at-point)

;; C-w >/< → resize con factor 2 (nvim default; Doom default es 1)
(map! :n "C-w >" (cmd! (evil-window-increase-width 2))
      :n "C-w <" (cmd! (evil-window-decrease-width 2))
      :n "C-w +" (cmd! (evil-window-increase-height 2))
      :n "C-w -" (cmd! (evil-window-decrease-height 2)))

;; zV → cerrar todos los folds excepto el actual
(defun my/fold-all-except-current ()
  "Hide all folds, then show only the block at point."
  (interactive)
  (when (bound-and-true-p hs-minor-mode)
    (hs-hide-all)
    (hs-show-block)))
(map! :n "z V" #'my/fold-all-except-current)

;; C-g + / C-g = → corregir spelling en insert
(after! flyspell-correct
  (map! :i "C-g +" #'flyspell-correct-at-point
        :i "C-g =" #'flyspell-correct-previous))

;; ============================================================
;; FOLD text-object (nvim: iz / az)
;; ============================================================
(after! evil
  (evil-define-text-object my/textobj-fold (count &optional beg end type)
    "Text-object: el fold bajo el cursor (hideshow)."
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
  "Run `doom SUBCMD' asíncrono desde `user-emacs-directory'."
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
;; OTROS
;; ============================================================

;; SPC ; → eval-expression rápido (nvim: cabbrev `;` → :=)
(map! :leader :desc "Eval expression" ";" #'eval-expression)

;; yc → yank line comentada (nvim parity)
(defun my/yank-line-commented ()
  "Duplica la línea actual y comenta la copia debajo."
  (interactive)
  (let ((line (buffer-substring (line-beginning-position) (line-end-position))))
    (save-excursion (end-of-line) (newline) (insert line))
    (forward-line)
    (comment-line 1)))

(map! :n "y c" #'my/yank-line-commented)

;; SPC c c → limpiar hl búsqueda
(map! :leader :desc "Clear search hl" "c c" #'evil-ex-nohighlight)
