local module = require("jishiben.module")

---@class JishibenWinConfig
---@field title string
---@field title_pos string
---@field border string|string[]
---@field width number|nil
---@field height number|nil
---@field row number|nil
---@field col number|nil

---@class JishibenConfig
---@field notes_path string
---@field todos_path string
---@field win JishibenWinConfig

local data_dir = vim.fn.stdpath("data") .. "/jishiben"

local M = {}

---@type JishibenConfig
M.config = {
  notes_path = data_dir .. "/notes.md",
  todos_path = data_dir .. "/todos.md",
  win = {
    title = " jishiben.nvim ",
    title_pos = "center",
    border = "single",
  },
}

local function sections()
  return {
    {
      id = "notes",
      label = "Notes",
      path = M.config.notes_path,
    },
    {
      id = "todos",
      label = "Todos",
      path = M.config.todos_path,
    },
  }
end

local function section_by_id(id)
  for _, section in ipairs(sections()) do
    if section.id == id then
      return section
    end
  end
  return sections()[1]
end

local function section_by_label(label)
  for _, section in ipairs(sections()) do
    if section.label == label then
      return section
    end
  end
  return sections()[1]
end

---@param args JishibenConfig?
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

---@return string
M.get_notes_path = function()
  return M.config.notes_path
end

---@return string
M.get_todos_path = function()
  return M.config.todos_path
end

local function set_content_title(win, title)
  if vim.fn.has("nvim-0.10") == 0 then
    return
  end

  pcall(vim.api.nvim_win_set_config, win, {
    title = " " .. title .. " ",
    title_pos = "center",
  })
end

local function render_sidebar(buf, current_id)
  local lines = { "jishiben.nvim", "" }

  for _, section in ipairs(sections()) do
    local marker = section.id == current_id and "> " or "  "
    table.insert(lines, marker .. section.label)
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
end

local function write_if_modified(buf)
  if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent write")
    end)
  end
end

local function close_layout(sidebar_win, content_win)
  if vim.api.nvim_win_is_valid(content_win) then
    write_if_modified(vim.api.nvim_win_get_buf(content_win))
    vim.api.nvim_win_close(content_win, true)
  end
  if vim.api.nvim_win_is_valid(sidebar_win) then
    vim.api.nvim_win_close(sidebar_win, true)
  end
end

M.open = function()
  module.ensure_storage_file(M.config.notes_path)
  module.ensure_storage_file(M.config.todos_path)

  local wc = M.config.win
  local width = wc.width or math.min(96, vim.o.columns - 4)
  local height = wc.height or math.min(24, vim.o.lines - 4)
  local row = wc.row or math.floor((vim.o.lines - height) / 2)
  local col = wc.col or math.floor((vim.o.columns - width) / 2)
  local sidebar_width = math.max(18, math.floor(width * 0.26))
  local content_width = width - sidebar_width - 1
  local title_pos = wc.title_pos or "center"

  local sidebar_buf = vim.api.nvim_create_buf(false, true)
  local current_section = section_by_id("notes")
  local content_buf = module.ensure_storage_buffer(current_section.path)

  local sidebar_config = {
    relative = "editor",
    width = sidebar_width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = wc.border,
    title = wc.title,
    title_pos = title_pos,
  }
  local content_config = {
    relative = "editor",
    width = content_width,
    height = height,
    row = row,
    col = col + sidebar_width + 1,
    style = "minimal",
    border = wc.border,
    title = " Notes ",
    title_pos = title_pos,
  }

  if vim.fn.has("nvim-0.10") == 1 then
    sidebar_config.footer = " [Enter] open "
    sidebar_config.footer_pos = "center"
    content_config.footer = " [n] notes  [t] todos  / search  q write+close "
    content_config.footer_pos = "center"
  end

  local sidebar_win = vim.api.nvim_open_win(sidebar_buf, false, sidebar_config)
  local content_win = vim.api.nvim_open_win(content_buf, true, content_config)

  vim.bo[sidebar_buf].buftype = "nofile"
  vim.bo[sidebar_buf].bufhidden = "wipe"
  vim.bo[sidebar_buf].modifiable = false

  vim.wo[sidebar_win].cursorline = true
  vim.wo[sidebar_win].number = false
  vim.wo[sidebar_win].signcolumn = "no"
  vim.wo[content_win].wrap = true
  vim.wo[content_win].cursorline = true
  vim.wo[content_win].number = true
  vim.wo[content_win].signcolumn = "no"

  local function map(buf, lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
  end

  local load_section

  local function map_content(buf)
    map(buf, "q", function()
      close_layout(sidebar_win, content_win)
    end, "Jishiben close")

    map(buf, "n", function()
      load_section(section_by_id("notes"))
    end, "Jishiben open notes")

    map(buf, "t", function()
      load_section(section_by_id("todos"))
    end, "Jishiben open todos")
  end

  load_section = function(section)
    if current_section.id == section.id then
      vim.api.nvim_set_current_win(content_win)
      return
    end

    write_if_modified(vim.api.nvim_win_get_buf(content_win))
    current_section = section
    local buf = module.ensure_storage_buffer(section.path)
    vim.api.nvim_win_set_buf(content_win, buf)
    map_content(buf)
    render_sidebar(sidebar_buf, section.id)
    set_content_title(content_win, section.label)
    vim.api.nvim_set_current_win(content_win)
  end

  map_content(content_buf)

  map(sidebar_buf, "q", function()
    close_layout(sidebar_win, content_win)
  end, "Jishiben close")

  map(sidebar_buf, "<CR>", function()
    local line = vim.api.nvim_get_current_line():gsub("^>%s*", ""):gsub("^%s*", "")
    load_section(section_by_label(line))
  end, "Jishiben open section")

  map(sidebar_buf, "n", function()
    load_section(section_by_id("notes"))
  end, "Jishiben open notes")

  map(sidebar_buf, "t", function()
    load_section(section_by_id("todos"))
  end, "Jishiben open todos")

  render_sidebar(sidebar_buf, current_section.id)
end

---@param text string?
M.add_note = function(text)
  module.append_line(M.get_notes_path(), text or "")
end

---@param text string?
M.add_todo = function(text)
  module.append_line(M.get_todos_path(), text or "")
end

M.clear_all = function()
  module.set_lines(M.get_notes_path(), {})
  module.set_lines(M.get_todos_path(), {})
end

return M
