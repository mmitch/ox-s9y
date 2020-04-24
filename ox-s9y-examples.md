- [basic formatting](#org1113888)
- [source code blocks](#org1e7cb4e)
  - [input](#orgf9379aa)
  - [output](#org832557e)
- [foldable `<details>` blocks](#orgf4f5d89)
  - [input](#org1a2b587)
  - [output](#orgeb38ebf)
- [block quotes](#org7aa5ed4)
  - [input](#org8e5bb50)
  - [output](#orgaf083cd)
- [entities](#orgf42c5b2)
  - [input](#orge21c41f)
  - [output](#org9bb6463)



<a id="org1113888"></a>

# basic formatting

Most normal Org formatting like **bold** `code` *italic* ~~striketrough~~ <span class="underline">underline</span> as well as sections and headlines should work out of the box.

Unimplemented element types should throw an error pointing to their missing implementation.


<a id="org1e7cb4e"></a>

# source code blocks

Source code using `#+BEGIN_SRC` / `#+END_SRC` will be rendered as a `[geshi]` code block.

The source language will be copied to the geshi tag. Some mappings are needed, see `(org-s9y--map-to-geshi-language)` and expand accordingly if you miss anything.


<a id="orgf9379aa"></a>

## input

```org
#+BEGIN_SRC java
package foo;
/* dummy dummy */
#+END_SRC
```


<a id="org832557e"></a>

## output

```html
[geshi lang=java]package foo;
/* dummy dummy */[/geshi]
```


<a id="orgf4f5d89"></a>

# foldable `<details>` blocks

Use a headline tagged with `:details:` to generate a foldable HTML `<details>` block. The `<details>` is closed by default. The headline title will be used as a `<summary>` and can contain markup.

`<details>` blocks may be nested.

The `<details>` block will end at the next headline of the same or higher level. To end the block early, insert a special headline with the title `END` (also tagged as `:details:`). While this will end the `<details>` block, the `END` headline will not show up in the output.


<a id="org1a2b587"></a>

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


<a id="orgeb38ebf"></a>

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


<a id="org7aa5ed4"></a>

# block quotes

Quote blocks using `#+BEGIN_QUOTE` / `#+END_QUOTE` will be rendered as an HTML `<blockquote>` tag.


<a id="org8e5bb50"></a>

## input

```org
#+BEGIN_QUOTE
Somebody
said
this.
#+END_QUOTE
```


<a id="orgaf083cd"></a>

## output

```html
<blockquote>Somebody
said
this.
</blockquote>
```


<a id="orgf42c5b2"></a>

# entities

Use `\ast{}` to export verbatim asterisks when `*` would activate bold formatting.

Other [Org entities](https://orgmode.org/manual/Special-Symbols.html) should also work.


<a id="orge21c41f"></a>

## input

```org
This is *bold* and this is in \ast{}asterisks\ast{}.
```


<a id="org9bb6463"></a>

## output

```html
<p>This is <strong>bold</strong> and this is in &lowast;asterisks&lowast;.</p>
```
