- [basic formatting](#org93578b3)
- [headlines](#org68cb935)
  - [input](#org489f867)
  - [output](#org7795bda)
- [source code blocks](#org3ca4ed7)
  - [input](#org1835d7c)
  - [output](#orgdcd3431)
- [foldable `<details>` blocks](#org5f39f6e)
  - [input](#orgcfd2374)
  - [output](#org2331ad7)
- [block quotes](#org4e80bec)
  - [input](#org346b677)
  - [output](#org6825e6b)
- [entities](#orgb908729)
  - [input](#org87f3ffb)
  - [output](#org4f152f9)
- [dangling links](#orgc44e319)
  - [input](#org51acf8c)
  - [output](#org7a049c5)



<a id="org93578b3"></a>

# basic formatting

Most normal Org formatting like **bold** `code` *italic* ~~striketrough~~ <span class="underline">underline</span> as well as sections and headlines should work out of the box.

Unimplemented element types should throw an error pointing to their missing implementation.


<a id="org68cb935"></a>

# headlines

Because Serendipity uses the first two headline levels for itself (title of blog and title of article), the blog entry can only use level three and lower headlines for subsections.

I usually simply use `* blog` as the first level headline and the article title on the second level. Both headlines are exported as an HTML comment so I can copy the article title over to the title text field in the Serendipity editor.


<a id="org489f867"></a>

## input

```org
* dummy
** dummy
*** dummy
**** TOPIC
```


<a id="org7795bda"></a>

## output

```html
<!--  dummy  -->
<!--  dummy  -->
<h3>dummy</h3>
<h4>TOPIC</h4>
```


<a id="org3ca4ed7"></a>

# source code blocks

Source code using `#+BEGIN_SRC` / `#+END_SRC` will be rendered as a `[geshi]` code block.

The source language will be copied to the geshi tag. Some mappings are needed, see `(org-s9y--map-to-geshi-language)` and expand accordingly if you miss anything.


<a id="org1835d7c"></a>

## input

```org
#+BEGIN_SRC java
package foo;
/* dummy dummy */
#+END_SRC
```


<a id="orgdcd3431"></a>

## output

```html
[geshi lang=java]package foo;
/* dummy dummy */[/geshi]
```


<a id="org5f39f6e"></a>

# foldable `<details>` blocks

Use a headline tagged with `:details:` to generate a foldable HTML `<details>` block. The `<details>` is closed by default. The headline title will be used as a `<summary>` and can contain markup.

`<details>` blocks may be nested.

The `<details>` block will end at the next headline of the same or higher level. To end the block early, insert a special headline with the title `END` (also tagged as `:details:`). While this will end the `<details>` block, the `END` headline will not show up in the output.


<a id="orgcfd2374"></a>

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


<a id="org2331ad7"></a>

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


<a id="org4e80bec"></a>

# block quotes

Quote blocks using `#+BEGIN_QUOTE` / `#+END_QUOTE` will be rendered as an HTML `<blockquote>` tag.


<a id="org346b677"></a>

## input

```org
#+BEGIN_QUOTE
Somebody
said
this.
#+END_QUOTE
```


<a id="org6825e6b"></a>

## output

```html
<blockquote>Somebody
said
this.
</blockquote>
```


<a id="orgb908729"></a>

# entities

Use `\ast{}` to export verbatim asterisks when `*` would activate bold formatting.

Other [Org entities](https://orgmode.org/manual/Special-Symbols.html) should also work.


<a id="org87f3ffb"></a>

## input

```org
This is *bold* and this is in \ast{}asterisks\ast{}.
```


<a id="org4f152f9"></a>

## output

```html
<p>This is <strong>bold</strong> and this is in &lowast;asterisks&lowast;.</p>
```


<a id="orgc44e319"></a>

# dangling links

To refer to a future blog article that has not yet been written, add a link with `todo:some text` as the link target. This will generate an `<abbr>` tag showing the given text as a hover text instead of a regular `<a>` link.

If you leave out `some text` and just use `todo:` as a link target, a default text will be supplied. This text can be customized via `M-x customize-variable org-s9y-todo-link-title`.


<a id="org51acf8c"></a>

## input

```org
[[todo:Show this text][bar]]
```


<a id="org7a049c5"></a>

## output

```html
<p><abbr title="Show this text">bar</abbr></p>
```
