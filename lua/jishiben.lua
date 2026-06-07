local module = require("jishiben.module")

---@class JishibenWinConfig
---@field title string
---@field title_pos string
---@field border string|string[]
---@field width number|nil
---@field height number|nil
---@field row number|nil
---@field col number|nil

---@class JishibenConfig
---@field storage_path string
---@field win JishibenWinConfig

local M = {}

---@type JishibenConfig
M.config = {
  storage_path = vim.fn.stdpath("data") .. "/jishiben.md",
  win = {
    title = " Jishiben ",
    title_pos = "center",
    border = "rounded",
  },
}

local function ensure_buffer_sections(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local next_lines = module.ensure_sections(lines)

  if vim.deep_equal(lines, next_lines) then
    return
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, next_lines)
end

local function section_insert_lnum(buf, heading)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return module.section_insert_index(lines, heading)
end

local function insert_buffer_entry(buf, heading, line)
  ensure_buffer_sections(buf)
  local lnum = section_insert_lnum(buf, heading)
  vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum - 1, false, { line })
  return lnum
end

local function start_insert_at(lnum, col)
  vim.api.nvim_win_set_cursor(0, { lnum, col })
  vim.cmd("startinsert")
end

local function note_prefix()
  return "- " .. os.date("%H:%M") .. "  "
end

local function todo_prefix()
  return "- [ ] "
end

---@param args JishibenConfig?
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

---@return string
M.get_storage_path = function()
  return M.config.storage_path
end

M.open = function()
  local path = M.get_storage_path()
  module.ensure_default_content(path)
  local buf = module.ensure_storage_buffer(path)
  ensure_buffer_sections(buf)

  local wc = M.config.win
  local width = wc.width or math.min(88, vim.o.columns - 4)
  local height = wc.height or math.min(math.max(vim.api.nvim_buf_line_count(buf), 20), vim.o.lines - 4)
  local row = wc.row or math.floor((vim.o.lines - height) / 2)
  local col = wc.col or math.floor((vim.o.columns - width) / 2)

  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = wc.border,
    title = wc.title,
    title_pos = wc.title_pos,
  }

  if vim.fn.has("nvim-0.10") == 1 then
    win_config.footer = " NORMAL  i note  o todo  <Space>x toggle  dd delete  / search  q write+close "
    win_config.footer_pos = "center"
  end

  local win = vim.api.nvim_open_win(buf, true, win_config)

  vim.wo[win].wrap = true
  vim.wo[win].cursorline = true
  vim.wo[win].number = true
  vim.wo[win].signcolumn = "no"

  vim.keymap.set("n", "q", function()
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent write")
      end)
    end
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf })

  vim.keymap.set("n", "i", function()
    local prefix = note_prefix()
    local lnum = insert_buffer_entry(buf, "## Capture", prefix)
    start_insert_at(lnum, #prefix)
  end, { buffer = buf, desc = "Jishiben add note" })

  vim.keymap.set("n", "o", function()
    local prefix = todo_prefix()
    local lnum = insert_buffer_entry(buf, "## Todo", prefix)
    start_insert_at(lnum, #prefix)
  end, { buffer = buf, desc = "Jishiben add todo" })

  vim.keymap.set("n", "<Space>x", function()
    M.toggle_todo()
  end, { buffer = buf, desc = "Jishiben toggle todo" })
end

---@param text string?
M.add_note = function(text)
  module.insert_under_heading(M.get_storage_path(), "## Capture", note_prefix() .. (text or ""))
end

---@param text string?
M.add_todo = function(text)
  module.insert_under_heading(M.get_storage_path(), "## Todo", todo_prefix() .. (text or ""))
end

M.toggle_todo = function()
  local buf = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ""
  local toggled = line:gsub("%[ %]", "[x]", 1)

  if toggled == line then
    toggled = line:gsub("%[x%]", "[ ]", 1)
  end
  if toggled == line then
    toggled = line:gsub("^(%s*%-)%s*", "%1 [ ] ", 1)
  end
  if toggled == line then
    toggled = todo_prefix() .. line
  end

  vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, false, { toggled })
end

M.clear_all = function()
  module.clear_all(M.get_storage_path())
end

return M
