;;; config.el -*- lexical-binding: t; -*-

;; ============================================================
;; Identidad
;; ============================================================
(setq user-full-name    "Diego Aguilar"
      user-mail-address "dcrag@pm.me"
      confirm-kill-emacs nil)

;; ============================================================
;; Mason binaries en PATH (instalados desde nvim)
;; ============================================================
;; El daemon de Emacs lanzado por systemd hereda PATH=/usr/local/bin:/usr/bin
;; (no lee .zshrc). Sin esto, basedpyright, lua-language-server, marksman,
;; texlab, etc. instalados por Mason en nvim no se encuentran.
(let ((mason-bin (expand-file-name "~/.local/share/nvim/mason/bin")))
  (when (file-directory-p mason-bin)
    (add-to-list 'exec-path mason-bin)
    (setenv "PATH" (concat mason-bin path-separator (getenv "PATH")))))

;; ============================================================
;; Fuente (alineada con kitty/kitty.conf)
;; ============================================================
(setq doom-font              (font-spec :family "DankMono Nerd Font Mono" :size 20.0)
      doom-unicode-font      (font-spec :family "Iosevka Nerd Font"       :size 20.0)
      doom-big-font          (font-spec :family "DankMono Nerd Font Mono" :size 26.0)
      doom-variable-pitch-font (font-spec :family "DankMono Nerd Font"    :size 20.0))

;; ============================================================
;; Tema "eyes" (auto-descubierto desde $DOOMDIR/themes/)
;; Lee ~/.config/eyes/mode para light/dark (paridad con nvim).
;; ============================================================
(defun my/eyes-mode-from-file ()
  "Devuelve `dark' o `light' leyendo ~/.config/eyes/mode (default light)."
  (let ((path (expand-file-name "~/.config/eyes/mode")))
    (if (and (file-exists-p path)
             (with-temp-buffer
               (insert-file-contents path)
               (string-match-p "\\<dark\\>" (buffer-string))))
        'dark 'light)))

(setq doom-theme (if (eq (my/eyes-mode-from-file) 'dark) 'eyes-dark 'eyes))

(defun my/eyes-toggle ()
  "Alterna entre `eyes' y `eyes-dark', persiste en ~/.config/eyes/mode."
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

;; Sólo overrides reales: Doom fuerza `major-mode-icon` a nil; el resto
;; (icon / lsp-icon / major-mode-color-icon) ya es t por default upstream.
(after! doom-modeline
  (setq doom-modeline-major-mode-icon t))

;; ============================================================
;; Fontificación (paridad con nvim)
;; ============================================================
;; Nivel máximo del motor treesit nativo (Emacs 29+). Por defecto es 3
;; — sube a 4 para activar todas las features de decoración (operator,
;; bracket, delimiter, function-call, property, variable-use, etc.).
(setq treesit-font-lock-level 4)

;; `treesit-auto' remappea *-mode → *-ts-mode y se ofrece a instalar
;; gramáticas faltantes la primera vez que abrís un archivo del lenguaje.
;; Reemplaza el flag +tree-sitter de Doom (motor legacy tree-sitter.el).
(use-package! treesit-auto
  :demand t
  :custom (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; `evil-textobj-tree-sitter' detecta `*-ts-mode' y usa treesit nativo
;; automáticamente (vía `evil-textobj-tree-sitter--use-builtin-treesitter');
;; no requiere activar el parser legacy.

;; Caras propias para tokens que ni font-lock ni treesit distinguen por
;; sí solos (parámetros, miembros, namespaces, macros, decoradores).
;; El theme `eyes` las customiza; aquí sólo se declaran para que existan
;; antes de que treesit/eglot las pidan.
(defface eyes-parameter-face   '((t :inherit font-lock-variable-name-face :slant italic))
  "Parámetros de función vía LSP semantic tokens.")
(defface eyes-member-face      '((t :inherit font-lock-property-use-face))
  "Miembros/propiedades de struct vía LSP semantic tokens.")
(defface eyes-namespace-face   '((t :inherit font-lock-constant-face))
  "Namespaces/módulos vía LSP semantic tokens.")
(defface eyes-macro-face       '((t :inherit font-lock-preprocessor-face))
  "Macros vía LSP semantic tokens.")
(defface eyes-decorator-face   '((t :inherit font-lock-preprocessor-face :slant italic))
  "Decoradores vía LSP semantic tokens.")
(defface eyes-constructor-face '((t :inherit font-lock-type-face))
  "Constructores vía LSP semantic tokens.")
(defface eyes-module-face      '((t :inherit font-lock-constant-face))
  "Módulos vía LSP semantic tokens.")
(defface eyes-return-face      '((t :inherit font-lock-warning-face))
  "Keyword `return' vía treesit.")
(defface eyes-exception-face   '((t :inherit font-lock-warning-face :weight bold))
  "Keywords de excepción vía treesit.")
(defface eyes-import-face      '((t :inherit font-lock-preprocessor-face))
  "Keywords de import vía treesit.")
(defface eyes-keyword-op-face  '((t :inherit font-lock-operator-face :weight bold))
  "Operadores que son keywords (and/or/in/is) vía treesit.")

;; LSP semantic tokens → caras eyes-*. Doom usa `lsp-mode' (no eglot) y
;; deja `lsp-semantic-tokens-enable' off por default — por eso parámetros
;; y propiedades quedaban del mismo color que variables. Este mapping da
;; la granularidad equivalente a @lsp.type.* en nvim/colors/eyes.lua.
(after! lsp-mode
  (setq lsp-semantic-tokens-enable t
        lsp-semantic-tokens-honor-refresh-requests t
        lsp-idle-delay 0.5
        lsp-log-io nil
        lsp-file-watch-threshold 10000
        lsp-enable-file-watchers nil
        ;; Perf extra: features cuyo costo (LSP request por cursor move) no
        ;; aporta vs lo que ya da treesit-font-lock-level 4 + semantic tokens.
        lsp-enable-symbol-highlighting nil       ; mata textDocument/documentHighlight por cursor move
        lsp-enable-links nil                     ; mata textDocument/documentLink
        lsp-modeline-code-actions-enable nil     ; mata textDocument/codeAction por cursor move
        ;; Signature help: añade :after-completion al default para mostrar
        ;; firma tras aceptar nombre de función (paridad con blink.cmp).
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
  "Limpia interfaz en buffers vterm."
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
  ;; Mason instala `basedpyright-langserver' (fork de pyright); el binario
  ;; oficial `pyright-langserver' no está. Sin esto lsp-pyright no conecta
  ;; y solo queda ruff (que no soporta textDocument/completion).
  (setq lsp-pyright-langserver-command "basedpyright"
        lsp-pyright-formatting-provider "ruff"))

;; ============================================================
;; Performance
;; ============================================================
;; Buffer de pipe LSP a 1MB (default 4KB; pyright manda chunks >800KB).
(setq read-process-output-max (* 1024 1024))

;; Tuning native-comp (Emacs 30 con native-comp habilitado).
(after! comp
  (setq native-comp-async-jobs-number (max 1 (- (num-processors) 1))
        native-comp-async-report-warnings-errors 'silent
        native-comp-speed 2))

;; ============================================================
;; Carga modular
;; ============================================================
(load! "options")   ; opciones generales (fill-column, scroll, undo, etc.)
(load! "autocmds")  ; trim whitespace, projectile search path
(load! "lang")      ; ajustes per-lenguaje
(load! "tectonic")  ; LaTeX live preview con tectonic
(load! "keybinds")  ; keymaps custom
