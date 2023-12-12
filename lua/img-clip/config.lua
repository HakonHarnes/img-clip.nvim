local M = {}

local defaults = {
  dir_path = "assets", -- directory path to save images to, can be relative (cwd or current file) or absolute
  file_name = "%Y-%m-%d-%H-%M-%S", -- file name format (see lua.org/pil/22.1.html)
  url_encode_path = false, -- encode spaces and special characters in file path
  use_absolute_path = false, -- expands dir_path to an absolute path
  relative_to_current_file = false, -- make dir_path relative to current file rather than the cwd
  prompt_for_file_name = true, -- ask user for file name before saving, leave empty to use default
  show_dir_path_in_prompt = false, -- show dir_path in prompt when prompting for file name
  use_cursor_in_template = true, -- jump to cursor position in template after pasting
  insert_mode_after_paste = true, -- enter insert mode after pasting the markup code
  embed_image_as_base64 = false, -- paste image as base64 string instead of saving to file
  max_base64_size = 10, -- max size of base64 string in KB

  -- drag and drop options
  enable_drag_and_drop = true, -- enable drag and drop support
  enable_in_insert_mode = false, -- enable drag and drop support in insert mode
  download_dropped_images = true, -- download image from url instead of just embedding the url
  copy_dropped_images = false, -- copy dropped images to dir_path instead of just including the original path

  template = "$FILE_PATH",

  markdown = {
    url_encode_path = true,
    download_dropped_images = false, -- just include the link to the image
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
}

defaults.plaintex = defaults.tex
defaults.rmd = defaults.markdown

M.options = {}

---@param key string
---@param opts? table The options passed to pasteImage function
---@return string | nil
M.get_option = function(key, opts)
  local ft = vim.bo.filetype
  local val

  -- check options passed explicitly to pasteImage function
  if opts and opts[key] ~= nil then
    val = opts[key]

  -- otherwise chck for filetype-specific option
  elseif M.options[ft] and M.options[ft][key] ~= nil then
    val = M.options[ft][key]

  -- otherwise check for global option
  elseif M.options[key] ~= nil then
    val = M.options[key]

  -- return nil if no option found
  else
    vim.notify("No option found for " .. key .. ".", vim.log.levels.WARN, { title = "img-clip" })
    return nil
  end

  if type(val) == "function" then
    return val() -- execute the function and return its result
  else
    return val
  end
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

M.setup()

return M
