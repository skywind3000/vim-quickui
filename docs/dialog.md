# QuickUI Dialog 模块参考文档

> **文件路径**: `autoload/quickui/dialog.vim`
> **依赖**: `quickui#window`, `quickui#readline`, `quickui#core`, `quickui#utils`, `quickui#highlight`
> **适用**: Vim 8.2+ / Neovim 0.4+
> **设计方案**: `site/specs/draft/quickui-dialog.md`
> **用户指南**: `site/specs/use-dialog.md`

## 概述

`quickui#dialog` 是一个数据驱动的通用对话框模块。调用方通过声明式的控件列表描述对话框内容，调用 `quickui#dialog#open(items, opts)` 弹出对话框，用户交互后返回包含所有控件值的字典。

支持 7 种控件：label（静态文本）、input（单行输入框）、radio（单选组）、check（复选框）、button（按钮行）、separator（分隔线）、dropdown（下拉列表）。

## 公开 API

### `quickui#dialog#open(items [, opts])`

唯一的公开入口函数。

- `items`: `List<Dict>` — 控件描述列表
- `opts`: `Dict`（可选）— 对话框选项
- 返回: `Dict` — 包含所有控件值和按钮状态

详细的参数格式和返回值说明见 `site/specs/use-dialog.md`。

## 内部架构

### 模块级变量

```vim
let s:has_nvim = g:quickui#core#has_nvim   " 平台检测（一次性）
let s:history = {}                          " input 历史记录缓存
```

`s:history` 以 `history_key` 为键存储各 input 的历史列表，跨多次 `dialog#open()` 调用保持。

### 核心数据结构

#### hwnd（对话框主状态对象）

```vim
let hwnd = {
    \ 'controls': [...],       " List<ctrl> 内部控件对象列表
    \ 'focus_list': [...],     " List<{index, type, control}> 可聚焦控件有序列表
    \ 'focus_index': 0,        " 当前焦点在 focus_list 中的索引
    \ 'win': <window>,         " quickui#window 实例
    \ 'w': 50,                 " 内容区宽度（列数）
    \ 'content_h': 20,         " 内容区高度（行数，由 calc_layout 计算）
    \ 'content': [...],        " List<String> 初始 buffer 文本
    \ 'keymap': {...},         " Dict<hotkey → {action, control, index}>
    \ 'exit': 0,               " 退出标志（1=退出主循环）
    \ 'exit_button': '',       " 触发退出的 button name（'' 表示取消或 Enter 确认）
    \ 'exit_index': -1,        " 触发退出的按钮索引（1-based，-1=取消，0=Enter 确认）
    \ 'color_on': 'QuickSel',  " 聚焦按钮高亮组
    \ 'color_off': 'QuickBG',  " 未聚焦按钮高亮组
    \ 'color_on2': 'QuickButtonOn2',   " 聚焦按钮快捷键下划线
    \ 'color_off2': 'QuickButtonOff2', " 未聚焦按钮快捷键下划线
    \ 'padding_left': 1,       " 左侧 padding 列数（用于鼠标坐标计算）
    \ 'sep_char': '─',        " separator 分隔线字符（从 border 样式获取）
    \ 'validator': v:null,    " Funcref/null 退出前校验函数
    \ }
```

#### ctrl（内部控件对象）

所有控件共享的字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `type` | String | 控件类型：`'label'`/`'input'`/`'radio'`/`'check'`/`'button'`/`'separator'`/`'dropdown'` |
| `index` | Number | 在原始 items 列表中的索引 |
| `line_start` | Number | 在 buffer 中的起始行号（0-based） |
| `line_count` | Number | 占用行数 |
| `focusable` | Number | 是否可聚焦（0/1） |

各类型控件额外字段：

