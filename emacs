;; ----------------------------------------------------------------------------
;; package related stuff
; dont initialize again packages after .emacs after processing init file
; (setq package-enable-at-startup nil) ; comment this line out if problematic
(setq package-archives '(("melpa" . "http://melpa.milkbox.net/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))
(require 'package)
(package-initialize)
;; ----------------------------------------------------------------------------
(blink-cursor-mode -1) ; stop blinking
(column-number-mode 1) ; show column no in status line
(scroll-bar-mode -1) ; no scroll bar
(menu-bar-mode -1) ; no menu bar
(tool-bar-mode -1) ; no tool bar
(setq inhibit-splash-screen t) ; no splash screen
(setq inhibit-startup-message t) ; no splash screen
(defun display-startup-echo-area-message () )
(setq initial-scratch-message " ") ; would set to "" but line numbers would not show
(global-linum-mode 1) ; show line number in every buffer
(defalias 'yes-or-no-p 'y-or-n-p) ; dont write "yes" but "y" in prompts
; (setq linum-format "%d")

;; ------- WORKAROUND1 --------------------------------------------------------
; http://lists.gnu.org/archive/html/help-gnu-emacs/2012-01/msg00199.html
; some plugins mess up (require 'abc) as a result various "ad handle definition"
; pop up in minibuffer at startup.
; (setq ad-redefinition-action 'accept) ; silence redefinition startup message.

;; --------- GENERAL KEYBINDINGS ----------------------------------------------
(global-set-key (kbd "<f8>") help-map) ; same result: 'help-command
(global-set-key (kbd "C-h") nil) ; no more c-h
(global-set-key (kbd "<f8> q") 'describe-key) ; the new C-h k
(global-set-key (kbd "<f8> k") nil) ; no more f8 k
(global-set-key (kbd "C-l") nil) ; stop the habbit of c-l to eol, it's now c-k.

;; -------  EVIL - must be at the bottom  -------------------------------------
(evil-mode 1)
(setq evil-emacs-state-cursor '("red" box))
(setq evil-normal-state-cursor '("orange" box))
(setq evil-visual-state-cursor '("green" box))
(setq evil-insert-state-cursor '("orange" bar))
(setq evil-replace-state-cursor '("orange" hbar))
(setq evil-operator-state-cursor '("orange" (hbar . 8))) ; ("red" hollow)
(setq evil-motion-state-cursor '("blue" box))
(setq evil-ex-substitute-global t) ; no more /g at :%s/old/new/g
(setq evil-want-Y-yank-to-eol t) ; Y yanks till eol, not whole line
(defun my-evil-move-eol ()
  " 'move-end-of-line' also works, does not preserve column for up-down
  movement and has strange C-S-k behavior in insert (marks selection and
  then moves)"
  (interactive) (evil-move-end-of-line))
(define-key evil-normal-state-map (kbd "C-k") 'my-evil-move-eol)
(define-key evil-insert-state-map (kbd "C-k") 'my-evil-move-eol)
(defun my-evil-move-bol ()
  "same as my-evil-move-eol, but to beginning of line"
  (interactive) (evil-move-beginning-of-line))
(define-key evil-normal-state-map (kbd "C-j") 'my-evil-move-bol)
(define-key evil-insert-state-map (kbd "C-j") 'my-evil-move-bol)
(define-key evil-normal-state-map (kbd ";") 'evil-ex) ; vim's "nno ; :"
(define-key evil-visual-state-map (kbd ";") 'evil-ex) ; vim's "nno ; :"
(define-key evil-motion-state-map (kbd ";") 'evil-ex) ; vim's "nno ; :"
(evil-define-key 'normal lisp-interaction-mode-map (kbd "C-l") 'eval-print-last-sexp)
(evil-define-key 'insert lisp-interaction-mode-map (kbd "C-l") 'eval-print-last-sexp)

(define-key evil-normal-state-map (kbd  "v") 'evil-visual-block)
(define-key evil-normal-state-map (kbd "C-v") 'evil-visual-line)
(define-key evil-normal-state-map (kbd "V") 'evil-visual-char)

(define-key evil-visual-state-map (kbd  "v") 'evil-visual-block)
(define-key evil-visual-state-map (kbd "C-v") 'evil-visual-line)
(define-key evil-visual-state-map (kbd "V") 'evil-visual-char)

(define-key evil-motion-state-map (kbd  "v") 'evil-visual-block)
(define-key evil-motion-state-map (kbd "C-v") 'evil-visual-line)
(define-key evil-motion-state-map (kbd "V") 'evil-visual-char)

(require 'evil) ; *** now whatever follows after loading
;; ----------------------------------------------------------------------------
