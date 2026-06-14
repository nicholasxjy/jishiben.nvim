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
  vim.b[buf].jishiben_file_path = normalized
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
  vim.fn.writefile(lines, normalized)
end

---@param path string
---@param line string
M.append_line = function(path, line)
  local lines = M.get_lines(path)
  table.insert(lines, line)
  M.set_lines(path, lines)
end

return M
