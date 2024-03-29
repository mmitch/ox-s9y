;;; ox-s9y.el --- Serendipity HTML Back-End for Org Export Engine -*- lexical-binding: t; -*-

;; Copyright (C) 2017-2021,2023  Christian Garbs <mitch@cgarbs.de>
;; Licensed under GNU GPL v3 or later.

;; This file is part of ox-s9y.

;; ox-s9y is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ox-s9y is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ox-s9y.  If not, see <http://www.gnu.org/licenses/>.

;; Author: Christian Garbs <mitch@cgarbs.de>
;; URL: https://github.com/mmitch/ox-s9y
;; Keywords: bbcode, org, export, outlines
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.4") (org "8.0"))

;;; Commentary:

;; export Org documents to Serendipity blog

;;; Code:

(require 'ox)
(require 'ox-html)

;;; Backend definition

					; internal reminder: for Org format information see
					; https://orgmode.org/worg/dev/org-element-api.html

(org-export-define-derived-backend 's9y 'html
  :translate-alist
  '((bold . ox-s9y-bold)
    (code . ox-s9y-code)
    (fixed-width . ox-s9y-fixed-width)
    (footnote-definition . ox-s9y-footnote-definition)
    (footnote-reference . ox-s9y-footnote-reference)
    (headline . ox-s9y-headline)
    (inner-template . ox-s9y-inner-template)
    (italic . ox-s9y-italic)
    (item . ox-s9y-item)
    (line-break . ox-s9y-line-break)
    (link . ox-s9y-link)
    (paragraph . ox-s9y-paragraph)
    (plain-list . ox-s9y-plain-list)
    (plain-text . ox-s9y-plain-text)
    (quote-block . ox-s9y-quote-block)
    (section . ox-s9y-section)
    (src-block . ox-s9y-geshi-block)
    (strike-through . ox-s9y-strike-through)
    (template . ox-s9y-template)
    (underline . ox-s9y-underline)
    (verbatim . ox-s9y-verbatim))
  :menu-entry
  '(?S "Export to Serendipity"
       ((?h "As HTML buffer" ox-s9y-export-as-html)
	(?f "As HTML file" ox-s9y-export-to-html)
	(?H "As HTML buffer and to clipboard" ox-s9y-export-to-kill-ring)))

;;; Customization

  (defgroup org-export-s9y nil
    "Options for exporting Org mode files to Serendipity."
    :tag "Org Export Serendipity"
    :group 'org-export)

  (defcustom ox-s9y-todo-link-title "Artikel folgt"
    "Default string to use as <abbr> title for todo: LINKS."
    :group 'org-export-s9y
    :type 'string)

;;; Helper methods

  (defun ox-s9y--put-in-tag (tag contents &optional attributes)
    "Puts the HTML tag TAG around the CONTENTS string.
Optional ATTRIBUTES for the tag can be given as an alist of
key/value pairs (both strings)."
    (let ((attribute-string (if attributes
				(mapconcat (function (lambda (attribute)
						       (let ((key (car attribute))
							     (value (cadr attribute)))
							 (format " %s=\"%s\"" key value))))
					   attributes
					   "")
			      "")))
      (format "<%s%s>%s</%s>" tag attribute-string contents tag)))

  (defun ox-s9y--fix-url (url)
    "Fix URL returned from `url-encode-url'.
Older versions of Emacs (eg. 24.3 used in the Travis CI minimal
image) prepend \"/\" to urls consisting only of an \"#anchor\"
part.  We don't want this, because we need relative anchors.  Fix
this the hard way."
    (if (string-prefix-p "/#" url)
	(substring url 1)
      url))

  (defun ox-s9y--map-to-geshi-language (language)
    "Map LANGUAGE from Org to Geshi."
    (cond ((string= language "elisp") "lisp")
	  ((string= language "shell") "bash")
	  ((string= language "sh")    "bash")
	  ((string= language "conf")  "ini")
	  ((string= language "") "plaintext")
	  (language)
	  (t "plaintext")))

  (defun ox-s9y--put-a-href (contents href &optional class id)
    "Put CONTENTS inside a simple <a> tag pointing to HREF.
Automagically escapes the target URL.  An optional CLASS and ID can be
set on the <a> tag."
    (let* ((target (ox-s9y--fix-url (url-encode-url (org-link-unescape href))))
	   (attributes (list (list "href" target))))
      (when class
	(setq attributes (append attributes (list (list "class" class))))
	(when id
	  (setq attributes (append attributes (list (list "id" id))))))
      (ox-s9y--put-in-tag "a" contents attributes)))

  (defun ox-s9y--apply-regexp-list (regexps text)
    "Apply the list of REGEXPS to TEXT."
    (if regexps
	(let* ((head (car regexps))
	       (tail (cdr regexps))
	       (regexp (car  head))
	       (rep    (cadr head)))
	  (replace-regexp-in-string regexp rep
				    (ox-s9y--apply-regexp-list tail text)
				    nil 'literal))
      text))

  (defun ox-s9y--quote-html (text)
    "Quote HTML entities in TEXT."
    (ox-s9y--apply-regexp-list (list (list "<"  "&lt;")
				     (list ">"  "&gt;")
				     (list "\"" "&quot;")
				     (list "&"  "&amp;"))
			       text))

  (defun ox-s9y--remove-leading-newline (text)
    "Remove a leading empty line from TEXT."
    (replace-regexp-in-string "\\`\n" "" text))

  (defun ox-s9y--remove-trailing-newline (text)
    "Remove the trailing newline from TEXT."
    (replace-regexp-in-string "\n\\'" "" text))

;;; Backend callbacks

  (defun ox-s9y-bold (_bold contents _info)
    "Transcode a BOLD element from Org to Serendipity.
CONTENTS is the bold text, as a string.  INFO is
  a plist used as a communication channel."
    (ox-s9y--put-in-tag "strong" contents))

  (defun ox-s9y-code (code _contents _info)
    "Transcode a CODE element from Org to Serendipity.
CONTENTS is nil.  INFO is a plist used as a communication channel."
    (ox-s9y--put-in-tag "code" (ox-s9y--quote-html (org-element-property :value code))))

  (defun ox-s9y-geshi-block (code-block _contents info)
    "Transcode a CODE-BLOCK element from Org to Serendipity GeSHi plugin.
CONTENTS is nil.  INFO is a plist holding
contextual information."
    (format "[geshi lang=%s]%s[/geshi]"
	    (ox-s9y--map-to-geshi-language (org-element-property :language code-block))
	    (ox-s9y--remove-trailing-newline
	     (org-export-format-code-default code-block info))))

  (defun ox-s9y-fixed-width (fixed-width _contents _info)
    "Transcode a FIXED-WIDTH element from Org to Serendipity.
CONTENTS is nil.  INFO is a plist holding contextual information."
    (format "[geshi lang=plaintext]%s[/geshi]"
	    (ox-s9y--remove-leading-newline
	     (ox-s9y--remove-trailing-newline
	      (org-element-property :value fixed-width)))))

  (defun ox-s9y-footnote-reference (footnote-reference _contents info)
    "Transcode a FOOTNOTE-REFERENCE element from Org to Serendipity.
CONTENTS is nil.  INFO is a plist holding contextual information."
    (if (eq (org-element-property :type footnote-reference) 'inline)
	(user-error "Inline footnotes not supported yet")
      (concat
       ;; Insert separator between two footnotes in a row.
       (let ((prev (org-export-get-previous-element footnote-reference info)))
	 (when (eq (org-element-type prev) 'footnote-reference)
	   "<sup>, </sup>"))
       (let* ((n (org-export-get-footnote-number footnote-reference info))
	      (anchor-to (format "#fn-to-%d" n))
	      (anchor-from (when (org-export-footnote-first-reference-p footnote-reference info)
			     (format "fn-from-%d" n)))
	      (reftext (format "[%d]" n)))
	 (ox-s9y--put-in-tag
	  "sup"
	  (ox-s9y--put-a-href reftext anchor-to "footnote" anchor-from))))))

  (defun ox-s9y-format-footnote-definition (fn)
    "Format the footnote definition FN."
    (let* ((n (car fn))
	   (def (cdr fn))
	   (n-format (format "[%d]" n))
	   (anchor-to (format "fn-to-%d" n))
	   (anchor-from (format "#fn-from-%d" n))
	   (definition (concat (ox-s9y--put-a-href n-format anchor-from)
			       ": "
			       def)))
      (ox-s9y--put-in-tag "div"
			  definition
			  (list (list "class" "footnote")
				(list "id" anchor-to)))))

  (defun ox-s9y-footnote-section (info)
    "Format the footnote section.
INFO is a plist used as a communication channel."
    (let* ((org-major (string-to-number (car (split-string (org-release) "\\."))))
	   (fn-alist (if (> org-major 8)
			 (org-export-collect-footnote-definitions
			  info (plist-get info :parse-tree))
		       (org-export-collect-footnote-definitions
			(plist-get info :parse-tree) info)))
	   (fn-alist
	    (cl-loop for (n _label raw) in fn-alist collect
		     (cons n (org-trim (org-export-data raw info)))))
	   (text (mapconcat #'ox-s9y-format-footnote-definition fn-alist "\n")))
      (if fn-alist
	  (ox-s9y--put-in-tag "div" text '((id footnotes)))
	"")))

  (defun ox-s9y-headline (headline contents info)
    "Transcode HEADLINE element from Org to Serendipity.
CONTENTS is the headline contents.  INFO is a plist used as
a communication channel."
    (let* ((title (org-export-data (org-element-property :title headline) info))
	   (level (org-export-get-relative-level headline info))
	   (is-details (and (plist-get info :with-tags)
			    (member "details" (org-export-get-tags headline info))))
	   (is-skip (string= "END" title))
	   (is-footnotes (org-element-property :footnote-section-p headline)))
      (cond
       (is-details (if is-skip
		       contents
		     (let ((summary (if title
					(concat (ox-s9y--put-in-tag "summary" title) "\n")
				      "")))
		       (ox-s9y--put-in-tag "details" (concat "\n" summary contents)))))
       (is-footnotes "")
       (t (concat
	   (if (<= level 2)
	       (format "<!--  %s  -->" title)
	     (ox-s9y--put-in-tag (format "h%d" level) title))
	   "\n"
	   contents)))))

  (defun ox-s9y-inner-template (contents info)
    "Return body of document string after Serendipity conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
    (concat
     contents
     (ox-s9y-footnote-section info)))

  (defun ox-s9y-italic (_italic contents _info)
    "Transcode a ITALIC element from Org to Serendipity.
CONTENTS is the italic text, as a string.  INFO is
  a plist used as a communication channel."
    (ox-s9y--put-in-tag "em" contents))

  (defun ox-s9y-item (item contents info)
    "Transcode a ITEM element from Org to Serendipity.
CONTENTS is the contents of the item, as a string.  INFO is
  a plist used as a communication channel."
    (let* ((plain-list (org-export-get-parent item))
	   (value (let ((counter (org-element-property :counter item)))
		    (if counter
			(list (list "value" counter))
		      ())))
	   (term (let ((tag (org-element-property :tag item)))
		   (and tag (org-export-data tag info))))
	   (type (org-element-property :type plain-list)))
      (concat
       (pcase type
	 (`descriptive
	  (concat
	   (ox-s9y--put-in-tag "dt" (org-trim term))
	   "\n"
	   (ox-s9y--put-in-tag "dd" (org-trim contents))))
	 (_
	  (ox-s9y--put-in-tag "li" (org-trim contents) value)))
       "\n")))

  (defun ox-s9y-line-break (_line-break _contents _info)
    "Transcode a LINE-BREAK object from Org to Serendipity.
CONTENTS is nil.  INFO is a plist holding contextual
information."
    "<br>\n")

  (defun ox-s9y-link (link contents _info)
    "Transcode a LINK element from Org to Serendipity.
CONTENTS is the contents of the link, as a string.  INFO is
  a plist used as a communication channel."
    (let ((type (org-element-property :type link))
	  (path (org-element-property :path link))
	  (raw  (org-element-property :raw-link link)))
      (cond
       ((string= type "fuzzy")
	(cond
	 ((string-prefix-p "todo:" raw)
	  (let* ((todo-suffix (substring raw (length "todo:")))
		 (title (if (string= "" todo-suffix) ox-s9y-todo-link-title
			  todo-suffix)))
	    (ox-s9y--put-in-tag "abbr" contents (list (list "title" title)))))
	 ((string-prefix-p "about:" raw)
	  (ox-s9y--put-a-href contents raw))
	 (t (user-error "Unknown fuzzy LINK type encountered: `%s'" raw))))
       ((member type '("http" "https"))
	(ox-s9y--put-a-href contents (concat type ":" path)))
       ((string= type "news")
	(ox-s9y--put-a-href contents raw))
       (t (user-error "LINK type `%s' not yet supported" type)))))

  (defun ox-s9y-paragraph (paragraph contents _info)
    "Transcode a PARAGRAPH element from Org to Serendipity.
CONTENTS is the contents of the paragraph, as a string.  INFO is
  a plist used as a communication channel."
    (let* ((parent (org-export-get-parent paragraph))
	   (parent-type (org-element-type parent)))
      (if (eq parent-type 'section)
	  (ox-s9y--put-in-tag "p" (org-trim contents))
	(org-trim contents))))

  (defun ox-s9y-plain-list (plain-list contents _info)
    "Transcode a PLAIN-LIST element from Org to Serendipity.
CONTENTS is the contents of the plain-list, as a string.  INFO is
  a plist used as a communication channel."
    (let ((type (org-element-property :type plain-list)))
      (concat
       (pcase type
	 (`descriptive (ox-s9y--put-in-tag "dl" (org-trim contents)))
	 (`unordered (ox-s9y--put-in-tag "ul" (org-trim contents)))
	 (`ordered (ox-s9y--put-in-tag "ol" (org-trim contents)))
	 (other (user-error "PLAIN-LIST type `%s' not yet supported" other)))
       "\n")))

  (defun ox-s9y-plain-text (text _info)
    "Transcode a TEXT string from Org to Serendipity.
INFO is a plist used as a communication channel."
    text)

  (defun ox-s9y-quote-block (_quote-block contents _info)
    "Transcode a QUOTE-BLOCK element from Org to Serendipity.
CONTENTS holds the contents of the block.  INFO is a plist used
as a communication channel."
    (ox-s9y--put-in-tag "blockquote" contents))

  (defun ox-s9y-section (_section contents _info)
    "Transcode a SECTION element from Org to Serendipity.
CONTENTS is the contents of the section, as a string.  INFO is a
  plist used as a communication channel."
    (org-trim contents))

  (defun ox-s9y-strike-through (_strike-through contents _info)
    "Transcode a STRIKE-THROUGH element from Org to Serendipity.
CONTENTS is the text with strike-through markup, as a string.
  INFO is a plist used as a communication channel."
    (ox-s9y--put-in-tag "s" contents))

  (defun ox-s9y-template (contents _info)
    "Return complete document string after Serendipity conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
    contents)

  (defun ox-s9y-underline (_underline contents _info)
    "Transcode a UNDERLINE element from Org to Serendipity.
CONTENTS is the underlined text, as a string.  INFO is
  a plist used as a communication channel."
    (ox-s9y--put-in-tag "u" contents))

  (defun ox-s9y-verbatim (verbatim _contents _info)
    "Transcode a VERBATIM element from Org to Serendipity.
CONTENTS is nil.  INFO is a plist used as a communication channel."
    (ox-s9y--put-in-tag "code" (ox-s9y--quote-html (org-element-property :value verbatim))))

;;; Export methods

;;;###autoload
  (defun ox-s9y-export-as-html
      (&optional async subtreep visible-only body-only ext-plist)
    "Export current buffer to a Serendipity HTML buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

TODO: document BODY-ONLY

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Export is done in a buffer named \"*Org S9Y Export*\"."
    (interactive)
    (org-export-to-buffer 's9y "*Org S9Y Export*"
      async subtreep visible-only body-only ext-plist
      (lambda () (html-mode))))

;;;###autoload
  (defun ox-s9y-export-to-html
      (&optional async subtreep visible-only body-only ext-plist)
    "Export current buffer to a Serendipity HTML file.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

TODO: document BODY-ONLY

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Return output file's name."
    (interactive)
    (let* ((extension (concat "." (or (plist-get ext-plist :html-extension)
				      org-html-extension
				      "html")))
	   (file (org-export-output-file-name extension subtreep))
	   (org-export-coding-system org-html-coding-system))
      (org-export-to-file 's9y file
	async subtreep visible-only body-only ext-plist)))

;;;###autoload
  (defun ox-s9y-export-to-kill-ring
      (&optional async subtreep visible-only body-only ext-plist)
    "Export current buffer as Serendipity HTML to buffer and kill ring.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

TODO: document BODY-ONLY

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Export is done in a buffer named \"*Org S9Y Export*\" which is
automatically copied to the kill ring (Clipboard)."
    (interactive)
    (let ((oldval org-export-copy-to-kill-ring))
      (progn
	(setq org-export-copy-to-kill-ring t)
	(org-export-to-buffer 's9y "*Org S9Y Export*"
	  async subtreep visible-only body-only ext-plist
	  (lambda () (html-mode)))
	(setq org-export-copy-to-kill-ring oldval)))))

;;; Register file

(provide 'ox-s9y)

;;; ox-s9y.el ends here
