local module = require("jishiben.module")
local plugin = require("jishiben")

local function make_tmp_file()
  return string.format("%s/jishiben-test-%d.json", vim.fn.stdpath("cache"), vim.loop.hrtime())
end

describe("jishiben", function()
  it("creates a note in single json file", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })

    local ok = plugin.add_note("buy milk")
    assert.is_true(ok)

    local notes = module.load_notes(path)
    assert.are.equal(1, #notes)
    assert.are.equal("buy milk", notes[1].text)
    assert.is_false(notes[1].done)

    vim.fn.delete(path)
  end)

  it("toggles note done state", function()
    local path = make_tmp_file()
    local note = module.create_note(path, "write report")
    assert.is_false(note.done)

    local toggled = module.toggle_note(path, note.id)
    assert.is_true(toggled.done)

    local toggled2 = module.toggle_note(path, note.id)
    assert.is_false(toggled2.done)

    vim.fn.delete(path)
  end)

  it("renders note as markdown checkbox line with time", function()
    local t = os.time({ year = 2026, month = 2, day = 15, hour = 14, min = 30 })
    assert.are.same("- [ ] **task** 2026-02-15 14:30", module.note_to_line({ text = "task", done = false, created_at = t }))
    assert.are.same("- [x] **task** 2026-02-15 14:30", module.note_to_line({ text = "task", done = true, created_at = t }))
  end)

  it("appends multiple notes to same file", function()
    local path = make_tmp_file()
    module.create_note(path, "first")
    module.create_note(path, "second")

    local notes = module.load_notes(path)
    assert.are.equal(2, #notes)
    assert.are.equal("first", notes[1].text)
    assert.are.equal("second", notes[2].text)

    vim.fn.delete(path)
  end)

  it("clears all notes", function()
    local path = make_tmp_file()
    module.create_note(path, "one")
    module.create_note(path, "two")
    assert.are.equal(2, #module.load_notes(path))

    module.clear_all(path)
    assert.are.equal(0, #module.load_notes(path))
  end)
end)
