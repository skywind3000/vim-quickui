# QuickUI Dialog Module Reference

> **File path**: `autoload/quickui/dialog.vim`
> **Dependencies**: `quickui#window`, `quickui#readline`, `quickui#core`, `quickui#utils`, `quickui#highlight`
> **Requires**: Vim 8.2+ / Neovim 0.4+
> **Design draft**: `site/specs/draft/quickui-dialog.md`
> **User guide**: `site/specs/use-dialog.md`

## Overview

`quickui#dialog` is a data-driven general-purpose dialog module. Callers describe the dialog content through a declarative list of controls, invoke `quickui#dialog#open(items, opts)` to pop up the dialog, and receive a dictionary containing all control values after user interaction.

Supports 7 control types: label (static text), input (single-line text input), radio (radio button group), check (checkbox), button (button row), separator (separator line), and dropdown (dropdown list).

## Public API

### `quickui#dialog#open(items [, opts])`

The sole public entry point.

- `items`: `List<Dict>` — control description list
- `opts`: `Dict` (optional) — dialog options
- Returns: `Dict` — containing all control values and button status

See `site/specs/use-dialog.md` for detailed parameter formats and return value descriptions.

## Internal Architecture

### Module-level Variables

```vim
let s:has_nvim = g:quickui#core#has_nvim   " platform detection (one-time)
let s:history = {}                          " input history cache
```

`s:history` stores per-input history lists keyed by `history_key`, persisted across multiple `dialog#open()` calls.

### Core Data Structures

#### hwnd (Dialog Main State Object)

```vim
let hwnd = {
    \ 'controls': [...],       " List<ctrl> internal control object list
    \ 'focus_list': [...],     " List<{index, type, control}> ordered focusable control list
    \ 'focus_index': 0,        " current focus index within focus_list
    \ 'win': <window>,         " quickui#window instance
    \ 'w': 50,                 " content area width (columns)
    \ 'content_h': 20,         " content area height (lines, computed by calc_layout)
    \ 'content': [...],        " List<String> initial buffer text
    \ 'keymap': {...},         " Dict<hotkey -> {action, control, index}>
    \ 'exit': 0,               " exit flag (1 = exit main loop)
    \ 'exit_button': '',       " button name that triggered exit ('' for cancel or Enter confirm)
    \ 'exit_index': -1,        " button index that triggered exit (0-based, -1=cancel, 0=Enter confirm or first button)
    \ 'color_on': 'QuickSel',  " focused button highlight group
    \ 'color_off': 'QuickBG',  " unfocused button highlight group
    \ 'color_on2': 'QuickButtonOn2',   " focused button hotkey underline
    \ 'color_off2': 'QuickButtonOff2', " unfocused button hotkey underline
    \ 'padding_left': 1,       " left padding columns (used for mouse coordinate calculation)
    \ 'sep_char': '─',        " separator line character (obtained from border style)
    \ 'validator': v:null,    " Funcref/null pre-exit validation function
    \ }
```

#### ctrl (Internal Control Object)

Fields shared by all controls:

| Field | Type | Description |
|-------|------|-------------|
| `type` | String | Control type: `'label'`/`'input'`/`'radio'`/`'check'`/`'button'`/`'separator'`/`'dropdown'` |
| `index` | Number | Index in the original items list |
| `line_start` | Number | Starting line number in the buffer (0-based) |
| `line_count` | Number | Number of lines occupied |
| `focusable` | Number | Whether focusable (0/1) |

Type-specific extra fields:

**input**:

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Control name (key name in return value) |
| `prompt` | String | Label text on the left side |
| `prompt_width` | Number | Aligned prompt column width (0 = no prompt) |
| `input_col` | Number | Input area starting column (= prompt_width) |
| `input_width` | Number | Input area width |
| `rl` | Object | `quickui#readline` instance |
| `pos` | Number | readline viewport position |
| `value` | String | Initial value |
| `history_key` | String | History namespace |

