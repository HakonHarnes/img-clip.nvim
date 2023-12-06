local util = require("img-clip.util")

describe("util", function()
  it("can get the directory path from the file path", function()
    local path_separator = package.config:sub(1, 1)

    local simple_filepath = "path" .. path_separator .. "file.txt"
    local expected_simple_dirpath = "path" .. path_separator
    assert.equals(expected_simple_dirpath, util.get_dir_path_from_filepath(simple_filepath))

    local full_filepath = "path" .. path_separator .. "to" .. path_separator .. "file.txt"
    local expected_full_dirpath = "path" .. path_separator .. "to" .. path_separator
    assert.equals(expected_full_dirpath, util.get_dir_path_from_filepath(full_filepath))

    local nested_filepath = "path"
      .. path_separator
      .. "to"
      .. path_separator
      .. "nested"
      .. path_separator
      .. "file.txt"
    local expected_nested_dirpath = "path" .. path_separator .. "to" .. path_separator .. "nested" .. path_separator
    assert.equals(expected_nested_dirpath, util.get_dir_path_from_filepath(nested_filepath))

    local no_ext_filepath = "path" .. path_separator .. "to" .. path_separator .. "file"
    local expected_no_ext_dirpath = "path" .. path_separator .. "to" .. path_separator
    assert.equals(expected_no_ext_dirpath, util.get_dir_path_from_filepath(no_ext_filepath))

    local space_in_path = "path" .. path_separator .. "to space" .. path_separator .. "my file.txt"
    local expected_space_in_dirpath = "path" .. path_separator .. "to space" .. path_separator
    assert.equals(expected_space_in_dirpath, util.get_dir_path_from_filepath(space_in_path))
  end)

  it("can extract the filename from a file path", function()
    local path_separator = package.config:sub(1, 1)

    local simple_filepath = "file.txt"
    local expected_simple_filename = "file.txt"
    assert.equals(expected_simple_filename, util.get_filename_from_filepath(simple_filepath))

    local full_filepath = "path" .. path_separator .. "to" .. path_separator .. "file.txt"
    local expected_full_filename = "file.txt"
    assert.equals(expected_full_filename, util.get_filename_from_filepath(full_filepath))

    local nested_filepath = "path"
      .. path_separator
      .. "to"
      .. path_separator
      .. "nested"
      .. path_separator
      .. "file.txt"
    local expected_nested_filename = "file.txt"
    assert.equals(expected_nested_filename, util.get_filename_from_filepath(nested_filepath))

    local no_ext_filepath = "path" .. path_separator .. "to" .. path_separator .. "file"
    local expected_no_ext_filename = "file"
    assert.equals(expected_no_ext_filename, util.get_filename_from_filepath(no_ext_filepath))

    local space_in_filename = "path" .. path_separator .. "to" .. path_separator .. "my file.txt"
    local expected_space_in_filename = "my file.txt"
    assert.equals(expected_space_in_filename, util.get_filename_from_filepath(space_in_filename))
  end)

  it("can add a file extension to a filename", function()
    assert.equals("file.png", util.add_file_ext("file", "png"))
    assert.equals("file.png", util.add_file_ext("file.png", "png"))
    assert.equals("file.png", util.add_file_ext("file.jpg", "png"))
    assert.equals("file.png", util.add_file_ext("file.hello.world", "png"))
    assert.equals("file.jpg", util.add_file_ext("file", "jpg"))
    assert.equals("my file.png", util.add_file_ext("my file", "png"))
  end)

  it("can add a file extension to a filepath", function()
    local path_separator = package.config:sub(1, 1)

    local filepath_no_ext = "path" .. path_separator .. "to" .. path_separator .. "file"
    local expected_filepath_no_ext = filepath_no_ext .. ".png"
    assert.equals(expected_filepath_no_ext, util.add_file_ext(filepath_no_ext, "png"))

    local filepath_with_ext = "path" .. path_separator .. "to" .. path_separator .. "file.jpg"
    local expected_filepath_with_ext = "path" .. path_separator .. "to" .. path_separator .. "file.png"
    assert.equals(expected_filepath_with_ext, util.add_file_ext(filepath_with_ext, "png"))

    local nested_dir_filepath = "path"
      .. path_separator
      .. "to"
      .. path_separator
      .. "nested"
      .. path_separator
      .. "file"
    local expected_nested_dir_filepath = nested_dir_filepath .. ".png"
    assert.equals(expected_nested_dir_filepath, util.add_file_ext(nested_dir_filepath, "png"))

    local dot_in_dir_filepath = "path" .. path_separator .. "to.version" .. path_separator .. "file"
    local expected_dot_in_dir_filepath = dot_in_dir_filepath .. ".png"
    assert.equals(expected_dot_in_dir_filepath, util.add_file_ext(dot_in_dir_filepath, "png"))

    local filepath_with_space = "path" .. path_separator .. "to" .. path_separator .. "my file"
    local expected_filepath_with_space = filepath_with_space .. ".png"
    assert.equals(expected_filepath_with_space, util.add_file_ext(filepath_with_space, "png"))
  end)
end)
