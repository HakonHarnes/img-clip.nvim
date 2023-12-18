local config = require("img-clip.config")
local util = require("img-clip.util")
local fs = require("img-clip.fs")

describe("fs", function()
  describe("get_file_path", function()
    before_each(function()
      util.input = function() -- mock user input
        return ""
      end

      config.setup({}) -- use default config values
    end)

    it("uses default directory and filename if no options or user inputs are provided", function()
      local ext = "png"
      local expected = config.get_option("dir_path") .. fs.sep .. os.date(config.get_option("file_name")) .. "." .. ext
      local actual = fs.get_file_path(ext)

      assert.equals(expected, actual)
    end)

    it("prompts for full file path when 'prompt_for_file_name' and 'show_dir_path_in_prompt' are true", function()
      config.setup({ default = { prompt_for_file_name = true, show_dir_path_in_prompt = true } })

      util.input = function()
        return "custom" .. fs.sep .. "dir" .. fs.sep .. "custom-file"
      end

      local ext = "png"
      local expected = "custom" .. fs.sep .. "dir" .. fs.sep .. "custom-file.png"
      local actual = fs.get_file_path(ext)

      assert.equals(expected, actual)
    end)

    it(
      "prompts only for filename when 'prompt_for_file_name' is true and 'show_dir_path_in_prompt' is false",
      function()
        config.setup({ default = { prompt_for_file_name = true, show_dir_path_in_prompt = false } })

        util.input = function()
          return "custom-file"
        end

        local ext = "png"
        local dir_path = config.get_option("dir_path") .. fs.sep
        local expected = dir_path .. "custom-file.png"
        local actual = fs.get_file_path(ext)

        assert.equals(expected, actual)
      end
    )

    it("prompts for file path when 'show_dir_path_in_prompt' is true", function()
      config.setup({ default = { show_dir_path_in_prompt = true } })

      util.input = function()
        return "custom-path" .. fs.sep .. "custom-file.png"
      end

      local ext = "png"
      local expected = "custom-path" .. fs.sep .. "custom-file.png"
      local actual = fs.get_file_path(ext)

      assert.equals(expected, actual)
    end)

    it("uses an absolute path when 'use_absolute_path' option is true", function()
      config.setup({ default = { use_absolute_path = true } }) -- set absolute_path option to true

      local ext = "png"
      local path = config.get_option("dir_path") .. fs.sep .. os.date(config.get_option("file_name")) .. "." .. ext
      local absolute_path = vim.fn.fnamemodify(path, ":p")
      local expected = absolute_path
      local actual = fs.get_file_path(ext)

      assert.equals(expected, actual)
    end)

    it("returns path with trailing separator when dir_path has no trailing separator", function()
      config.setup({ default = { dir_path = "custom" .. fs.sep .. "path" } })

      local ext = "png"
      local expected = "custom" .. fs.sep .. "path" .. fs.sep .. os.date(config.get_option("file_name")) .. "." .. ext
      local actual = fs.get_file_path(ext)

      assert.equals(expected, actual)
    end)

    it("handles empty or invalid user input gracefully", function()
      util.input = function()
        return ""
      end

      local ext = "png"
      local expected = config.get_option("dir_path") .. fs.sep .. os.date(config.get_option("file_name")) .. "." .. ext
      local actual = fs.get_file_path(ext)

      assert.equals(expected, actual)
    end)

    it("correctly processes different date formats in filename", function()
      config.setup({ default = { file_name = "%Y-%m-%d" } })

      local ext = "png"
      local expected = config.get_option("dir_path") .. fs.sep .. os.date("%Y-%m-%d") .. "." .. ext
      local actual = fs.get_file_path(ext)

      assert.equals(expected, actual)
    end)
  end)

  describe("mkdirp", function()
    local test_dir_base = "test-dir"
    local nested_dir_path = test_dir_base .. fs.sep .. "nested" .. fs.sep .. "dir"

    after_each(function()
      vim.fn.delete(test_dir_base, "rf")
    end)

    local function directory_exists(path)
      local stat = vim.loop.fs_stat(path)
      return stat and stat.type == "directory"
    end

    it("creates nested directories", function()
      local result = fs.mkdirp(nested_dir_path)
      assert.is_true(result)
      assert.is_true(directory_exists(nested_dir_path))
    end)

    it("returns true for existing directory", function()
      vim.loop.fs_mkdir(test_dir_base, 493)

      local result = fs.mkdirp(test_dir_base)
      assert.is_true(result)
    end)

    it("handles paths with trailing separators", function()
      local path_with_trailing_sep = nested_dir_path .. fs.sep
      local result = fs.mkdirp(path_with_trailing_sep)
      assert.is_true(result)
      assert.is_true(directory_exists(path_with_trailing_sep))
    end)
  end)

  describe("add_file_ext", function()
    it("adds extension to a filename without an extension", function()
      assert.equals("file.png", fs.add_file_ext("file", "png"))
    end)

    it("does not change filename that already has the same extension", function()
      assert.equals("file.png", fs.add_file_ext("file.png", "png"))
    end)

    it("replaces existing different extension with new extension", function()
      assert.equals("file.png", fs.add_file_ext("file.jpg", "png"))
    end)

    it("adds extension to a filename with multiple dots", function()
      assert.equals("file.hello.png", fs.add_file_ext("file.hello.world", "png"))
    end)

    it("handles different extensions correctly", function()
      assert.equals("file.jpg", fs.add_file_ext("file", "jpg"))
    end)

    it("handles filenames with spaces", function()
      assert.equals("my file.png", fs.add_file_ext("my file", "png"))
    end)

    describe("normalize_path", function()
      it("adds a path separator at the end of a simple path", function()
        local path = "some" .. fs.sep .. "directory"
        assert.equals(path .. fs.sep, fs.normalize_path(path))
      end)

      it("replaces multiple separators with a single one and adds a trailing separator", function()
        local path = "some" .. fs.sep:rep(2) .. "directory" .. fs.sep:rep(2)
        assert.equals("some" .. fs.sep .. "directory" .. fs.sep, fs.normalize_path(path))
      end)

      it("handles paths that already have a single trailing separator", function()
        local path = "some" .. fs.sep .. "directory" .. fs.sep
        assert.equals(path, fs.normalize_path(path))
      end)

      it("handles an empty path", function()
        local path = ""
        assert.equals(fs.sep, fs.normalize_path(path))
      end)
    end)
  end)
end)
