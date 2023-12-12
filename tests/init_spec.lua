local init = require("img-clip.init")
local clipboard = require("img-clip.clipboard")
local markup = require("img-clip.markup")
local util = require("img-clip.util")
local fs = require("img-clip.fs")
local spy = require("luassert.spy")

describe("img-clip.init", function()
  describe("pasteImage", function()
    before_each(function()
      init.clip_cmd = nil
      clipboard.get_clip_cmd = function()
        return "xclip"
      end
      clipboard.content_is_image = function(cmd)
        return cmd == "xclip"
      end
      fs.get_file_path = function()
        return "/path/to/image.png"
      end
      fs.mkdirp = function()
        return true
      end
      clipboard.save_image = function()
        return true
      end
      markup.insert_markup = function()
        return true
      end

      spy.on(util, "warn")
      spy.on(util, "error")
      spy.on(init, "_paste_as_file")
    end)

    after_each(function()
      util.warn:revert()
      util.error:revert()
      init._paste_as_file:revert()
    end)

    it("errors if clipboard command is not found", function()
      clipboard.get_clip_cmd = function()
        return nil
      end

      local success = init.pasteImage()
      assert.is_false(success)
      assert.spy(util.error).was_called_with("Could not get clipboard command. See :checkhealth img-clip.")
    end)

    it("successfully pastes an image", function()
      local success = init.pasteImage()
      assert.is_true(success)
    end)

    it("warns if clipboard content is not an image", function()
      clipboard.content_is_image = function()
        return false
      end
      local success = init.pasteImage()
      assert.is_false(success)
      assert.spy(util.warn).was_called_with("Clipboard content is not an image.")
    end)

    it("errors if file path cannot be determined", function()
      fs.get_file_path = function()
        return nil
      end
      local success = init.pasteImage()
      assert.is_false(success)
      assert.spy(util.error).was_called_with("Could not determine file path.")
    end)

    it("errors if directories cannot be created", function()
      fs.mkdirp = function()
        return false
      end
      local success = init.pasteImage()
      assert.is_false(success)
      assert.spy(util.error).was_called_with("Could not create directories.")
    end)

    it("errors if image cannot be saved to disk", function()
      clipboard.save_image = function()
        return false
      end
      local success = init.pasteImage()
      assert.is_false(success)
      assert.spy(util.error).was_called_with("Could not save image to disk.")
    end)

    it("errors if markup cannot be inserted", function()
      markup.insert_markup = function()
        return false
      end
      local success = init.pasteImage()
      assert.is_false(success)
      assert.spy(util.error).was_called_with("Could not insert markup code.")
    end)

    it("pastes as base64 when embed_image_as_base64 is true and filetype supports base64", function()
      local opts = { embed_image_as_base64 = true }
      vim.bo.filetype = "markdown"

      clipboard.get_base64_encoded_image = function()
        return "base64string"
      end

      local success = init.pasteImage(opts)
      assert.is_true(success)
    end)

    it("pastes as file when embed_image_as_base64 is true but filetype does not support base64", function()
      local opts = { embed_image_as_base64 = true }
      vim.bo.filetype = "txt"

      local success = init.pasteImage(opts)
      assert.is_true(success)
    end)

    it("pastes as file when embed_image_as_base64 is false", function()
      local opts = { embed_image_as_base64 = false }
      vim.bo.filetype = "markdown"

      local success = init.pasteImage(opts)
      assert.is_true(success)
    end)

    it("pastes as file if base64 encoding fails", function()
      local opts = { embed_image_as_base64 = true }
      vim.bo.filetype = "markdown"

      clipboard.get_base64_encoded_image = function()
        return nil
      end

      init.pasteImage(opts)
      assert.spy(init._paste_as_file).was_called()
    end)

    it("pastes as file if base64 string is too long", function()
      local opts = { embed_image_as_base64 = true, max_base64_size = 15 }
      vim.bo.filetype = "markdown"

      -- creates a base64 string > 15 KB
      clipboard.get_base64_encoded_image = function()
        return string.rep("a", 20000)
      end

      init.pasteImage(opts)
      assert.spy(init._paste_as_file).was_called()
    end)

    it("errors if base64 markup cannot be inserted", function()
      local opts = { embed_image_as_base64 = true }
      vim.bo.filetype = "markdown"

      clipboard.get_base64_encoded_image = function()
        return "base64string"
      end

      markup.insert_markup = function()
        return false
      end

      local success = init.pasteImage(opts)
      assert.is_false(success)
      assert.spy(util.error).was_called_with("Could not insert markup code.")
    end)
  end)
end)
