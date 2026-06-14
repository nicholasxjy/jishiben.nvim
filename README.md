# jishiben.nvim

A lightweight notebook plugin for Neovim. Notes live in a single markdown file and are edited from a two-pane TUI floating layout.

![demo](assets/demo1.gif)

## Features

- Single markdown file storage (`jishiben.md` by default)
- TUI layout with a left sidebar for `Notes` and `Todos`
- Right content pane edits the selected section directly
- Quick note and todo capture
- Buffer-local mappings for switching sections, adding notes, adding todos, and toggling tasks
- Markdown workflow stays compatible with normal text editing

## Installation

### lazy.nvim

```lua
{
  "nicholasxjy/jishiben.nvim",
  event = "VeryLazy",
  opts = {
    win = {
      title = "JISHIBEN",
      width = 40,
    },
  },
  keys = {
    { "<leader>Jp", "<cmd>JishibenOpen<cr>", desc = "Jishiben Open" },
    { "<leader>Jn", "<cmd>JishibenNote ", desc = "Jishiben Note" },
    { "<leader>Jt", "<cmd>JishibenTodo ", desc = "Jishiben Todo" },
    { "<leader>Jc", "<cmd>JishibenClear<cr>", desc = "Jishiben Clear" },
  },
}
```

### packer.nvim

```lua
use({
  "nicholasxjy/jishiben.nvim",
  config = function()
    require("jishiben").setup()
  end,
})
```

## Commands

| Command | Description |
| --- | --- |
| `:JishibenOpen` | Open the real markdown file in a floating window |
| `:JishibenNote {text}` | Capture a timestamped note under `## Capture` |
| `:JishibenTodo {text}` | Add an unchecked task under `## Todo` |
| `:JishibenClear` | Clear the markdown file |

## Configuration

All options are optional. Below are the defaults:

```lua
require("jishiben").setup({
  storage_path = vim.fn.stdpath("data") .. "/jishiben.md",
  win = {
    title = " jishiben.nvim ",
    title_pos = "center",
    border = "single",
    -- width = 96,
    -- height = 24,
    -- row = 2,
    -- col = 10,
  },
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `storage_path` | `string` | `stdpath("data") .. "/jishiben.md"` | Path to the markdown file |
| `win.title` | `string` | `" jishiben.nvim "` | Sidebar floating window title |
| `win.title_pos` | `string` | `"center"` | Title position |
| `win.border` | `string\|string[]` | `"single"` | Border style |
| `win.width` | `number\|nil` | `nil` | Total layout width (auto max 96) |
| `win.height` | `number\|nil` | `nil` | Layout height (auto max 24) |
| `win.row` | `number\|nil` | `nil` | Window row offset (auto centered) |
| `win.col` | `number\|nil` | `nil` | Window column offset (auto centered) |

## Usage

```vim
:JishibenOpen
```

`JishibenOpen` creates a left sidebar and a right content pane. The sidebar lists `Notes` and `Todos`; the right pane title follows the selected section and its buffer is editable. `:write`, switching sections, and `q` sync the right pane back to the markdown storage file.

Example `jishiben.md`:

```md
# Jishiben

## Notes
- 09:30  idea

## Todos
- [ ] write report
```

When the floating layout opens, normal editing happens in the right content pane. Add, reorder, rewrite, or toggle items with normal markdown editing commands. Press `q` to close both panes; modified content is written before closing.

Content pane mappings:

| Key | Action |
| --- | --- |
| `n` | Add a timestamped note under `Notes` and enter Insert mode |
| `t` | Add an unchecked task under `Todos` and enter Insert mode |
| `<Space>x` | Toggle the current task between `[ ]` and `[x]` |
| `q` | Write modified content and close the floating layout |

Sidebar mappings:

| Key | Action |
| --- | --- |
| `<Enter>` | Open the selected sidebar section |
| `n` | Open `Notes` |
| `t` | Open `Todos` |
| `q` | Write modified content and close the floating layout |

`JishibenClear` wipes the file content while keeping the file itself.

## Development

```bash
make test
```

## License

MIT
