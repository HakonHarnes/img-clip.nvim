# 📸 img-clip.nvim

Effortlessly embed images into any markup language, like LaTeX, Markdown or Typst.

![demo](https://github.com/HakonHarnes/img-clip.nvim/assets/89907156/db364ae2-f966-43d2-8f15-34654e03e0f4)

## Features

- Paste images directly from the system clipboard.
- Drag and drop images from your web browser or file explorer to embed them.
- Embed images as files, URLs, or directly as Base64.
- Configurable templates with cursor positioning and figure labels.
- Default templates for widely-used markup languages like LaTeX, Markdown and Typst.
- Cross-compatibility with Linux, Windows, and MacOS.

See these features in action in the [demonstration section](#demonstration)!

## Requirements

- **Linux:** [xclip](https://github.com/astrand/xclip) (x11) or [wl-clipboard](https://github.com/bugaevc/wl-clipboard) (wayland).
- **MacOS:** [pngpaste](https://github.com/jcsalterego/pngpaste) (optional, but recommended).
- **Windows:** No requirements.

> ⚠️ Run `:checkhealth img-clip` after installation to ensure requirements are satisfied.

## Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  "HakonHarnes/img-clip.nvim",
  event = "BufEnter",
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

## Usage

### Commands

The plugin comes with the following commands:

- `PasteImage` Inserts the image from the clipboard into the document.

Consider binding `PasteImage` to something like `<leader>p`.

### API

You can also use the Lua equivalent, which allows you to override your configuration by passing the options directly to the function:

```lua
require("img-clip").pasteImage({ use_absolute_path = false, file_name = "image.png" })
```

## Configuration

### Setup

The plugin comes with the following defaults:

```lua
{
  default = {
    debug = false, -- enable debug mode
    dir_path = "assets", -- directory path to save images to, can be relative (cwd or current file) or absolute
    file_name = "%Y-%m-%d-%H-%M-%S", -- file name format (see lua.org/pil/22.1.html)
    url_encode_path = false, -- encode spaces and special characters in file path
    use_absolute_path = false, -- expands dir_path to an absolute path
    relative_to_current_file = false, -- make dir_path relative to current file rather than the cwd
    relative_template_path = true, -- make file path in the template relative to current file rather than the cwd
    prompt_for_file_name = true, -- ask user for file name before saving, leave empty to use default
    show_dir_path_in_prompt = false, -- show dir_path in prompt when prompting for file name
    use_cursor_in_template = true, -- jump to cursor position in template after pasting
    insert_mode_after_paste = true, -- enter insert mode after pasting the markup code
    embed_image_as_base64 = false, -- paste image as base64 string instead of saving to file
    max_base64_size = 10, -- max size of base64 string in KB
    template = "$FILE_PATH", -- default template

    drag_and_drop = {
      enabled = true, -- enable drag and drop mode
      insert_mode = false, -- enable drag and drop in insert mode
      copy_images = false, -- copy images instead of using the original file
      download_images = true, -- download images and save them to dir_path instead of using the URL
    },
  },

  -- file type specific opts
  -- any opts that are passed here will override the default config
  -- for instance, setting use_absolute_path = true for markdown will
  -- only enable that for this particular file type
  -- the key (e.g. "markdown") is the filetype (output of "set filetype?")
  filetypes = {
    markdown = {
      url_encode_path = true,
      template = "![$CURSOR]($FILE_PATH)",

      drag_and_drop = {
        download_images = false,
      },
    },

    html = {
      template = '<img src="$FILE_PATH" alt="$CURSOR">',
    },

    tex = {
      relative_template_path = false,
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
  },

  -- override opts for specific files, dirs or custom triggers
  files = {}, -- file specific opts (e.g. "main.md" or "/path/to/main.md")
  dirs = {}, -- dir specific opts (e.g. "project" or "/home/hakon/project")
  custom = {}, -- custom opts enabled with the trigger option
}
```

### Options

The options can be configured as either static values (e.g. "assets"), or by dynamically generating them through functions.
For example, to set the `dir_path` to match the name of the currently opened file:

```lua
dir_path = function()
  return vim.fn.expand("%:t:r")
end,
```

### File types

The options can also be scoped to specific file types.
In the default configuration the templates for the `markdown`, `html`, `tex` ..., files override the template defined in the global settings.
Any option can be added under the specific file type, not just the template. For instance, if you only want to use absolute file paths for LaTeX, then:

```lua
filetypes = {
  tex = {
    use_absolute_path = true
  }
}
```

File type-specific options are determined by the _file type_ (see `:help filetype`).
You can override settings for any file type by specifying it as the key in your configuration:

```lua
filetypes = {
  <filetype> = { -- obtained from "set filetype?"
    -- add opts here
  }
}
```

### Overriding options for specific files, directories or custom triggers

Options can be overridden for specific files, directories or based on custom conditions.
This means that you can have different options for different projects, or even different files within the same project.

For files and directories, you can specify settings that apply to only a specific file or directory using its absolute path (e.g. `/home/user/project/README.md`).
You can also specify a general file or directory name (e.g. `README.md`) which will apply the settings to any `README.md` file.
For custom options, you can specify a _trigger_ function that returns a boolean value that is used to enable it.

The plugin evaluates the options in the following order:

1. Custom options
2. File-specific options
3. Directory-specific options
4. File type-specific options
5. Default options

Example configuration:

```lua
-- File-specific opts
files = {
  ["/path/to/specific/file.md"] = {
    template = "Custom template for this file",
  },
  ["README.md"] = {
    template = "Custom template for README.md files",
  },
},

-- directory-specific opts
dirs = {
  ["/path/to/project"] = {
    template = "Project-specific template",
  },
},

-- custom opts
custom = {
  {
    trigger = function() -- returns true to activate
      return vim.fn.strftime("%A") == "Monday"
    end,
    template = "Template for Mondays only",
  },
}
```

The options can be nested arbitrarily deep:

```lua
dirs = {
  ["/home/hakon/markdown"] = {
    template = "template for this project",

    filetypes = { -- filetypes opt nested inside dirs
      markdown = {
        template = "markdown template"
      }
    }

    files = { -- files opt nested inside dirs
      ["readme.md"] = {
        dir_path = "images"
      },
    },
  },
}
```

### Templates

Templates in the plugin use placeholders that are dynamically replaced with the correct values at runtime.
For available placeholders, see the following table and the [demonstration](#demonstration):

| Placeholder         | Description                                                                                             | Example                            |
| ------------------- | ------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `$FILE_NAME`        | File name, including its extension.                                                                     | `image.png`                        |
| `$FILE_NAME_NO_EXT` | File name, excluding its extension.                                                                     | `image`                            |
| `$FILE_PATH`        | File path.                                                                                              | `/path/to/image.png`               |
| `$LABEL`            | Figure label, generated from the file name, converted to lower-case and with spaces replaced by dashes. | `the-image` (from `the image.png`) |
| `$CURSOR`           | Indicates where the cursor will be placed after insertion if `use_cursor_in_template` is true.          |                                    |

Templates can also be defined using functions with the above placeholders available as function parameters:

```lua
template = function(context)
  return "![" .. context.cursor .. "](" .. context.file_path .. ")"
end
```

## Drag and drop

The drag and drop feature enables users to drag images from the web browser or file explorer into the terminal to automatically embed them, in normal mode.
It can be optionally enabled in insert mode using the `drag_and_drop.insert_mode` option.
For drag and drop to work properly, the following is required by the terminal emulator:

1. The terminal emulator must paste the file path or URL to the image when it is dropped into the terminal.
2. The text must be inserted in [bracketed paste mode](https://cirw.in/blog/bracketed-paste), which allows Neovim to differentiate pasted text from typed-in text.
   This is required because the drag and drop feature is implemented by overriding `vim.paste()`.

A list of terminal emulators and their capabilities is given below.

<table>
  <thead>
    <tr>
      <th rowspan="2" style="text-align:center;">Terminal</th>
      <th colspan="2" style="text-align:center;">X11</th>
      <th colspan="2" style="text-align:center;">Wayland</th>
      <th colspan="2" style="text-align:center;">MacOS</th>
      <th colspan="2" style="text-align:center;">Windows</th>
    </tr>
    <tr>
      <th style="text-align:center;">File</th>
      <th style="text-align:center;">URL</th>
      <th style="text-align:center;">File</th>
      <th style="text-align:center;">URL</th>
      <th style="text-align:center;">File</th>
      <th style="text-align:center;">URL</th>
      <th style="text-align:center;">File</th>
      <th style="text-align:center;">URL</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/kovidgoyal/kitty">Kitty</a></td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
    </tr>
    <tr>
      <td><a href="https://github.com/goblinfactory/konsole">Konsole</a></td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">❓️</td>
      <td style="text-align:center;">❓️</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
    </tr>
    <tr>
      <td><a href="https://github.com/alacritty/alacritty">Alacritty</a></td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">❌</td>
    </tr>
    <tr>
      <td><a href="https://github.com/wez/wezterm">Wezterm</a></td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❓️</td>
      <td style="text-align:center;">❓️</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">❌</td>
    </tr>
    <tr>
      <td><a href="https://codeberg.org/dnkl/foot">Foot</a></td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
    </tr>
    <tr>
      <td><a href="https://en.wikipedia.org/wiki/Terminal_(macOS)">Terminal.app</a></td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
    </tr>
    <tr>
      <td><a href="https://iterm2.com/">iTerm.app</a></td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
    </tr>
    <tr>
      <td><a href="https://github.com/vercel/hyper">Hyper</a></td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❓️</td>
      <td style="text-align:center;">❓️</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
    </tr>
    <tr>
      <td><a href="https://en.wikipedia.org/wiki/Xterm">XTerm</a></td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
    </tr>
    <tr>
      <td><a href="https://apps.microsoft.com/detail/9N0DX20HK701">Windows Terminal</a></td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">✅</td>
      <td style="text-align:center;">✅</td>
    </tr>
    <tr>
      <td><a href="https://en.wikipedia.org/wiki/PowerShell">PowerShell</a></td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
    </tr>
    <tr>
      <td><a href="https://github.com/cmderdev/cmder">Cmder</a></td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
    </tr>
    <tr>
      <td><a href="https://github.com/Maximus5/ConEmu">ConEmu</a></td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">➖</td>
      <td style="text-align:center;">❌</td>
      <td style="text-align:center;">❌</td>
    </tr>
  </tbody>
</table>

> 💡 If you're having issues on Windows, try changing the default shell to `powershell` or `pwsh`. See `:h shell-powershell`.

> ⚠️ MacOS URLs only work in Safari.

## Demonstration

### Drag and drop

![drag-and-drop](https://github.com/HakonHarnes/img-clip.nvim/assets/89907156/7ca4543c-e68e-4ec6-b723-46c959833e6e)

### Paste from clipboard

![clipboard-screenshot](https://github.com/HakonHarnes/img-clip.nvim/assets/89907156/6ecbdbf8-b382-434b-ad92-a09776309864)
![clipboard-copy](https://github.com/HakonHarnes/img-clip.nvim/assets/89907156/05c3f0e3-3d73-45d6-a2ad-d8f43a298943)

### Templates

![template](https://github.com/HakonHarnes/img-clip.nvim/assets/89907156/af10a690-cea9-4776-88aa-1f793c1552e6)
![template-image](https://github.com/HakonHarnes/img-clip.nvim/assets/89907156/fd996028-adc0-4706-9340-63ba33f6e252)

### Base64

![base64-encoding](https://github.com/HakonHarnes/img-clip.nvim/assets/89907156/504fc4bd-bb91-456c-b580-2ec8c05e2aea)
