local M = {}

local defaults = {
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

  -- filetype specific options
  -- any options that are passed here will override the default config
  -- for instance, setting use_absolute_path = true for markdown will
  -- only enable that for this particular filetype
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

  files = {}, -- file specific options (e.g. "main.md" or "/path/to/main.md")
  dirs = {}, -- dir specific options (e.g. "project" or "/home/hakon/project")
  custom = {}, -- custom options enabled with the trigger option
}

defaults.filetypes.plaintex = defaults.filetypes.tex
defaults.filetypes.rmd = defaults.filetypes.markdown
defaults.filetypes.md = defaults.filetypes.markdown

local function sort_config()
  local function sort_keys(tbl)
    local sorted_keys = {}

    for key in pairs(tbl) do
      table.insert(sorted_keys, key)
    end

    table.sort(sorted_keys, function(a, b)
      return #a > #b
    end)

    return sorted_keys
  end

  M.opts["sorted_files"] = sort_keys(M.opts["files"])
  M.opts["sorted_dirs"] = sort_keys(M.opts["dirs"])
end

---Recursively gets the value of the option (e.g. "default.debug")
---@param key string
---@param opts table
---@return string | nil
local function recursive_get_opt(key, opts)
  local keys = vim.split(key, ".", { plain = true, trimempty = true })

  for _, k in pairs(keys) do
    if opts and opts[k] ~= nil then
      opts = opts[k]
    else
      return nil
    end
  end

  return opts
end

---Gets the value of the option, executing it if it's a function
---@param val any
---@param args? table
---@return string | nil
local function get_val(val, args)
  if val == nil then
    return nil
  else
    return type(val) == "function" and val(args or {}) or val
  end
end

---Gets the option from the custom table
---@param key string
---@param args table
---@return string | nil
local function get_custom_opt(key, args)
  if M.opts["custom"] == nil then
    return nil
  end

  for _, config_opts in ipairs(M.opts["custom"]) do
    if config_opts["trigger"] and get_val(config_opts["trigger"]) then
      local original_opts = M.opts
      M.opts = config_opts
      local val = M.get_opt(key, {}, args)
      M.opts = original_opts
      return val
    end
  end
end

---Gets the option from the files table
---@param key string
---@param args table
---@return string | nil
local function get_file_opt(key, args, file)
  if M.opts["files"] == nil then
    return nil
  end

  local function file_matches(f1, f2)
    return string.sub(f1:lower(), -#f2:lower()) == f2:lower()
  end

  for _, config_file in ipairs(M.opts["sorted_files"]) do
    if file_matches(file, config_file) or file_matches(file, vim.fn.resolve(vim.fn.expand(config_file))) then
      local config_file_opts = M.opts["files"][config_file]
      local original_opts = M.opts
      M.opts = config_file_opts
      local val = M.get_opt(key, {}, args)
      M.opts = original_opts
      return val
    end
  end

  return nil
end

---Gets the option from the dirs table
---@param key string
---@param args table
---@return string | nil
local function get_dir_opt(key, args, dir)
  if M.opts["dirs"] == nil then
    return nil
  end

  local function dir_matches(d1, d2)
    return string.find(d1:lower(), d2:lower(), 1, true)
  end

  for _, config_dir in ipairs(M.opts["sorted_dirs"]) do
    if dir_matches(dir, config_dir) or dir_matches(dir, vim.fn.resolve(vim.fn.expand(config_dir))) then
      local config_dir_opts = M.opts["dirs"][config_dir]
      local original_opts = M.opts
      M.opts = config_dir_opts
      local val = M.get_opt(key, {}, args)
      M.opts = original_opts
      return val
    end
  end

  return nil
end

---Gets the option from the filetypes table
---@param key string
---@return string | nil
local function get_filetype_opt(key, ft)
  return recursive_get_opt("filetypes." .. ft .. "." .. key, M.opts)
end

---Gets the option from the default table
---@param key string
---@return string | nil
local function get_default_opt(key)
  return recursive_get_opt("default." .. key, M.opts)
end

---Gets the option from the main opts table
---@param key string
---@return string | nil
local function get_unscoped_opt(key)
  return recursive_get_opt(key, M.opts)
end

M.opts = {}

---@param key string: The key, may be nested (e.g. "default.debug")
---@param api_opts? table: The opts passed to pasteImage function
---@return string | nil
M.get_opt = function(key, api_opts, args)
  if api_opts and api_opts[key] ~= nil then
    local val = api_opts[key]
    return get_val(val, args)
  end

  local val = get_custom_opt(key, args)
  if val == nil then
    val = get_file_opt(key, args, vim.fn.expand("%:p"))
  end
  if val == nil then
    val = get_dir_opt(key, args, vim.fn.expand("%:p:h"))
  end
  if val == nil then
    val = get_filetype_opt(key, vim.bo.filetype)
  end
  if val == nil then
    val = get_default_opt(key)
  end
  if val == nil then
    val = get_unscoped_opt(key)
  end

  return get_val(val, args)
end

function M.setup(config_opts)
  M.opts = vim.tbl_deep_extend("force", {}, defaults, config_opts or {})
  sort_config()
end

return M
