;; -*- lexical-binding: t -*-

;;; init.el --- my Emacs init file

;;; Commentary:

;; My Emacs init file.

;;; Code:

;; Prevent any special-filename parsing of files loaded from the init file
(setq file-name-handler-alist nil)

;; Minimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum
      read-process-output-max (* 1024 1024))

;; Lower threshold back to 8 MiB (default is 800kB)
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq gc-cons-threshold (expt 2 23))))

;; Native elisp file compile
(require 'package)
(setq package-native-compile t)

;; Scrolling by pixel lines
(pixel-scroll-precision-mode t)

;; Disable the menubar
(menu-bar-mode -1)

;; Disable the toolbar
(tool-bar-mode -1)

;; Disable scrollbar
(scroll-bar-mode -1)

;; Alias for yes(y) and no(n)
(defalias 'yes-or-no-p 'y-or-n-p)

;; Line numbers
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

;; Time 24hr format
(require 'time)
;;  Show current time in the modeline
(display-time-mode 1)
(setq display-time-format nil
      display-time-24hr-format 1)

;; Highlight the current line
(global-hl-line-mode 1)

;; Replace the standard text representation of various identifiers/symbols
(global-prettify-symbols-mode 1)

;; Default UTF8
(set-default-coding-systems 'utf-8)

;; spell-check
(setq-default ispell-program-name "aspell")

;; Disable bell sound
(setq ring-bell-function 'ignore)

;; Matching pairs of parentheses
(show-paren-mode 1)

;; Whether confirmation is requested before visiting a new file or buffer
(setq confirm-nonexistent-file-or-buffer nil)

;; Make window title the buffer name
(setq-default frame-title-format '("%b"))

;; Debug
(require 'gdb-mi)
(setq gdb-many-windows 1)
(setq gdb-show-main 1)

;; Line-style cursor similar to other text editors
(setq-default cursor-type 'box)

;; Line and column display
(setq column-number-mode t)
(setq line-number-mode t)

;; Structure Templates org mode
(require 'org-tempo)

;; Save Cursor Position
(save-place-mode 1)

;; Save minibuffer history
(savehist-mode 1)

;; Encrypting and Decrypting gpg Files
(require 'epa-file)
(epa-file-enable)

;; Keep a list of recently opened files
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)

;; Icomplete
(require 'icomplete)
(icomplete-mode 1)
(setq icomplete-separator "\n")
(setq icomplete-hide-common-prefix nil)
(setq icomplete-in-buffer t)
(define-key icomplete-minibuffer-map (kbd "<right>") 'icomplete-forward-completions)
(define-key icomplete-minibuffer-map (kbd "<left>") 'icomplete-backward-completions)
(fido-vertical-mode 1)

;; ANSI Coloring in Compilation Mode
;; (require 'ansi-color)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

;; Delete old version backup
(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;; Set directory for backup and autosave
(setq backup-directory-alist '(("." . "~/.config/emacs/backups")))
(setq auto-save-file-name-transforms '((".*" "~/.config/emacs/auto-save-list/" t)))

;; Lockfiles unfortunately cause more pain than benefit
(setq create-lockfiles nil)

;; Undo
(setq undo-no-redo t)

;; Kill all buffers
(defun nullzeiger-kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))

;; Tangle my init org file
(defun nullzeiger-tangle-dotfiles ()
  "Tangle my org file for generate init.el."
  (interactive)
  (org-babel-tangle)
  (message "Dotfile tangled"))

;; Formatting C style using indent
(defun nullzeiger-indent-format ()
  "Formatting c file using indent."
  (interactive)
  (shell-command-to-string
   (concat
    "indent --no-tabs " (buffer-file-name)))
  (revert-buffer :ignore-auto :noconfirm))

;; Create TAGS file for c
(defun nullzeiger-create-tags (dir-name)
  "Create tags file in DIR-NAME."
  (interactive "DDirectory: ")
  (eshell-command
   (format "find %s -type f -name \"*.[ch]\" | etags -" dir-name)))

;; Auto imports before-save-hook
(require 'eglot)
(defun nullzeiger-eglot-imports ()
  "Auto import."
  (interactive)
  (eglot-code-actions nil nil "source.organizeImports" t))

;; No default startup buffer
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)

;; dabbrev mode key
(global-set-key (kbd "C-<tab>") 'dabbrev-expand)
(define-key minibuffer-local-map (kbd "C-<tab>") 'dabbrev-expand)

;; Flymake
(require 'flymake)
(remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake)
;; Activate flymake in c-mode
(add-hook 'c-mode-hook 'flymake-mode)
;; Activate flymake in emacs-lisp-mode
(add-hook 'emacs-lisp-mode-hook 'flymake-mode)
;; Activate flymake in python-mode
(add-hook 'python-mode-hook 'flymake-mode)
;; Display messages when idle, without prompting
(setq help-at-pt-display-when-idle t)
;; Message navigation bindings
(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "C-c n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "C-c p") #'flymake-goto-prev-error))

;; Electric-pair
(add-hook 'emacs-lisp-mode-hook 'electric-pair-mode)

;; Set calendar
(require 'solar)
(setq calendar-latitude 49.5137)
(setq calendar-longitude 8.4176)
(setq calendar-location-name "Ludwigshafen")

;; My birthday
(setq holiday-other-holidays '((holiday-fixed 5 8 "Compleanno Amore")))
(setq holiday-other-holidays '((holiday-fixed 5 22 "Compleanno")))

;; Don't prompt me to load tags
(require 'etags)
(setq tags-revert-without-query 1)

;; Font
(set-frame-font "Iosevka Extended 13" nil t)

;; Set guile default scheme
(require 'scheme)
(setq scheme-program-name "guile")

;; Reuse buffer
(require 'dired)
(setf dired-kill-when-opening-new-dired-buffer t)

;; Theme
(load-theme 'modus-operandi)

;; C template
(require 'tempo)
(setq tempo-interactive t)

(defvar c-tempo-tags nil)
(defvar c-tempo-keys-alist nil)

(defun nullzeiger-tempo-c ()
  "Tempo c snippets."
  (local-set-key (read-kbd-macro "C-<return>") 'tempo-complete-tag)
  (tempo-use-tag-list 'c-tempo-tags))

(add-hook 'c-mode-hook 'nullzeiger-tempo-c)

(tempo-define-template "c-main"
		       '("#include <stdio.h>" n n
			 "int" n
			 "main ()" n
			 "{" n>
			 "puts (\"Hello, World!\");" r n>
			 "return 0;" n
			 "}"
			 )
		       "main"
		       "Insert base main"
		       'c-tempo-tags)

(tempo-define-template "c-include"
		       '("#include <" r ".h>" > n
			 )
		       "include"
		       "Insert a #include <> statement"
		       'c-tempo-tags)

(tempo-define-template "c-ifdef"
		       '("#ifdef " (p "ifdef-clause: " clause) > n> p n
			 "#else /* !(" (s clause) ") */" n> p n
			 "#endif /* " (s clause)" */" n>
			 )
		       "ifdef"
		       "Insert a #ifdef #else #endif statement"
		       'c-tempo-tags)

(tempo-define-template "c-ifndef"
		       '("#ifndef " (p "ifndef-clause: " clause) > n
			 "#define " (s clause) n> p n
			 "#endif /* " (s clause)" */" n>
			 )
		       "ifndef"
		       "Insert a #ifndef #define #endif statement"
		       'c-tempo-tags)

(tempo-define-template "c-if"
		       '(> "if (" (p "if-clause: " clause) ")"  n>
			   "{" > n> r n>
			   "}" > n>
			   )
		       "if"
		       "Insert a C if statement"
		       'c-tempo-tags)

(tempo-define-template "c-else"
		       '(n> "else" n>
			    "{" > n> r n>
			    "}" > n>
			    )
		       "else"
		       "Insert a C else statement"
		       'c-tempo-tags)

;; Hippie
(require 'hippie-exp)
(global-set-key (kbd "M-ò") 'hippie-expand)
(setq hippie-expand-verbose t)
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
	try-expand-line
	try-expand-list
	try-complete-lisp-symbol-partially
	try-complete-file-name-partially
	try-complete-file-name
	try-expand-all-abbrevs
	try-expand-dabbrev-from-kill))

;; gnus
(require 'gnus)
(require 'gnus-start)
(require 'gnus-group)
(require 'gnus-cache)
(require 'nnfolder)
(require 'smtpmail)
(require 'message)
(require 'nnmail)
(setq user-mail-address "ivan.guerreschi.dev@gmail.com"
      user-full-name "Ivan Guerreschi"
      user-login-name "ivan.guerreschi.dev")

(setq gnus-select-method
      '(nnimap "gmail"
	       (nnimap-address "imap.gmail.com")
	       (nnimap-server-port "imaps")
	       (nnimap-stream ssl
			      (nnmail-expiry-target "nnimap+gmail:[Gmail]/Trash")
			      (nnmail-expiry-wait immediate))))

(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587
      smtpmail-local-domain "minerva"
      gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

(add-to-list 'gnus-secondary-select-methods '(nntp "news.gwene.org"))

(setq gnus-expert-user t)
(setq gnus-interactive-exit nil)
(setq gnus-novice-user nil)
(setq gnus-message-archive-group "\"[Gmail]/Sent Mail\"")

(setq message-directory "~/.config/emacs/mail/")
(setq gnus-directory "~/.config/emacs/news/")
(setq nnfolder-directory "~/.config/emacs/mail/archive")
(setq gnus-use-dribble-file nil)

;; Variables
(setq
 gnus-summary-ignore-duplicates t
 nnmail-expiry-wait 30
 gnus-use-adaptive-scoring t
 gnus-summary-line-format "%U%R%z %(%&user-date;  %-15,15f  %B (%c) %s%)\n"
 gnus-user-date-format-alist '((t . "%Y-%m-%d %H:%M"))
 gnus-group-line-format "%M%S%p%P%5y:%B %G\n";;"%B%(%g%)"
 gnus-thread-sort-functions '(gnus-thread-sort-by-most-recent-date))

;;; init.el ends here
