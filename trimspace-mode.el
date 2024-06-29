;;; trimspace-mode.el --- A minor mode to trim trailing whitespace and newlines  -*- lexical-binding: t; -*-

;; Copyright 2021  Björn Lindström <bkhl@elektrubadur.se>

;; Author: Björn Lindström <bkhl@elektrubadur.se>
;; URL: https://git.sr.ht/~bkhl/trimspace-mode
;; Version: 1.1
;; Package-Requires: ((emacs "24.3"))
;; Keywords: files, convenience

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free Software
;; Foundation, either version 3 of the License, or (at your option) any later
;; version.

;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;; FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
;; details.

;; You should have received a copy of the GNU General Public License along with
;; this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a very minimal minor mode that adds a hook to
;; run `delete-trailing-whitespace' before saving a file.
;;
;; It also has the function `trimspace-mode-maybe', which
;; activates the mode only if the buffer does not already have traling
;; whitespace or newlines.
;;
;; In addition, `require-final-newline' is enabled, since it's assumed that if
;; you want the editor to maintain trailing whitespace, you are most likely to
;; also want to maintain a trailing final newline in all files.

;; This package provides a minimalistic minor mode that enables Emacs' built-in
;; functions to trim/fix:
;;
;; - whitespace trailing off ends of lines.
;; - multiple newlines at the end of a file.
;; - empty lines at the end of a file.
;; - missing newline at end of file.
;;
;; It contains the function `trimspace-mode-maybe', which activates the mode
;; conditionally, only if it can not find pre-existing issues of any of these
;; types.
;;
;; The package has functions to detect if the file has any of these issues
;; previously, but only uses built-in Emacs functionality to perform the
;; clean-up, by specifically:
;;
;; - setting the variables `require-final-newline' and `delete-trailing-lines' locally.
;; - adding the function `delete-trailing-whitespace' to `before-save-hook'.
;;
;; This package is intentionally minimalistic and only concerned with whitespace
;; trailing off lines and files, not other whitespace issues like multiple
;; spaces, erronous mixing of tabs and spaces, &c. For that you may be
;; interested in the package ~whitespace-mode~, included in Emacs.
;;
;; To enable this mode for any new files opened, but only if they are already
;; clean of trailing whitespace and newlines, you can use this:
;;
;; (add-hook 'prog-mode-hook 'trimspace-mode-maybe)
;; (add-hook 'text-mode-hook 'trimspace-mode-maybe)
;;
;; Or something like this with `use-package':
;;
;; (use-package trimspace-mode
;;   :hook
;;   (prog-mode . trimspace-mode-maybe)
;;   (text-mode . trimspace-mode-maybe))
;;
;; If you open a file with trailing whitespace and want to clean them out, you
;; can enable the mode anyway with =M-x trimspace-mode=, which will then make
;; Emacs perform clean-up the next time you save the file.

;;; Code:

(defun trimspace--trailing-whitespacep ()
  "Return t if the current buffer has any line with trailing whitespace.
Otherwise, return nil."
  (goto-char (point-min))
  (when (re-search-forward (rx blank eol) nil t) t))

(defun trimspace--trailing-newlinesp ()
    "Return t if current buffer has multiple newlines at the end of the file.
Otherwise, return nil."
    (goto-char (point-max))
    (when (re-search-backward (rx (= 2 (* blank) "\n") eot) nil t) t))

(defun trimspace--missing-final-newlinep ()
    "Return t if current buffer is missing a final newline.
Otherwise, return nil."
    (goto-char (point-max))
    (when (re-search-backward (rx not-newline eot) nil t) t))

;;;###autoload
(defun trimspace-mode-maybe ()
  "Start trimming trailing whitespace on save unless there is already some.

This is useful as a hook, to automatically trim whitespace on save, but skipping
files that have extraneous whitespace already when opening them."
  (interactive)
  (unless (save-restriction
            (widen)
            (save-excursion
              (or (and (trimspace--trailing-whitespacep)
                       (message "Buffer has trailing whitespace"))
                  (and (trimspace--trailing-newlinesp)
                       (message "Buffer has trailing newlines"))
                  (and (trimspace--missing-final-newlinep)
                       (message "Buffer lacks final newline")))))
    (trimspace-mode 1)))

;;;###autoload
(define-minor-mode trimspace-mode
  "Trim trailing whitespace automatically.

When this minor mode is active, on saving a file, trim trailing whitespace
at the end of lines, and newlines at the end of the file."
  :init-value nil
  :lighter " Tr"
  :keymap nil

  (if trimspace-mode
      (progn
        (add-hook 'before-save-hook #'delete-trailing-whitespace 0 t)
        (unless require-final-newline
          (setq-local require-final-newline t))
        (unless delete-trailing-lines
          (setq-local delete-trailing-lines t)))
    (remove-hook 'before-save-hook #'delete-trailing-whitespace t)
    (kill-local-variable require-final-newline)
    (kill-local-variable delete-trailing-lines)))

(provide 'trimspace-mode)

;;; trimspace-mode.el ends here
