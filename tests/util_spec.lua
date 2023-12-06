local util = require("img-clip.util")

describe("util", function()
  it("can get the directory path from the file path", function()
    -- construct test input
    local path_separator = package.config:sub(1, 1)
    local test_path = "path" .. path_separator .. "to" .. path_separator .. "file.txt"
    local expected_dir_path = "path" .. path_separator .. "to" .. path_separator

    -- check if the correct directory path is returned
    local dir_path = util.get_dir_path_from_filepath(test_path)
    assert.equals(expected_dir_path, dir_path)
  end)
end)
