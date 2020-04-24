- [basic formatting](#org88ec8b9)
- [source code blocks](#org8f8b4d2)
  - [input](#orge60f84c)
  - [output](#org2bbbc13)
- [foldable `<detail>` blocks](#org3b1e91a)
  - [input](#org04d9a7c)
  - [output](#org42c4ded)
- [block quotes](#org83dc9ca)
  - [input](#orga9e8990)
  - [output](#orgadd8a9c)



<a id="org88ec8b9"></a>

# basic formatting

Most normal Org formatting like **bold** `code` *italic* ~~striketrough~~ <span class="underline">underline</span> as well as sections and headlines should work out of the box.

Unimplemented element types should throw an error pointing to their missing implementation.


<a id="org8f8b4d2"></a>

# source code blocks

Source code using `#+BEGIN_SRC` / `#+END_SRC` will be rendered as a `[geshi]` code block.

The source language will be copied to the geshi tag. Some mappings are needed, see `(org-s9y--map-to-geshi-language)` and expand accordingly if you miss anything.


<a id="orge60f84c"></a>

## input

```org
#+BEGIN_SRC java
package foo;
/* dummy dummy */
#+END_SRC
```


<a id="org2bbbc13"></a>

## output

```html
[geshi lang=java]package foo;
/* dummy dummy */[/geshi]
```


<a id="org3b1e91a"></a>

# foldable `<detail>` blocks

Use a headline tagged with `:detail:` to generate a foldable HTML `<detail>` block. The `<detail>` is closed by default. The headline title will be used as a `<summary>` and can contain markup.

`<detail>` blocks may be nested.

The `<detail>` block will end at the next headline of the same or higher leven. To end the block early, insert a special headline with the title `END` (also tagged as `:detail:`). While this will end the `<detail>` block, the `END` headline will not show up in the output.


<a id="org04d9a7c"></a>

## input

```org
introduction paragraph

* plain *bold* /italic/ _underline_ +strike+                         :detail:
paragraph =one=

#+BEGIN_SRC shell
#!/bin/sh
echo formatted code
#+END_SRC

paragraph =two=
* END :detail:

footer paragraph
```


<a id="org42c4ded"></a>

## output

```html
<p>introduction paragraph</p>

<detail>
<summary>plain <strong>bold</strong> <em>italic</em> <u>underline</u> <s>strike</s></summary>
<p>paragraph <code>one</code></p>

[geshi lang=bash]#!/bin/sh
echo formatted code[/geshi]

<p>paragraph <code>two</code></p>
</detail>
<p>footer paragraph</p>
```


<a id="org83dc9ca"></a>

# block quotes

Quote blocks using `#+BEGIN_QUOTE` / `#+END_QUOTE` will be rendered as an HTML `<blockquote>` tag.


<a id="orga9e8990"></a>

## input

```org
#+BEGIN_QUOTE
Somebody
said
this.
#+END_QUOTE
```


<a id="orgadd8a9c"></a>

## output

```html
<blockquote>Somebody
said
this.
</blockquote>
```
