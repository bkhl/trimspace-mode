;;; trimspace-mode-tests.el --- Test suite for trimspace-mode -*- lexical-binding: t -*-

;; Copyright 2024  Björn Lindström <bkhl@elektrubadur.se>

;; This file is not part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Code:

(require 'trimspace-mode)

(defun trimspace-mode-test--test (input expected)
  (let ((filename (make-temp-file "trimspace-mode-test-")))
    (with-temp-buffer
      (set-visited-file-name filename)
      (insert input)
      (trimspace-mode)
      (save-buffer)
      (should (string= expected (buffer-string)))
      (delete-file filename))))

(ert-deftest trimspace-mode-test--trailing-spaces ()
  (trimspace-mode-test--test "foo\nbar  \nbaz\n" "foo\nbar\nbaz\n"))

(ert-deftest trimspace-mode-test--trailing-tabs ()
  (trimspace-mode-test--test "foo\nbar\t\t\nbaz\n" "foo\nbar\nbaz\n"))

(ert-deftest trimspace-mode-test--single-empty-line ()
  (trimspace-mode-test--test "   \n" "\n"))

(ert-deftest trimspace-mode-test--single-newline ()
  (trimspace-mode-test--test "\n" "\n"))

(ert-deftest trimspace-mode-test--only-newlines ()
  (trimspace-mode-test--test "\n\n\n" "\n"))

;;; trimspace-mode-tests.el ends here
