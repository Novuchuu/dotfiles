
;;; ---------------------------------------------------------------
;;; Fast access to the reference org docs
;;; ---------------------------------------------------------------
;; Defaults to ~/org/reference/
(defvar my/org-reference-dir "~/org/reference/"
  "Directory containing reference org docs for fast lookup.")

(defun my/find-reference-doc ()
  "Fuzzy-find and open a reference org doc, most-recently-modified first."
  (interactive)
  (require 'consult)  ; consult is :bind-deferred elsewhere; consult--read needs it loaded first
  (let* ((dir (expand-file-name my/org-reference-dir)))
    (unless (file-directory-p dir)
      (user-error "my/org-reference-dir (%s) doesn't exist — create it or update the variable" dir))
    (let* ((files (directory-files-recursively dir "\\.org$"))
           (sorted (sort files
                         (lambda (a b)
                           (time-less-p (nth 5 (file-attributes b))
                                        (nth 5 (file-attributes a))))))
           (choice (consult--read
                    (mapcar (lambda (f) (file-relative-name f dir)) sorted)
                    :prompt "Reference doc: "
                    :sort nil)))  ; keep our recency ordering, don't let consult re-sort
      (find-file (expand-file-name choice dir)))))

(global-set-key (kbd "C-c r") #'my/find-reference-doc)

(provide 'novu-commands)
