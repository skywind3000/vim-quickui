# QuickUI Window 模块参考文档

> **文件路径**: `autoload/quickui/window.vim`
> **依赖**: `quickui#core`、`quickui#utils`
> **适用**: Vim 8.2+（popup window）/ Neovim 0.4+（floating window）

## 概述

`quickui#window` 是 QuickUI 的底层窗口抽象层，将 Vim 的 `popup_*` API 和 Neovim 的 `nvim_open_win` floating window API 封装为统一的面向对象接口。上层组件（如 `input.vim` 输入框）通过此模块创建和管理浮动窗口，而无需关心底层平台差异。

### 设计定位

- **不是**面向终端用户的组件，而是 QuickUI 内部的基础设施层
- 提供统一的窗口生命周期管理：创建、显示/隐藏、移动、调整大小、关闭
- 提供 buffer 内容管理和语法高亮辅助
- 自动处理 Neovim 下的边框模拟（Neovim 早期版本无内置边框支持）

## 架构说明

### Vim vs Neovim 差异封装

| 能力 | Vim 实现 | Neovim 实现 |
|------|---------|-------------|
| 窗口创建 | `popup_create()` | `nvim_open_win()` |
| 显示/隐藏 | `popup_show()` / `popup_hide()` | 关闭再重建窗口 |
| 窗口移动 | `popup_move()` | `nvim_win_set_config()` |
| 调整大小 | `popup_move()` 设置 min/max width/height | `nvim_win_set_config()` |
| 边框 | `popup_setoptions()` 内置 border 支持 | 创建独立的背景窗口模拟边框 |
| 关闭回调 | `popup_setoptions()` 的 callback | 无（手动管理） |
| 关闭按钮 | `popup_setoptions()` 的 close='button' | 在边框 buffer 中绘制关闭按钮字符 |
| 命令执行 | `quickui#core#win_execute()` | `quickui#core#win_execute()` |

### Neovim 边框模拟

Neovim 早期不支持 floating window 原生边框，因此 window.vim 使用"双窗口"方案：

1. **前景窗口**（`self.winid`）：显示实际内容，大小为 `w × h`
2. **边框窗口**（`self.info.border_winid`）：显示边框字符的背景窗口，大小为 `tw × th`（含边框和 padding），z-index 比前景窗口低 1

边框内容由 `quickui#utils#make_border()` 生成文本行，写入独立 buffer。

## 类定义：`s:window`

### 属性一览

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `w` | Number | 1 | 内容区宽度（字符数） |
| `h` | Number | 1 | 内容区高度（行数） |
| `x` | Number | 1 | 窗口左上角列坐标（从 0 开始，相对于 editor） |
| `y` | Number | 1 | 窗口左上角行坐标（从 0 开始，相对于 editor） |
| `z` | Number | 40 | 优先级/z-index（实际 z-index 为 `z+1`，边框为 `z`） |
| `winid` | Number | -1 | 当前窗口 ID（-1 表示未打开或已隐藏[Neovim]） |
| `dirty` | Number | 0 | buffer 内容是否需要更新 |
| `text` | List | [] | 当前 buffer 文本行列表 |
| `bid` | Number | -1 | 内容 buffer ID（通过 `quickui#core#buffer_alloc()` 分配） |
| `hide` | Number | 0 | 是否处于隐藏状态（0=可见, 1=隐藏） |
| `mode` | Number | 0 | 生命周期状态（0=未创建/已关闭, 1=已创建） |
| `opts` | Dict | {} | 创建选项的深拷贝 |
| `info` | Dict | {} | 初始化期间计算的内部环境数据 |
| `quit` | Number | 0 | 是否被关闭按钮关闭（仅 Vim，通过 callback 设置） |

### `info` 字典内部字段

