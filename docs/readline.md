# QuickUI Readline 模块参考文档

> **文件路径**: `autoload/quickui/readline.vim`
> **依赖**: 无外部依赖（纯 VimL 实现）
> **适用**: Vim 8.0+ / Neovim 0.4+

## 概述

`quickui#readline` 是 QuickUI 的单行文本编辑引擎，提供类似 Readline/Emacs 风格的行编辑能力。它管理一个字符级别的编辑缓冲区，支持光标移动、文本插入/删除、可视选择、历史记录、光标闪烁、以及视口滚动渲染。

该模块是 `quickui#input` 输入框的核心依赖——input.vim 将用户按键通过 `rl.feed()` 传递给 readline 对象，readline 处理编辑逻辑后通过 `rl.render()` 输出渲染结果，input.vim 再将渲染结果绘制到 popup/floating window 中。

### 设计特点

- **字符级编辑**：内部使用 `str2list()` / `list2str()` 将文本拆为 Unicode 码点数组，天然支持 CJK 等多字节字符
- **宽度感知**：维护每个字符的 `strdisplaywidth`，正确处理全角/半角混排
- **可视选择**：支持 Shift+方向键的选区操作，类似现代编辑器的行为
- **视口滚动**：当文本超出显示宽度时，自动滑动视口跟随光标
- **独立于 UI**：readline 本身不涉及任何窗口操作，纯粹管理编辑状态和渲染输出

## 数据模型

readline 将一行文本表示为三个并行数组：

```
text:  "Hello世界"
code:  [72, 101, 108, 108, 111, 19990, 30028]    " Unicode 码点
wide:  [1,  1,   1,   1,   1,   2,     2    ]    " 各字符的显示宽度
size:  7                                          " 字符个数
cursor: 5                                         " 光标位于 '世' 上
```

- `code`：`str2list()` 的结果，每个元素是一个 Unicode 码点
- `wide`：每个字符的 `strdisplaywidth()`，用于视口计算
- `size`：`len(code)`，字符个数（非字节数）
- `cursor`：光标所在字符位置（0-based，范围 `[0, size]`，等于 size 时光标在末尾）

## 类定义：`s:readline`

### 属性一览

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `cursor` | Number | 0 | 光标位置（字符索引，0-based） |
| `code` | List | [] | 字符码点数组（`str2list()` 结果） |
| `wide` | List | [] | 每个字符的显示宽度 |
| `size` | Number | 0 | 字符总数 |
| `text` | String | '' | 文本缓存（`update()` 后同步） |
| `dirty` | Number | 0 | `code` 是否已修改但 `text` 未同步 |
| `select` | Number | -1 | 可视选择起始位置（-1 表示无选区） |
| `history` | List | [] | 历史记录列表 |
| `index` | Number | 0 | 当前历史记录指针（0 为最新） |
| `timer` | Number | -1 | 光标闪烁计时器起点（毫秒时间戳，-1 表示重置） |

### 关于 `dirty` 和 `text`

`code` 数组是编辑操作的主数据源。每次修改 `code` 后 `dirty` 会置为 1，但 `text` 字符串不会立即更新（避免频繁的 `list2str` 转换）。调用 `update()` 会同步 `text` 并清除 `dirty`。

`text` 主要用于：
- 返回最终输入结果
- `history_save()` 保存历史时使用

## 构造函数

### `quickui#readline#new()`

创建并返回一个新的 readline 对象实例（`s:readline` 的深拷贝）。

```vim
let rl = quickui#readline#new()
```

## 方法参考

### 文本操作方法

#### `rl.set(text)`

设置整个编辑缓冲区的内容。

**参数**: `text` - 字符串。

**行为**: 将 text 拆解为 `code` 和 `wide` 数组，更新 `size`，置 `dirty=1`，然后对当前 cursor 做边界修正。

#### `rl.update()`

将 `code` 数组同步回 `text` 字符串。

**返回值**: 同步后的文本字符串。

**注意**: 这是获取编辑结果的标准方法。不要直接读取 `self.text`，因为它可能是过期的。

#### `rl.insert(text)`

在光标当前位置插入文本。

**参数**: `text` - 要插入的字符串。

**行为**: 将 text 拆为码点和宽度数组，插入到 `code` 和 `wide` 的 cursor 位置，cursor 后移到插入文本之后。

#### `rl.delete(size)`

删除光标位置及之后的 size 个字符（类似 Delete 键）。

