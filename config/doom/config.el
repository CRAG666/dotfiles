(setq user-full-name "Diego Aguilar"
      user-mail-address "dcrag@pm.me")

(setq confirm-kill-emacs nil)

;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq doom-font (font-spec :family "DankMono Nerd Font Mono" :size 25)
      doom-unicode-font (font-spec :family "Iosevka Nerd Font" :size 14)
      doom-big-font (font-spec :family "DankMono Nerd Font Mono" :size 28))

(custom-set-faces!
  '(font-lock-keyword-face :slant italic))

(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'mocha) ; or 'frappe 'latte, 'macchiato, or 'mocha
(load-theme 'catppuccin t)

(setq display-line-numbers-type 'relative)
(setq display-line-numbers-exempt-modes '(pdf-view-mode doc-view-mode image-mode vterm-mode))

(setq doom-modeline-icon t)
(setq doom-modeline-major-mode-icon t)
(setq doom-modeline-lsp-icon t)
(setq doom-modeline-major-mode-color-icon t)

(setq org-directory "~/Documentos/Org/")

(load! "tectonic")

;; Performance optimizations
(setq gc-cons-threshold (* 256 1024 1024))
(setq read-process-output-max (* 4 1024 1024))
(setq comp-deferred-compilation t)
(setq comp-async-jobs-number 8)

;; Garbage collector optimization
(setq gcmh-idle-delay 5)
(setq gcmh-high-cons-threshold (* 1024 1024 1024))

;; Version control optimization
(setq vc-handled-backends '(Git))

(setq browse-url-browser-function 'browse-url-generic)
(setq browse-url-generic-program "zen-browser")

(setq which-key-idle-delay 0.2)

;; Evil-escape sequence
(setq-default evil-escape-key-sequence "kj")
(setq-default evil-escape-delay 0.1)

;; Don't move cursor back when exiting insert mode
(setq evil-move-cursor-back nil)
;; granular undo with evil mode
(setq evil-want-fine-undo t)
;; Enable paste from system clipboard with C-v in insert mode
(evil-define-key 'insert global-map (kbd "C-v") 'clipboard-yank)

;; ------------------------------
;; Limpieza visual para vterm
;; ------------------------------
(defun my/vterm-cleanup ()
  "Limpiar interfaz en buffers vterm."
  (display-line-numbers-mode -1)
  (setq-local global-hl-line-mode nil)
  (setq-local mode-line-format nil))

(add-hook 'vterm-mode-hook #'my/vterm-cleanup)

(load! "keybinds.el")

;; Configuración específica para Python
(after! python
  ;; Asegúrate de que lsp-mode esté activo para Python
  (setq lsp-pyright-formatting-provider "ruff"))

;; Opcional: Configura ruff como linter también
(add-hook 'python-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'lsp-format-buffer nil t)))

;; Habilita corfu globalmente
(use-package corfu
  :init
  (global-corfu-mode t) ; Activa corfu en todos los modos
  :config
  ;; Personaliza el comportamiento de corfu
  (setq corfu-cycle t) ; Permite ciclar entre las opciones
  (setq corfu-auto t)  ; Muestra sugerencias automáticamente
  (setq corfu-auto-delay 0.1) ; Retardo antes de mostrar sugerencias
  (setq corfu-quit-at-boundary nil) ; No cierra corfu al llegar al límite
  (setq corfu-quit-no-match 'separator) ; Cierra corfu si no hay coincidencias
  )