| 字段 | 说明 |
|------|------|
| `tw` | 总宽度（含 padding + border） |
| `th` | 总高度（含 padding + border） |
| `has_padding` | 是否有 padding |
| `has_border` | 是否有边框 |
| `cmd` | 窗口创建后执行的初始化命令列表 |
| `pending_cmd` | 窗口尚未显示时缓存的待执行命令 |
| `border_winid` | Neovim 边框窗口 ID（-1 表示无） |
| `border_bid` | Neovim 边框 buffer ID（-1 表示无） |
| `nvim_opts` | Neovim 前景窗口的 `nvim_open_win()` 选项 |
| `border_opts` | Neovim 边框窗口的 `nvim_open_win()` 选项 |
| `border_init` | Neovim 边框窗口的初始化命令 |
| `sim_border` | Neovim 是否使用模拟边框 |
| `off_x` / `off_y` | Neovim 前景窗口相对于逻辑位置 (x,y) 的偏移（边框+padding 造成） |
| `syntax_cmd` | `syntax_begin/end` 期间收集的语法高亮命令 |
| `syntax_mod` | 语法高亮模式标志 |

## 构造函数

### `quickui#window#new()`

创建并返回一个新的 window 对象实例（`s:window` 的深拷贝）。

```vim
let win = quickui#window#new()
```

返回的对象尚未关联任何窗口，需要调用 `win.open()` 才会创建实际的 popup/floating window。

## 方法参考

### 生命周期方法

#### `win.open(textlist, opts)`

创建并显示窗口。如果窗口已打开，会先调用 `close()` 关闭旧窗口。

**参数**:

