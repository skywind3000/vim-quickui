# QuickUI Dialog User Guide

`quickui#dialog#open()` provides a data-driven dialog system. Simply declare a list of controls, and it pops up a dialog containing inputs, radio buttons, checkboxes, buttons, etc. Once the user finishes interacting, all control values are returned.

## Quick Start

```vim
let items = [
    \ {'type': 'label', 'text': 'Please fill in:'},
    \ {'type': 'input', 'name': 'username', 'prompt': 'Name:', 'value': 'skywind'},
    \ {'type': 'input', 'name': 'email', 'prompt': 'Email:'},
    \ {'type': 'button', 'name': 'confirm', 'items': [' &OK ', ' &Cancel ']},
    \ ]

let result = quickui#dialog#open(items, {'title': 'User Info'})

if result.button ==# 'confirm' && result.button_index == 1
    echo 'Name: ' . result.username
    echo 'Email: ' . result.email
endif
```

Result:

```
┌─ User Info ──────────────────────────────┐
│                                           │
│  Please fill in:                          │
│                                           │
│  Name:  [skywind                       ]  │
│  Email: [                              ]  │
│                                           │
│            < OK >    < Cancel >            │
│                                           │
└───────────────────────────────────────────┘
```

## API

```vim
let result = quickui#dialog#open(items [, opts])
```

- `items` — `List<Dict>`, each element describes a control
- `opts` — `Dict` (optional), dialog-level options
- Returns — `Dict`, containing all control values and exit status

## Control Types

### label — Static Text

Not focusable. Used to display descriptive text.

```vim
{'type': 'label', 'text': 'Please fill in the form:'}
{'type': 'label', 'text': ['Line 1', 'Line 2']}   " multiline
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | String | Yes | `'label'` |
| `text` | String / List | Yes | Display text. String is split by `\n`; List uses one element per line |

### input — Single-line Text Input

Focusable. Built-in readline editing (cursor movement, selection, clipboard, history browsing).

```vim
{'type': 'input', 'name': 'username', 'prompt': 'Name:', 'value': 'skywind'}
```

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | String | Yes | — | `'input'` |
| `name` | String | Yes | — | Control name, used as key in return value |
| `prompt` | String | No | `''` | Label text on the left side |
| `value` | String | No | `''` | Initial text |
| `history` | String | No | `''` | History namespace (shared across calls) |

**Editing keybindings** (when input is focused):

| Key | Action |
|-----|--------|
| Regular characters | Insert |
| `Left` / `Right` | Move cursor |
| `Home` / `End` | Beginning / end of line |
| `Ctrl+A` / `Ctrl+E` | Beginning / end of line |
| `Backspace` / `Delete` | Delete character |
| `Ctrl+K` / `Ctrl+U` | Delete to end / beginning of line |
| `Ctrl+W` | Delete previous word |
| `Shift+Left/Right` | Select text |
| `Ctrl+C` / `Ctrl+V` | Copy / paste |
| `Ctrl+Up` / `Ctrl+Down` | Browse history |
| `Enter` | Confirm dialog |
| `Up` / `Down` | Move focus to previous / next control |
| `Tab` / `S-Tab` | Move focus forward / backward |

### radio — Radio Button Group

Focusable. Use Left/Right/Space to switch between options.

```vim
{'type': 'radio', 'name': 'role', 'prompt': 'Role:',
 \ 'items': ['&Dev', '&QA', '&PM'], 'value': 0}
```

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | String | Yes | — | `'radio'` |
| `name` | String | Yes | — | Control name |
| `prompt` | String | No | `''` | Label on the left side |
| `items` | List | Yes | — | Option text list; `&` marks the hotkey character |
| `value` | Number | No | `0` | Default selected index (0-based) |
| `vertical` | Number | No | auto | `0` forces horizontal, `1` forces vertical; auto if omitted |

Horizontal layout: `Role:  (*) Dev  ( ) QA  ( ) PM`

Vertical layout (auto-switches when options are too wide):
```
Role:  (*) Development
       ( ) Quality Assurance
       ( ) Project Management
