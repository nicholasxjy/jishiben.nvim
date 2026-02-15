local module = require("jishiben.module")

---@class JishibenWinConfig
---@field title string
---@field title_pos string
---@field border string|string[]
---@field width number|nil
---@field height number|nil

---@class JishibenConfig
---@field storage_path string
---@field win JishibenWinConfig

local M = {}

---@type JishibenConfig
M.config = {
  storage_path = vim.fn.stdpath("data") .. "/jishiben.json",
  win = {
    title = " Jishiben ",
    title_pos = "center",
    border = "rounded",
  },
}

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
  local notes = module.load_notes(path)

  local lines = {}
  local note_ids = {}
  for _, note in ipairs(notes) do
    table.insert(lines, module.note_to_line(note))
    table.insert(note_ids, note.id)
  end

  if #lines == 0 then
    table.insert(lines, "(empty)")
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].filetype = "markdown"

  local wc = M.config.win
  local width = wc.width or math.min(60, vim.o.columns - 4)
  local height = wc.height or math.min(#lines, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = wc.border,
    title = wc.title,
    title_pos = wc.title_pos,
  })

  vim.b[buf].jishiben_ids = note_ids

  vim.keymap.set("n", "<CR>", function()
    M._toggle_popup_item(buf, path)
  end, { buffer = buf })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })
end

---@param buf number
---@param path string
---@return boolean
M._toggle_popup_item = function(buf, path)
  local ids = vim.b[buf].jishiben_ids
  if not ids or #ids == 0 then
    return false
  end

  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local id = ids[cursor_row]
  if not id then
    return false
  end

  local note = module.toggle_note(path, id)
  if not note then
    return false
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, cursor_row - 1, cursor_row, false, { module.note_to_line(note) })
  vim.bo[buf].modifiable = false
  return true
end

---@param text string?
---@return boolean
M.add_note = function(text)
  local content = text
  if not content or content == "" then
    content = vim.fn.input("Jishiben: ")
  end
  if content == "" then
    return false
  end
  module.create_note(M.get_storage_path(), content)
  return true
end

---@return boolean
M.toggle_item = function()
  local buf = vim.api.nvim_get_current_buf()
  local ids = vim.b[buf].jishiben_ids
  if ids then
    return M._toggle_popup_item(buf, M.get_storage_path())
  end
  return false
end

M.clear_all = function()
  module.clear_all(M.get_storage_path())
end

return M
