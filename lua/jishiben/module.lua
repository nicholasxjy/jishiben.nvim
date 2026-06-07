local M = {}

M.default_lines = {
  "# Inbox",
  "",
  "## Capture",
  "",
  "## Todo",
  "",
  "## Later",
}

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

M.is_empty_lines = function(lines)
  return #lines == 0 or (#lines == 1 and lines[1] == "")
end

local function find_line(lines, target)
  for index, line in ipairs(lines) do
    if line == target then
      return index
    end
  end
  return nil
end

M.ensure_heading = function(lines, heading)
  local index = find_line(lines, heading)
  if index then
    return index
  end

  if #lines > 0 and lines[#lines] ~= "" then
    table.insert(lines, "")
  end
  table.insert(lines, heading)
  table.insert(lines, "")
  return #lines - 1
end

M.ensure_sections = function(lines)
  if M.is_empty_lines(lines) then
    return vim.deepcopy(M.default_lines)
  end

  local next_lines = vim.deepcopy(lines)
  M.ensure_heading(next_lines, "# Inbox")
  M.ensure_heading(next_lines, "## Capture")
  M.ensure_heading(next_lines, "## Todo")
  M.ensure_heading(next_lines, "## Later")
  return next_lines
end

M.section_insert_index = function(lines, heading)
  local heading_index = M.ensure_heading(lines, heading)
  local next_heading = #lines + 1

  for index = heading_index + 1, #lines do
    if lines[index]:match("^##%s+") then
      next_heading = index
      break
    end
  end

  if next_heading > heading_index + 1 and lines[next_heading - 1] == "" then
    return next_heading - 1
  end
  return next_heading
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
M.ensure_default_content = function(path)
  local lines = M.get_lines(path)
  if not M.is_empty_lines(lines) then
    return
  end

  M.set_lines(path, M.default_lines)
end

---@param path string
---@param heading string
---@param line string
M.insert_under_heading = function(path, heading, line)
  local lines = M.ensure_sections(M.get_lines(path))
  local insert_index = M.section_insert_index(lines, heading)
  table.insert(lines, insert_index, line)
  M.set_lines(path, lines)
end

---@param path string
M.clear_all = function(path)
  M.set_lines(path, {})
end

return M
