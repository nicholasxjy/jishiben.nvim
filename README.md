# jishiben.nvim

A lightweight notebook plugin for Neovim. Notes are stored in a single markdown file and edited directly inside a floating window.

![demo](assets/demo.gif)

## Features

- Single markdown file storage (`jishiben.md` by default)
- Floating window opens the real markdown file for direct editing
- Markdown checkbox workflow stays compatible with normal text editing
- Optional [snacks.nvim](https://github.com/folke/snacks.nvim) picker for checkbox items only

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
    { "<leader>Ja", "<cmd>JishibenAdd<cr>", desc = "Jishiben Add" },
    { "<leader>Jp", "<cmd>JishibenOpen<cr>", desc = "Jishiben Open" },
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
| `:JishibenAdd [text]` | Append `- [ ] text` to the markdown file |
| `:JishibenOpen` | Open the real markdown file in a floating window |
| `:JishibenToggle` | Toggle the checkbox on the current line in `jishiben.md` |
| `:JishibenDelete` | Delete the current line in `jishiben.md` |
| `:JishibenPick` | Open checkbox lines in the snacks.nvim picker |
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

## Usage

```vim
:JishibenAdd buy milk
:JishibenOpen
```

Example `jishiben.md`:

```md
# Inbox

- [ ] buy milk
- [x] write report
```

When the floating window opens, you are editing the actual markdown file. Use normal markdown editing commands, `:write`, and any file-local tooling you already use. Press `q` to close the floating window; modified content is written before closing.

`JishibenToggle` and `JishibenDelete` are convenience commands for the current line inside the markdown buffer.

## Snacks Picker

If you have [snacks.nvim](https://github.com/folke/snacks.nvim) installed, `:JishibenPick` lists markdown checkbox lines only. Press `<CR>` to toggle a checkbox, or `<C-x>` to delete that checkbox line.

![snacks-picker](assets/snacks-picker.png)

```lua
-- lazy.nvim keys example
{ "<leader>Jf", "<cmd>JishibenPick<cr>", desc = "Jishiben Pick" },
```

You can also call it directly from Lua:

```lua
require("jishiben.picker").open()
```

## Development

```bash
make test
```

## License

MIT
