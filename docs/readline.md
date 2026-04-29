# QuickUI Readline Module Reference

> **File**: `autoload/quickui/readline.vim`
> **Dependencies**: None (pure VimL implementation)
> **Requires**: Vim 8.0+ / Neovim 0.4+

## Overview

`quickui#readline` is QuickUI's single-line text editing engine, providing Readline/Emacs-style line editing capabilities. It manages a character-level editing buffer with support for cursor movement, text insertion/deletion, visual selection, history browsing, cursor blinking, and viewport scrolling/rendering.

This module is the core dependency of the `quickui#input` input box — input.vim passes user keystrokes to the readline object via `rl.feed()`, readline processes the editing logic and produces rendering output via `rl.render()`, and input.vim then draws the rendering result into a popup/floating window.

### Design Highlights

- **Character-level editing**: Internally uses `str2list()` / `list2str()` to split text into Unicode codepoint arrays, natively supporting CJK and other multi-byte characters
- **Width-aware**: Maintains `strdisplaywidth` for each character, correctly handling mixed full-width/half-width text
- **Visual selection**: Supports Shift+arrow key selection operations, similar to modern editor behavior
- **Viewport scrolling**: Automatically slides the viewport to follow the cursor when text exceeds the display width
- **UI-independent**: readline itself performs no window operations — it purely manages editing state and rendering output

## Data Model

readline represents a line of text as three parallel arrays:

```
text:  "Hello世界"
code:  [72, 101, 108, 108, 111, 19990, 30028]    " Unicode codepoints
wide:  [1,  1,   1,   1,   1,   2,     2    ]    " display width of each character
size:  7                                          " character count
cursor: 5                                         " cursor is on '世'
```

- `code`: Result of `str2list()`, each element is a Unicode codepoint
- `wide`: `strdisplaywidth()` of each character, used for viewport calculations
- `size`: `len(code)`, character count (not byte count)
- `cursor`: Cursor position as character index (0-based, range `[0, size]`, equals size when cursor is at end)

## Class Definition: `s:readline`

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `cursor` | Number | 0 | Cursor position (character index, 0-based) |
| `code` | List | [] | Character codepoint array (`str2list()` result) |
| `wide` | List | [] | Display width of each character |
| `size` | Number | 0 | Total character count |
| `text` | String | '' | Text cache (synced after `update()`) |
| `dirty` | Number | 0 | Whether `code` has been modified but `text` not yet synced |
| `select` | Number | -1 | Visual selection anchor position (-1 means no selection) |
| `history` | List | [] | History record list |
| `index` | Number | 0 | Current history pointer (0 is the most recent) |
| `timer` | Number | -1 | Cursor blink timer start (millisecond timestamp, -1 means reset) |

### About `dirty` and `text`

The `code` array is the primary data source for editing operations. After each modification to `code`, `dirty` is set to 1, but the `text` string is not immediately updated (to avoid frequent `list2str` conversions). Calling `update()` syncs `text` and clears `dirty`.

`text` is primarily used for:
- Returning the final input result
- Saving history via `history_save()`

## Constructor

### `quickui#readline#new()`

Creates and returns a new readline object instance (a deep copy of `s:readline`).

```vim
let rl = quickui#readline#new()
```

## Method Reference

### Text Manipulation Methods

#### `rl.set(text)`

Sets the entire editing buffer content.

**Parameter**: `text` - String.

**Behavior**: Splits text into `code` and `wide` arrays, updates `size`, sets `dirty=1`, then clamps the current cursor to valid bounds.

#### `rl.update()`

Syncs the `code` array back to the `text` string.

**Returns**: The synced text string.

**Note**: This is the standard method for obtaining the editing result. Do not read `self.text` directly, as it may be stale.

#### `rl.insert(text)`

Inserts text at the current cursor position.

**Parameter**: `text` - String to insert.

**Behavior**: Splits text into codepoint and width arrays, inserts them into `code` and `wide` at the cursor position, then advances the cursor past the inserted text.

#### `rl.delete(size)`

Deletes `size` characters at and after the cursor position (like the Delete key).

**Parameter**: `size` - Number of characters to delete. Automatically clamped if exceeding available range.

