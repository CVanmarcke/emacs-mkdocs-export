(require 'org)
(require 'org-element)
(require 'ox)
(require 'ox-md)
(require 'oc)
(require 'oc-csl)
(require 'package)
(require 'ox-publish)

(message "Emacs: initializing packages")
(package-initialize)
(require 'citeproc)
(load "~/.emacs.d/ox-mkdocs.el")

;; Cache
(message "Emacs: setting variables and locations")
(setq make-backup-files nil)
(setq var-directory (expand-file-name "/cache"))
(make-directory "/cache/org/persist/timestamps" t)
(make-directory "/cache/persist" t)
(make-directory "/cache/org/persist" t)
(setq org-publish-timestamp-directory
      (expand-file-name (convert-standard-filename "org/timestamps/") var-directory))
(setq org-id-locations-file  
      (expand-file-name (convert-standard-filename "org/id-locations.el") var-directory))
(setq org-persist-directory  
      (expand-file-name (convert-standard-filename "org/persist/") var-directory))
(setq persist--directory-location  
      (expand-file-name (convert-standard-filename "persist/") var-directory))


;; ---------------------
(message "Emacs: setting citeproc config")
(setq org-cite-csl-styles-dir "/config")
(if (file-exists-p "/config/library.bib")
    (setq org-cite-global-bibliography '("/config/library.bib"))
  (message "Warning: no library.bib file in /config: citations will not be rendered."))
(setq org-cite-export-processors '((t . (csl "springer-vancouver-brackets.csl" "springer-vancouver-brackets.csl"))))
;; ---------------------

;; ---------------------
(message "Emacs: setting default roam configuration")
(setq org-roam-directory "/roam")
(setq org-roam-db-location "/cache/org-roam.db")
(require 'org-roam)
;; ---------------------

;; ---------------------
(message "Emacs: setting default publishing configuration")
(setq publishing-dir "/output")
(setq org-publish-project-alist
      `(("roam"
         :base-directory "/roam"
         :recursive t
         :publishing-directory ,publishing-dir
         :with-broken-links     t
         :base-extension "org\\|jpg\\|gif\\|png"
         :publishing-function org-mkdocs-publish-to-md)))
;; ---------------------

(message "Emacs: populating custom config")
(when (not (file-exists-p "/config/config.el"))
  (copy-file "/root/config-default/config.el" "/config/config.el"))
(when (not (file-exists-p "/config/springer-vancouver-brackets.csl"))
  (copy-file "/root/config-default/springer-vancouver-brackets.csl" "/config/springer-vancouver-brackets.csl"))

(message "Emacs: loading custom config (/config/config.el)")
(load "/config/config.el")

(message "Emacs: initializing roam database")
(org-roam-db-sync)

(message "------------------")
(message "Starting export with settings:")
(message (concat "- Roam directory: " org-roam-directory))
(message (concat "- Publishing directory target: " publishing-dir))
(message (format "- org-publish-project-alist: %s" org-publish-project-alist))
(message (format "- org-cite-csl-styles-dir: %s" org-cite-csl-styles-dir))
(message (format "- org-cite-export-processors: %s" org-cite-export-processors))

