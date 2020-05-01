- [basic formatting](#org6e5e6b1)
- [headlines](#orga4247d9)
  - [input](#org899ec1e)
  - [output](#orgc453e52)
- [source code blocks](#orgc39965f)
  - [input](#org247ace8)
  - [output](#orgc12926f)
- [foldable `<details>` blocks](#orge86027c)
  - [input](#org17fba1d)
  - [output](#org20bbd71)
- [block quotes](#org5c39bd9)
  - [input](#org705fc37)
  - [output](#org312b4fa)
- [entities](#orgd49a55b)
  - [input](#org9eac4ac)
  - [output](#org05f7dbc)



<a id="org6e5e6b1"></a>

# basic formatting

Most normal Org formatting like **bold** `code` *italic* ~~striketrough~~ <span class="underline">underline</span> as well as sections and headlines should work out of the box.

Unimplemented element types should throw an error pointing to their missing implementation.


<a id="orga4247d9"></a>

# headlines

Because Serendipity uses the first two headline levels for itself (title of blog and title of article), the blog entry can only use level three and lower headings for subsections.

I usually simply use `* blog` as a first level headline and the article title as a second level. Both headlines are exported as an HTML comment so I can cut'n'paste the article title over to the title text field in the Serendipity editor.


<a id="org899ec1e"></a>

## input

```org
* dummy
** dummy
*** dummy
**** TOPIC
```


<a id="orgc453e52"></a>

## output

```html
<!--  dummy  -->
<!--  dummy  -->
<h3>dummy</h3>
<h4>TOPIC</h4>
```


<a id="orgc39965f"></a>

# source code blocks

Source code using `#+BEGIN_SRC` / `#+END_SRC` will be rendered as a `[geshi]` code block.

The source language will be copied to the geshi tag. Some mappings are needed, see `(org-s9y--map-to-geshi-language)` and expand accordingly if you miss anything.


<a id="org247ace8"></a>

## input

```org
#+BEGIN_SRC java
package foo;
/* dummy dummy */
#+END_SRC
```


<a id="orgc12926f"></a>

## output

```html
[geshi lang=java]package foo;
/* dummy dummy */[/geshi]
```


<a id="orge86027c"></a>

# foldable `<details>` blocks

Use a headline tagged with `:details:` to generate a foldable HTML `<details>` block. The `<details>` is closed by default. The headline title will be used as a `<summary>` and can contain markup.

`<details>` blocks may be nested.

The `<details>` block will end at the next headline of the same or higher level. To end the block early, insert a special headline with the title `END` (also tagged as `:details:`). While this will end the `<details>` block, the `END` headline will not show up in the output.


<a id="org17fba1d"></a>

## input

```org
introduction paragraph

* plain *bold* /italic/ _underline_ +strike+                        :details:
paragraph =one=

#+BEGIN_SRC shell
#!/bin/sh
echo formatted code
#+END_SRC

paragraph =two=
* END                                                               :details:

footer paragraph
```


<a id="org20bbd71"></a>

## output

```html
<p>introduction paragraph</p>

<details>
<summary>plain <strong>bold</strong> <em>italic</em> <u>underline</u> <s>strike</s></summary>
<p>paragraph <code>one</code></p>

[geshi lang=bash]#!/bin/sh
echo formatted code[/geshi]

<p>paragraph <code>two</code></p>
</details>
<p>footer paragraph</p>
```


<a id="org5c39bd9"></a>

# block quotes

Quote blocks using `#+BEGIN_QUOTE` / `#+END_QUOTE` will be rendered as an HTML `<blockquote>` tag.


<a id="org705fc37"></a>

## input

```org
#+BEGIN_QUOTE
Somebody
said
this.
#+END_QUOTE
```


<a id="org312b4fa"></a>

## output

```html
<blockquote>Somebody
said
this.
</blockquote>
```


<a id="orgd49a55b"></a>

# entities

Use `\ast{}` to export verbatim asterisks when `*` would activate bold formatting.

Other [Org entities](https://orgmode.org/manual/Special-Symbols.html) should also work.


<a id="org9eac4ac"></a>

## input

```org
This is *bold* and this is in \ast{}asterisks\ast{}.
```


<a id="org05f7dbc"></a>

## output

```html
<p>This is <strong>bold</strong> and this is in &lowast;asterisks&lowast;.</p>
```