```

| Key | Action |
|-----|--------|
| `Left` / `h` | Select previous option |
| `Right` / `l` / `Space` | Select next option |
| `Enter` | Confirm dialog |
| `Up` / `Down` | Move focus |

### check — Checkbox

Focusable. Space toggles the checked state.

```vim
{'type': 'check', 'name': 'admin', 'text': '&Administrator'}
{'type': 'check', 'name': 'notify', 'text': 'Send &notification', 'value': 1}
```

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | String | Yes | — | `'check'` |
| `name` | String | Yes | — | Control name |
| `text` | String | Yes | — | Display text; `&` marks the hotkey character |
| `prompt` | String | No | `''` | Label on the left side (participates in prompt alignment when set) |
| `value` | Number | No | `0` | 0 = unchecked, 1 = checked |

Layout: `[x] Administrator` or `Admin:  [x] Administrator` (with prompt)

| Key | Action |
|-----|--------|
| `Space` | Toggle check |
| `Enter` | Confirm dialog |
| `Up` / `Down` | Move focus |

### button — Button Row

Focusable. Buttons are centered. Activating any button closes the dialog.

```vim
{'type': 'button', 'name': 'confirm', 'items': [' &OK ', ' &Cancel ']}
```

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | String | Yes | — | `'button'` |
| `name` | String | No | `'button'` | Control name |
| `items` | List | Yes | — | Button text list; `&` marks the hotkey character |
| `value` | Number | No | `0` | Default focused button index (0-based) |

Layout: `< OK >    < Cancel >`

| Key | Action |
|-----|--------|
| `Left` / `h` | Switch to left button |
| `Right` / `l` | Switch to right button |
| `Space` / `Enter` | Activate current button and close dialog |

## Dialog Options

Passed via the second parameter `opts`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | String | `'Dialog'` | Title text |
| `w` | Number | auto | Content area width (auto-calculated if omitted) |
| `min_w` | Number | `40` | Minimum width for auto-calculation |
| `border` | Number | `g:quickui#style#border` | Border style |
| `center` | Number | `1` | Whether to center the dialog |
| `padding` | List | `[1,1,1,1]` | Inner padding `[top, right, bottom, left]` |
| `color` | String | `'QuickBG'` | Background highlight group |
| `bordercolor` | String | `'QuickBorder'` | Border highlight group |
| `gap` | Number | `1` | Number of blank lines between different control types |
| `button` | Number | `1` | Whether to show the close button |
| `focus` | String | — | Name of the control to receive initial focus |

## Return Value

Returns a Dict. **All control values are always included, regardless of confirm or cancel**:

| Field | Type | Description |
|-------|------|-------------|
| `button` | String | Name of the button that triggered exit; `''` for Enter confirm or cancel |
| `button_index` | Number | Button index (**1-based**); `0` for Enter confirm; `-1` for cancel |
| `<input.name>` | String | Text content of the input |
| `<radio.name>` | Number | Selected option index (0-based) |
| `<check.name>` | Number | Checked state (0/1) |

### Detecting Exit Method

```vim
let r = quickui#dialog#open(items, opts)

" User clicked the OK button (button name='confirm', OK is the 1st button)
if r.button ==# 'confirm' && r.button_index == 1
    " Handle confirm logic
endif

" User pressed Enter from input/radio/check (button='' but button_index=0)
if r.button ==# '' && r.button_index == 0
    " Handle Enter confirm
endif

" User cancelled (ESC / Ctrl-C / close button: button='' and button_index=-1)
if r.button ==# '' && r.button_index == -1
    " Handle cancel (r still contains user-modified values)
endif
```

## Hotkeys

Use `&` in button, radio, and check text to mark a hotkey character (e.g., `' &OK '` makes `O` the hotkey).

- **Button hotkey** — directly activates the button and closes the dialog
- **Radio hotkey** — selects the corresponding option without closing
- **Check hotkey** — toggles the checkbox without closing

Hotkeys are globally active when focus is **not** on an input. When an input is focused, all characters are treated as text input and hotkeys are disabled.

## Focus Navigation

| Key | Action |
|-----|--------|
| `Tab` | Move focus to next control (wraps around) |
| `Shift-Tab` | Move focus to previous control (wraps around) |
| `Up` | Move focus backward (vertical intuition) |
| `Down` | Move focus forward (vertical intuition) |

