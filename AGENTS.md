# vim-quickui — Coding Agent Guide

## Project Overview

vim-quickui is a pure VimScript TUI component library for Vim 8.2+ and Neovim 0.4+. It provides Borland/Turbo C++ flavored popup-based UI widgets: **menu**, **listbox**, **inputbox**, **context menu**, **textbox**, **preview window**, **terminal**, **confirm dialog**, and a data-driven **dialog** system. No `+python` or external dependencies required.

## Repository Layout

```
plugin/quickui.vim          — Entry point: version, :QuickUI command, theme setup
autoload/quickui/
  core.vim                  — Platform abstraction, buffer pool, utility functions
  utils.vim                 — Item parsing (&hotkey), border drawing, text helpers
  window.vim                — Window abstraction (Vim popup / Neovim floating win)
  readline.vim              — Single-line text editing engine (Unicode-aware)
  highlight.vim             — Highlight group introspection & manipulation
  style.vim                 — Border style global setting
  menu.vim                  — Top menubar widget
  listbox.vim               — Scrollable listbox widget
  context.vim               — Context menu widget
  input.vim                 — Single-line input box (uses readline + window)
  textbox.vim               — Multi-line text display popup
  preview.vim               — Preview window (auto-close on CursorMoved)
  terminal.vim              — Terminal in popup window
  confirm.vim               — Simple confirm dialog
  dialog.vim                — Data-driven dialog with 7 control types
  tools.vim                 — High-level tools (buffer switcher, function list, etc.)
  palette.vim / palette9.vim — Color palette utilities
  tags.vim                  — Tag-related utilities
  command.vim               — :QuickUI command dispatcher
colors/quickui/*.vim        — Color scheme files (borland, gruvbox, solarized, etc.)
docs/                       — Internal module reference docs (for developer use)
test/                       — Test scripts (interactive + headless)
MANUAL.md                   — User manual (public API reference)
DIALOG.md                   — Dialog system user guide
```

## Architecture & Module Dependencies

```
                    plugin/quickui.vim  (entry, theme, :QuickUI command)
                            |
              +-------------+-------------+
              |             |             |
          core.vim      utils.vim     style.vim
          (platform,    (item parse,  (border
           buffer pool,  border gen,   style)
           win_execute)  text utils)
              |             |
              +------+------+
                     |
                 window.vim   (unified popup/floating window abstraction)
                     |
         +-----------+-----------+
         |           |           |
    readline.vim  highlight.vim  |
    (line editor) (hl groups)    |
         |           |           |
         +-----+-----+          |
               |                 |
           input.vim         textbox.vim  listbox.vim  context.vim  menu.vim
           (input box)      (text view)  (scrollable)  (ctx menu)  (menubar)
               |
           dialog.vim  (data-driven dialog: label/input/radio/check/button/separator/dropdown)
               |
           tools.vim   (buffer switcher, function list, help viewer, etc.)
```

### Key Dependency Rules

- `window.vim` depends on `core.vim` + `utils.vim` — never bypass this layer
- `readline.vim` is **UI-independent** — manages edit state only, no window operations
- `dialog.vim` depends on `window.vim` + `readline.vim` + `highlight.vim`
- All modules use `g:quickui#core#has_nvim` for platform detection (never re-detect)

## Code Style & Conventions

### VimScript Patterns

- **Language**: Pure legacy VimScript (no Vim9script). Target Vim 8.2+ and Neovim 0.4+
- **Modeline**: Every `.vim` file starts with a header block and contains a modeline:
  ```vim
  " vim: set ts=4 sw=4 tw=78 noet :
  ```
  or:
  ```vim
  " vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :
  ```
- **Indentation**: Tabs, not spaces. Tab width = 4
- **Naming**:
  - Public functions: `quickui#module#function_name()` (autoload convention)
  - Script-local functions: `s:function_name()` — use `abort` keyword
  - Script-local variables: `s:var_name`
  - Global flags: `g:quickui_option_name` (user-facing) or `g:quickui#module#var` (internal)
- **OOP pattern**: Objects are implemented as dictionaries with function references. Class templates are script-local dicts (e.g., `s:readline`, `s:window`). Constructor functions return `deepcopy()` of the template:
  ```vim
  let s:myclass = {}
  function! s:myclass.method() dict
      " self refers to the instance
  endfunc
  function! quickui#module#new()
      return deepcopy(s:myclass)
  endfunc
  ```
- **Section dividers**: Use comment blocks with `"------` or `"======` separators

### Platform Compatibility

Every feature must work on both Vim and Neovim. Key differences are abstracted in `core.vim` and `window.vim`:

| Capability | Vim | Neovim |
|---|---|---|
| Popup creation | `popup_create()` | `nvim_open_win()` |
| Show/hide | `popup_show()`/`popup_hide()` | Close and recreate window |
| Border | Native popup border | Simulated with a separate background window |
| Close button | Popup callback mechanism | Manual detection in border window |
| Win execute | `win_execute()` or `quickui#core#win_execute()` | Same wrapper |

**Important**: On Neovim, `winid` changes after `show(0)` + `show(1)`. Do not cache `winid` long-term.

### Coordinate System

- All QuickUI coordinates are **0-based** (`x=0, y=0` is top-left of the editor)
- Vim's popup API uses 1-based coordinates — `window.vim` handles the +1 conversion internally
- `window.vim` fields: `w`/`h` = content area size; `info.tw`/`info.th` = total size including border + padding

## Widget APIs (Public)

| Widget | Entry Function | Returns |
|---|---|---|
| Menu | `quickui#menu#open([namespace])` | Executes selected command |
| Listbox | `quickui#listbox#open(content, opts)` | Async (callback) |
| Listbox (sync) | `quickui#listbox#inputlist(items, opts)` | Selected index or -1 |
| Input | `quickui#input#open(prompt [, text [, history]])` | String or `''` |
| Context menu | `quickui#context#open(content, opts)` | Executes selected command |
| Textbox | `quickui#textbox#open(textlist, opts)` | — |
| Preview | `quickui#preview#open(filename, opts)` | — |
| Terminal | `quickui#terminal#open(cmd, opts)` | Async (callback) |
| Confirm | `quickui#confirm#open(msg [, choices [, default [, title]]])` | 1-based choice index |
| Dialog | `quickui#dialog#open(items [, opts])` | Dict with all control values |

### Dialog System

The dialog module (`dialog.vim`) is the most complex component. It supports 7 control types:

| Type | Focusable | Description |
|---|---|---|
| `label` | No | Static text (single or multiline) |
| `input` | Yes | Single-line text input with readline editing |
| `radio` | Yes | Radio button group (horizontal or vertical) |
| `check` | Yes | Checkbox toggle |
| `button` | Yes | Button row (activating closes dialog) |
| `separator` | No | Horizontal divider line |
| `dropdown` | Yes | Collapsed selection with popup list |

Key design points:
- **Data-driven**: Declare controls as a list of dicts, get back a result dict
- **Prompt alignment**: Consecutive prompted controls auto-align their prompts
- **Hotkey system**: `&` prefix marks hotkey characters; disabled when input is focused
- **Validator**: Optional `opts.validator` Funcref to reject exit with error message
- **History**: Input controls share cross-call history via `history` key

See `DIALOG.md` for the full user guide, and `docs/dialog.md` for internal architecture details.

## Highlight Groups

### Theme-defined groups (set by color scheme files in `colors/quickui/`)

| Group | Purpose |
|---|---|
| `QuickDefaultBackground` | Window background |
| `QuickDefaultSel` | Selected/focused item |
| `QuickDefaultKey` | Hotkey character |
| `QuickDefaultDisable` | Disabled item |
| `QuickDefaultHelp` | Tip text |
| `QuickDefaultBorder` | Border |
| `QuickDefaultTermBorder` | Terminal border |
| `QuickDefaultPreview` | Preview window background |
| `QuickDefaultInput` | Input field text |
| `QuickDefaultCursor` | Input cursor |
| `QuickDefaultVisual` | Input selection |

### Alias groups (set in `plugin/quickui.vim`, linked to defaults)

`QuickBG`, `QuickSel`, `QuickKey`, `QuickOff`, `QuickHelp`, `QuickBorder`, `QuickTermBorder`, `QuickPreview`, `QuickInput`, `QuickCursor`, `QuickVisual`

### Dynamically generated groups (created at runtime)

| Group | Purpose | Generator |
|---|---|---|
| `QuickOff` | Unfocused input | `highlight.vim` overlay |
| `QuickButtonOn2` | Focused button hotkey underline | `highlight.vim` make_underline |
| `QuickButtonOff2` | Unfocused button hotkey underline | `highlight.vim` make_underline |

When adding new widgets, reuse existing highlight groups. Only create new `QuickDefault*` groups if the existing ones cannot express the needed visual state.

## Testing

### Test Structure

Tests live in `test/`. There are two kinds:

1. **Interactive tests** (`test/test_*.vim`) — Source in Vim manually:
   ```vim
   :source test/test_dialog.vim
   :call Test_dialog_basic()
   ```
   These require human interaction to verify visual behavior.