**input**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | String | 控件名称（返回值键名） |
| `prompt` | String | 左侧标签文本 |
| `prompt_width` | Number | 对齐后的 prompt 列宽（0=无 prompt） |
| `input_col` | Number | 输入区域起始列（= prompt_width） |
| `input_width` | Number | 输入区域宽度 |
| `rl` | Object | `quickui#readline` 实例 |
| `pos` | Number | readline 视口位置 |
| `value` | String | 初始值 |
| `history_key` | String | 历史记录命名空间 |

**radio**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | String | 控件名称 |
| `prompt` / `prompt_width` | | 同 input |
| `items` | List | 原始选项文本列表 |
| `parsed` | List | `item_parse()` 解析后的列表 |
| `value` | Number | 当前选中项索引（0-based） |
| `cursor` | Number | 当前视觉焦点索引（0-based），方向键移动 cursor，Space 将 value 设为 cursor |
| `vertical` | Number | 用户指定的布局（-1=auto, 0=水平, 1=垂直） |
| `is_vertical` | Number | 实际布局（由 calc_layout 计算） |

**check**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | String | 控件名称 |
| `text` | String | 显示文本 |
| `prompt` / `prompt_width` | | 同 input |
| `parsed` | Object | `item_parse()` 解析结果 |
| `value` | Number | 0=未选中, 1=选中 |

**button**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | String | 控件名称（默认 `'button'`） |
| `items` | List | 原始按钮文本列表 |
| `parsed` | List | `item_parse()` 解析后的列表 |
| `value` | Number | 当前聚焦的按钮索引（0-based） |
| `btn_final` | String | 渲染后的按钮行文本 |
| `btn_positions` | List | 每个按钮的 `{start, endup, offset}` 位置信息 |
| `btn_width` | Number | 按钮行总宽度 |
| `btn_padding` | Number | 居中对齐的左侧填充 |

**label**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `lines` | List | 文本行列表 |

**separator**:

无额外字段。`line_count=1`，`focusable=0`。渲染为一行水平分隔线（字符来自 dialog 边框样式）。

**dropdown**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | String | 控件名称（返回值键名） |
| `prompt` | String | 左侧标签文本 |
| `prompt_width` | Number | 对齐后的 prompt 列宽 |
| `items` | List | 可选项文本列表 |
| `value` | Number | 当前选中项索引（0-based，自动 clamp） |
| `dropdown_col` | Number | 下拉显示区域起始列（= prompt_width） |
| `dropdown_width` | Number | 下拉显示区域宽度 |

折叠态显示：`[selected_text     v]`。展开时使用独立 `quickui#window` 弹出列表。

### 内部函数列表

#### 初始化阶段

| 函数 | 说明 |
|------|------|
| `s:parse_items(items)` | 解析用户 items 列表，创建内部 ctrl 对象。检查 name 唯一性、type 合法性。为 input 创建 readline 实例并加载历史。支持 separator 和 dropdown。 |
| `s:calc_width(controls, opts)` | 自动计算对话框宽度。遍历所有控件取最大宽度需求，限定在 `[min_w, &columns*80%]` 范围内。dropdown 宽度 = prompt + 最长 item + 4。 |
| `s:calc_layout(hwnd, opts)` | 5 遍扫描：(1) prompt 对齐组（dropdown 参与，separator 不打断） (2) radio 垂直布局判定 (3) 行位置分配+gap 插入（separator 替代 gap） (4) input/dropdown 列宽计算 (5) 高度溢出检查。返回 -1 表示失败。 |
| `s:build_focus_list(hwnd)` | 过滤 focusable 控件，构建有序焦点链。 |
| `s:build_keymap(hwnd)` | 收集 button/radio/check 的 `&` 快捷键，检测冲突。构建 `hwnd.keymap` 映射表。 |
| `s:build_content(hwnd)` | 生成初始 buffer 文本行（所有控件的默认渲染）。separator 用 `hwnd.sep_char` 填充。 |
| `s:build_dropdown_line(hwnd, ctrl, lines)` | 生成 dropdown 折叠态文本行 `[selected_text v]`。 |
| `s:hl_prepare(hwnd)` | 准备高亮组：`QuickButtonOn2`/`Off2`（按钮下划线变体）、`QuickOff`（未聚焦 input）。 |

