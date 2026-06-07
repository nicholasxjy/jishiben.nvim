# jishiben.nvim

A lightweight notebook plugin for Neovim. Notes live in a single markdown file and are edited directly inside a floating window.

![demo](assets/demo1.gif)

## Features

- Single markdown file storage (`jishiben.md` by default)
- Floating window opens the real markdown file for direct editing
- Quick note and todo capture
- Buffer-local Vim mappings for adding notes, adding todos, and toggling tasks
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
    title = " Jishiben ",
    title_pos = "center",
    border = "rounded",
    -- width = 80,
    -- height = 20,
    -- row = 2,
    -- col = 10,
  },
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `storage_path` | `string` | `stdpath("data") .. "/jishiben.md"` | Path to the markdown file |
| `win.title` | `string` | `" Jishiben "` | Floating window title |
| `win.title_pos` | `string` | `"center"` | Title position |
| `win.border` | `string\|string[]` | `"rounded"` | Border style |
| `win.width` | `number\|nil` | `nil` | Window width (auto max 80) |
| `win.height` | `number\|nil` | `nil` | Window height (auto min 20) |
| `win.row` | `number\|nil` | `nil` | Window row offset (auto centered) |
| `win.col` | `number\|nil` | `nil` | Window column offset (auto centered) |

## Usage

```vim
:JishibenOpen
```

Example `jishiben.md`:

```md
# Inbox

- [ ] buy milk
- [x] write report
```

When the floating window opens, you are editing the actual markdown file. Add, reorder, rewrite, or toggle items with normal markdown editing commands. Press `q` to close the floating window; modified content is written before closing.

Buffer-local mappings inside the floating window:

| Key | Action |
| --- | --- |
| `i` | Add a timestamped note under `## Capture` and enter Insert mode |
| `o` | Add an unchecked task under `## Todo` and enter Insert mode |
| `<Space>x` | Toggle the current task between `[ ]` and `[x]` |
| `q` | Write modified content and close the floating window |

`JishibenClear` wipes the file content while keeping the file itself.

## Development

```bash
make test
```

## License

MIT