- `textlist`：String 或 List。窗口初始内容。String 会按 `\n` 分割为行列表。
- `opts`：Dict。创建选项，见下方 [选项参考](#选项参考)。

**流程**:
1. 调用 `close()` 确保旧窗口已关闭
2. 调用 `__prepare_opts()` 解析选项、分配 buffer、计算尺寸
3. 根据平台调用 `__vim_create()` 或 `__nvim_create()`
4. 如果 `opts.center` 为真，自动居中
5. 如果 `opts.hide` 为 0（默认），立即显示窗口

#### `win.close()`

关闭窗口并释放所有资源。

**行为**:
- Vim：调用 `popup_close()`
- Neovim：调用 `nvim_win_close()` 关闭内容窗口和边框窗口
- 释放内容 buffer 和边框 buffer（`quickui#core#buffer_free()`）
- 重置 `winid=-1`、`bid=-1`、`mode=0`、`hide=0`

#### `win.show(show)`

控制窗口可见性。

**参数**:
- `show`：Number。`1` 显示，`0` 隐藏。

**平台差异**:
- Vim：调用 `popup_show()` / `popup_hide()`（窗口 ID 不变）
- Neovim：隐藏时关闭窗口（`nvim_win_close`），显示时重新创建（`nvim_open_win`），因此 **Neovim 下隐藏/显示后 `winid` 会变化**

### 位置与尺寸方法

#### `win.move(x, y)`

移动窗口到指定位置，自动做边界裁剪确保窗口不超出屏幕。

**参数**:
- `x`：列坐标（从 0 开始）
- `y`：行坐标（从 0 开始）

**边界裁剪逻辑**:
- 如果 `x + tw > &columns`，则 `x = &columns - tw`
- 如果 `y + th > &lines`，则 `y = &lines - th`
- x 和 y 不低于 0

注意：`tw`/`th` 是包含 border 和 padding 的总尺寸。

#### `win.center(...)`

将窗口居中显示。

**参数**:
- `style`（可选，默认 0）：
  - `0`：偏上居中，垂直方向取屏幕 38% 处为中心（更符合视觉习惯）
  - `1`：标准居中，垂直方向取 80% 区域的中心

#### `win.resize(w, h)`

调整窗口内容区大小。

**参数**:
- `w`：新的内容宽度
- `h`：新的内容高度

**行为**:
- 更新 `self.w`、`self.h` 和 `info.tw`、`info.th`
- Vim：通过 `popup_move()` 设置 min/max width/height
- Neovim：通过 `nvim_win_set_config()` 更新，同时重建边框 buffer 内容

### 内容管理方法

#### `win.set_text(textlist)`

设置窗口全部文本内容。

**参数**:
- `textlist`：String（按 `\n` 分割）或 List（直接使用）。

会立即调用 `update()` 写入 buffer。

#### `win.set_line(index, text [, refresh])`

设置指定行的文本。

**参数**:
- `index`：行号（从 0 开始）
- `text`：行内容字符串
- `refresh`（可选，默认 1）：是否立即刷新 buffer

如果 `index` 超过当前行数，会自动用空行填充到足够的行数。

#### `win.get_line(index)`

获取指定行的文本。超出范围返回空字符串。

#### `win.update()`

将 `self.text` 列表写入 buffer（`quickui#core#buffer_update()`）。通常在修改 `self.text` 后调用。

### 命令执行方法

#### `win.execute(cmdlist)`

在窗口上下文中执行 Ex 命令。

**参数**:
- `cmdlist`：String（按 `\n` 分割）或 List。要执行的命令列表。

**行为**:
- 如果窗口已打开（`winid >= 0`），立即通过 `quickui#core#win_execute()` 执行
- 如果窗口尚未显示，命令会被追加到 `info.pending_cmd`，在窗口显示时自动执行

这个延迟执行机制确保了在窗口创建前设置的命令不会丢失。

### 语法高亮方法

这组方法提供批量语法高亮的 begin/end 模式，避免频繁调用 win_execute。

#### `win.syntax_begin([mod])`

开始语法高亮批次。初始化命令列表并清除已有语法。

**参数**:
- `mod`（可选，默认 1）：传递给 `quickui#core#high_region()` 的模式标志

#### `win.syntax_region(color, x1, y1, x2, y2)`

添加一个高亮区域到当前批次。

**参数**:
- `color`：高亮组名称（如 `'QuickInput'`、`'QuickCursor'`）
- `x1, y1`：起始位置（从 0 开始）
- `x2, y2`：结束位置（从 0 开始）

坐标会自动 +1 转换为 Vim 的 1-based 行列号。如果 y1==y2 且 x1>=x2，则跳过（空区域）。

#### `win.syntax_end()`

结束语法高亮批次，执行累积的所有高亮命令。

**典型使用模式**:

```vim
call win.syntax_begin()
call win.syntax_region('QuickSel', 0, 2, 10, 2)
call win.syntax_region('QuickKey', 0, 3, 5, 3)
call win.syntax_end()
```

### 鼠标交互方法

#### `win.mouse_click()`

处理鼠标点击事件，返回点击在窗口内容区中的相对坐标。

**返回值**: Dict `{'x': col, 'y': row}`，坐标从 0 开始。如果点击不在本窗口内，返回 `{'x': -1, 'y': -1}`。

有边框时会自动减去边框偏移。

### 其他方法

#### `win.refresh()`

强制刷新窗口显示。Vim 下调用 `popup_setoptions(winid, {})`，然后 `redraw`。

## 选项参考

通过 `win.open(textlist, opts)` 的第二个参数传递：

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `x` | Number | 1 | 窗口左上角列坐标（0-based） |
| `y` | Number | 1 | 窗口左上角行坐标（0-based） |
| `z` | Number | 40 | z-index 优先级 |
| `w` | Number | 1 | 内容区宽度 |
| `h` | Number | -1 | 内容区高度（-1 表示自动取 textlist 行数） |
| `hide` | Number | 0 | 创建后是否隐藏（0=立即显示, 1=隐藏） |
| `wrap` | Number | 0 | 是否自动换行 |
| `color` | String | `'QuickBG'` | 窗口内容区高亮组 |
| `border` | Number | 0 | 边框样式（0=无边框，正数对应 `quickui#core#border_auto()` 的样式） |
| `bordercolor` | String | `'QuickBorder'` | 边框高亮组（仅有边框时生效） |
| `padding` | List | [0,0,0,0] | 内边距 [top, right, bottom, left] |
| `center` | Number | 0 | 创建后是否自动居中 |
| `title` | String | 无 | 窗口标题（显示在顶部边框中） |
| `button` | Number | 0 | 是否显示关闭按钮 |
| `drag` | Number | 0 | 是否允许拖拽（仅 Vim） |
| `cursorline` | Number | 0 | 是否显示光标行高亮 |
| `number` | Number | 0 | 是否显示行号 |
| `syntax` | String | 无 | 设置 filetype 以启用语法高亮 |
| `tabstop` | Number | 4 | Tab 显示宽度 |
| `list` | Number | 无 | 是否启用 list 模式 |
| `focusable` | Number | 0 | 是否可聚焦（仅 Neovim） |
| `command` | String/List | 无 | 窗口创建后执行的额外 Ex 命令 |

## 依赖的 quickui#core 函数

| 函数 | 用途 |
|------|------|
| `quickui#core#buffer_alloc()` | 分配一个可复用的 scratch buffer |
| `quickui#core#buffer_free(bid)` | 释放 buffer 回池 |
| `quickui#core#buffer_update(bid, lines)` | 更新 buffer 内容 |
| `quickui#core#win_execute(winid, cmdlist)` | 在指定窗口上下文中执行命令 |
| `quickui#core#popup_local(winid)` | 获取窗口关联的局部数据字典 |
| `quickui#core#popup_clear(winid)` | 清除窗口关联的局部数据 |
| `quickui#core#border_auto(border)` | 获取边框字符列表 |
| `quickui#core#high_region(color, y1, x1, y2, x2, mod)` | 生成语法高亮命令字符串 |
| `quickui#utils#make_border(w, h, border, title, button)` | 生成边框文本行（Neovim 边框模拟用） |

## 使用示例

### 基础窗口

```vim
let win = quickui#window#new()
call win.open(['Hello, World!', 'Line 2', 'Line 3'], {
    \ 'w': 30, 'h': 3,
    \ 'x': 10, 'y': 5,
    \ 'border': 1,
    \ 'title': ' Demo ',
    \ 'color': 'QuickBG',
    \ })

" 修改内容
call win.set_line(1, 'Updated Line 2')

" 移动窗口
call win.move(20, 10)

" 关闭
call win.close()
```

### 延迟命令执行

```vim
let win = quickui#window#new()

" 窗口未创建时设置命令，会被缓存
call win.execute('setl cursorline')

" 创建窗口时，缓存的命令会自动执行
call win.open(lines, {'w': 40, 'h': 10, 'hide': 1})

" 显示窗口
call win.show(1)
```

### 语法高亮

```vim
call win.syntax_begin()
call win.syntax_region('QuickSel', 0, 0, 20, 0)   " 第1行 0-20 列
call win.syntax_region('QuickKey', 0, 1, 5, 1)     " 第2行 0-5 列
call win.syntax_end()
```

## 注意事项

1. **Neovim 下 winid 不稳定**：`show(0)` 会关闭窗口（winid 置为 -1），`show(1)` 会重新创建窗口获得新的 winid。不要缓存 winid 长期使用。
2. **坐标系**：`x`/`y` 使用 0-based 坐标，但 Vim 的 popup API 使用 1-based 坐标，window.vim 内部做了 +1 转换。
3. **边框尺寸**：`tw`/`th` 是包含 border + padding 的总尺寸，`w`/`h` 是纯内容区尺寸。`move()` 的边界裁剪基于 `tw`/`th`。
4. **buffer 管理**：window 使用 `quickui#core#buffer_alloc/free` 进行 buffer 池管理，不要直接操作 buffer，也不要在 `close()` 后继续使用 `bid`。
5. **quit 属性**：仅 Vim 有效，当用户点击关闭按钮时通过 `popup_exit` 回调设为 1。Neovim 无此机制。
6. **mode 属性**：`0` 表示窗口未创建或已关闭，`1` 表示已创建。大部分方法在 `mode==0` 时会提前返回。