**radio**:

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Control name |
| `prompt` / `prompt_width` | | Same as input |
| `items` | List | Original option text list |
| `parsed` | List | List parsed by `item_parse()` |
| `value` | Number | Currently selected item index (0-based) |
| `cursor` | Number | Current visual cursor index (0-based); arrow keys move cursor, Space sets value to cursor |
| `vertical` | Number | User-specified layout (-1=auto, 0=horizontal, 1=vertical) |
| `is_vertical` | Number | Actual layout (computed by calc_layout) |

**check**:

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Control name |
| `text` | String | Display text |
| `prompt` / `prompt_width` | | Same as input |
| `parsed` | Object | Parse result from `item_parse()` |
| `value` | Number | 0=unchecked, 1=checked |

**button**:

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Control name (default `'button'`) |
| `items` | List | Original button text list |
| `parsed` | List | List parsed by `item_parse()` |
| `value` | Number | Currently focused button index (0-based) |
| `btn_final` | String | Rendered button row text |
| `btn_positions` | List | `{start, endup, offset}` position info for each button |
| `btn_width` | Number | Total button row width |
| `btn_padding` | Number | Left padding for center alignment |

**label**:

| Field | Type | Description |
|-------|------|-------------|
| `lines` | List | List of text lines |

**separator**:

No extra fields. `line_count=1`, `focusable=0`. Rendered as a horizontal separator line (character from dialog border style).

**dropdown**:

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Control name (key name in return value) |
| `prompt` | String | Label text on the left side |
| `prompt_width` | Number | Aligned prompt column width |
| `items` | List | Option text list |
| `value` | Number | Currently selected item index (0-based, auto-clamped) |
| `dropdown_col` | Number | Dropdown display area starting column (= prompt_width) |
| `dropdown_width` | Number | Dropdown display area width |

Collapsed display: `[selected_text     v]`. When expanded, uses a separate `quickui#window` popup list.

### Internal Function List

#### Initialization Phase

| Function | Description |
|----------|-------------|
| `s:parse_items(items)` | Parses the user items list, creates internal ctrl objects. Checks name uniqueness and type validity. Creates readline instances for input and loads history. Supports separator and dropdown. |
| `s:calc_width(controls, opts)` | Auto-calculates dialog width. Traverses all controls to find maximum width requirement, constrained to `[min_w, &columns*80%]`. Dropdown width = prompt + longest item + 4. |
| `s:calc_layout(hwnd, opts)` | 6-pass scan: (1) prompt alignment groups (dropdown participates, separator does not break groups) (1.5) alignment inflation width check — check/radio content widths are fixed; after alignment `prompt_width + content` may exceed `hwnd.w`, this pass expands `hwnd.w` (capped at `&columns*80%`) (2) radio vertical layout decision (3) line position assignment + gap insertion (separator replaces gap) (4) input/dropdown column width calculation (5) height overflow check. Returns -1 on failure. |
| `s:build_focus_list(hwnd)` | Filters focusable controls, builds ordered focus chain. |
| `s:build_keymap(hwnd)` | Collects `&` hotkeys from button/radio/check, detects conflicts. Builds `hwnd.keymap` mapping table. |
| `s:build_content(hwnd)` | Generates initial buffer text lines (default rendering of all controls). Separator uses `hwnd.sep_char` fill. |
| `s:build_dropdown_line(hwnd, ctrl, lines)` | Generates dropdown collapsed text line `[selected_text v]`. |
| `s:hl_prepare(hwnd)` | Prepares highlight groups: `QuickButtonOn2`/`Off2` (button underline variants), `QuickOff` (unfocused input). |

#### Rendering Functions