2. **Headless/automated tests** — Run from command line with exit code verification:
   ```bash
   # Headless test (uses feedkeys to simulate input)
   vim -u NONE -N --noplugin -es --cmd "set lines=40 columns=100" \
       -S test/test_dialog_headless.vim

   # Auto test (with rtp setup)
   vim -u NONE -N -i NONE -n --not-a-term -es \
       -c "set rtp+=." \
       -c "source test/test_dialog_auto.vim"
   ```
   Exit code 0 = pass, non-zero = fail.

### Test Patterns

- **feedkeys injection**: Use `call feedkeys("\<ESC>", 't')` before `dialog#open()` to inject key sequences
- **assert helpers**: Define `s:assert_equal(expected, actual, msg)` or `s:assert(msg, cond)` locally
- **runtime loading**: Headless tests must explicitly `runtime` or `set rtp+=` to load autoload modules
- **Result checking**: Call the API, check return value fields

### Running Tests

From the project root:
```bash
# Run headless dialog tests
vim -u NONE -N --noplugin -es --cmd "set lines=40 columns=100" -S test/test_dialog_headless.vim

# Run automated dialog tests
vim -u NONE -N -i NONE -n --not-a-term -es -c "set rtp+=." -c "source test/test_dialog_auto.vim"
```

### Writing New Tests

When adding features, write both interactive and headless tests where possible. Follow the existing pattern:
```vim
" headless test template
set rtp+=.
" runtime load all needed modules...

let s:pass = 0
let s:fail = 0

function! s:assert(msg, cond)
    if a:cond
        let s:pass += 1
    else
        let s:fail += 1
        echoerr 'FAIL: ' . a:msg
    endif
endfunc

" Test case: inject keys then call API
call feedkeys("\<ESC>", 't')
let result = quickui#dialog#open(items, opts)
call s:assert('description', result.field == expected)

" Report and exit
echo printf('Results: %d passed, %d failed', s:pass, s:fail)
if s:fail > 0
    cquit!
endif
qall!
```

## Development Guidelines

### Adding a New Widget

1. Create `autoload/quickui/newwidget.vim` following the existing module structure
2. Use `quickui#window#new()` for window management — never call `popup_create()` / `nvim_open_win()` directly
3. Use `quickui#core#has_nvim` for platform branching (not `has('nvim')` inline)
4. Reuse `quickui#utils#item_parse()` for menu-item-like content with `&` hotkeys
5. Reuse existing highlight groups (`QuickBG`, `QuickSel`, `QuickKey`, etc.)
6. Add test files in `test/`

### Adding a New Dialog Control Type

1. Add parsing logic in `s:parse_items()` in `dialog.vim`
2. Add a `s:render_<type>()` function
3. Add a `s:handle_<type>()` function for key events
4. Register in `s:build_focus_list()` if focusable
5. Register in `s:build_keymap()` if it has hotkeys
6. Add to `s:collect_result()` to include its value in the return dict
7. Update `DIALOG.md` with the new control type documentation
8. Write headless tests using `feedkeys()` injection

### Adding a New Color Scheme

1. Create `colors/quickui/mytheme.vim`
2. Define all `QuickDefault*` highlight groups
3. Register the name alias in `QuickThemeChange()` in `plugin/quickui.vim`

### Common Pitfalls

- **Never read `self.text` directly on readline** — it may be stale. Always call `rl.update()` first
- **Neovim winid instability** — `show(0)` + `show(1)` creates a new window ID. Don't cache it
- **Buffer lifecycle** — Use `quickui#core#buffer_alloc()` / `buffer_free()`. Don't create/wipe buffers manually
- **Input focus eats hotkeys** — When an input has focus, character keys go to readline, not to the hotkey dispatcher. This is by design
- **0-based vs 1-based** — QuickUI uses 0-based coords internally. `button_index` in dialog return values is 1-based (consistent with `confirm#open`)
- **Border size accounting** — `window.move()` clips based on `info.tw`/`info.th` (total with border), not `w`/`h`

## Internal Reference Docs

Detailed internal specs live in `docs/`:

| File | Covers |
|---|---|
| `docs/core.md` | platform flags, buffer pool, border styles, string utils, screen helpers, macros |
| `docs/readline.md` | readline data model, all methods, rendering pipeline |
| `docs/window.md` | window abstraction, Vim/Neovim differences, options |
| `docs/dialog.md` | dialog architecture, control lifecycle, event dispatch, layout algorithm |
| `docs/palette.md` | 256-color palette, best-fit matching, hex/RGB/name conversion, alpha blending |

These docs describe internal implementation details — data structures, function signatures, rendering flow, and platform branching logic. Consult them when modifying core modules.
