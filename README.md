# jishiben.nvim

A lightweight notebook plugin for Neovim:

- All notes stored in a single JSON file
- Displayed in a floating window with markdown checkbox list
- Each entry shows its creation time (yyyy-MM-dd HH:mm)
- Press `<CR>` in the popup to toggle completion status

## Commands

- `:JishibenAdd [text]` — Add a new note (prompts for input if text is omitted)
- `:JishibenOpen` — Open the floating window to display all notes
- `:JishibenToggle` — Toggle the checkbox of the current line in the popup
- `:JishibenClear` — Clear all notes

Popup keymaps:

- `<CR>` Toggle checkbox
- `q` Close window

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

## Configuration

```lua
require("jishiben").setup({
  storage_path = vim.fn.stdpath("data") .. "/jishiben.json",
  win = {
    title = " Jishiben ",
    title_pos = "center",
    border = "rounded",
    width = 60,
    height = 20,
  },
})
```

### Options

- `storage_path`:
  - Type: `string`
  - Description: Path to the JSON file
  - Default: `vim.fn.stdpath("data") .. "/jishiben.json"`
- `win.title`:
  - Type: `string`
  - Default: `" Jishiben "`
- `win.title_pos`:
  - Type: `string`
  - Default: `"center"`
- `win.border`:
  - Type: `string|string[]`
  - Default: `"rounded"`
- `win.width`:
  - Type: `number|nil`
  - Description: Floating window width
  - Default: `nil` (auto-calculated, max 60)
- `win.height`:
  - Type: `number|nil`
  - Description: Floating window height
  - Default: `nil` (fits the number of notes)

## Usage

```vim
:JishibenAdd buy milk
:JishibenAdd write report
:JishibenOpen
```

The popup displays:

```markdown
- [ ] 2026-02-15 14:30 buy milk
- [ ] 2026-02-15 14:35 write report
```

Move the cursor to a line and press `<CR>` to toggle its completion status.

## Development

```bash
make test
```

## License

MIT
