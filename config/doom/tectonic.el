;;; tectonic.el --- Configuración para Tectonic con Doom Emacs -*- lexical-binding: t; -*-

(defvar tectonic-pdf-window nil
  "Ventana donde se muestra el PDF de Tectonic.")

(defun tectonic-compile-silent ()
  "Compila el proyecto Tectonic silenciosamente en segundo plano."
  (let* ((project-root (or (locate-dominating-file default-directory "Tectonic.toml")
                           (locate-dominating-file default-directory "src/")
                           default-directory))
         (default-directory project-root))
    (when (file-exists-p "Tectonic.toml")
      (start-process "tectonic-compile" "*Tectonic Output*" "tectonic" "-X" "build"))))

(defun tectonic-show-pdf ()
  "Muestra el PDF compilado en un split vertical."
  (let* ((project-root (or (locate-dominating-file default-directory "Tectonic.toml")
                           default-directory))
         (pdf-file (expand-file-name "build/default/default.pdf" project-root)))
    (when (file-exists-p pdf-file)
      (if (and tectonic-pdf-window (window-live-p tectonic-pdf-window))
          (with-selected-window tectonic-pdf-window
            (let ((pdf-buffer (find-file-noselect pdf-file)))
              (switch-to-buffer pdf-buffer)
              (when (eq major-mode 'pdf-view-mode)
                (pdf-view-revert-buffer nil t))
              (when (eq major-mode 'doc-view-mode)
                (doc-view-revert-buffer nil t))))
        (let ((current-window (selected-window)))
          (setq tectonic-pdf-window (split-window-right))
          (select-window tectonic-pdf-window)
          (find-file pdf-file)
          (when (eq major-mode 'pdf-view-mode)
            (tectonic--disable-conflicting-modes))
          (select-window current-window))))))

(defun tectonic-compile-and-show ()
  "Compila Tectonic silenciosamente y muestra el PDF al finalizar."
  (interactive)
  (let* ((project-root (or (locate-dominating-file default-directory "Tectonic.toml")
                           (locate-dominating-file default-directory "src/")
                           default-directory))
         (default-directory project-root))
    (when (file-exists-p "Tectonic.toml")
      (let ((proc (start-process "tectonic-compile" "*Tectonic Output*" "tectonic" "-X" "build")))
        (set-process-sentinel
         proc
         (lambda (_proc event)
           (when (string-match "finished" event)
             (message "Compilación completada.")
             (tectonic-show-pdf))
           (when (string-match "exited abnormally" event)
             (message "Error en la compilación de Tectonic."))))))))

(defun tectonic-auto-compile ()
  "Auto-compila archivos LaTeX con Tectonic al guardar."
  (when (and buffer-file-name
             (or (eq major-mode 'latex-mode)
                 (eq major-mode 'LaTeX-mode))
             (or (locate-dominating-file default-directory "Tectonic.toml")
                 (locate-dominating-file default-directory "src/")))
    (tectonic-compile-and-show)))

(defun tectonic-toggle-pdf ()
  "Alterna la visualización del PDF compilado."
  (interactive)
  (if (and tectonic-pdf-window (window-live-p tectonic-pdf-window))
      (tectonic-close-pdf)
    (tectonic-show-pdf)))

(defun tectonic-close-pdf ()
  "Cierra la ventana del PDF de Tectonic."
  (interactive)
  (when (and tectonic-pdf-window (window-live-p tectonic-pdf-window))
    (delete-window tectonic-pdf-window)
    (setq tectonic-pdf-window nil)))

(defun tectonic--disable-conflicting-modes ()
  "Desactiva modos incompatibles con `pdf-view-mode`."
  (when (bound-and-true-p display-line-numbers-mode)
    (display-line-numbers-mode -1))
  (when (bound-and-true-p hl-line-mode)
    (hl-line-mode -1))
  (when (bound-and-true-p linum-mode)
    (linum-mode -1))
  (when (bound-and-true-p nlinum-mode)
    (nlinum-mode -1)))

;;;###autoload
(defun tectonic-setup ()
  "Configura Tectonic para Doom Emacs."

  ;; Hook para guardar (C-x C-s y :w)
  (add-hook 'after-save-hook #'tectonic-auto-compile)

  ;; Extra para Evil :w
  (when (featurep 'evil)
    (advice-add 'evil-write :after
                (lambda (&rest _) (tectonic-auto-compile))))

  ;; PDF viewer ajustes
  (when (featurep 'pdf-tools)
    (add-hook 'pdf-view-mode-hook #'tectonic--disable-conflicting-modes)

    ;; Registrar modos incompatibles explícitamente
    (setq pdf-view-incompatible-modes
          (append pdf-view-incompatible-modes
                  '(display-line-numbers-mode
                    linum-mode
                    hl-line-mode
                    nlinum-mode))))

  ;; Configuración de AUCTeX si está disponible
  (with-eval-after-load 'tex
    (setq TeX-command-default "Tectonic")
    (add-to-list 'TeX-command-list
                 '("Tectonic" "tectonic -X build" TeX-run-command nil t
                   :help "Run Tectonic build"))
    (setq split-height-threshold nil)
    (setq split-width-threshold 120)

    (when (featurep 'evil)
      (map! :localleader
            :map (latex-mode-map LaTeX-mode-map)
            :desc "Compilar y mostrar PDF" "c" #'tectonic-compile-and-show
            :desc "Alternar PDF" "v" #'tectonic-toggle-pdf
            :desc "Cerrar PDF" "q" #'tectonic-close-pdf)))

  (message "Tectonic configurado correctamente"))

;; Ejecutar setup al cargar el archivo
(tectonic-setup)

(provide 'tectonic)
;;; tectonic.el ends here
