# jishiben.nvim

一个轻量的 Neovim 记事本插件：

- 输入内容后保存到本地 Markdown 文件
- 使用 `- [ ]` / `- [x]` 任务格式展示
- 在编辑区可一键切换完成状态（check）

## 功能

- `:JishibenAdd [内容]`
  - 追加一条待办到本地文件
  - 不传内容时会弹出输入框
- `:JishibenOpen`
  - 打开本地 Markdown 记事本
- `:JishibenToggle`
  - 在当前行切换 `- [ ]` 和 `- [x]`

## 安装

### lazy.nvim

```lua
{
  "nick/jishiben.nvim",
  config = function()
    require("jishiben").setup({
      -- 默认路径：vim.fn.stdpath("data") .. "/jishiben.md"
      storage_path = vim.fn.stdpath("data") .. "/jishiben.md",
    })
  end,
}
```

### packer.nvim

```lua
use({
  "nick/jishiben.nvim",
  config = function()
    require("jishiben").setup()
  end,
})
```

## 配置

```lua
require("jishiben").setup({
  storage_path = vim.fn.stdpath("data") .. "/jishiben.md",
})
```

### 配置项

- `storage_path`:
  - 类型：`string`
  - 说明：本地 Markdown 文件路径
  - 默认值：`vim.fn.stdpath("data") .. "/jishiben.md"`

## 使用示例

```vim
:JishibenAdd 买牛奶
:JishibenAdd 写周报
:JishibenOpen
```

打开文件后，光标放在任务行执行：

```vim
:JishibenToggle
```

会在以下两种状态间切换：

```markdown
- [ ] 写周报
- [x] 写周报
```

## 开发与测试

```bash
make test
```

## 许可证

MIT