#### 渲染函数

| 函数 | 说明 |
|------|------|
| `s:render_all(hwnd)` | 入口：`syntax_begin()` → 逐控件渲染 → `win.update()` → `syntax_end()`。 |
| `s:render_input(hwnd, ctrl, focused)` | 聚焦时：`rl.slide()`/`rl.render()`/`rl.blink()` + 逐片段 `syntax_region()`。未聚焦时：`QuickOff` 高亮。 |
| `s:render_radio(hwnd, ctrl, focused)` | 重建 `(*)/(  )` 标记行（`(*)` 跟随 `value`）。失焦时重置 `cursor=value`。聚焦时 `cursor` 所在项用 `QuickSel` 高亮。支持水平/垂直布局。 |
| `s:render_check(hwnd, ctrl, focused)` | 重建 `[x]/[ ]` 标记行。聚焦时用 `QuickSel` 高亮。 |
| `s:render_button(hwnd, ctrl, focused)` | 按钮高亮：聚焦态 `QuickSel`/`QuickButtonOn2`，未聚焦态 `QuickBG`/`QuickButtonOff2`。 |
| `s:render_dropdown(hwnd, ctrl, focused)` | 重建 `[text v]` 折叠显示。聚焦时整个下拉区域用 `QuickSel` 高亮。 |

**渲染流程关键点**：

1. 所有 render 函数使用 `win.set_line(y, line, 0)` 写入文本（`refresh=0` 仅更新内存）
2. `s:render_all()` 在循环结束后调用 `win.update()` 一次性刷新 buffer
3. `syntax_begin(1)` 的参数 `1` 表示清除旧语法规则
4. 高亮通过 `win.syntax_region()` 基于 `\%Nl\%Nv` 虚拟列模式实现

#### 事件处理

| 函数 | 说明 |
|------|------|
| `s:handle_key(hwnd, ch)` | 按键分发主函数。优先级：全局键 → (input: 直接给 readline，跳过 hotkey) → hotkey → 控件专属处理。 |
| `s:dispatch_hotkey(hwnd, ch)` | 检查 `hwnd.keymap`，执行 hotkey 动作。返回 1=已消费，0=未匹配。 |
| `s:handle_input(hwnd, ctrl, ch)` | Enter=确认, Up/Down=焦点切换, Ctrl+Up/Down=历史浏览, 其余=`rl.feed(ch)`。 |
| `s:handle_radio(hwnd, ctrl, ch)` | Enter=确认退出, Space=选中 cursor 项（`value=cursor`）, Left/Right/h/l=移动 cursor, 垂直模式 Up/Down=在 items 内移动 cursor（到边界切换控件）, 水平模式 Up/Down=焦点切换。 |
| `s:handle_check(hwnd, ctrl, ch)` | Enter=确认, Up/Down=焦点切换, Space=切换。 |
| `s:handle_button(hwnd, ctrl, ch)` | Up/Down=焦点切换, Left/h=左按钮, Right/l=右按钮, Space/Enter=激活。 |
| `s:handle_dropdown(hwnd, ctrl, ch)` | Enter/Space=打开下拉列表, Up/Down=焦点切换, Left/h=上一项, Right/l=下一项。 |
| `s:dropdown_open(hwnd, ctrl)` | 创建 `quickui#window` 弹出列表。自有事件循环处理导航/选择/取消。返回选中索引或 -1。 |
| `s:dropdown_visible(items, offset, height, width)` | 生成下拉列表可见区域的文本行列表（处理滚动偏移和文本截断）。 |
| `s:handle_mouse(hwnd)` | 平台分支：Vim 用 `getmousepos()`，Neovim 用 `v:mouse_*`。Neovim 额外检测边框窗口关闭按钮。 |
| `s:dispatch_click(hwnd, x, y)` | 将 0-based 坐标映射到控件，执行点击操作。点击 dropdown 直接打开下拉列表。 |
| `s:focus_to_ctrl(hwnd, ctrl)` | 将焦点移到指定控件。 |
| `s:input_select_all(ctrl)` | 若 input 有内容，全选文本并将光标置于末尾（Windows 风格焦点行为）。 |

