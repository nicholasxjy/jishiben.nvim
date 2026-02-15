# jishiben.nvim

一个轻量的 Neovim 记事本插件：

- 所有记录保存在单个 JSON 文件中
- 使用浮动窗口（popup）展示，markdown list 格式
- 每条记录显示创建时间（yyyy-MM-dd HH:mm）
- 在浮动窗口内按 `<CR>` 切换完成状态

## 功能

- `:JishibenAdd [内容]` — 新增一条待办（不传内容时弹出输入框）
- `:JishibenOpen` — 浮动窗口展示所有待办
- `:JishibenToggle` — 在浮动窗口内切换当前行完成状态
- `:JishibenClear` — 清除所有记录

浮动窗口快捷键：

- `<CR>` 切换 checkbox
- `q` 关闭窗口

## 安装

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

## 配置

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

### 配置项

- `storage_path`:
  - 类型：`string`
  - 说明：JSON 文件路径
  - 默认值：`vim.fn.stdpath("data") .. "/jishiben.json"`
- `win.title`:
  - 类型：`string`
  - 默认值：`" Jishiben "`
- `win.title_pos`:
  - 类型：`string`
  - 默认值：`"center"`
- `win.border`:
  - 类型：`string|string[]`
  - 默认值：`"rounded"`
- `win.width`:
  - 类型：`number|nil`
  - 说明：浮动窗口宽度
  - 默认值：`nil`（自动计算，最大 60）
- `win.height`:
  - 类型：`number|nil`
  - 说明：浮动窗口高度
  - 默认值：`nil`（自动适配记录数量）

## 使用示例

```vim
:JishibenAdd 买牛奶
:JishibenAdd 写周报
:JishibenOpen
```

浮动窗口中显示：

```markdown
- [ ] 2026-02-15 14:30 买牛奶
- [ ] 2026-02-15 14:35 写周报
```

光标移到任务行按 `<CR>` 即可切换完成状态。

## 开发与测试

```bash
make test
```

## 许可证

MIT
