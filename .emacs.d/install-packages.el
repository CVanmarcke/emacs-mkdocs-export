(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(package-refresh-contents)
(when (not (package-installed-p 'citeproc))
  (package-install 'citeproc))
(when (not (package-installed-p 'org-roam))
  (package-install 'org-roam))
