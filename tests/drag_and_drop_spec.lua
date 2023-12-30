local drag_and_drop = require("img-clip.drag_and_drop")
local config = require("img-clip.config")
local util = require("img-clip.util")

describe("drag and drop", function()
  describe("handle_paste", function()
    before_each(function()
      config.setup({}) -- use default config

      vim.fn.mode = function()
        return "n"
      end
    end)

    it("should return false if input is not url or path", function()
      local result = drag_and_drop.handle_paste("some string")
      assert.is_false(result)
    end)

    it("should return true if input is image path", function()
      local r1 = drag_and_drop.handle_paste("path/to/image/image.png")
      assert.is_true(r1)

      local r2 = drag_and_drop.handle_paste("file:///home/user/Pictures/wallpapers/test.jpg")
      assert.is_true(r2)
    end)

    it("should return true if input is a valid url", function()
      config.setup({
        default = {
          drag_and_drop = {
            download_images = false,
          },
        },
      })

      util.is_image_url = function()
        return true
      end

      local result = drag_and_drop.handle_paste("https://example.com/image.png")
      assert.is_true(result)
    end)
  end)
end)
