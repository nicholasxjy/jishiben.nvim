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

local commands = vim.api.nvim_get_commands({ builtin = false })
if not commands.JishibenOpen then
  vim.cmd("runtime plugin/jishiben.lua")
end

describe("jishiben", function()
  it("registers only the supported user commands", function()
    local user_commands = vim.api.nvim_get_commands({ builtin = false })

    assert.is_table(user_commands.JishibenOpen)
    assert.is_table(user_commands.JishibenClear)
    assert.is_nil(user_commands.JishibenAdd)
    assert.is_nil(user_commands.JishibenDelete)
    assert.is_nil(user_commands.JishibenPick)
    assert.is_nil(user_commands.JishibenToggle)
  end)

  it("opens the real markdown storage buffer", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })

    plugin.open()

    local buf = vim.api.nvim_get_current_buf()
    assert.are.equal(vim.fn.fnamemodify(path, ":p"), vim.api.nvim_buf_get_name(buf))
    assert.are.equal("markdown", vim.bo[buf].filetype)
    assert.are.equal(1, vim.fn.filereadable(path))

    close_current_float_if_needed()
    vim.fn.delete(path)
  end)

  it("edits the real markdown storage buffer", function()
    local path = make_tmp_file()
    plugin.setup({ storage_path = path })
    vim.fn.writefile({ "# Inbox" }, path)

    plugin.open()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "- [ ] write report" })

    close_current_float_if_needed()

    assert.are.same({ "# Inbox", "", "- [ ] write report" }, module.get_lines(path))
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