**参数**: `size` - 要删除的字符数。超出可用范围时自动裁剪。

光标位置不变。

#### `rl.backspace(size)`

删除光标之前的 size 个字符（类似 Backspace 键）。

**参数**: `size` - 要删除的字符数。超出可用范围时自动裁剪。

光标前移 size 个位置。

#### `rl.replace(text)`

替换光标位置开始的字符。先删除 `strchars(text)` 个字符，再插入 text。

### 光标移动方法

#### `rl.move(pos)`

将光标移动到指定位置，自动裁剪到 `[0, size]` 范围。同时重置闪烁计时器。

**返回值**: 裁剪后的实际位置。

#### `rl.seek(pos, mode)`

相对/绝对光标定位（类似 C 的 `fseek`）。

**参数**:
- `pos`：偏移量
- `mode`：基准点
  - `0`：从行首开始（绝对位置）
  - `1`：从当前位置开始（相对偏移）
  - `2`：从行尾开始（`size + pos`）

**示例**:
```vim
call rl.seek(0, 0)    " 跳到行首
call rl.seek(0, 2)    " 跳到行尾
call rl.seek(-1, 1)   " 左移一个字符
call rl.seek(1, 1)    " 右移一个字符
```

#### `rl.is_eol()`

返回光标是否在行尾（`cursor >= size`）。

### 文本提取方法

#### `rl.extract(locate)`

提取光标相对位置的文本。

**参数**:
- `locate`：
  - `-1`：光标之前的所有文本
  - `0`：光标所在的字符
  - `1`：光标之后的所有文本

**返回值**: 提取的文本字符串。

### 可视选择方法

选区由 `select` 和 `cursor` 两个位置界定。`select` 是选区的锚点（起始位置），`cursor` 是活动端。`select == -1` 表示无选区。

#### `rl.visual_range()`

返回选区的规范化范围 `[start, end)`（start <= end）。无选区时返回 `[-1, -1]`。

#### `rl.visual_text()`

返回选区内的文本字符串。无选区时返回空字符串。

#### `rl.visual_delete()`

删除选区内容。行为取决于 cursor 和 select 的相对位置：
- 如果 `cursor > select`：相当于 backspace 删除 cursor 到 select 之间的字符
- 如果 `cursor < select`：相当于 delete 删除 cursor 到 select 之间的字符

删除后 `select` 重置为 -1。

#### `rl.visual_replace(text)`

用 text 替换选区内容（先 `visual_delete()` 再 `insert(text)`）。

### 显示与渲染方法

这组方法负责将编辑状态转换为可显示的带属性文本片段列表。

#### 属性值定义

渲染输出中每个文本片段带有属性值：

| 属性值 | 含义 | 对应高亮组（input.vim 中） |
|--------|------|---------------------------|
| `0` | 普通文本 | `QuickInput` |
| `1` | 光标 | `QuickCursor`（闪烁时为 `QuickInput`） |
| `2` | 选区 | `QuickVisual` |
| `3` | 选区 + 光标 | `QuickCursor`（闪烁时为 `QuickVisual`） |

#### `rl.display()`

生成完整编辑缓冲区的带属性显示列表。

**返回值**: `List<[attr, text]>` — 属性值和文本片段的列表。

**示例**（缓冲区为 `"Hello, World!!"`, 光标在 `W` 上，无选区）:
```
[[0, "Hello, "], [1, "W"], [0, "orld !!"]]
```

**示例**（有选区，select=2, cursor=5）:
```
[[0, "He"], [2, "llo"], [3, ","], [0, " World!!"]]
```

光标在行尾时，会生成一个空格字符作为光标占位符。

#### `rl.window(display, start, endup)`

对 `display()` 的结果进行视口裁剪，只保留字符位置 `[start, endup)` 范围内的内容。

**参数**:
- `display`：`display()` 的返回值
- `start`：起始字符位置（可以为负数，负数部分用空格填充）
- `endup`：结束字符位置（不含）

**返回值**: 裁剪后的 `List<[attr, text]>`。如果文本不足以填满 `[start, endup)` 范围，末尾用 `[0, spaces]` 填充。

#### `rl.render(pos, display_width)`

核心渲染方法：生成指定视口位置和宽度下的完整显示列表。

**参数**:
- `pos`：视口起始字符位置
- `display_width`：视口显示宽度（字符列数）

**返回值**: `List<[attr, text]>` — 填满整个视口宽度的带属性文本片段列表。