| Function | Description |
|----------|-------------|
| `s:render_all(hwnd)` | Entry point: `syntax_begin()` -> per-control rendering -> `win.update()` -> `syntax_end()`. |
| `s:render_input(hwnd, ctrl, focused)` | Focused: `rl.slide()`/`rl.render()`/`rl.blink()` + per-segment `syntax_region()`. Unfocused: `QuickOff` highlight. |
| `s:render_radio(hwnd, ctrl, focused)` | Rebuilds `(*)/(  )` marker lines (`(*)` follows `value`). On blur, resets `cursor=value`. When focused, the item under `cursor` is highlighted with `QuickSel`. Supports horizontal/vertical layout. |
| `s:render_check(hwnd, ctrl, focused)` | Rebuilds `[x]/[ ]` marker line. Focused item highlighted with `QuickSel`. |
| `s:render_button(hwnd, ctrl, focused)` | Button highlight: focused uses `QuickSel`/`QuickButtonOn2`, unfocused uses `QuickBG`/`QuickButtonOff2`. |
| `s:render_dropdown(hwnd, ctrl, focused)` | Rebuilds `[text v]` collapsed display. When focused, the entire dropdown area is highlighted with `QuickSel`. |

**Key rendering flow details**:

1. All render functions use `win.set_line(y, line, 0)` to write text (`refresh=0` updates memory only)
2. `s:render_all()` calls `win.update()` once after the loop to flush the buffer
3. The `1` argument to `syntax_begin(1)` means clear old syntax rules
4. Highlighting is implemented via `win.syntax_region()` using `\%Nl\%Nv` virtual column patterns

#### Event Handling

| Function | Description |
|----------|-------------|
| `s:handle_key(hwnd, ch)` | Main key dispatch function. Priority: global keys -> (input: pass directly to readline, skip hotkey) -> hotkey -> control-specific handling. |
| `s:dispatch_hotkey(hwnd, ch)` | Checks `hwnd.keymap`, executes hotkey action. Returns 1=consumed, 0=no match. |
| `s:handle_input(hwnd, ctrl, ch)` | Enter=confirm, Up/Down=focus switch, Ctrl+Up/Down=history browsing, others=`rl.feed(ch)`. |
| `s:handle_radio(hwnd, ctrl, ch)` | Enter=confirm exit, Space=select cursor item (`value=cursor`), Left/Right/h/l=move cursor, vertical mode Up/Down=move cursor within items (switches control at boundary), horizontal mode Up/Down=focus switch. |
| `s:handle_check(hwnd, ctrl, ch)` | Enter=confirm, Up/Down=focus switch, Space=toggle. |
| `s:handle_button(hwnd, ctrl, ch)` | Up/Down=focus switch, Left/h=left button, Right/l=right button, Space/Enter=activate. |
| `s:handle_dropdown(hwnd, ctrl, ch)` | Enter/Space=open dropdown list, Up/Down=focus switch, Left/h=previous item, Right/l=next item. |
| `s:dropdown_open(hwnd, ctrl)` | Creates a `quickui#window` popup list. Has its own event loop for navigation/selection/cancel. Returns selected index or -1. |
| `s:dropdown_visible(items, offset, height, width)` | Generates text lines for the dropdown list visible area (handles scroll offset and text truncation). |
| `s:handle_mouse(hwnd)` | Platform branching: Vim uses `getmousepos()`, Neovim uses `v:mouse_*`. Neovim additionally detects the close button on the border window. |
| `s:dispatch_click(hwnd, x, y)` | Maps 0-based coordinates to a control, executes click action. Clicking a dropdown directly opens the dropdown list. |
| `s:focus_to_ctrl(hwnd, ctrl)` | Moves focus to the specified control. |
| `s:input_select_all(ctrl)` | If the input has content, selects all text and places cursor at the end (Windows-style focus behavior). |

#### Exit Phase

| Function | Description |
|----------|-------------|
| `s:collect_result(hwnd)` | Traverses controls, collects current values from input (`rl.update()`), radio/check/dropdown (`ctrl.value`). |

