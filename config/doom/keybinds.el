;;; ~/.doom.d/keybinds.el -*- lexical-binding: t; -*-

;; 🧱 BLOQUES: evil-textobj-anyblock
(use-package! evil-textobj-anyblock
  :after evil
  :config
  ;; “b” será el text-object para cualquier bloque { } [ ] ( )
  (define-key evil-inner-text-objects-map "b" #'evil-textobj-anyblock-inner-block)
  (define-key evil-outer-text-objects-map "b" #'evil-textobj-anyblock-a-block))

;; 🔁 DELIMITADORES: embrace (complemento a evil-surround)
(use-package! embrace
  :after evil
  :config
  (add-hook 'org-mode-hook #'embrace-org-mode-hook)
  (setq embrace-show-help-p t)
  (evil-define-key 'visual 'global "s" #'embrace-commander))

(defun my/smart-buffer-switch ()
  "Si hay un prefijo numérico, cambia a ese buffer por número.
Si no, cambia al buffer anterior o al siguiente si no hay anterior."
  (interactive)
  (let ((n current-prefix-arg))
    (cond
     ((numberp n)
      ;; Cambiar al buffer N (en orden del buffer-list)
      (let ((buf (nth (1- n) (buffer-list))))
        (if buf
            (switch-to-buffer buf)
          (message "No buffer en la posición %d" n))))
     (t
      ;; Si hay buffer anterior, ve a él; si no, al siguiente
      (if (buffer-live-p (other-buffer))
          (switch-to-buffer (other-buffer))
        (next-buffer))))))

;; Mapear a <backspace> en modo normal
(map! :n "<backspace>" #'my/smart-buffer-switch)


;; Define a vterm popup toggle
(map! :leader
      :desc "Toggle vterm"
      "t t" #'my/toggle-vterm)

(defvar my/vterm-buffer-name "*doom:vterm*")

(defun my/toggle-vterm ()
  "Toggle a persistent vterm popup window."
  (interactive)
  (let ((vterm-buffer (get-buffer my/vterm-buffer-name)))
    (if vterm-buffer
        (if (get-buffer-window vterm-buffer)
            (delete-window (get-buffer-window vterm-buffer))
          (pop-to-buffer vterm-buffer))
      (progn
        (vterm my/vterm-buffer-name)
        (pop-to-buffer my/vterm-buffer-name)))))

;; Definir mapas de teclas para buscar y reemplazar
(map! :leader
      (:prefix ("r" . "replace")
       :desc "Replace in current line"  "l" #'my/replace-in-line
       :desc "Replace in entire file"  "r" #'my/replace-in-file
       :desc "Replace with extended pattern" "e" #'my/replace-in-structure
       :desc "Replace word in entire file" "w" #'my/replace-word-in-file
       :desc "Replace next word occurrence" "n" #'my/replace-next-word
       :desc "Replace previous word occurrence" "N" #'my/replace-prev-word))

;; Función para buscar y reemplazar en la línea actual
(defun my/replace-in-line ()
  "Busca y reemplaza en la línea actual usando Evil."
  (interactive)
  (evil-ex "s/"))

;; Función para buscar y reemplazar en todo el archivo
(defun my/replace-in-file ()
  "Busca y reemplaza en todo el archivo usando Evil."
  (interactive)
  (evil-ex "%s/"))

(defun my/replace-in-structure ()
  "Busca y reemplaza en la línea actual usando Evil."
  (interactive)
  (evil-ex "%s/\\(.*\\)/\\1/g"))

(defun my/replace-word-in-file ()
  "Reemplaza la palabra actual en todo el archivo."
  (interactive)
  (let ((word (thing-at-point 'word t)))
    (when word
      (evil-ex (format "%%s/\\<%s\\>/" word)))))

(defun my/replace-next-word ()
  "Encuentra la siguiente ocurrencia de la palabra bajo el cursor y entra en modo reemplazo."
  (interactive)
  (let ((word (thing-at-point 'word t)))
    (when word
      (evil-search word 'forward t)
      (evil-change (point) (progn (evil-search word 'forward t) (point))))))

(defun my/replace-prev-word ()
  "Encuentra la ocurrencia anterior de la palabra bajo el cursor y entra en modo reemplazo."
  (interactive)
  (let ((word (thing-at-point 'word t)))
    (when word
      (evil-search word 'backward t)
      (evil-change (point) (progn (evil-search word 'backward t) (point))))))

;; Deshabilitar mapeos predeterminados de Doom Emacs en modo normal
(after! evil
  (define-key evil-normal-state-map (kbd "C-d") nil)
  (define-key evil-normal-state-map (kbd "C-u") nil)
  (define-key evil-normal-state-map (kbd "n") nil)
  (define-key evil-normal-state-map (kbd "N") nil))

;; Mapeos personalizados para centrar la pantalla después de los movimientos canción
(map! :n "C-d" (lambda () (interactive) (evil-scroll-down 0) (recenter))
      :n "C-u" (lambda () (interactive) (evil-scroll-up 0) (recenter))
      :n "n"   (lambda () (interactive) (evil-ex-search-next) (recenter) (evil-scroll-line-to-top-if-folded nil))
      :n "N"   (lambda () (interactive) (evil-ex-search-previous) (recenter) (evil-scroll-line-to-top-if-folded nil)))


(defun my/toggle-flyspell-es-mx-or-en-us ()
  "Toggle Flyspell mode, prompting for es, es_MX, or en_US dictionary if enabling."
  (interactive)
  (if (bound-and-true-p flyspell-mode)
      (progn
        (flyspell-mode -1)
        (message "Flyspell disabled"))
    (let ((dict (completing-read "Select dictionary: " '("es" "en_US") nil t)))
      (if (member dict (ispell-valid-dictionary-list))
          (progn
            (ispell-change-dictionary dict)
            (flyspell-mode 1)
            (message "Flyspell enabled with %s dictionary" dict))
        (message "Dictionary %s is not available" dict)))))

(map! :leader
      :desc "Cambiar idioma del corrector"
      "s c" #'my/toggle-flyspell-es-mx-or-en-us)

;; zoom in/out like we do everywhere else.
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
