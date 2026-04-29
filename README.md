# vim-quickui

[![GitHub Stars](https://img.shields.io/github/stars/skywind3000/vim-quickui?style=flat-square&logo=github)](https://github.com/skywind3000/vim-quickui/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![Vim](https://img.shields.io/badge/Vim-8.2+-green.svg?style=flat-square&logo=vim)](https://www.vim.org)
[![NeoVim](https://img.shields.io/badge/NeoVim-0.4+-green.svg?style=flat-square&logo=neovim)](https://neovim.io)

Borland/Turbo C++ inspired TUI widget library for Vim and NeoVim — menus, dialogs, context menus and more, all in pure VimScript with no dependencies.

![](https://skywind3000.github.io/images/p/quickui/screenshot.gif)

## Features

- **Rich widget set** — menubar, context menu, data-driven dialog, listbox, textbox, preview window, and more
- **Data-driven dialog system** — declare UI controls as data, get results as a dictionary
- **Cross-platform** — consistent experience across Vim 8.2+ and NeoVim 0.4+
- **Keyboard-driven** — navigate with `hjkl`, confirm with `Enter`, cancel with `ESC`; full mouse support
- **Customizable** — multiple color schemes (Borland, gruvbox, solarized...) and border styles
- **Pure VimScript** — no `+python`, no external dependencies, zero overhead

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'skywind3000/vim-quickui'
```

Using Vim's built-in package manager:

```bash
mkdir -p ~/.vim/pack/vendor/start
cd ~/.vim/pack/vendor/start
git clone https://github.com/skywind3000/vim-quickui
```

## Quick Start

Add a dropdown menubar to your Vim — just put this in your `.vimrc`:

```vim
" clear all the menus
call quickui#menu#reset()

" install a 'File' menu
call quickui#menu#install('&File', [
            \ [ "&Open\t(:w)", 'call feedkeys(":tabe ")'],
            \ [ "&Save\t(:w)", 'write'],
            \ [ "--", ],
            \ [ "E&xit", 'qa' ],
            \ ])

" install a 'Edit' menu
call quickui#menu#install('&Edit', [
            \ [ '&Trailing Space', 'call StripTrailingWhitespace()' ],
            \ [ 'Format J&son', '%!python -m json.tool' ],
            \ ])

" map to a key
noremap <silent><space><space> :call quickui#menu#open()<cr>
```

Press `<space><space>` and you'll see a menubar at the top of Vim — navigate with `hjkl` or mouse, pick an item with `Enter`:

![](https://skywind3000.github.io/images/p/quickui/mainmenu.png)

For a complete configuration example, see [menu_example.vim](test/menu_example.vim).

## Showcase

### Menu

The menubar displays a row of dropdown menus at the top of the screen, similar to the classic Borland/Turbo C++ IDE. Use `&` in item text to define hotkeys, and `\t` to add right-aligned annotations:

![](https://skywind3000.github.io/images/p/quickui/mainmenu.png)

Customizable border styles and color schemes:

| Border Styles | Color Schemes |
|:---:|:---:|
| ![](https://skywind3000.github.io/images/p/quickui/border2.png) | ![](https://skywind3000.github.io/images/p/quickui/colors.png) |

See: [Menu API reference](MANUAL.md#menu)

### Context Menu

A right-click style menu that appears near the cursor — ideal for presenting commands relevant to the current context:

| Default Border | Custom Border |
|:---:|:---:|
| ![](https://skywind3000.github.io/images/p/quickui/context.png) | ![](https://skywind3000.github.io/images/p/quickui/context2.png) |

```vim
let content = [
            \ ['&Help Keyword', 'echo 123' ],
            \ ['&Signature', 'echo 456' ],
            \ ['-'],
            \ ['&Peek Definition', 'echo 789'],
            \ ]
call quickui#context#open(content, {})
```

See: [Context Menu API reference](MANUAL.md#context-menu)

### Dialog

The most powerful widget in QuickUI. Declare a list of controls — inputs, radio buttons, checkboxes, dropdowns, buttons — and get all values back as a dictionary:

![](https://skywind3000.github.io/images/p/quickui/dialog1.png)

```vim
let items = [
            \ {'type': 'label', 'text': 'Settings:'},
            \ {'type': 'input', 'name': 'name', 'prompt': 'Name:', 'value': 'test'},
            \ {'type': 'radio', 'name': 'choice', 'prompt': 'Pick:', 'items': ['A', 'B', 'C']},
            \ {'type': 'check', 'name': 'flag', 'text': 'Enable Feature'},
            \ {'type': 'button', 'name': 'confirm', 'items': [' &OK ', ' &Cancel ']},
            \ ]
let result = quickui#dialog#open(items, {'title': 'Settings'})
echo result
```

Supported controls: `label`, `input`, `radio`, `check`, `button`, `separator`, `dropdown`. Navigate with `Tab`/`Shift-Tab` or hotkeys.

See: [Dialog guide](DIALOG.md) | [Tutorial](https://dev.to/skywind3000/build-real-dialogs-in-vim-no-python-no-dependencies-3b5a) | [Dialog Examples](test/test_dialog.vim)

### More Widgets

QuickUI also provides several additional widgets:

| Widget | Description | Docs |
|--------|------------|------|
| **Listbox** | Scrollable list with search (`/` or `?`) and mouse wheel support — great for buffer switching or function navigation | [Manual](MANUAL.md#listbox) |
| **Textbox** | Display arbitrary text in a popup — useful for reading help or messages without splitting windows | [Manual](MANUAL.md#textbox) |
| **Preview** | Popup preview window near cursor — glimpse definitions or quickfix results without opening files | [Manual](MANUAL.md#preview-window) |
| **Inputbox** | Single-line text input popup | [Manual](MANUAL.md#inputbox) |
| **Terminal** | Run terminal programs in a popup window | [Manual](MANUAL.md#terminal) |
| **Confirm** | Simple choice dialog | [Manual](MANUAL.md#confirm-dialog) |

| Listbox | Preview | Textbox |
|:---:|:---:|:---:|
| ![](https://skywind3000.github.io/images/p/quickui/listbox.png) | ![](https://skywind3000.github.io/images/p/quickui/preview.png) | ![](https://skywind3000.github.io/images/p/quickui/display-help.png) |

## Documentation

- **[User Manual](MANUAL.md)** — complete API reference for all widgets
- **[Dialog Guide](DIALOG.md)** — in-depth guide for the dialog system

## Related Projects

- [vim-navigator](https://github.com/skywind3000/vim-navigator) — navigate your commands easily, powered by QuickUI

## Author

Created by **Lin Wei** ([@skywind3000](https://github.com/skywind3000)), an open-source advocate and long-time Vim user. This project is inspired by the Borland/Turbo C++ IDE from the 1990s — an attempt to bring that classic TUI experience into modern Vim.

![](https://skywind3000.github.io/images/p/quickui/editor.png)

*A Turbo C++ style editor I wrote for Watcom C++ back in the day*

## License

[MIT](LICENSE)

---

Like vim-quickui? Star the repo on [GitHub](https://github.com/skywind3000/vim-quickui) and vote on [vim.org](https://www.vim.org/scripts/script.php?script_id=5845).
Follow [@skywind3000](https://twitter.com/skywind3000) on Twitter for updates.
