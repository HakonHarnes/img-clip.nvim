local markup = require("img-clip.markup")
local config = require("img-clip.config")

describe("markup", function()
  describe("split_lines", function()
    it("splits a string into lines, removing empty lines at start and end", function()
      local result = markup.split_lines("\nline1\nline2\n")
      assert.are.same({ "line1", "line2" }, result)
    end)
  end)

  describe("get_new_cursor_row", function()
    it("returns the new cursor position based on the $CURSOR token", function()
      local cur_row = 15
      local new_row, matched_line, matched_line_index =
        markup.get_new_cursor_row(cur_row, { "line1", "line$CURSOR2", "line3" })

      assert.equal(cur_row + 2, new_row)
      assert.equal("line$CURSOR2", matched_line)
      assert.equal(2, matched_line_index)
    end)

    it("returns the last line if no $CURSOR token is found", function()
      local new_row, matched_line, matched_line_index = markup.get_new_cursor_row(1, { "line1", "line2", "line3" })
      assert.are.equal(4, new_row)
      assert.are.equal("line3", matched_line)
      assert.are.equal(3, matched_line_index)
    end)
  end)

  describe("get_new_cursor_col", function()
    it("returns the new column position based on the $CURSOR token", function()
      local new_col = markup.get_new_cursor_col("hello $CURSORworld")
      assert.are.equal(6, new_col)
    end)

    it("returns the last column position if there is no $CURSOR token", function()
      local input_string = "hello world"
      local expected_col = string.len(input_string) - 1
      local new_col = markup.get_new_cursor_col(input_string)
      assert.are.equal(expected_col, new_col)
    end)
  end)

  describe("insert_markup", function()
    before_each(function()
      vim.bo.filetype = "text"
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
      config.setup() -- use default config values
    end)

    it("inserts markup into a file", function()
      local success = markup.insert_markup("/path/to/file.png")
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      assert.equal("/path/to/file.png", lines[2])
      assert.is_true(success)
    end)

    it("inserts markup into a markdown file", function()
      vim.bo.filetype = "markdown"

      local success = markup.insert_markup("/path/to/file.png")
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      assert.equal("![](/path/to/file.png)", lines[2])
      assert.is_true(success)
    end)

    it("inserts markup into a markdown file", function()
      vim.bo.filetype = "tex"

      local success = markup.insert_markup("/path/to/example file.png")
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      assert.equal("\\begin{figure}[h]", lines[2])
      assert.equal("  \\centering", lines[3])
      assert.equal("  \\includegraphics[width=0.8\\textwidth]{/path/to/example file.png}", lines[4])
      assert.equal("  \\caption{}", lines[5])
      assert.equal("  \\label{fig:example-file}", lines[6])
      assert.equal("\\end{figure}", lines[7])

      assert.is_true(success)
    end)
  end)
end)
