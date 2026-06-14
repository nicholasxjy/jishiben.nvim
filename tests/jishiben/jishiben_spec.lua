local module = require("jishiben.module")
local plugin = require("jishiben")

local function make_tmp_file()
  return string.format("%s/jishiben-test-%d.md", vim.fn.stdpath("cache"), vim.loop.hrtime())
end

local function floating_windows()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      table.insert(wins, win)
    end
  end
  return wins
end

local function close_all_floats()
  for _, win in ipairs(floating_windows()) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
end

local function normalize_win_coord(value)
  if type(value) == "table" then
    return value[false] or value[1]
  end
  return value
end

local commands = vim.api.nvim_get_commands({ builtin = false })
if not commands.JishibenOpen then
  vim.cmd("runtime plugin/jishiben.lua")
end

describe("jishiben", function()
  it("registers only the supported user commands", function()
    local user_commands = vim.api.nvim_get_commands({ builtin = false })

    assert.is_table(user_commands.JishibenOpen)
    assert.is_table(user_commands.JishibenNote)
    assert.is_table(user_commands.JishibenTodo)
    assert.is_table(user_commands.JishibenClear)
    assert.is_nil(user_commands.JishibenAdd)
    assert.is_nil(user_commands.JishibenDelete)
    assert.is_nil(user_commands.JishibenPick)
    assert.is_nil(user_commands.JishibenToggle)
  end)

  it("opens a sidebar and editable content pane", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })

    plugin.open()

    local content_buf = vim.api.nvim_get_current_buf()
    assert.matches("^jishiben://notes/%d+$", vim.api.nvim_buf_get_name(content_buf))
    assert.are.equal("markdown", vim.bo[content_buf].filetype)
    assert.are.equal("acwrite", vim.bo[content_buf].buftype)
    assert.are.equal(1, vim.fn.filereadable(path))
    assert.are.equal(2, #floating_windows())

    close_all_floats()
    vim.fn.delete(path)
  end)

  it("initializes notes and todos sections for an empty file", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })

    plugin.open()

    assert.are.same({
      "# Jishiben",
      "",
      "## Notes",
      "",
      "## Todos",
      "",
    }, module.get_lines(path))

    close_all_floats()
    vim.fn.delete(path)
  end)

  it("edits the current section from the content pane", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })
    vim.fn.writefile({
      "# Jishiben",
      "",
      "## Notes",
      "",
      "## Todos",
      "",
    }, path)

    plugin.open()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "- 10:00  idea" })
    vim.cmd("write")

    close_all_floats()

    assert.are.same({
      "# Jishiben",
      "",
      "## Notes",
      "- 10:00  idea",
      "",
      "## Todos",
      "",
    }, module.get_lines(path))
    vim.fn.delete(path)
  end)

  it("captures notes and todos under their markdown sections", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })

    plugin.add_note("idea")
    plugin.add_todo("write report")

    local lines = module.get_lines(path)
    assert.matches("^%- %d%d:%d%d  idea$", lines[4])
    assert.are.equal("- [ ] write report", lines[7])

    vim.fn.delete(path)
  end)

  it("toggles the current todo line", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })
    vim.fn.writefile({
      "# Jishiben",
      "",
      "## Notes",
      "- [ ] write report",
      "",
      "## Todos",
      "",
    }, path)

    plugin.open()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    plugin.toggle_todo()
    assert.are.equal("- [x] write report", vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1])

    plugin.toggle_todo()
    assert.are.equal("- [ ] write report", vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1])

    close_all_floats()
    vim.fn.delete(path)
  end)

  it("respects custom floating window position and size", function()
    local path = make_tmp_file()
    plugin.setup({
      storage_path = path,
      win = {
        width = 48,
        height = 12,
        row = 3,
        col = 7,
      },
    })

    plugin.open()

    local content_win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(content_win)

    assert.are.equal(29, config.width)
    assert.are.equal(12, config.height)
    assert.are.equal(3, normalize_win_coord(config.row))
    assert.are.equal(26, normalize_win_coord(config.col))

    close_all_floats()
    vim.fn.delete(path)
  end)

  it("clears all notes but keeps markdown file", function()
    local path = make_tmp_file()
    vim.fn.writefile({ "# Inbox", "", "- [ ] one", "- [x] two" }, path)

    plugin.setup({ storage_path = path })
    plugin.clear_all()

    assert.are.equal(1, vim.fn.filereadable(path))
    assert.are.same({}, module.get_lines(path))

    vim.fn.delete(path)
  end)
end)
