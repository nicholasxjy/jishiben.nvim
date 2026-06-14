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
---@field storage_path string
---@field win JishibenWinConfig

local M = {}

---@type JishibenConfig
M.config = {
  storage_path = vim.fn.stdpath("data") .. "/jishiben.md",
  win = {
    title = " jishiben.nvim ",
    title_pos = "center",
    border = "single",
  },
}

local sections = {
  {
    id = "notes",
    label = "Notes",
    heading = module.headings.notes,
    prefix = function()
      return "- " .. os.date("%H:%M") .. "  "
    end,
  },
  {
    id = "todos",
    label = "Todos",
    heading = module.headings.todos,
    prefix = function()
      return "- [ ] "
    end,
  },
}

local function section_by_id(id)
  for _, section in ipairs(sections) do
    if section.id == id then
      return section
    end
  end
  return sections[1]
end

local function section_by_label(label)
  for _, section in ipairs(sections) do
    if section.label == label then
      return section
    end
  end
  return sections[1]
end

local function start_insert_at(lnum, col)
  vim.api.nvim_win_set_cursor(0, { lnum, col })
  vim.cmd("startinsert")
end

local function note_prefix()
  return sections[1].prefix()
end

local function todo_prefix()
  return sections[2].prefix()
end

---@param args JishibenConfig?
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

---@return string
M.get_storage_path = function()
  return M.config.storage_path
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

local function content_lines(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if module.is_empty_lines(lines) then
    return { "" }
  end
  return lines
end

local function mark_clean(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.bo[buf].modified = false
  end
end

local function sync_content(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local section = section_by_id(vim.b[buf].jishiben_section_id)
  module.set_section_lines(M.get_storage_path(), section.heading, content_lines(buf))
  mark_clean(buf)
end

local function render_sidebar(buf, current_id)
  local lines = { "jishiben.nvim", "" }

  for _, section in ipairs(sections) do
    local marker = section.id == current_id and "> " or "  "
    table.insert(lines, marker .. section.label)
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
end

local function close_layout(sidebar_win, content_win, content_buf)
  sync_content(content_buf)

  if vim.api.nvim_win_is_valid(content_win) then
    vim.api.nvim_win_close(content_win, true)
  end
  if vim.api.nvim_win_is_valid(sidebar_win) then
    vim.api.nvim_win_close(sidebar_win, true)
  end
end

M.open = function()
  local path = M.get_storage_path()
  module.ensure_default_content(path)

  local wc = M.config.win
  local width = wc.width or math.min(96, vim.o.columns - 4)
  local height = wc.height or math.min(24, vim.o.lines - 4)
  local row = wc.row or math.floor((vim.o.lines - height) / 2)
  local col = wc.col or math.floor((vim.o.columns - width) / 2)
  local sidebar_width = math.max(18, math.floor(width * 0.26))
  local content_width = width - sidebar_width - 1
  local title_pos = wc.title_pos or "center"

  local sidebar_buf = vim.api.nvim_create_buf(false, true)
  local content_buf = vim.api.nvim_create_buf(false, true)

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
    content_config.footer = " [n] note  [t] todo  [Space]x toggle  / search  q write+close "
    content_config.footer_pos = "center"
  end

  local sidebar_win = vim.api.nvim_open_win(sidebar_buf, false, sidebar_config)
  local content_win = vim.api.nvim_open_win(content_buf, true, content_config)
  local current_section = sections[1]

  vim.bo[sidebar_buf].buftype = "nofile"
  vim.bo[sidebar_buf].bufhidden = "wipe"
  vim.bo[sidebar_buf].modifiable = false
  vim.bo[content_buf].buftype = "acwrite"
  vim.bo[content_buf].bufhidden = "wipe"
  vim.bo[content_buf].filetype = "markdown"
  vim.api.nvim_buf_set_name(content_buf, "jishiben://" .. current_section.id .. "/" .. content_buf)

  vim.wo[sidebar_win].cursorline = true
  vim.wo[sidebar_win].number = false
  vim.wo[sidebar_win].signcolumn = "no"
  vim.wo[content_win].wrap = true
  vim.wo[content_win].cursorline = true
  vim.wo[content_win].number = true
  vim.wo[content_win].signcolumn = "no"

  local function load_section(section)
    if vim.b[content_buf].jishiben_section_id then
      sync_content(content_buf)
    end
    current_section = section
    vim.b[content_buf].jishiben_section_id = section.id
    vim.bo[content_buf].modifiable = true
    vim.api.nvim_buf_set_lines(content_buf, 0, -1, false, module.get_section_lines(path, section.heading))
    mark_clean(content_buf)
    render_sidebar(sidebar_buf, section.id)
    set_content_title(content_win, section.label)
    if vim.api.nvim_win_is_valid(content_win) then
      vim.api.nvim_set_current_win(content_win)
      vim.api.nvim_win_set_cursor(content_win, { 1, 0 })
    end
  end

  local function insert_entry(section)
    if current_section.id ~= section.id then
      load_section(section)
    end

    local prefix = section.prefix()
    local line_count = vim.api.nvim_buf_line_count(content_buf)
    local last_line = vim.api.nvim_buf_get_lines(content_buf, line_count - 1, line_count, false)[1] or ""
    local lnum = line_count

    if last_line ~= "" then
      lnum = line_count + 1
      vim.api.nvim_buf_set_lines(content_buf, line_count, line_count, false, { prefix })
    else
      vim.api.nvim_buf_set_lines(content_buf, line_count - 1, line_count, false, { prefix })
    end

    vim.api.nvim_set_current_win(content_win)
    start_insert_at(lnum, #prefix)
  end

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = content_buf,
    callback = function()
      sync_content(content_buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
    buffer = content_buf,
    callback = function()
      sync_content(content_buf)
    end,
  })

  local function map(buf, lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
  end

  map(content_buf, "q", function()
    close_layout(sidebar_win, content_win, content_buf)
  end, "Jishiben close")

  map(content_buf, "n", function()
    insert_entry(section_by_id("notes"))
  end, "Jishiben add note")

  map(content_buf, "t", function()
    insert_entry(section_by_id("todos"))
  end, "Jishiben add todo")

  map(content_buf, "<Space>x", function()
    M.toggle_todo()
  end, "Jishiben toggle todo")

  map(sidebar_buf, "q", function()
    close_layout(sidebar_win, content_win, content_buf)
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

  load_section(current_section)
end

---@param text string?
M.add_note = function(text)
  module.insert_under_heading(M.get_storage_path(), module.headings.notes, note_prefix() .. (text or ""))
end

---@param text string?
M.add_todo = function(text)
  module.insert_under_heading(M.get_storage_path(), module.headings.todos, todo_prefix() .. (text or ""))
end

M.toggle_todo = function()
  local buf = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ""
  local toggled = line:gsub("%[ %]", "[x]", 1)

  if toggled == line then
    toggled = line:gsub("%[x%]", "[ ]", 1)
  end
  if toggled == line then
    toggled = line:gsub("^(%s*%-)%s*", "%1 [ ] ", 1)
  end
  if toggled == line then
    toggled = todo_prefix() .. line
  end

  vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, false, { toggled })
end

M.clear_all = function()
  module.clear_all(M.get_storage_path())
end

return M
