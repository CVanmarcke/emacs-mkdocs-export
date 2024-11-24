;;; ox-mkdocs.el --- Back-End for Org Export Engine to mkdocs -*- lexical-binding: t; -*-

;; Based on ox-md
(require 'org)
(require 'org-element)
(require 'ox)
(require 'ox-md)
(require 'ox-publish)

;; (package-initialize)
;; (when (not (package-installed-p 'citeproc))
;;   (package-refresh-contents)
;;   (package-vc-install "https://github.com/andras-simonyi/citeproc-el" "54184baaff555b5c7993d566d75dd04ed485b5c0")
;;   (package-install 'citeproc))
;; (when (not (package-installed-p 'org-roam))
;;   (package-install 'org-roam))
;; (require 'citeproc)

;; TODO quote block via admonition

(org-export-define-derived-backend 'mkdocs 'md
  :filters-alist '((:filter-parse-tree . org-md-separate-elements))
  :menu-entry
  '(?m "Export to Markdown"
       (
	(?K "To mkdocs temporary buffer"
	    (lambda (a s v b) (org-mkdocs-export-as-markdown a s v)))
	(?k "To mkdocs file" (lambda (a s v b) (org-mkdocs-export-to-markdown a s v)))
	;; (?o "To file and open"
	;;     (lambda (a s v b)
	;;       (if a (org-mkdocs-export-to-markdown t s v)
	;; 	(org-open-file (org-md-export-to-markdown nil s v)))))
	))
  :translate-alist '(;; (bold . org-md-bold)
		     ;; (center-block . org-md--convert-to-html)
		     ;; (code . org-md-verbatim)
		     ;; (drawer . org-md--identity)
		     ;; (dynamic-block . org-md--identity)
		     ;; (example-block . org-md-example-block)
		     ;; (export-block . org-md-export-block)
		     ;; (fixed-width . org-md-example-block)
		     ;; (headline . org-mkdocs-headline)
		     (headline . org-md-headline)
		     ;; (horizontal-rule . org-md-horizontal-rule)
		     ;; (inline-src-block . org-md-verbatim)
		     ;; (inlinetask . org-md--convert-to-html)
		     ;; (inner-template . org-md-inner-template)
		     ;; (italic . org-md-italic)
		     (item . org-mkdocs-item)
		     ;; (keyword . org-md-keyword)
                     ;; (latex-environment . org-md-latex-environment)
                     ;; (latex-fragment . org-md-latex-fragment)
		     ;; (line-break . org-md-line-break)
		     (link . org-mkdocs-link) ;; custom
		     ;; (node-property . org-md-node-property)
		     (paragraph . org-mkdocs-paragraph)
		     ;; (plain-list . org-md-plain-list)
		     ;; (plain-text . org-md-plain-text)
		     ;; (property-drawer . org-md-property-drawer)
		     ;; (quote-block . org-md-quote-block)
		     (section . org-mkdocs-section) ;; Custom
		     ;; (special-block . org-md--convert-to-html)
		     ;; (src-block . org-md-example-block)
		     ;; (table . org-md--convert-to-html)
		     (template . org-mkdocs-template)
		     (verbatim . org-md-verbatim))
  :options-alist
  '(;; (:md-footnote-format nil nil org-md-footnote-format)
    ;; (:md-footnotes-section nil nil org-md-footnotes-section)
    ;; (:md-headline-style nil nil org-md-headline-style)
    (:html-text-markup-alist nil nil org-mkdocs-text-markup-alist)
    (:md-toplevel-hlevel nil 2 org-mkdocs-toplevel-hlevel)
    (:with-toc nil nil org-mkdocs-export-with-toc)
    ;; (:with-sub-superscript nil '{} org-export-with-sub-superscripts) ;; TODO testen
    (:with-sub-superscript nil "^" '{}) ;Require curly braces to be wrapped around text to sub/super-scripted
    (:mkdocs-pymdown-caption nil nil org-mkdocs-pymdown-caption) ;; TODO testen
    (:mkdocs-admonition nil nil org-mkdocs-admonition) ;; TODO testen
    (:mkdocs-highlight nil nil org-mkdocs-highlight) ;; TODO testen
    ))

(setopt org-export-with-section-numbers nil)
;; (setopt org-export-with-section-numbers 2)

(defcustom org-mkdocs-highlight t
  "If non-nil export !!text!! as a highlight. "
  :group 'org-export-mkdocs)

(defcustom org-mkdocs-highlight-string "!!"
  "The marker to emphasize"
  :group 'org-export-mkdocs)

(defcustom org-mkdocs-admonition t
  "If non-nil export admonitions
  ! admonition
  Becomes 
   /// warning
       admonition
   ///"
  :group 'org-export-mkdocs)

(defcustom org-mkdocs-pymdown-caption t
  "If non-nil export captions for use with pymdownx.blocks.caption.
   
   ![img](image.png)
   /// caption
   captiontext
   ///"
  :group 'org-export-mkdocs)

(defcustom org-mkdocs-export-with-toc nil
  "Export with toc. If nil, do not export with toc."
  :group 'org-export-mkdocs)

(defcustom org-mkdocs-toplevel-hlevel 2
  "Heading level to use for level 1 Org headings in markdown export.
   Should be 2: changes all the headers to >= 2, as the title will get header 1."
  :group 'org-export-mkdocs
  ;; Avoid `natnum' because that's not available until Emacs 28.1.
  :type 'integer)

(defcustom org-mkdocs-text-markup-alist
  '((bold . "<b>%s</b>")
    (code . "<code>%s</code>")
    (italic . "<i>%s</i>")
    (strike-through . "<del>%s</del>")
    (underline . "<u>%s</u>")
    (verbatim . "<code>%s</code>"))
  "Alist of HTML expressions to convert text markup.

The key must be a symbol among `bold', `code', `italic',
`strike-through', `underline' and `verbatim'.  The value is
a formatting string to wrap fontified text with.

If no association can be found for a given markup, text will be
returned as-is."
  :group 'org-export-html
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(alist :key-type (symbol :tag "Markup type")
		:value-type (string :tag "Format string"))
  :options '(bold code italic strike-through underline verbatim))

(defun ox-mkdocs/link-filter (text backend info)
  (if (org-export-derived-backend-p backend 'md)
      ;; remove <.link> en vervang door normale []()
      ;; (let* ((text (replace-regexp-in-string "<\\(.+\\)>" "[\\1](\\1)" text)))
      ;; 	)
      ;; change ../folder/link.md with link.md
      ;; TODO voeg optie "flatten tree" ofzo toe die dit doet.... (cave mag enkel voor MD documenten)
      (replace-regexp-in-string "(\\.\\./.+?/\\(.+\\))" "(\\1)" text)
    text))

(defun org-mkdocs-template (contents _info)
  "Return complete document string after Markdown conversion.
CONTENTS is the transcoded contents string.  INFO is a plist used
as a communication channel."
  (let* ((taglist (org-get-tags))
	 (title (org-get-title)
	      ;; (org-element-interpret-data (plist-get contents :title))
	      )
       (id (cdr (assoc "ID" (org-entry-properties)))))
    (concat "---\n"
            "title: \"" title "\"\n"
            (mkdocs/format-tags-to-yaml taglist)
            "context_id: " id "\n"
            "---\n"
            "# " title "\n"
            contents)))

(defun mkdocs/format-tags-to-yaml (taglist)
  (concat "tags:\n"
	  (mapconcat (lambda (tag)
		       (concat "  - " (substring-no-properties tag) "\n"))
		     taglist )
   ;; (dolist (tag taglist result)
   ;;   (setq result (concat result "  - " (substring-no-properties tag) "\n")))
   ))

(defun org-mkdocs-paragraph (paragraph contents info)
  (let ((contents (org-md-paragraph paragraph contents info)))
    ;; Adds support for underlining (_text_)
	(setq contents (replace-regexp-in-string
					"\\([ (]\\)\\\\_\\(\\w.+\\w\\)\\\\_\\([ ).]\\)"
					"\\1<u>\\2</u>\\3"
					contents))
	(when (plist-get info :mkdocs-admonition)
	  ;; Admonition
	  (setq contents (replace-regexp-in-string
					  "^! \\(.*\\)$" "!!! warning\n    \\1" contents)))
	(when (plist-get info :mkdocs-highlight)
	  (let ((regex-matcher (concat "\\([ \t\n]\\|^\\)" ;; before marker
				       org-mkdocs-highlight-string
				       "\\([^ \n\r\t!].+?[^ \n\r\t!]\\)" ;; inside markers
				       org-mkdocs-highlight-string
				       "\\([ \t\n.]\\|$\\)")) ;; after marker
		(regex-replace (concat "\\1"
				       (format (cdr (assq 'highlight org-mkdocs-text-markup-alist)) "\\2")
				       "\\3")))
	    (setq contents (replace-regexp-in-string regex-matcher regex-replace contents))))
	contents))

(defun org-mkdocs-section (_section contents info)
  ;; Execute the section filter of org-md
  (let ((contents (org-md-section _section contents info)))
	(when (plist-get info :mkdocs-pymdown-caption)
	  (setq contents (replace-regexp-in-string
					  "\\(!\\[img\\](.+\\)\\(\\.png\\|\\.jpe?g\\|\\.gif\\|\\.webp\\)\\()[ \t]*\n\\)\\(.+\\)+\n"
					  "\\1\\2\\3/// caption\n\\4\n///\n\n" contents)))))

;; TODO support for width
;; ![Image title](https://dummyimage.com/600x400/){ width="300" }
(defun org-mkdocs-link (link desc info)
  "Transcode LINK object into Markdown format.
DESC is the description part of the link, or the empty string.
INFO is a plist holding contextual information.  See
`org-export-data'."
  (let* ((link-org-files-as-md
	  (lambda (raw-path)
	    ;; Treat links to `file.org' as links to `file.md'.
	    (if (string= ".org" (downcase (file-name-extension raw-path ".")))
		(concat (file-name-sans-extension raw-path) ".md")
	      raw-path)))
	 (type (org-element-property :type link))
	 (raw-path (org-element-property :path link))
	 (path (cond
		((member type '("http" "https" "ftp" "mailto"))
		 (concat type ":" raw-path))
		((string-equal  type "file")
		 (org-export-file-uri (funcall link-org-files-as-md raw-path)))
		(t raw-path))))
    (cond
     ;; Link type is handled by a special function.
     ((org-export-custom-protocol-maybe link desc 'mkdocs info)) ;; Changed
     ((member type '("custom-id" "id" "fuzzy"))
      (let ((destination (if (string= type "fuzzy")
			     (org-export-resolve-fuzzy-link link info)
			   ;; Changed from org-md-link
			   (org-export-resolve-id-link-with-roam link info))))
	(pcase (org-element-type destination)
	  (`plain-text			; External file.
	   (let ((path (funcall link-org-files-as-md destination)))
	     (if (not desc) (format "[%s](%s)" path path) ;; Changed
	       (format "[%s](%s)" desc path))))
	  (`headline
	   (format
	    "[%s](#%s)"
	    ;; Description.
	    (cond ((org-string-nw-p desc))
		  ((org-export-numbered-headline-p destination info)
		   (mapconcat #'number-to-string
			      (org-export-get-headline-number destination info)
			      "."))
		  (t (org-export-data (org-element-property :title destination)
				      info)))
	    ;; Reference.
	    (or (org-element-property :CUSTOM_ID destination)
		(org-export-get-reference destination info))))
	  (_
	   (let ((description
		  (or (org-string-nw-p desc)
		      (let ((number (org-export-get-ordinal destination info)))
			(cond
			 ((not number) nil)
			 ((atom number) (number-to-string number))
			 (t (mapconcat #'number-to-string number ".")))))))
	     (when description
	       (format "[%s](#%s)"
		       description
		       (org-export-get-reference destination info))))))))
     ((org-export-inline-image-p link org-html-inline-image-rules)
      (let ((path (cond ((not (string-equal type "file"))
			 (concat type ":" raw-path))
			((not (file-name-absolute-p raw-path)) raw-path)
			(t (expand-file-name raw-path))))
	    (caption (org-export-data
		      (org-export-get-caption
		       (org-export-get-parent-element link))
		      info)))
	;; TODO setting voor aan of uit te zetten
	(if (and (org-string-nw-p caption)
		 (plist-get info :mkdocs-pymdown-caption))
	    (format "![img](%s)\n%s" path (org-mkdocs/format-caption caption))
	  (format "![img](%s)" path))
	;; (format "![img](%s)"
	;; 	(if (not (org-string-nw-p caption))
	;; 	    path
	;; 	  (format "%s \"%s\"" path caption)))
	))
     ((string= type "coderef")
      (format (org-export-get-coderef-format path desc)
	      (org-export-resolve-coderef path info)))
     ((string= type "radio")
      (let ((destination (org-export-resolve-radio-link link info)))
	(if (not destination) desc
	  (format "<a href=\"#%s\">%s</a>"
		  (org-export-get-reference destination info)
		  desc))))
     (t (if (not desc) (format "[%s](%s)" path path) ;; Changed from org-md-link
	  (format "[%s](%s)" desc path))))))

(defun org-mkdocs/format-caption (caption)
  (format "/// caption\n%s\n///" caption))


(defun org-mkdocs-item (item contents info)
  "Transcode ITEM element into Markdown format.
CONTENTS is the item contents.  INFO is a plist used as
a communication channel."
  (let* ((type (org-element-property :type (org-export-get-parent item)))
	 (struct (org-element-property :structure item))
	 (bullet (if (not (eq type 'ordered)) "-"
		   (concat (number-to-string
			    (car (last (org-list-get-item-number
					(org-element-property :begin item)
					struct
					(org-list-prevs-alist struct)
					(org-list-parents-alist struct)))))
			   ".")))
	 (tag (org-element-property :tag item)))
    (concat bullet
	    (make-string (- 4 (length bullet)) ? )
	    (pcase (org-element-property :checkbox item)
	      (`on "[X] ")
	      (`trans "[-] ")
	      (`off "[ ] "))
	    ;; prevents - tag ::\n  - nextitem -> - tag: - nextitem
	    (and tag
		 (format "**%s:** " (org-export-data tag info)))
	    (if (and tag (s-equals-p (substring contents 0 1) "-"))
		(concat "\n" (replace-regexp-in-string "^" "    " contents))
	      (and contents
		   (org-trim (replace-regexp-in-string "^" "    " contents)))))))

;; ----------------------------
;; Makes the export process aware of org-roam, and preferentially makes it get links from the roam DB.
;; ----------------------------
(defun org-export-resolve-id-link-with-roam (link info)
  "Return headline referenced as LINK destination.

INFO is a plist used as a communication channel.

Return value can be the headline element matched in current parse
tree or a file name.  Assume LINK type is either \"id\" or
\"custom-id\".  Throw an error if no match is found."
  (let ((id (org-element-property :path link)))
    (or
     ;; Check if id is known in org-roam
     (when (fboundp 'org-roam-id-find)
	  (let ((link-path (car (org-roam-id-find id))))
	    (when link-path
	      (file-relative-name link-path
				  (file-name-parent-directory (buffer-file-name))))))

	;; First check if id is within the current parse tree.
     (let ((local-ids (or (plist-get info :id-local-cache)
                          (let ((table (make-hash-table :test #'equal)))
                            (org-element-map
                             (plist-get info :parse-tree)
                             'headline
                             (lambda (headline)
                               (let ((id (org-element-property :ID headline))
                                     (custom-id (org-element-property :CUSTOM_ID headline)))
                                 (when id
                                   (unless (gethash id table)
                                     (puthash id headline table)))
                                 (when custom-id
                                   (unless (gethash custom-id table)
                                     (puthash custom-id headline table)))))
                             info)
                            (plist-put info :id-local-cache table)
                            table))))
       (gethash id local-ids))
     ;; Otherwise, look for external files.
     (cdr (assoc id (plist-get info :id-alist))) ;;This one finds it
     (signal 'org-link-broken (list id)))))

;; TODO: gaat niet lukken met die lexical binding: moet vervangen worden in de definitie.

(defun org-mkdocs-export-with-lexical-bindings (function arglist)
  (let (;; (outfile (org-export-output-file-name ".md" subtreep))
		;; (org-md-toplevel-hlevel 2)
		;; Prevents doing weird things when _ is in the text
		;; (org-use-sub-superscripts '{})
		;; (org-export-with-sub-superscripts '{}) ;;todo test
		(org-html-text-markup-alist org-html-text-markup-alist)
		(org-export-filter-link-functions org-export-filter-link-functions))

    (add-to-list 'org-html-text-markup-alist '(underline . "<u>%s</u>"))
    ;; TODO aan filter toevoegen van de dispatch
    ;; (add-hook 'org-export-filter-link-functions #'ox-mkdocs/link-filter) ;; not ran as local because errors
    ;; (advice-add 'org-export-resolve-id-link :override #'org-export-resolve-id-link-with-roam)

    ;; Export
    (apply function arglist)

    ;; Cleanup
    ;; (advice-remove 'org-export-resolve-id-link #'org-export-resolve-id-link-with-roam)
    )
  )


;;;###autoload
(defun org-mkdocs-export-as-markdown (&optional async subtreep visible-only)
  "Export current buffer to a mkdocs compatible markdown buffer.

Export is done in a buffer named \"*Org mkdocs MD Export*\", which will
be displayed when `org-export-show-temporary-export-buffer' is
non-nil."
  (interactive)
  (org-mkdocs-export-with-lexical-bindings
   'org-export-to-buffer
   (list 'mkdocs "*Org mkdocs MD Export*"
	 async subtreep visible-only nil nil (lambda () (text-mode)))))


;;;###autoload
(defun org-mkdocs-export-to-markdown (&optional async subtreep visible-only)
  "Export current buffer to a Markdown file.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Return output file's name."
  (interactive)
  (let ((outfile (org-export-output-file-name ".md" subtreep)))
    (org-mkdocs-export-with-lexical-bindings
     'org-export-to-file
     (list 'mkdocs outfile async subtreep visible-only))))


;; TODO: voor export lukt dat wel...

;;;###autoload
(defun org-mkdocs-publish-to-md (plist filename pub-dir)
  "Publish an org file to Markdown.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (org-mkdocs-export-with-lexical-bindings
   'org-publish-org-to
   (list 'mkdocs filename ".md" plist pub-dir)))

(provide 'ox-mkdocs)

;; Local variables:
;; generated-autoload-file: "org-loaddefs.el"
;; End:

;;; ox-md.el ends here