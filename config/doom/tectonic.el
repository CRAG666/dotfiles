;;; tectonic.el --- Tectonic minimal compile + PDF preview -*- lexical-binding: t; -*-
;;
;; Comandos:
;;   - SPC m c : elegir Project/Single y lanzar `tectonic -X watch`
;;   - SPC m v : toggle ventana del PDF
;;   - SPC m k : detener el watch
;;   - SPC m f : SyncTeX forward search (TeX → PDF)
;;   - SPC m s : toggle follow-mode (cursor TeX sincroniza el PDF en vivo)
;;
;; Inverse search (PDF → TeX): doble click en el PDF (pdf-sync-minor-mode).

;; ============================================================
;; AucTeX: deshabilitar chequeo TeX Live + PATH
;; ============================================================
(after! tex
  (setq TeX-check-TeX nil
        TeX-check-TeX-command nil))

(let ((local-bin (expand-file-name "~/.local/bin")))
  (unless (member local-bin exec-path) (add-to-list 'exec-path local-bin))
  (unless (string-match-p (regexp-quote local-bin) (or (getenv "PATH") ""))
    (setenv "PATH" (concat local-bin ":" (getenv "PATH")))))

(defvar tectonic-executable
  (or (executable-find "tectonic")
      (expand-file-name "~/.local/bin/tectonic")))

;; ============================================================
;; Estado
;; ============================================================

(defvar tectonic-watch-process nil)
(defvar tectonic-watch-buffer "*Tectonic Watch*")
(defvar tectonic-pdf-window nil)
(defvar tectonic--last-mode nil)            ; 'project | 'single
(defvar tectonic--last-source-file nil)
(defvar tectonic--last-project-root nil)
(defvar tectonic--pdf-watch nil)            ; handle de file-notify activo

;; ============================================================
;; Detección + path del PDF
;; ============================================================

(defun tectonic--project-root ()
  (or (locate-dominating-file default-directory "Tectonic.toml")
      (locate-dominating-file default-directory "src/")))

(defun tectonic--current-pdf ()
  (pcase tectonic--last-mode
    ('single  (concat (file-name-sans-extension tectonic--last-source-file) ".pdf"))
    ('project (expand-file-name "build/default/default.pdf"
                                (or tectonic--last-project-root default-directory)))
    (_        (concat (file-name-sans-extension (or (buffer-file-name) "")) ".pdf"))))

;; ============================================================
;; Watch process + apertura asíncrona del PDF (file-notify)
;; ============================================================

(defun tectonic--cancel-pdf-watch ()
  (when tectonic--pdf-watch
    (ignore-errors (file-notify-rm-watch tectonic--pdf-watch))
    (setq tectonic--pdf-watch nil)))

(defun tectonic--schedule-pdf-open (src-buffer &optional retries)
  "Abre el PDF asíncronamente apenas exista. Sin polling activo: usa
`file-notify' sobre el directorio del PDF. Si ese directorio aún no
existe (p.ej. project mode antes del primer build), reintenta a 1 s
hasta RETRIES veces (default 60)."
  (require 'filenotify)
  (tectonic--cancel-pdf-watch)
  (when (buffer-live-p src-buffer)
    (with-current-buffer src-buffer
      (let* ((pdf      (tectonic--current-pdf))
             (pdf-dir  (file-name-directory pdf))
             (pdf-name (file-name-nondirectory pdf))
             (retries  (or retries 60)))
        (cond
         ((file-exists-p pdf)
          (tectonic-show-pdf))
         ((file-directory-p pdf-dir)
          (setq tectonic--pdf-watch
                (file-notify-add-watch
                 pdf-dir '(change)
                 (lambda (event)
                   (when (and (equal (file-name-nondirectory (nth 2 event)) pdf-name)
                              (file-exists-p pdf))
                     (tectonic--cancel-pdf-watch)
                     (when (buffer-live-p src-buffer)
                       (with-current-buffer src-buffer
                         (tectonic-show-pdf))))))))
         ((> retries 0)
          (run-at-time 1.0 nil #'tectonic--schedule-pdf-open src-buffer (1- retries)))
         (t
          (message "Tectonic: directorio del PDF no apareció. Revisa %s"
                   tectonic-watch-buffer)))))))

(defun tectonic--start-watch (cmd)
  (unless (file-executable-p tectonic-executable)
    (user-error "tectonic no encontrado: %s" tectonic-executable))
  (when (process-live-p tectonic-watch-process)
    (kill-process tectonic-watch-process))
  (tectonic--cancel-pdf-watch)
  (let* ((root (tectonic--project-root))
         (default-directory (or root (file-name-directory (buffer-file-name))))
         (src-buffer (current-buffer)))
    (setq tectonic-watch-process
          (start-process-shell-command "tectonic-watch" tectonic-watch-buffer cmd))
    (message "Tectonic: %s" cmd)
    ;; Deferido al siguiente tick: el control vuelve al usuario sin esperar.
    (run-at-time 0 nil #'tectonic--schedule-pdf-open src-buffer)))

(defun tectonic-watch-project ()
  (interactive)
  (setq tectonic--last-mode 'project
        tectonic--last-project-root (tectonic--project-root))
  (tectonic--start-watch
   (format "%s -X watch -x 'build --synctex'" (shell-quote-argument tectonic-executable))))

(defun tectonic-watch-project-logs ()
  (interactive)
  (setq tectonic--last-mode 'project
        tectonic--last-project-root (tectonic--project-root))
  (tectonic--start-watch
   (format "%s -X watch -x 'build --synctex --keep-logs'"
           (shell-quote-argument tectonic-executable))))

(defun tectonic-watch-single ()
  (interactive)
  (let ((file (buffer-file-name)))
    (setq tectonic--last-mode 'single
          tectonic--last-source-file file)
    (tectonic--start-watch
     (format "%s -X watch -x 'compile %s --synctex --keep-logs -Zsearch-path=/latex'"
             (shell-quote-argument tectonic-executable)
             (shell-quote-argument file)))))

(defun tectonic-compile ()
  "SPC m c → elegir Project/Project+logs/Single y arrancar watch."
  (interactive)
  (unless (buffer-file-name) (user-error "Buffer sin archivo"))
  (let* ((in-project (tectonic--project-root))
         (options (if in-project '("Project" "Project + logs" "Single") '("Single")))
         (choice (completing-read "Tectonic mode: " options nil t)))
    (pcase choice
      ("Project"        (tectonic-watch-project))
      ("Project + logs" (tectonic-watch-project-logs))
      ("Single"         (tectonic-watch-single))
      (_                (message "Tectonic: cancelado")))))

(defun tectonic-stop ()
  "SPC m k → detener watch."
  (interactive)
  (tectonic--cancel-pdf-watch)
  (if (process-live-p tectonic-watch-process)
      (progn (kill-process tectonic-watch-process)
             (setq tectonic-watch-process nil)
             (message "Tectonic: detenido"))
    (message "Tectonic: no había proceso activo")))

;; ============================================================
;; PDF window
;; ============================================================

(defun tectonic--disable-conflicting-modes ()
  (when (bound-and-true-p display-line-numbers-mode) (display-line-numbers-mode -1))
  (when (bound-and-true-p hl-line-mode) (hl-line-mode -1)))

(defun tectonic-show-pdf ()
  "Abre/refresca el PDF en split derecho."
  (interactive)
  (let ((pdf (tectonic--current-pdf)))
    (cond
     ((not (file-exists-p pdf)) (message "PDF no existe aún: %s" pdf))
     ((and tectonic-pdf-window (window-live-p tectonic-pdf-window))
      (with-selected-window tectonic-pdf-window
        (find-file pdf)
        (when (eq major-mode 'pdf-view-mode)
          (pdf-view-revert-buffer nil t))))
     (t
      ;; auto-revert + disable-conflicting-modes los hace el hook global
      ;; sobre `pdf-view-mode-hook' más abajo.
      (let ((current (selected-window)))
        (setq tectonic-pdf-window (split-window-right))
        (select-window tectonic-pdf-window)
        (find-file pdf)
        (select-window current))))))

