# QuickUI Core Module Reference

> **File**: `autoload/quickui/core.vim`
> **Dependencies**: None
> **Requires**: Vim 8.0+ / Neovim 0.4+

## Overview

`quickui#core` is the foundational infrastructure module of QuickUI. It provides platform detection flags, buffer pool management, popup/window caching, string and text utilities, border style definitions, screen coordinate helpers, project root detection, and macro expansion. Nearly every other QuickUI module depends on it.

## Global Platform Detection Flags

These variables are evaluated once at load time and used throughout QuickUI for platform branching:

| Variable | Type | Description |
|----------|------|-------------|
| `g:quickui#core#has_nvim` | Number | `has('nvim')` — running in Neovim |
| `g:quickui#core#has_vim9` | Number | `v:version >= 900` — Vim 9.0+ |
| `g:quickui#core#has_popup` | Number | `exists('*popup_create') && v:version >= 800` — Vim popup API available |
| `g:quickui#core#has_floating` | Number | `has('nvim-0.4')` — Neovim floating window API available |
| `g:quickui#core#has_nvim_040` | Number | Neovim 0.4+ |
| `g:quickui#core#has_nvim_050` | Number | Neovim 0.5+ |
| `g:quickui#core#has_nvim_060` | Number | Neovim 0.6+ |
| `g:quickui#core#has_vim_820` | Number | Vim 8.2+ (not Neovim) |
| `g:quickui#core#has_win_exe` | Number | `exists('*win_execute')` |
| `g:quickui#core#has_vim9script` | Number | Vim 9.0+ with vim9script support |

**Usage convention**: Always use these flags instead of calling `has()` inline. This ensures consistent detection and avoids redundant checks.

## Object Pool

Generic named object pool for reusing objects across calls. Used internally for caching reusable resources.

### `quickui#core#object_acquire(name)`

Acquires an object from the named pool.

- **Parameter**: `name` — Pool name string
- **Returns**: An object, or `v:null` if the pool is empty

### `quickui#core#object_release(name, obj)`

Returns an object to the named pool.

- **Parameters**: `name` — Pool name, `obj` — Object to release

## String Utilities

### `quickui#core#string_replace(text, old, new)`

Replaces all occurrences of `old` with `new` in `text`.

- Uses `split()` + `join()` internally (treats `old` as a pattern)

### `quickui#core#string_compose(target, pos, source)`

Overlays `source` onto `target` at character position `pos`.

- **Parameters**: `target` — Base string, `pos` — Character position (can be negative), `source` — String to overlay
- **Behavior**: If `pos` is negative, trims the leading portion of `source`. If `target` is shorter than `pos`, pads with spaces. Characters in `target` beyond the overlay range are preserved.

### `quickui#core#string_fit(source, size)`

Truncates `source` to fit within `size` bytes, inserting `..` in the middle if necessary.

- If `size <= 2`, returns dots
- Otherwise returns `left_half..right_half` totaling `size` bytes

### `quickui#core#string_strip(text)`

Strips leading and trailing whitespace (spaces, tabs, `\r`, `\n`) from `text`.

## Text Expansion

### `quickui#core#expand_text(string)`

Evaluates and expands `%{script}` expressions embedded in a string.

- **Example**: `"Spell %{&spell? 'Off':'On'}"` evaluates the VimL expression between `%{` and `}`, replacing it with the result
- Used in menu items to show dynamic state

## Key/Hotkey Parsing

### `quickui#core#escape(text)`

Parses `&`-prefixed hotkey markers from a text string.

- **Parameter**: `text` — String potentially containing `&X` hotkey markers
- **Returns**: List `[stripped_text, key_char, key_byte_pos, key_char_pos, key_display_pos]`
  - `stripped_text`: Text with `&` markers removed
  - `key_char`: The hotkey character (or `''` if none)
  - `key_byte_pos`: Byte position of the hotkey in stripped text (-1 if none)
  - `key_char_pos`: Character position (strchars-based)
  - `key_display_pos`: Display column position (strdisplaywidth-based)
