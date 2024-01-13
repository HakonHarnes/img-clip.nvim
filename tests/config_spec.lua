local config = require("img-clip.config")

describe("config", function()
  before_each(function()
    config.setup({}) -- use default config values
  end)

  it("should have default values for all configuration options", function()
    assert.equals("assets", config.get_option("dir_path"))
    assert.equals("%Y-%m-%d-%H-%M-%S", config.get_option("file_name"))
    assert.is_true(config.get_option("prompt_for_file_name"))
    assert.is_false(config.get_option("show_dir_path_in_prompt"))
    assert.is_false(config.get_option("use_absolute_path"))
    assert.is_true(config.get_option("insert_mode_after_paste"))
    assert.is_true(config.get_option("use_cursor_in_template"))
    assert.is_false(config.get_option("embed_image_as_base64"))
    assert.equal(10, config.get_option("max_base64_size"))
    assert.equals("$FILE_PATH", config.get_option("template"))
  end)

  it("should allow overriding default values", function()
    config.setup({ default = { dir_path = "new_assets", file_name = "new_format", insert_mode_after_paste = true } })

    assert.equals("new_assets", config.get_option("dir_path"))
    assert.equals("new_format", config.get_option("file_name"))
    assert.is_true(config.get_option("insert_mode_after_paste"))
  end)

  it("should handle nil values gracefully", function()
    local result = config.get_option("non_existing_option")
    assert.is_nil(result)
  end)

  it("should allow filetype-specific configuration", function()
    vim.bo.filetype = "markdown"

    config.options.markdown = { template = "markdown-template-override" }
    assert.equals("markdown-template-override", config.get_option("template"))
  end)

  it("should prioritize explicitly passed options over defaults", function()
    local opts = { file_name = "custom-filename" }
    assert.equals("custom-filename", config.get_option("file_name", opts))
  end)
end)