Cursor position remains unchanged.

#### `rl.backspace(size)`

Deletes `size` characters before the cursor (like the Backspace key).

**Parameter**: `size` - Number of characters to delete. Automatically clamped if exceeding available range.

Cursor moves back by `size` positions.

#### `rl.replace(text)`

Replaces characters starting at the cursor position. First deletes `strchars(text)` characters, then inserts text.

### Cursor Movement Methods

#### `rl.move(pos)`

Moves the cursor to the specified position, automatically clamped to `[0, size]` range. Also resets the blink timer.

**Returns**: The clamped actual position.

#### `rl.seek(pos, mode)`

Relative/absolute cursor positioning (similar to C's `fseek`).

**Parameters**:
- `pos`: Offset
- `mode`: Reference point
  - `0`: From line start (absolute position)
  - `1`: From current position (relative offset)
  - `2`: From line end (`size + pos`)

**Examples**:
```vim
call rl.seek(0, 0)    " jump to line start
call rl.seek(0, 2)    " jump to line end
call rl.seek(-1, 1)   " move left one character
call rl.seek(1, 1)    " move right one character
```

#### `rl.is_eol()`

Returns whether the cursor is at the end of line (`cursor >= size`).

### Text Extraction Methods

#### `rl.extract(locate)`

Extracts text relative to the cursor position.

**Parameter**:
- `locate`:
  - `-1`: All text before the cursor
  - `0`: The character at the cursor
  - `1`: All text after the cursor

**Returns**: The extracted text string.

### Visual Selection Methods

The selection is bounded by two positions: `select` and `cursor`. `select` is the anchor (start position), `cursor` is the active end. `select == -1` means no selection.

#### `rl.visual_range()`

Returns the normalized selection range `[start, end)` (start <= end). Returns `[-1, -1]` when there is no selection.

#### `rl.visual_text()`

Returns the text string within the selection. Returns an empty string when there is no selection.

#### `rl.visual_delete()`

Deletes the selection content. Behavior depends on the relative positions of cursor and select:
- If `cursor > select`: equivalent to backspace-deleting characters between cursor and select
- If `cursor < select`: equivalent to forward-deleting characters between cursor and select

After deletion, `select` is reset to -1.

#### `rl.visual_replace(text)`

Replaces the selection content with text (calls `visual_delete()` then `insert(text)`).

### Display and Rendering Methods

This group of methods converts the editing state into displayable attributed text fragment lists.

#### Attribute Value Definitions

Each text fragment in the rendering output carries an attribute value:

| Attribute | Meaning | Corresponding highlight group (in input.vim) |
|-----------|---------|----------------------------------------------|
| `0` | Normal text | `QuickInput` |
| `1` | Cursor | `QuickCursor` (or `QuickInput` when blinking) |
| `2` | Selection | `QuickVisual` |
| `3` | Selection + Cursor | `QuickCursor` (or `QuickVisual` when blinking) |

#### `rl.display()`

Generates the full editing buffer as an attributed display list.

**Returns**: `List<[attr, text]>` — List of attribute values and text fragments.

**Example** (buffer is `"Hello, World!!"`, cursor on `W`, no selection):
```
[[0, "Hello, "], [1, "W"], [0, "orld !!"]]
```

**Example** (with selection, select=2, cursor=5):
```
[[0, "He"], [2, "llo"], [3, ","], [0, " World!!"]]
```

When the cursor is at the end of line, a space character is generated as a cursor placeholder.

#### `rl.window(display, start, endup)`

Clips the result of `display()` to a viewport, keeping only content within the character position range `[start, endup)`.

**Parameters**:
- `display`: Return value of `display()`
- `start`: Start character position (can be negative; negative portion is filled with spaces)
- `endup`: End character position (exclusive)

**Returns**: Clipped `List<[attr, text]>`. If the text is insufficient to fill the `[start, endup)` range, the end is padded with `[0, spaces]`.

#### `rl.render(pos, display_width)`

Core rendering method: generates a complete display list for a given viewport position and width.

**Parameters**:
- `pos`: Viewport start character position
- `display_width`: Viewport display width (column count)

**Returns**: `List<[attr, text]>` — Attributed text fragment list filling the entire viewport width.

**Behavior**:
1. Calls `avail()` to calculate how many characters the viewport can hold
2. Calls `display()` to get the full display list
3. Calls `window()` to clip to viewport range
4. If total width is less than `display_width`, pads with spaces carrying the correct attribute (considering cursor and selection extending to the viewport end)

#### `rl.slide(window_pos, display_width)`

Calculates the viewport sliding position to ensure the cursor is always visible.

**Parameters**:
- `window_pos`: Current viewport start position
- `display_width`: Viewport display width

**Returns**: New viewport start position.

**Logic**:
- If the cursor is to the left of the viewport (`cursor < window_pos`), slide the viewport left to the cursor position
- If the cursor is within the viewport, keep unchanged
- If the cursor exceeds the viewport right edge, slide the viewport right so the cursor just appears at the right edge

**Typical usage pattern** (in input.vim):
```vim
let hwnd.pos = rl.slide(hwnd.pos, hwnd.w)
let display = rl.render(hwnd.pos, hwnd.w)
```

### Width Calculation Methods

#### `rl.avail(pos, length)`

Calculates how many characters can fit starting from `pos` within the given display width.

**Parameters**:
- `pos`: Start character position
- `length`: Display width (positive counts rightward, negative counts leftward)

**Returns**: Number of characters that can fit.

**Note**: This method accounts for each character's actual display width (`wide` array); full-width characters occupy 2 columns. Stops when the next character would not fit.

#### `rl.width(start, endup)`

Calculates the total display width of all characters in the `[start, endup)` range.

#### `rl.read_data(pos, width, what)`

Reads a range of the codepoint or width array.

**Parameters**:
- `pos`: Start position
- `width`: Number of characters to read
- `what`: 0 returns the `code` array, non-zero returns the `wide` array

Automatically handles boundary clamping.

### Cursor Blink Methods

#### `rl.blink(millisec)`

Determines whether the cursor should be blinking (invisible) based on the current timestamp.

**Parameter**: `millisec` — Current time in milliseconds (obtained via `float2nr(reltimefloat(reltime()) * 1000)`).

**Returns**: `0` cursor visible, `1` cursor hidden (blinking).

**Blink rhythm**:
- After the first call, waits 500ms without blinking
- Then alternates at 300ms visible / 300ms hidden

**Timer reset**: Any operation that moves the cursor (`move`, `insert`, `delete`, `backspace`) resets `timer` to -1, and the next `blink()` call restarts the timer.

### Mouse Interaction Methods

#### `rl.mouse_click(winpos, offset)`

Converts a mouse click display position to a character position.

**Parameters**:
- `winpos`: Viewport start character position
- `offset`: Click position column offset relative to the viewport left edge

**Returns**: Corresponding character position (clamped to `[0, size]`).

### History Methods

History is a list of strings, with `index` pointing to the currently browsed entry. `index=0` is typically the current input (empty string or text the user is editing).

#### `rl.history_init(history)`

Initializes the history.

**Parameter**: `history` — List of history strings (oldest to newest).

**Behavior**: Reverses the input list, appends an empty string as a placeholder for "current input", and sets `index` to 0.

#### `rl.history_save()`

Saves the current editing content to the history at the current position.

#### `rl.history_prev()`

Browses the previous history entry. First saves the current content, then increments `index` (wrapping around), and loads the corresponding history text.

#### `rl.history_next()`

Browses the next history entry. First saves the current content, then decrements `index` (wrapping around), and loads the corresponding history text.

### Key Handling Methods

#### `rl.feed(char)`

Processes a single key input — this is readline's core input entry point.

**Parameter**: `char` — Key string (can be special keys like `"\<BS>"`, `"\<LEFT>"`, etc.).

**Returns**: `0` means the key was handled, `-1` means an unrecognized control key.

**Supported keys**:

| Key | Behavior |
|-----|----------|
| `<BS>` | If selection exists, delete selection; otherwise backspace one character |
| `<Delete>` / `<C-d>` | If selection exists, delete selection; otherwise forward-delete one character |
| `<Left>` / `<C-b>` | If selection exists, jump to selection left end and clear selection; otherwise move left one character |
| `<Right>` / `<C-f>` | If selection exists, jump to selection right end and clear selection; otherwise move right one character |
| `<Home>` / `<C-a>` | Jump to line start, clear selection |
| `<End>` / `<C-e>` | Jump to line end, clear selection |
| `<Up>` | Browse previous history, clear selection |
| `<Down>` | Browse next history, clear selection |
| `<S-Left>` | Extend selection leftward (sets anchor on first press) |
| `<S-Right>` | Extend selection rightward (sets anchor on first press) |
| `<S-Home>` | Extend selection to line start |
| `<S-End>` | Extend selection to line end |
| `<C-k>` | If selection exists, delete selection; otherwise delete from cursor to line end |
| `<C-w>` | If selection exists, delete selection; otherwise delete previous word (including trailing whitespace) |
| `<C-c>` | Copy selection text to register `"0` |
| `<C-x>` | Cut selection text to register `"0` |
| `<C-v>` | Paste from register `"0` (deletes selection first if exists) |
| `<C-Insert>` | Copy selection text to system clipboard `"*` |
| `<S-Insert>` | Paste from system clipboard `"*` (deletes selection first if exists) |
| Regular characters | If selection exists, delete selection first, then insert at cursor position |

**Note**: `feed()` does not handle `<CR>`, `<ESC>`, and `<C-C>` — these are handled directly by the upper layer (input.vim).

### Debug Methods

#### `rl.echo(blink [, pos, size])`

Displays the editing state directly in the command line (using `echohl` + `echon`).

**Parameters**:
- `blink`: Blink state (0=cursor visible, 1=cursor hidden)
- `pos` (optional): Viewport start position
- `size` (optional): Viewport width

Without pos/size, displays the full content. Primarily used for standalone testing (the `quickui#readline#cli` function).

## Usage Flow in input.vim

Here is the typical flow of how `quickui#input` uses the readline object:

```vim
" 1. Create a readline instance
let rl = quickui#readline#new()

" 2. Set initial text (if any)
call rl.set('initial text')
call rl.seek(0, 2)          " move cursor to end

" 3. Initialize history
let rl.history = [''] + previous_history_list

" 4. Main loop
let pos = 0                 " viewport start position
while not_exited
    " 4a. Calculate viewport position
    let pos = rl.slide(pos, window_width)

    " 4b. Render
    let display = rl.render(pos, window_width)

    " 4c. Draw to popup window (set highlight based on attr)
    for [attr, text] in display
        " Use quickui#core#high_region to set corresponding highlight groups
    endfor

    " 4d. Get keypress
    let ch = getchar()

    " 4e. Special key handling
    if ch == "\<CR>"
        let result = rl.update()    " get final text
        call rl.history_save()
        break
    elseif ch == "\<ESC>"
        break
    endif

    " 4f. Pass other keys to readline
    call rl.feed(ch)
endwhile
```

## Testing

The module includes built-in test functions:

- `quickui#readline#test()` — Unit tests verifying basic editing operation correctness
- `quickui#readline#cli(prompt)` — Interactive command-line test for experiencing readline behavior in Vim

```vim
" Run unit tests
:echo quickui#readline#test()

" Run interactive test
:echo quickui#readline#cli(">>> ")
```

## Notes

1. **`text` may be stale**: Modification operations only update `code`/`wide`/`size`; the `text` string requires an explicit `update()` call to sync. Do not read `self.text` directly to get the current content.
2. **Selection convention**: `select` is the anchor, `cursor` is the active end. `select` can be greater than or less than `cursor`. `visual_range()` returns a normalized `[min, max)` range.
3. **Vim/Neovim compatibility**: The `s:list_slice()` helper function handles the difference between Vim's `slice()` and Neovim's list slicing syntax (Neovim lacks the `slice()` built-in function).
4. **Paste behavior**: Only the first line is taken when pasting (`split(text, "\n", 1)[0]`), and newlines and tabs are replaced with spaces.
5. **Word deletion** (`<C-w>`): Uses `\S\+\s*$` to match the last non-whitespace word before the cursor along with its trailing whitespace.
6. **History wrapping**: `history_prev()` and `history_next()` wrap around when reaching the list boundary.
