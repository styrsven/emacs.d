;; -*- coding: utf-8; lexical-binding: t; -*-

;; What to do on Emacs exit / workgroups-mode exit?
(setq wg-emacs-exit-save-behavior           'save)      ; Options: 'save 'ask nil
(setq wg-workgroups-mode-exit-save-behavior 'save)      ; Options: 'save 'ask nil

;; Mode Line changes
;; Display workgroups in Mode Line?
(setq wg-mode-line-display-on t)          ; Default: (not (featurep 'powerline))
(setq wg-flag-modified t)                 ; Display modified flags as well
(setq wg-mode-line-decor-left-brace "["
      wg-mode-line-decor-right-brace "]"  ; how to surround it
      wg-mode-line-decor-divider ":")

;; by default, the sessions are saved in "~/.emacs_workgroups"
(defun my-wg-switch-workgroup ()
  (interactive)
  (my-ensure 'workgroups2)
  (my-ensure 'ivy)
  (let* ((group-names (mapcar (lambda (group)
                                ;; re-shape list for the ivy-read
                                (cons (wg-workgroup-name group) group))
                              (wg-session-workgroup-list (read (f-read-text (file-truename wg-session-file)))))))

    (ivy-read "work groups"
              group-names
              :action (lambda (e)
                        (wg-find-session-file wg-default-session-file)
                        ;; ivy8 & ivy9
                        (if (stringp (car e)) (setq e (cdr e)))
                        (wg-switch-to-workgroup e)))))

(eval-after-load 'workgroups2
  '(progn
     ;; make sure wg-create-workgroup always success
     (defadvice wg-create-workgroup (around wg-create-workgroup-hack activate)
       (unless (file-exists-p (wg-get-session-file))
         (wg-reset t)
         (wg-save-session t))

       (unless wg-current-session
         ;; code extracted from `wg-open-session'.
         ;; open session but do NOT load any workgroup.
         (let* ((session (read (f-read-text (file-truename wg-session-file)))))
           (setf (wg-session-file-name session) wg-session-file)
           (wg-reset-internal (wg-unpickel-session-parameters session))))
       ad-do-it
       ;; save the session file in real time
       (wg-save-session t))

     (defadvice wg-reset (after wg-reset-hack activate)
       (wg-save-session t))

     ;; I'm fine to to override the original workgroup
     (defadvice wg-unique-workgroup-name-p (around wg-unique-workgroup-name-p-hack activate)
       (setq ad-return-value t))))

(provide 'init-workgroups2)
