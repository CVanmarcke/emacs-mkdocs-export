(setq publishing-dir "/output")
(setq org-publish-project-alist
      `(("roam"
         :base-directory "/roam"
         :recursive t
         :publishing-directory ,publishing-dir
         :with-broken-links     t
         :base-extension "org\\|jpg\\|gif\\|png"
         :publishing-function org-mkdocs-publish-to-md)))

(setq org-cite-csl-styles-dir "/config")
(setq org-cite-export-processors '((t . (csl "springer-vancouver-brackets.csl" "springer-vancouver-brackets.csl"))))
(setq org-cite-global-bibliography '("/config/library.bib"))


;; If non-nil export !!text!! as a highlight. Default: t
;; (setopt org-mkdocs-highlight t)
;; The emphasis string to export as highlighted text.
;; (setopt org-mkdocs-highlight-string "!!")

;; If non-nil export admonitions. Default: t
;; "! text" becomes an admonition.
;; "admonition" must be added to markdown extensions.
;; (setopt org-mkdocs-admonition t)

;; If non-nil, export the width of images if written in the format #ATTR_HTML :width ***
;; The markdown extension attr_list needs to be enabled in mkdocs.yml
;; (setopt org-mkdocs-export-image-width t)

;; Adds an attribute to the image to align and wrap text to the left or right of the image.
;;  If nil, keep default and do not wrap text around image.
;;  The markdown extension attr_list needs to be enabled in mkdocs.yml
;; (setopt org-mkdocs-image-alignment nil)

;; If non-nil, lazy load image.
;; The markdown extension attr_list needs to be enabled in mkdocs.yml
;; (setopt org-mkdocs-lazy-load-image t)

;; If non-nil export captions for use with pymdownx.blocks.caption.
;; (setopt org-mkdocs-pymdown-caption t)
