;;; init.el --- Main entry point -*- lexical-binding: t; -*-
(setq inhibit-startup-screen t
      ring-bell-function 'ignore
      create-lockfiles nil)

;; Backups and autosaves: ON, but confined to one directory
(let ((backup-dir (expand-file-name "backups" user-emacs-directory))
      (autosave-dir (expand-file-name "auto-saves/" user-emacs-directory)))
  (dolist (dir (list backup-dir autosave-dir))
    (unless (file-exists-p dir) (make-directory dir t)))
  (setq backup-directory-alist `(("." . ,backup-dir))
	auto-save-file-name-transforms `((".*" ,autosave-dir t))
	auto-save-default t
	make-backup-files t
	backup-by-copying t     ; don't clobber originals via symlink tricks
	version-control t       ; numbered backups
	delete-old-versions t   
	kept-new-versions 5
	kept-old-versions 2))

;; keybaord exist
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; line numbers
(global-display-line-numbers-mode 1)
(column-number-mode 1)

;; Avpiding the is this theme safe message
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Load configuration files
(add-to-list 'load-path
             (expand-file-name "lisp" user-emacs-directory))

(require 'novu-packages)
(require 'novu-commands)
