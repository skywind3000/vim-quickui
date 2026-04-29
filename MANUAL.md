# User Manual

QuickUI is fully customizable and easy to configure.

# Content

<!-- TOC -->

- [User Manual](#user-manual)
- [Content](#content)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Available Widgets](#available-widgets)
    - [Menu](#menu)
    - [Context menu](#context-menu)
    - [Dialog](#dialog)
    - [Listbox](#listbox)
    - [Textbox](#textbox)
    - [Preview window](#preview-window)
    - [Inputbox](#inputbox)
    - [Terminal](#terminal)
    - [Confirm dialog](#confirm-dialog)
  - [Tools](#tools)
    - [Buffer switcher](#buffer-switcher)
    - [Function list](#function-list)
    - [Help viewer](#help-viewer)
    - [Preview tag](#preview-tag)
    - [Preview quickfix](#preview-quickfix)
  - [Customize](#customize)
    - [How to change border style](#how-to-change-border-style)
    - [How to change the color scheme](#how-to-change-the-color-scheme)
    - [How to change preview window size](#how-to-change-preview-window-size)
    - [Specify color group precisely](#specify-color-group-precisely)
  - [Who Am I ?](#who-am-i-)
  - [Credit](#credit)

<!-- /TOC -->

## Requirements

- Vim: 8.2 or later.
- NeoVim: 0.4.0 or later.

## Installation

    Plug 'skywind3000/vim-quickui'

## Available Widgets

### Menu

Displays a dropdown menubar at the top of the screen:

![](https://skywind3000.github.io/images/p/quickui/mainmenu.png)

**Usage**:

- `h` / `CTRL+h` / `LEFT`: move left.
- `l` / `CTRL+l` / `RIGHT`: move right.
- `j` / `CTRL+j` / `DOWN`: move down.
- `k` / `CTRL+k` / `UP`: move up.
- `SPACE` / `ENTER`: confirm.
- `ESC` / `CTRL+[`: cancel.
- `H`: move to the leftmost menu.
- `L`: move to the rightmost menu.
- `J`: move to the last item.
- `K`: move to the first item.

Note: `hjkl` may be overridden by user hotkeys, so `CTRL`+`hjkl` or arrow keys can be used at all times.

**APIs**:

Register menu entries:

```VimL
call quickui#menu#install(section, items [, weight [, filetypes]])
```

Display the menu:

```VimL
call quickui#menu#open()
```

**Sample code**:

```VimL
" clear all the menus
call quickui#menu#reset()

" install a 'File' menu, use [text, command] to represent an item.
call quickui#menu#install('&File', [
            \ [ "&New File\tCtrl+n", 'echo 0' ],
            \ [ "&Open File\t(F3)", 'echo 1' ],
            \ [ "&Close", 'echo 2' ],
            \ [ "--", '' ],
            \ [ "&Save\tCtrl+s", 'echo 3'],
            \ [ "Save &As", 'echo 4' ],
            \ [ "Save All", 'echo 5' ],
            \ [ "--", '' ],
            \ [ "E&xit\tAlt+x", 'echo 6' ],
            \ ])

" items with tips; tips are shown in the cmdline
call quickui#menu#install('&Edit', [
            \ [ '&Copy', 'echo 1', 'help 1' ],
            \ [ '&Paste', 'echo 2', 'help 2' ],
            \ [ '&Find', 'echo 3', 'help 3' ],
            \ ])

" script inside %{...} will be evaluated and expanded in the string
call quickui#menu#install("&Option", [
			\ ['Set &Spell %{&spell? "Off":"On"}', 'set spell!'],
			\ ['Set &Cursor Line %{&cursorline? "Off":"On"}', 'set cursorline!'],
			\ ['Set &Paste %{&paste? "Off":"On"}', 'set paste!'],
			\ ])

" register HELP menu with weight 10000
call quickui#menu#install('H&elp', [
			\ ["&Cheatsheet", 'help index', ''],
			\ ['T&ips', 'help tips', ''],
			\ ['--',''],
			\ ["&Tutorial", 'help tutor', ''],
			\ ['&Quick Reference', 'help quickref', ''],
			\ ['&Summary', 'help summary', ''],
			\ ], 10000)

" enable tip display in the cmdline
let g:quickui_show_tip = 1

" hit space twice to open menu
noremap <space><space> :call quickui#menu#open()<cr>
```

Then you can open the menu by pressing space twice. If the 4th parameter `filetypes` is provided as a comma-separated list, the menu appears only when the current file type matches an entry in the list.

```VimL
call quickui#menu#install('&C/C++', [
            \ [ '&Compile', 'echo 1' ],
            \ [ '&Run', 'echo 2' ],
            \ ], '<auto>', 'c,cpp')
```

This `C/C++` menu is visible only when the `filetype` of the current buffer is `c` or `cpp`.

Menus can also be organized into [multiple namespaces](https://github.com/skywind3000/vim-quickui/wiki/Menu-Namespaces). The `quickui#menu#open` function accepts an optional argument:

```VimL
call quickui#menu#open('abc')
```

When invoked with the argument `"abc"`, menus in the `"abc"` namespace are displayed. If the argument is omitted, the default namespace `"system"` is used.

### Context menu

Context menu imitates the Windows right-click menu and appears near the cursor:

![](https://skywind3000.github.io/images/p/quickui/context.png)

It is typically used to present commands relevant to the source code at the current line.

**APIs**:

Open the context menu:

```VimL
quickui#context#open(content, opts)
```

Parameter `content` is a list of `[text, command]` items. `opts` is a dictionary sharing the same options as `listbox`, with one addition:

- `ignore_case`: ignore case when matching keywords, default 1.

**Sample code**:

```VimL
let content = [
            \ ["&Help Keyword\t\\ch", 'echo 100' ],
            \ ["&Signature\t\\cs", 'echo 101'],
            \ ['-'],
            \ ["Find in &File\t\\cx", 'echo 200' ],
            \ ["Find in &Project\t\\cp", 'echo 300' ],
            \ ["Find in &Defintion\t\\cd", 'echo 400' ],
            \ ["Search &References\t\\cr", 'echo 500'],
            \ ['-'],
            \ ["&Documentation\t\\cm", 'echo 600'],
            \ ]
" set cursor to the last position
let opts = {'index':g:quickui#context#cursor}
call quickui#context#open(content, opts)
```

You can define your own context menu and map it to `K` (overriding the default `keywordprg` command) for a much more powerful `K` command.

### Dialog

`quickui#dialog#open()` provides a data-driven dialog system. Simply declare a list of controls, and it pops up a dialog containing inputs, radio buttons, checkboxes, dropdowns, buttons, separators, etc. Once the user finishes interacting, all control values are returned.

#### Quick Start

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
│            < OK >    < Cancel >           │
│                                           │
└───────────────────────────────────────────┘
```

#### API

```vim
let result = quickui#dialog#open(items [, opts])
```

- `items` — `List<Dict>`, each element describes a control
- `opts` — `Dict` (optional), dialog-level options
- Returns — `Dict`, containing all control values and exit status

#### Control Types

##### label — Static Text

Not focusable. Used to display descriptive text.

```vim
{'type': 'label', 'text': 'Please fill in the form:'}
{'type': 'label', 'text': ['Line 1', 'Line 2']}   " multiline
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | String | Yes | `'label'` |
| `text` | String / List | Yes | Display text. String is split by `\n`; List uses one element per line |

##### input — Single-line Text Input

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

##### radio — Radio Button Group

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

##### check — Checkbox

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

##### button — Button Row

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

##### separator — Separator Line

Not focusable. Draws a horizontal line to visually group controls.

```vim
{'type': 'separator'}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | String | Yes | `'separator'` |

Layout (using border character):
```
├───────────────────────────────────────────┤
```

The separator character matches the dialog border style (e.g., `─` for single-line borders, `-` for ASCII borders). When the dialog has no border, a plain `-` is used.

**Note**: Separators replace the automatic gap between controls — no blank lines are inserted before or after a separator.

##### dropdown — Dropdown List

Focusable. Displays a collapsed selection field that opens a self-drawn popup list when activated.

```vim
{'type': 'dropdown', 'name': 'lang', 'prompt': 'Language:',
 \ 'items': ['Python', 'C/C++', 'Java', 'Go'], 'value': 1}
```

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | String | Yes | — | `'dropdown'` |
| `name` | String | Yes | — | Control name, used as key in return value |
| `prompt` | String | No | `''` | Label text on the left side (participates in prompt alignment) |
| `items` | List | Yes | — | Option text list |
| `value` | Number | No | `0` | Default selected index (0-based); clamped to valid range |

Collapsed layout:
```
Language:  [C/C++                        v]
```

When activated (Enter/Space/click), a popup list appears below the control:

```
Language:  [C/C++                        v]
           ┌────────────────────────────┐
           │  Python                     │
           │> C/C++                      │
           │  Java                       │
           │  Go                         │
           └────────────────────────────┘
```

**Collapsed keybindings** (when dropdown is focused in dialog):

| Key | Action |
|-----|--------|
| `Enter` / `Space` | Open popup list |
| `Left` / `h` | Select previous item (wraps) |
| `Right` / `l` | Select next item (wraps) |
| `Up` / `Down` | Move focus to adjacent control |

**Popup keybindings** (when popup list is open):

| Key | Action |
|-----|--------|
| `Up` / `k` | Move highlight up |
| `Down` / `j` | Move highlight down |
| `Home` / `gg` | Jump to first item |
| `End` / `G` | Jump to last item |
| `PageUp` / `PageDown` | Scroll by page |
| `Enter` / `Space` | Confirm selection and close popup |
| `Esc` | Cancel and close popup (value unchanged) |
| Mouse click | Select clicked item and close popup |

#### Dialog Options

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
| `validator` | Funcref | — | Validation function called before normal exit (see below) |

##### Validator

If `opts.validator` is provided, it is called before the dialog exits normally (i.e., `button_index >= 0`). It is **not** called on cancel (ESC / Ctrl-C / close button).

The function receives a single argument — the same Dict that `open()` would return — and should return:
- `0` or `''` (empty string) — validation passed, dialog exits normally
- A non-empty string — validation failed, the string is displayed as an error message with `ErrorMsg` highlight, and the dialog remains open

```vim
function! MyValidator(result) abort
    if a:result.username ==# ''
        return 'Username cannot be empty!'
    endif
    return ''
endfunc

let result = quickui#dialog#open(items, {
    \ 'title': 'Form',
    \ 'validator': function('MyValidator'),
    \ })
```

#### Return Value

Returns a Dict. **All control values are always included, regardless of confirm or cancel**:

| Field | Type | Description |
|-------|------|-------------|
| `button` | String | Name of the button that triggered exit; `''` for Enter confirm or cancel |
| `button_index` | Number | Button index (**1-based**); `0` for Enter confirm; `-1` for cancel |
| `<input.name>` | String | Text content of the input |
| `<radio.name>` | Number | Selected option index (0-based) |
| `<check.name>` | Number | Checked state (0/1) |
| `<dropdown.name>` | Number | Selected item index (0-based) |

##### Detecting Exit Method

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

#### Hotkeys

Use `&` in button, radio, and check text to mark a hotkey character (e.g., `' &OK '` makes `O` the hotkey).

- **Button hotkey** — directly activates the button and closes the dialog
- **Radio hotkey** — selects the corresponding option without closing
- **Check hotkey** — toggles the checkbox without closing

Hotkeys are globally active when focus is **not** on an input. When an input is focused, all characters are treated as text input and hotkeys are disabled.

#### Focus Navigation

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

#### Layout Rules

##### Vertical Stacking

Controls are arranged top-to-bottom in the order of `items`.

##### Blank Line Separation

- Adjacent controls of **different** types are separated by `gap` blank lines (default: 1)
- Adjacent controls of the **same** type have **no** blank lines, forming a visual group
- **Separators** replace gaps — no blank lines are inserted before or after a separator

##### Prompt Alignment

Consecutive controls with prompts (input, radio, dropdown, check with prompt) are automatically aligned:

```
Name:      [skywind                       ]
Email:     [                              ]
Language:  [Python                       v]
Role:      (*) Dev  ( ) QA  ( ) PM
```

Labels and separators do not break alignment groups; only interactive controls without a prompt break the group.

#### Mouse Support

- Click input — focus and position cursor
- Click radio option — focus and select that option
- Click check — focus and toggle check state
- Click dropdown — focus and open popup list
- Click button — activate that button and close dialog
- Click close button (X) — cancel

#### Complete Examples

##### User Form

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

##### Simple Confirmation Dialog

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

##### Search Box with History

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

##### Label-only with Enter to Exit

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

##### Project Settings with Separator and Dropdown

```vim
let items = [
    \ {'type': 'input', 'name': 'project', 'prompt': 'Project:',
    \  'value': 'MyApp'},
    \ {'type': 'dropdown', 'name': 'lang', 'prompt': 'Language:',
    \  'items': ['Python', 'C/C++', 'Java', 'Go', 'Rust'], 'value': 0},
    \ {'type': 'dropdown', 'name': 'build', 'prompt': 'Build:',
    \  'items': ['Debug', 'Release', 'MinSizeRel'], 'value': 1},
    \ {'type': 'separator'},
    \ {'type': 'check', 'name': 'verbose', 'text': '&Verbose output'},
    \ {'type': 'check', 'name': 'parallel', 'text': '&Parallel build',
    \  'value': 1},
    \ {'type': 'separator'},
    \ {'type': 'button', 'name': 'action',
    \  'items': [' &Save ', ' &Cancel ']},
    \ ]

let result = quickui#dialog#open(items, {
    \ 'title': 'Project Settings', 'w': 50})

if result.button ==# 'action' && result.button_index == 1
    echo 'Project: ' . result.project
    echo 'Language: ' . result.lang        " index (0-based)
    echo 'Build: ' . result.build          " index (0-based)
    echo 'Verbose: ' . result.verbose
    echo 'Parallel: ' . result.parallel
endif
```

Result:
```
┌─ Project Settings ────────────────────────────┐
│                                                │
│  Project:   [MyApp                          ]  │
│  Language:  [Python                        v]  │
│  Build:     [Release                       v]  │
│                                                │
├────────────────────────────────────────────────┤
│                                                │
│  [ ] Verbose output                            │
│  [x] Parallel build                            │
│                                                │
├────────────────────────────────────────────────┤
│                                                │
│            < Save >    < Cancel >              │
│                                                │
└────────────────────────────────────────────────┘
```

#### Notes

1. **Names must be unique** — all controls with a name must not share the same name
2. **Multiple button rows need different names** — the default name is `'button'`; multiple button controls must each specify a different name
3. **Hotkeys must not conflict** — the `&` hotkey characters across different controls must be unique
4. **button_index is 1-based** — consistent with `quickui#confirm#open()`; the first button returns 1
5. **Height limit** — total control lines must not exceed screen height, otherwise an error is raised
6. **Values are preserved on cancel** — after ESC cancel, the return value still contains user-modified control values, useful for restoring state when reopening

### Listbox

When you have hundreds of items to deal with, a menu cannot hold them all — use a listbox instead.

![](https://skywind3000.github.io/images/p/quickui/listbox.png)

**Features**:

- Pick an item from thousands of entries.
- Columns separated by `"\t"` are automatically aligned.
- A scroll bar appears when there are too many items.
- Mouse wheel scrolls the content.
- Characters prefixed with `&` serve as shortcuts.
- Has a title and can be dragged with the mouse.
- Search items with `/` or `?`.
- Jump to a line number with `:`.

**Usage**:

- `j` / `CTRL+j` / `UP`: move up.
- `k` / `CTRL+k` / `DOWN`: move down.
- `J` / `CTRL+d`: half page down.
- `K` / `CTRL+u`: half page up.
- `H` / `CTRL+b` / `PageUp`: page up.
- `L` / `CTRL+f` / `PageDown`: page down.
- `SPACE` / `ENTER`: confirm.
- `ESC` / `CTRL+[`: cancel.
- `g`: go to the first item.
- `G`: go to the last item.
- `/`: search forwards.
- `?`: search backwards.
- `:`: go to line number.
- `n` / `CTRL+n`: next match.
- `N` / `CTRL+p`: previous match.

Note: `hjkl` or `n` may be overridden by user hotkeys, so `CTRL`+`hjkl` or `CTRL`+`n` can always be used.

**APIs**:

Open the listbox:

```VimL
quickui#listbox#open(content, opts)
```

Parameter `content` is a list of `[text, command]` items. `opts` is a dictionary of options:

- `title`: title of the listbox.
- `index`: initial cursor position, starting from 0.
- `w`: listbox width.
- `h`: listbox height.
- `col`: screen position in columns, starting from 1.
- `line`: screen position in lines, starting from 1.
- `color`: background color, defaults to `QuickBG`.
- `syntax`: the `filetype` applied to the `listbox`.
- `callback`: a function (`"fn(code)"` form) called after the listbox closes (on Enter or ESC).

All options are optional. The `callback` function receives a parameter `code` representing the selected item index. If you quit (`ESC`/`CTRL+[`) without making a selection, `code` will be `-1`.

The internal variable `g:quickui#listbox#cursor` stores the last cursor position (index) in the listbox. It can be used to restore the previous location.

**Sample code**:

```VimL
let content = [
            \ [ 'echo 1', 'echo 100' ],
            \ [ 'echo 2', 'echo 200' ],
            \ [ 'echo 3', 'echo 300' ],
            \ [ 'echo 4' ],
            \ [ 'echo 5', 'echo 500' ],
            \]
let opts = {'title': 'select one'}
call quickui#listbox#open(content, opts)
```

It can also work like the `inputlist()` function via `quickui#listbox#inputlist`, which returns the selected index immediately instead of executing a Vim command:

```VimL
let linelist = [
            \ "line &1",
            \ "line &2",
            \ "line &3",
            \ ]
" restore last position in previous listbox
let opts = {'index':g:quickui#listbox#cursor, 'title': 'select'}
echo quickui#listbox#inputlist(linelist, opts)
```

The key difference is that `open` returns immediately to Vim's event loop, while `inputlist` blocks until you select an item or press `ESC`.

### Textbox

Textbox displays arbitrary text in a popup window.

![](https://skywind3000.github.io/images/p/quickui/textbox.png)

**Features**:

- HJKL to scroll up/down, ESC to quit
- Supports syntax highlighting

**APIs**:

Open textbox:

```VimL
quickui#textbox#open(textlist, opts)
```

Run a shell command and display the output in the textbox:

```VimL
quickui#textbox#command(command, opts)
```

**Sample code**:

```VimL
" display vim messages in the textbox
function! DisplayMessages()
    let x = ''
    redir => x
    silent! messages
    redir END
    let x = substitute(x, '[\n\r]\+\%$', '', 'g')
    let content = filter(split(x, "\n"), 'v:key != ""')
    let opts = {"close":"button", "title":"Vim Messages"}
    call quickui#textbox#open(content, opts)
endfunc
```

This function displays Vim messages (`:messages`) in a text window:

![](https://skywind3000.github.io/images/p/quickui/messages.png)

Navigating the messages with `HJKL` or `PageUp/PageDown` is much handier than listing them in the command line with `:messages`.

### Preview window

The preview window replaces the traditional `:pedit` command, displaying a file in a small popup window near your cursor:

![](https://skywind3000.github.io/images/p/quickui/preview.png)

You can open the preview window with:

```VimL
quickui#preview#open(filename, opts)
```

It won't interfere with your work and closes automatically when you move the cursor. The second parameter `opts` is a dictionary with the following options:

| Option | Type | Default | Description |
|-|-|-|-|
| cursor | Number | -1 | If set above zero, that line is highlighted (using cursorline). |
| number | Number | 1 | Set to zero to disable line numbers |
| syntax | String | `unset` | Syntax file type, e.g., `cpp` or `python` |
| title | String | `unset` | Title for the preview window |
| persist | Number | 0 | By default the preview window closes automatically on `CursorMoved`. Set to 1 to close it manually with `quickui#preview#close()` |
| col | Number | `unset` | Window position (column) |
| line | Number | `unset` | Window position (line) |
| w | Number | `unset` | Window width |
| h | Number | `unset` | Window height |

Syntax highlighting and cursorline are especially useful when peeking at symbol definitions.

The `filename` argument can also be a list of strings. In that case, the preview window displays the list content, and the `syntax` field in `opts` can be used for highlighting.

You can scroll the content in the preview window with:

```VimL
quickui#preview#scroll(offset)
```

Parameter `offset` is an integer: positive to scroll down, negative to scroll up.

### Inputbox

Prompts the user to input a string in a TUI box:

![](https://skywind3000.github.io/images/p/quickui/input1.png)

Can serve as a drop-in replacement for the `input()` function.

**APIs**:

```VimL
quickui#input#open(prompt [, text [, history_key]])
```

**Sample code**

```VimL
echo quickui#input#open('Enter your name:', 'nobody')
```

**Usage**:

- `Left` / `Ctrl+B`: move cursor left.
- `Right` / `Ctrl+F`: move cursor right.
- `Shift+Left`: select left.
- `Shift+Right`: select right.
- `Ctrl+g`: select all.
- `Up` / `Ctrl+P`: previous history.
- `Down` / `Ctrl+N`: next history.
- `Ctrl+Insert`: copy to register `*`.
- `Shift+Insert`: paste from register `*`.
- `Ctrl+K`: kill all characters from cursor to end of line.
- `Ctrl+D`: delete character under cursor.
- `Ctrl+W`: delete word before cursor.
- `Home` / `Ctrl+A`: move cursor to the beginning.
- `End` / `Ctrl+E`: move cursor to the end.
- `Ctrl+R Ctrl+W`: read current word.
- `Ctrl+R =`: read evaluation.
- `Ctrl+R {reg}`: read register.

**Another sample**

```VimL
function! SearchBox()
	let cword = expand('<cword>')
	let title = 'Enter text to search:'
	let text = quickui#input#open(title, cword, 'search')
	if text != ''
		let text = escape(text, '[\/*~^')
		call feedkeys("\<ESC>/" . text . "\<cr>", 'n')
	endif
endfunc
```

You can search text with this function without dealing with special character escaping.

### Terminal

The `terminal` widget lets you open a terminal in a popup window:

```VimL
quickui#terminal#open(cmd, opts)
```

Parameter `cmd` can be a string or a list. `opts` is a dictionary with the following options:

| Option | Type | Default | Description |
|-|-|-|-|
| w | Number | 80 | Terminal window width |
| h | Number | 24 | Terminal window height |
| col | Number | `unset` | Window horizontal position |
| line | Number | `unset` | Window vertical position |
| border | Number | 1 | Use `0` for no border |
| title | String | `unset` | Window title |
| callback | String/Function | `unset` | A function receiving the exit code when the terminal exits |

e.g.

```VimL
function! TermExit(code)
    echom "terminal exit code: ". a:code
endfunc

let opts = {'w':60, 'h':8, 'callback':'TermExit'}
let opts.title = 'Terminal Popup'
call quickui#terminal#open('python', opts)
```

This runs `python` in a popup window:

![](https://skywind3000.github.io/images/p/quickui/terminal.png)

This feature requires Vim `8.2.200` (NeoVim `0.4.0`) or later, enabling you to run various TUI programs in a popup window.

### Confirm dialog

This widget presents the user with a dialog from which a choice can be made. It returns the number of the choice. For the first choice, this is 1.

```VimL
quickui#confirm#open(msg, [choices, [default, [title]]])
```

e.g.

```VimL
let question = "What do you want ?"
let choices = "&Apples\n&Oranges\n&Bananas"

let choice = quickui#confirm#open(question, choices, 1, 'Confirm')

if choice == 0
	echo "make up your mind!"
elseif choice == 3
	echo "tasteful"
else
	echo "I prefer bananas myself."
endif
```

Result:

![](https://skywind3000.github.io/images/p/quickui/confirm1.png)

Use `h` and `l` to move the cursor, `<space>` or `<cr>` to confirm, and `<ESC>` to cancel. Mouse is also supported.

## Tools

Tools are built on top of the basic widgets.

### Buffer switcher

There is a built-in buffer switcher using `listbox`. Open it with:

    call quickui#tools#list_buffer('e')

or

    call quickui#tools#list_buffer('tabedit')

Use `hjkl` to navigate, `enter`/`space` to switch buffer, and `ESC`/`CTRL+[` to quit:

![](https://skywind3000.github.io/images/p/quickui/listbox.png)

If there are many buffers listed, you can use `/` or `?` to search, and `n` or `N` to jump to the next / previous match.

Usage:

- `j`/`k`: navigate.
- `ESC`/`CTRL+[`: quit
- `Enter`: open with `switchbuf` rules (override with `g:quickui_switch_enter`).
- `Space`: open with `switchbuf` rules (override with `g:quickui_switch_space`).
- `CTRL+e`: edit in current window.
- `CTRL+x`: open in a new split.
- `CTRL+]`: open in a new vertical split.
- `CTRL+t`: open in a new tab.
- `CTRL+g`: open with `:drop` command.
- `/`: search.
- `?`: search backwards.

If you want to open a file in the current window when pressing `Space`, you can either change the `switchbuf` option or set `g:quickui_switch_space` manually:

```VimL
let g:quickui_switch_space = ''
```

Once defined, it overrides the `switchbuf` option. An empty string means edit in the current window.

    :h switchbuf

For more information, see the help for `switchbuf`.

### Function list

The function list can be activated with:

    call quickui#tools#list_function()

The cursor starts at the current function:

![](https://skywind3000.github.io/images/p/quickui/list-function.png)

Navigate and press enter to jump to the selected function. This feature requires `ctags` in your `$PATH`.

### Help viewer

Use `textbox` to display Vim help in a popup window:

    call quickui#tools#display_help('index')

See the screenshot:

![](https://skywind3000.github.io/images/p/quickui/display-help.png)

The only argument to `display_help` is the help tag name. With this tool, you can read help text at any time without creating a new split window.

### Preview tag

Sometimes you just want to glimpse the definition of the word under cursor without actually opening that file. The tag previewer was made for this:

![](https://skywind3000.github.io/images/p/quickui/preview_tag.png)

Use it like:

```VimL
nnoremap <F3> :call quickui#tools#preview_tag('')<cr>
```

When you move the cursor and press `<F3>`, the definition of the current `<cword>` is shown in the preview window. If there are multiple definitions, pressing `<F3>` again cycles to the next one. The command line shows the definition count and source file name.

Use `quickui#preview#scroll` to scroll the content in the preview window if you want to see more.

This feature requires ctags databases to be loaded correctly in Vim. The [gutentags](https://github.com/ludovicchabant/vim-gutentags) plugin can handle this automatically in the background.

### Preview quickfix

If you have many items in the quickfix window, instead of opening them one by one, you can press `p` in the quickfix window to preview them in a popup:

```VimL
augroup MyQuickfixPreview
  au!
  au FileType qf noremap <silent><buffer> p :call quickui#tools#preview_quickfix()<cr>
augroup END
```

This sets up a `p` keymap in the quickfix window to preview items. Press `p` again to close the preview window.

## Customize

### How to change border style

Change border characters:

    let g:quickui_border_style = 1   (default)

![](https://skywind3000.github.io/images/p/quickui/border1.png)


    let g:quickui_border_style = 2

![](https://skywind3000.github.io/images/p/quickui/border2.png)

    let g:quickui_border_style = 3

![](https://skywind3000.github.io/images/p/quickui/border3.png)

### How to change the color scheme

To change the color scheme, set the following option:

    let g:quickui_color_scheme = 'borland'

The default color scheme is `"borland"`.

Available color schemes:

![](https://skywind3000.github.io/images/p/quickui/colors.png)

### How to change preview window size

The default preview window width is 85 and height is 10. You can change them like this:

    let g:quickui_preview_w = 100
    let g:quickui_preview_h = 15

### Specify color group precisely

If none of the built-in color schemes suit your needs, you can define the color groups yourself in your `.vimrc` before the `VimEnter` event.

| Group | Meaning |
|-|-|
| QuickBG | Background color |
| QuickSel | Selector (or cursor) color |
| QuickKey | Hotkey (or shortcut-key) color |
| QuickOff | Disabled item color |
| QuickHelp | Tip text color |

The default `"borland"` color scheme is defined as:

```VimL
hi! QuickBG ctermfg=0 ctermbg=7 guifg=black guibg=gray
hi! QuickSel cterm=bold ctermfg=0 ctermbg=2 gui=bold guibg=brown guifg=gray
hi! QuickKey term=bold ctermfg=9 gui=bold guifg=#f92772
hi! QuickOff ctermfg=59 guifg=#75715e
hi! QuickHelp ctermfg=247 guifg=#959173
```

## Who Am I ?

My name is Lin Wei, an open source advocate and Vim enthusiast. I started learning programming in the early 1990s. Borland's Turbo Pascal/C++ was the most popular IDE at that time, and I really enjoyed those days — coming home from school, powering on my computer, launching Turbo C++ 3.1, and learning how to make games in MS-DOS.

I even imitated Turbo C++ and made my own editor when I moved to Watcom C++:

![](https://skywind3000.github.io/images/p/quickui/editor.png)

Because I didn't have a proper editor/IDE for Watcom C++ at that time.

After moving to Windows, I tried many GUI editors — from UltraEdit and EditPlus to Notepad++, from gedit to geany — but none fully satisfied me. Every day I was busy learning new IDEs, editors, or frameworks, and I had lost the true joy of programming. Then I discovered Vim and fell in love with it.

As Vim evolved, thanks to Bram's efforts, version 8.2 was released. I realized that maybe it was now possible to bring some of those cool things from 25 years ago into Vim. Maybe I could have a Borland/Turbo C++ flavored Vim in my everyday work, just like when I was a middle school student learning to make PC games in the golden 1990s.

It is time to bring these ideas to reality, starting with this plugin.

## Credit

Like vim-quickui? Follow the repository on [GitHub](https://github.com/skywind3000/vim-quickui) and vote for it on [vim.org](https://www.vim.org/scripts/script.php?script_id=5845). And if you're feeling especially charitable, follow skywind3000 on [Twitter](https://twitter.com/skywind3000) and [GitHub](https://github.com/skywind3000).
