;;; test-ox-s9y.el --- Tests Serendipity HTML Back-End for Org Export Engine -*- lexical-binding: t; -*-

;; Copyright (C) 2017-2021  Christian Garbs <mitch@cgarbs.de>
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

;;; Commentary:

;; Tests for ox-s9y.

;;; Code:

(require 'ox-s9y)

;;;;;
;;;;; helper functions
;;;;;

(defun test-org-s9y-verbatim-regression ()
  "Return t if verbatim blocks generate an extra newline.
This is a possible regression in Org introduced with 7d9e4da447
which was released with Org 9.1.14.  See
https://lists.gnu.org/archive/html/emacs-orgmode/2021-01/msg00338.html
for details."
  (not (version< (org-release) "9.1.14")))

(defun test-org-s9y-export (input)
  "Transform INPUT to Serendipity HTML and return the result."
  (with-temp-buffer
    (org-mode)
    (insert input)
    (org-s9y-export-as-html)
    (with-current-buffer "*Org S9Y Export*"
      (buffer-substring-no-properties (point-min) (point-max)))))

;;;;;
;;;;; tests of internal methods
;;;;;

;;; org-s9y--put-in-tag

(ert-deftest org-s9y/put-in-tag/no-attribute ()
  (should (equal (org-s9y--put-in-tag "p" "foo")
		 "<p>foo</p>")))

(ert-deftest org-s9y/put-in-tag/single-attribute ()
  (should (equal (org-s9y--put-in-tag "a" "foo" '(("href" "file.htm")))
		 "<a href=\"file.htm\">foo</a>")))

(ert-deftest org-s9y/put-in-tag/multiple-attributes ()
  (should (equal (org-s9y--put-in-tag "div" "foo" '(("class" "bar") ("style" "margin: 0;")))
		 "<div class=\"bar\" style=\"margin: 0;\">foo</div>")))

;;; org-s9y--put-a-href

(ert-deftest org-s9y/put-a-href/plain ()
  (should (equal (org-s9y--put-a-href "some text" "https://example.com/")
		 "<a href=\"https://example.com/\">some text</a>")))

(ert-deftest org-s9y/put-a-href/anchor ()
  (should (equal (org-s9y--put-a-href "anchor text" "#anchor")
		 "<a href=\"#anchor\">anchor text</a>")))

(ert-deftest org-s9y/put-a-href/encode-url-only-once ()
  (should (equal (org-s9y--put-a-href "baz" "http://foo/%20bar")
		 "<a href=\"http://foo/%20bar\">baz</a>")))

(ert-deftest org-s9y/put-a-href/with-class ()
  (should (equal (org-s9y--put-a-href "some text" "https://example.com/" "myclass")
		 "<a href=\"https://example.com/\" class=\"myclass\">some text</a>")))

(ert-deftest org-s9y/put-a-href/with-id ()
  (should (equal (org-s9y--put-a-href "some text" "https://example.com/" "myclass" "myid")
		 "<a href=\"https://example.com/\" class=\"myclass\" id=\"myid\">some text</a>")))

;;; org-s9y--quote-html

(ert-deftest org-s9y/quote-html/plain-text ()
  (should (equal (org-s9y--quote-html "hello world")
		 "hello world")))

(ert-deftest org-s9y/quote-html/tag ()
  (should (equal (org-s9y--quote-html "<a>")
		 "&lt;a&gt;")))

(ert-deftest org-s9y/quote-html/amp ()
  (should (equal (org-s9y--quote-html "me&you")
		 "me&amp;you")))

(ert-deftest org-s9y/quote-html/quot ()
  (should (equal (org-s9y--quote-html "$a=\"foo\";")
		 "$a=&quot;foo&quot;;")))

(ert-deftest org-s9y/quote-html/mixed ()
  (should (equal (org-s9y--quote-html "<a href=\"/rest/api?count=10&skip=30\">more</a>")
		 "&lt;a href=&quot;/rest/api?count=10&amp;skip=30&quot;&gt;more&lt;/a&gt;")))

;;; org-s9y--remove-leading-newline

(ert-deftest org-s9y/remove-leading-newline/remove ()
  (should (equal( org-s9y--remove-leading-newline "\nsome text")
		"some text")))

(ert-deftest org-s9y/remove-leading-newline/keep-text-before-first-newline ()
  (should (equal( org-s9y--remove-leading-newline "no empty line\nsome more text\n")
		"no empty line\nsome more text\n")))

(ert-deftest org-s9y/remove-leading-newline/only-remove-first-newline ()
  (should (equal( org-s9y--remove-leading-newline "\n\nsome text")
		"\nsome text")))

(ert-deftest org-s9y/remove-leading-newline/keep-newlines-within ()
  (should (equal( org-s9y--remove-leading-newline "\nline 1\nline 2")
		"line 1\nline 2")))

(ert-deftest org-s9y/remove-leading-newline/dont-fail-with-no-newline ()
  (should (equal( org-s9y--remove-leading-newline "some text")
		"some text")))

;;; org-s9y--remove-trailing-newline

(ert-deftest org-s9y/remove-trailing-newline/remove ()
  (should (equal( org-s9y--remove-trailing-newline "some text\n")
		"some text")))

(ert-deftest org-s9y/remove-trailing-newline/keep-text-after-last-newline ()
  (should (equal( org-s9y--remove-trailing-newline "some text\nno empty line")
		"some text\nno empty line")))

(ert-deftest org-s9y/remove-trailing-newline/only-remove-last-newline ()
  (should (equal( org-s9y--remove-trailing-newline "some text\n\n")
		"some text\n")))

(ert-deftest org-s9y/remove-trailing-newline/keep-newlines-within ()
  (should (equal( org-s9y--remove-trailing-newline "line 1\nline 2\n")
		"line 1\nline 2")))

(ert-deftest org-s9y/remove-trailing-newline/dont-fail-with-no-newline ()
  (should (equal( org-s9y--remove-trailing-newline "some text")
		"some text")))

;;; org- org-s9y--map-to-geshi-language

(ert-deftest org-s9y/map-to-geshi-language/unchanged ()
  (should (equal( org-s9y--map-to-geshi-language "java")
		"java")))

(ert-deftest org-s9y/map-to-geshi-language/changed ()
  (should (equal( org-s9y--map-to-geshi-language "elisp")
		"lisp")))

(ert-deftest org-s9y/map-to-geshi-language/nil ()
  (should (equal( org-s9y--map-to-geshi-language nil)
		"plaintext")))

(ert-deftest org-s9y/map-to-geshi-language/empty ()
  (should (equal( org-s9y--map-to-geshi-language "")
		"plaintext")))

;;;;;
;;;;; whole-file export tests
;;;;;

(ert-deftest org-s9y/export-bold ()
  (should (equal (test-org-s9y-export "foo *BAR* baz
")
		 "<p>foo <strong>BAR</strong> baz</p>
")))

(ert-deftest org-s9y/export-code-html-entities ()
  (should (equal (test-org-s9y-export "HTML ~</a href=\"bar\">~

C ~#define and(a,b) a&b~
")
		 "<p>HTML <code>&lt;/a href=&quot;bar&quot;&gt;</code></p>

<p>C <code>#define and(a,b) a&amp;b</code></p>
")))

(ert-deftest org-s9y/export-code-plain ()
  (should (equal (test-org-s9y-export "foo ~BAR~ baz
")
		 "<p>foo <code>BAR</code> baz</p>
")))

(ert-deftest org-s9y/export-details-complex ()
  (should (equal (test-org-s9y-export "introduction paragraph

* plain *bold* /italic/ _underline_ +strike+                        :details:
paragraph =one=

#+BEGIN_SRC shell
#!/bin/sh
echo formatted code
#+END_SRC

paragraph =two=
* END                                                               :details:

footer paragraph
")
		 "<p>introduction paragraph</p>

<details>
<summary>plain <strong>bold</strong> <em>italic</em> <u>underline</u> <s>strike</s></summary>
<p>paragraph <code>one</code></p>

[geshi lang=bash]#!/bin/sh
echo formatted code[/geshi]

<p>paragraph <code>two</code></p>
</details>
<p>footer paragraph</p>
")))

(ert-deftest org-s9y/export-details-nested ()
  (should (equal (test-org-s9y-export "preface

* outer                                                             :details:

text 1

** inner                                                            :details:
*inner* =text=
** END                                                              :details:

text 2

* END                                                               :details:

footer
")
		 "<p>preface</p>

<details>
<summary>outer</summary>
<p>text 1</p>

<details>
<summary>inner</summary>
<p><strong>inner</strong> <code>text</code></p>
</details>
<p>text 2</p>
</details>

<p>footer</p>
")))

(ert-deftest org-s9y/export-details-plain ()
  (should (equal (test-org-s9y-export "* title                                                             :details:
content
")
		 "<details>
<summary>title</summary>
<p>content</p>
</details>
")))

(ert-deftest org-s9y/export-entity ()
  (should (equal (test-org-s9y-export "This is *bold* and this is in \\ast{}asterisks\\ast{}.
")
		 "<p>This is <strong>bold</strong> and this is in &lowast;asterisks&lowast;.</p>
")))

(ert-deftest org-s9y/export-fixed-width ()
  (should (equal (test-org-s9y-export "paragraph 1

: verbatim line
:   indented verbatim line

paragraph 2")
		 (if (test-org-s9y-verbatim-regression)
		     "<p>paragraph 1</p>

[geshi lang=plaintext]verbatim line
  indented verbatim line[/geshi]


<p>paragraph 2</p>
"
		   "<p>paragraph 1</p>

[geshi lang=plaintext]verbatim line
  indented verbatim line[/geshi]

<p>paragraph 2</p>
"))))

(ert-deftest org-s9y/export-footnote-concat ()
  (should (equal (test-org-s9y-export "# multiple footnotes at the same location are delimited by \", \"
foo[fn:1][fn:2]

* Footnotes

[fn:1] foo
[fn:2] bar
")
		 "<p>foo<sup><a href=\"#fn-to-1\" class=\"footnote\" id=\"fn-from-1\">[1]</a></sup><sup>, </sup><sup><a href=\"#fn-to-2\" class=\"footnote\" id=\"fn-from-2\">[2]</a></sup></p>
<div id=\"footnotes\"><div class=\"footnote\" id=\"fn-to-1\"><a href=\"#fn-from-1\">[1]</a>: foo</div>
<div class=\"footnote\" id=\"fn-to-2\"><a href=\"#fn-from-2\">[2]</a>: bar</div></div>")))

(ert-deftest org-s9y/export-footnote-id-on-first ()
  (should (equal (test-org-s9y-export "# only the first reference of a footnote gets the <a id=\"…\"> backlink.
foo[fn:1]bar[fn:1]
* Footnotes

[fn:1] foo

")
		 "<p>foo<sup><a href=\"#fn-to-1\" class=\"footnote\" id=\"fn-from-1\">[1]</a></sup>bar<sup><a href=\"#fn-to-1\" class=\"footnote\">[1]</a></sup></p>
<div id=\"footnotes\"><div class=\"footnote\" id=\"fn-to-1\"><a href=\"#fn-from-1\">[1]</a>: foo</div></div>")))

(ert-deftest org-s9y/export-footnote-multiple ()
  (should (equal (test-org-s9y-export "foo[fn:1] bar[fn:2]
* Footnotes

[fn:1] foo
[fn:2] bar
")
		 "<p>foo<sup><a href=\"#fn-to-1\" class=\"footnote\" id=\"fn-from-1\">[1]</a></sup> bar<sup><a href=\"#fn-to-2\" class=\"footnote\" id=\"fn-from-2\">[2]</a></sup></p>
<div id=\"footnotes\"><div class=\"footnote\" id=\"fn-to-1\"><a href=\"#fn-from-1\">[1]</a>: foo</div>
<div class=\"footnote\" id=\"fn-to-2\"><a href=\"#fn-from-2\">[2]</a>: bar</div></div>")))

(ert-deftest org-s9y/export-footnote-plain ()
  (should (equal (test-org-s9y-export "bar[fn:1]
* Footnotes

[fn:1] foo
")
		 "<p>bar<sup><a href=\"#fn-to-1\" class=\"footnote\" id=\"fn-from-1\">[1]</a></sup></p>
<div id=\"footnotes\"><div class=\"footnote\" id=\"fn-to-1\"><a href=\"#fn-from-1\">[1]</a>: foo</div></div>")))

(ert-deftest org-s9y/export-geshi-block-without-language ()
  (should (equal (test-org-s9y-export "#+BEGIN_SRC
package foo;
/* dummy dummy */
#+END_SRC
")
		 "[geshi lang=plaintext]package foo;
/* dummy dummy */[/geshi]
")))

(ert-deftest org-s9y/export-geshi-block ()
  (should (equal (test-org-s9y-export "#+BEGIN_SRC java
package foo;
/* dummy dummy */
#+END_SRC
")
		 "[geshi lang=java]package foo;
/* dummy dummy */[/geshi]
")))

(ert-deftest org-s9y/export-headline-lv1-as-comment ()
  (should (equal (test-org-s9y-export "* TOPIC
")
		 "<!--  TOPIC  -->
")))

(ert-deftest org-s9y/export-headline-lv2-as-comment ()
  (should (equal (test-org-s9y-export "* dummy
** TOPIC
")
		 "<!--  dummy  -->
<!--  TOPIC  -->
")))

(ert-deftest org-s9y/export-headline-lv3-as-h3 ()
  (should (equal (test-org-s9y-export "* dummy
** dummy
*** TOPIC
")
		 "<!--  dummy  -->
<!--  dummy  -->
<h3>TOPIC</h3>
")))

(ert-deftest org-s9y/export-headline-lv4-as-h4 ()
  (should (equal (test-org-s9y-export "* dummy
** dummy
*** dummy
**** TOPIC
")
		 "<!--  dummy  -->
<!--  dummy  -->
<h3>dummy</h3>
<h4>TOPIC</h4>
")))

(ert-deftest org-s9y/export-headline-lv5-as-h5 ()
  (should (equal (test-org-s9y-export "* dummy
** dummy
*** dummy
**** dummy
***** TOPIC
")
		 "<!--  dummy  -->
<!--  dummy  -->
<h3>dummy</h3>
<h4>dummy</h4>
<h5>TOPIC</h5>
")))

(ert-deftest org-s9y/export-italic ()
  (should (equal (test-org-s9y-export "foo /BAR/ baz
")
		 "<p>foo <em>BAR</em> baz</p>
")))

(ert-deftest org-s9y/export-keyword-skip ()
  (should (equal (test-org-s9y-export "#+OPTIONS: ^:nil

nothing special, just this text
")
		 "<p>nothing special, just this text</p>
")))

(ert-deftest org-s9y/export-line-break ()
  (should (equal (test-org-s9y-export "foo\\\\
bar
")
		 "<p>foo<br>
bar</p>
")))

(ert-deftest org-s9y/export-link-about ()
  (should (equal (test-org-s9y-export "[[about:config][bar]]
")
		 "<p><a href=\"about:config\">bar</a></p>
")))

(ert-deftest org-s9y/export-link-encode-url-only-once ()
  (should (equal (test-org-s9y-export "[[http://foo/%20bar][baz]]
")
		 "<p><a href=\"http://foo/%20bar\">baz</a></p>
")))

(ert-deftest org-s9y/export-link-encode-url ()
  (should (equal (test-org-s9y-export "[[http://foo/ bar][baz]]
")
		 "<p><a href=\"http://foo/%20bar\">baz</a></p>
")))

(ert-deftest org-s9y/export-link-http ()
  (should (equal (test-org-s9y-export "[[http://foo/][bar]]
")
		 "<p><a href=\"http://foo/\">bar</a></p>
")))

(ert-deftest org-s9y/export-link-https ()
  (should (equal (test-org-s9y-export "[[https://foo/][bar]]
")
		 "<p><a href=\"https://foo/\">bar</a></p>
")))

(ert-deftest org-s9y/export-link-todo-with-text ()
  (should (equal (test-org-s9y-export "[[todo:Show this text][bar]]
")
		 "<p><abbr title=\"Show this text\">bar</abbr></p>
")))

(ert-deftest org-s9y/export-link-todo-without-text ()
  (should (equal (test-org-s9y-export "[[todo:][bar]]
")
		 "<p><abbr title=\"Artikel folgt\">bar</abbr></p>
")))

(ert-deftest org-s9y/export-multiline-paragraph ()
  (should (equal (test-org-s9y-export "foo
bar
")
		 "<p>foo
bar</p>
")))

(ert-deftest org-s9y/export-multiple-paragraphs ()
  (should (equal (test-org-s9y-export "foo

bar
")
		 "<p>foo</p>

<p>bar</p>
")))

(ert-deftest org-s9y/export-plain-list-descriptive ()
  (should (equal (test-org-s9y-export "- foo :: pokey
- bar :: hokey
")
		 "<dl><dt>foo</dt>
<dd>pokey</dd>
<dt>bar</dt>
<dd>hokey</dd></dl>
")))

(ert-deftest org-s9y/export-plain-list-ordered-start ()
  (should (equal (test-org-s9y-export "1. foo

Hello

2. [@2] bar
3. baz
")
		 "<ol><li>foo</li></ol>

<p>Hello</p>

<ol><li value=\"2\">bar</li>
<li>baz</li></ol>
")))

(ert-deftest org-s9y/export-plain-list-ordered ()
  (should (equal (test-org-s9y-export "1. foo
2. bar
")
		 "<ol><li>foo</li>
<li>bar</li></ol>
")))

(ert-deftest org-s9y/export-plain-list-unordered ()
  (should (equal (test-org-s9y-export "- foo
- bar
")
		 "<ul><li>foo</li>
<li>bar</li></ul>
")))

(ert-deftest org-s9y/export-quote-block ()
  (should (equal (test-org-s9y-export "#+BEGIN_QUOTE
Somebody
said
this.
#+END_QUOTE
")
		 "<blockquote>Somebody
said
this.
</blockquote>
")))

(ert-deftest org-s9y/export-single-paragraph ()
  (should (equal (test-org-s9y-export "foo
")
		 "<p>foo</p>
")))

(ert-deftest org-s9y/export-strike-through ()
  (should (equal (test-org-s9y-export "foo +BAR+ baz
")
		 "<p>foo <s>BAR</s> baz</p>
")))

(ert-deftest org-s9y/export-underline ()
  (should (equal (test-org-s9y-export "foo _BAR_ baz
")
		 "<p>foo <u>BAR</u> baz</p>
")))

(ert-deftest org-s9y/export-verbatim-html-entities ()
  (should (equal (test-org-s9y-export "HTML special characters =<>\"&=
")
		 "<p>HTML special characters <code>&lt;&gt;&quot;&amp;</code></p>
")))

(ert-deftest org-s9y/export-verbatim-plain ()
  (should (equal (test-org-s9y-export "foo =BAR= baz
")
		 "<p>foo <code>BAR</code> baz</p>
")))

;;; Register file

(provide 'test-ox-s9y)

;;; test-ox-s9y.el ends here