(defun tectonic-toggle-pdf ()
  "SPC m v → toggle ventana del PDF."
  (interactive)
  (if (and tectonic-pdf-window (window-live-p tectonic-pdf-window))
      (progn (delete-window tectonic-pdf-window)
             (setq tectonic-pdf-window nil))
    (tectonic-show-pdf)))

;; ============================================================
;; SyncTeX
;; ============================================================

(defun tectonic-forward-search ()
  "SPC m f → SyncTeX forward search: salta desde la línea actual del .tex
al punto correspondiente del PDF."
  (interactive)
  (require 'pdf-sync)
  (let* ((source (or (buffer-file-name) (user-error "Buffer sin archivo")))
         (line   (line-number-at-pos))
         (col    (current-column))
         (pdf    (tectonic--current-pdf)))
    (unless (file-exists-p pdf)
      (user-error "PDF no existe aún: %s" pdf))
    (unless (and tectonic-pdf-window (window-live-p tectonic-pdf-window))
      (tectonic-show-pdf))
    (let ((pdf-buffer (or (find-buffer-visiting pdf)
                          (user-error "PDF no está abierto: %s" pdf))))
      (with-selected-window tectonic-pdf-window
        (switch-to-buffer pdf-buffer)
        (let* ((result (pdf-info-synctex-forward-search source line col pdf))
               (page  (cdr (assq 'page result)))
               (edges (cdr (assq 'edges result)))
               (y1    (nth 1 edges)))
          (pdf-view-goto-page page)
          (let ((top (* y1 (cdr (pdf-view-image-size)))))
            (pdf-util-tooltip-arrow (round top))))))))

;; ============================================================
;; Follow mode: TeX → PDF en vivo al mover el cursor
;; ============================================================

(defcustom tectonic-follow-idle-delay 0.4
  "Segundos de idle antes de sincronizar el PDF con el cursor."
  :type 'number
  :group 'tectonic)

(defvar tectonic--follow-timer nil)
(defvar-local tectonic--follow-last-pos nil)

(defun tectonic--follow-do-sync (buf)
  (when (and (buffer-live-p buf) (eq (current-buffer) buf))
    (let ((pdf (tectonic--current-pdf)))
      (when (and (buffer-file-name)
                 (file-exists-p pdf)
                 tectonic-pdf-window
                 (window-live-p tectonic-pdf-window)
                 (find-buffer-visiting pdf)
                 (not (equal (point) tectonic--follow-last-pos)))
        (setq tectonic--follow-last-pos (point))
        (let ((inhibit-message t))
          (ignore-errors (tectonic-forward-search)))))))

(defun tectonic--follow-schedule ()
  (when (timerp tectonic--follow-timer)
    (cancel-timer tectonic--follow-timer))
  (setq tectonic--follow-timer
        (run-with-idle-timer tectonic-follow-idle-delay nil
                             #'tectonic--follow-do-sync (current-buffer))))

(define-minor-mode tectonic-follow-mode
  "Auto-SyncTeX: al mover el cursor en el .tex, el PDF salta al punto correspondiente."
  :lighter " TecFollow"
  (if tectonic-follow-mode
      (progn
        (setq tectonic--follow-last-pos nil)
        (add-hook 'post-command-hook #'tectonic--follow-schedule nil t))
    (remove-hook 'post-command-hook #'tectonic--follow-schedule t)
    (when (timerp tectonic--follow-timer)
      (cancel-timer tectonic--follow-timer)
      (setq tectonic--follow-timer nil))))

;; ============================================================
;; Auto-revert para todo buffer pdf-view (cuando tectonic recompila)
;; ============================================================
(add-hook! 'pdf-view-mode-hook
  #'auto-revert-mode
  #'tectonic--disable-conflicting-modes
  #'pdf-sync-minor-mode)

;; ============================================================
;; Bindings
;; ============================================================

(defun tectonic--apply-bindings ()
  (map! :map LaTeX-mode-map
        :localleader
        :desc "Tectonic compilar"     "c" #'tectonic-compile
        :desc "Tectonic stop"         "k" #'tectonic-stop
        :desc "Tectonic toggle PDF"   "v" #'tectonic-toggle-pdf
        :desc "SyncTeX forward"       "f" #'tectonic-forward-search
        :desc "SyncTeX follow toggle" "s" #'tectonic-follow-mode))

(after! latex
  (tectonic--apply-bindings))

(provide 'tectonic)
;;; tectonic.el ends here
