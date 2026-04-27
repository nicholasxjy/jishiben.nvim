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

  local items = module.list_notes(path)

  Snacks.picker.pick({
    title = "Jishiben",
    layout = "select",
    items = items,
    format = function(item)
      local status_hl = item.done and "DiagnosticOk" or "DiagnosticWarn"
      local status = item.done and " ✓ " or "   "
      return {
        { status, status_hl },
        { item.text, "Normal" },
        { string.format("    line %d", item.line_number), "Comment" },
      }
    end,
    preview = false,
    actions = {
      delete_note = function(picker)
        local item = picker:current()
        if not item then
          return
        end
        module.delete_line(path, item.line_number)
        picker:close()
        M.open(opts)
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-x>"] = { "delete_note", mode = { "n", "i" } },
        },
      },
      list = {
        keys = {
          ["<C-x>"] = { "delete_note", mode = { "n" } },
        },
      },
    },
    confirm = function(picker, item)
      if not item then
        return
      end
      module.toggle_note(path, item.line_number)
      picker:close()
      M.open(opts)
    end,
  })
end

return M
