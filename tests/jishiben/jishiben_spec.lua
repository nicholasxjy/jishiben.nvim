local module = require("jishiben.module")
local plugin = require("jishiben")

local function make_tmp_file()
  return string.format("%s/jishiben-test-%d.md", vim.fn.stdpath("cache"), vim.loop.hrtime())
end

describe("jishiben", function()
  it("appends markdown task to local file", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })

    local ok = plugin.add_note("buy milk")
    assert.is_true(ok)

    local lines = vim.fn.readfile(path)
    assert.are.same("# Jishiben", lines[1])
    assert.are.same("- [ ] buy milk", lines[3])

    vim.fn.delete(path)
  end)

  it("toggles markdown checkbox line", function()
    assert.are.same("- [x] done", module.toggle_markdown_checkbox("- [ ] done"))
    assert.are.same("- [ ] done", module.toggle_markdown_checkbox("- [x] done"))
    assert.is_nil(module.toggle_markdown_checkbox("plain text"))
  end)

  it("toggles current buffer line", function()
    vim.cmd("enew")
    vim.api.nvim_set_current_line("- [ ] test task")

    local ok = plugin.toggle_item()
    assert.is_true(ok)
    assert.are.same("- [x] test task", vim.api.nvim_get_current_line())
  end)
end)
