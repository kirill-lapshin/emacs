(defconst kir-c-style
  '(
    (c-basic-offset . 4)
    (c-comment-only-line-offset . 0)
    (c-offsets-alist . ((statement-block-intro . +)
                        (substatement-open . 0)
                        (label . 0)
                        (statement-cont . +)
                        (inline-open . 0)
                        ))
    )
  "My C++ Programming Style")

;; Customizations for all of c-mode, c++-mode, and objc-mode
(defun kir-c-mode-common-hook ()
  (c-add-style "My" kir-c-style t)
  ;; other customizations
  (setq tab-width 4
        ;; this will make sure spaces are used instead of tabs
        indent-tabs-mode nil)
  ;; we like auto-newline and hungry-delete
  ;(c-toggle-auto-hungry-state 1)
  ;; keybindings for C, C++, and Objective-C.  We can put these in
  ;; c-mode-map because c++-mode-map and objc-mode-map inherit it
  (define-key c-mode-map "\C-m" 'newline-and-indent)
  )

(add-hook 'c-mode-common-hook 'kir-c-mode-common-hook)