Initial focus defaults to the first focusable control. Use `opts.focus` to specify initial focus:

```vim
let result = quickui#dialog#open(items, {'focus': 'email'})
```

## Layout Rules

### Vertical Stacking

Controls are arranged top-to-bottom in the order of `items`.

### Blank Line Separation

- Adjacent controls of **different** types are separated by `gap` blank lines (default: 1)
- Adjacent controls of the **same** type have **no** blank lines, forming a visual group

### Prompt Alignment

Consecutive controls with prompts (input, radio, check with prompt) are automatically aligned:

```
Name:   [skywind                       ]
Email:  [                              ]
Role:   (*) Dev  ( ) QA  ( ) PM
```

Labels do not break alignment groups; only interactive controls without a prompt break the group.

## Mouse Support

- Click input — focus and position cursor
- Click radio option — focus and select that option
- Click check — focus and toggle check state
- Click button — activate that button and close dialog
- Click close button (X) — cancel

## Complete Examples

### User Form

```vim
let items = [
    \ {'type': 'label', 'text': 'Please fill in the user form:'},
    \ {'type': 'input', 'name': 'username', 'prompt': 'Name:',
    \  'value': 'skywind'},
    \ {'type': 'input', 'name': 'email', 'prompt': 'Email:'},
    \ {'type': 'radio', 'name': 'role', 'prompt': 'Role:',
    \  'items': ['&Dev', '&QA', '&PM'], 'value': 0},
    \ {'type': 'check', 'name': 'admin', 'text': '&Administrator'},
    \ {'type': 'check', 'name': 'notify', 'text': 'Send &notification',
    \  'value': 1},
    \ {'type': 'button', 'name': 'confirm',
    \  'items': [' &OK ', ' &Cancel ']},
    \ ]

let result = quickui#dialog#open(items, {
    \ 'title': 'User Form', 'w': 50})

if result.button ==# 'confirm' && result.button_index == 1
    echo 'User: ' . result.username
    echo 'Email: ' . result.email
    echo 'Role: ' . result.role
    echo 'Admin: ' . result.admin
    echo 'Notify: ' . result.notify
endif
```

### Simple Confirmation Dialog

```vim
let items = [
    \ {'type': 'label', 'text': 'Are you sure you want to delete this file?'},
    \ {'type': 'button', 'name': 'confirm',
    \  'items': [' &Yes ', ' &No ']},
    \ ]

let result = quickui#dialog#open(items, {'title': 'Confirm Delete'})

if result.button ==# 'confirm' && result.button_index == 1
    echo 'Deleted!'
endif
```

### Search Box with History

```vim
let items = [
    \ {'type': 'input', 'name': 'pattern', 'prompt': 'Search:',
    \  'history': 'dialog_search'},
    \ {'type': 'check', 'name': 'case', 'text': 'Case &sensitive'},
    \ {'type': 'check', 'name': 'regex', 'text': 'Use &regex', 'value': 1},
    \ {'type': 'button', 'name': 'action',
    \  'items': [' &Find ', ' &Replace ', ' &Cancel ']},
    \ ]

let result = quickui#dialog#open(items, {
    \ 'title': 'Find and Replace', 'w': 50})
```

### Label-only with Enter to Exit

```vim
let items = [
    \ {'type': 'label', 'text': [
    \   'Build completed successfully!',
    \   '',
    \   'Output: /tmp/build/output',
    \   'Time: 3.2s',
    \ ]},
    \ {'type': 'button', 'name': 'done', 'items': [' &OK ']},
    \ ]

let result = quickui#dialog#open(items, {'title': 'Build Result'})
```

## Notes

1. **Names must be unique** — all controls with a name must not share the same name
2. **Multiple button rows need different names** — the default name is `'button'`; multiple button controls must each specify a different name
3. **Hotkeys must not conflict** — the `&` hotkey characters across different controls must be unique
4. **button_index is 1-based** — consistent with `quickui#confirm#open()`; the first button returns 1
5. **Height limit** — total control lines must not exceed screen height, otherwise an error is raised
6. **Values are preserved on cancel** — after ESC cancel, the return value still contains user-modified control values, useful for restoring state when reopening
