- [basic formatting](#orgf3787fc)
- [source code blocks](#org34761b3)
  - [input](#orgfb8db79)
  - [output](#org82cc3fe)
- [foldable `<details>` blocks](#orgb3cf537)
  - [input](#org055e369)
  - [output](#org3e334d8)
- [block quotes](#orgd9525be)
  - [input](#orga018df7)
  - [output](#org7e98cbc)



<a id="orgf3787fc"></a>

# basic formatting

Most normal Org formatting like **bold** `code` *italic* ~~striketrough~~ <span class="underline">underline</span> as well as sections and headlines should work out of the box.

Unimplemented element types should throw an error pointing to their missing implementation.


<a id="org34761b3"></a>

# source code blocks

Source code using `#+BEGIN_SRC` / `#+END_SRC` will be rendered as a `[geshi]` code block.

The source language will be copied to the geshi tag. Some mappings are needed, see `(org-s9y--map-to-geshi-language)` and expand accordingly if you miss anything.


<a id="orgfb8db79"></a>

## input

```org
#+BEGIN_SRC java
package foo;
/* dummy dummy */
#+END_SRC
```


<a id="org82cc3fe"></a>

## output

```html
[geshi lang=java]package foo;
/* dummy dummy */[/geshi]
```


<a id="orgb3cf537"></a>

# foldable `<details>` blocks

Use a headline tagged with `:details:` to generate a foldable HTML `<details>` block. The `<details>` is closed by default. The headline title will be used as a `<summary>` and can contain markup.

`<details>` blocks may be nested.

The `<details>` block will end at the next headline of the same or higher level. To end the block early, insert a special headline with the title `END` (also tagged as `:details:`). While this will end the `<details>` block, the `END` headline will not show up in the output.


<a id="org055e369"></a>

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


<a id="org3e334d8"></a>

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


<a id="orgd9525be"></a>

# block quotes

Quote blocks using `#+BEGIN_QUOTE` / `#+END_QUOTE` will be rendered as an HTML `<blockquote>` tag.


<a id="orga018df7"></a>

## input

```org
#+BEGIN_QUOTE
Somebody
said
this.
#+END_QUOTE
```


<a id="org7e98cbc"></a>

## output

```html
<blockquote>Somebody
said
this.
</blockquote>
```
