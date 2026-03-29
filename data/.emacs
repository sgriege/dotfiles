;; Load additional Lisp code
(add-to-list 'load-path "~/.emacs-lisp.d")
(load "terminal-title-mode")

;; Load customizations
(setq custom-file "~/.emacs-custom.el")
(load custom-file)

;; Mode preferences
(defalias 'perl-mode 'cperl-mode)

;; Indentation and filling
(setq-default tab-width 8)
(setq-default indent-tabs-mode nil)
(setq-default fill-column 100)

;; Per-mode settings: c-mode
(setq-default c-basic-offset 2)

;; Per-mode settings: cperl-mode
(setq-default cperl-indent-level 2)
(setq-default cperl-electric-parens t)

;; Enable company-mode, if available
(when (fboundp 'company-mode)
  (company-mode)
  (add-hook 'after-init-hook 'global-company-mode))

;; Indentation: Interactive function indent-using-single-tab
(defun indent-using-single-tab ()
  "Enable indentation using a single tab character in the current buffer."
  (interactive)
  (setq tab-width 2)
  (setq indent-tabs-mode t))

;; Disable backups
(setq make-backup-files nil)

;; Scrolling
(setq scroll-step 0)
(setq scroll-conservatively 1)

;; Appearance
(setq inhibit-startup-screen nil)
(unless (display-graphic-p)
  (menu-bar-mode -1))
(setq frame-title-format "Emacs: %b")
(setq icon-title-format "%b")
(when (display-graphic-p)
  (setq default-frame-alist '((user-size     .   t)
                              (width         . 160)
                              (height        .  50)
                              (user-position .   t)
                              (left          . 0.5)
                              (top           . 0.5))))
(terminal-title-mode)
(show-paren-mode)
(line-number-mode)
(column-number-mode)
