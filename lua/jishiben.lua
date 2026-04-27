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
  storage_path = vim.fn.stdpath("data") .. "/jishiben.md",
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
  local buf = module.ensure_storage_buffer(path)

  local wc = M.config.win
  local width = wc.width or math.min(80, vim.o.columns - 4)
  local height = wc.height or math.min(math.max(vim.api.nvim_buf_line_count(buf), 20), vim.o.lines - 4)
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

  vim.wo[win].wrap = true
  vim.wo[win].cursorline = true

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
  local path = M.get_storage_path()
  local buf = vim.api.nvim_get_current_buf()
  if not module.is_storage_buffer(path, buf) then
    return false
  end
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  return module.toggle_note(path, cursor_row)
end

---@return boolean
M.delete_item = function()
  local path = M.get_storage_path()
  local buf = vim.api.nvim_get_current_buf()
  if not module.is_storage_buffer(path, buf) then
    return false
  end
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  return module.delete_line(path, cursor_row)
end

M.clear_all = function()
  module.clear_all(M.get_storage_path())
end

return M
