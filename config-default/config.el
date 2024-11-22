(setq publishing-dir "/output")
(setq org-publish-project-alist
      `(("roam"
         :base-directory "/roam"
         :recursive t
         :publishing-directory ,publishing-dir
         :with-broken-links     t
         :base-extension "org\\|jpg\\|gif\\|png"
         :publishing-function org-mkdocs-publish-to-md)))

;; (setq org-cite-csl-styles-dir "/config")
;; (setq org-cite-export-processors '((t . (csl "springer-vancouver-brackets.csl" "springer-vancouver-brackets.csl"))))
;; (setq org-cite-global-bibliography '("/config/library.bib"))
