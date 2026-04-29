# QuickUI Dialog Module Reference

> **File**: `autoload/quickui/dialog.vim`
> **Dependencies**: `quickui#window`, `quickui#readline`, `quickui#core`, `quickui#utils`, `quickui#highlight`
> **Requires**: Vim 8.2+ / Neovim 0.4+
> **User Guide**: `DIALOG.md`

## Overview

`quickui#dialog` is a data-driven general-purpose dialog module. Callers describe the dialog content through a declarative list of controls and call `quickui#dialog#open(items, opts)` to pop up a dialog. After user interaction, it returns a dictionary containing all control values.

Supports 7 control types: label (static text), input (single-line input), radio (radio button group), check (checkbox), button (button row), separator (divider line), and dropdown (dropdown list).

## Public API

### `quickui#dialog#open(items [, opts])`

The sole public entry function.

- `items`: `List<Dict>` — Control description list
- `opts`: `Dict` (optional) — Dialog options
- Returns: `Dict` — Contains all control values and button status

See `DIALOG.md` for detailed parameter formats and return value documentation.

## Internal Architecture

### Module-Level Variables

```vim
let s:has_nvim = g:quickui#core#has_nvim   " Platform detection (one-time)
let s:history = {}                          " Input history cache
```

`s:history` stores each input's history list keyed by `history_key`, persisting across multiple `dialog#open()` calls.

### Core Data Structures

#### hwnd (Dialog Main State Object)

```vim
let hwnd = {
    \ 'controls': [...],       " List<ctrl> internal control object list
    \ 'focus_list': [...],     " List<{index, type, control}> ordered focusable control list
    \ 'focus_index': 0,        " Current focus index within focus_list
    \ 'win': <window>,         " quickui#window instance
    \ 'w': 50,                 " Content area width (columns)
    \ 'content_h': 20,         " Content area height (lines, computed by calc_layout)
    \ 'content': [...],        " List<String> initial buffer text
    \ 'keymap': {...},         " Dict<hotkey → {action, control, index}>
    \ 'exit': 0,               " Exit flag (1=exit main loop)
    \ 'exit_button': '',       " Button name that triggered exit ('' means cancel or Enter confirm)
    \ 'exit_index': -1,        " Button index that triggered exit (1-based, -1=cancel, 0=Enter confirm)
    \ 'color_on': 'QuickSel',  " Focused button highlight group
    \ 'color_off': 'QuickBG',  " Unfocused button highlight group
    \ 'color_on2': 'QuickButtonOn2',   " Focused button hotkey underline
    \ 'color_off2': 'QuickButtonOff2', " Unfocused button hotkey underline
    \ 'padding_left': 1,       " Left padding column count (for mouse coordinate calculation)
    \ 'sep_char': '─',        " Separator line character (derived from border style)
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

Extra fields by control type:

**input**:

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Control name (return value key) |
| `prompt` | String | Left-side label text |
| `prompt_width` | Number | Aligned prompt column width (0=no prompt) |
| `input_col` | Number | Input area start column (= prompt_width) |
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
| `parsed` | List | Parsed list from `item_parse()` |
| `value` | Number | Currently selected item index (0-based) |
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
| `parsed` | List | Parsed list from `item_parse()` |
| `value` | Number | Currently focused button index (0-based) |
| `btn_final` | String | Rendered button row text |
| `btn_positions` | List | Each button's `{start, endup, offset}` position info |
| `btn_width` | Number | Button row total width |
| `btn_padding` | Number | Left padding for center alignment |

**label**:

| Field | Type | Description |
|-------|------|-------------|
| `lines` | List | Text line list |

**separator**:

No extra fields. `line_count=1`, `focusable=0`. Rendered as a horizontal divider line (character from dialog border style).

**dropdown**:

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Control name (return value key) |
| `prompt` | String | Left-side label text |
| `prompt_width` | Number | Aligned prompt column width |
| `items` | List | Option text list |
| `value` | Number | Currently selected item index (0-based, auto-clamped) |
| `dropdown_col` | Number | Dropdown display area start column (= prompt_width) |
| `dropdown_width` | Number | Dropdown display area width |

Collapsed display: `[selected_text     v]`. When expanded, uses a separate `quickui#window` popup list.

