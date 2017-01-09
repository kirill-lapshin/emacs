(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

;;==============================================================================
;; Per Steve Yegge's advices as found at
;;  http://steve.yegge.googlepages.com/effective-emacs

;; Item 3: Prefer backward-kill-word over Backspace
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(global-set-key "\C-co" 'other-frame)

;; Item 7: Lose the UI
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; end of Steve Yegge's settings
;;==============================================================================

(global-set-key "\M-/" 'dabbrev-expand)


(defun back-to-indentation-or-beginning ()
   (interactive)
   (if (= (point) (save-excursion (back-to-indentation) (point)))
       (beginning-of-line)
     (back-to-indentation)))


(defun transpose-windows ()
  (interactive)
  (let ((this-buffer (window-buffer (selected-window)))
        (other-buffer (prog2
                          (other-window +1)
                          (window-buffer (selected-window))
                        (other-window -1))))
    (switch-to-buffer other-buffer)
    (switch-to-buffer-other-window this-buffer)
    (other-window -1)))


(setq ff-search-directories '("." "/usr/include" "/usr/local/include/*" ".." "../../include/*/" "../../../include/*/" "../../../include/*/*/" "../../src/*/" "../../../src/*/" "../../../src/*/*/" "../../xll/*" "../../../xll/*") )

(defun my-compile ()
  "Run compile and resize the compile window closing the old one if necessary"
  (interactive)
  (progn
    (if (get-buffer "*compilation*") ; If old compile window exists
  	(progn
  	  (delete-windows-on (get-buffer "*compilation*")) ; Delete the compilation windows
  	  (kill-buffer "*compilation*") ; and kill the buffers
  	  )
      )
    (call-interactively 'compile)
    (enlarge-window 10)
    ;(save-excursion (switch-to-buffer-other-window "*compilation*") (goto-char (point-max) ) )
    )
  )

(setq compilation-scroll-output 't)

(defun my-untabify ()
  "Untabify buffer"
  (interactive)
  (progn
    (untabify (point-min) (point-max))
    )
  )

(global-set-key [f7] 'my-compile)
(global-set-key [f8] 'next-error)
(global-set-key [S-f8] 'previous-error)
(global-set-key [f6] 'new-frame)
(global-set-key [S-f6] 'delete-frame)
(global-set-key [C-f6] 'transpose-windows)
(global-set-key [f5] 'gud-go)
(global-set-key [f9] 'gud-break)
(global-set-key [S-f9] 'gud-remove)
(global-set-key [f10] 'gud-next)
(global-set-key [f11] 'gud-step)
(global-set-key [S-f11] 'gud-finish)
(define-key global-map [S-f4] 'apply-macro-to-region-lines) ; f4 is already apply macro
(global-set-key "\C-cf" 'ff-find-other-file)
;(global-set-key "\C-a" 'back-to-indentation-or-beginning)
(global-set-key "\C-cu" 'my-untabify)
(global-set-key "\C-cw" 'whitespace-mode)
(global-set-key "\C-co" 'other-frame)
(global-set-key "\C-ca" 'list-matching-lines)

; unbind navigation to force myself to use C-b, C-f, etc
(global-unset-key (kbd "<left>"))
(global-unset-key (kbd "<right>"))
(global-unset-key (kbd "<up>"))
(global-unset-key (kbd "<down>"))
(global-unset-key (kbd "<prior>"))
(global-unset-key (kbd "<next>"))
(global-unset-key (kbd "<home>"))
(global-unset-key (kbd "<end>"))

(global-font-lock-mode t) ; turn on syntax coloring
(transient-mark-mode t) ; turn on selection highlighting
(show-paren-mode t) ; turn on paren match highlighting
(column-number-mode t)
(setq inhibit-startup-message t) ; to skip *GNU Emacs* buffer (one with banner)
(setq vc-svn-diff-switches "--diff-cmd=diff") ; force syste diff to be used, in case if colordiff is configured as svn diff

(set-face-font 'default "DejaVu Sans Mono-12")

(load "kir_cpp.el")


;;(load "haskell-mode/haskell-site-file")
;;
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)


(eval-after-load 'grep
      '(progn
         (grep-apply-setting
          'grep-find-ignored-directories
          (purecopy '(".svn" ".git")))
         (add-to-list 'grep-files-history "*")))

(eval-after-load 'grep
      '(progn
         (grep-apply-setting
          'grep-find-ignored-files
          (purecopy '("*~" "#*#")))
         (add-to-list 'grep-files-history "*")))

(eval-after-load 'grep
      '(progn
         (grep-apply-setting 'grep-find-use-xargs 'gnu)))


;(iswitchb-mode t) ; turn on more intelligent buffer switcher on (C-x b)

;(add-to-list 'load-path emacs-root )
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t) ;; enable fuzzy matching

(load-theme 'wombat t)

; make gud to highlight whole current line
(defvar gud-overlay
    (let* ((ov (make-overlay (point-min) (point-min))))
      (overlay-put ov 'face 'secondary-selection)
      ov)
    "Overlay variable for GUD highlighting.")

(defadvice gud-display-line (after my-gud-highlight act)
  "Highlight current line."
  (let* ((ov gud-overlay)
	 (bf (gud-find-file true-file)))
    (save-excursion
      (set-buffer bf)
      (move-overlay ov (line-beginning-position) (line-beginning-position 2)
		    ;;(move-overlay ov (line-beginning-position) (line-end-position)
		    (current-buffer)))))

(defun gud-kill-buffer ()
  (if (eq major-mode 'gud-mode)
      (delete-overlay gud-overlay)))

(add-hook 'kill-buffer-hook 'gud-kill-buffer)
(setq gdb-many-windows t)

; delete trailing whitespace on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; ; breadcrumb bookmarks
;; (require 'breadcrumb)
;; (global-set-key [(control f2)]          'bc-set)
;; (global-set-key [(f2)]                  'bc-previous)
;; (global-set-key [(shift f2)]            'bc-next)
;; (global-set-key [(meta f2)]             'bc-list)


;; (require 'idle-highlight-mode)
;; (defun my-coding-hook ()
;; ;  (if window-system (hl-line-mode t))
;;   (idle-highlight-mode t))

;; (add-hook 'emacs-lisp-mode-hook 'my-coding-hook)
;; (add-hook 'ruby-mode-hook 'my-coding-hook)
;; (add-hook 'js2-mode-hook 'my-coding-hook)
;; (add-hook 'c++-mode-hook 'my-coding-hook)
;; (add-hook 'python-mode-hook 'my-coding-hook)

;; (require 'jinja2-mode)
;; (autoload 'js2-mode "js2-20090723b" nil t)
;; (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
;; (add-to-list 'auto-mode-alist '("\\.json$" . js2-mode))

;; (defun beautify-json ()
;;   (interactive)
;;   (let ((b (if mark-active (min (point) (mark)) (point-min)))
;;         (e (if mark-active (max (point) (mark)) (point-max))))
;;     (shell-command-on-region b e
;;      "python -mjson.tool" (current-buffer) t)))

(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

;; (if (not windows-flag)
;; (when (load "flymake" t)
;;   (defun flymake-pyflakes-init ()
;;      ; Make sure it's not a remote buffer or flymake would not work
;;      (when
;; 	 (if (fboundp 'tramp-list-remote-buffers)
;; 	     (not (subsetp
;; 		   (list (current-buffer))
;; 		   (tramp-list-remote-buffers)))
;; 	   t)
;;       (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                          'flymake-create-temp-inplace))
;;              (local-file (file-relative-name
;;                           temp-file
;;                           (file-name-directory buffer-file-name))))
;;         (list "pyflakes" (list local-file)))))
;;   (add-to-list 'flymake-allowed-file-name-masks
;;                '("\\.py\\'" flymake-pyflakes-init)))
;; )
;(require 'flymake)

; Python Hook
(require 'python)
(add-hook 'python-mode-hook
          (function (lambda ()
                      (setq indent-tabs-mode nil
                            tab-width 4
                            python-indent 4)
		      (flymake-mode)
		      )))

;; (custom-set-variables
;;  '(help-at-pt-timer-delay 0.9)
;;  '(help-at-pt-display-when-idle '(flymake-overlay)))

;; (require 'rust-mode)
;; (require 'csharp-mode)

;; kill stupid default editing by visual line
;; it screws up macros
(setq line-move-visual nil)

;; (add-to-list 'load-path (concat emacs-root "ergoemacs-mode"))
;; (require 'dabbrev)
;; (package-initialize)
(require 'ergoemacs-mode)
;; ;(setq ergoemacs-theme nil) ;; Uses Standard Ergoemacs keyboard theme
;; (setq ergoemacs-keyboard-layout "us") ;; Assumes QWERTY keyboard layout
;; (ergoemacs-deftheme kir
;;    "My variant"
;;    nil ;; This is the variant your new variant is based on.  Nil for the standard variant.
;;    (ergoemacs-key (kbd "<f3>") 'kmacro-start-macro-or-insert-counter "Macro start")
;;    (ergoemacs-key (kbd "<f4>") 'kmacro-end-or-call-macro "Macro end")
;;    (ergoemacs-key "M-/"  'dabbrev-expand "dyn abbrev")
;;    (ergoemacs-key "M-h"  'back-to-indentation-or-beginning "<- line")
;;    (ergoemacs-key (kbd "<f11>") 'gud-step)
;;    )
;; (setq ergoemacs-theme "kir")
(ergoemacs-mode 1)
