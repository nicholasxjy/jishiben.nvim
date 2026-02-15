local module = require("jishiben.module")

local M = {}

---@param opts? { path?: string }
M.open = function(opts)
  local ok, Snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("Jishiben: snacks.nvim is required for picker", vim.log.levels.ERROR)
    return
  end

  local jishiben = require("jishiben")
  local path = (opts and opts.path) or jishiben.get_storage_path()

  local notes = module.load_notes(path)
  local items = {}
  for _, note in ipairs(notes) do
    local status = note.done and "[done]" or "[todo]"
    local time_str = note.created_at and os.date("%Y-%m-%d %H:%M", note.created_at) or ""
    table.insert(items, {
      text = note.text .. " " .. status .. " " .. time_str,
      note_id = note.id,
      note_text = note.text,
      note_done = note.done,
      note_time = time_str,
    })
  end

  Snacks.picker.pick({
    title = "Jishiben",
    items = items,
    format = function(item)
      local status_hl = item.note_done and "DiagnosticOk" or "DiagnosticWarn"
      local status = item.note_done and " ✓ " or "   "
      return {
        { status, status_hl },
        { item.note_text, "Normal" },
        { "    " .. item.note_time, "Comment" },
      }
    end,
    preview = false,
    confirm = function(picker, item)
      if not item then
        return
      end
      module.toggle_note(path, item.note_id)
      picker:close()
      M.open(opts)
    end,
  })
end

return M
