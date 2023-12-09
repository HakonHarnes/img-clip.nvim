# 📸 img-clip.nvim

Paste images directly from your clipboard into any markup language, like LaTeX, Markdown or Typst.

![gif of plugin](https://github.com/HakonHarnes/img-clip.nvim/assets/89907156/c1d2a46e-7212-4049-931c-bb77eb753592)

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

> ⚠️ Run `checkhealth img-clip` after installation. to ensure requirements are satisfied

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
  dir_path = "assets", -- directory path to save images to, can be relative (cwd) or absolute
  file_name = "%Y-%m-%d-%H-%M-%S", -- file name format (see lua.org/pil/22.1.html)
  use_absolute_path = false, -- expands dir_path to absolute path
  prompt_for_file_name = true, -- ask user for file name before saving, leave empty to use default
  show_dir_path_in_prompt = false, -- show dir_path in prompt when prompting for file name
  insert_mode_after_paste = true, -- enter insert mode after pasting the markup code
  respect_cursor_placment_in_template = true, -- jump to cursor position in template after pasting

  -- default template when filetype-specific template is not defined
  template = "$FILE_PATH",

  -- markdown specific options
  markdown = {
    -- any opt can be passed here to override the global config
    -- e.g. insert_mode_after_paste = false,
    template = "![$CURSOR]($FILE_PATH)",
  },

  -- html specific options
  html = {
    template = '<img src="$FILE_PATH" alt="$CURSOR">',
  },

  -- latex specific options
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

  -- typst specific options
  typst = {
    template = [[
#figure(
  image("$FILE_PATH", width: 80%),
  caption: [$CURSOR],
) <fig-$LABEL>
    ]],
  },
}
```

The options can be static values (e.g. "assets"), or be dynamically generated using functions. For instance, to set the `dir_path` to be relative to the current file (rather than the current working directory):

```lua
dir_path = function()
  return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h") .. "/assets"
end
```

The options can also be scoped to specific file types. In the default configuration the templates for the `markdown`, `html`, `tex` and `typst` files override the template defined in the global settings. Any option can be added under the specific file type, not just the template. For instance, if you only want to use absolute file paths for LaTeX, then:

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

| **Placeholder**     | **Description**                                                                                              | **Example**                        |
| ------------------- | ------------------------------------------------------------------------------------------------------------ | ---------------------------------- |
| `$FILE_NAME`        | File name, including its extension.                                                                          | `image.png`                        |
| `$FILE_NAME_NO_EXT` | File name, excluding its extension.                                                                          | `image`                            |
| `$FILE_PATH`        | File path.                                                                                                   | `/path/to/image.png`               |
| `$LABEL`            | Figure label, generated from the file name, converted to lower-case and with spaces replaced by dashes.      | `the-image` (from `the image.png`) |
| `$CURSOR`           | Indicates where the cursor will be placed after insertion if `respect_cursor_placement_in_template` is true. | -                                  |

## Usage

> 💡 Consider binding `PasteImage` to something like `<leader>p`.

The plugin comes with the following commands:

- `PasteImage`: Inserts the image from the clipboard into the document.

You can also use the Lua equivalent, which allows you to override your configuration by passing the options directly to the function:

```lua
require("img-clip").pasteImage({ use_absolute_path = false, file_name = "image.png" })
```
