local config = require("img-clip.config")

describe("config", function()
  before_each(function()
    config.setup({}) -- use default config values
  end)

  it("should have default values for all configuration options", function()
    assert.equals("assets", config.get_option("dir_path"))
    assert.equals("%Y-%m-%d-%H-%M-%S", config.get_option("filename"))
    assert.is_true(config.get_option("prompt_for_filename"))
    assert.is_false(config.get_option("include_path_in_prompt"))
    assert.is_false(config.get_option("absolute_path"))
    assert.is_false(config.get_option("cursor_insert_mode"))
    assert.equals("$FILEPATH", config.get_option("template"))
    assert.equals("![$CURSOR]($FILEPATH)", config.get_option("markdown").template)
    assert.equals([[\includegraphics{$FILEPATH}]], config.get_option("latex").template)
  end)

  it("should allow overriding default values", function()
    config.setup({ dir_path = "new_assets", filename = "new_format", cursor_insert_mode = true })

    assert.equals("new_assets", config.get_option("dir_path"))
    assert.equals("new_format", config.get_option("filename"))
    assert.is_true(config.get_option("cursor_insert_mode"))
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
    local opts = { filename = "custom-filename" }
    assert.equals("custom-filename", config.get_option("filename", opts))
  end)
end)