**行为**:
1. 调用 `avail()` 计算视口能容纳的字符数
2. 调用 `display()` 获取完整显示列表
3. 调用 `window()` 裁剪到视口范围
4. 如果总宽度不足 `display_width`，用带正确属性的空格填充（考虑光标和选区延伸到视口末尾的情况）

#### `rl.slide(window_pos, display_width)`

计算视口滑动位置，确保光标始终可见。

**参数**:
- `window_pos`：当前视口起始位置
- `display_width`：视口显示宽度

**返回值**: 新的视口起始位置。

**逻辑**:
- 如果光标在视口左边（`cursor < window_pos`），视口左移到光标位置
- 如果光标在视口内，保持不变
- 如果光标超出视口右边，右移视口使光标刚好出现在视口右边缘

**典型使用模式**（在 input.vim 中）:
```vim
let hwnd.pos = rl.slide(hwnd.pos, hwnd.w)
let display = rl.render(hwnd.pos, hwnd.w)
```

### 宽度计算方法

#### `rl.avail(pos, length)`

计算从 pos 位置开始，在给定显示宽度内能容纳多少个字符。

**参数**:
- `pos`：起始字符位置
- `length`：显示宽度（正数向右计算，负数向左计算）

**返回值**: 能容纳的字符数量。

**说明**: 该方法考虑了每个字符的实际显示宽度（`wide` 数组），全角字符占 2 列。当下一个字符放不下时停止。

#### `rl.width(start, endup)`

计算 `[start, endup)` 范围内所有字符的总显示宽度。

#### `rl.read_data(pos, width, what)`

读取指定范围的码点数组或宽度数组。

**参数**:
- `pos`：起始位置
- `width`：读取的字符数
- `what`：0 返回 `code` 数组，非 0 返回 `wide` 数组

自动处理边界裁剪。

### 光标闪烁方法

#### `rl.blink(millisec)`

根据当前时间戳判断光标是否应该闪烁（不可见）。

**参数**: `millisec` — 当前时间毫秒数（通过 `float2nr(reltimefloat(reltime()) * 1000)` 获取）。

**返回值**: `0` 光标可见，`1` 光标隐藏（闪烁中）。

**闪烁节奏**:
- 首次调用后等待 500ms 不闪烁
- 之后以 300ms 亮 / 300ms 灭 的节奏交替

**计时器重置**: 任何导致光标移动的操作（`move`、`insert`、`delete`、`backspace`）都会将 `timer` 重置为 -1，下次 `blink()` 调用重新开始计时。

### 鼠标交互方法

#### `rl.mouse_click(winpos, offset)`

将鼠标点击的显示位置转换为字符位置。

**参数**:
- `winpos`：视口起始字符位置
- `offset`：点击位置相对于视口左边缘的列偏移

**返回值**: 对应的字符位置（裁剪到 `[0, size]`）。

### 历史记录方法

历史记录是一个字符串列表，`index` 指向当前浏览的历史条目。`index=0` 通常是当前输入（空字符串或用户正在编辑的文本）。

#### `rl.history_init(history)`

初始化历史记录。

**参数**: `history` — 历史字符串列表（从旧到新）。

**行为**: 将输入列表反转，追加一个空字符串作为 "当前输入" 的占位，`index` 设为 0。

#### `rl.history_save()`

将当前编辑内容保存到历史记录的当前位置。

#### `rl.history_prev()`

浏览上一条历史记录。先保存当前内容，然后 `index+1`（循环），加载对应的历史文本。

#### `rl.history_next()`

浏览下一条历史记录。先保存当前内容，然后 `index-1`（循环），加载对应的历史文本。

### 按键处理方法

#### `rl.feed(char)`

处理单个按键输入，这是 readline 的核心输入入口。

**参数**: `char` — 按键字符串（可以是特殊键如 `"\<BS>"`、`"\<LEFT>"` 等）。

**返回值**: `0` 表示按键已处理，`-1` 表示未识别的控制键。

**支持的按键**:

