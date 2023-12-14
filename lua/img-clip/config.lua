local M = {}

local defaults = {
  default = {
    debug = false, -- enable debug mode
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

    template = "$FILE_PATH",

    drag_and_drop = {
      enabled = true,
      insert_mode = false,
      copy_images = false,
      download_images = true,
    },
  },

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

  local function extract_option(table, nested_key)
    local keys = vim.split(nested_key, ".", { plain = true, trimempty = true })
    for _, k in ipairs(keys) do
      if table and table[k] ~= nil then
        table = table[k] -- navigate into the nested structure
      else
        return nil -- option not found in this table
      end
    end
    return table
  end

  -- check options passed explicitly to pasteImage function
  if opts and opts[key] ~= nil then
    val = opts[key]

  -- check for filetype-specific option, including nested ones
  elseif M.options[ft] then
    val = extract_option(M.options[ft], key)
    if val == nil then
      -- fallback to default if not found in filetype-specific options
      val = extract_option(M.options["default"], key)
    end

  -- check for global option, including nested ones
  elseif M.options["default"] then
    val = extract_option(M.options["default"], key)
  end

  -- return nil if no option found
  if val == nil then
    vim.notify("No option found for " .. key .. ".", vim.log.levels.WARN, { title = "img-clip" })
    return nil
  end

  return type(val) == "function" and val() or val -- execute if it's a function and return its result, otherwise return the value
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

M.setup()

return M