### Main Loop Execution Flow

```
quickui#dialog#open(items, opts)
  +-- empty items -> return empty result immediately
  +-- s:parse_items() -> controls
  +-- s:calc_width() -> hwnd.w
  +-- s:calc_layout() -> prompt alignment, alignment inflation width check, line_start, content_h
  +-- s:build_focus_list() -> focus_list
  +-- opts.focus -> set initial focus
  +-- initial focus is input -> s:input_select_all() to select all content
  +-- s:build_keymap() -> keymap (with conflict detection)
  +-- compute hwnd.sep_char (obtain horizontal line character from border style)
  +-- s:build_content() -> initial buffer text
  +-- s:hl_prepare() -> QuickOff, QuickButtonOn2/Off2
  +-- win = quickui#window#new()
  |   call win.open(content, win_opts)
  |
  \-- while hwnd.exit == 0
        +-- determine wait mode:
        |   input focused -> getchar(0) non-blocking (drives cursor blink)
        |   other focused -> getchar()  blocking (saves CPU)
        +-- s:render_all(hwnd) -> render + flush buffer + apply highlights
        +-- redraw
        +-- detect Vim close button (win.quit)
        +-- getchar -> ch
        |   getchar(0) returns 0 -> sleep 15m -> continue
        \-- s:handle_key(hwnd, ch) -> may set exit=1
              on focus change: if new focus is input and not mouse operation -> s:input_select_all()
              pre-exit validator check: if exit_index>=0 and validator exists,
              call validator(result); non-empty string -> reset exit=0 + ErrorMsg displays error
  |
  +-- exit animation: final state render + redraw + sleep 15m
  +-- save input history: rl.history_save() + s:history cache
  +-- win.close()
  \-- return s:collect_result() + button/button_index
```

### Highlight Group Dependencies

| Highlight Group | Source | Usage |
|-----------------|--------|-------|
| `QuickBG` | Theme-defined | Window background / unfocused buttons |
| `QuickInput` | Theme-defined | Focused input text area |
| `QuickCursor` | Theme-defined | Input cursor (blinking) |
| `QuickVisual` | Theme-defined | Input selection |
| `QuickSel` | Theme-defined | Focused button / radio selected item / check selected item |
| `QuickBorder` | Theme-defined | Border |
| `QuickOff` | Dynamically generated | Unfocused input: `overlay(QuickInput, QuickDefaultDisable)` |
| `QuickButtonOn2` | Dynamically generated | Focused button hotkey: `make_underline(QuickSel)` |
| `QuickButtonOff2` | Dynamically generated | Unfocused button hotkey: `make_underline(QuickBG)` |

### Key Dispatch Priority

```
getchar() -> ch
  |
  +-- ESC / Ctrl-C -> cancel exit
  +-- Tab -> advance focus
  +-- S-Tab -> retreat focus
  +-- LeftMouse -> s:handle_mouse()
  +-- Vim close button -> cancel exit
  |
  \-- dispatch by focused control type:
      +-- input -> s:handle_input(ch)     <- no hotkey check
      +-- radio -> hotkey? -> s:handle_radio(ch)
      +-- check -> hotkey? -> s:handle_check(ch)
      +-- button -> hotkey? -> s:handle_button(ch)
      \-- dropdown -> hotkey? -> s:handle_dropdown(ch)
```

Hotkeys are skipped when input is focused to prevent characters from being intercepted by button hotkeys while the user is typing.

### Prompt Alignment Group Algorithm

