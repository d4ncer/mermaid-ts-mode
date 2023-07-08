;;; mermaid-ts-mode.el --- Treesit-powered major mode for working with Mermaid files  -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Raghuvir Kasturi

;; Author           : Raghuvir Kasturi
;; Version          : 0.1
;; URL              : https://github.com/d4ncer/mermaid-ts-mode
;; Package-Requires : ((emacs "29"))
;; Created          : July 2023
;; Keywords         : mermaid languages tree-sitter

;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.

;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.

;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'treesit)

(declare-function treesit-parser-create "treesit.c")
(declare-function treesit-node-child "treesit.c")
(declare-function treesit-node-type "treesit.c")
(declare-function treesit-node-child-by-field-name "treesit.c")
(declare-function treesit-parser-language "treesit.c")
(declare-function treesit-parser-included-ranges "treesit.c")
(declare-function treesit-parser-list "treesit.c")
(declare-function treesit-node-parent "treesit.c")
(declare-function treesit-node-start "treesit.c")
(declare-function treesit-node-end "treesit.c")
(declare-function treesit-query-compile "treesit.c")
(declare-function treesit-query-capture "treesit.c")
(declare-function treesit-node-eq "treesit.c")
(declare-function treesit-node-prev-sibling "treesit.c")
(declare-function treesit-install-language-grammar "treesit.el")

(defgroup mermaid-ts nil
  "Major mode powered by treesit for editing Mermaid code."
  :prefix "mermaid-ts/"
  :group 'extensions)

(defcustom mermaid-ts/indent-offset 4
  "Indentation of Mermaid defs."
  :type 'integer
  :safe 'integerp
  :group 'mermaid-ts)

(defcustom mermaid-ts/mmdc-location "mmdc"
  "Mmdc location."
  :type 'string
  :group 'mermaid-ts)

(defcustom mermaid-ts/output-format ".png"
  "Mmdc output format."
  :group 'mermaid-ts
  :type 'string)

(defcustom mermaid-ts/tmp-dir "/tmp/"
  "Dir for tmp files."
  :group 'mermaid-ts
  :type 'string)

(defcustom mermaid-ts/flags ""
  "Additional flags to pass to the mermaid-cli."
  :group 'mermaid-ts
  :type 'string)

;; Copied from `mermaid-ts-mode'.
(defvar mermaid-ts/syntax-table
  (let ((syntax-table (make-syntax-table)))
    ;; Comment style "%% ..."
    (modify-syntax-entry ?% ". 124" syntax-table)
    (modify-syntax-entry ?\n ">" syntax-table)
    syntax-table)
  "Syntax table for `mermaid-ts-mode'.")

(defvar mermaid-ts/indent-rules
  (let ((offset mermaid-ts/indent-offset))
    `((mermaid
       ((parent-is "^diagram_*") parent ,offset)))))

(defun mermaid-ts/forward-sexp (&optional arg)
  "Move forward across one balanced expression.
With ARG, do it many times.  Negative ARG means move backward."
  (let* ((a (or arg 1))
         (fn (if (> a 0) #'treesit-end-of-thing #'treesit-beginning-of-thing))
         (abs-a (abs a)))
    (funcall fn abs-a)))

;;;###autoload
(define-derived-mode mermaid-ts-mode prog-mode "Mermaid"
  "Major mode for editing Mermaid files (*.mmd), powered by treesit."
  :group 'mermaid-ts
  :syntax-table mermaid-ts/syntax-table

  (setq-local comment-start "%%")
  (setq-local comment-end "")
  (setq-local comment-start-skip "%%+ *")

  (when (treesit-ready-p 'mermaid)
    (treesit-parser-create 'mermaid)

    ;; TODO: Font-lock.
    ;; Examples from `elixir-ts-mode' & `python-ts-mode'.
    ;; (setq-local treesit-font-lock-settings elixir-ts--font-lock-settings)
    ;; (setq-local treesit-font-lock-feature-list
    ;;             '(( elixir-comment elixir-constant elixir-doc )
    ;;               ( elixir-string elixir-keyword elixir-unary-operator
    ;;                 elixir-call elixir-operator )
    ;;               ( elixir-sigil elixir-string-escape elixir-string-interpolation)))
    ;; (setq-local treesit-font-lock-feature-list
    ;;             '(( comment definition)
    ;;               ( keyword string type)
    ;;               ( assignment builtin constant decorator
    ;;                 escape-sequence number property string-interpolation )
    ;;               ( bracket delimiter function operator variable)))
    ;; (setq-local treesit-font-lock-settings python--treesit-settings)

    ;; TODO: Imenu.
    ;; Examples from `elixir-ts-mode' & `python-ts-mode'.
    ;; (setq-local treesit-simple-imenu-settings
    ;;             '((nil "\\`call\\'" elixir-ts--defun-p nil)))
    ;; (setq-local imenu-create-index-function
    ;;             #'python-imenu-treesit-create-index)

    ;; TODO: Indent.
    (setq-local treesit-simple-indent-rules mermaid-ts/indent-rules)

    ;; TODO: Navigation.
    ;; Example from `elixir-ts-mode'.
    ;; (setq-local forward-sexp-function #'mermaid-ts/forward-sexp)
    ;; (setq-local treesit-defun-type-regexp
    ;;             '("call" . elixir-ts--defun-p))

    (treesit-major-mode-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.mmd\\'" . mermaid-ts-mode))

(provide 'mermaid-ts-mode)

;;; mermaid-ts-mode.el ends here