#### 退出阶段

| 函数 | 说明 |
|------|------|
| `s:collect_result(hwnd)` | 遍历控件，收集 input(`rl.update()`)、radio/check/dropdown(`ctrl.value`) 的当前值。 |

### 主循环执行流程

```
quickui#dialog#open(items, opts)
  ├── 空 items → 直接返回空结果
  ├── s:parse_items() → controls
  ├── s:calc_width() → hwnd.w
  ├── s:calc_layout() → line_start, content_h, prompt 对齐
  ├── s:build_focus_list() → focus_list
  ├── opts.focus → 设置初始焦点
  ├── 初始焦点为 input 时 → s:input_select_all() 全选内容
  ├── s:build_keymap() → keymap (含冲突检测)
  ├── 计算 hwnd.sep_char（从 border 样式获取水平线字符）
  ├── s:build_content() → 初始 buffer 文本
  ├── s:hl_prepare() → QuickOff, QuickButtonOn2/Off2
  ├── win = quickui#window#new()
  │   call win.open(content, win_opts)
  │
  └── while hwnd.exit == 0
        ├── 判断等待模式：
        │   input 焦点 → getchar(0) 非阻塞（驱动光标闪烁）
        │   其他焦点 → getchar()  阻塞（省 CPU）
        ├── s:render_all(hwnd) → 渲染 + 刷新 buffer + 应用高亮
        ├── redraw
        ├── 检测 Vim 关闭按钮 (win.quit)
        ├── getchar → ch
        │   getchar(0) 返回 0 → sleep 15m → continue
        └── s:handle_key(hwnd, ch) → 可能设置 exit=1
              焦点变化时：若新焦点为 input 且非鼠标操作 → s:input_select_all()
              exit 前 validator 检查：若 exit_index>=0 且 validator 存在，
              调用 validator(result)，非空字符串则 exit=0 + ErrorMsg 显示错误
  │
  ├── 退出动画：最终状态 render + redraw + sleep 15m
  ├── 保存 input 历史：rl.history_save() + s:history 缓存
  ├── win.close()
  └── return s:collect_result() + button/button_index
```

### 高亮组依赖

| 高亮组 | 来源 | 用途 |
|--------|------|------|
| `QuickBG` | 主题定义 | 窗口背景 / 未聚焦按钮 |
| `QuickInput` | 主题定义 | 聚焦 input 文本区域 |
| `QuickCursor` | 主题定义 | input 光标（闪烁） |
| `QuickVisual` | 主题定义 | input 选区 |
| `QuickSel` | 主题定义 | 聚焦按钮 / radio 选中项 / check 选中项 |
| `QuickBorder` | 主题定义 | 边框 |
| `QuickOff` | 动态生成 | 未聚焦 input：`overlay(QuickInput, QuickDefaultDisable)` |
| `QuickButtonOn2` | 动态生成 | 聚焦按钮快捷键：`make_underline(QuickSel)` |
| `QuickButtonOff2` | 动态生成 | 未聚焦按钮快捷键：`make_underline(QuickBG)` |

### 按键分发优先级

```
getchar() → ch
  │
  ├── ESC / Ctrl-C → 取消退出
  ├── Tab → 焦点前进
  ├── S-Tab → 焦点后退
  ├── LeftMouse → s:handle_mouse()
  ├── Vim close button → 取消退出
  │
  └── 根据焦点类型分发：
      ├── input → s:handle_input(ch)     ← 不检查 hotkey
      ├── radio → hotkey? → s:handle_radio(ch)
      ├── check → hotkey? → s:handle_check(ch)
      ├── button → hotkey? → s:handle_button(ch)
      └── dropdown → hotkey? → s:handle_dropdown(ch)
```

