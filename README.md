# Link-sass Extension For Quarto

Makes theme SASS variables available in a document as pandoc attributes.

### Installing

```bash
quarto add andrewpbray/link-sass
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

### Using

Activate the filter by adding to your document YAML

```yaml
---
filters:
  - link-sass
---
```
Then pass the SASS variables defined in your scss file as pandoc style attributes.
```
# For a block

:::{style="color: $my-green"}
Here is a paragraph.
:::

# For a span

Here is a [paragraph]{style="color: $my-green"}.
```

While the main use case is passing HTML style attributes, it should be possible to store anything that could be useful to pass as a pandoc attribute as a SASS variable in an scss file.

### The problem

When working in the HTML format, it is helpful to store top-level aesthetic attributes (e.g. colors) as SASS variables. These variables become accessible to CSS rules.

```css
/*-- scss:defaults --*/
$my-green: #4CBB17 !default;
$my-success-color: $my-green !default;
$my-text-color: $my-success-color !default;

/*-- scss:rules --*/
.highlight-word{
  color: $my-success-color;
  background-color: lighten($my-success-color, 20%);
}
```

Document authors can call on these rules by adding an effected class or id to a document element through pandoc classes and ids.

```markdown
This is [fun]{.highlight-word}. 
```

It does not work, however, to pass to an element the name of the variable directly as a pandoc attribute.

```markdown
This is [fun]{.highlight-word}. [This]{style="color: $my-success-color"}, however, is not.
```

### Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