### Internal Function List

#### Initialization Phase

| Function | Description |
|----------|-------------|
| `s:parse_items(items)` | Parses user items list, creates internal ctrl objects. Checks name uniqueness and type validity. Creates readline instances for inputs and loads history. Supports separator and dropdown. |
| `s:calc_width(controls, opts)` | Auto-calculates dialog width. Iterates all controls for maximum width requirement, constrained to `[min_w, &columns*80%]` range. Dropdown width = prompt + longest item + 4. |
| `s:calc_layout(hwnd, opts)` | 5-pass scan: (1) prompt alignment groups (dropdown participates, separator doesn't break groups) (2) radio vertical layout determination (3) line position assignment + gap insertion (separator replaces gap) (4) input/dropdown column width calculation (5) height overflow check. Returns -1 on failure. |
| `s:build_focus_list(hwnd)` | Filters focusable controls, builds ordered focus chain. |
| `s:build_keymap(hwnd)` | Collects `&` hotkeys from button/radio/check, detects conflicts. Builds `hwnd.keymap` mapping table. |
| `s:build_content(hwnd)` | Generates initial buffer text lines (default rendering of all controls). Separators are filled with `hwnd.sep_char`. |
| `s:build_dropdown_line(hwnd, ctrl, lines)` | Generates dropdown collapsed text line `[selected_text v]`. |
| `s:hl_prepare(hwnd)` | Prepares highlight groups: `QuickButtonOn2`/`Off2` (button underline variants), `QuickOff` (unfocused input). |

#### Rendering Functions

| Function | Description |
|----------|-------------|
| `s:render_all(hwnd)` | Entry point: `syntax_begin()` → render each control → `win.update()` → `syntax_end()`. |
| `s:render_input(hwnd, ctrl, focused)` | When focused: `rl.slide()`/`rl.render()`/`rl.blink()` + per-fragment `syntax_region()`. When unfocused: `QuickOff` highlight. |
| `s:render_radio(hwnd, ctrl, focused)` | Rebuilds `(*)/(  )` marker lines. Selected item uses `QuickSel` highlight when focused. Supports horizontal/vertical layout. |
| `s:render_check(hwnd, ctrl, focused)` | Rebuilds `[x]/[ ]` marker lines. Uses `QuickSel` highlight when focused. |
| `s:render_button(hwnd, ctrl, focused)` | Button highlighting: focused state `QuickSel`/`QuickButtonOn2`, unfocused state `QuickBG`/`QuickButtonOff2`. |
| `s:render_dropdown(hwnd, ctrl, focused)` | Rebuilds `[text v]` collapsed display. Entire dropdown area uses `QuickSel` highlight when focused. |

**Key rendering flow points**:

1. All render functions use `win.set_line(y, line, 0)` to write text (`refresh=0` updates memory only)
2. `s:render_all()` calls `win.update()` once at the end to flush the buffer
3. `syntax_begin(1)` parameter `1` means clear old syntax rules
4. Highlighting is implemented via `win.syntax_region()` using `\%Nl\%Nv` virtual column patterns

#### Event Handling

| Function | Description |
|----------|-------------|
| `s:handle_key(hwnd, ch)` | Main key dispatch function. Priority: global keys → (input: directly to readline, skip hotkey) → hotkey → control-specific handling. |
| `s:dispatch_hotkey(hwnd, ch)` | Checks `hwnd.keymap`, executes hotkey action. Returns 1=consumed, 0=not matched. |
| `s:handle_input(hwnd, ctrl, ch)` | Enter=confirm, Up/Down=focus switch, Ctrl+Up/Down=history browsing, others=`rl.feed(ch)`. |
| `s:handle_radio(hwnd, ctrl, ch)` | Enter=confirm, Up/Down=focus switch, Left/h=previous item, Right/l/Space=next item. |
| `s:handle_check(hwnd, ctrl, ch)` | Enter=confirm, Up/Down=focus switch, Space=toggle. |
| `s:handle_button(hwnd, ctrl, ch)` | Up/Down=focus switch, Left/h=left button, Right/l=right button, Space/Enter=activate. |
| `s:handle_dropdown(hwnd, ctrl, ch)` | Enter/Space=open dropdown list, Up/Down=focus switch, Left/h=previous item, Right/l=next item. |
| `s:dropdown_open(hwnd, ctrl)` | Creates a `quickui#window` popup list. Has its own event loop for navigation/selection/cancel. Returns selected index or -1. |
| `s:dropdown_visible(items, offset, height, width)` | Generates visible text lines for the dropdown list (handles scroll offset and text truncation). |
| `s:handle_mouse(hwnd)` | Platform branching: Vim uses `getmousepos()`, Neovim uses `v:mouse_*`. Neovim additionally detects border window close button. |
| `s:dispatch_click(hwnd, x, y)` | Maps 0-based coordinates to a control, executes click action. Clicking dropdown directly opens the popup list. |
| `s:focus_to_ctrl(hwnd, ctrl)` | Moves focus to the specified control. |
| `s:input_select_all(ctrl)` | If input has content, selects all text and places cursor at end (Windows-style focus behavior). |

#### Exit Phase

| Function | Description |
|----------|-------------|
| `s:collect_result(hwnd)` | Iterates controls, collects input (`rl.update()`), radio/check/dropdown (`ctrl.value`) current values. |

### Main Loop Execution Flow

```
quickui#dialog#open(items, opts)
  ├── Empty items → return empty result directly
  ├── s:parse_items() → controls
  ├── s:calc_width() → hwnd.w
  ├── s:calc_layout() → line_start, content_h, prompt alignment
  ├── s:build_focus_list() → focus_list
  ├── opts.focus → set initial focus
  ├── Initial focus is input → s:input_select_all() selects all content
  ├── s:build_keymap() → keymap (with conflict detection)
  ├── Compute hwnd.sep_char (horizontal line character from border style)
  ├── s:build_content() → initial buffer text
  ├── s:hl_prepare() → QuickOff, QuickButtonOn2/Off2
  ├── win = quickui#window#new()
  │   call win.open(content, win_opts)
  │
  └── while hwnd.exit == 0
        ├── Determine wait mode:
        │   input focused → getchar(0) non-blocking (drives cursor blink)
        │   other focused → getchar()  blocking (saves CPU)
        ├── s:render_all(hwnd) → render + flush buffer + apply highlighting
        ├── redraw
        ├── Check Vim close button (win.quit)
        ├── getchar → ch
        │   getchar(0) returns 0 → sleep 15m → continue
        └── s:handle_key(hwnd, ch) → may set exit=1
              On focus change: if new focus is input and not mouse operation → s:input_select_all()
              Before exit, validator check: if exit_index>=0 and validator exists,
              call validator(result), non-empty string → exit=0 + ErrorMsg display error
  │
  ├── Exit animation: final state render + redraw + sleep 15m
  ├── Save input history: rl.history_save() + s:history cache
  ├── win.close()
  └── return s:collect_result() + button/button_index
```

### Highlight Group Dependencies

| Highlight Group | Source | Purpose |
|-----------------|--------|---------|
| `QuickBG` | Theme-defined | Window background / unfocused buttons |
| `QuickInput` | Theme-defined | Focused input text area |
| `QuickCursor` | Theme-defined | Input cursor (blink) |
| `QuickVisual` | Theme-defined | Input selection |
| `QuickSel` | Theme-defined | Focused button / radio selected item / check selected item |
| `QuickBorder` | Theme-defined | Border |
| `QuickOff` | Dynamically generated | Unfocused input: `overlay(QuickInput, QuickDefaultDisable)` |
| `QuickButtonOn2` | Dynamically generated | Focused button hotkey: `make_underline(QuickSel)` |
| `QuickButtonOff2` | Dynamically generated | Unfocused button hotkey: `make_underline(QuickBG)` |

### Key Dispatch Priority

```
getchar() → ch
  │
  ├── ESC / Ctrl-C → cancel exit
  ├── Tab → focus forward
  ├── S-Tab → focus backward
  ├── LeftMouse → s:handle_mouse()
  ├── Vim close button → cancel exit
  │
  └── Dispatch by focus type:
      ├── input → s:handle_input(ch)     ← does NOT check hotkey
      ├── radio → hotkey? → s:handle_radio(ch)
      ├── check → hotkey? → s:handle_check(ch)
      ├── button → hotkey? → s:handle_button(ch)
      └── dropdown → hotkey? → s:handle_dropdown(ch)
```

When input is focused, hotkeys are skipped to prevent user text input from being intercepted by button hotkeys.

### Prompt Alignment Group Algorithm

1. Iterate all controls, skipping label and separator (they do not break alignment groups)
2. Consecutive interactive controls with prompts (input/radio/check/dropdown) form an alignment group
3. Interactive controls without a prompt break the alignment group
4. Within a group, all controls' `prompt_width` = longest prompt width + 2

### Validator Mechanism

`opts.validator` accepts a Funcref that is called before the dialog exits normally (`exit_index >= 0`). It is NOT called on cancel exit (ESC / Ctrl-C / close button, i.e., `exit_index < 0`).

**Call timing**: At the end of the main loop, after `handle_key()` sets `exit=1` and before `endwhile`.

**Signature**: `validator(result) -> String|Number`
- Parameter `result`: A Dict with the same structure as the `open()` return value (built via `s:collect_result()`, containing `button` / `button_index` and all control values)
- Returns `0` or `''` — validation passed, dialog exits normally
- Returns a non-empty string — validation failed, resets `exit=0` to continue the loop, displays the string at the bottom via `echohl ErrorMsg` (no prefix added, caller controls the wording)

**Implementation details**:
- After each validator rejection, `render_all()` + `redraw` restores the dialog display before echoing the error
- The error message naturally disappears on the user's next keypress (overwritten by `redraw`)
- The validator can be called multiple times (user repeatedly attempts to submit)

### Vim/Neovim Compatibility

The dialog module shields platform differences through `quickui#window`, with direct branching in only two places:

1. **`s:handle_mouse()`**: Vim uses `getmousepos()` (coordinates are already content-area-relative), Neovim uses `v:mouse_*` and additionally checks the border window close button
2. **Close button detection**: Vim via `hwnd.win.quit != 0` (set by popup callback), Neovim via mouse click on the border window's top-right corner

## Testing

### Interactive Tests

```vim
:source test/test_dialog.vim
:call Test_dialog_basic()

:source test/test_dialog_dropdown.vim
:call Test_dropdown_basic()      " basic dropdown
:call Test_separator_basic()     " separator line
:call Test_dropdown_full()       " dropdown + separator + other controls combined
:call Test_dropdown_index()      " default index
:call Test_dropdown_scroll()     " large number of items scrolling

:source test/test_dialog_validator.vim
:call Test_validator_basic()     " empty field validation blocks exit
:call Test_validator_number()    " return 0 means pass
:call Test_validator_cancel()    " cancel does not trigger validator
```

11 interactive test functions requiring manual operation to verify.

### Automated Tests

```bash
vim -u NONE -N -i NONE -n --not-a-term -es \
    -c "set rtp+=." \
    -c "source test/test_dialog_auto.vim"

vim -u NONE -N --noplugin -es --cmd "set lines=40 columns=100" \
    -S test/test_dialog_headless.vim
```

- Exit code 0 = pass, non-zero = fail
- `test_dialog_auto.vim`: 12 test cases, 27 assertions
- `test_dialog_headless.vim`: 4 test cases, 6 assertions (including separator/dropdown)
- Uses `feedkeys()` to inject key sequences simulating user operations

## Known Limitations and Future Extensions

1. **No scrolling support** — dialog has a static layout; an error is raised when total control height exceeds screen size
2. **Input is single-line only** — could be extended in the future via `multiline: 1`
3. **Button activation closes immediately** — could add callback functions in the future for "Apply"-style non-closing buttons
4. **Control disabling** — `enable: 0` field reserved
5. **Value change callbacks** — Reserved for radio/check/dropdown value change triggers
6. **Field validation** — Reserved for input/dropdown `validate` callbacks