input 焦点时跳过 hotkey 是为了避免用户输入文字时字符被按钮快捷键拦截。

### prompt 对齐组算法

1. 遍历所有控件，跳过 label 和 separator（不打断对齐组）
2. 连续的带 prompt 的交互控件（input/radio/check/dropdown）构成一个对齐组
3. 无 prompt 的交互控件打断对齐组
4. 组内所有控件的 `prompt_width` = 最长 prompt 宽度 + 2

### validator 校验机制

`opts.validator` 接受一个 Funcref，在对话框正常退出前（`exit_index >= 0`）被调用。取消退出（ESC / Ctrl-C / 关闭按钮，即 `exit_index < 0`）时不调用。

**调用时机**: 主循环末尾，`handle_key()` 设置 `exit=1` 之后、`endwhile` 之前。

**签名**: `validator(result) -> String|Number`
- 参数 `result`: 与 `open()` 返回值结构相同的 Dict（通过 `s:collect_result()` 构建，含 `button` / `button_index` 及各控件值）
- 返回 `0` 或 `''` — 校验通过，正常退出
- 返回非空字符串 — 校验失败，重置 `exit=0` 继续循环，底部 `echohl ErrorMsg` 显示该字符串（不加前缀，由调用方控制措辞）

**实现要点**:
- 每次 validator 拒绝退出后，会先 `render_all()` + `redraw` 恢复对话框显示再 echo 错误
- 错误信息在用户下次按键后自然消失（被 `redraw` 覆盖）
- validator 可被多次调用（用户反复尝试提交）

### Vim/Neovim 兼容性

dialog 通过 `quickui#window` 屏蔽平台差异，仅在以下两处直接分支：

1. **`s:handle_mouse()`**: Vim 用 `getmousepos()`（坐标已是内容区相对），Neovim 用 `v:mouse_*` 且需检测边框窗口的关闭按钮
2. **关闭按钮检测**: Vim 通过 `hwnd.win.quit != 0`（popup callback 设置），Neovim 通过鼠标点击边框窗口右上角

## 测试

### 交互测试

```vim
:source tools/test/test_dialog.vim
:call Test_dialog_basic()

:source tools/test/test_dialog_dropdown.vim
:call Test_dropdown_basic()      " 基础 dropdown
:call Test_separator_basic()     " separator 分隔线
:call Test_dropdown_full()       " dropdown + separator + 其他控件组合
:call Test_dropdown_index()      " 默认 index
:call Test_dropdown_scroll()     " 大量 items 滚动

:source tools/test/test_dialog_validator.vim
:call Test_validator_basic()     " 空字段校验阻止退出
:call Test_validator_number()    " 返回 0 表示通过
:call Test_validator_cancel()    " 取消时不触发 validator
```

11 个交互测试函数，需手动操作验证。

### 自动化测试

```bash
vim -u NONE -N -i NONE -n --not-a-term -es \
    -c "set rtp+=c:/Share/vim" \
    -c "source c:/Share/vim/tools/test/test_dialog_auto.vim"

vim -u NONE -N --noplugin -es --cmd "set lines=40 columns=100" \
    -S tools/test/test_dialog_headless.vim
```

- 退出码 0 = 通过，非 0 = 失败
- `test_dialog_auto.vim`: 12 个测试用例，27 个断言
- `test_dialog_headless.vim`: 4 个测试用例，6 个断言（含 separator/dropdown）
- 使用 `feedkeys()` 注入按键序列模拟用户操作

## 已知限制与扩展预留

1. **不支持滚动** — dialog 是静态布局，控件总高度超出屏幕时报错
2. **input 仅单行** — 未来可通过 `multiline: 1` 扩展
3. **按钮激活即关闭** — 未来可通过回调函数实现 "Apply" 等不关闭的按钮
4. **控件禁用** — 预留 `enable: 0` 字段
5. **值变更回调** — 预留 radio/check/dropdown 值变更时触发回调
6. **字段校验** — 预留 input/dropdown 的 `validate` 回调