- `&&` escapes to a literal `&`, `&~` escapes to a literal `~`

### `quickui#core#single_parse(description)`

Parses a single menu item description into a structured item object.

- **Parameter**: `description` — String or List `[text, command]`
- **Returns**: Dict with fields:
  - `part`: List of tab-separated text segments (hotkeys stripped)
  - `size`: Number of segments
  - `key_char`, `key_pos`, `key_idx`: Hotkey info from the first segment containing `&`
  - `cmd`: Associated command string

## Instance and Local Data Management

### `quickui#core#instance(local)`

Gets a shared data dictionary for storing QuickUI state.

- **Parameter**: `local` — `0` for global (`g:__quickui__`), non-zero for tab-local (`t:__quickui__`)
- **Returns**: The dictionary (created if it doesn't exist)

### `quickui#core#object(bid)`

Gets the QuickUI data dictionary attached to a specific buffer.

- **Parameter**: `bid` — Buffer number (0 or negative uses current buffer)
- **Returns**: Dict (created as `b:__quickui__` if needed), or `v:null` if buffer doesn't exist

### `quickui#core#popup_local(winid)`

Gets the local data dictionary associated with a window ID.

- **Returns**: Dict stored in `g:__quickui__.popup_local[winid]` (created if needed)
- Used by widgets to attach per-window state

### `quickui#core#popup_clear(winid)`

Clears the local data associated with a window ID.

## Popup Window Cache (Vim Only)

Tab-local cache of pre-created popup windows for reuse, reducing popup creation overhead.

### `quickui#core#popup_alloc(name)`

Acquires a popup window from the named cache.

- **Parameter**: `name` — Cache name
- **Returns**: Window ID (either recycled or newly created via `popup_create()`)
- New popups are created hidden with default settings (`nonumber`, `nowrap`, `signcolumn=no`, `wincolor=QuickBG`)

### `quickui#core#popup_release(name, winid)`

Returns a popup window to the named cache (hides it for later reuse).

## Window Execution

### `quickui#core#win_execute(winid, command [, silent])`

Executes a command in the context of a specified window. Abstracts the platform difference:

- **Vim with popup**: Uses `win_execute()`
- **Neovim without win_execute**: Temporarily switches to the target window via `nvim_set_current_win()`, executes, then switches back
- **Neovim with win_execute**: Uses `win_execute()`

All calls use `keepalt` to preserve the alternate buffer.

- **Parameters**: `winid` — Target window, `command` — String or List of Ex commands, `silent` (optional, default 0) — Whether to execute silently

### `quickui#core#win_close(winid, force)`

Closes a window in a platform-compatible way.

- Vim: Executes `close[!]` via `win_execute()`
- Neovim: Calls `nvim_win_close()`
- **Returns**: `0` on success, `-1` if window not found

## Buffer Pool

Scratch buffer pool for reuse across widget lifecycles. Avoids creating and wiping buffers repeatedly.

### `quickui#core#buffer_alloc()`

Allocates a scratch buffer. Returns a recycled buffer from the pool if available, otherwise creates a new one.

- New buffers are configured: `nobuflisted`, `bufhidden=hide`, `buftype=nofile`, `noswapfile`
- Buffer content is cleared before returning
- **Returns**: Buffer ID

### `quickui#core#buffer_free(bid)`

Returns a buffer to the pool after clearing its content.

### `quickui#core#buffer_update(bid, textlist)`

Replaces the entire content of a buffer.

- **Parameters**: `bid` — Buffer ID, `textlist` — String (split by `\n`) or List of lines

### `quickui#core#buffer_clear(bid)`

Clears a buffer's content (equivalent to `buffer_update(bid, [])`).

### `quickui#core#scratch_buffer(name, textlist)`

Gets or creates a named scratch buffer and updates its content.

- **Parameters**: `name` — Buffer name (empty string for anonymous), `textlist` — Content
- Named buffers are cached and reused across calls
- **Returns**: Buffer ID

## Syntax Highlighting

### `quickui#core#high_region(name, srow, scol, erow, ecol, virtual)`

Generates a `syn region` command string for highlighting a rectangular area.

- **Parameters**: Highlight group `name`, start row/col, end row/col (all 1-based), `virtual` flag (0=byte column `c`, 1=virtual column `v`)
- **Returns**: A string like `syn region GroupName start=/\%3l\%5v/ end=/\%3l\%15v/`
- Used by `window.vim`'s `syntax_region()` method

## Border Styles

### Border String Format

Borders are defined as 11-character strings, where each character position represents:

```
Position:  0   1   2   3   4   5   6   7   8   9   10
Meaning:   TL  T   TR  L   M   R   BL  B   BR  ML  MR
           ┌   ─   ┐   │   ─   │   └   ─   ┘   ├   ┤
```

- TL/T/TR: Top-left corner, top edge, top-right corner
- L/R: Left edge, right edge
- BL/B/BR: Bottom-left corner, bottom edge, bottom-right corner
- ML/MR: Middle-left, middle-right (for separator lines)

### Built-in Border Styles

| Key | Style | Characters |
|-----|-------|------------|
| `0` / `'solid'` | Blank (spaces) | `'           '` |
| `1` / `'ascii'` / `'default'` | ASCII | `'+-+\|-\|+-+++'` |
| `2` / `'single'` | Single line | `'┌─┐│─│└─┘├┤'` |
| `3` / `'double'` | Double line | `'╔═╗║─║╚═╝╟╢'` |
| `4` / `'rounded'` | Rounded corners | `'╭─╮│─│╰─╯├┤'` |
| `5` | Slash | `'/-\\\|-\\\\-/++'` |
| `'none'` | No border | `[]` |

### Border Functions

#### `quickui#core#border_extract(pattern)`

Extracts an 11-character border string into a List of 11 individual characters.

#### `quickui#core#border_install(name, pattern)`

Registers a custom border style.

- **Parameters**: `name` — Style name, `pattern` — 11-character border string

#### `quickui#core#border_get(name)`

Returns the border character list for a style name. Falls back to ASCII if not found.

#### `quickui#core#border_vim(name)` / `quickui#core#border_nvim(name)`

Returns border characters in Vim popup format or Neovim floating window format (different character ordering).

#### `quickui#core#border_auto(name)`

Returns border characters in the format appropriate for the current platform.

#### `quickui#core#border_convert(pattern, nvim_format)`

Converts between internal 11-element format and Vim/Neovim 8-element border format.

- `nvim_format=0`: Vim ordering `[T, R, B, L, TL, TR, BR, BL]`
- `nvim_format=1`: Neovim ordering `[TL, T, TR, R, BR, B, BL, L]`

## Screen Coordinate Helpers

### `quickui#core#cursor_pos()`

Returns the current cursor's screen position as `[row, col]` (1-based).

### `quickui#core#in_screen(line, column, width, height)`

Checks whether a rectangle fits entirely within the screen.

- **Parameters**: All 1-based. `line`/`column` = top-left position, `width`/`height` = dimensions
- **Returns**: `1` if within screen, `0` if exceeding

### `quickui#core#screen_fit(line, column, width, height)`

Clamps a rectangle to fit within the screen.

- **Returns**: `[row, col]` (1-based) — adjusted top-left position

### `quickui#core#around_cursor(width, height)`

Finds the best position to place a popup of given size near the cursor.

- Tries below-right first, then flips horizontally/vertically if needed
- Falls back to `screen_fit()` clamping
- **Returns**: `[row, col]` (1-based)

## Project Root Detection

### `quickui#core#fullname(f)`

Resolves a filename to its full absolute path.

- Handles mark references (`'a`), `%` for current file, and Windows path normalization (`\` → `/`)

### `quickui#core#find_root(name, markers, strict)`

Finds the nearest parent directory containing any of the specified marker files/directories.

- **Parameters**: `name` — Starting file path, `markers` — List of marker names, `strict` — If 1, returns empty string when no marker found; if 0, returns the file's directory
- Uses Vim's `findfile()` / `finddir()` with upward search (`;` suffix)

### `quickui#core#project_root(name [, strict])`

Convenience wrapper around `find_root()` using default markers: `.project`, `.git`, `.hg`, `.svn`, `.root`.

- Respects `g:quickui_rootmarks` or `g:asyncrun_rootmarks` if defined

## Macro Expansion

### `quickui#core#expand_macros()`

Returns a Dict of predefined macros for template expansion:

| Macro | Value |
|-------|-------|
| `VIM_FILEPATH` | `expand("%:p")` — Full file path |
| `VIM_FILENAME` | `expand("%:t")` — File name only |
| `VIM_FILEDIR` | `expand("%:p:h")` — File directory |
| `VIM_FILENOEXT` | `expand("%:t:r")` — File name without extension |
| `VIM_PATHNOEXT` | `expand("%:p:r")` — Full path without extension |
| `VIM_FILEEXT` | `"." . expand("%:e")` — File extension with dot |
| `VIM_FILETYPE` | `&filetype` |
| `VIM_CWD` | `getcwd()` |
| `VIM_RELDIR` | `expand("%:h:.")` — Relative directory |
| `VIM_RELNAME` | `expand("%:p:.")` — Relative path |
| `VIM_CWORD` | `expand("<cword>")` — Word under cursor |
| `VIM_CFILE` | `expand("<cfile>")` — File under cursor |
| `VIM_CLINE` | `line('.')` — Current line number |
| `VIM_VERSION` | `v:version` |
| `VIM_SVRNAME` | `v:servername` |
| `VIM_COLUMNS` | `&columns` |
| `VIM_LINES` | `&lines` |
| `VIM_GUI` | `has('gui_running')` |
| `VIM_ROOT` | Project root path |
| `VIM_HOME` | First `rtp` entry |
| `VIM_PRONAME` | Project root directory name |
| `VIM_DIRNAME` | CWD directory name |
| `<cwd>` | Alias for `VIM_CWD` |
| `<root>` | Alias for `VIM_ROOT` |

## Miscellaneous Utilities

### `quickui#core#input(prompt, text)`

Safe wrapper around `input()` with `inputsave()`/`inputrestore()` and `Ctrl-C` handling.

### `quickui#core#chdir(path)`

Changes directory respecting the current scope (local/tab/global) via `lcd`/`tcd`/`cd`.

### `quickui#core#write_script(command, pause)`

Writes a shell script (`.cmd` on Windows, `.sh` on Unix) to a temp file for external command execution.

- **Parameters**: `command` — Shell command, `pause` — Whether to pause after execution
- **Returns**: Temp script file path

### `quickui#core#extract_opts(command)`

Extracts `-key=value` option flags from the beginning of a command string.

- **Returns**: `[remaining_command, opts_dict]`

### `quickui#core#split_argv(cmdline)`

Splits a command line string into an argv list, respecting backslash-escaped spaces.

### `quickui#core#execute_string(text)`

Executes a command string with special prefix handling:

| Prefix | Behavior |
|--------|----------|
| `funcname(...)` | Calls as a function via `call` |
| `<key>...` | Feeds remaining text as keystrokes |
| `@...` | Feeds remaining text as keystrokes |
| `<plug>...` | Feeds as `<plug>` mapping |
| (none) | Executes as Ex command |

### `quickui#core#mock_function(id, text)`

A no-op dummy function returning 0. Used as a placeholder callback.
