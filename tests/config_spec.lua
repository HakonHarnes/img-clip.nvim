local config = require("img-clip.config")

describe("config", function()
  before_each(function()
    vim.bo.filetype = ""
    config.setup({})
    config.configs = {}
  end)

  it("should have default values for all configuration options", function()
    assert.is_false(config.get_opt("debug"))
    assert.equals("assets", config.get_opt("dir_path"))
    assert.equals("%Y-%m-%d-%H-%M-%S", config.get_opt("file_name"))
    assert.is_false(config.get_opt("url_encode_path"))
    assert.is_false(config.get_opt("use_absolute_path"))
    assert.is_false(config.get_opt("relative_to_current_file"))
    assert.is_true(config.get_opt("relative_template_path"))
    assert.is_true(config.get_opt("prompt_for_file_name"))
    assert.is_false(config.get_opt("show_dir_path_in_prompt"))
    assert.is_true(config.get_opt("use_cursor_in_template"))
    assert.is_true(config.get_opt("insert_mode_after_paste"))
    assert.is_false(config.get_opt("embed_image_as_base64"))
    assert.equal(10, config.get_opt("max_base64_size"))
    assert.equals("$FILE_PATH", config.get_opt("template"))

    assert.is_true(config.get_opt("drag_and_drop.enabled"))
    assert.is_false(config.get_opt("drag_and_drop.insert_mode"))
    assert.is_false(config.get_opt("drag_and_drop.copy_images"))
    assert.is_true(config.get_opt("drag_and_drop.download_images"))

    vim.bo.filetype = "markdown"
    assert.is_true(config.get_opt("url_encode_path"))
    assert.equals("![$CURSOR]($FILE_PATH)", config.get_opt("template"))
    assert.is_false(config.get_opt("drag_and_drop.download_images"))
  end)

  it("should allow overriding default values", function()
    config.setup({ default = { dir_path = "new_assets", file_name = "new_format", insert_mode_after_paste = true } })

    assert.equals("new_assets", config.get_opt("dir_path"))
    assert.equals("new_format", config.get_opt("file_name"))
    assert.is_true(config.get_opt("insert_mode_after_paste"))
  end)

  it("should handle nil values gracefully", function()
    local result = config.get_opt("non_existing_option")
    assert.is_nil(result)
  end)

  it("should allow filetype-specific configuration", function()
    vim.bo.filetype = "markdown"

    config.setup({ filetypes = { markdown = { template = "markdown-template" } } })
    assert.equals("markdown-template", config.get_opt("template"))
  end)

  it("should prioritize API options over config values", function()
    assert.equals("custom-filename", config.get_opt("file_name", { file_name = "custom-filename" }))
    assert.equals(true, config.get_opt("debug", { debug = true }))
  end)

  it("should execute functions that are passed in the API", function()
    assert.equals(
      42,
      config.get_opt("life", {
        life = function()
          return 40 + 2
        end,
      })
    )
  end)
end)
