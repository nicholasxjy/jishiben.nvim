# jishiben.nvim

一个轻量的 Neovim 记事本插件：

- 所有记录保存在单个 JSON 文件中
- 使用浮动窗口（popup）展示，markdown list 格式
- 在浮动窗口内按 `<CR>` 切换完成状态

## 功能

- `:JishibenAdd [内容]` — 新增一条待办（不传内容时弹出输入框）
- `:JishibenOpen` — 浮动窗口展示所有待办
- `:JishibenToggle` — 在浮动窗口内切换当前行完成状态

浮动窗口快捷键：

- `<CR>` 切换 checkbox
- `q` 关闭窗口

## 安装

### lazy.nvim

```lua
{
  "nick/jishiben.nvim",
  config = function()
    require("jishiben").setup({
      -- 默认路径：vim.fn.stdpath("data") .. "/jishiben.json"
      storage_path = vim.fn.stdpath("data") .. "/jishiben.json",
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
  storage_path = vim.fn.stdpath("data") .. "/jishiben.json",
})
```

### 配置项

- `storage_path`:
  - 类型：`string`
  - 说明：JSON 文件路径
  - 默认值：`vim.fn.stdpath("data") .. "/jishiben.json"`

## 使用示例

```vim
:JishibenAdd 买牛奶
:JishibenAdd 写周报
:JishibenOpen
```

浮动窗口中显示：

```markdown
- [ ] 买牛奶
- [ ] 写周报
```

光标移到任务行按 `<CR>` 即可切换完成状态。

## 开发与测试

```bash
make test
```

## 许可证

MIT
