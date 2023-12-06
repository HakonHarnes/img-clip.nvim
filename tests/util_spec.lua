local util = require("img-clip.util")

describe("util", function()
  it("can get the directory path from the file path", function()
    local dir_path = util.get_dir_path_from_filepath("/home/user/project/image.png")
    assert.same("/home/user/project/", dir_path)
  end)
end)
