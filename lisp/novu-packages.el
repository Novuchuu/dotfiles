;;; novu-packages.el --- Package bootstrap + all use-package config -*- lexical-binding: t; -*-

;; external pkgs
;;   vterm     cmake, a C compiler, libvterm
;;   eglot     a Python language server (pylsp or pyright), nixd
;;   cider     jdk, clojure, leiningen, rlwrap

;;; ---------------------------------------------------------------
;;; Bootstrap
;;; ---------------------------------------------------------------
(require 'package)

(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu" . 3) ("nongnu" . 2) ("melpa" . 1)))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(setq package-install-upgrade-built-in t)

(require 'use-package)
(setq use-package-always-ensure t)

;;; ---------------------------------------------------------------
;;; Completion
;;; ---------------------------------------------------------------
;; Remember minibuffer history between sessions
(use-package savehist
  :ensure nil
  :init (savehist-mode))

;; vertical lsit for mini buffer
(use-package vertico
  :init (vertico-mode))

;; match words in any order
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Show docs and keybinds beside canidates
(use-package marginalia
  :init (marginalia-mode))

;; fuzzy search buffers, lines, files, grep
(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("M-y"   . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("C-s"   . consult-line)))
;; auto-complete popup
(use-package corfu
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-cycle t))

;; Extra completion like file paths
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file))

;; icons for completion type
(use-package kind-icon
  :after corfu
  :custom (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; better help buffers
(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)))

;; shows avalible key after a prefix
(use-package which-key
  :init (which-key-mode)
  :custom (which-key-idle-delay 0.4))

;;; ---------------------------------------------------------------
;;; Org + babel
;;; ---------------------------------------------------------------
(use-package org
  :ensure nil
  :preface
  ;; Only files under ~/org/ skip the prompt
  (defun my/org-confirm-babel-evaluate (_lang _body)
    (not (and buffer-file-name
              (file-in-directory-p buffer-file-name
                                   (expand-file-name "~/org/")))))
  :custom
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-confirm-babel-evaluate #'my/org-confirm-babel-evaluate)
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t) (python . t) (emacs-lisp . t))))

;; run babel blocks without freezing emacs
(use-package ob-async
  :after org)

;; Render ANSI colors in shell block output
(use-package xterm-color
  :after org
  :preface
  (defun my/org-babel-filter-ansi-color ()
    "Render ANSI escapes in the most recent shell babel result block."
    (when (and (eq major-mode 'org-mode)
               (equal (nth 0 (org-babel-get-src-block-info t)) "sh")
               (org-babel-where-is-src-block-result))
      (save-excursion
        (goto-char (org-babel-where-is-src-block-result))
        (xterm-color-colorize-buffer))))
  :hook (org-babel-after-execute . my/org-babel-filter-ansi-color))

;; Header-arg completion
(use-package corg
  :vc (:url "https://github.com/isamert/corg.el" :rev :newest)
  :hook (org-mode . corg-setup))

;; Spaced repetition. 
(use-package org-drill
  :commands (org-drill org-drill-resume org-drill-tree))

;;; ---------------------------------------------------------------
;;; Dev tools
;;; ---------------------------------------------------------------
(use-package nix-mode)

(use-package python
  :ensure nil
  :custom
  (python-shell-interpreter "python3")
  (python-shell-completion-native-enable nil)) ; avoids readline hangs

(use-package clojure-mode)

(use-package cider
  :hook ((clojure-mode . cider-mode)
         (clojurescript-mode . cider-mode)
         (clojurec-mode . cider-mode))
  :custom
  (cider-repl-pop-to-buffer-on-connect 'display-only)
  (cider-show-error-buffer 'only-in-repl)
  (cider-repl-use-pretty-printing t))

;; built-in language server client
(use-package eglot
  :ensure nil
  :hook ((python-mode    . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (nix-mode       . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '(nix-mode . ("nixd")))
  (setq-default eglot-workspace-configuration
                '(:nixd (:formatting (:command ["nixfmt" "-"]))))
  :bind (:map eglot-mode-map
              ("C-c l a" . eglot-code-actions)
              ("C-c l r" . eglot-rename)
              ("C-c l f" . eglot-format)
              ("C-c l d" . eldoc)))

;; inline error and warning markers
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :bind (:map flymake-mode-map
              ("C-c ! n" . flymake-goto-next-error)
              ("C-c ! p" . flymake-goto-prev-error)
              ("C-c ! l" . flymake-show-buffer-diagnostics)))


;; compile and run current buffer
(use-package quickrun
  :bind (("C-c q q" . quickrun)
         ("C-c q r" . quickrun-region)
         ("C-c q c" . quickrun-compile-only)))

;; Godly git interface
(use-package magit
  :bind ("C-x g" . magit-status))

;; jump to defintions without a server
(use-package dumb-jump
  :init (add-hook 'xref-backend-functions #'dumb-jump-xref-activate 100))

(use-package vterm
  :bind ("C-c v" . vterm))

(use-package paredit
  :hook ((clojure-mode . paredit-mode)
         (clojurescript-mode . paredit-mode)
         (clojurec-mode . paredit-mode)
         (cider-repl-mode . paredit-mode)
         (emacs-lisp-mode . paredit-mode)
         ))

;;; ---------------------------------------------------------------
;;;  TRAMP + perspectives
;;; ---------------------------------------------------------------
(use-package tramp
  :ensure nil
  :custom
  (tramp-default-method "ssh")
  (password-cache-expiry 10800)
  :config
  ;; Keep backups of remote files on THIS machine, not on the target.
  (setq tramp-backup-directory-alist backup-directory-alist))

;; Each perspective has its own buffer list and window layout, so remote
;; and local work don't mix.  C-c w TAB toggles back to the last one.
(use-package perspective
  :custom (persp-mode-prefix-key (kbd "C-c w"))
  :init (persp-mode)
  :bind ("C-c w TAB" . persp-switch-last))

(provide 'novu-packages)
