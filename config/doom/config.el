;;; config.el -*- lexical-binding: t; -*-

;; ============================================================
;; Identity
;; ============================================================
(setq user-full-name    "Diego Aguilar"
      user-mail-address "dcrag@pm.me"
      confirm-kill-emacs nil)

;; ============================================================
;; Mason binaries on PATH (installed from nvim)
;; ============================================================
;; The Emacs daemon started by systemd inherits PATH=/usr/local/bin:/usr/bin
;; (it does not read .zshrc). Without this, basedpyright, lua-language-server,
;; marksman, texlab, etc. installed by Mason in nvim are not found.
(let ((mason-bin (expand-file-name "~/.local/share/nvim/mason/bin")))
  (when (file-directory-p mason-bin)
    (add-to-list 'exec-path mason-bin)
    (setenv "PATH" (concat mason-bin path-separator (getenv "PATH")))))

;; ============================================================
;; Font (aligned with kitty/kitty.conf)
;; ============================================================
(setq doom-font              (font-spec :family "DankMono Nerd Font Mono" :size 20.0)
      doom-unicode-font      (font-spec :family "Iosevka Nerd Font"       :size 20.0)
      doom-big-font          (font-spec :family "DankMono Nerd Font Mono" :size 26.0)
      doom-variable-pitch-font (font-spec :family "DankMono Nerd Font"    :size 20.0))

;; ============================================================
;; "eyes" theme (auto-discovered from $DOOMDIR/themes/)
;; Reads ~/.config/eyes/mode for light/dark (parity with nvim).
;; ============================================================
(defun my/eyes-mode-from-file ()
  "Return `dark' or `light' by reading ~/.config/eyes/mode (default light)."
  (let ((path (expand-file-name "~/.config/eyes/mode")))
    (if (and (file-exists-p path)
             (with-temp-buffer
               (insert-file-contents path)
               (string-match-p "\\<dark\\>" (buffer-string))))
        'dark 'light)))

(setq doom-theme (if (eq (my/eyes-mode-from-file) 'dark) 'eyes-dark 'eyes))

(defun my/eyes-toggle ()
  "Toggle between `eyes' and `eyes-dark', persisting to ~/.config/eyes/mode."
  (interactive)
  (let* ((new  (if (eq doom-theme 'eyes-dark) 'eyes 'eyes-dark))
         (mode (if (eq new 'eyes-dark) "dark" "light"))
         (path (expand-file-name "~/.config/eyes/mode")))
    (disable-theme doom-theme)
    (load-theme new t)
    (setq doom-theme new)
    (make-directory (file-name-directory path) t)
    (with-temp-file path (insert mode))
    (message "Eyes theme: %s" mode)))

(map! :leader :desc "Eyes toggle light/dark" "t e" #'my/eyes-toggle)

;; ============================================================
;; UI
;; ============================================================
(setq display-line-numbers-type 'relative
      display-line-numbers-exempt-modes
      '(pdf-view-mode doc-view-mode image-mode vterm-mode)
      browse-url-browser-function 'browse-url-generic
      browse-url-generic-program  "zen-browser")

(after! which-key
  (setq which-key-idle-delay 0.2))

;; Real overrides only: Doom forces `major-mode-icon` to nil; the rest
;; (icon / lsp-icon / major-mode-color-icon) is already t upstream by default.
(after! doom-modeline
  (setq doom-modeline-major-mode-icon t))

;; ============================================================
;; Fontification (parity with nvim)
;; ============================================================
;; Maximum level of the native treesit engine (Emacs 29+). Default is 3
;; — raise to 4 to enable every decoration feature (operator,
;; bracket, delimiter, function-call, property, variable-use, etc.).
(setq treesit-font-lock-level 4)

;; `treesit-auto' remaps *-mode → *-ts-mode and offers to install
;; missing grammars the first time you open a file in that language.
;; Replaces Doom's +tree-sitter flag (legacy tree-sitter.el engine).
(use-package! treesit-auto
  :demand t
  :custom (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; `evil-textobj-tree-sitter' detects `*-ts-mode' and uses native treesit
;; automatically (via `evil-textobj-tree-sitter--use-builtin-treesitter');
;; the legacy parser does not need to be enabled.

;; Custom faces for tokens that neither font-lock nor treesit distinguish
;; on their own (parameters, members, namespaces, macros, decorators).
;; The `eyes` theme customizes them; here they are only declared so they
;; exist before treesit/eglot request them.
(defface eyes-parameter-face   '((t :inherit font-lock-variable-name-face :slant italic))
  "Function parameters via LSP semantic tokens.")
(defface eyes-member-face      '((t :inherit font-lock-property-use-face))
  "Struct members/properties via LSP semantic tokens.")
(defface eyes-namespace-face   '((t :inherit font-lock-constant-face))
  "Namespaces/modules via LSP semantic tokens.")
(defface eyes-macro-face       '((t :inherit font-lock-preprocessor-face))
  "Macros via LSP semantic tokens.")
(defface eyes-decorator-face   '((t :inherit font-lock-preprocessor-face :slant italic))
  "Decorators via LSP semantic tokens.")
(defface eyes-constructor-face '((t :inherit font-lock-type-face))
  "Constructors via LSP semantic tokens.")
(defface eyes-module-face      '((t :inherit font-lock-constant-face))
  "Modules via LSP semantic tokens.")
(defface eyes-return-face      '((t :inherit font-lock-warning-face))
  "`return' keyword via treesit.")
(defface eyes-exception-face   '((t :inherit font-lock-warning-face :weight bold))
  "Exception keywords via treesit.")
(defface eyes-import-face      '((t :inherit font-lock-preprocessor-face))
  "Import keywords via treesit.")
(defface eyes-keyword-op-face  '((t :inherit font-lock-operator-face :weight bold))
  "Operators that are keywords (and/or/in/is) via treesit.")

;; LSP semantic tokens → eyes-* faces. Doom uses `lsp-mode' (not eglot) and
;; leaves `lsp-semantic-tokens-enable' off by default — so parameters and
;; properties ended up the same color as variables. This mapping gives
;; granularity equivalent to @lsp.type.* in nvim/colors/eyes.lua.
(after! lsp-mode
  (setq lsp-semantic-tokens-enable t
        lsp-semantic-tokens-honor-refresh-requests t
        lsp-idle-delay 0.5
        lsp-log-io nil
        lsp-file-watch-threshold 10000
        lsp-enable-file-watchers nil
        ;; Extra perf: features whose cost (LSP request per cursor move) adds
        ;; nothing over what treesit-font-lock-level 4 + semantic tokens give.
        lsp-enable-symbol-highlighting nil       ; kills textDocument/documentHighlight per cursor move
        lsp-enable-links nil                     ; kills textDocument/documentLink
        lsp-modeline-code-actions-enable nil     ; kills textDocument/codeAction per cursor move
        ;; Signature help: add :after-completion to the default to show the
        ;; signature after accepting a function name (parity with blink.cmp).
        lsp-signature-auto-activate '(:on-trigger-char :after-completion :on-server-request)
        lsp-signature-render-documentation t
        lsp-semantic-token-faces
        '(("namespace"     . eyes-namespace-face)
          ("type"          . font-lock-type-face)
          ("class"         . font-lock-type-face)
          ("enum"          . font-lock-type-face)
          ("interface"     . font-lock-type-face)
          ("struct"        . font-lock-type-face)
          ("typeParameter" . font-lock-type-face)
          ("parameter"     . eyes-parameter-face)
          ("variable"      . font-lock-variable-name-face)
          ("property"      . eyes-member-face)
          ("enumMember"    . font-lock-constant-face)
          ("event"         . font-lock-warning-face)
          ("function"      . font-lock-function-name-face)
          ("method"        . font-lock-function-name-face)
          ("macro"         . eyes-macro-face)
          ("keyword"       . font-lock-keyword-face)
          ("modifier"      . font-lock-keyword-face)
          ("comment"       . font-lock-comment-face)
          ("string"        . font-lock-string-face)
          ("number"        . font-lock-number-face)
          ("regexp"        . font-lock-regexp-face)
          ("operator"      . font-lock-operator-face)
          ("decorator"     . eyes-decorator-face))))

;; ============================================================
;; Evil
;; ============================================================
(after! evil
  (setq evil-move-cursor-back nil
        evil-want-fine-undo   t))

;; ============================================================
;; vterm
;; ============================================================
(defun my/vterm-cleanup ()
  "Clean up the UI in vterm buffers."
  (display-line-numbers-mode -1)
  (setq-local global-hl-line-mode nil
              mode-line-format    nil))

(add-hook! 'vterm-mode-hook #'my/vterm-cleanup)

(set-popup-rule! "^\\*doom:vterm"
  :side 'right :size 0.5 :select t :quit nil :ttl 0)

;; ============================================================
;; Org
;; ============================================================
(setq org-directory "~/Documents/Org/")

;; ============================================================
;; Python
;; ============================================================
(after! lsp-pyright
  ;; Mason installs `basedpyright-langserver' (a pyright fork); the official
  ;; `pyright-langserver' binary is absent. Without this lsp-pyright fails to
  ;; connect and only ruff remains (which lacks textDocument/completion).
  (setq lsp-pyright-langserver-command "basedpyright"
        lsp-pyright-formatting-provider "ruff"))

;; ============================================================
;; Performance
;; ============================================================
;; LSP pipe buffer at 1MB (default 4KB; pyright sends chunks >800KB).
(setq read-process-output-max (* 1024 1024))

;; native-comp tuning (Emacs 30 with native-comp enabled).
(after! comp
  (setq native-comp-async-jobs-number (max 1 (- (num-processors) 1))
        native-comp-async-report-warnings-errors 'silent
        native-comp-speed 2))

;; ============================================================
;; Modular loading
;; ============================================================
(load! "options")   ; general options (fill-column, scroll, undo, etc.)
(load! "autocmds")  ; trim whitespace, projectile search path
(load! "lang")      ; per-language settings
(load! "tectonic")  ; LaTeX live preview with tectonic
(load! "keybinds")  ; keymaps custom