| 按键 | 行为 |
|------|------|
| `<BS>` | 有选区时删除选区，否则退格删除一个字符 |
| `<Delete>` / `<C-d>` | 有选区时删除选区，否则向前删除一个字符 |
| `<Left>` / `<C-b>` | 有选区时跳到选区左端并清除选区，否则左移一个字符 |
| `<Right>` / `<C-f>` | 有选区时跳到选区右端并清除选区，否则右移一个字符 |
| `<Home>` / `<C-a>` | 跳到行首，清除选区 |
| `<End>` / `<C-e>` | 跳到行尾，清除选区 |
| `<Up>` | 浏览上一条历史，清除选区 |
| `<Down>` | 浏览下一条历史，清除选区 |
| `<S-Left>` | 向左扩展选区（首次按下时设置锚点） |
| `<S-Right>` | 向右扩展选区（首次按下时设置锚点） |
| `<S-Home>` | 选区扩展到行首 |
| `<S-End>` | 选区扩展到行尾 |
| `<C-k>` | 有选区时删除选区，否则删除光标到行尾的所有字符 |
| `<C-w>` | 有选区时删除选区，否则向后删除一个单词（含尾部空白） |
| `<C-c>` | 复制选区文本到寄存器 `"0` |
| `<C-x>` | 剪切选区文本到寄存器 `"0` |
| `<C-v>` | 从寄存器 `"0` 粘贴（有选区时先删除选区） |
| `<C-Insert>` | 复制选区文本到系统剪贴板 `"*` |
| `<S-Insert>` | 从系统剪贴板 `"*` 粘贴（有选区时先删除选区） |
| 普通字符 | 有选区时先删除选区，然后在光标位置插入 |

**注意**: `feed()` 不处理 `<CR>`、`<ESC>` 和 `<C-C>`，这些由上层（input.vim）直接处理。

### 调试方法

#### `rl.echo(blink [, pos, size])`

在命令行直接显示编辑状态（使用 `echohl` + `echon`）。

**参数**:
- `blink`：闪烁状态（0=光标可见, 1=光标隐藏）
- `pos`（可选）：视口起始位置
- `size`（可选）：视口宽度

不带 pos/size 时显示完整内容。主要用于独立测试（`quickui#readline#cli` 函数）。

## input.vim 中的使用流程

以下是 `quickui#input` 如何使用 readline 对象的典型流程：

```vim
" 1. 创建 readline 实例
let rl = quickui#readline#new()

" 2. 设置初始文本（如有）
call rl.set('initial text')
call rl.seek(0, 2)          " 光标移到末尾

" 3. 初始化历史
let rl.history = [''] + previous_history_list

" 4. 主循环
let pos = 0                 " 视口起始位置
while not_exited
    " 4a. 计算视口位置
    let pos = rl.slide(pos, window_width)

    " 4b. 渲染
    let display = rl.render(pos, window_width)

    " 4c. 绘制到 popup window（根据 attr 设置高亮）
    for [attr, text] in display
        " 使用 quickui#core#high_region 设置对应高亮组
    endfor

    " 4d. 获取按键
    let ch = getchar()

    " 4e. 特殊键处理
    if ch == "\<CR>"
        let result = rl.update()    " 获取最终文本
        call rl.history_save()
        break
    elseif ch == "\<ESC>"
        break
    endif

    " 4f. 其他按键交给 readline 处理
    call rl.feed(ch)
endwhile
```

## 测试

模块内置了测试函数：

- `quickui#readline#test()` — 单元测试，验证基本编辑操作的正确性
- `quickui#readline#cli(prompt)` — 交互式命令行测试，可在 Vim 中运行体验 readline 行为

```vim
" 运行单元测试
:echo quickui#readline#test()

" 运行交互测试
:echo quickui#readline#cli(">>> ")
```

## 注意事项

1. **`text` 可能过期**：修改操作只更新 `code`/`wide`/`size`，`text` 字符串需要显式调用 `update()` 才会同步。不要直接读取 `self.text` 获取当前内容。
2. **选区约定**：`select` 是锚点，`cursor` 是活动端。`select` 可以大于也可以小于 `cursor`。`visual_range()` 返回的是规范化的 `[min, max)` 范围。
3. **Vim/Neovim 兼容**：`s:list_slice()` 辅助函数处理了 Vim 的 `slice()` 和 Neovim 的列表切片语法差异（Neovim 没有 `slice()` 内置函数）。
4. **粘贴行为**：粘贴时只取第一行（`split(text, "\n", 1)[0]`），并将换行符和 Tab 替换为空格。
5. **单词删除**（`<C-w>`）：使用 `\S\+\s*$` 匹配光标前的最后一个非空白单词及其尾部空白。
6. **历史循环**：`history_prev()` 和 `history_next()` 在到达列表边界时会循环到另一端。
