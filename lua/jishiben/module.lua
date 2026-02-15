local M = {}

---@param path string
M.ensure_file = function(path)
  if vim.fn.filereadable(path) == 1 then
    return
  end

  local dir = vim.fn.fnamemodify(path, ":h")
  vim.fn.mkdir(dir, "p")
  vim.fn.writefile({ "# Jishiben", "" }, path)
end

---@param path string
---@param text string
M.append_task = function(path, text)
  local line = string.format("- [ ] %s", text)
  vim.fn.writefile({ line }, path, "a")
end

---@param line string
---@return string|nil
M.toggle_markdown_checkbox = function(line)
  local unchecked = line:gsub("^%- %[ %] ", "- [x] ")
  if unchecked ~= line then
    return unchecked
  end

  local checked = line:gsub("^%- %[x%] ", "- [ ] ")
  if checked ~= line then
    return checked
  end

  return nil
end

return M
