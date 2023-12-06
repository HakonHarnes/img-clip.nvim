local util = require("img-clip.util")

describe("util", function()
  it("can get the directory path from the file path", function()
    local path_separator = package.config:sub(1, 1)
    local test_path = "path" .. path_separator .. "to" .. path_separator .. "file.txt"
    local expected_dir_path = "path" .. path_separator .. "to" .. path_separator

    local dir_path = util.get_dir_path_from_filepath(test_path)
    assert.equals(expected_dir_path, dir_path)
  end)

  it("can add a file extension to a filename", function()
    assert.equals("file.png", util.add_file_ext("file", "png"))
    assert.equals("file.png", util.add_file_ext("file.png", "png"))
    assert.equals("file.png", util.add_file_ext("file.jpg", "png"))
    assert.equals("file.png", util.add_file_ext("file.hello.world", "png"))
    assert.equals("file.jpg", util.add_file_ext("file", "jpg"))
  end)

  it("can add a file extension to a filepath", function()
    local path_separator = package.config:sub(1, 1)
    local test_filepath = "path" .. path_separator .. "to" .. path_separator .. "file"
    local expected_filepath = "path" .. path_separator .. "to" .. path_separator .. "file.png"

    local filepath = util.add_file_ext(test_filepath, "png")
    assert.equals(expected_filepath, filepath)
  end)
end)
