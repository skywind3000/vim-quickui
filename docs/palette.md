# QuickUI Palette Module Reference

> **File**: `autoload/quickui/palette.vim` (legacy VimScript), `autoload/quickui/palette9.vim` (Vim9script accelerated)
> **Dependencies**: None
> **Requires**: Vim 8.0+ / Neovim 0.4+

## Overview

`quickui#palette` provides color conversion and matching utilities for terminal environments. It maintains the standard 256-color xterm palette and offers functions to:

- Convert between hex color strings, RGB tuples, and terminal color indices
- Find the closest terminal color index for any given RGB value (best-fit matching)
- Alpha-blend two colors
- Look up colors by name

This module is used by `quickui#highlight` to translate GUI colors (`guifg`/`guibg`) into terminal color indices (`ctermfg`/`ctermbg`) when manipulating highlight groups programmatically.

### Performance

When Vim 9.0+ with `vim9script` support is available, the module automatically imports `palette9.vim` which re-implements the hot-path functions in Vim9script, achieving approximately **40x** speedup for color matching operations.

## Data Structures

### `g:quickui#palette#colors`

A List of 256 Dicts, one per xterm color, each containing:

| Field | Type | Description |
|-------|------|-------------|
| `color` | Number | Color index (0-255) |
| `name` | String | Color name (e.g., `'Navy'`, `'Grey53'`) |
| `hex` | String | Hex RGB value (e.g., `'#000080'`) |

Layout:
- 0-7: Standard 8 colors (Black, Maroon, Green, Olive, Navy, Purple, Teal, Silver)
- 8-15: High-intensity 8 colors (Grey, Red, Lime, Yellow, Blue, Fuchsia, Aqua, White)
- 16-231: 6x6x6 RGB color cube
- 232-255: 24-step grayscale ramp (Grey3 to Grey93)

### `g:quickui#palette#rgb`

A List of 256 `[r, g, b]` tuples (0-255 each), derived from `g:quickui#palette#colors` at load time.

### `g:quickui#palette#name`

A Dict mapping lowercase color names to their color indices.

### `g:quickui#palette#number`

Number. The effective palette size for matching, defaulting to 256. Can be overridden by `g:quickui_color_num` to limit matching to fewer colors (e.g., 16 for terminals that only support 16 colors).

## Best-Fit Color Matching

The core matching algorithm uses a **weighted perceptual distance** formula:

```
distance = (dr^2 * 30^2) + (dg^2 * 59^2) + (db^2 * 11^2)
```

where `dr`, `dg`, `db` are the per-channel differences. The weights (30, 59, 11) approximate human perceptual sensitivity (green > red > blue), similar to the ITU-R BT.601 luma coefficients.

A pre-computed lookup table (`s:diff_lookup`, 1536 entries) caches `(delta^2 * weight^2)` for all possible channel differences (0-255), enabling fast distance computation without multiplication in the inner loop.

The algorithm uses **early termination**: it checks the green channel first (highest weight), then red, then blue, skipping the remaining channels if the partial sum already exceeds the current best distance.

### `quickui#palette#bestfit8(r, g, b)`

Finds the closest match in the first 8 colors (standard ANSI).

### `quickui#palette#bestfit16(r, g, b)`

Finds the closest match in the first 16 colors (standard + high-intensity ANSI).

### `quickui#palette#bestfit256(r, g, b)`

Finds the closest match in all 256 colors.

### `quickui#palette#bestfit(r, g, b)`

Finds the closest match respecting `g:quickui#palette#number` (configurable palette size).

### `quickui#palette#match(r, g, b)`

Cached version of `bestfit()`. Results are stored in an internal dictionary keyed by a quantized RGB value (divided by 4 per channel to reduce cache size). Subsequent lookups for nearby colors return instantly.

## Color Conversion Functions

### `quickui#palette#hex2rgb(hex)`

Converts a hex color string to an RGB tuple.

**Parameter**: `hex` — String in `'#RRGGBB'` format, or `'(R,G,B)'` parenthesized format.

**Returns**: `[r, g, b]` list with values 0-255.

### `quickui#palette#hex2index(hex)`

Converts a hex color string directly to the closest terminal color index.

**Returns**: Color index (0-255).

### `quickui#palette#name2index(name [, default])`

Resolves a color name to a terminal color index.

**Parameter**: `name` — Can be:
- A hex string (`'#RRGGBB'`) — converted via `hex2index()`
- A parenthesized RGB (`'(R,G,B)'`) — converted via `hex2index()`
- A color name (`'Navy'`, `'Grey53'`) — looked up in the name table
- If `v:colornames` exists (Vim 9.0+), also checks Vim's built-in color name dictionary

**Returns**: Color index, or `default` (0 if not specified) if not found.

## Alpha Blending

### `quickui#palette#blend(c1, c2, alpha)`

Alpha-blends two colors.

**Parameters**:
- `c1` — Destination color (hex string like `'#RRGGBB'`, or a single integer for per-channel blending)
- `c2` — Source color (same format as `c1`)
- `alpha` — Blend factor (0-255). 0 = full `c1`, 255 = full `c2`

**Returns**:
- If both inputs are integers: blended integer value
- If inputs are hex strings: blended hex string `'#RRGGBB'`

**Formula**: `result = c1 * (255 - alpha) / 255 + c2 * alpha / 255` (per channel)

## Desert256-Style Color Matching

An alternative matching algorithm ported from the desert256 colorscheme, supporting both 88-color and 256-color terminals. These functions use a different approach: they map RGB values to the nearest point in the 6x6x6 color cube or the 24-step grayscale ramp, choosing whichever is perceptually closer.

### `quickui#palette#color_match(r, g, b)`

Finds the closest palette index using the cube+grey algorithm.

**Logic**:
1. Compute the nearest grey index for each channel
2. Compute the nearest RGB cube index for each channel
3. If all three grey indices are equal (the color is near grey), compare the Euclidean distance to the grey ramp vs. the RGB cube and return the closer one
4. Otherwise, return the RGB cube match

### `quickui#palette#rgb_match(rgb)`

Wrapper that accepts a hex string (`'#RRGGBB'` or `'RRGGBB'`) and calls `color_match()`.

## Benchmarking

### `quickui#palette#timing()`

Runs 256 `match()` calls and returns the elapsed time as a string. Useful for comparing legacy VimScript vs. Vim9script performance.

```vim
:echo quickui#palette#timing()
```

## Vim9script Acceleration

When `has('vim9script')` is true, the module imports `palette9.vim` and replaces the following functions with Vim9script implementations:

- `bestfit8`, `bestfit16`, `bestfit256`
- `bestfit`, `match`
- `hex2rgb`, `hex2index`, `name2index`

The Vim9script versions use typed variables and compiled execution, providing approximately 40x faster color matching. The API signatures remain identical.

## Usage Examples

```vim
" Find closest 256-color index for a GUI color
let idx = quickui#palette#hex2index('#4c4846')

" Convert RGB to terminal color
let idx = quickui#palette#match(128, 64, 32)

" Look up a named color
let idx = quickui#palette#name2index('DarkCyan')

" Alpha blend two colors (50% blend)
let blended = quickui#palette#blend('#ff0000', '#0000ff', 128)
" Returns '#800080'
```
