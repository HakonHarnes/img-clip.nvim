# 📸 img-clip.nvim

Paste images directly from your clipboard into any markup language, like LaTeX, Markdown or Typst.

![demo of plugin](assets/demo.gif)

## Features

- **Directly** paste images from the **clipboard**.
- **Automatically** generate file names.
- Fully **configurable templates** with:
  - Cursor placement.
  - Figure labels.
  - File name.
  - File path.
- **Default templates** for widely-used markup languages like LaTeX, Markdown and Typst.
- **Cross-compatibility** with Linux, Windows, and MacOS.

## Requirements

- **Linux:** `xclip` (x11) or `wl-clipboard` (wayland).
- **MacOS:** `pngpaste` (optional, but recommended).
- **Windows:** No requirements.

> ⚠️ Run `:checkhealth img-clip` after installation to ensure requirements are satisfied.

## Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  "HakonHarnes/img-clip.nvim",
  cmd = "PasteImage",
  opts = {
    -- add options here
    -- or leave it empty to use the default settings
  },
  keys = {
    -- suggested keymap
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste clipboard image" },
  },
}
```

## Configuration

### Setup

The plugin comes with the following defaults:

```lua
{
  dir_path = "assets", -- directory path to save images to, can be relative (cwd or current file) or absolute
  file_name = "%Y-%m-%d-%H-%M-%S", -- file name format (see lua.org/pil/22.1.html)
  use_absolute_path = false, -- expands dir_path to an absolute path
  prompt_for_file_name = true, -- ask user for file name before saving, leave empty to use default
  show_dir_path_in_prompt = false, -- show dir_path in prompt when prompting for file name
  use_cursor_in_template = true, -- jump to cursor position in template after pasting
  insert_mode_after_paste = true, -- enter insert mode after pasting the markup code
  relative_to_current_file = false, -- make dir_path relative to current file rather than the cwd

  template = "$FILE_PATH", -- default template

  -- file-type specific options
  -- any options that are passed here will override the global config
  -- for instance, setting use_absolute_path = true for markdown will
  -- only enable that for this particular file type
  -- the key (e.g. "markdown") is the filetype (output of "set filetype?")

  markdown = {
    template = "![$CURSOR]($FILE_PATH)",
  },

  html = {
    template = '<img src="$FILE_PATH" alt="$CURSOR">',
  },

  tex = {
    template = [[
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \caption{$CURSOR}
  \label{fig:$LABEL}
\end{figure}
    ]],
  },

  typst = {
    template = [[
#figure(
  image("$FILE_PATH", width: 80%),
  caption: [$CURSOR],
) <fig-$LABEL>
    ]],
  },

  rst = {
    template = [[
.. image:: $FILE_PATH
   :alt: $CURSOR
   :width: 80%
    ]],
  },

  asciidoc = {
    template = 'image::$FILE_PATH[width=80%, alt="$CURSOR"]',
  },

  org = {
    template = [=[
#+BEGIN_FIGURE
[[file:$FILE_PATH]]
#+CAPTION: $CURSOR
#+NAME: fig:$LABEL
#+END_FIGURE
    ]=],
  },
```

You can configure the options either as static values (e.g. "assets"), or dynamically generate them using functions. For example, if you want to set `dir_path` to match the name of the currently opened file, you can achieve this through:

```lua
dir_path = function()
  return vim.fn.expand("%:t:r")
end,
```

The options can also be scoped to specific file types. In the default configuration the templates for the `markdown`, `html`, `tex` ..., files override the template defined in the global settings. Any option can be added under the specific file type, not just the template. For instance, if you only want to use absolute file paths for LaTeX, then:

```lua
tex = {
  use_absolute_path = true
}
```

File type-specific options are determined by the _filetype_ (see `:help filetype`). You can override settings for any filetype by specifying it as the key in your configuration:

```lua
<filetype> = { -- obtained from "set filetype?"
  -- add opts here
}
```

### Templates

Templates in the plugin use placeholders that are dynamically replaced with specific values during runtime. See the following table:

| **Placeholder**     | **Description**                                                                                         | **Example**                        |
| ------------------- | ------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `$FILE_NAME`        | File name, including its extension.                                                                     | `image.png`                        |
| `$FILE_NAME_NO_EXT` | File name, excluding its extension.                                                                     | `image`                            |
| `$FILE_PATH`        | File path.                                                                                              | `/path/to/image.png`               |
| `$LABEL`            | Figure label, generated from the file name, converted to lower-case and with spaces replaced by dashes. | `the-image` (from `the image.png`) |
| `$CURSOR`           | Indicates where the cursor will be placed after insertion if `use_cursor_in_template` is true.          | -                                  |

## Usage

> 💡 Consider binding `PasteImage` to something like `<leader>p`.

The plugin comes with the following commands:

- `PasteImage`: Inserts the image from the clipboard into the document.

You can also use the Lua equivalent, which allows you to override your configuration by passing the options directly to the function:

```lua
require("img-clip").pasteImage({ use_absolute_path = false, file_name = "image.png" })
```
