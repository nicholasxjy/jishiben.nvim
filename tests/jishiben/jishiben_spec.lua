local module = require("jishiben.module")
local plugin = require("jishiben")

local function make_tmp_paths()
  local dir = string.format("%s/jishiben-test-%d", vim.fn.stdpath("cache"), vim.loop.hrtime())
  return {
    dir = dir,
    notes = dir .. "/notes.md",
    todos = dir .. "/todos.md",
    prompts = dir .. "/prompts.md",
  }
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

local function setup_tmp(paths)
  plugin.setup({
    notes_path = paths.notes,
    todos_path = paths.todos,
    prompts_path = paths.prompts,
  })
end

local function find_sidebar()
  for _, win in ipairs(floating_windows()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "nofile" then
      return win, buf
    end
  end
  return nil, nil
end

local function keymap_callback(buf, lhs, mode)
  for _, keymap in ipairs(vim.api.nvim_buf_get_keymap(buf, mode or "n")) do
    if keymap.lhs == lhs then
      return keymap.callback
    end
  end
  return nil
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

  it("creates notes, todos, and prompts markdown files", function()
    local paths = make_tmp_paths()
    setup_tmp(paths)

    plugin.open()

    assert.are.equal(1, vim.fn.filereadable(paths.notes))
    assert.are.equal(1, vim.fn.filereadable(paths.todos))
    assert.are.equal(1, vim.fn.filereadable(paths.prompts))
    assert.are.equal(2, #floating_windows())

    close_all_floats()
    vim.fn.delete(paths.dir, "rf")
  end)

  it("opens the notes markdown file in the content pane", function()
    local paths = make_tmp_paths()
    setup_tmp(paths)

    plugin.open()

    local buf = vim.api.nvim_get_current_buf()
    assert.are.equal(vim.fn.fnamemodify(paths.notes, ":p"), vim.api.nvim_buf_get_name(buf))
    assert.are.equal("markdown", vim.bo[buf].filetype)
    assert.are.equal("", vim.bo[buf].buftype)

    close_all_floats()
    vim.fn.delete(paths.dir, "rf")
  end)

  it("switches the content pane to the todos markdown file", function()
    local paths = make_tmp_paths()
    setup_tmp(paths)

    plugin.open()
    local sidebar_win, sidebar_buf = find_sidebar()
    assert.is_number(sidebar_win)
    assert.is_number(sidebar_buf)

    vim.api.nvim_set_current_win(sidebar_win)
    vim.api.nvim_win_set_cursor(sidebar_win, { 4, 0 })
    keymap_callback(sidebar_buf, "<CR>")()

    local buf = vim.api.nvim_get_current_buf()
    assert.are.equal(vim.fn.fnamemodify(paths.todos, ":p"), vim.api.nvim_buf_get_name(buf))

    close_all_floats()
    vim.fn.delete(paths.dir, "rf")
  end)

  it("opens prompts and sends its visual selection to Sidekick", function()
    local paths = make_tmp_paths()
    setup_tmp(paths)

    plugin.open()
    local sidebar_win, sidebar_buf = find_sidebar()
    assert.is_number(sidebar_win)
    assert.is_number(sidebar_buf)

    vim.api.nvim_set_current_win(sidebar_win)
    vim.api.nvim_win_set_cursor(sidebar_win, { 5, 0 })
    keymap_callback(sidebar_buf, "<CR>")()

    local buf = vim.api.nvim_get_current_buf()
    assert.are.equal(vim.fn.fnamemodify(paths.prompts, ":p"), vim.api.nvim_buf_get_name(buf))

    local sent
    local original_sidekick = package.loaded["sidekick.cli"]
    package.loaded["sidekick.cli"] = {
      send = function(opts)
        sent = opts
      end,
    }

    keymap_callback(buf, "<CR>", "x")()
    package.loaded["sidekick.cli"] = original_sidekick

    assert.are.same({
      msg = "{selection}",
      submit = true,
      focus = true,
    }, sent)

    close_all_floats()
    vim.fn.delete(paths.dir, "rf")
  end)

  it("edits the real notes markdown file", function()
    local paths = make_tmp_paths()
    setup_tmp(paths)

    plugin.open()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "# Any markdown", "", "- free-form note" })
    vim.cmd("write")

    close_all_floats()

    assert.are.same({ "# Any markdown", "", "- free-form note" }, module.get_lines(paths.notes))
    vim.fn.delete(paths.dir, "rf")
  end)

  it("captures raw notes and todos in separate files", function()
    local paths = make_tmp_paths()
    setup_tmp(paths)

    plugin.add_note("# idea")
    plugin.add_todo("- buy milk")

    assert.are.same({ "# idea" }, module.get_lines(paths.notes))
    assert.are.same({ "- buy milk" }, module.get_lines(paths.todos))

    vim.fn.delete(paths.dir, "rf")
  end)

  it("respects custom floating window position and size", function()
    local paths = make_tmp_paths()
    plugin.setup({
      notes_path = paths.notes,
      todos_path = paths.todos,
      prompts_path = paths.prompts,
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
    vim.fn.delete(paths.dir, "rf")
  end)

  it("clears notes, todos, and prompts but keeps the markdown files", function()
    local paths = make_tmp_paths()
    vim.fn.mkdir(paths.dir, "p")
    vim.fn.writefile({ "one" }, paths.notes)
    vim.fn.writefile({ "two" }, paths.todos)
    vim.fn.writefile({ "three" }, paths.prompts)

    setup_tmp(paths)
    plugin.clear_all()

    assert.are.equal(1, vim.fn.filereadable(paths.notes))
    assert.are.equal(1, vim.fn.filereadable(paths.todos))
    assert.are.equal(1, vim.fn.filereadable(paths.prompts))
    assert.are.same({}, module.get_lines(paths.notes))
    assert.are.same({}, module.get_lines(paths.todos))
    assert.are.same({}, module.get_lines(paths.prompts))

    vim.fn.delete(paths.dir, "rf")
  end)
end)
