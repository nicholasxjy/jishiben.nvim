local M = {}

---@param path string
---@return table[] notes
M.load_notes = function(path)
  if vim.fn.filereadable(path) ~= 1 then
    return {}
  end
  local content = vim.fn.readfile(path)
  if #content == 0 then
    return {}
  end
  local ok, notes = pcall(vim.fn.json_decode, table.concat(content, ""))
  if not ok or type(notes) ~= "table" then
    return {}
  end
  return notes
end

---@param path string
---@param notes table[]
M.save_notes = function(path, notes)
  local dir = vim.fn.fnamemodify(path, ":h")
  vim.fn.mkdir(dir, "p")
  vim.fn.writefile({ vim.fn.json_encode(notes) }, path)
end

---@param path string
---@param text string
---@return table note
M.create_note = function(path, text)
  local notes = M.load_notes(path)
  local note = {
    id = tostring(vim.loop.hrtime()),
    text = text,
    done = false,
    created_at = os.time(),
  }
  table.insert(notes, note)
  M.save_notes(path, notes)
  return note
end

---@param path string
---@param id string
---@return table|nil note
M.toggle_note = function(path, id)
  local notes = M.load_notes(path)
  local target = nil
  for _, note in ipairs(notes) do
    if note.id == id then
      note.done = not note.done
      target = note
      break
    end
  end
  if not target then
    return nil
  end
  M.save_notes(path, notes)
  return target
end

---@param note table
---@return string
M.note_to_line = function(note)
  local checkbox = note.done and "- [x] " or "- [ ] "
  local time_str = ""
  if note.created_at then
    time_str = "    " .. os.date("%Y-%m-%d %H:%M", note.created_at)
  end
  return checkbox .. "**" .. note.text .. "**" .. time_str
end

---@param path string
---@param id string
---@return boolean
M.delete_note = function(path, id)
  local notes = M.load_notes(path)
  for i, note in ipairs(notes) do
    if note.id == id then
      table.remove(notes, i)
      M.save_notes(path, notes)
      return true
    end
  end
  return false
end

---@param path string
M.clear_all = function(path)
  if vim.fn.filereadable(path) == 1 then
    vim.fn.delete(path)
  end
end

return M
