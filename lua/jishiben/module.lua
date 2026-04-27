local M = {}

local function normalize_path(path)
  return vim.fn.fnamemodify(path, ":p")
end

local function get_storage_buf(path)
  local bufnr = vim.fn.bufnr(normalize_path(path))
  if bufnr == -1 or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end
  return bufnr
end

local function write_lines(path, lines)
  vim.fn.writefile(lines, normalize_path(path))
end

---@param path string
M.ensure_storage_file = function(path)
  local normalized = normalize_path(path)
  local dir = vim.fn.fnamemodify(normalized, ":h")
  vim.fn.mkdir(dir, "p")
  if vim.fn.filereadable(normalized) ~= 1 then
    vim.fn.writefile({}, normalized)
  end
end

---@param path string
---@return number
M.ensure_storage_buffer = function(path)
  local normalized = normalize_path(path)
  M.ensure_storage_file(normalized)
  local buf = vim.fn.bufadd(normalized)
  vim.fn.bufload(buf)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "hide"
  vim.b[buf].jishiben_storage_path = normalized
  return buf
end

---@param path string
---@return string[]
M.get_lines = function(path)
  local normalized = normalize_path(path)
  M.ensure_storage_file(normalized)
  local buf = get_storage_buf(normalized)
  if buf and vim.api.nvim_buf_is_loaded(buf) then
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  end
  return vim.fn.readfile(normalized)
end

---@param path string
---@param lines string[]
M.set_lines = function(path, lines)
  local normalized = normalize_path(path)
  M.ensure_storage_file(normalized)
  local buf = get_storage_buf(normalized)
  if buf and vim.api.nvim_buf_is_loaded(buf) then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent write")
    end)
    return
  end
  write_lines(normalized, lines)
end

---@param path string
---@param buf integer?
---@return boolean
M.is_storage_buffer = function(path, buf)
  local target = normalize_path(path)
  local current = vim.api.nvim_buf_get_name(buf or vim.api.nvim_get_current_buf())
  return current ~= "" and normalize_path(current) == target
end

---@param text string
---@return string
M.note_to_line = function(text)
  return string.format("- [ ] %s", text)
end

---@param line string
---@return { text: string, done: boolean }|nil
M.parse_checkbox_line = function(line)
  local _, _, prefix, state, text = line:find("^(%s*[-*]%s+)%[([ xX])%]%s*(.*)$")
  if not prefix then
    return nil
  end
  return {
    text = text,
    done = state:lower() == "x",
  }
end

---@param line string
---@return string|nil
M.toggle_checkbox_line = function(line)
  local _, _, prefix, state, text = line:find("^(%s*[-*]%s+)%[([ xX])%](.*)$")
  if not prefix then
    return nil
  end
  local next_state = state:lower() == "x" and " " or "x"
  return string.format("%s[%s]%s", prefix, next_state, text)
end

---@param path string
---@param text string
M.create_note = function(path, text)
  local lines = M.get_lines(path)
  table.insert(lines, M.note_to_line(text))
  M.set_lines(path, lines)
end

---@param path string
---@return { text: string, done: boolean, line_number: integer, raw_line: string }[]
M.list_notes = function(path)
  local notes = {}
  for index, line in ipairs(M.get_lines(path)) do
    local parsed = M.parse_checkbox_line(line)
    if parsed then
      table.insert(notes, {
        text = parsed.text,
        done = parsed.done,
        line_number = index,
        raw_line = line,
      })
    end
  end
  return notes
end

---@param path string
---@param line_number integer
---@return boolean
M.toggle_note = function(path, line_number)
  local lines = M.get_lines(path)
  local line = lines[line_number]
  if not line then
    return false
  end

  local toggled = M.toggle_checkbox_line(line)
  if not toggled then
    return false
  end

  lines[line_number] = toggled
  M.set_lines(path, lines)
  return true
end

---@param path string
---@param line_number integer
---@return boolean
M.delete_line = function(path, line_number)
  local lines = M.get_lines(path)
  if not lines[line_number] then
    return false
  end

  table.remove(lines, line_number)
  M.set_lines(path, lines)
  return true
end

---@param path string
M.clear_all = function(path)
  M.set_lines(path, {})
end

return M
