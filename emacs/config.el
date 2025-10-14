(setq frame-resize-pixelwise t)
  

  (defvar elpaca-installer-version 0.11)
  (defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
  (defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
  (defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
  (defvar elpaca-order
    '(elpaca :repo "https://github.com/progfolio/elpaca.git"
             :ref nil :depth 1 :inherit ignore
             :files (:defaults "elpaca-test.el" (:exclude "extensions"))
             :build (:not elpaca--activate-package)))

  (let* ((repo (expand-file-name "elpaca/" elpaca-repos-directory))
         (build (expand-file-name "elpaca/" elpaca-builds-directory))
         (order (cdr elpaca-order))
         (default-directory repo))
    (add-to-list 'load-path (if (file-exists-p build) build repo))
    (unless (file-exists-p repo)
      (make-directory repo t)
      (when (<= emacs-major-version 28) (require 'subr-x))
      (condition-case-unless-debug err
          (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                    ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                    ,@(when-let* ((depth (plist-get order :depth)))
                                                        (list (format "--depth=%d" depth) "--no-single-branch"))
                                                    ,(plist-get order :repo) ,repo))))
                    ((zerop (call-process "git" nil buffer t "checkout"
                                          (or (plist-get order :ref) "--"))))
                    (emacs (concat invocation-directory invocation-name))
                    ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                          "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                    ((require 'elpaca))
                    ((elpaca-generate-autoloads "elpaca" repo)))
              (progn (message "%s" (buffer-string)) (kill-buffer buffer))
            (error "%s" (with-current-buffer buffer (buffer-string))))
        ((error) (warn "%s" err) (delete-directory repo 'recursive)))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads")))

  (add-hook 'after-init-hook #'elpaca-process-queues)
  (elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  (elpaca-use-package-mode))


(elpaca evil
  (use-package evil
    :init
    (setq evil-want-integration t
          evil-want-keybinding nil
          evil-vsplit-window-right t
          evil-split-window-below t)
    :config
    (evil-mode 1)))

(elpaca evil-collection
  (use-package evil-collection
    :after evil
    :config
    (setq evil-collection-mode-list '(dashboard dired ibuffer))
    (evil-collection-init)))

(elpaca evil-tutor
  (use-package evil-tutor))

(use-package emacs :ensure nil
  :config
  (setq ring-bell-function #'ignore))

(elpaca general
  (use-package general
    :config
    (general-evil-setup)

    ;; Set 'SPC' as leader key
    (general-create-definer solomon/leader-keys
      :states '(normal insert visual emacs)
      :keymaps 'override
      :prefix "SPC"
      :global-prefix "M-SPC")

  (solomon/leader-keys
            "SPC" '(counsel-M-x :wk "Counsel M-x") ;; Same as Meta-X (Alt-X)

	    "." '(find-file :wk "Find file")
	    "f c" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
	    "g c c" '(comment-line :wk "Comment lines")
	    "f r" '(counsel-recentf :wk "Find recent files")
            "pc" '(clipboard-yank :wk "Paste Clipboard")

	   "a" '(:ignore t :wk "App")
	   "a l a" '(counsel-linux-app :wk "App launcher")

	    "b" '(:ignore t :wk "buffer")
	    "b b" '(switch-to-buffer :wk "Switch buffer")
	    "b i" '(ibuffer :wk "Ibuffer")
	    "b k" '(kill-this-buffer :wk "Kill buffer")
	    "b n" '(next-buffer :wk "Next buffer")
	    "b p" '(previous-buffer :wk "Previous buffer")
	    "b r" '(revert-buffer :wk "Reload buffer")

	    "d" '(:ignore t :wk "Dired")
	    "d d" '(dired :wk "Open dired")
	    "d j" '(dired-jump :wk "Dired jump to current")
	    "d p" '(peep-dired :wk "Peep-dired")

	    "e" '(:ignore t :wk "evaluate/eshell")
	    "e b" '(eval-buffer :wk "Eval buffer")
	    "e d" '(eval-defun :wk "Eval defun")
	    "e e" '(eval-expression :wk "Eval expression")
	    
	    "e l" '(eval-last-sexp :wk "Eval last sexp")
	    "e r" '(eval-region :wk "Eval region")
	   "e s" '(eshell :which-key "Eshell") 


	    "h" '(:ignore t :wk "Help")
	    "h f" '(describe-function :wk "Describe function")
	    "h v" '(describe-variable :wk "Describe variable")
	    ;; "h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config")
	    "h r r" '(reload-init-file :wk "Reload emacs config")
	    
	    "l" '(:ignore t :wk "Load")
	    "l t" '(load-theme :wk "Load theme")

		"m" '(:ignore t :wk "Org")
		"m a" '(org-agenda :wk "Org agenda")
		"m e" '(org-export-dispatch :wk "Org export dispatch")
		"m i" '(org-toggle-item :wk "Org toggle item")
		"m t" '(org-todo :wk "Org todo")
		"m B" '(org-babel-tangle :wk "Org babel tangle")
		"m T" '(org-todo-list :wk "Org todo list")

		    "m b" '(:ignore t :wk "Tables")
		    "m b -" '(org-table-insert-hline :wk "Insert hline in table")

		"m d" '(:ignore t :wk "Date/deadline")
		"m d t" '(org-time-stamp :wk "Org time stamp")

	"n" '(:ignore t :wk "NeoTree")
	    "n t" '(neotree-toggle :wk "NeoTree toggle")

	    "t" '(:ignore t :wk "Toggle")
	    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
	    "t t" '(visual-line-mode :wk "Toggle truncated lines")
	    
	   "t v" '(vterm-toggle :wk "Toggle vterm") 
	    
		"w" '(:ignore t :wk "Windows")
		;; Window splits
		"w c" '(evil-window-delete :wk "Close window")
		"w n" '(evil-window-new :wk "New window")
		"w s" '(evil-window-split :wk "Horizontal split window")
		"w v" '(evil-window-vsplit :wk "Vertical split window")
		;; Window motions
		"w h" '(evil-window-left :wk "Window left")
		"w j" '(evil-window-down :wk "Window down")
		"w k" '(evil-window-up :wk "Window up")
		"w l" '(evil-window-right :wk "Window right")
		"w w" '(evil-window-next :wk "Goto next window")
		;; Move Windows
		"w H" '(buf-move-left :wk "Buffer move left")
		"w J" '(buf-move-down :wk "Buffer move down")
		"w K" '(buf-move-up :wk "Buffer move up")
		"w L" '(buf-move-right :wk "Buffer move right")
	  )))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(defun reload-init-file () ;; 'defun' == 'def' in python
  (interactive) ;; Makes function available using 'M-x' which is 'Alt-x'
  (load-file user-init-file)
  (load-file user-init-file))

(elpaca eshell-syntax-highlighting
(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.
  
(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh")))

(elpaca vterm
(use-package vterm
:config
(setq shell-file-name "/bin/bash"
      vterm-max-scrollback 5000)))

(elpaca vterm-toggle
(use-package vterm-toggle
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.3)))))

(setq-default line-spacing 0.12)

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(global-set-key (kbd "C-=") 'text-scale-increase) ;; Ctrl +/-
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package doom-modeline
        :ensure t
        :init (doom-modeline-mode 1))
    ;; (use-package powerline
    ;;   :ensure t
    ;;   :config
    ;;   (powerline-default-theme))
;;  (use-package spaceline
  ;;   :ensure t
  ;;   :config
  ;;   (require 'spaceline-config)
  ;;   (spaceline-emacs-theme))

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-banner-logo-title "Emacs Is More Than A Text Editor!"
        dashboard-startup-banner "~/.config/emacs/images/emacs-dash.png"
        dashboard-center-content nil
        dashboard-items '((recents . 5)
                          (agenda . 5)
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
                                     (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

;; (invert-face 'default)
 (use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (nerd-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(elpaca counsel
(use-package counsel
  :after ivy
  :config (counsel-mode)))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(elpaca toc-org
  (use-package toc-org
    :commands toc-org-enable
    :init
    (add-hook 'org-mode-hook 'toc-org-enable)))

(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

(electric-indent-mode -1)

(require 'org-tempo)
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))

(elpaca sudo-edit
(use-package sudo-edit
  :config
    (solomon/leader-keys
      "fu" '(sudo-edit-find-file :wk "Sudo find file")
      "fU" '(sudo-edit :wk "Sudo edit file"))))

(use-package which-key
  :init (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-idle-delay 0.1
        which-key-side-window-max-height 0.25
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit nil
        which-key-separator " → "))

(use-package app-launcher
    :ensure '(app-launcher :host github :repo "SebastienWae/app-launcher"))
;; create a global keyboard shortcut with the following code
;; emacsclient -cF "((visibility . nil))" -e "(emacs-run-launcher)"

(defun emacs-run-launcher ()
  "Create and select a frame called emacs-run-launcher which consists only of a minibuffer and has specific dimensions. Runs app-launcher-run-app on that frame, which is an emacs command that prompts you to select an app and open it in a dmenu like behaviour. Delete the frame after that command has exited"
  (interactive)
  (with-selected-frame 
    (make-frame '((name . "emacs-run-launcher")
                  (minibuffer . only)
                  (fullscreen . 0) ; no fullscreen
                  (undecorated . t) ; remove title bar
                  ;;(auto-raise . t) ; focus on this frame
                  ;;(tool-bar-lines . 0)
                  ;;(menu-bar-lines . 0)
                  (internal-border-width . 10)
                  (width . 80)
                  (height . 11)))
                  (unwind-protect
                    (app-launcher-run-app)
                    (delete-frame))))

(elpaca projectile
(use-package projectile
  :config
  (projectile-mode 1))
)

(elpaca haskell-mode
  (use-package haskell-mode))

(elpaca python-mode
(use-package python-mode))  

  (elpaca lua-mode
  (use-package lua-mode))

(elpaca diminish
(use-package diminish)
)

(elpaca flycheck ;; IF IT DOESN@T WORK RUN META-X FLYCHECK_MODE
(use-package flycheck
     :ensure t
     ;; :defer t
     :init (global-flycheck-mode)
     :config
    (setq flycheck-check-syntax-automatically '(save mode-enabled idle-change))
    (setq flycheck-idle-change-delay 0.5)
    (setq flycheck-python-pylint-executable "pylint"))
       )

(require 'python)
  (setq python-shell-interpreter "python3")  ;; or "python" depending on your system
(setq python-shell-interpreter-args "")
(setq flycheck-python-pylint-executable "pylint")  ;; Make sure it points to your pylint

(elpaca company
  (use-package company
    :defer 2
    :diminish
    :custom
    (company-begin-commands '(self-insert-command))
    (company-idle-delay .1)
    (company-minimum-prefix-length 2)
    (company-show-numbers t)
    (company-tooltip-align-annotations 't)
    (global-company-mode t))
  )
  
(elpaca company-box
(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))
)

(add-to-list 'default-frame-alist '(alpha-background . 90)) ; For all new frames henceforth

(elpaca dired-open
  (use-package dired-open
    :config
    (setq dired-open-extensions '(("gif" . "sxiv")
                                  ("jpg" . "sxiv")
                                  ("png" . "sxiv")
                                  ("mkv" . "vlc")
                                  ("mp4" . "vlc"))))
  )

(elpaca peep-dired
  (use-package peep-dired
    :after dired
    :hook (evil-normalize-keymaps . peep-dired-hook)
    :config
      (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
      (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
      (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
      (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
  ))

(elpaca neotree
(use-package neotree
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 55
        neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action) 
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

;; show hidden files

)
