local module = require("jishiben.module")
local plugin = require("jishiben")

local function make_tmp_file()
  return string.format("%s/jishiben-test-%d.md", vim.fn.stdpath("cache"), vim.loop.hrtime())
end

local function close_current_float_if_needed()
  local win = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(win)
  if config.relative ~= "" then
    vim.api.nvim_win_close(win, true)
  end
end

describe("jishiben", function()
  it("creates a note in single markdown file", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })

    local ok = plugin.add_note("buy milk")
    assert.is_true(ok)

    assert.are.same({ "- [ ] buy milk" }, module.get_lines(path))

    vim.fn.delete(path)
  end)

  it("toggles checkbox state in the storage buffer", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })
    module.create_note(path, "write report")

    plugin.open()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    local ok = plugin.toggle_item()
    assert.is_true(ok)
    assert.are.same({ "- [x] write report" }, module.get_lines(path))

    close_current_float_if_needed()
    vim.fn.delete(path)
  end)

  it("renders note as markdown checkbox line", function()
    assert.are.same("- [ ] task", module.note_to_line("task"))
  end)

  it("lists only markdown checkbox lines", function()
    local path = make_tmp_file()
    vim.fn.writefile({ "# Inbox", "", "- [ ] first task", "plain text", "- [x] done task" }, path)

    local notes = module.list_notes(path)
    assert.are.equal(2, #notes)
    assert.are.equal("first task", notes[1].text)
    assert.is_false(notes[1].done)
    assert.are.equal(3, notes[1].line_number)
    assert.are.equal("done task", notes[2].text)
    assert.is_true(notes[2].done)
    assert.are.equal(5, notes[2].line_number)

    vim.fn.delete(path)
  end)

  it("appends multiple notes to same file", function()
    local path = make_tmp_file()
    module.create_note(path, "first")
    module.create_note(path, "second")

    assert.are.same({ "- [ ] first", "- [ ] second" }, module.get_lines(path))

    vim.fn.delete(path)
  end)

  it("clears all notes but keeps markdown file", function()
    local path = make_tmp_file()
    module.create_note(path, "one")
    module.create_note(path, "two")

    module.clear_all(path)

    assert.are.equal(1, vim.fn.filereadable(path))
    assert.are.same({}, module.get_lines(path))

    vim.fn.delete(path)
  end)

  it("opens the real markdown storage buffer", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })

    plugin.open()

    local buf = vim.api.nvim_get_current_buf()
    assert.are.equal(vim.fn.fnamemodify(path, ":p"), vim.api.nvim_buf_get_name(buf))
    assert.are.equal("markdown", vim.bo[buf].filetype)

    close_current_float_if_needed()
    vim.fn.delete(path)
  end)
end)
