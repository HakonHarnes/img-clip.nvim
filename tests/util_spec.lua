local util = require("img-clip.util")

describe("util", function()
  describe("_is_image_url", function()
    it("should return true for valid urls", function()
      assert.is_true(util.is_image_url("https://example.com/image.png"))
      assert.is_true(util.is_image_url("http://example.com/image.png"))
      assert.is_true(util.is_image_url("https://example.com/image.jpg"))
      assert.is_true(util.is_image_url("http://example.com/image.jpg"))
      assert.is_true(util.is_image_url("https://example.com/image.jpeg"))
      assert.is_true(util.is_image_url("http://example.com/image.jpeg"))
    end)
  end)

  describe("execute", function()
    before_each(function()
      vim.o.shell = "cmd.exe"
      vim.fn.system = function(cmd)
        return cmd
      end

      vim.fn.has = function()
        return 0
      end
    end)

    it("should return output and exit code", function()
      local command = "command"
      local output, exit_code = util.execute(command)

      assert.equal(output, command)
      assert.equal(exit_code, 0)
    end)

    it("should execute .NET commands directly if shell is powershell", function()
      vim.o.shell = "powershell"

      local command = "command"
      local output, exit_code = util.execute(command, true)

      assert.equal(command, output)
      assert.equal(exit_code, 0)
    end)

    it("should execute .NET commands directly if shell is pwsh", function()
      vim.o.shell = "pwsh"

      local command = "command"
      local output, exit_code = util.execute(command, true)

      assert.equal(command, output)
      assert.equal(exit_code, 0)
    end)

    it("should wrap the command in powershell.exe -Command if shell is cmd.exe", function()
      local command = 'command "path/to/file"'
      local output, exit_code = util.execute(command, true)

      assert.equal([[powershell.exe -Command "command 'path/to/file'"]], output)
      assert.equal(exit_code, 0)
    end)

    it("should wrap the command in powershell.exe -Command if in WSL", function()
      vim.fn.has = function(feature)
        if feature == "wsl" then
          return 1
        else
          return 0
        end
      end

      local command = "command 'path/to/file'"
      local output, exit_code = util.execute(command, true)

      assert.equal([[powershell.exe -Command 'command "path/to/file"']], output)
      assert.equal(exit_code, 0)
    end)
  end)
end)
