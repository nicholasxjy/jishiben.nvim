local module = require("jishiben.module")

---@class JishibenConfig
---@field storage_path string

local M = {}

---@type JishibenConfig
M.config = {
  storage_path = vim.fn.stdpath("data") .. "/jishiben.md",
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
  module.ensure_file(path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
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

  local path = M.get_storage_path()
  module.ensure_file(path)
  module.append_task(path, content)
  return true
end

---@return boolean
M.toggle_item = function()
  local line = vim.api.nvim_get_current_line()
  local updated = module.toggle_markdown_checkbox(line)

  if not updated then
    return false
  end

  vim.api.nvim_set_current_line(updated)
  return true
end

return M
