local clipboard = require("img-clip.clipboard")
local paste = require("img-clip.paste")
local config = require("img-clip.config")
local spy = require("luassert.spy")

describe("paste", function()
  before_each(function()
    config.setup({})
    config.get_config = function()
      return config.opts
    end
  end)

  describe("paste_image", function()
    it("should paste image from clipboard if clipboard content is image", function()
      clipboard.content_is_image = function()
        return true
      end

      paste.paste_image_from_clipboard = function()
        return true
      end

      spy.on(paste, "paste_image_from_clipboard")

      paste.paste_image()
      assert.spy(paste.paste_image_from_clipboard).was_called()
    end)

    it("should paste image from input if given explicitly", function()
      paste.paste_image_from_path = function()
        return true
      end

      spy.on(paste, "paste_image_from_path")

      paste.paste_image({}, "/home/user/Pictures/image.png")
      assert.spy(paste.paste_image_from_path).was_called()

      paste.paste_image_from_url = function()
        return true
      end

      spy.on(paste, "paste_image_from_url")

      paste.paste_image({}, "https://example.com/image.png")
      assert.spy(paste.paste_image_from_url).was_called()
    end)

    it("should paste image from clipboard if clipboard content is a file path or url", function()
      clipboard.content_is_image = function()
        return false
      end

      clipboard.get_content = function()
        return "/home/user/Pictures/image.png"
      end

      paste.paste_image_from_path = function()
        return true
      end

      spy.on(paste, "paste_image_from_path")

      paste.paste_image()
      assert.spy(paste.paste_image_from_path).was_called()

      clipboard.get_content = function()
        return "https://example.com/image.png"
      end

      paste.paste_image_from_url = function()
        return true
      end

      spy.on(paste, "paste_image_from_url")

      paste.paste_image()
      assert.spy(paste.paste_image_from_url).was_called()
    end)
  end)
end)
