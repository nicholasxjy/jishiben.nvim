# jishiben.nvim

A lightweight notebook plugin for Neovim. Notes are stored in a single JSON file and displayed in a floating window as a markdown checkbox list.

## Features

- Single JSON file storage
- Floating window (popup) with markdown checkbox list
- Creation time displayed on each entry
- Toggle completion with `<CR>`, close with `q`

## Installation

### lazy.nvim

```lua
{
  "nicholasxjy/jishiben.nvim",
  config = function()
    require("jishiben").setup()
  end,
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
| `:JishibenAdd [text]` | Add a note (prompts if text omitted) |
| `:JishibenOpen` | Open popup to display all notes |
| `:JishibenToggle` | Toggle checkbox in popup |
| `:JishibenClear` | Clear all notes |

## Configuration

All options are optional. Below are the defaults:

```lua
require("jishiben").setup({
  storage_path = vim.fn.stdpath("data") .. "/jishiben.json",
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
| `storage_path` | `string` | `stdpath("data") .. "/jishiben.json"` | Path to the JSON file |
| `win.title` | `string` | `" Jishiben "` | Popup title |
| `win.title_pos` | `string` | `"center"` | Title position |
| `win.border` | `string\|string[]` | `"rounded"` | Border style |
| `win.width` | `number\|nil` | `nil` | Window width (auto max 80) |
| `win.height` | `number\|nil` | `nil` | Window height (auto min 20) |

## Usage

```vim
:JishibenAdd buy milk
:JishibenAdd write report
:JishibenOpen
```

The popup displays:

```
- [ ] **buy milk**    2026-02-15 14:30
- [ ] **write report**    2026-02-15 14:35
```

Move the cursor to a line and press `<CR>` to toggle its status.

## Development

```bash
make test
```

## License

MIT
