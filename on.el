;;; on.el --- Hooks for faster startup -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022-2025 Alex Griffin
;;
;; Author: Alex Griffin <alex.griffin@axgfn.com>
;; Maintainer: Alex Griffin <alex.griffin@axgfn.com>
;; Version: 0.2.0
;; Keywords: convenience
;; Homepage: https://gitlab.com/ajgrf/on.el
;; Package-Requires: ((emacs "27.1"))
;;
;; This file is not part of GNU Emacs.
;;
;; The MIT License (MIT)
;;
;; Copyright (c) 2014-2022 Henrik Lissner.
;; Copyright (c) 2022-2025 Alex Griffin
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;;
;;; Commentary:
;;
;;  This package exposes a number of utility hooks and functions ported
;;  from Doom Emacs. The hooks make it easier to speed up Emacs startup
;;  by providing finer-grained control of the timing at which packages
;;  are loaded.
;;
;;; Code:

(defvar on-first-input-hook nil
  "Transient hooks run before the first user input.")

(defvar on-first-file-hook nil
  "Transient hooks run before the first interactively opened file.")

(defvar on-first-buffer-hook nil
  "Transient hooks run before the first interactively opened buffer.")

(defvar on-init-ui-hook nil
  "List of hooks to run when the UI has been initialized.")

(defun on-run-first-input-hooks-h (&rest _)
  "Run `on-first-input-hook' hooks."
  (run-hooks 'on-first-input-hook)
  (remove-hook 'pre-command-hook #'on-run-first-input-hooks-h))

(defun on-run-first-file-hooks-h (&rest _)
  "Run `on-first-file-hook' hooks."
  (run-hooks 'on-first-file-hook)
  (advice-remove 'after-find-file #'on-run-first-file-hooks-h)
  (remove-hook 'dired-initial-position-hook #'on-run-first-file-hooks-h))

(defun on-run-first-buffer-hooks-h (&rest _)
  "Run `on-first-buffer-hook' hooks."
  (run-hooks 'on-first-buffer-hook)
  (advice-remove 'after-find-file #'on-run-first-buffer-hooks-h)
  (remove-hook 'window-buffer-change-functions #'on-run-first-buffer-hooks-h)
  (remove-hook 'server-visit-hook #'on-run-first-buffer-hooks-h))

(defun on-run-init-ui-hooks-h (&rest _)
  "Run `on-init-ui-hook' hooks."
  (run-hooks 'on-init-ui-hook)
  (remove-hook 'server-after-make-frame-hook #'on-run-init-ui-hooks-h)
  (remove-hook 'after-init-hook #'on-run-init-ui-hooks-h))
(let ((hook (if (daemonp)
                'server-after-make-frame-hook
              'after-init-hook)))
  (add-hook hook #'on-run-init-ui-hooks-h))

(defun on-setup-hooks-h ()
  "Set up hooks to run `on-first-input-hook' and `on-first-buffer-hook'."
  ;; Set up `on-first-input-hook' triggers.
  (add-hook 'pre-command-hook #'on-run-first-input-hooks-h)

  ;; Set up `on-first-file-hook' triggers.
  (advice-add 'after-find-file :before #'on-run-first-file-hooks-h)
  (add-hook 'dired-initial-position-hook #'on-run-first-file-hooks-h)

  ;; Set up `on-first-buffer-hook' triggers.
  (advice-add 'after-find-file :before #'on-run-first-buffer-hooks-h)
  (add-hook 'window-buffer-change-functions #'on-run-first-buffer-hooks-h)
  ;; `window-buffer-change-functions' doesn't trigger for files visited via the server.
  (add-hook 'server-visit-hook #'on-run-first-buffer-hooks-h))
;; Set up hooks after the rest of the config has loaded.
(add-hook 'window-setup-hook #'on-setup-hooks-h -100)

(provide 'on)
;;; on.el ends here