1. Traverse all controls, skipping label and separator (they do not break alignment groups)
2. Consecutive interactive controls with prompts (input/radio/check/dropdown) form an alignment group
3. An interactive control without a prompt breaks the alignment group
4. All controls within a group have their `prompt_width` set to the longest prompt width + 2
5. **Alignment inflation width check** (pass 1.5): Alignment may inflate the `prompt_width` of controls with short prompts. `input`/`dropdown` content areas adapt automatically (`input_width = content_w - prompt_width`), but `check`/`radio` text widths are fixed. This pass traverses check (`prompt_width + 4 + text_width`) and radio (vertical: max of `prompt_width + 4 + item_width` per line; forced horizontal: full row width), and expands `hwnd.w` if the result exceeds `content_w`, capped at `&columns * 80%`. After expansion, pass 2's radio auto-detect uses the updated `content_w`, ensuring correct horizontal/vertical layout decisions.

### Validator Mechanism

`opts.validator` accepts a Funcref that is called before the dialog exits normally (`exit_index >= 0`). It is not called on cancel exit (ESC / Ctrl-C / close button, i.e., `exit_index < 0`).

**Call timing**: At the end of the main loop, after `handle_key()` sets `exit=1` and before `endwhile`.

**Signature**: `validator(result) -> String|Number`
- Parameter `result`: A Dict with the same structure as the `open()` return value (built via `s:collect_result()`, containing `button` / `button_index` and all control values)
- Returns `0` or `''` — validation passed, exit normally
- Returns a non-empty string — validation failed, resets `exit=0` to continue the loop, displays the string at the bottom with `echohl ErrorMsg` (no prefix added; wording is controlled by the caller)

**Implementation details**:
- After each validator rejection, `render_all()` + `redraw` restores the dialog display before echoing the error
- The error message naturally disappears on the user's next keypress (overwritten by `redraw`)
- The validator may be called multiple times (user repeatedly attempts to submit)

### Vim/Neovim Compatibility

The dialog shields platform differences through `quickui#window`, with direct branching in only two places:

1. **`s:handle_mouse()`**: Vim uses `getmousepos()` (coordinates are already content-area relative), Neovim uses `v:mouse_*` and additionally checks the close button on the border window
2. **Close button detection**: Vim via `hwnd.win.quit != 0` (set by popup callback), Neovim via mouse click on the top-right corner of the border window

## Testing

### Interactive Tests

```vim
:source tools/test/test_dialog.vim
:call Test_dialog_basic()

:source tools/test/test_dialog_dropdown.vim
:call Test_dropdown_basic()      " basic dropdown
:call Test_separator_basic()     " separator line
:call Test_dropdown_full()       " dropdown + separator + other controls combined
:call Test_dropdown_index()      " default index
:call Test_dropdown_scroll()     " scrolling with many items

:source tools/test/test_dialog_validator.vim
:call Test_validator_basic()     " empty field validation blocks exit
:call Test_validator_number()    " returning 0 means pass
:call Test_validator_cancel()    " cancel does not trigger validator
```

11 interactive test functions requiring manual operation to verify.

### Automated Tests

```bash
vim -u NONE -N -i NONE -n --not-a-term -es \
    -c "set rtp+=c:/Share/vim" \
    -c "source c:/Share/vim/tools/test/test_dialog_auto.vim"

vim -u NONE -N --noplugin -es --cmd "set lines=40 columns=100" \
    -S tools/test/test_dialog_headless.vim
```

- Exit code 0 = pass, non-zero = fail
- `test_dialog_auto.vim`: 13 test cases, 30 assertions
- `test_dialog_headless.vim`: 4 test cases, 6 assertions (including separator/dropdown)
- Uses `feedkeys()` to inject key sequences simulating user operations

## Known Limitations and Future Extensions

1. **No scrolling** — dialog uses static layout; an error is raised if total control lines exceed screen height
2. **Input is single-line only** — could be extended with `multiline: 1` in the future
3. **Button activation always closes** — could support "Apply"-style non-closing buttons via callbacks in the future
4. **Control disabling** — reserved `enable: 0` field
5. **Value change callbacks** — reserved for triggering callbacks on radio/check/dropdown value changes
6. **Field validation** — reserved `validate` callback for input/dropdown
