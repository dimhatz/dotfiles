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
(defalias 'yes-or-no-p 'y-or-n-p) ; dont write "yes" but "y" in prompts

;; ------- WORKAROUND1 --------------------------------------------------------
; http://lists.gnu.org/archive/html/help-gnu-emacs/2012-01/msg00199.html
; some plugins mess up (require 'abc) as a result various "ad handle definition"
; pop up in minibuffer at startup.
; (setq ad-redefinition-action 'accept) ; silence redefinition startup message.

;; --------- CURSOR IN CENTER -------------------------------------------------
;; TODO: make jumping to end (G) not pull text showing only upper middle of screen filled.
;; TODO: (optional: make shortcut <ScrLock> to turn on/off centered mode).
(require 'centered-cursor-mode)
(global-centered-cursor-mode 1)
;; ----------------------
; (require 'smooth-scroll)
; (smooth-scroll-mode t)
; (global-set-key [(control  down)]  'scroll-up-1)
; (global-set-key [(control  up)]    'scroll-down-1)
; (global-set-key [(control  left)]  'scroll-right-1)
; (global-set-key [(control  right)] 'scroll-left-1)
;; ----------------------
; (require 'smooth-scrolling) ; not scrolling smoothly on high margins
; (setq smooth-scroll-margin 34) ; does not really center
;; ----------------------
;; simplest possible from author of centered-cursor,
;; but pulls text upwards when reaching the end of buffer to stay centered.
 ; (add-hook 'post-command-hook
 ;   (lambda ()
 ;     (recenter '("don't redraw"))))

;; --------- GENERAL KEYBINDINGS ----------------------------------------------
(global-set-key (kbd "<f8>") help-map) ; same result: 'help-command
(global-set-key (kbd "C-h") nil) ; no more c-h
(global-set-key (kbd "<f8> q") 'describe-key) ; the new C-h k
(global-set-key (kbd "<f8> k") nil) ; no more f8 k
(global-set-key (kbd "C-l") nil) ; stop the habbit of c-l to eol, it's now c-k.

;; -------- LINE NUMBERS -----------------------------------------------------------
(require 'linum)
(global-linum-mode 1) ; show line number in every buffer
; (setq linum-format "%4d")
; (defun linum-format-func (line)
;   (let ((w (length (number-to-string (count-lines (point-min) (point-max))))))
;      (propertize (format (format "%%%dd " w) line) 'face 'linum)))
; (setq linum-format 'linum-format-func)

;; ------- COLOR THEME -------------------------------------------------------------
; (setq x-underline-at-descent-line t) ; suggestion from solarized emacs author
; -------------------------------
; (require 'solarized)
; ; (setq solarized-high-contrast-mode-line t)
; (setq solarized-use-variable-pitch nil);; Don't change the font for some headings and titles
; (setq solarized-use-less-bold t)
; (setq solarized-scale-org-headlines nil)
; ;; Avoid all font-size changes
; (setq solarized-height-minus-1 1)
; (setq solarized-height-plus-1 1)
; (setq solarized-height-plus-2 1)
; (setq solarized-height-plus-3 1)
; (setq solarized-height-plus-4 1)
; (load-theme 'solarized-dark t)
; -------------------------------
; (load-theme 'wombat t)
; -------------------------------
(require 'color-theme-sanityinc-tomorrow)
(load-theme 'sanityinc-tomorrow-night t)
(set-face-attribute 'fringe nil
    :foreground (face-foreground 'default)
    :background (face-background 'default))
(set-face-attribute 'linum nil
    :foreground (face-foreground 'default)
    :background (face-background 'default))

;; ----- PARENS ---------------------------------------------------------------
(setq show-paren-delay 0) ; no delay
(show-paren-mode 1) ; highlight matching paren
(set-face-attribute 'show-paren-match nil
    :background "nil"
    :foreground "dodger blue"
    :weight 'bold
    :underline t)
(set-face-attribute 'show-paren-mismatch nil
    :background "nil"
    :foreground "deep pink"
    :weight 'bold
    :underline t
    :box t)

;; -------- DEFAULT FONT -----------------------------------------------------------
; (custom-set-faces
;  '(default ((t (:height 100 :family "MonaVu")))))

;; -------  EVIL leader key ---------------------------------------------------
(require 'evil-leader)
(evil-leader/set-leader "<SPC>")
(global-evil-leader-mode)
; (evil-leader/set-key
;   "e" 'find-file
;   "b" 'switch-to-buffer
;   "k" 'kill-buffer)

;; -------  EVIL EASYMOTION ---------------------------------------------------
(require 'evil-easymotion)
(evilem-default-keybindings ",")

;; -------  EVIL itself - must be at the bottom  ------------------------------
(evil-mode 1)
(setq evil-emacs-state-cursor '("red" box))
(setq evil-normal-state-cursor '("orange" box))
(setq evil-visual-state-cursor '("lawn green" box))
(setq evil-insert-state-cursor '("orange" bar))
(setq evil-replace-state-cursor '("orange" hbar))
(setq evil-operator-state-cursor '("orange" (hbar . 8))) ; ("red" hollow)
(setq evil-motion-state-cursor '("dodger blue" box))
(setq evil-ex-substitute-global t) ; no more /g at :%s/old/new/g
(setq evil-want-Y-yank-to-eol t) ; Y yanks till eol, not whole line


(setq evil-motion-state-modes ; no more emacs state by default, motion state instead.
      (append evil-emacs-state-modes evil-motion-state-modes))
(setq evil-emacs-state-modes nil)

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

;; -------- STUFF FROM EASY CUSTOMIZATION ------------------------------------------
(require 'avy)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :width normal :height 100 :family "MonaVu"))))
 '(avy-lead-face ((t (:foreground "DarkOrange2" :weight bold))))
 '(avy-lead-face-0 ((t (:foreground "red" :weight bold))))
 '(avy-lead-face-1 ((t (:foreground "lawn green" :weight bold))))
 '(avy-lead-face-2 ((t (:foreground "gold" :weight bold)))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(avy-keys
   (quote
    (97 115 100 102 103 104 106 107 108 122 120 99 118 98 110 109 59 113 119 101 114 116 121 117 105 111 112))))
